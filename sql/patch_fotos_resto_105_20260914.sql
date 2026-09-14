-- Resto de pendientes post-SQL (14-sep-2026, noche)
-- Pegar DESPUÉS de patch_fotos_google_ean_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Cada pieza se abrió. Foto = frente de la pieza que se vende.
-- Pide deploy de Vercel. No se toca codigo_barras.
--
-- No se usó: Dibar 250 (Promexsa sigue mostrando 1 L);
-- Enterogermina Fahorro 4 billones ≠ 2 billones C/10;
-- Melox Nadro = dorso legal Sanofi; se usó el frente menta C/50;
-- Jaloma Mertodol 40 ml ≠ 60 ml; Jaloma rosas 250 ml ≠ 130 ml;
-- Gerber 113 g ≠ 100 g; Pantene 7501001303464 ≠ 3454;
-- Sico 7501685171113 ≠ 7501685171118; Voldratol C/1 ≠ C/25;
-- Valclan 500/125 ≠ ticket 10 tabs EAN 7503000422795;
-- SensiMedical 3 ml 22G / 60 ml: sin caja pública de ese calibre.

begin;

update public.productos
set nombre = 'Jeringa insulina SensiMedical 0.5 ml 31G x 6 mm',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/100)',
    descripcion = 'Jeringa insulina SensiMedical 0.5 ml 31G x 6 mm'
where sku = 'FC-23273451';

update public.productos
set nombre = 'Jeringa SensiMedical 3 ml 21G x 32 mm verde',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/100)',
    descripcion = 'Jeringa hipodérmica SensiMedical 3 ml 21G x 32 mm'
where sku = 'FMX-506388';

update public.productos
set nombre = 'Jeringa insulina SensiMedical 1 ml 27G x 13 mm',
    marca = 'SensiMedical',
    presentacion = '1 pieza 1 ml 27G x 13 mm',
    descripcion = 'Jeringa insulina SensiMedical 1 ml 27G x 13 mm'
where sku = 'FC-22300881';

update public.productos
set nombre = 'Jeringa insulina SensiMedical 0.3 ml 31G x 6 mm',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/100)',
    descripcion = 'Jeringa insulina SensiMedical 0.3 ml 31G x 6 mm'
where sku = 'FC-23272151';

update public.productos
set nombre = 'Jeringa SensiMedical 5 ml 21G x 32 mm verde',
    marca = 'SensiMedical',
    presentacion = '1 pieza (caja C/100)',
    descripcion = 'Jeringa hipodérmica SensiMedical 5 ml 21G x 32 mm'
where sku = 'FMX-506389';

update public.productos
set nombre = 'Contac Ultra C/12 tabletas',
    marca = 'Contac',
    presentacion = 'Caja con 12 tabletas',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '500/5/2 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Paracetamol / Fenilefrina / Clorfenamina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    descripcion = 'Contac Ultra paracetamol 500 mg + fenilefrina 5 mg + clorfenamina 2 mg C/12'
where sku = 'FC-50608272';

update public.productos
set nombre = 'GUM Paw Patrol gel dental infantil bubble gum 50 g',
    marca = 'GUM',
    presentacion = 'Tubo 50 g',
    descripcion = 'GUM Paw Patrol gel dental infantil sabor chicle 50 g'
where sku = 'FC-42003469';

update public.productos
set nombre = 'Pasta Lassar Andrómaco óxido de zinc 25% tarro 60 g',
    marca = 'Andrómaco',
    presentacion = 'Tarro 60 g',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '25%'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Óxido de zinc'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pasta'),
    descripcion = 'Pasta Lassar Andrómaco óxido de zinc 25% tarro 60 g'
where sku = 'FC-28951141';

update public.productos
set nombre = 'Xiomara Cera modeladora profesional 100 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 100 g',
    descripcion = 'Xiomara Cera modeladora para cabello brillo y fijación 100 g'
where sku = 'FC-46506181';

update public.productos
set nombre = 'Ego Force antitranspirante roll-on 45 ml',
    marca = 'Ego',
    presentacion = 'Roll-on 45 ml',
    descripcion = 'Ego Force antitranspirante roll-on 24 h 45 ml'
where sku = 'FC-75064938';

update public.productos
set nombre = 'Ricitos de Oro shampoo Agua de Coco 250 ml',
    marca = 'Ricitos de Oro',
    presentacion = 'Frasco 250 ml',
    descripcion = 'Ricitos de Oro shampoo hipoalergénico agua de coco 250 ml'
