-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Descargar de iNadro y subir a public/catalogo-propia/:
--   excelsior-pomada-8g-7501022112106.jpg
--   mifepristona-200mg-1tab-7502214986659.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/excelsior-pomada-8g-7501022112106.jpg'
where (codigo_barras = '7501022112106' or sku in ('FC-22112106', 'FC-ND-22112106'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/excelsior-pomada-8g%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/mifepristona-200mg-1tab-7502214986659.jpg'
where (codigo_barras = '7502214986659' or sku in ('FC-14986659', 'FC-ND-14986659'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/mifepristona-200mg-1tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/excelsior-pomada-8g-7501022112106.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501022112106' or p.sku in ('FC-22112106', 'FC-ND-22112106'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/excelsior-pomada-8g%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/mifepristona-200mg-1tab-7502214986659.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502214986659' or p.sku in ('FC-14986659', 'FC-ND-14986659'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/mifepristona-200mg-1tab%'
  );

commit;

select sku, codigo_barras, left(nombre, 40) as nombre, imagen_url
from public.productos
where codigo_barras in ('7501022112106', '7502214986659')
   or sku in ('FC-22112106', 'FC-14986659', 'FC-ND-22112106', 'FC-ND-14986659');
