-- Farmalive 12127 · B1-8/8 · altas (6 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Ensure Advance café', 'FC-33962530', '7501033962530', 'Suplemento', 'Nutrición clínica', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 50.47::numeric, 64::numeric, 0::integer, 1::integer, true, false, 'Ensure', 'Frasco 237 mL', 'Líquido', null::text, null::text, 'Abbott', 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-cafe-237ml-7501033962530.jpg', 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-cafe-237ml-7501033962530.jpg'),
  ('Suerox Mineral mora azul', 'FC-00801590', '6502400801590', 'Bebidas', 'Electrolitos', 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 15.19::numeric, 25::numeric, 0::integer, 1::integer, true, false, 'Suerox', 'Botella 355 mL', 'Bebida', null::text, null::text, 'Genomma Lab', null::text, null::text),
  ('Suerox Mineral fresa kiwi', 'FC-00801668', '6502400801668', 'Bebidas', 'Electrolitos', 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 15.19::numeric, 25::numeric, 0::integer, 1::integer, true, false, 'Suerox', 'Botella 355 mL', 'Bebida', null::text, null::text, 'Genomma Lab', null::text, null::text),
  ('Nido Kinder', 'FC-59225350', '7501059225350', 'Nutrición', 'Leche en polvo', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 137.56::numeric, 172::numeric, 0::integer, 1::integer, true, false, 'Nido', 'Lata 800 g', 'Polvo', null::text, null::text, 'Nestlé', 'https://www.farmacapital.mx/catalogo-propia/nido-kinder-800g-7501059225350.jpg', 'https://www.farmacapital.mx/catalogo-propia/nido-kinder-800g-7501059225350.jpg'),
  ('Alliviax 550 mg', 'FC-00503982', '6502400503982', 'Analgésico', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 0.01::numeric, 1::numeric, 0::integer, 1::integer, true, false, 'Alliviax', 'Caja 20 tabletas', 'Tableta', 'Naproxeno', '550 mg', 'Genomma Lab', null::text, null::text),
  ('Sico Mutual Climax', 'FC-58799685', '7501058799685', 'Cuidado personal', 'Preservativos', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 80.95::numeric, 102::numeric, 0::integer, 1::integer, true, false, 'Sico', 'Caja 3 piezas', 'Condón', null::text, null::text, 'RB Health', 'https://www.farmacapital.mx/catalogo-propia/sico-mutual-climax-3-7501058799685.jpg', 'https://www.farmacapital.mx/catalogo-propia/sico-mutual-climax-3-7501058799685.jpg')
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
where codigo_barras in ('7501033962530', '6502400801590', '6502400801668', '7501059225350', '6502400503982', '7501058799685');
