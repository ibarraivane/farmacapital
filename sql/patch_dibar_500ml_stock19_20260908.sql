-- Alcohol Dibar rojo 500 ml (FC-68990023)
-- Conteo de mostrador 8-sep-2026: había 20, se vendió 1 → 19.
-- Escribir solo productos.stock no sirve: el trigger lo vuelve a 0
-- si el lote está vacío. Aquí se ajusta el lote (sin inventar MMAA).
-- Idempotente: si la suma de lotes activos ya es 19, no toca cantidades.

begin;

-- EAN del bote (por si este SQL se pega solo)
update public.productos
   set codigo_barras = null
 where codigo_barras = '7501868900233'
   and sku is distinct from 'FC-68990023';

update public.productos
   set codigo_barras = '7501868900233',
       marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
       presentacion = coalesce(nullif(btrim(presentacion), ''), '500 ML')
 where sku = 'FC-68990023'
    or codigo_barras in ('7501868990023', '7501868900233');

do $$
declare
  v_pid bigint;
  v_lote bigint;
  v_sum integer;
  v_costo numeric;
begin
  select id, costo into v_pid, v_costo
    from public.productos
   where sku = 'FC-68990023'
   limit 1;

  if v_pid is null then
    raise exception 'No está FC-68990023 (Alcohol Dibar 500 ml)';
  end if;

  select coalesce(sum(l.cantidad_actual), 0) into v_sum
    from public.lotes l
   where l.producto_id = v_pid
     and coalesce(l.activo, true);

  if v_sum = 19 then
    return;
  end if;

  select l.id into v_lote
    from public.lotes l
   where l.producto_id = v_pid
   order by coalesce(l.activo, true) desc,
            coalesce(l.cantidad_actual, 0) desc,
            l.id desc
   limit 1;

  if v_lote is null then
    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_pid, 'INV-CONTEO-20260908', 19, 19,
      null, v_costo, true
    )
    returning id into v_lote;
  else
    update public.lotes
       set cantidad_actual = 0,
           activo = false
     where producto_id = v_pid
       and id <> v_lote
       and coalesce(activo, true)
       and coalesce(cantidad_actual, 0) > 0;

    update public.lotes
       set cantidad_actual = 19,
           activo = true,
           cantidad_inicial = greatest(coalesce(cantidad_inicial, 0), 19)
     where id = v_lote;
  end if;

  insert into public.movimientos_inventario (
    producto_id, tipo, cantidad, motivo
  ) values (
    v_pid, 'ajuste', 19,
    'Conteo mostrador 8-sep-2026: 20 en anaquel − 1 vendida = 19. No inventa caducidad.'
  );
end $$;

commit;

select p.sku, p.codigo_barras, p.nombre, p.presentacion, p.stock,
       l.id as lote_id, l.numero_lote, l.cantidad_actual, l.fecha_caducidad, l.activo
  from public.productos p
  left join public.lotes l on l.producto_id = p.id
 where p.sku = 'FC-68990023'
 order by l.activo desc nulls last, l.id;
