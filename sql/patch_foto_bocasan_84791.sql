-- Foto Bocasan Premium (alta Farmaceutica La Mejor 84791).
-- DESPUÉS del deploy de Vercel (el JPG vive en public/catalogo-propia/).
-- Si corres este SQL antes, la URL da 404.
-- No toca stock ni caducidad.

begin;

update public.productos
   set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg',
       imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg'
 where codigo_barras = '7501417515949'
   and sku in ('FC-41751594', 'FC-FLM-41751594')
   and coalesce(nullif(imagen_url, ''), '') = '';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg',
  'catalogo-propia/bocasan-premium-24-sobres.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.codigo_barras = '7501417515949'
  and p.sku in ('FC-41751594', 'FC-FLM-41751594')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg'
  );

update public.producto_imagenes i
   set es_principal = false
 where i.producto_id in (
   select p.id from public.productos p
   where p.codigo_barras = '7501417515949'
 )
   and i.url is distinct from 'https://www.farmacapital.mx/catalogo-propia/bocasan-premium-24-sobres.jpg'
   and i.es_principal;

commit;

select id, sku, nombre, imagen_url
  from public.productos
 where codigo_barras = '7501417515949';
