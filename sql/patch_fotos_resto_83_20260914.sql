-- Resto de 83 pendientes (14-sep-2026, noche)
-- Pegar DESPUÉS de patch_fotos_resto_89_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Cada pieza se abrió. Foto = frente de la pieza que se vende.
-- Pide deploy de Vercel. No se toca codigo_barras.
--
-- No se usó: Dibar Promexsa 250 ml sigue siendo 1 L (1000 ml);
-- Jaloma rosas pública 250 ml ≠ 130 ml; Jaloma Mertodol 40 ml ≠ 60 ml;
-- Cintapore ≠ 3M Micropore; SKN Nadro = Silica gloss otro EAN;
-- Protect Nadro = Sporasec; algodón Laranita = Zuum no Dibar;
-- vaso Promexsa foto ilegible; Sanax Medicar foto borrosa.

begin;

update public.productos
set nombre = 'Xiomara pomada Wax & Shine Black 60 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 60 g',
    descripcion = 'Xiomara pomada profesional Wax & Shine Black 60 g para barba, bigote y cabello'
where sku = 'FC-46504859';

update public.productos
set nombre = 'Dibar gasa simple 10 × 10 cm C/10',
    marca = 'Dibar',
    presentacion = 'Paquete con 10 piezas',
    descripcion = 'Gasa simple Dibar 10 × 10 cm doblada (25 × 40 cm extendida) esterilizada C/10'
where sku = 'FC-68900127';

update public.productos
set nombre = 'Pinza Curtis Lady Mini 58LC',
    marca = 'Curtis',
    presentacion = '1 pieza',
    descripcion = 'Pinza tijera Curtis Lady Mini modelo 58LC para cejas'
where sku = 'FC-IFC-PINZACH';

update public.productos
set nombre = 'Pinza Curtis Lady Maxi 57LC',
    marca = 'Curtis',
    presentacion = '1 pieza',
    descripcion = 'Pinza tijera Curtis Lady Maxi modelo 57LC para cejas'
where sku = 'FC-IFC-PINZAGR';

update public.productos
set nombre = 'Centrassol 300/15/6 mg C/12 óvulos Loeffler',
    marca = 'Loeffler',
    presentacion = 'Caja con 12 óvulos',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '300/15/6 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Metronidazol / Centella asiática / Nitrofural'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Óvulos'),
    descripcion = 'Centrassol metronidazol 300 mg, centella asiática 15 mg, nitrofural 6 mg C/12 óvulos Loeffler'
where sku = 'EQ-LOE111';

update public.productos
set nombre = 'Baby Einstein Neptune''s Busy Bubbles juguete sensorial Ocean Explorers',
    marca = 'Baby Einstein',
    presentacion = '1 pieza · modelo 16656 · 3+ meses',
    descripcion = 'Baby Einstein Ocean Explorers Neptune''s Busy Bubbles · Kids2 modelo 16656 · UPC 074451166561'
where sku = 'FC-45116656';

update public.productos
set nombre = 'Pinza depilar Merheje Basic C/12',
    marca = 'Merheje',
    presentacion = 'Cartela con 12 piezas',
    descripcion = 'Pinzas depilatorias Merheje Basic punta recta, cartela C/12'
where sku = 'FC-IFC-PIN01';

update public.productos
set nombre = 'Gerber Comidita casera res, verduras y arroz 100 g',
    marca = 'Gerber',
    presentacion = 'Frasco 100 g',
    descripcion = 'Gerber Etapa 2 Comidita casera res, verduras y arroz 100 g'
where sku = 'FC-75102520';

update public.productos
set nombre = 'Gerber Comidita casera pollo con verduras y arroz 100 g',
    marca = 'Gerber',
    presentacion = 'Frasco 100 g',
    descripcion = 'Gerber Etapa 2 Comidita casera pollo con verduras y arroz 100 g'
where sku = 'FC-75102537';

update public.productos
set nombre = 'Gerber Cosecha natural mango 100 g',
    marca = 'Gerber',
    presentacion = 'Frasco 100 g',
    descripcion = 'Gerber Etapa 2 Cosecha natural mango 100 g'
where sku = 'FC-75102469';

update public.productos
set nombre = 'Gerber Cosecha natural durazno 100 g',
    marca = 'Gerber',
    presentacion = 'Frasco 100 g',
    descripcion = 'Gerber Etapa 2 Cosecha natural durazno 100 g'
where sku = 'FC-75102476';

create temporary table tmp_foto_resto83 (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto83 (sku, url, origen)
values
  ('FC-46504859', 'https://www.farmacapital.mx/catalogo-propia/xiomara-pomada-wax-shine-black-60g.jpg', 'propia'),
  ('FC-68900127', 'https://www.farmacapital.mx/catalogo-propia/dibar-gasa-simple-10x10-10pz.jpg', 'propia'),
  ('FC-IFC-PINZACH', 'https://www.farmacapital.mx/catalogo-propia/curtis-lady-mini-58lc.jpg', 'propia'),
  ('FC-IFC-PINZAGR', 'https://www.farmacapital.mx/catalogo-propia/curtis-lady-maxi-57lc.jpg', 'propia'),
  ('EQ-LOE111', 'https://www.farmacapital.mx/catalogo-propia/centrassol-loeffler-300-15-6-c12.jpg', 'propia'),
  ('FC-45116656', 'https://www.farmacapital.mx/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg', 'propia'),
  ('FC-IFC-PIN01', 'https://www.farmacapital.mx/catalogo-propia/merheje-basic-pinza-c12.jpg', 'propia'),
  ('FC-75102520', 'https://www.farmacapital.mx/catalogo-propia/gerber-comidita-casera-res-100g.jpg', 'propia'),
  ('FC-75102537', 'https://www.farmacapital.mx/catalogo-propia/gerber-comidita-casera-pollo-100g.jpg', 'propia'),
  ('FC-75102469', 'https://www.farmacapital.mx/catalogo-propia/gerber-cosecha-natural-mango-100g.jpg', 'propia'),
  ('FC-75102476', 'https://www.farmacapital.mx/catalogo-propia/gerber-cosecha-natural-durazno-100g.jpg', 'propia');

create temporary table tmp_foto_resto83_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto83_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_resto83 m on p.sku = m.sku
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_resto83_match m
where p.id = m.producto_id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_resto83_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_resto83_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_resto83_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_resto83_match)
  and i.url in (select url from tmp_foto_resto83_match)
  and not i.es_principal;

commit;
