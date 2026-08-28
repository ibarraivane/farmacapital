-- Completa `principio_activo` en productos que no lo tenían registrado.
-- Generado por scripts/proponer_principio_activo.py desde propuestas_pa_2026-08-15.csv
-- Solo incluye las filas confirmadas manualmente.
-- Sin este campo no se puede verificar ningún precio de referencia contra la competencia.

BEGIN;

UPDATE public.productos SET principio_activo = 'Ampicilina + Dicloxacilina' WHERE sku = 'FC-2001A890' AND coalesce(btrim(principio_activo), '') = '';
UPDATE public.productos SET principio_activo = 'Ciprofloxacino' WHERE sku = 'FC-B25B4654' AND coalesce(btrim(principio_activo), '') = '';
UPDATE public.productos SET principio_activo = 'Metamizol + Dexametasona + Vit.' WHERE sku = 'FC-DE106642' AND coalesce(btrim(principio_activo), '') = '';

-- Filas confirmadas: 3

COMMIT;
