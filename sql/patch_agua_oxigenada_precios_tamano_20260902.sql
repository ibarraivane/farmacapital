-- Agua oxigenada Dermocleen: precios por tamaño coherentes + refs mal matcheadas.
--
-- Problema: imports fuzzy (Exprezo 250/500 ml, Similares 224 ml) se pegaron a
-- 100 / 230 / 480 ml. Eso hacía ver (o sugerir) la botella grande más barata
-- que la chica. El PVP correcto sigue costo × 50% material_curación:
--   100 ml costo 7.64 → $13
--   230 ml costo 10.19 → $16
--   480 ml costo 14.70 → $23

BEGIN;

-- Nombres limpios (sin "$15.00" de OCR) y PVP ordenado por ml.
UPDATE public.productos SET
  nombre = 'Agua oxigenada Dermocleen',
  marca = 'Dermocleen',
  presentacion = '100 ML',
  forma_farmaceutica = 'Agua oxigenada',
  categoria = 'Botiquín',
  precio = 13
WHERE sku = 'FC-83351381';

UPDATE public.productos SET
  nombre = 'Agua oxigenada Dermocleen',
  marca = 'Dermocleen',
  presentacion = '230 ML',
  forma_farmaceutica = 'Agua oxigenada',
  categoria = 'Botiquín',
  precio = 16
WHERE sku = 'FC-83351691';

UPDATE public.productos SET
  nombre = 'Agua oxigenada Dermocleen',
  marca = 'Dermocleen',
  presentacion = '480 ML',
  forma_farmaceutica = 'Agua oxigenada',
  categoria = 'Botiquín',
  precio = 23
WHERE sku = 'FC-48335305';

-- Quitar referencias de compra/venta que cruzaron tamaños (Exprezo 250→100,
-- Exprezo 500→480 genérica, Similares 224 ml en las tres).
DELETE FROM public.producto_precios_referencia r
USING public.productos p
WHERE r.producto_id = p.id
  AND p.sku IN ('FC-83351381', 'FC-83351691', 'FC-48335305')
  AND (
    (r.fuente = 'exprezo' AND r.precio IN (13.2, 15.95))
    OR (r.fuente = 'similares' AND r.precio = 17
        AND coalesce(r.notas, '') ILIKE '%224%')
    OR (r.fuente = 'similares' AND r.precio = 17
        AND coalesce(r.notas, '') ILIKE '%OXIGENADA%')
  );

COMMIT;
