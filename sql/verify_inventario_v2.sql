-- Verificación inventario v2 — SIEMPRE devuelve filas legibles en Supabase SQL Editor
-- Ejecutar después de schema_inventario_v2_con_proveedores.sql

SELECT 'tabla' AS tipo, table_name AS nombre, 'ok' AS estado
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('productos_v2', 'ofertas_proveedor', 'lotes_v2', 'movimientos_v2')

UNION ALL

SELECT 'funcion', p.proname::text, 'ok'
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname = 'create_producto_con_oferta'

UNION ALL

SELECT 'vista', table_name, 'ok'
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name IN ('vw_mejor_precio', 'vw_comparativa_precios')

ORDER BY 1, 2;

-- Debe mostrar 7 filas (4 tablas + 1 función + 2 vistas).
-- Si faltan filas, ejecuta de nuevo sql/schema_inventario_v2_con_proveedores.sql
