-- Fotos de tarjeta que hoy salen como caja vacía (16-sep-2026 noche)
-- Gastro/Diabetes/Hipertensión/Alergia de las capturas + otras
-- cuya principal catalogo-propia aún no está en el CDN (Vercel = HTML).
--
-- URLs VIVAS (Fahorro / ficha de lab / mayoreo). Se ve al pegar.
-- Copias propias de las 7 de las capturas: public/catalogo-propia/
--
-- Si un Run anterior falló con ux_producto_imagenes_producto_posicion,
-- el begin se revirtió: pega ESTE archivo completo de nuevo.
--
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temporary table tmp_foto_caja (
  sku text,
  ean text,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_caja (sku, ean, url, origen)
values
  ('FC-65006386', '7501165006386', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501165006386.jpg', 'distribuidor'),
  ('FC-65006171', '7501165006171', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501165006171.jpg', 'distribuidor'),
  ('FC-30042152', '7501300421524', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501300421524.jpg', 'distribuidor'),
  ('FC-98223704', '7501298223704', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501298223704.jpg', 'distribuidor'),
  ('FC-00422750', '7501300422750', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501300422750.jpg', 'distribuidor'),
  ('FC-09902866', '7501109902866', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501109902866.jpg', 'distribuidor'),
  ('FC-09902637', '7501109902637', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501109902637.jpg', 'distribuidor'),
  ('FC-00420824', '7501300420824', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501300420824.jpg', 'distribuidor'),
  ('FC-03476594', '7702003476594', 'https://production-media.fahorro.com/media/catalog/product/7/7/7702003476594.jpg', 'distribuidor'),
  ('FC-42270027', '42270027', 'https://production-media.fahorro.com/media/catalog/product/4/2/42270027_1.jpg', 'distribuidor'),
  ('FC-51037878', '7891051037878', 'https://production-media.fahorro.com/media/catalog/product/7/8/7891051037878.jpg', 'distribuidor'),
  ('FC-35258166', '7500435258166', 'https://production-media.fahorro.com/media/catalog/product/7/5/7500435258166.jpg', 'distribuidor'),
  ('FC-35906341', '7501035906341', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501035906341_1.jpg', 'distribuidor'),
  ('FC-46501100', '7501846501100', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501846501100.jpg', 'distribuidor'),
  ('FC-45798022', '7503045798022', 'https://ik.imagekit.io/buscamed/10923949111479001139.webp', 'distribuidor'),
  ('FC-46016507', '7503046016507', 'https://ascendlabs.cl/wp-content/uploads/2025/04/Metformina-XR-750-mg-3x10s-600x600.jpg', 'otro'),
  ('FC-8497593', '7501008497593', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501008497593.jpg', 'distribuidor'),
  ('FC-75004996', '75004996', 'https://production-media.fahorro.com/media/catalog/product/7/5/75004996_1.jpg', 'distribuidor'),
  ('FC-17048860', '7891317048860', 'https://production-media.fahorro.com/media/catalog/product/7/8/7891317048860.jpg', 'distribuidor'),
  ('FC-00753067', '020800753067', 'https://production-media.fahorro.com/media/catalog/product/0/2/020800753067_1.jpg', 'distribuidor'),
  ('FC-68810713', '7501168810713', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501168810713.jpg', 'distribuidor'),
  ('FC-93025919', '7791293025919', 'https://production-media.fahorro.com/media/catalog/product/7/7/7791293025919_1.jpg', 'distribuidor'),
  ('FC-007206', '6910021007206', 'https://production-media.fahorro.com/media/catalog/product/6/9/6910021007206.jpg', 'distribuidor'),
  ('FC-16800803', '7501943474994', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501943474994_1.jpg', 'distribuidor'),
  ('FC-42507240', '070942507240', 'https://production-media.fahorro.com/media/catalog/product/0/7/070942507240.jpg', 'distribuidor'),
  ('FC-43454743', '7501943454743', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501943454743.jpg', 'distribuidor'),
  ('FC-31976394', '7702031976394', 'https://production-media.fahorro.com/media/catalog/product/7/7/7702031976394.jpg', 'distribuidor'),
  ('FC-10974329', '7891010974329', 'https://production-media.fahorro.com/media/catalog/product/7/8/7891010974329.jpg', 'distribuidor'),
  ('FC-31887928', '7702031887928', 'https://production-media.fahorro.com/media/catalog/product/7/7/7702031887928.jpg', 'distribuidor'),
  ('FC-75062897', '75062897', 'https://production-media.fahorro.com/media/catalog/product/7/5/75062897.jpg', 'distribuidor'),
  ('FC-93022567', '7791293022567', 'https://production-media.fahorro.com/media/catalog/product/7/7/7791293022567.jpg', 'distribuidor'),
  ('FC-75062927', '75062927', 'https://production-media.fahorro.com/media/catalog/product/7/5/75062927.jpg', 'distribuidor'),
  ('FC-09498091', '7896009498091', 'https://production-media.fahorro.com/media/catalog/product/7/8/7896009498091_1.jpg', 'distribuidor'),
  ('FC-40171550', '7794640171550', 'https://production-media.fahorro.com/media/catalog/product/7/7/7794640171550.jpg', 'distribuidor'),
  ('FC-25301752', '7501825301752', 'https://wecarepharma.mx/cdn/shop/files/7501825301752_1200x1200.jpg?v=1744665013', 'distribuidor'),
  ('FC-25301721', '7501825301721', 'https://bspharma.net/wp-content/uploads/2024/09/BIOFILEN-50MG-.jpg', 'distribuidor'),
  ('FC-LV-SKITTLES24', '7502226816944', 'https://production-media.fahorro.com/media/catalog/product/7/5/7502226816944.jpg', 'distribuidor'),
  ('EQ-VAL063', '7501122960201', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501122960201.jpg', 'distribuidor'),
  ('EQ-NOV007', '7501075711011', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501075711011.jpg', 'distribuidor'),
  ('FC-84900204', '759684900204', 'https://production-media.fahorro.com/media/catalog/product/7/5/759684900204.jpg', 'distribuidor'),
  ('FC-40071775', '650240071775', 'https://production-media.fahorro.com/media/catalog/product/6/5/650240071775.jpg', 'distribuidor'),
  ('FC-95337454', '7506295337454', 'https://production-media.fahorro.com/media/catalog/product/7/5/7506295337454.jpg', 'distribuidor'),
  ('FC-50003314', '714706800900', 'https://production-media.fahorro.com/media/catalog/product/7/1/714706800900.jpg', 'distribuidor'),
  ('FC-98073256', '3664798073256', 'https://production-media.fahorro.com/media/catalog/product/3/6/3664798073256.jpg', 'distribuidor'),
  ('FC-35230445', '7500435230445', 'https://production-media.fahorro.com/media/catalog/product/7/5/7500435230445_1.jpg', 'distribuidor'),
  ('FC-80596011', '3664798059601', 'https://production-media.fahorro.com/media/catalog/product/3/6/3664798059601_1.jpg', 'distribuidor'),
  ('FC-90910182', '7501390910182', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501390910182.jpg', 'distribuidor'),
  ('FC-8062229', '3664798062229', 'https://production-media.fahorro.com/media/catalog/product/3/6/3664798062229_1.jpg', 'distribuidor'),
  ('FC-87010404', '7501587010404', 'https://production-media.fahorro.com/media/catalog/product/7/5/7501587010404.jpg', 'distribuidor');

create temporary table tmp_foto_caja_match (
  producto_id bigint primary key,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_caja_match (producto_id, url, origen)
select distinct on (p.id)
  p.id,
  m.url,
  m.origen
from public.productos p
join tmp_foto_caja m
  on (
    (m.sku is not null and p.sku = m.sku)
    or (m.ean is not null and nullif(btrim(p.codigo_barras), '') = m.ean)
  )
order by p.id, m.url;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_caja_match m
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
from tmp_foto_caja_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_caja_match)
  and i.es_principal
  and i.url not in (
    select m.url from tmp_foto_caja_match m where m.producto_id = i.producto_id
  );

-- ux_producto_imagenes_producto_posicion: NyQuil Z (1732) ya tiene
-- catalogo-propia en posicion 0. Hay que soltar esa plaza antes.
update public.producto_imagenes i
set posicion = (
  select coalesce(max(x.posicion), 0) + 1
  from public.producto_imagenes x
  where x.producto_id = i.producto_id
)
where i.producto_id in (select producto_id from tmp_foto_caja_match)
  and i.posicion = 0
  and i.url not in (
    select m.url from tmp_foto_caja_match m where m.producto_id = i.producto_id
  );

update public.producto_imagenes i
set es_principal = true,
    posicion = 0
where i.producto_id in (select producto_id from tmp_foto_caja_match)
  and i.url in (
    select m.url from tmp_foto_caja_match m where m.producto_id = i.producto_id
  );

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  left(p.imagen_url, 96) as foto
from public.productos p
join tmp_foto_caja_match m on m.producto_id = p.id
order by p.sku;

commit;
