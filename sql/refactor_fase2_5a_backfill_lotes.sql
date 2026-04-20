-- ============================================================
-- FARMAX — Refactor FASE 2.5a: BACKFILL lotes desde productos
-- ============================================================
-- Objetivo: crear un lote sintético por cada producto con stock > 0
-- que todavía NO tenga un lote activo, para que lotes.cantidad_actual
-- represente el mismo inventario que productos.stock.
--
-- Después de esto:
--   sum(lotes.cantidad_actual where activo) == productos.stock  (por producto)
--
-- No toca productos.stock. No toca RPCs. No instala triggers.
-- Idempotente: se puede correr varias veces.
-- ============================================================

begin;

insert into public.lotes (
  producto_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  costo_unitario,
  fecha_caducidad,
  fecha_recepcion,
  activo,
  sucursal_id,
  proveedor_id
)
select
  p.id,
  coalesce(nullif(trim(p.lote), ''), 'SIN-LOTE-' || p.sku) as numero_lote,
  p.stock::integer                                         as cantidad_inicial,
  p.stock::integer                                         as cantidad_actual,
  coalesce(p.costo, 0)                                     as costo_unitario,
  p.fecha_caducidad,
  coalesce(p.created_at::date, current_date)               as fecha_recepcion,
  true                                                     as activo,
  null::integer                                            as sucursal_id,
  null::integer                                            as proveedor_id
from public.productos p
where p.stock > 0
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
  );

commit;

-- ============================================================
-- Verificación (correr aparte y pegarme los resultados)
-- ============================================================
--
-- -- 1) ¿Cuántos lotes se crearon?
-- select count(*) from public.lotes;
--
-- -- 2) ¿Coinciden productos.stock con sum(lotes.cantidad_actual)?
-- select
--   count(*)                                                   as productos_totales,
--   count(*) filter (where p.stock = coalesce(v.stock_lotes, 0)) as coinciden,
--   count(*) filter (where p.stock > 0 and coalesce(v.stock_lotes, 0) = 0) as sin_lote_con_stock,
--   count(*) filter (where p.stock = 0)                          as productos_sin_stock
-- from public.productos p
-- left join public.v_stock_actual v on v.producto_id = p.id;
--
-- -- 3) Top 10 productos con mayor diferencia (debería estar vacío)
-- select
--   p.id, p.nombre, p.sku,
--   p.stock as stock_productos,
--   coalesce(v.stock_lotes, 0) as stock_lotes,
--   (p.stock - coalesce(v.stock_lotes, 0)) as diferencia
-- from public.productos p
-- left join public.v_stock_actual v on v.producto_id = p.id
-- where p.stock <> coalesce(v.stock_lotes, 0)
-- order by abs(p.stock - coalesce(v.stock_lotes, 0)) desc
-- limit 10;
-- ============================================================
