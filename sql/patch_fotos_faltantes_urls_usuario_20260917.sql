-- Fotos faltantes (17-sep-2026) — fuentes que pasó el usuario
-- Pegar en Supabase → SQL Editor → Run.
--
-- URLs vivas (se ven al pegar, sin esperar deploy):
--   Clorofil · Sanorim / Shopify
--   Exomega Control · A-Derma / Pierre Fabre
--   Acarbosa 50 mg · Farmatodo
--   Ácido alendrónico 10 mg · Farmatodo
--   Savilé roll-on bicarbonato y limón · Unilever
--
-- Bicarbonato Velázquez 200 g: foto de mostrador con fondo blanco en
--   public/catalogo-propia/bicarbonato-velazquez-200g-7503022640153.jpg
--   → pegar ESTE SQL DESPUÉS del deploy de Vercel (si no, el SPA
--   devuelve HTML y la tarjeta queda vacía).
--
-- Copias propias (mismo lote, tras merge):
--   clorofil-jahvs-500ml-6358975544000.jpg
--   exomega-control-crema-noche-3282770397666.jpg
--   acarbosa-50mg-30tab-7503004908875.jpg
--   alendronico-10-7501349014190.jpg  (refresh Farmatodo)
--   savile-rollon-bicarbonato-limon-75068622.jpg
--   bicarbonato-velazquez-200g-7503022640153.jpg
--
-- No pisa foto si imagen_url ya tiene valor (salvo alendrónico AMSA
-- donde reforzamos el packshot Farmatodo _01).

begin;

create temporary table tmp_foto_pack (
  sku text,
  ean text,
  url text not null,
  origen text not null,
  forzar boolean not null default false
) on commit drop;

insert into tmp_foto_pack (sku, ean, url, origen, forzar)
values
  (null, '6358975544000',
   'https://cdn.shopify.com/s/files/1/0748/7052/2148/files/clorofila.png?v=1788883692',
   'distribuidor', false),
  (null, '3282770397666',
   'https://media-pierre-fabre.wedia-group.com/api/wedia/dam/transform/u5wa3z31qn5sjq97wwh4i4nwta1g7a1mjar9ere/out?t=resize&height=1200',
   'distribuidor', false),
  (null, '03282770397666',
   'https://media-pierre-fabre.wedia-group.com/api/wedia/dam/transform/u5wa3z31qn5sjq97wwh4i4nwta1g7a1mjar9ere/out?t=resize&height=1200',
   'distribuidor', false),
  (null, '7503004908875',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7002009/7503004908875_01.jpg',
   'distribuidor', false),
  (null, '7501349014190',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7007139/7501349014190_01.jpg',
   'distribuidor', true),
  ('FC-75068622', '75068622',
   'https://assets.unileversolutions.com/v1/82262316.png',
   'distribuidor', false),
  -- tras deploy:
  ('FC-08DB70CB', '7503022640153',
   'https://www.farmacapital.mx/catalogo-propia/bicarbonato-velazquez-200g-7503022640153.jpg',
   'propia', false);

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_match (producto_id, url, origen)
select distinct on (p.id)
  p.id,
  m.url,
  m.origen
from public.productos p
join tmp_foto_pack m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
  )
where m.forzar
   or coalesce(nullif(btrim(p.imagen_url), ''), '') = ''
order by p.id, m.forzar desc, m.url;

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
  and i.url not in (
    select m.url from tmp_foto_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set posicion = (
  select coalesce(max(x.posicion), 0) + 1
  from public.producto_imagenes x
  where x.producto_id = i.producto_id
)
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.posicion = 0
  and i.url not in (
    select m.url from tmp_foto_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set es_principal = true,
    posicion = 0
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.url in (
    select m.url from tmp_foto_match m where m.producto_id = i.producto_id
  );

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  left(p.imagen_url, 100) as foto
from public.productos p
join tmp_foto_match m on m.producto_id = p.id
order by p.sku;

commit;
