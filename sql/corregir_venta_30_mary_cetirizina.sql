-- FarmaCapital — Corregir VTA-00000030 (restaurada mal).
--
-- Qué salió mal al restaurar desde kardex:
--   1) atendido_por = quien BORRÓ (admin), no Mary Yen que vendió.
--   2) tipo_entrega quedó en "pickup" (default de la columna; el POS manda null).
--   3) precios = catálogo actual (~$32), no el cobrado ($21).
--
-- Ticket real: cetirizina 10 mg caja c/10, $21, mostrador POS, Mary Yen.
--
-- Corre TODO en Supabase → SQL Editor → Run.
-- Recarga Transacciones. Si el bloque 6 no encuentra el producto, pégame
-- el resultado de las consultas 1–5.

-- 1) Ticket actual
select
  p.id,
  p.created_at at time zone 'America/Mexico_City' as hora,
  p.total, p.metodo_pago, p.tipo, p.tipo_entrega, p.estado, p.notas,
  p.atendido_por, u.nombre as atendido_nombre
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
where p.id = 30;

-- 2) Partidas actuales
select i.id, i.producto_id, pr.sku, pr.nombre, i.cantidad, i.precio_unitario,
       (i.cantidad * i.precio_unitario) as subtotal, i.lote_id
from public.pedido_items i
left join public.productos pr on pr.id = i.producto_id
where i.pedido_id = 30
order by i.id;

-- 3) Kardex del folio (la primera SALIDA es la venta de Mary)
select
  m.created_at at time zone 'America/Mexico_City' as cuando,
  m.tipo, m.cantidad, m.motivo, m.referencia, m.usuario_id,
  u.nombre as usuario, m.producto_id, pr.nombre, pr.sku, pr.precio
from public.movimientos_inventario m
left join public.usuarios u on u.id = m.usuario_id
left join public.productos pr on pr.id = m.producto_id
where m.referencia = '30'
   or m.motivo ilike '%pedido #30%'
order by m.created_at;

-- 4) Perfil de Mary Yen
select id, nombre, rol, activo
from public.usuarios
where nombre ilike '%mary%'
order by id;

-- 5) Candidatos cetirizina 10 mg
select id, sku, codigo_barras, nombre, precio, stock, principio_activo, concentracion, presentacion
from public.productos
where coalesce(activo, true) = true
  and (
    nombre ilike '%cetirizin%'
    or coalesce(principio_activo, '') ilike '%cetirizin%'
  )
order by
  case when sku = 'FC-27872123' then 0 else 1 end,
  case when nombre ilike '%10%mg%' or coalesce(concentracion,'') ilike '%10%' then 0 else 1 end,
  nombre;

-- 6) Default de tipo_entrega (si es pickup, lo quitamos abajo)
select column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'pedidos'
  and column_name = 'tipo_entrega';


-- 7) Aplicar corrección
do $$
declare
  v_folio        bigint := 30;
  v_mary_id      bigint;
  v_vendedor_id  bigint;
  v_prod_id      bigint;
  v_lote_id      bigint;
  v_old          record;
  v_qty_old      int;
  v_precio       numeric := 21;
  v_qty          int := 1;
