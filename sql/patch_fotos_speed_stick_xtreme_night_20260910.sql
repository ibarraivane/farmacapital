-- Foto catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivo: public/catalogo-propia/speed-stick-xtreme-night-crema-30g.jpg
-- (packshot Fahorro del tubo 30 g, EAN 7501033204920)
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/speed-stick-xtreme-night-crema-30g.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/speed-stick-xtreme-night-crema-30g.jpg'
where (codigo_barras = '7501033204920' or sku = 'FC-33204920')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url like '%fahorro.com%'
    or imagen_url not like '%catalogo-propia/speed-stick-xtreme-night-crema-30g%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/speed-stick-xtreme-night-crema-30g.jpg',
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from public.productos p
where (p.codigo_barras = '7501033204920' or p.sku = 'FC-33204920')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/speed-stick-xtreme-night-crema-30g%'
  );

commit;

select
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.imagen_url
from public.productos p
where p.codigo_barras = '7501033204920'
   or p.sku = 'FC-33204920';
