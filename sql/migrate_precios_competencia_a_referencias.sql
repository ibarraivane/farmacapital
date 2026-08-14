-- ════════════════════════════════════════════════════════════════
-- Migración one-shot: columnas legacy → producto_precios_referencia
-- Ejecutar DESPUÉS de patch_producto_precios_referencia.sql
-- Idempotente: no duplica si ya migró (busca origen manual previo)
-- ════════════════════════════════════════════════════════════════

BEGIN;

-- Similares
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, notas
)
SELECT
  p.id,
  'similares',
  'venta',
  p.precio_similares,
  COALESCE(p.fecha_actualizacion_precios, CURRENT_DATE),
  'manual',
  'Migrado desde productos.precio_similares'
FROM public.productos p
WHERE p.precio_similares IS NOT NULL
  AND p.precio_similares > 0
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r
    WHERE r.producto_id = p.id
      AND r.fuente = 'similares'
      AND r.origen = 'manual'
      AND r.notas = 'Migrado desde productos.precio_similares'
  );

-- Del Ahorro
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, notas
)
SELECT
  p.id,
  'fahorro',
  'venta',
  p.precio_del_ahorro,
  COALESCE(p.fecha_actualizacion_precios, CURRENT_DATE),
  'manual',
  'Migrado desde productos.precio_del_ahorro'
FROM public.productos p
WHERE p.precio_del_ahorro IS NOT NULL
  AND p.precio_del_ahorro > 0
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r
    WHERE r.producto_id = p.id
      AND r.fuente = 'fahorro'
      AND r.origen = 'manual'
      AND r.notas = 'Migrado desde productos.precio_del_ahorro'
  );

COMMIT;