begin
  if not exists (select 1 from public.pedidos where id = v_folio) then
    raise exception 'No existe el pedido #%. Corre primero restaurar_venta_borrada_hoy.sql', v_folio;
  end if;

  -- Vendedora: primera salida del folio (Mary), con fallback por nombre
  select m.usuario_id into v_vendedor_id
  from public.movimientos_inventario m
  where m.tipo = 'salida'
    and (m.referencia = v_folio::text or m.motivo ilike '%pedido #' || v_folio::text || '%')
    and m.motivo not ilike '%Restauración%'
    and m.motivo not ilike '%Corrección%'
  order by m.created_at asc
  limit 1;

  select id into v_mary_id
  from public.usuarios
  where nombre ilike '%mary%yen%'
     or nombre ilike '%mary yen%'
     or (nombre ilike '%mary%' and coalesce(rol, '') in ('vendedor', 'vendedora', 'empleado'))
  order by
    case when nombre ilike '%yen%' then 0 else 1 end,
    id
  limit 1;

  v_vendedor_id := coalesce(v_mary_id, v_vendedor_id);
  if v_vendedor_id is null then
    raise exception 'No encontré el usuario de Mary Yen. Revisa la consulta 4.';
  end if;

  -- Producto: SKU Raamcinet, o el de la salida original si es cetirizina, o búsqueda
  select id into v_prod_id
  from public.productos
  where sku = 'FC-27872123'
     or codigo_barras = '7502227872123'
  limit 1;

  if v_prod_id is null then
    select m.producto_id into v_prod_id
    from public.movimientos_inventario m
    join public.productos pr on pr.id = m.producto_id
    where m.tipo = 'salida'
      and (m.referencia = v_folio::text or m.motivo ilike '%pedido #' || v_folio::text || '%')
      and (
        pr.nombre ilike '%cetirizin%'
        or coalesce(pr.principio_activo, '') ilike '%cetirizin%'
      )
    order by m.created_at asc
    limit 1;
  end if;

  if v_prod_id is null then
    select id into v_prod_id
    from public.productos
    where coalesce(activo, true) = true
      and (
        nombre ilike '%cetirizin%'
        or coalesce(principio_activo, '') ilike '%cetirizin%'
      )
      and (
        nombre ~* '10\s*mg'
        or coalesce(concentracion, '') ~* '10'
        or nombre ilike '%10 mg%'
      )
    order by
      case when nombre ilike '%c/10%' or nombre ilike '%c 10%' or nombre ilike '%10 tab%' then 0 else 1 end,
      id
    limit 1;
  end if;

  if v_prod_id is null then
    raise exception 'No encontré cetirizina 10 mg c/10. Pégame el resultado de la consulta 5.';
  end if;

  -- Reintegrar lo que la restauración dejó en el ticket (si no es ya 1 caja de ese producto)
  for v_old in
    select producto_id, sum(cantidad)::int as cantidad, max(lote_id) as lote_id
    from public.pedido_items
    where pedido_id = v_folio
    group by producto_id
  loop
    v_qty_old := coalesce(v_old.cantidad, 0);
    if v_old.producto_id = v_prod_id and v_qty_old = v_qty then
      continue;
    end if;
    if v_old.producto_id is not null and v_qty_old > 0 then
      if v_old.producto_id = v_prod_id then
        -- Misma caja, cantidad distinta (p.ej. 10 piezas vs 1 empaque)
        update public.lotes
           set cantidad_actual = coalesce(cantidad_actual, 0) + (v_qty_old - v_qty),
               activo = true
         where id = coalesce(
           v_old.lote_id,
           (select l.id from public.lotes l
             where l.producto_id = v_prod_id
             order by l.fecha_caducidad nulls last, l.id
             limit 1)
         );
      else
        update public.lotes
           set cantidad_actual = coalesce(cantidad_actual, 0) + v_qty_old,
               activo = true
         where id = coalesce(
           v_old.lote_id,
           (select l.id from public.lotes l
             where l.producto_id = v_old.producto_id
             order by l.fecha_caducidad nulls last, l.id
             limit 1)
         );
      end if;
    end if;
  end loop;

  -- Si el ticket no tenía ese producto, descontar 1 caja
  if not exists (
    select 1 from public.pedido_items
    where pedido_id = v_folio and producto_id = v_prod_id
  ) then
    select l.id into v_lote_id
    from public.lotes l
    where l.producto_id = v_prod_id
    order by (coalesce(l.cantidad_actual, 0) > 0) desc, l.fecha_caducidad nulls last, l.id
    limit 1;

    if v_lote_id is not null then
      update public.lotes
         set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - v_qty),
             activo = case
               when greatest(0, coalesce(cantidad_actual, 0) - v_qty) <= 0 then false
               else activo
             end
       where id = v_lote_id;
    end if;
  else
    select max(lote_id) into v_lote_id
    from public.pedido_items
    where pedido_id = v_folio and producto_id = v_prod_id;
  end if;

  delete from public.pedido_items where pedido_id = v_folio;

  insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario, lote_id)
  values (v_folio, v_prod_id, v_qty, v_precio, v_lote_id);

  update public.pedidos
     set atendido_por = v_vendedor_id,
         tipo         = 'pos',
         tipo_entrega = null,
         total        = v_precio * v_qty,
         estado       = 'completado',
         notas        = 'Venta mostrador. Corregida: Mary Yen, cetirizina 10 mg c/10 $21.'
   where id = v_folio;

  raise notice 'Pedido #%: atendido_por=%, producto=%, total=$%',
    v_folio, v_vendedor_id, v_prod_id, v_precio * v_qty;
end $$;

-- Quitar default "pickup" para que el POS no se contamine
alter table public.pedidos alter column tipo_entrega drop default;

-- Ventas de mostrador no deben llevar pickup (valor inválido; el contrato es recoger|envio|null)
update public.pedidos
   set tipo_entrega = null
 where coalesce(tipo, '') in ('pos', 'tienda_fisica', 'fisica')
   and tipo_entrega in ('pickup', 'recoger');

-- Confirmación
select
  p.id,
  p.created_at at time zone 'America/Mexico_City' as hora,
  p.total, p.metodo_pago, p.tipo, p.tipo_entrega, p.estado,
  u.nombre as atendido_por,
  pr.sku, pr.nombre, i.cantidad, i.precio_unitario
from public.pedidos p
left join public.usuarios u on u.id = p.atendido_por
left join public.pedido_items i on i.pedido_id = p.id
left join public.productos pr on pr.id = i.producto_id
where p.id = 30;
