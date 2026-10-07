-- Farmalive 12127 · B1-4/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Puribel 300 mg', 'FC-08894946', '7502208894946', 'Medicamentos', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 17.16::numeric, 22::numeric, 0::integer, 1::integer, true, true, 'Puribel', 'Caja 20 tabletas', 'Tableta', null::text, '300 mg', 'Bruluart', null::text, null::text),
  ('Sterimar Infantil spray', 'FC-80954212', '7501080954212', 'Respiratorio', 'Nasal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 155.98::numeric, 195::numeric, 0::integer, 1::integer, true, false, 'Sterimar', 'Spray 50 mL', 'Spray', null::text, null::text, 'Church & Dwight', 'https://www.farmacapital.mx/catalogo-propia/sterimar-infantil-50ml-7501080954212.jpg', 'https://www.farmacapital.mx/catalogo-propia/sterimar-infantil-50ml-7501080954212.jpg'),
  ('Punab 100 mg', 'FC-40450711', '7502240450711', 'Cardiovascular', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 20.37::numeric, 33::numeric, 0::integer, 1::integer, true, true, 'Punab', 'Caja 15 tabletas', 'Tableta', 'Losartán', '100 mg', 'Wermar', null::text, null::text),
  ('Bromuro de pinaverio', 'FC-11789918', '7502211789918', 'Gastro', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 18.22::numeric, 30::numeric, 0::integer, 1::integer, true, true, 'Loeffler', 'Caja 14 tabletas', 'Tableta', 'Bromuro de pinaverio', null::text, 'Loeffler', null::text, null::text),
  ('Combesteral', 'FC-25139543', '7501125139543', 'Hormonas', 'Inyectable', 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 221.71::numeric, 355::numeric, 0::integer, 1::integer, true, true, 'Combesteral', 'Caja 3 ampolletas', 'Ampolleta', 'Betametasona', null::text, 'Pisa', null::text, null::text),
  ('Ciclox 200 mg', 'FC-87543278', '7851187543278', 'Analgésico', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 38.81::numeric, 63::numeric, 0::integer, 1::integer, true, true, 'Ciclox', 'Caja 10 cápsulas', 'Cápsula', 'Celecoxib', '200 mg', 'MAVI', null::text, null::text),
  ('Cobedina NS', 'FC-83148645', '780083148645', 'Alergia', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 10.42::numeric, 14::numeric, 0::integer, 1::integer, true, true, 'Cobedina', 'Caja 10 tabletas', 'Tableta', 'Loratadina / betametasona', null::text, 'Collins', null::text, null::text),
  ('Esomeprazol 40 mg', 'FC-16808430', '7502216808430', 'Gastro', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 101.20::numeric, 162::numeric, 0::integer, 1::integer, true, true, 'Ultra', 'Caja 14 tabletas', 'Tableta', 'Esomeprazol', '40 mg', 'Ultra', null::text, null::text)
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
where codigo_barras in ('7502208894946', '7501080954212', '7502240450711', '7502211789918', '7501125139543', '7851187543278', '780083148645', '7502216808430');
