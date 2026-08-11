-- Una sola vez: crea lotes para productos con stock pero sin lote activo.
-- NO cambia precios. El stock total queda igual (misma cantidad, ahora en PEPS).
-- Idempotente — se puede correr varias veces.

insert into public.lotes (
  producto_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  costo_unitario,
  fecha_caducidad,
  fecha_recepcion,
  activo
)
select
  p.id,
  'SIN-LOTE-' || coalesce(nullif(btrim(p.sku), ''), p.id::text) as numero_lote,
  p.stock::integer,
  p.stock::integer,
  coalesce(p.costo, 0),
  null::date as fecha_caducidad,
  coalesce(p.created_at::date, current_date),
  true
from public.productos p
where coalesce(p.activo, true)
  and p.stock > 0
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  );

-- Cuántos quedaron sin lote (debería ser 0 si todo tiene stock en lotes)
select count(*) as productos_con_stock_sin_lote
from public.productos p
where coalesce(p.activo, true)
  and p.stock > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and l.cantidad_actual > 0
  );
