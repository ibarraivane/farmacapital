-- Quinta pasada: los que faltaban, Google + fabricante (14-sep-2026)
-- Pegar DESPUÉS de patch_fotos_meds_fabricante_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Fuentes (cada caja se abrió):
--   Aspirina Bayer 500 mg C/80 · BuscaMed / Chedraui (inventario: 80 tabletas)
--   Compl = Bencil/Benz Comp AMSA 1.2 M UI 1 FA · Galarza EAN 7501349025271
--   Acetilsalicílico Ef = AAS efervescente Psicofarma 300 mg C/20
--     (Farmasmart EAN 7501384504908; EQ-ALP0300 ya tiene ese EAN)
--   SensiMedical 5 ml 22G x 32 mm C/100 · Promexsa
--   SensiMedical 20 ml 21G x 32 mm C/50 · Promexsa
--
-- No se toca codigo_barras (UNIQUE: EQ-AMS398 ya tiene 7501349025271).
-- No se usó: Dibar 250 (foto era 1 L); Ursofalk (lab desconocido);
-- Jaloma 60 ml Mertodol (público es 40 ml); otras SensiMedical (calibre distinto);
-- Amoxicilina / Gentamicina / Tratidri / Eferox / Protect / Ursodesoxicólico.

begin;

update public.productos
set nombre = 'Aspirina 500 mg C/80',
    marca = 'Aspirina',
    presentacion = 'Caja con 80 tabletas',
    concentracion = '500 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ácido acetilsalicílico'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Analgésico' else categoria end,
    descripcion = 'Aspirina Bayer 500 mg C/80'
where sku = 'FC-08491074';

update public.productos
set nombre = 'Bencil/Benz Comp 1.2 millones UI 1 FA',
    marca = 'AMSA',
    presentacion = 'Caja con 1 frasco ámpula y ampolleta 3 ml',
    concentracion = '1 200 000 UI',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Bencilpenicilina benzatínica / procaínica / cristalina'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Suspensión inyectable'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Antibiótico' else categoria end,
    descripcion = 'Bencilpenicilina benzatínica compuesta AMSA 1.2 millones UI'
where sku = 'FC-64EB83AA';

update public.productos
set nombre = 'Ácido acetilsalicílico efervescente 300 mg C/20',
    marca = 'Psicofarma',
    presentacion = 'Caja con 20 tabletas efervescentes',
    concentracion = '300 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ácido acetilsalicílico'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas efervescentes'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Analgésico' else categoria end,
    descripcion = 'Ácido acetilsalicílico efervescente Psicofarma 300 mg C/20'
where sku = 'FC-95779436';

create temporary table tmp_foto_resto2 (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto2 (sku, url, origen)
values
  ('FC-08491074',
   'https://www.farmacapital.mx/catalogo-propia/aspirina-bayer-500mg-c80.jpg',
   'propia'), -- Aspirina 500 mg C/80 · no es C/20 ni C/40
  ('FC-64EB83AA',
   'https://www.farmacapital.mx/catalogo-propia/bencil-benz-compuesta-amsa-12m.jpg',
   'propia'), -- Compl = Bencil/Benz Comp AMSA 1 FA
  ('FC-95779436',
   'https://www.farmacapital.mx/catalogo-propia/aas-efervescente-psicofarma-300mg-c20.jpg',
   'propia'), -- Acetilsalicílico Ef = Psicofarma 300 mg C/20 · no AMSA
  ('FMX-506386',
   'https://www.farmacapital.mx/catalogo-propia/sensimedical-5ml-22gx32-c100.jpg',
   'propia'), -- solo 5 ml 22G x 32 mm negra
  ('FMX-307658',
   'https://www.farmacapital.mx/catalogo-propia/sensimedical-20ml-21gx32-c50.jpg',
   'propia'); -- 20 ml 21G x 32 mm C/50

create temporary table tmp_foto_resto2_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_resto2_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_resto2 m on p.sku = m.sku
where p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_resto2_match m
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
from tmp_foto_resto2_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_resto2_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_resto2_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_resto2_match)
  and i.url in (select url from tmp_foto_resto2_match)
  and not i.es_principal;

commit;
