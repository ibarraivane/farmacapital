-- Resincroniza productos.stock desde lotes activos (PEPS).
-- Ejecutar en Supabase si Lotes muestra existencia pero POS decía 0.
-- Requiere trigger trg_sync_productos_stock (refactor_fase2_5b_trigger_stock.sql).

begin;

update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)
  from public.lotes l
  where l.producto_id = p.id
    and coalesce(l.activo, true) = true
), 0);

-- Opcional: listar desajustes que queden (debería ser 0 filas)
-- select p.id, p.nombre, p.stock,
--   coalesce((select sum(l.cantidad_actual) from lotes l where l.producto_id=p.id and coalesce(l.activo,true)),0) as sum_lotes
-- from productos p
-- where p.stock <> coalesce((select sum(l.cantidad_actual) from lotes l where l.producto_id=p.id and coalesce(l.activo,true)),0);

commit;
