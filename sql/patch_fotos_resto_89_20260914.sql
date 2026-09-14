-- Resto de 89 pendientes (14-sep-2026, noche)
-- Pegar DESPUÉS de patch_fotos_resto_105_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Cada pieza se abrió. Foto = frente de la pieza que se vende.
-- Pide deploy de Vercel. No se toca codigo_barras.
--
-- No se usó: Rexona Chedraui 50 g EAN 75069209 ≠ 45 g 75069223;
-- Bebin 120 ≠ 40/80; Dibar 250 sigue siendo 1 L;
-- Jaloma Mertodol 40 ml ≠ 60 ml; Pantene 3464 ≠ 3454;
-- Sico 1113 ≠ 1118; Tinkle solo collages de tienda.

begin;

update public.productos
set nombre = 'Jeringa SensiMedical 3 ml 22G x 32 mm negra',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/100)',
    descripcion = 'Jeringa hipodérmica SensiMedical 3 ml 22G x 32 mm'
where sku = 'FC-22300775';

update public.productos
set nombre = 'Jeringa SensiMedical 60 ml sin aguja',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/50)',
    descripcion = 'Jeringa SensiMedical 60 ml pivote concéntrico sin aguja'
where sku = 'FMX-301565';

update public.productos
set nombre = 'Rexona Men Sport Intense stick 45 g',
    marca = 'Rexona',
    presentacion = 'Stick 45 g',
    descripcion = 'Rexona Men Sport Intense antitranspirante stick 45 g'
where sku = 'FC-75069223';

update public.productos
set nombre = 'Pregabalina 150 mg C/28 cápsulas AMSA',
    marca = 'AMSA',
    presentacion = 'Caja con 28 cápsulas',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '150 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Pregabalina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
    descripcion = 'Pregabalina 150 mg C/28 cápsulas AMSA'
where sku = 'EQ-AMS234';

update public.productos
set nombre = 'Bebin Super toallitas húmedas C/40',
    marca = 'Bebin Super',
    presentacion = 'Paquete con 40 toallitas',
    descripcion = 'Bebin Super toallitas húmedas C/40'
where sku = 'FC-85103015';

update public.productos
set nombre = 'Bebin Super toallitas húmedas C/80',
    marca = 'Bebin Super',
    presentacion = 'Paquete con 80 toallitas',
    descripcion = 'Bebin Super toallitas húmedas con tapa C/80'
where sku = 'FC-85800198';

create temporary table tmp_foto_resto89 (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto89 (sku, url, origen)
values
  ('FC-22300775', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-3ml-22gx32-c100.jpg', 'propia'),
  ('FMX-301565', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-60ml-sin-aguja.jpg', 'propia'),
  ('FC-75069223', 'https://www.farmacapital.mx/catalogo-propia/rexona-sport-intense-stick-45g.jpg', 'propia'),
  ('EQ-AMS234', 'https://www.farmacapital.mx/catalogo-propia/pregabalina-amsa-150mg-c28.jpg', 'propia'),
  ('FC-85103015', 'https://www.farmacapital.mx/catalogo-propia/bebin-super-40.jpg', 'propia'),
  ('FC-85800198', 'https://www.farmacapital.mx/catalogo-propia/bebin-super-80.jpg', 'propia');

create temporary table tmp_foto_resto89_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto89_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_resto89 m on p.sku = m.sku
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_resto89_match m
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
from tmp_foto_resto89_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_resto89_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_resto89_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_resto89_match)
  and i.url in (select url from tmp_foto_resto89_match)
  and not i.es_principal;

commit;
