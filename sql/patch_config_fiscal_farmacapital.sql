-- FARMACAPITAL — Datos fiscales del emisor (Constancia SAT enero 2025)
-- Ejecutar en Supabase SQL Editor (rol admin).
-- Idempotente: INSERT nuevas claves; UPDATE solo si el valor sigue siendo placeholder vacío.

INSERT INTO public.configuracion (clave, valor) VALUES
  ('nombre_farmacia',        'FarmaCapital'),
  ('nombre_comercial',       'FarmaCapital'),
  ('razon_social',           'LUIS ANGEL PALILLERO VENTURA'),
  ('rfc',                    'PAVL911030NC8'),
  ('curp',                   'PAVL911030HDFLNS03'),
  ('regimen_fiscal',         '605'),
  ('regimen_fiscal_texto',   'Régimen de Sueldos y Salarios e Ingresos Asimilados a Salarios'),
  ('codigo_postal',          '09208'),
  ('domicilio_fiscal',       'Calle Frente 7 K Int 102, Col. Chinampac de Juárez, Iztapalapa, Ciudad de México, C.P. 09208'),
  ('direccion_farmacia',     'Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208'),
  ('telefono_farmacia',      '5562530631')
ON CONFLICT (clave) DO UPDATE SET
  valor = EXCLUDED.valor
WHERE public.configuracion.valor IS NULL
   OR trim(public.configuracion.valor) = ''
   OR public.configuracion.clave IN (
     'razon_social', 'rfc', 'curp', 'regimen_fiscal', 'regimen_fiscal_texto',
     'codigo_postal', 'domicilio_fiscal'
   );

-- Verificación
SELECT clave, valor
FROM public.configuracion
WHERE clave IN (
  'nombre_farmacia', 'nombre_comercial', 'razon_social', 'rfc', 'curp',
  'regimen_fiscal', 'regimen_fiscal_texto', 'codigo_postal',
  'domicilio_fiscal', 'direccion_farmacia', 'telefono_farmacia'
)
ORDER BY clave;
