-- Farmalive 12127 · B1-5/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Vitacilina Bebé', 'FC-50340255', '7502250340255', 'Cuidado personal', 'Bebé', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 83.17::numeric, 104::numeric, 0::integer, 1::integer, true, false, 'Vitacilina', 'Tarro 110 g', 'Crema', null::text, null::text, 'KSK', 'https://www.farmacapital.mx/catalogo-propia/vitacilina-bebe-110g-7502250340255.jpg', 'https://www.farmacapital.mx/catalogo-propia/vitacilina-bebe-110g-7502250340255.jpg'),
  ('Sterimar Alergias spray', 'FC-80911185', '7501080911185', 'Respiratorio', 'Nasal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 173.40::numeric, 217::numeric, 0::integer, 1::integer, true, false, 'Sterimar', 'Spray 100 mL', 'Spray', null::text, null::text, 'Church & Dwight', 'https://www.farmacapital.mx/catalogo-propia/sterimar-alergias-100ml-7501080911185.jpg', 'https://www.farmacapital.mx/catalogo-propia/sterimar-alergias-100ml-7501080911185.jpg'),
  ('Vexotil 10 mg', 'FC-73900221', '7501573900221', 'Cardiovascular', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 7.10::numeric, 12::numeric, 0::integer, 1::integer, true, true, 'Vexotil', 'Caja 30 tabletas', 'Tableta', 'Enalapril', '10 mg', 'BiomeP', null::text, null::text),
  ('Sterimar Cobre spray', 'FC-80911178', '7501080911178', 'Respiratorio', 'Nasal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 173.40::numeric, 217::numeric, 0::integer, 1::integer, true, false, 'Sterimar', 'Spray 100 mL', 'Spray', null::text, null::text, 'Church & Dwight', 'https://www.farmacapital.mx/catalogo-propia/sterimar-cobre-100ml-7501080911178.jpg', 'https://www.farmacapital.mx/catalogo-propia/sterimar-cobre-100ml-7501080911178.jpg'),
  ('Ciruelax Forte', 'FC-10003409', '7803510003409', 'Gastro', 'Laxante', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 133.77::numeric, 168::numeric, 0::integer, 1::integer, true, false, 'Ciruelax', 'Caja 24 tabletas', 'Tableta', 'Senósidos', null::text, 'Grisi', 'https://www.farmacapital.mx/catalogo-propia/ciruelax-forte-24-tab-7803510003409.jpg', 'https://www.farmacapital.mx/catalogo-propia/ciruelax-forte-24-tab-7803510003409.jpg'),
  ('Sukrol', 'FC-61009016', '7147061009016', 'Vitaminas', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 137.28::numeric, 172::numeric, 0::integer, 1::integer, true, false, 'Sukrol', 'Caja 100 tabletas', 'Tableta', null::text, null::text, 'Farmamédica', null::text, null::text),
  ('Oral-B Kids Mickey pasta dental', 'FC-35127363', '7500435127363', 'Cuidado personal', 'Higiene bucal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 25.19::numeric, 32::numeric, 0::integer, 1::integer, true, false, 'Oral-B', 'Tubo 37 mL', 'Pasta', null::text, null::text, 'P&G', null::text, null::text),
  ('Cloranfenicol ungüento oftálmico', 'FC-75049638', '75049638', 'Oftalmología', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 41.62::numeric, 67::numeric, 0::integer, 1::integer, true, true, 'Exakta', 'Tubo 5 g', 'Ungüento oftálmico', 'Cloranfenicol', null::text, 'Exakta', null::text, null::text)
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
where codigo_barras in ('7502250340255', '7501080911185', '7501573900221', '7501080911178', '7803510003409', '7147061009016', '7500435127363', '75049638');
