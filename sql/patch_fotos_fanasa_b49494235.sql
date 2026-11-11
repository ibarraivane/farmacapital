-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivo:
--   public/catalogo-propia/meladinina-fs-pomada-30g-7501088542756.jpg
-- Sin bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/meladinina-fs-pomada-30g-7501088542756.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/meladinina-fs-pomada-30g-7501088542756.jpg'
where (codigo_barras = '7501088542756' or sku in ('FC-88542756', 'FC-ND-88542756'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/meladinina-fs-pomada-30g%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/meladinina-fs-pomada-30g-7501088542756.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501088542756' or p.sku in ('FC-88542756', 'FC-ND-88542756'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/meladinina-fs-pomada-30g%'
  );

commit;

select
  p.sku,
  p.codigo_barras,
  left(p.nombre, 40) as nombre,
  left(p.imagen_url, 90) as imagen
from public.productos p
where p.codigo_barras = '7501088542756'
order by p.codigo_barras;
