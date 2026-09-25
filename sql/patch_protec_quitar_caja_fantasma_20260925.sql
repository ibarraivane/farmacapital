-- Protec bandas FC-48640676: quitar caja fantasma (doble conteo).
--
-- Estado malo (ficha Inventario):
--   stock (cajas) = 1
--   stock_unidades = 99
--   lote REINTEGRO-20260925-… cad 2030-01-01
--
-- Realidad: 1 caja C/100 abierta, −1 vendida fuera del sistema →
-- 99 piezas sueltas, 0 cajas cerradas.
--
-- Cómo se rompió: abrir-caja pasó a sueltas; un reintegro
-- (venta fallida / restock_via_lote) inventó REINTEGRO +1 caja.
--
-- Fix: apaga REINTEGRO, stock cajas = 0, sueltas = 99.
-- Caducidad real Degasa: 503500048 · 2029-03-31 (no 2030-01-01).
-- Idempotente. Supabase → SQL Editor → Run.

begin;

select
  p.id,
  p.sku,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja,
  p.precio_unidad,
  l.id as lote_id,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo as lote_activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.codigo_barras = '7501048640676'
   or p.sku in ('FC-48640676', 'FC-ND-48640676')
   or p.id = 19700
order by p.id, l.id;

do $$
declare
  v_pid bigint;
  v_sueltas integer;
begin
  select p.id, coalesce(p.stock_unidades, 0)
    into v_pid, v_sueltas
  from public.productos p
  where p.activo = true
    and (
      p.codigo_barras = '7501048640676'
      or p.sku in ('FC-48640676', 'FC-ND-48640676')
      or p.id = 19700
    )
  order by case
    when p.codigo_barras = '7501048640676' then 0
    when p.sku = 'FC-48640676' then 1
    else 2
  end, p.id
  limit 1;

  if v_pid is null then
    raise notice 'Protec no encontrado';
    return;
  end if;

  -- 1) Apaga reintegros sintéticos.
  update public.lotes
     set cantidad_actual = 0,
         activo = false
   where producto_id = v_pid
     and numero_lote ilike 'REINTEGRO%';

  -- 2) Si ya hay sueltas, ninguna caja cerrada puede quedar viva
  --    (la pieza física ya está abierta en mostrador).
  if v_sueltas > 0 then
    update public.lotes
       set cantidad_actual = 0,
           activo = false
     where producto_id = v_pid
       and coalesce(cantidad_actual, 0) > 0;
  end if;

  -- 3) Lote Degasa real: metadatos correctos, cantidad 0.
  if exists (
    select 1 from public.lotes
    where producto_id = v_pid and numero_lote = '503500048'
  ) then
    update public.lotes set
      fecha_caducidad = coalesce(fecha_caducidad, '2029-03-31'::date),
      cantidad_actual = 0,
      activo = false
    where producto_id = v_pid
      and numero_lote = '503500048';
  else
    insert into public.lotes (
      producto_id, numero_lote, fecha_caducidad,
      cantidad_inicial, cantidad_actual, activo
    ) values (
      v_pid, '503500048', '2029-03-31'::date,
      1, 0, false
    );
  end if;

  -- 4) Contadores: 0 cajas + 99 sueltas (o las que ya tenga si 1..100).
  update public.productos set
    stock = 0,
    stock_unidades = case
      when coalesce(stock_unidades, 0) between 1 and 100 then stock_unidades
      else 99
    end,
    venta_unidad = true,
    unidades_por_caja = 100,
    precio_unidad = case when coalesce(precio_unidad, 0) <= 0 then 1 else precio_unidad end,
    presentacion = coalesce(nullif(btrim(presentacion), ''), 'Caja C/100')
  where id = v_pid;

  raise notice 'Protec id %: cajas=0 sueltas=%',
    v_pid,
    (select stock_unidades from public.productos where id = v_pid);
end $$;

commit;

select
  p.id,
  p.sku,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja,
  p.precio_unidad,
  l.id as lote_id,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo as lote_activo
from public.productos p
left join public.lotes l on l.producto_id = p.id
where p.codigo_barras = '7501048640676'
   or p.sku in ('FC-48640676', 'FC-ND-48640676')
   or p.id = 19700
order by p.id, l.id;
