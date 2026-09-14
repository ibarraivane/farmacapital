-- Medicamentos: fabricante / Google / foto del mostrador (14-sep-2026)
-- Pegar DESPUÉS de patch_fotos_resto_129_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Fuentes (cada caja se abrió):
--   Merthiolate Rojo Kohn 20 ml · kohnmexico.com/producto/merthiolate-rojo-kohn/
--   Raamcinet 10 mg C/10 · WeCare / Curitek / ML MLM39474398 (ticket decía Ramcinet)
--   Losartán Alpharma 50 mg C/30 · foto de la caja real (mostrador)
--   Drosequim Adulto 300/160 200 ml · Sanorim / Quimpharma (ticket decía Drosquim)
--   Budenova 0.125 mg/ml 5 amp × 2 ml · Curitek / Novag
--   Hidroxin 10 mg C/30 · mavifarmaceutica.com/hidroxin (ticket decía Hidroxon)
--   LAÜR Adulto C/3 · MiFarma (ticket decía Aquito 500/100/30/4)
--
-- No se toca codigo_barras: esos EAN ya viven en FC-27872123 / EQ-MAI099 /
-- EQ-QUM070 / EQ-SON264 (UNIQUE).
-- No se usó: Aspirina 7501008491074; Protect 7501109900008; Compl / Tratidri /
-- Eferox / Amoxicilina / Gentamicina / Ursodesoxicólico / Acetilsalicílico Ef
-- (sin lab + cuenta). Drosequim infantil 150/80 ≠ adulto.

begin;

-- Nombres de mostrador (typos del ticket)
update public.productos
set nombre = 'Merthiolate Rojo Kohn 20 ml',
    marca = 'Kohn',
    presentacion = 'Frasco 20 mL',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Cloruro de benzalconio'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tintura'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Botiquín' else categoria end,
    descripcion = 'Merthiolate Rojo Kohn 20 ml'
where sku = 'FC-46601138';

update public.productos
set nombre = 'Merthiolate Rojo Kohn 20 ml',
    marca = 'Kohn',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Cloruro de benzalconio'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tintura'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Botiquín' else categoria end,
    descripcion = 'Merthiolate Rojo Kohn 20 ml'
where sku = 'FC-926099D3';

update public.productos
set nombre = 'Raamcinet cetirizina 10 mg C/10',
    marca = 'RAAM',
    presentacion = 'Caja con 10 tabletas',
    concentracion = '10 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Cetirizina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    categoria = 'Alergia',
    descripcion = 'Raamcinet cetirizina 10 mg C/10'
where sku = 'FC-26EA40A4';

update public.productos
set nombre = 'Losartán Alpharma 50 mg C/30',
    marca = 'Alpharma',
    presentacion = 'Caja con 30 tabletas',
    concentracion = '50 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Losartán'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    descripcion = 'Losartán Alpharma 50 mg C/30'
where sku = 'EQ-ALP0634';

update public.productos
set nombre = 'Drosequim Adulto jarabe 300/160 mg 200 ml',
    marca = 'Quimpharma',
    presentacion = 'Frasco 200 mL',
    concentracion = '300/160 mg/100 ml',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Dropropizina / Bromhexina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Jarabe'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro', 'Producto') then 'Respiratorio' else categoria end,
    descripcion = 'Drosequim Adulto jarabe miel-limón 200 ml'
where sku = 'FC-AA7B0686';

update public.productos
set nombre = 'Budenova budesonida 0.125 mg/ml 5 amp × 2 ml',
    marca = 'Novag',
    presentacion = '5 ampolletas de 2 ml',
    concentracion = '0.125 mg/ml',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Budesonida'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Suspensión para nebulizar'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Respiratorio' else categoria end,
    descripcion = 'Budenova 0.125 mg/ml 5 ampolletas de 2 ml'
where sku = 'FC-6C2878CF';

update public.productos
set nombre = 'Hidroxin hidroxizina 10 mg C/30',
    marca = 'Mavi',
    presentacion = 'Caja con 30 tabletas',
    concentracion = '10 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Hidroxizina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Alergia' else categoria end,
    descripcion = 'Hidroxin hidroxizina 10 mg C/30'
where sku = 'FC-1321B34F';

update public.productos
set nombre = 'LAÜR Adulto solución inyectable C/3',
    marca = 'SON''S',
    presentacion = 'Caja con 3 frascos ámpula, 3 ampolletas 3 mL y 3 jeringas',
    concentracion = '500/500/100/30/4 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ampicilina / Metamizol / Guaifenesina / Lidocaína / Clorfenamina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Solución inyectable'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Antibiótico' else categoria end,
    descripcion = 'LAÜR Adulto 500/500/100/30/4 mg C/3'
where sku = 'FC-44B6751A';

create temporary table tmp_foto_meds (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_meds (sku, url, origen)
values
  ('FC-46601138',
   'https://www.farmacapital.mx/catalogo-propia/merthiolate-rojo-kohn-20ml.jpg',
   'propia'), -- Merthiolate Rojo Kohn 20 ml · fabricante
  ('FC-926099D3',
   'https://www.farmacapital.mx/catalogo-propia/merthiolate-rojo-kohn-20ml.jpg',
   'propia'), -- mismo frasco; inventario C/25 = paquete Kohn
  ('FC-26EA40A4',
   'https://www.farmacapital.mx/catalogo-propia/raamcinet-10mg-c10.jpg',
   'propia'), -- Raamcinet 10 mg C/10 · WeCare 7502227872123
  ('EQ-ALP0634',
   'https://www.farmacapital.mx/catalogo-propia/losartan-alpharma-50mg-c30.jpg',
   'propia'), -- Losartán Alpharma 50 mg C/30 · caja de mostrador
  ('FC-AA7B0686',
   'https://www.farmacapital.mx/catalogo-propia/drosequim-adulto-200ml.jpg',
   'propia'), -- Drosequim Adulto 300/160 200 ml · frente
  ('FC-6C2878CF',
   'https://www.farmacapital.mx/catalogo-propia/budenova-0125-5amp-2ml.jpg',
   'propia'), -- Budenova 0.125 mg/ml 5 amp × 2 ml · no es 0.250
  ('FC-1321B34F',
   'https://www.farmacapital.mx/catalogo-propia/hidroxin-10mg-c30.jpg',
   'propia'), -- Hidroxin 10 mg C/30 · fabricante Mavi
  ('FC-44B6751A',
   'https://www.farmacapital.mx/catalogo-propia/laur-adulto-c3.jpg',
   'propia'); -- LAÜR Adulto C/3 · no es el infantil

create temporary table tmp_foto_meds_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_meds_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_meds m on p.sku = m.sku
where p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_meds_match m
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
from tmp_foto_meds_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_meds_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_meds_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_meds_match)
  and i.url in (select url from tmp_foto_meds_match)
  and not i.es_principal;

commit;
