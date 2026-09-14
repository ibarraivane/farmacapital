-- Fotos del resto de 129 (14-sep-2026, tercera pasada)
-- Pegar DESPUÉS de patch_fotos_nombre_exprezo_levic_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Cada renglón se abrió: frente de la pieza de mostrador.
-- Fragile (WP / Cloudfront / Buscamed / Claroshop) → catalogo-propia (pide deploy).
-- Fahorro / Nadro / Farmatodo se dejan como URL de distribuidor.
--
-- No se usó: Aspirina EAN 1074 (no existe ficha; 20/40 son otros códigos);
-- Losartán Alpharma (solo placeholder); Jaloma Mertodol 40 ml ≠ 60 ml;
-- Gerber 113 g ≠ 100 g; Rexona stick ≠ R-ON; Ego aerosol ≠ roll-on;
-- Sico lubricante ≠ condón; Piojitos ≠ Rayo; LAÜR adulto ≠ infantil.

begin;

create temporary table tmp_foto_resto (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto (sku, url, origen)
values
  -- EAN exacto Fahorro / Nadro
  ('FC-00721541',
   'https://production-media.fahorro.com/media/catalog/product/6/5/650240072154_1.jpg',
   'distribuidor'), -- Suerox Vitamins Energy manzana verde-limón 630 ml
  ('FC-LV-SKITTLES24',
   'https://production-media.fahorro.com/media/catalog/product/7/5/7502226816944_1.jpg',
   'distribuidor'), -- Skittles Original 22 g
  ('FC-58752796',
   'https://production-media.fahorro.com/media/catalog/product/7/5/7501058752796_1.jpg',
   'distribuidor'), -- Lysol Crisp Linen 475 g
  ('FC-38891190',
   'https://production-media.fahorro.com/media/catalog/product/0/6/067238891190_1.jpg',
   'distribuidor'), -- Dove Original 135 g · EAN 067238891190
  ('FC-67923654',
   'https://production-media.fahorro.com/media/catalog/product/7/5/7506267923654_1.jpg',
   'distribuidor'), -- Honey Keeper gel manzanilla-miel 200 ml · frente (Nadro _02 era el dorso)
  ('FC-07521317',
   'https://production-media.fahorro.com/media/catalog/product/7/5/7501507521317_1.jpg',
   'distribuidor'), -- Gotero de vidrio Damaco
  ('FC-40030963',
   'https://nadro.vtexassets.com/arquivos/ids/204029/650240030963_01.jpg',
   'distribuidor'), -- Teatrical Células Madre nutritiva 400 ml
  ('FC-36040450',
   'https://nadro.vtexassets.com/arquivos/ids/203690/37836040450_01.jpg',
   'distribuidor'), -- Grisi concha nácar manos 80 ml
  ('FC-21187575',
   'https://nadro.vtexassets.com/arquivos/ids/214202/7502221187575_01.jpg',
   'distribuidor'), -- Brut Deep Blue spray 150 ml · EAN exacto
  ('FC-20500201',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7011036/810120500195_01.jpg',
   'distribuidor'), -- Pert aceite de oliva 180 ml (Farmatodo; inventario 8101205002010)

  -- Copiadas a catalogo-propia (URL de terceros frágil)
  ('FC-06209763',
   'https://www.farmacapital.mx/catalogo-propia/savile-manzanilla-spray-150ml.jpg',
   'propia'), -- Savile sábila+manzanilla spray 150 ml · DelSol EAN exacto
  ('EQ-BIO212',
   'https://www.farmacapital.mx/catalogo-propia/colchicina-biomep-1mg-c30.jpg',
   'propia'), -- Colchicina Biomep 1 mg C/30 · Levic BIO212
  ('FC-73909859',
   'https://www.farmacapital.mx/catalogo-propia/sarox-omeprazol-20mg-c28.jpg',
   'propia'), -- Sarox Omeprazol 20 mg C/28 · Levic BIO213
  ('FC-40071775',
   'https://www.farmacapital.mx/catalogo-propia/nordiko-original-130g.jpg',
   'propia'), -- Nordiko Original 130 g
  ('FC-40071799',
   'https://www.farmacapital.mx/catalogo-propia/nordiko-icy-blast-130g.jpg',
   'propia'), -- Nordiko Icy Blast 130 g
  ('FMX-505937',
   'https://www.farmacapital.mx/catalogo-propia/pleniform-40-c30.jpg',
   'propia'), -- Pleniform-40 C/30 · Levic BMI076
  ('FC-08895196',
   'https://www.farmacapital.mx/catalogo-propia/ky6-clorfenamina-compuesta-c10.jpg',
   'propia'), -- KY6 Clorfenamina compuesta C/10 · Levic BRU150
  ('FC-01167001',
   'https://www.farmacapital.mx/catalogo-propia/laur-infantil-c3.jpg',
   'propia'), -- LAÜR Infantil C/3 · no es el adulto SON264
  ('FMX-307657',
   'https://www.farmacapital.mx/catalogo-propia/sensimedical-10ml-22gx32.jpg',
   'propia'), -- Jeringa SensiMedical 10 ml 22G x 32 mm negra · solo este calibre
  ('FMX-302884',
   'https://www.farmacapital.mx/catalogo-propia/solsun-cara-face-50g-fps50.jpg',
   'propia'), -- Sol-Sun Cara Face FPS 50+ 50 g · Levic BLB037
  ('FC-89592876',
   'https://www.farmacapital.mx/catalogo-propia/tegaderm-3m-10x12-c50.jpg',
   'propia'), -- Tegaderm 3M 1626W 10x12 cm C/50
  ('FMX-301721',
   'https://www.farmacapital.mx/catalogo-propia/vita-kid-c-jarabe-240ml.jpg',
   'propia'); -- Vita Kid-C jarabe naranja s/azúcar 240 ml · Levic CMD126 · EAN 7501590287855

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_resto m on p.sku = m.sku
where p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_match m
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
from tmp_foto_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.url in (select url from tmp_foto_match)
  and not i.es_principal;

commit;
