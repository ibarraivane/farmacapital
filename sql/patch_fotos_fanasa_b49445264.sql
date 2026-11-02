-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/fluxedan-6-12mg-24comp-7501070903237.jpg
--   public/catalogo-propia/fluxedan-jarabe-225ml-7501070900441.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/fluxedan-6-12mg-24comp-7501070903237.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/fluxedan-6-12mg-24comp-7501070903237.jpg'
where (codigo_barras = '7501070903237' or sku in ('FC-70903237', 'FC-ND-70903237'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/fluxedan-6-12mg-24comp%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/fluxedan-jarabe-225ml-7501070900441.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/fluxedan-jarabe-225ml-7501070900441.jpg'
where (codigo_barras = '7501070900441' or sku in ('FC-70900441', 'FC-ND-70900441'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/fluxedan-jarabe-225ml%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/fluxedan-6-12mg-24comp-7501070903237.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501070903237' or p.sku in ('FC-70903237', 'FC-ND-70903237'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/fluxedan-6-12mg-24comp%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/fluxedan-jarabe-225ml-7501070900441.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501070900441' or p.sku in ('FC-70900441', 'FC-ND-70900441'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/fluxedan-jarabe-225ml%'
  );

commit;

select
  p.sku,
  p.codigo_barras,
  left(p.nombre, 40) as nombre,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in ('7501070903237', '7501070900441')
order by p.codigo_barras;
