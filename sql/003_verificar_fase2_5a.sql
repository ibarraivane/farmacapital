-- ============================================================
-- FARMAX — Verificación Fase 2.5a (backfill de lotes)
-- ============================================================

-- 1) Lotes existentes en total
select count(*) as total_lotes from public.lotes;

-- 2) Coincidencia productos.stock vs sum(lotes.cantidad_actual)
select
  count(*)                                                               as productos_totales,
  count(*) filter (where p.stock = coalesce(v.stock_lotes, 0))           as coinciden,
  count(*) filter (where p.stock > 0 and coalesce(v.stock_lotes, 0) = 0) as sin_lote_con_stock,
  count(*) filter (where p.stock = 0)                                    as productos_sin_stock
from public.productos p
left join public.v_stock_actual v on v.producto_id = p.id;

-- 3) Top 10 diferencias (esperado: 0 filas después del backfill)
select
  p.id, p.nombre, p.sku,
  p.stock                                as stock_productos,
  coalesce(v.stock_lotes, 0)             as stock_lotes,
  (p.stock - coalesce(v.stock_lotes, 0)) as diferencia
from public.productos p
left join public.v_stock_actual v on v.producto_id = p.id
where p.stock <> coalesce(v.stock_lotes, 0)
order by abs(p.stock - coalesce(v.stock_lotes, 0)) desc
limit 10;
