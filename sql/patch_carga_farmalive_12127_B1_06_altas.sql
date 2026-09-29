-- Farmalive 12127 · B1-6/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Colchiquim 1 mg', 'FC-09762446', '7501109762446', 'Medicamentos', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 36.08::numeric, 58::numeric, 0::integer, 1::integer, true, true, 'Colchiquim', 'Caja 20 tabletas', 'Tableta', 'Colchicina', '1 mg', 'Química y Farmacia', null::text, null::text),
  ('Deflamox Plus', 'FC-85491139', '7501385491139', 'Antibióticos', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 53.94::numeric, 68::numeric, 0::integer, 1::integer, true, true, 'Deflamox', 'Caja 16 tabletas', 'Tableta', 'Amoxicilina / ácido clavulánico', null::text, 'Sanfer', null::text, null::text),
  ('Oral-B Essential hilo dental', 'FC-05082024', '7800005082024', 'Cuidado personal', 'Higiene bucal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 73.51::numeric, 92::numeric, 0::integer, 1::integer, true, false, 'Oral-B', '1 unidad', 'Hilo dental', null::text, null::text, 'P&G', null::text, null::text),
  ('Johnson''s Baby jabón neutro', 'FC-07501031', '7501007501031', 'Cuidado personal', 'Bebé', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 14.50::numeric, 19::numeric, 0::integer, 1::integer, true, false, 'Johnson''s', 'Barra 75 g', 'Jabón', null::text, null::text, 'Johnson & Johnson', null::text, null::text),
  ('Cloranfenicol gotas oftálmicas', 'FC-22840349', '7502222840349', 'Oftalmología', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 21.86::numeric, 35::numeric, 0::integer, 1::integer, true, true, 'Alvartis', 'Frasco 15 mL', 'Gotas oftálmicas', 'Cloranfenicol', null::text, 'Alvartis', null::text, null::text),
  ('Hipromelosa oftálmica', 'FC-49028654', '7501349028654', 'Oftalmología', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 22.51::numeric, 37::numeric, 0::integer, 1::integer, true, false, 'AMSA', 'Frasco 10 mL', 'Solución oftálmica', 'Hipromelosa', null::text, 'AMSA', null::text, null::text),
  ('Oral-B Kids Princess pasta dental', 'FC-35137737', '7500435137737', 'Cuidado personal', 'Higiene bucal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 25.19::numeric, 32::numeric, 0::integer, 1::integer, true, false, 'Oral-B', 'Tubo 37 mL', 'Pasta', null::text, null::text, 'P&G', null::text, null::text),
  ('Silka Medic spray', 'FC-00368802', '6502400368802', 'Dermatología', 'Antifúngico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 142.49::numeric, 179::numeric, 0::integer, 1::integer, true, false, 'Silka', 'Spray 150 mL', 'Spray', null::text, null::text, 'Genomma Lab', 'https://www.farmacapital.mx/catalogo-propia/silka-medic-spray-150ml-6502400368802.jpg', 'https://www.farmacapital.mx/catalogo-propia/silka-medic-spray-150ml-6502400368802.jpg')
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
where codigo_barras in ('7501109762446', '7501385491139', '7800005082024', '7501007501031', '7502222840349', '7501349028654', '7500435137737', '6502400368802');
