-- Farmalive 12127 · B1-3/8 · altas (8 SKUs)
-- Lote chico. Idempotente. Sin fc_buscar (evita Load failed).

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select *
from (values
  ('Adinol solución infantil', 'FC-37103545', '7501537103545', 'Analgésico', 'Pediátrico', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 20.06::numeric, 26::numeric, 0::integer, 1::integer, true, false, 'Adinol', 'Frasco 120 mL', 'Solución', 'Paracetamol', null::text, 'Bruluart', null::text, null::text),
  ('Sukrol Hombre', 'FC-30020570', '6758730020570', 'Vitaminas', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 129.36::numeric, 162::numeric, 0::integer, 1::integer, true, false, 'Sukrol', 'Caja 30 tabletas', 'Tableta', null::text, null::text, 'Farmamédica', 'https://www.farmacapital.mx/catalogo-propia/sukrol-hombre-30-tab-6758730020570.jpg', 'https://www.farmacapital.mx/catalogo-propia/sukrol-hombre-30-tab-6758730020570.jpg'),
  ('Sterimar Bebé spray', 'FC-80912274', '7501080912274', 'Respiratorio', 'Nasal', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 151.30::numeric, 190::numeric, 0::integer, 1::integer, true, false, 'Sterimar', 'Spray 50 mL', 'Spray', null::text, null::text, 'Church & Dwight', 'https://www.farmacapital.mx/catalogo-propia/sterimar-bebe-50ml-7501080912274.jpg', 'https://www.farmacapital.mx/catalogo-propia/sterimar-bebe-50ml-7501080912274.jpg'),
  ('Algidol 400 mg', 'FC-27425022', '7502227425022', 'Analgésico', null::text, 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 16.65::numeric, 21::numeric, 0::integer, 1::integer, true, false, 'Algidol', 'Caja 10 cápsulas', 'Cápsula', 'Ibuprofeno', '400 mg', 'Gelpharma', null::text, null::text),
  ('Erispan Compuesto', 'FC-09744129', '7502009744129', 'Alergia', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 22.51::numeric, 37::numeric, 0::integer, 1::integer, true, true, 'Erispan', 'Frasco 60 mL', 'Solución', 'Loratadina / betametasona', null::text, 'Maver', null::text, null::text),
  ('Pasta Lassar', 'FC-89511438', '7501289511438', 'Dermatología', 'Protectores', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 60.66::numeric, 76::numeric, 0::integer, 1::integer, true, false, 'Pasta Lassar', 'Tubo 60 g', 'Pasta', 'Óxido de zinc', null::text, 'Andrómaco', null::text, null::text),
  ('Vitacilina serum facial retinol', 'FC-50342556', '7502250342556', 'Cuidado personal', 'Facial', 'marca', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 111.88::numeric, 140::numeric, 0::integer, 1::integer, true, false, 'Vitacilina', 'Frasco 30 mL', 'Serum', null::text, null::text, 'KSK', null::text, null::text),
  ('Visertral 10 mg', 'FC-58205863', '7501258205863', 'Alergia', null::text, 'generico', 'Alta Farmalive 12127 · 2026-09-28 · listo para pistola', 24.20::numeric, 39::numeric, 0::integer, 1::integer, true, false, 'Visertral', 'Caja 10 tabletas', 'Tableta', 'Cetirizina', '10 mg', 'Serral', null::text, null::text)
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
where codigo_barras in ('7501537103545', '6758730020570', '7501080912274', '7502227425022', '7502009744129', '7501289511438', '7502250342556', '7501258205863');
