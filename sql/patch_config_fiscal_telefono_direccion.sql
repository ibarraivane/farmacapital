-- FARMACAPITAL — Teléfono y dirección comercial + claves fiscales faltantes
-- Ejecutar en Supabase SQL Editor (rol admin).

UPDATE public.configuracion
SET valor = '5562530631'
WHERE clave = 'telefono_farmacia';

UPDATE public.configuracion
SET valor = 'Radiodifusora 100, Col. Chinampac de Juárez, Iztapalapa, CDMX, C.P. 09208'
WHERE clave = 'direccion_farmacia';

INSERT INTO public.configuracion (clave, valor) VALUES
  ('nombre_farmacia',      'FarmaCapital'),
  ('nombre_comercial',     'FarmaCapital'),
  ('curp',                 'PAVL911030HDFLNS03'),
  ('regimen_fiscal_texto', 'Régimen de Sueldos y Salarios e Ingresos Asimilados a Salarios')
ON CONFLICT (clave) DO UPDATE SET
  valor = EXCLUDED.valor
WHERE public.configuracion.valor IS NULL
   OR trim(public.configuracion.valor) = ''
   OR public.configuracion.clave IN ('curp', 'regimen_fiscal_texto');

-- Verificación
SELECT clave, valor
FROM public.configuracion
WHERE clave IN (
  'telefono_farmacia', 'direccion_farmacia', 'nombre_farmacia',
  'nombre_comercial', 'curp', 'regimen_fiscal_texto', 'rfc', 'razon_social'
)
ORDER BY clave;
