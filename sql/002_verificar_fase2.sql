-- ============================================================
-- FARMAX — Verificación post-Fase 2
-- ============================================================
-- Corre las 4 queries (una a la vez si el editor solo muestra
-- el último resultado, o todas juntas si devuelve varios tabs).
-- Pega los resultados en el chat.
-- ============================================================

-- a) Cuántos proveedores quedaron en el catálogo
select count(*) as total_proveedores from public.proveedores;

-- b) Distribución de lotes.proveedor_id vs lotes.proveedor (texto legacy)
select
  count(*) filter (where proveedor_id is not null)                                        as con_proveedor_id,
  count(*) filter (where proveedor_id is null and proveedor is not null and trim(proveedor) <> '') as texto_sin_match,
  count(*) filter (where proveedor is null or trim(proveedor) = '')                       as sin_proveedor_origen,
  count(*)                                                                                as total_lotes
from public.lotes;

-- c) Distribución de pedido_items.lote_id vs pedido_items.lote (texto legacy)
select
  count(*) filter (where lote_id is not null)                                       as con_lote_id,
  count(*) filter (where lote_id is null and lote is not null and trim(lote) <> '') as texto_sin_match,
  count(*) filter (where lote is null or trim(lote) = '')                           as sin_lote_origen,
  count(*)                                                                          as total_items
from public.pedido_items;

-- d) Divergencia productos.stock vs sum(lotes.cantidad_actual)
--    Top 20 productos con mayor diferencia absoluta.
select
  p.id,
  p.nombre,
  p.sku,
  p.stock                                as stock_productos,
  coalesce(v.stock_lotes, 0)             as stock_lotes,
  (p.stock - coalesce(v.stock_lotes, 0)) as diferencia
from public.productos p
left join public.v_stock_actual v on v.producto_id = p.id
order by abs(p.stock - coalesce(v.stock_lotes, 0)) desc nulls last
limit 20;
