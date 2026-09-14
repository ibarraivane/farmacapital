-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivo:
--   public/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg
-- Fuente: Kids2 / Baby Einstein ficha modelo 16656 (packshot pieza).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg'
where (
    codigo_barras in ('074451166561', '74451166561', '0074451166561')
    or sku in ('FC-45116656', 'FC-ND-45116656')
  )
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (
    p.codigo_barras in ('074451166561', '74451166561', '0074451166561')
    or p.sku in ('FC-45116656', 'FC-ND-45116656')
  )
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656%'
  );

commit;

select
  sku,
  codigo_barras,
  nombre,
  left(coalesce(imagen_url, ''), 120) as imagen
from public.productos
where codigo_barras in ('074451166561', '74451166561', '0074451166561')
   or sku in ('FC-45116656', 'FC-ND-45116656')
order by nombre;
