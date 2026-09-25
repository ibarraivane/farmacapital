-- Protec bandas C/100: abrir caja → piezas sueltas
--
-- Qué pasa: el POS vende «Pieza» desde stock_unidades.
-- Recibir / el alta dejaron 1 caja (stock=1) y 0 sueltas →
-- error «piezas sueltas insuficientes … (faltan 2)» aunque la caja tiene 100.
--
-- Misma lógica que abrir_caja_lote: −1 caja FEFO, +unidades_por_caja sueltas.
-- Idempotente si ya hay sueltas. Supabase → SQL Editor → Run.

begin;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja,
  p.precio_unidad,
  p.venta_unidad
from public.productos p
where p.id = 19700
   or p.codigo_barras = '7501048640676'
   or p.sku in ('FC-48640676', 'FC-ND-48640676')
order by p.id;

do $$
declare
  v_pid bigint;
  v_upc integer;
  v_lote_id bigint;
  v_sueltas integer;
  v_cajas integer;
begin
  select p.id,
         greatest(coalesce(p.unidades_por_caja, 100), 1),
         coalesce(p.stock_unidades, 0),
         coalesce(p.stock, 0)
    into v_pid, v_upc, v_sueltas, v_cajas
  from public.productos p
  where p.activo = true
    and (
      p.id = 19700
      or p.codigo_barras = '7501048640676'
      or p.sku in ('FC-48640676', 'FC-ND-48640676')
    )
  order by case
    when p.codigo_barras = '7501048640676' then 0
    when p.id = 19700 then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    raise notice 'Protec no encontrado';
    return;
  end if;

  -- Asegura flags de venta suelta aunque ya haya piezas.
  update public.productos set
    venta_unidad = true,
    unidades_por_caja = v_upc,
    precio_unidad = case when coalesce(precio_unidad, 0) <= 0 then 1 else precio_unidad end,
    presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja C/100')
  where id = v_pid;

  if v_sueltas > 0 then
    -- Ya hay sueltas: si quedó stock/caja fantasma (REINTEGRO), limpia.
    if v_cajas > 0 then
      update public.lotes set
        cantidad_actual = 0,
        activo = false
      where producto_id = v_pid
        and coalesce(cantidad_actual, 0) > 0;
      update public.productos set
        stock = 0,
        venta_unidad = true,
        unidades_por_caja = v_upc,
        precio_unidad = case when coalesce(precio_unidad, 0) <= 0 then 1 else precio_unidad end
      where id = v_pid;
      raise notice 'Protec id %: ya tenía % sueltas; se quitó caja fantasma (stock→0)', v_pid, v_sueltas;
    else
      raise notice 'Protec id % ya tiene % sueltas; ok', v_pid, v_sueltas;
    end if;
    return;
  end if;

  select l.id into v_lote_id
  from public.lotes l
  where l.producto_id = v_pid
    and coalesce(l.activo, true)
    and coalesce(l.cantidad_actual, 0) >= 1
  order by l.fecha_caducidad nulls first, l.id
  limit 1;

  if v_lote_id is null and v_cajas <= 0 then
    -- Sin caja ni lote: deja las 100 sueltas para no frenar mostrador
    -- (caja física ya abierta; no inventar lote).
    update public.productos set
      stock_unidades = v_upc,
      stock = 0
    where id = v_pid;
    raise notice 'Protec id %: sin lote/caja → stock_unidades=% (caja ya abierta en piso)', v_pid, v_upc;
    return;
  end if;

  if v_lote_id is not null then
    update public.lotes set
      cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - 1),
      activo = case
        when greatest(0, coalesce(cantidad_actual, 0) - 1) <= 0 then false
        else activo
      end
    where id = v_lote_id;
  end if;

  update public.productos set
    stock_unidades = v_upc,
    stock = (
      select coalesce(sum(l.cantidad_actual), 0)::integer
      from public.lotes l
      where l.producto_id = v_pid
        and coalesce(l.activo, true)
    )
  where id = v_pid;

  raise notice 'Protec id %: abierta 1 caja → % piezas sueltas', v_pid, v_upc;
end $$;

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja,
  p.precio_unidad,
  p.venta_unidad
from public.productos p
where p.id = 19700
   or p.codigo_barras = '7501048640676'
   or p.sku in ('FC-48640676', 'FC-ND-48640676')
order by p.id;
