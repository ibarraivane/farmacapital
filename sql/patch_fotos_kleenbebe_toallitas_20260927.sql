-- Fotos catalogo-propia · correr DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/kleenbebe-absorsec-140-7506425662388.jpg
--   public/catalogo-propia/kleenbebe-absorsec-90-7501943471337.jpg
--   public/catalogo-propia/dibar-venda-deportiva-pieza-7501868902527.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- Toallitas 140
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-140-7506425662388.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-140-7506425662388.jpg'
where (codigo_barras = '7506425662388' or sku in ('FC-25662388', 'FC-ND-25662388'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/kleenbebe-absorsec-140%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-140-7506425662388.jpg',
       'catalogo-propia/kleenbebe-absorsec-140-7506425662388.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7506425662388' or p.sku in ('FC-25662388', 'FC-ND-25662388'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/kleenbebe-absorsec-140%'
  );

-- Toallitas 90
update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-90-7501943471337.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-90-7501943471337.jpg'
where (codigo_barras = '7501943471337' or sku in ('FC-43471337', 'FC-ND-43471337'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/kleenbebe-absorsec-90%'
  );

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/kleenbebe-absorsec-90-7501943471337.jpg',
       'catalogo-propia/kleenbebe-absorsec-90-7501943471337.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and coalesce(i.es_principal, false)
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501943471337' or p.sku in ('FC-43471337', 'FC-ND-43471337'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/kleenbebe-absorsec-90%'
  );

-- Galería extra del rollo Dibar (no pisa packshot de caja si ya hay)
insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/dibar-venda-deportiva-pieza-7501868902527.jpg',
       'catalogo-propia/dibar-venda-deportiva-pieza-7501868902527.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       false,
       'propia'
from public.productos p
where (p.codigo_barras in ('7501868950207', '7501868902527')
    or p.sku in ('FC-IFC-83733', 'FC-68950207'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%dibar-venda-deportiva-pieza-7501868902527%'
  );

commit;

select
  sku,
  codigo_barras,
  presentacion,
  left(coalesce(imagen_url, ''), 100) as imagen
from public.productos
where codigo_barras in (
    '7506425662388', '7501943471337',
    '7501868950207', '7501868902527'
  )
   or sku in (
    'FC-25662388', 'FC-ND-25662388',
    'FC-43471337', 'FC-ND-43471337',
    'FC-IFC-83733', 'FC-68950207'
  )
order by presentacion, sku;
