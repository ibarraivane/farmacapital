-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/chupon-ternura-flor-balon-miel-7501026462245.jpg
--   public/catalogo-propia/leukoplast-hypafix-10cm-x-2m-4042809591446.jpg
--   public/catalogo-propia/asepxia-polvo-compacto-canela-10g-650240032431.jpg
--   public/catalogo-propia/asepxia-bb-polvo-compacto-natural-mate-10g-650240032455.jpg
-- Origen: iNadro packshot (chupón, Asepxia Canela); retailers (Hypafix, Asepxia Natural Mate).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/chupon-ternura-flor-balon-miel-7501026462245.jpg'
where (codigo_barras = '7501026462245' or sku in ('FC-26462078', 'FC-ND-26462078'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/chupon-ternura-flor-balon-miel%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cm-x-2m-4042809591446.jpg'
where (codigo_barras = '4042809591446' or sku in ('FC-09591446', 'FC-ND-09591446'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/leukoplast-hypafix-10cm-x-2m%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/asepxia-polvo-compacto-canela-10g-650240032431.jpg'
where (codigo_barras = '650240032431' or sku in ('FC-40032431', 'FC-ND-40032431'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/asepxia-polvo-compacto-canela%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/asepxia-bb-polvo-compacto-natural-mate-10g-650240032455.jpg'
where (codigo_barras = '650240032455' or sku in ('FC-40032455', 'FC-ND-40032455'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/asepxia-bb-polvo-compacto-natural-mate%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/chupon-ternura-flor-balon-miel-7501026462245.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501026462245' or p.sku in ('FC-26462078', 'FC-ND-26462078'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/chupon-ternura-flor-balon-miel%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/leukoplast-hypafix-10cm-x-2m-4042809591446.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '4042809591446' or p.sku in ('FC-09591446', 'FC-ND-09591446'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/leukoplast-hypafix-10cm-x-2m%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/asepxia-polvo-compacto-canela-10g-650240032431.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '650240032431' or p.sku in ('FC-40032431', 'FC-ND-40032431'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/asepxia-polvo-compacto-canela%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/asepxia-bb-polvo-compacto-natural-mate-10g-650240032455.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '650240032455' or p.sku in ('FC-40032455', 'FC-ND-40032455'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/asepxia-bb-polvo-compacto-natural-mate%'
  );

commit;

select sku, codigo_barras, left(nombre, 48) as nombre, left(imagen_url, 80) as imagen
from public.productos
where codigo_barras in (
  '7501026462245', '4042809591446', '650240032431', '650240032455'
)
order by codigo_barras;
