-- Columna Farma City en referencias de compra (lista Cityfarma).
-- Ejecutar una vez en Supabase SQL Editor si ya tienes fuentes_precio.

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  (
    'farmacity',
    'Farma City',
    'compra',
    'import_archivo',
    'Lista Cityfarma Iztapalapa. Precio neto de mayoreo.'
  )
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;
