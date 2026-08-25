-- Fuentes públicas de compra (higiene / pañales). No son columnas fijas:
-- viven en producto_precios_referencia y ganan en «Comprar en».

INSERT INTO public.fuentes_precio (id, nombre, tipo, metodo, notas) VALUES
  ('scorpion', 'Scorpion', 'compra', 'job_api',
   'Mayoreo CDMX — higiene y pañales. El botón Actualizar refresca el listado público.'),
  ('abarrotero', 'Abarrotero', 'compra', 'job_api',
   'WooCommerce público — farmacia OTC y cuidado personal.'),
  ('mayoreototal', 'MayoreoTotal', 'compra', 'job_api',
   'Shopify público. Poco traslape con el catálogo; se usa si gana precio.')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  tipo = EXCLUDED.tipo,
  metodo = EXCLUDED.metodo,
  notas = EXCLUDED.notas;
