-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Packshots iNadro → public/catalogo-propia/:
--   danzen-10mg-20tab-7501385491085.jpg
--   danzen-5mg-30tab-7501385420061.jpg
--   mifepristona-200mg-1tab-7502214986659.jpg (ya existía; se reafirma)
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/danzen-10mg-20tab-7501385491085.jpg'
where (codigo_barras = '7501385491085' or sku in ('FC-85491085', 'FC-ND-85491085'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/danzen-10mg-20tab%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/danzen-5mg-30tab-7501385420061.jpg'
where (codigo_barras = '7501385420061' or sku in ('FC-85420061', 'FC-ND-85420061'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/danzen-5mg-30tab%'
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
       'https://www.farmacapital.mx/catalogo-propia/danzen-10mg-20tab-7501385491085.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501385491085' or p.sku in ('FC-85491085', 'FC-ND-85491085'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/danzen-10mg-20tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/danzen-5mg-30tab-7501385420061.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501385420061' or p.sku in ('FC-85420061', 'FC-ND-85420061'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/danzen-5mg-30tab%'
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
where codigo_barras in ('7501385491085', '7501385420061', '7502214986659')
   or sku in (
     'FC-85491085', 'FC-85420061', 'FC-14986659',
     'FC-ND-85491085', 'FC-ND-85420061', 'FC-ND-14986659'
   );
