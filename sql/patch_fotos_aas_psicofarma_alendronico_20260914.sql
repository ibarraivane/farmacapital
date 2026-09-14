-- Corrección: Acetilsalicílico Ef es Psicofarma, no AMSA.
-- Ácido Alendrónico AMSA 10 mg C/30: el JPG ya vive en catalogo-propia
-- (EQ-AMS147 ya apunta a esa URL; esto solo completa galería si faltaba).
--
-- Pegar DESPUÉS de patch_fotos_resto_busqueda_20260914.sql
-- (o solo este archivo si ya corriste el lote AMSA por error).
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Fuentes (cada caja se abrió):
--   FC-95779436 Acetilsalicílico Ef
--     https://farmasmart.com/acido-acetilsalicilico-ef-20-tab-300-mg
--     EAN 7501384504908 · caja Psicofarma 300 mg efervescente C/20
--     EQ-ALP0300 ya tiene ese EAN (UNIQUE: no se copia)
--   EQ-AMS147 Ácido alendrónico 10 mg C/30 AMSA
--     https://vitau.mx/acido-alendronico-10mg-caja-con-30-tabletas-15236
--     EAN 7501349014190 · foto de la caja de mostrador
--
-- Pide deploy de Vercel para que las URLs de catalogo-propia existan.

begin;

-- Sobrescribe nombre/marca/foto aunque el lote anterior haya puesto AMSA.
update public.productos
set nombre = 'Ácido acetilsalicílico efervescente 300 mg C/20',
    marca = 'Psicofarma',
    presentacion = 'Caja con 20 tabletas efervescentes',
    concentracion = '300 mg',
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ácido acetilsalicílico'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas efervescentes'),
    categoria = case when coalesce(categoria, '') in ('', 'Otro') then 'Analgésico' else categoria end,
    descripcion = 'Ácido acetilsalicílico efervescente Psicofarma 300 mg C/20',
    imagen_url = 'https://www.farmacapital.mx/catalogo-propia/aas-efervescente-psicofarma-300mg-c20.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/aas-efervescente-psicofarma-300mg-c20.jpg'
where sku = 'FC-95779436';

update public.productos
set imagen_url = coalesce(nullif(btrim(imagen_url), ''),
      'https://www.farmacapital.mx/catalogo-propia/acido-alendronico-10-30-amsa.jpg'),
    imagen_mobile_url = coalesce(nullif(btrim(imagen_mobile_url), ''),
      'https://www.farmacapital.mx/catalogo-propia/acido-alendronico-10-30-amsa.jpg')
where sku = 'EQ-AMS147';

create temporary table tmp_foto_psico_alend (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_psico_alend (sku, url, origen)
values
  ('FC-95779436',
   'https://www.farmacapital.mx/catalogo-propia/aas-efervescente-psicofarma-300mg-c20.jpg',
   'propia'),
  ('EQ-AMS147',
   'https://www.farmacapital.mx/catalogo-propia/acido-alendronico-10-30-amsa.jpg',
   'propia');

create temporary table tmp_foto_psico_alend_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_psico_alend_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_psico_alend m on p.sku = m.sku
order by p.id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_psico_alend_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_psico_alend_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_psico_alend_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_psico_alend_match)
  and i.url in (select url from tmp_foto_psico_alend_match)
  and not i.es_principal;

commit;
