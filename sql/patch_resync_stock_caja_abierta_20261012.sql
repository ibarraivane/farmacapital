-- Caja abierta: productos.stock = solo cajas cerradas (suma de lotes).
-- Si se abrió la caja y el trigger no dejó el caché en 0, Inventario/Rappi/
-- dashboard seguían viendo 1 caja fantasma aunque solo hubiera piezas sueltas.
-- Pegar en Supabase → SQL Editor. Idempotente.
-- No toca stock_unidades ni stock_blisters.

begin;

update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)
  from public.lotes l
  where l.producto_id = p.id
    and coalesce(l.activo, true) = true
), 0)
where coalesce(p.venta_unidad, false) = true
   or coalesce(p.stock_unidades, 0) > 0
   or coalesce(p.stock_blisters, 0) > 0
   or p.stock is distinct from coalesce((
        select sum(l.cantidad_actual)
        from public.lotes l
        where l.producto_id = p.id
          and coalesce(l.activo, true) = true
      ), 0);

commit;

-- Verificación (opcional):
-- select p.id, p.sku, p.nombre, p.stock, p.stock_unidades, p.stock_blisters,
--   coalesce((select sum(l.cantidad_actual) from public.lotes l
--             where l.producto_id = p.id and coalesce(l.activo,true)), 0) as sum_lotes
-- from public.productos p
-- where coalesce(p.venta_unidad, false)
-- order by p.stock desc, p.stock_unidades desc
-- limit 40;
