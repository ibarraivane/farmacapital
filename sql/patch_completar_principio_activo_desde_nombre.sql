-- Completa `principio_activo` vacío desde denominación genérica o el genérico
-- que ya viene entre paréntesis en el nombre (ej. Eferox (Cefalexina)).
-- No pisa valores capturados. No inventa PA para higiene / empaque / dosis.

BEGIN;

UPDATE public.productos
SET principio_activo = btrim(denominacion_generica)
WHERE coalesce(btrim(principio_activo), '') = ''
  AND coalesce(btrim(denominacion_generica), '') <> '';

UPDATE public.productos p
SET principio_activo = btrim(x.m[1])
FROM (
  SELECT id,
         regexp_match(nombre, '\(([^)]{3,80})\)') AS m
  FROM public.productos
  WHERE coalesce(btrim(principio_activo), '') = ''
    AND nombre ~ '\([^)]{3,80}\)'
) x
WHERE p.id = x.id
  AND x.m IS NOT NULL
  AND btrim(x.m[1]) !~ '^\d'
  AND btrim(x.m[1]) !~* '^\d+(?:[.,]\d+)?\s*(mg|g|ml|mcg|%|ui|iu)'
  AND lower(translate(
        btrim(x.m[1]),
        'ÁÉÍÓÚÜÑáéíóúüñ',
        'AEIOUUNaeiouun'
      )) NOT IN (
        'hombre','mujer','men','women','unisex','adulto','adultos','infantil',
        'nino','ninos','nina','ninas','bebe','bebes','inyectable','tabletas',
        'tableta','capsulas','capsula','comprimidos','crema','gel','spray',
        'solucion','jarabe','suspension','gotas','unguento','pomada'
      );

COMMIT;
