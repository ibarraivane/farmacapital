-- Farmalive 12127 · B1-2/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Lotrimin Uno crema', 'FC-76040566', '7502276040566', 'Dermatología', 'Antifúngico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 163.20::numeric, 204::numeric, 0::integer, 1::integer, true, false, 'Lotrimin', '3 tubos 20 g', 'Crema', 'Terbinafina', '1%', 'Bayer', 'https://www.farmacapital.mx/catalogo-propia/lotrimin-uno-crema-20g-7502276040566.jpg', 'https://www.farmacapital.mx/catalogo-propia/lotrimin-uno-crema-20g-7502276040566.jpg'),
  ('Suavelastic Recién nacido', 'FC-43498815', '7501943498815', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 115.74::numeric, 145::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 40 pañales recién nacido', 'Pañal', null::text, null::text, 'Kimberly-Clark', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-recien-nacido-40-7501943498815.jpg', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-recien-nacido-40-7501943498815.jpg'),
  ('Suavelastic Extra Jumbo', 'FC-43447615', '7501943447615', 'Higiene', 'Pañales', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 259.90::numeric, 325::numeric, 0::integer, 1::integer, true, false, 'Suavelastic', 'Paquete 40 pañales talla extra jumbo', 'Pañal', null::text, null::text, 'Kimberly-Clark', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-extra-jumbo-40-7501943447615.jpg', 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-extra-jumbo-40-7501943447615.jpg'),
  ('Head & Shoulders 2 en 1 Suave y Manejable', 'FC-35162241', '7500435162241', 'Cuidado personal', 'Capilar', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 123.03::numeric, 154::numeric, 0::integer, 1::integer, true, false, 'Head & Shoulders', 'Frasco 650 mL', 'Shampoo', null::text, null::text, 'P&G', 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-2en1-650ml-7500435162241.jpg', 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-2en1-650ml-7500435162241.jpg'),
  ('Flextrin 25/200/300 mg', 'FC-90211201', '7501590211201', 'Suplemento', 'Articulaciones', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 69.19::numeric, 87::numeric, 0::integer, 1::integer, true, false, 'Flextrin', 'Caja 30 comprimidos', 'Comprimido', 'Glucosamina / condroitina / MSM', '25/200/300 mg', 'CMD', null::text, null::text),
  ('Jaloma manzanilla toallitas', 'FC-84431234', '759684431234', 'Higiene', 'Toallitas', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 18.48::numeric, 24::numeric, 0::integer, 1::integer, true, false, 'Jaloma', 'Paquete 80 toallitas', 'Toallitas', null::text, null::text, 'Jaloma', null::text, null::text),
  ('Tampax Pearl Regular', 'FC-95369363', '7506295369363', 'Cuidado personal', 'Higiene femenina', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 45.96::numeric, 58::numeric, 0::integer, 1::integer, true, false, 'Tampax', 'Caja 8 tampones', 'Tampones', null::text, null::text, 'P&G', null::text, null::text),
  ('Vitacilina ungüento', 'FC-50340521', '7502250340521', 'Dermatología', 'Antibiótico tópico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 32.94::numeric, 42::numeric, 0::integer, 1::integer, true, false, 'Vitacilina', 'Tubo 32 g', 'Ungüento', null::text, null::text, 'KSK', 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-32g-7502250340521.jpg', 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-32g-7502250340521.jpg')
) as v(
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
where not exists (
  select 1 from public.productos p where p.codigo_barras = v.codigo_barras
)
  and not exists (
  select 1 from public.productos p where p.sku = v.sku
);

select count(*) as ya_en_catalogo
from public.productos
where codigo_barras in ('7502276040566', '7501943498815', '7501943447615', '7500435162241', '7501590211201', '759684431234', '7506295369363', '7502250340521');
