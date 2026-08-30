-- Anula precios Rappi que no son la misma presentación (pack / polvo / 4.5× el mostrador).
-- El panel ya los ignora al sugerir; esto quita la fila vigente para que no reaparezcan.
-- Revisá el SELECT de preview antes del INSERT.

BEGIN;

-- Preview (no escribe):
-- SELECT p.sku, p.nombre, p.presentacion, p.precio AS tu_venta,
--        a.fuente, a.precio AS rappi, a.nombre_fuente
-- FROM public.producto_precios_referencia_actual a
-- JOIN public.productos p ON p.id = a.producto_id
-- WHERE a.fuente IN ('rappi_gdl','rappi_farmatodo','rappi_benavides','rappi_otros','rappi_super')
--   AND a.precio > 0
--   AND COALESCE(a.notas, '') IS DISTINCT FROM '__anulado__'
--   AND p.precio > 0
--   AND (
--     a.precio >= p.precio * 4.5
--     OR COALESCE(a.nombre_fuente, '') ~* '(^|[^0-9])([2-9]|1[0-9]|2[0-4])[[:space:]-]*packs?'
--     OR COALESCE(a.nombre_fuente, '') ~* 'caja[[:space:]]+con[[:space:]]+([2-9]|1[0-9]|2[0-4])'
--     OR COALESCE(a.nombre_fuente, '') ~* '([2-9]|1[0-9]|2[0-4])[[:space:]]*x[[:space:]]*[0-9]+[[:space:]]*m[lL]'
--   )
--   AND (COALESCE(p.presentacion, '') || ' ' || COALESCE(p.nombre, ''))
--       !~* '(^|[^0-9])([2-9]|1[0-9]|2[0-4])[[:space:]-]*packs?';

INSERT INTO public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT
  a.producto_id,
  a.fuente,
  'venta',
  0,
  CURRENT_DATE,
  'manual',
  0,
  '__anulado__'
FROM public.producto_precios_referencia_actual a
JOIN public.productos p ON p.id = a.producto_id
WHERE a.fuente IN ('rappi_gdl', 'rappi_farmatodo', 'rappi_benavides', 'rappi_otros', 'rappi_super')
  AND a.precio > 0
  AND COALESCE(a.notas, '') IS DISTINCT FROM '__anulado__'
  AND p.precio > 0
  AND (
    a.precio >= p.precio * 4.5
    OR COALESCE(a.nombre_fuente, '') ~* '(^|[^0-9])([2-9]|1[0-9]|2[0-4])[[:space:]-]*packs?'
    OR COALESCE(a.nombre_fuente, '') ~* 'caja[[:space:]]+con[[:space:]]+([2-9]|1[0-9]|2[0-4])'
    OR COALESCE(a.nombre_fuente, '') ~* '([2-9]|1[0-9]|2[0-4])[[:space:]]*x[[:space:]]*[0-9]+[[:space:]]*m[lL]'
  )
  AND (COALESCE(p.presentacion, '') || ' ' || COALESCE(p.nombre, ''))
      !~* '(^|[^0-9])([2-9]|1[0-9]|2[0-4])[[:space:]-]*packs?';

COMMIT;
