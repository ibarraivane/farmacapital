-- FIX: fotos que tenían imagen_url pero el archivo en catalogo-propia
-- aún no está en el CDN (Vercel devuelve HTML → caja vacía).
-- FORZAR URLs vivas que ya cargan. Pegar YA en Supabase.
-- Sin updated_at (esa columna no existe).

begin;

create temporary table tmp_foto_fix (
  sku text,
  ean text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_fix (sku, ean, url, origen)
values
  -- OK ya, reforzar por si acaso
  ('EQ-JAV050', '6358975544000',
   'https://cdn.shopify.com/s/files/1/0748/7052/2148/files/clorofila.png?v=1788883692',
   'distribuidor'),
  ('EQ-AMS147', '7501349014190',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7007139/7501349014190_01.jpg',
   'distribuidor'),
  -- ROTAS (catalogo-propia 404/HTML) → URL viva
  ('EQ-ALP0210', '7503004908875',
   'https://gruporfp.vteximg.com.br/arquivos/ids/7002009/7503004908875_01.jpg',
   'distribuidor'),
  ('FC-75068622', '75068622',
   'https://assets.unileversolutions.com/v1/82262316.png',
   'distribuidor'),
  -- Exomega en catálogo es 400 ml (EAN 3282770073577), NO la crema de noche
  ('FC-70073577', '3282770073577',
   'https://gruporfp.vteximg.com.br/arquivos/ids/6998023/3282770073577_01.jpg',
   'distribuidor'),
  -- Bicarbonato: JPG en la rama del PR (raw GitHub) hasta que se mergee/deploy
  ('FC-08DB70CB', '7503022640153',
   'https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/fotos-faltantes-packshots-b644/public/catalogo-propia/bicarbonato-velazquez-200g-7503022640153.jpg',
   'propia');

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
join tmp_foto_fix m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
  )
order by p.id, m.url;

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
  left(p.imagen_url, 110) as foto
from public.productos p
join tmp_foto_match m on m.producto_id = p.id
order by p.sku;

commit;
