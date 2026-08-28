-- Farmalive: lista de precios de compra (Excel del 17-ago-2026).
-- Columna propia en Referencias de precio. Solo se cruzan productos
-- que ya están en catálogo, por código de barras.

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('farmalive', 'Farmalive', 'compra', 'import_archivo',
   'Lista normal Club Iztapalapa. Precio base (2%), no campañas de día.')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;
