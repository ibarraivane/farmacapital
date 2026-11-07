-- Corregir caducidad: Colgate Total Advanced Clean 75 ml
-- EAN 7509546052632 · SKU FC-46052632 · lote RX-28130-5942 (id 3056)
-- Hoy en BD: 2026-10-31 (MMAA 1026 = OCT26 del ticket Bodega F-42 28130).
--
-- ANTES DE CORRER: poner en v_nueva la fecha REAL de la caja (último día del mes).
-- Ejemplo: caja dice sep 2028 → '2028-09-30'. Nunca inventar.
-- Si v_nueva queda NULL, el script no cambia nada (solo reporta).

begin;

do $$
declare
  v_pid bigint := 20250;
  v_lote bigint := 3056;
  -- >>> completar con la caja (o dejar null para no tocar) <<<
  v_nueva date := null; -- p. ej. '2028-09-30'::date
  v_prev date;
  v_num text;
  v_qty integer;
begin
  select l.fecha_caducidad, l.numero_lote, l.cantidad_actual
    into v_prev, v_num, v_qty
  from public.lotes l
  where l.id = v_lote
    and l.producto_id = v_pid
  for update;

  if not found then
    raise exception 'No está el lote % del producto %', v_lote, v_pid;
  end if;

  raise notice 'Antes: lote % (%) caducidad=% qty=%', v_lote, v_num, v_prev, v_qty;

  if v_nueva is null then
    raise notice 'v_nueva es null — no se actualiza. Pon la fecha de la caja y vuelve a correr.';
    return;
  end if;

  if v_nueva is not distinct from v_prev then
    raise notice 'Ya tiene % — nada que hacer.', v_prev;
    return;
  end if;

  update public.lotes
  set fecha_caducidad = v_nueva
  where id = v_lote
    and producto_id = v_pid;

  update public.recepcion_items
  set fecha_caducidad = v_nueva
  where lote_id = v_lote
     or (
       producto_id = v_pid
       and codigo_escaneado = '7509546052632'
       and fecha_caducidad is not distinct from v_prev
     );

  raise notice 'Después: caducidad % → %', v_prev, v_nueva;
end $$;

-- Verificación
select
  l.id,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  p.sku,
  p.nombre
from public.lotes l
join public.productos p on p.id = l.producto_id
where l.id = 3056;

commit;
