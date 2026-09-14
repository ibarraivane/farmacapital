-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/curitas-el-gallo-c6-7702003477270.jpg
--   public/catalogo-propia/estropajo-fclean-clasica-7503005405168.jpg
--   public/catalogo-propia/metoclopramida-10mg-20tab-7501563310269.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/curitas-el-gallo-c6-7702003477270.jpg'
where (codigo_barras = '7702003477270' or sku in ('FC-03477270', 'FC-ND-03477270'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/curitas-el-gallo-c6%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/estropajo-fclean-clasica-7503005405168.jpg'
where (codigo_barras = '7503005405168' or sku in ('FC-05405168', 'FC-ND-05405168'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/estropajo-fclean-clasica%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/metoclopramida-10mg-20tab-7501563310269.jpg'
where (codigo_barras = '7501563310269' or sku in ('FC-63310269', 'FC-ND-63310269'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/metoclopramida-10mg-20tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/curitas-el-gallo-c6-7702003477270.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7702003477270' or p.sku in ('FC-03477270', 'FC-ND-03477270'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/curitas-el-gallo-c6%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/estropajo-fclean-clasica-7503005405168.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7503005405168' or p.sku in ('FC-05405168', 'FC-ND-05405168'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/estropajo-fclean-clasica%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/metoclopramida-10mg-20tab-7501563310269.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501563310269' or p.sku in ('FC-63310269', 'FC-ND-63310269'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/metoclopramida-10mg-20tab%'
  );

commit;

select
  sku,
  codigo_barras,
  nombre,
  left(coalesce(imagen_url, ''), 110) as imagen
from public.productos
where codigo_barras in ('7702003477270', '7503005405168', '7501563310269')
   or sku in (
     'FC-03477270', 'FC-05405168', 'FC-63310269',
     'FC-ND-03477270', 'FC-ND-05405168', 'FC-ND-63310269'
   )
order by sku;
