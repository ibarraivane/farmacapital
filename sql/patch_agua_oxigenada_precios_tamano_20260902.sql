-- Agua oxigenada (Protec / Dermocleen / Degasa): PVP por tamaño.
--
-- Reporte Erika (Team FarmaCap, 2026-09-02): en el POS estaban invertidos
--   100 ml → $23
--   230 ml → $19
--   480 ml → $23
-- La botella chica no puede costar igual o más que la grande.
--
-- Piso = costo × 50% (material_curación), redondeo hacia arriba:
--   100 ml costo 7.64  → $13
--   230 ml costo 10.19 → $16
--   480 ml costo 14.70 → $23

BEGIN;

UPDATE public.productos SET
  presentacion = '100 ML',
  forma_farmaceutica = COALESCE(NULLIF(btrim(forma_farmaceutica), ''), 'Agua oxigenada'),
  categoria = COALESCE(NULLIF(btrim(categoria), ''), 'Botiquín'),
  precio = 13
WHERE sku = 'FC-83351381';

UPDATE public.productos SET
  presentacion = '230 ML',
  forma_farmaceutica = COALESCE(NULLIF(btrim(forma_farmaceutica), ''), 'Agua oxigenada'),
  categoria = COALESCE(NULLIF(btrim(categoria), ''), 'Botiquín'),
  precio = 16
WHERE sku = 'FC-83351691';

UPDATE public.productos SET
  presentacion = '480 ML',
  forma_farmaceutica = COALESCE(NULLIF(btrim(forma_farmaceutica), ''), 'Agua oxigenada'),
  categoria = COALESCE(NULLIF(btrim(categoria), ''), 'Botiquín'),
  precio = 23
WHERE sku = 'FC-48335305';

-- Por si el SKU cambió pero la presentación sigue: forzar orden en la familia.
UPDATE public.productos SET precio = 13
WHERE (nombre ILIKE '%agua%oxigen%' OR forma_farmaceutica ILIKE '%oxigen%')
  AND presentacion ~* '(^|[^0-9])100\s*m?l'
  AND coalesce(precio, 0) > 16;

UPDATE public.productos SET precio = 16
WHERE (nombre ILIKE '%agua%oxigen%' OR forma_farmaceutica ILIKE '%oxigen%')
  AND presentacion ~* '(^|[^0-9])230\s*m?l'
  AND coalesce(precio, 0) > 0
  AND coalesce(precio, 0) < 16;

UPDATE public.productos SET precio = 23
WHERE (nombre ILIKE '%agua%oxigen%' OR forma_farmaceutica ILIKE '%oxigen%')
  AND presentacion ~* '(^|[^0-9])480\s*m?l'
  AND coalesce(precio, 0) > 0
  AND coalesce(precio, 0) < 23;

-- Refs de otro tamaño pegadas a estos SKUs (Exprezo 250/500, Similares 224).
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