where sku = 'FC-36033735';

update public.productos
set nombre = 'Melox Plus menta tabletas masticables C/50',
    marca = 'Melox Plus',
    presentacion = 'Caja con 50 tabletas masticables',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '200/200/25 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Hidróxido de aluminio / Hidróxido de magnesio / Simeticona'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas masticables'),
    descripcion = 'Melox Plus antiácido-antigas sabor menta C/50'
where sku = 'FC-7048853';

update public.productos
set nombre = 'GUM cera de ortodoncia menta C/5',
    marca = 'GUM',
    presentacion = 'Caja con 5 barras',
    descripcion = 'GUM Orthodontic cera de ortodoncia precortada menta C/5'
where sku = 'FC-42507240';

update public.productos
set nombre = 'Enterogermina 2 billones C/10 ampolletas 5 ml',
    marca = 'Enterogermina',
    presentacion = 'Caja con 10 ampolletas de 5 ml',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '2 billones UFC / 5 ml'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Esporas de Bacillus clausii'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Suspensión oral'),
    descripcion = 'Enterogermina 2 billones UFC suspensión oral C/10 ampolletas de 5 ml'
where sku = 'FC-79807468';

update public.productos
set nombre = 'Tampax Super C/10',
    marca = 'Tampax',
    presentacion = 'Caja con 10 tampones super',
    descripcion = 'Tampax Super absorbentes internos C/10'
where sku = 'FC-08006033';

update public.productos
set nombre = 'Palmolive Neutro Balance jabón 100 g 8 pack',
    marca = 'Palmolive',
    presentacion = 'Paquete con 8 jabones de 100 g',
    descripcion = 'Palmolive Neutro Balance dermolimpiador 8 × 100 g'
where sku = 'FC-EXP-PALM8';

create temporary table tmp_foto_resto105 (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto105 (sku, url, origen)
values
  ('FC-23273451', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-insulina-05ml-31gx6.jpg', 'propia'),
  ('FMX-506388', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-3ml-21gx32-c100.jpg', 'propia'),
  ('FC-22300881', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-insulina-1ml-27gx13.jpg', 'propia'),
  ('FC-23272151', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-insulina-03ml-31gx6.jpg', 'propia'),
  ('FMX-506389', 'https://www.farmacapital.mx/catalogo-propia/sensimedical-5ml-21gx32-c100.jpg', 'propia'),
  ('FC-50608272', 'https://www.farmacapital.mx/catalogo-propia/contac-ultra-c12.jpg', 'propia'),
  ('FC-42003469', 'https://www.farmacapital.mx/catalogo-propia/gum-paw-patrol-gel-50g.jpg', 'propia'),
  ('FC-28951141', 'https://www.farmacapital.mx/catalogo-propia/pasta-lassar-andromaco-60g.jpg', 'propia'),
  ('FC-46506181', 'https://www.farmacapital.mx/catalogo-propia/xiomara-cera-modeladora-100g.jpg', 'propia'),
  ('FC-75064938', 'https://www.farmacapital.mx/catalogo-propia/ego-force-rollon-45ml.jpg', 'propia'),
  ('FC-36033735', 'https://www.farmacapital.mx/catalogo-propia/ricitos-oro-agua-coco-250ml.jpg', 'propia'),
  ('FC-7048853', 'https://www.farmacapital.mx/catalogo-propia/melox-plus-menta-c50.jpg', 'propia'),
  ('FC-42507240', 'https://www.farmacapital.mx/catalogo-propia/gum-cera-ortodoncia-menta.jpg', 'propia'),
  ('FC-79807468', 'https://www.farmacapital.mx/catalogo-propia/enterogermina-2b-c10.jpg', 'propia'),
  ('FC-08006033', 'https://www.farmacapital.mx/catalogo-propia/tampax-super-c10.jpg', 'propia'),
  ('FC-EXP-PALM8', 'https://www.farmacapital.mx/catalogo-propia/palmolive-neutro-balance-8x100g.jpg', 'propia');

create temporary table tmp_foto_resto105_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto105_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_resto105 m on p.sku = m.sku
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_resto105_match m
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
from tmp_foto_resto105_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_resto105_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_resto105_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_resto105_match)
  and i.url in (select url from tmp_foto_resto105_match)
  and not i.es_principal;

commit;
