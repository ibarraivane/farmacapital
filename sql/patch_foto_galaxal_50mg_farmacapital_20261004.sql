-- Galaxal 50 mg (FC-59603757, EAN 7501559603757).
-- La ficha ya está. La foto quedó en jsDelivr con el texto JSDELIVR_SHA y no carga.
-- El JPG ya vive en public/catalogo-propia/.
-- ORDEN: 1) deploy  2) pegar este SQL en Supabase → SQL Editor → Run.
-- No toca precio, costo ni stock.

begin;

update public.productos p
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg'
where p.sku = 'FC-59603757'
  and (
    coalesce(p.imagen_url, '') ilike '%JSDELIVR_SHA%'
    or coalesce(p.imagen_url, '') ilike '%jsdelivr.net%'
    or btrim(coalesce(p.imagen_url, '')) = ''
  );

update public.producto_imagenes i
set url = 'https://www.farmacapital.mx/catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
    storage_path = 'catalogo-propia/galaxal-lacosamida-50mg-c14-7501559603757.jpg',
    origen = 'propia'
from public.productos p
where i.producto_id = p.id
  and p.sku = 'FC-59603757'
  and (
    coalesce(i.url, '') ilike '%JSDELIVR_SHA%'
    or coalesce(i.url, '') ilike '%jsdelivr.net%'
  );

commit;

select p.sku, p.nombre, p.imagen_url
from public.productos p
where p.sku = 'FC-59603757';
