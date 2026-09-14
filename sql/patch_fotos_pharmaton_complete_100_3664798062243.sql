-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivo: public/catalogo-propia/pharmaton-complete-100tab.jpg
-- Fuente: Benavides packshot EAN 3664798062243 (mismo frente que la caja).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/pharmaton-complete-100tab.jpg'
where (codigo_barras = '3664798062243' or sku in ('FC-98062243', 'FC-ND-98062243'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/pharmaton-complete-100tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/pharmaton-complete-100tab.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '3664798062243' or p.sku in ('FC-98062243', 'FC-ND-98062243'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/pharmaton-complete-100tab%'
  );

commit;

select
  sku,
  codigo_barras,
  nombre,
  left(coalesce(imagen_url, ''), 120) as imagen
from public.productos
where codigo_barras = '3664798062243'
   or sku in ('FC-98062243', 'FC-ND-98062243');
