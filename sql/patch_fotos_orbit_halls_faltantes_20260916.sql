-- Packshots VIVOS (16-sep-2026, corrección)
-- El SQL anterior apuntó a catalogo-propia/?v=2 ANTES del deploy.
-- Esos JPG en el CDN siguen siendo las fotos de celular; Extra Strong,
-- Skittles y Nórdiko dan 404 (el SPA devuelve HTML).
--
-- Este parche usa URLs de ficha que YA responden (Fahorro / Scorpion /
-- SuperDulces / Benavides). Se ve al pegar, sin esperar Vercel.
-- Las copias en public/catalogo-propia/ quedan para el deploy.
--
-- Galería: inserta es_principal=false y luego rota (ux_producto_imagenes_una_principal).
-- origen: distribuidor | propia | otro
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temporary table tmp_foto_pack (
  sku text,
  ean text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_pack (sku, ean, url, origen)
values
  -- gomas: improvisada / ?v=2 viejo → packshot que ya carga
  ('FC-LV-CLORETS40', '75068011',
   'https://superdulces.com/cdn/shop/files/1e715c8f6d9b5cb64e3075971c8f88ee_008ffc57-d76a-4f3d-8885-a8a29b7fa635.png?v=1732216115',
   'distribuidor'),
  ('FC-LV-ORBITFRE40', '75038762',
   'https://d1zc67o3u1epb0.cloudfront.net/media/catalog/product/1/4/14978_1__2.jpg',
   'distribuidor'),
  ('FC-LV-ORBITHB40', '75038823',
   'https://d1zc67o3u1epb0.cloudfront.net/media/catalog/product/1/6/16611_1__2.jpg',
   'distribuidor'),
  ('FC-LV-HALLSY12', '7622210267832',
   'https://production-media.fahorro.com/media/catalog/product/7/6/7622210267832_1.jpg',
   'distribuidor'),
  ('7622210267832', '7622210267832',
   'https://production-media.fahorro.com/media/catalog/product/7/6/7622210267832_1.jpg',
   'distribuidor'),
  ('FC-LV-HALLSX12', null,
   'https://www.benavides.com.mx/media/catalog/product/2/0/20260807_1047973.JPG',
   'distribuidor'),
  -- 404 actuales (catalogo-propia aún no está en el CDN)
  ('FC-LV-SKITTLES24', '7502226816944',
   'https://production-media.fahorro.com/media/catalog/product/7/5/7502226816944.jpg',
   'distribuidor'),
  ('FC-40071775', '650240071775',
   'https://production-media.fahorro.com/media/catalog/product/6/5/650240071775.jpg',
   'distribuidor');

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
  left(p.imagen_url, 96) as foto
from public.productos p
join tmp_foto_match m on m.producto_id = p.id
order by p.sku;

commit;
