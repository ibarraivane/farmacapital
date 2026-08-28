-- FarmaCapital — ¿Dónde quedó la venta borrada? Diagnóstico + restore.
-- El botón Eliminar borra pedidos y partidas. NO guarda el ticket completo
-- en audit_log (solo "se reintegró N ítems"). La foto de la fila sólo existe
-- si el trigger de audit_log_detallado está instalado.
-- El kardex (movimientos_inventario) casi siempre SÍ deja rastro.
--
-- Corre TODO en Supabase → SQL Editor → Run.
-- En el selector de resultados verás varias tablas. Pégame las 1–4 si
-- esto no restaura sola.

-- 1) ¿Está el trigger de auditoría en pedidos?
select event_object_table as tabla, trigger_name, event_manipulation
from information_schema.triggers
where event_object_schema = 'public'
  and event_object_table in ('pedidos', 'pedido_items', 'movimientos_inventario')
  and trigger_name ilike '%audit%'
order by 1, 3;

-- 2) Log simple: "se eliminó el pedido" (sin productos ni total)
select
  created_at at time zone 'America/Mexico_City' as cuando,
  accion, tabla, registro_id as folio, detalle
from public.audit_log
where created_at > now() - interval '24 hours'
  and (
    accion ilike '%pedido%'
    or accion ilike '%venta%'
    or tabla in ('pedidos', 'pedido_items')
  )
order by created_at desc
limit 40;

-- 3) Kardex de hoy: ventas y reintegros por borrado
select
  m.created_at at time zone 'America/Mexico_City' as cuando,
  m.tipo, m.cantidad, m.motivo, m.referencia,
  m.producto_id, p.nombre, p.sku, p.precio
from public.movimientos_inventario m
left join public.productos p on p.id = m.producto_id
where m.created_at > now() - interval '24 hours'
  and (
    m.motivo ilike '%pedido%'
    or m.motivo ilike '%venta%'
    or m.motivo ilike '%reintegro%'
    or m.motivo ilike '%eliminaci%'
  )
order by m.created_at desc
limit 80;

-- 4) Pedidos de hoy (por si estaba cancelada, no borrada)
select id, created_at at time zone 'America/Mexico_City' as hora,
       total, metodo_pago, tipo, estado, atendido_por
from public.pedidos
where created_at > now() - interval '24 hours'
order by created_at desc
limit 30;


-- 5) Restaurar desde kardex si hay un "Reintegro por eliminación de pedido #N"
--    y ese folio ya no existe. Precios = precio actual del catálogo (no el cobrado).
do $$
declare
  v_folio bigint;
  v_user  bigint;
  v_total numeric := 0;
  r       record;
  v_items int := 0;
  v_precio numeric;
begin
  select substring(m.motivo from 'pedido #([0-9]+)')::bigint
    into v_folio
  from public.movimientos_inventario m
  where m.created_at > now() - interval '24 hours'
    and m.tipo = 'entrada'
    and m.motivo ilike '%eliminaci%pedido%'
  order by m.created_at desc
  limit 1;

  if v_folio is null then
    select registro_id::bigint into v_folio
    from public.audit_log
    where created_at > now() - interval '24 hours'
      and accion = 'eliminar_pedido'
    order by created_at desc
    limit 1;
  end if;

  if v_folio is null then
    raise notice 'No hay rastro de un pedido eliminado en las últimas 24 h.';
    return;
  end if;

  if exists (select 1 from public.pedidos where id = v_folio) then
    raise notice 'El folio % ya existe en pedidos (no hace falta restaurar, o quedó cancelado).', v_folio;
    return;
  end if;

  -- Quien vendió = primera SALIDA, no el admin que reintegró al borrar.
  select m.usuario_id::bigint into v_user
  from public.movimientos_inventario m
  where m.tipo = 'salida'
    and (m.referencia = v_folio::text or m.motivo ilike '%pedido #' || v_folio::text || '%')
  order by m.created_at asc
  limit 1;

  -- Total aproximado con precio actual
  select coalesce(sum(m.cantidad * coalesce(p.precio, 0)), 0)
    into v_total
  from public.movimientos_inventario m
  left join public.productos p on p.id = m.producto_id
  where m.tipo = 'salida'
    and (
      m.referencia = v_folio::text
      or m.motivo ilike '%pedido #' || v_folio::text || '%'
    )
    and m.motivo not ilike '%Restauración%';

  insert into public.pedidos (
    id, total, estado, tipo, tipo_entrega, metodo_pago, atendido_por, notas, created_at
  )
  select
    v_folio,
    v_total,
    'completado',
    'pos',
    null,
    'efectivo',
    v_user,
    'Restaurada tras borrado accidental. Verificar método de pago y precios.',
    coalesce(
      (select min(created_at) from public.movimientos_inventario
        where referencia = v_folio::text or motivo ilike '%pedido #' || v_folio::text || '%'),
      now()
    )
  where not exists (select 1 from public.pedidos where id = v_folio);

  for r in
    select m.producto_id, sum(m.cantidad)::int as cantidad
    from public.movimientos_inventario m
    where m.tipo = 'salida'
      and (
        m.referencia = v_folio::text
        or m.motivo ilike '%pedido #' || v_folio::text || '%'
      )
      and m.motivo not ilike '%Restauración%'
      and m.producto_id is not null
    group by m.producto_id
  loop
    select coalesce(precio, 0) into v_precio from public.productos where id = r.producto_id;
    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_folio, r.producto_id, r.cantidad, v_precio);
    v_items := v_items + 1;

    -- Volver a descontar lo que el borrado reintegró
    begin
      update public.lotes
         set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - r.cantidad)
       where id = (
         select l.id from public.lotes l
          where l.producto_id = r.producto_id
          order by l.fecha_caducidad nulls last, l.id
          limit 1
       );
    exception when others then
      raise notice 'Stock producto %: %', r.producto_id, SQLERRM;
    end;
  end loop;

  raise notice 'Restaurada venta folio % con % partida(s), total aprox %. Revisa método de pago.',
    v_folio, v_items, v_total;
end $$;

-- Confirmación
select id, created_at at time zone 'America/Mexico_City' as hora,
       total, metodo_pago, tipo, estado, notas
from public.pedidos
where id in (
  select substring(motivo from 'pedido #([0-9]+)')::bigint
  from public.movimientos_inventario
  where created_at > now() - interval '24 hours'
    and motivo ilike '%pedido%'
)
order by created_at desc;
