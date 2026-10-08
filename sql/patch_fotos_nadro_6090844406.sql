-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Packshots Nadro 6090844406:
--   mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg
--   exakta-latanoprost-0.05mg-3ml-75055813.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg'
where (codigo_barras = '7502231320696' or sku in ('FC-31320696', 'FC-ND-31320696'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502231320696' or p.sku in ('FC-31320696', 'FC-ND-31320696'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/mictrobil-bimatoprost-0.3mg-3ml-7502231320696%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813.jpg'
where (codigo_barras = '75055813' or sku in ('FC-75055813', 'FC-ND-75055813'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '75055813' or p.sku in ('FC-75055813', 'FC-ND-75055813'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/exakta-latanoprost-0.05mg-3ml-75055813%'
  );

commit;

select sku, codigo_barras, left(nombre, 40) as nombre, imagen_url
from public.productos
where codigo_barras in ('7502231320696', '75055813')
   or sku in ('FC-31320696', 'FC-ND-31320696', 'FC-75055813', 'FC-ND-75055813');
