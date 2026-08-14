-- Columnas «Otros» en referencias de precio (compra + venta)
-- Ejecutar una vez en Supabase SQL Editor si ya tienes patch_producto_precios_referencia.sql

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  (
    'otros_compra',
    'Otros (compra)',
    'compra',
    'manual',
    'Promedio de mercado o consulta manual (Claude, Google, etc.)'
  ),
  (
    'otros_venta',
    'Otros (venta)',
    'venta',
    'manual',
    'Promedio de mercado o consulta manual (Claude, Google, etc.)'
  )
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;
