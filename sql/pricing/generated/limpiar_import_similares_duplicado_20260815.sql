-- ════════════════════════════════════════════════════════════════
-- Limpieza: importación duplicada de Similares (2026-08-15)
--
-- El sync corrió dos veces en paralelo y generó dos importaciones idénticas:
--   import_id 20 → 160 filas
--   import_id 21 → 161 filas (mismos 160 productos con idéntico precio y
--                             confianza, más el producto_id 142)
-- Se conserva la 21 por ser superset. Ejecutar en Supabase SQL Editor.
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- Verificación previa: debe devolver 160 y 161
SELECT import_id, count(*) AS filas
FROM public.producto_precios_referencia
WHERE import_id IN (20, 21)
GROUP BY import_id
ORDER BY import_id;

DELETE FROM public.producto_precios_referencia
WHERE import_id = 20;

DELETE FROM public.importaciones_referencia
WHERE id = 20;

-- Verificación posterior: solo debe quedar la 21 con 161 filas
SELECT import_id, count(*) AS filas
FROM public.producto_precios_referencia
WHERE fuente = 'similares' AND fecha = '2026-08-15'
GROUP BY import_id
ORDER BY import_id;

COMMIT;
