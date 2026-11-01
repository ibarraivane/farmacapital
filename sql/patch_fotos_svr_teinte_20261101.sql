-- ============================================================================
-- FARMA CAPITAL — Fotos oficiales SVR + distinguir Sun Secure Teinté
-- 2026-11-01 · fuente: mx.svr.com (Shopify CDN → catalogo-propia/)
--
-- Problema: stock SVR quedó sin foto; en POS los dos Blur SPF50+ se veían
-- casi iguales porque el título corto perdía «Teinté».
--
-- EAN 3662361002597 = Blur SPF50+ SIN color (stock 20)
-- EAN 3662361003167 = Blur Teinté SPF50+ CON color (stock 10)
--
-- ORDEN: 1) merge/deploy (fotos en public/catalogo-propia/)
--        2) pegar TODO este SQL en Supabase → Run
-- ============================================================================

begin;

create temporary table tmp_svr_fix_teinte (
  ean text primary key,
  sku text not null,
  nombre text not null,
  presentacion text not null,
  concentracion text,
  forma text,
  url text not null
) on commit drop;

insert into tmp_svr_fix_teinte
  (ean, sku, nombre, presentacion, concentracion, forma, url)
values
  (
    '3662361002450', 'FC-61002450',
    'SVR Sebiaclear Ampoule Flash',
    '30 ml', null, 'Ampolla',
    'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-ampoule-flash-30ml-3662361002450.jpg'
  ),
  (
    '3662361000364', 'FC-61000364',
    'SVR Sebiaclear Sérum',
    '30 ml', null, 'Sérum',
    'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-serum-30ml.jpg'
  ),
  (
    '3662361003402', 'FC-61003402',
    'SVR Sebiaclear Gel Moussant',
    '400 ml', null, 'Gel',
    'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-gel-moussant-400ml.jpg'
  ),
  (
    '3662361002597', 'FC-61002597',
    'SVR Sun Secure Blur SPF50+',
    '50 ml · sin color', 'SPF50+', 'Crema mousse',
    'https://www.farmacapital.mx/catalogo-propia/svr-sun-secure-blur-spf50-50ml-3662361002597.jpg'
  ),
  (
    '3662361003167', 'FC-61003167',
    'SVR Sun Secure Blur Teinté SPF50+',
    '50 ml · con color', 'SPF50+', 'Crema mousse',
    'https://www.farmacapital.mx/catalogo-propia/svr-sun-secure-blur-teinte-spf50-50ml-3662361003167.jpg'
  ),
  (
    '3662361001897', 'FC-61001897',
    'SVR Topialyse Gel Lavant',
    '400 ml', null, 'Gel',
    'https://www.farmacapital.mx/catalogo-propia/svr-topialyse-gel-lavant-400ml-3662361001897.jpg'
  ),
  (
    '3662361004300', 'FC-61004300',
    'SVR Hyalu Biotic Rechargeable',
    '50 ml', null, 'Gel',
    'https://www.farmacapital.mx/catalogo-propia/svr-hyalu-biotic-50ml-3662361004300.jpg'
  ),
  (
    '3662361003792', 'FC-61003792',
    'SVR Physiopure Gelée Moussante',
    '200 ml', null, 'Gelée',
    'https://www.farmacapital.mx/catalogo-propia/svr-physiopure-gelee-moussante-200ml-3662361003792.jpg'
  ),
  (
    '3662361000937', 'FC-61000937',
    'SVR Ampoule B3 Hydra',
    '30 ml', null, 'Ampolla',
    'https://www.farmacapital.mx/catalogo-propia/svr-ampoule-b3-hydra-30ml-3662361000937.jpg'
  ),
  (
    '3662361000401', 'FC-61000401',
    'SVR Ampoule C Anti-Ox',
    '30 ml', null, 'Ampolla',
    'https://www.farmacapital.mx/catalogo-propia/svr-ampoule-c-anti-ox-30ml-3662361000401.jpg'
  );

update public.productos p
set
  nombre = t.nombre,
  marca = 'SVR',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'SVR'),
  presentacion = t.presentacion,
  concentracion = coalesce(t.concentracion, p.concentracion),
  forma_farmaceutica = coalesce(t.forma, p.forma_farmaceutica),
  imagen_url = t.url,
  imagen_mobile_url = t.url,
  activo = true
from tmp_svr_fix_teinte t
where p.codigo_barras = t.ean
   or p.sku = t.sku
   or p.sku = 'FC-ND-' || right(t.ean, 8);

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.url,
  'catalogo-propia/' || regexp_replace(t.url, '^.*/', ''),
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  false,
  'propia'
from tmp_svr_fix_teinte t
join public.productos p
  on p.codigo_barras = t.ean
  or p.sku = t.sku
  or p.sku = 'FC-ND-' || right(t.ean, 8)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select p.id
  from public.productos p
  join tmp_svr_fix_teinte t
    on p.codigo_barras = t.ean
    or p.sku = t.sku
    or p.sku = 'FC-ND-' || right(t.ean, 8)
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
join tmp_svr_fix_teinte t
  on p.codigo_barras = t.ean
  or p.sku = t.sku
  or p.sku = 'FC-ND-' || right(t.ean, 8)
where i.producto_id = p.id
  and i.url = t.url;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.presentacion,
  p.concentracion,
  p.stock,
  p.precio,
  left(p.imagen_url, 96) as foto,
  (select count(*) from public.producto_imagenes i where i.producto_id = p.id) as n_imgs
from public.productos p
where p.codigo_barras in (
  '3662361002450','3662361000364','3662361003402','3662361002597','3662361003167',
  '3662361001897','3662361004300','3662361003792','3662361000937','3662361000401'
)
   or p.sku in (
  'FC-61002450','FC-61000364','FC-61003402','FC-61002597','FC-61003167',
  'FC-61001897','FC-61004300','FC-61003792','FC-61000937','FC-61000401'
)
order by p.nombre;
