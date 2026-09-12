-- Fotos oxitetraciclina 2026-09-12 · Tervutan + Terramicina
-- Fuentes packshot:
--   Tervutan 7502227879597 → Mercadofarma (RAAM caja 500 mg / 16 cáps)
--   Terramicina 7501287630506 → Pharmafast CDN (Pfizer 125 mg / 24 pastillas)
-- Archivos en public/catalogo-propia/ (este commit).
-- ORDEN: 1) merge/deploy a Vercel  2) pegar este SQL en Supabase.
--
-- Galería: inserta con es_principal=false y LUEGO degrada la anterior /
-- marca la nueva (evita ux_producto_imagenes_una_principal).
-- Idempotente: no pisa otra foto distinta; no duplica la misma URL.
begin;

-- FC-27879597 | 7502227879597 | Tervutan Oxitetraciclina 500 mg 16 cápsulas
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/tervutan-oxitetraciclina-500mg-16caps.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/tervutan-oxitetraciclina-500mg-16caps.jpg'
where (sku = 'FC-27879597' or codigo_barras = '7502227879597')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/tervutan-oxitetraciclina-500mg-16caps%'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/tervutan-oxitetraciclina-500mg-16caps.jpg',
  'catalogo-propia/tervutan-oxitetraciclina-500mg-16caps.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false, 'propia'
from public.productos p
where (p.sku = 'FC-27879597' or p.codigo_barras = '7502227879597')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/tervutan-oxitetraciclina-500mg-16caps%'
  );

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select id from public.productos
  where sku = 'FC-27879597' or codigo_barras = '7502227879597'
)
  and i.es_principal
  and i.url not like '%catalogo-propia/tervutan-oxitetraciclina-500mg-16caps%';

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (
  select id from public.productos
  where sku = 'FC-27879597' or codigo_barras = '7502227879597'
)
  and i.url like '%catalogo-propia/tervutan-oxitetraciclina-500mg-16caps%'
  and not i.es_principal;


-- Terramicina | 7501287630506 | Oxitetraciclina 125 mg 24 trociscos/pastillas
-- SKU puede variar (alta Farmalive 97); matchear por EAN / nombre de caja.
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos.jpg'
where (
    codigo_barras = '7501287630506'
    or (nombre ilike '%Terramicina%' and nombre ilike '%Oxitetraciclina%')
  )
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos%'
    or imagen_url !~* 'farmacapital\.mx/catalogo-propia/'
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
  'https://www.farmacapital.mx/catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos.jpg',
  'catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false, 'propia'
from public.productos p
where (
    p.codigo_barras = '7501287630506'
    or (p.nombre ilike '%Terramicina%' and p.nombre ilike '%Oxitetraciclina%')
  )
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url like '%catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos%'
  );

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select id from public.productos
  where codigo_barras = '7501287630506'
     or (nombre ilike '%Terramicina%' and nombre ilike '%Oxitetraciclina%')
)
  and i.es_principal
  and i.url not like '%catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos%';

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (
  select id from public.productos
  where codigo_barras = '7501287630506'
     or (nombre ilike '%Terramicina%' and nombre ilike '%Oxitetraciclina%')
)
  and i.url like '%catalogo-propia/terramicina-oxitetraciclina-125mg-24trociscos%'
  and not i.es_principal;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  left(coalesce(p.imagen_url, ''), 90) as foto
from public.productos p
where p.codigo_barras in ('7502227879597', '7501287630506')
   or p.sku = 'FC-27879597'
   or (p.nombre ilike '%Terramicina%' and p.nombre ilike '%Oxitetraciclina%')
order by p.sku;
