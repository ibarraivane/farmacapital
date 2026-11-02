-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos en public/catalogo-propia/:
--   amcef-iv-1g-10ml-7501349012011.jpg
--   amcef-im-500mg-2ml-7501349011007.jpg
--   cboost-omega3-90gomitas-7501022112274.jpg
--   natural-health-colageno-biotina-ah-14gomitas-7501853805253.jpg
--   olnatura-just-omega3-120gomitas-7503024083439.jpg
--   metformina-lp-alpharma-500mg-30tab-7502226293929.jpg
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/amcef-iv-1g-10ml-7501349012011.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/amcef-iv-1g-10ml-7501349012011.jpg'
where (codigo_barras = '7501349012011' or sku in ('FC-49012011', 'FC-ND-49012011'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/amcef-iv-1g-10ml%'
  );

update public.productos
set
  imagen_url = coalesce(
    nullif(btrim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/amcef-im-500mg-2ml-7501349011007.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/amcef-im-500mg-2ml-7501349011007.jpg'
  )
where (codigo_barras = '7501349011007' or sku in ('FC-07F04F88', 'FC-49011007', 'FC-ND-49011007'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cboost-omega3-90gomitas-7501022112274.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/cboost-omega3-90gomitas-7501022112274.jpg'
where (codigo_barras = '7501022112274' or sku in ('FC-22112274', 'FC-ND-22112274'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/cboost-omega3%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/natural-health-colageno-biotina-ah-14gomitas-7501853805253.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/natural-health-colageno-biotina-ah-14gomitas-7501853805253.jpg'
where (codigo_barras = '7501853805253' or sku in ('FC-53805253', 'FC-ND-53805253'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/natural-health-colageno%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/olnatura-just-omega3-120gomitas-7503024083439.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/olnatura-just-omega3-120gomitas-7503024083439.jpg'
where (codigo_barras = '7503024083439' or sku in ('FC-24083439', 'FC-ND-24083439'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/olnatura-just-omega3%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/metformina-lp-alpharma-500mg-30tab-7502226293929.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/metformina-lp-alpharma-500mg-30tab-7502226293929.jpg'
where (codigo_barras = '7502226293929' or sku in ('FC-26293929', 'FC-ND-26293929'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/metformina-lp-alpharma-500%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/amcef-iv-1g-10ml-7501349012011.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501349012011' or p.sku in ('FC-49012011', 'FC-ND-49012011'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/amcef-iv-1g-10ml%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/amcef-im-500mg-2ml-7501349011007.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501349011007' or p.sku in ('FC-07F04F88', 'FC-49011007', 'FC-ND-49011007'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/amcef-im-500mg%'
  )
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url like '%catalogo-propia/amcef-im-500mg%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/cboost-omega3-90gomitas-7501022112274.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501022112274' or p.sku in ('FC-22112274', 'FC-ND-22112274'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/cboost-omega3%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/natural-health-colageno-biotina-ah-14gomitas-7501853805253.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501853805253' or p.sku in ('FC-53805253', 'FC-ND-53805253'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/natural-health-colageno%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/olnatura-just-omega3-120gomitas-7503024083439.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7503024083439' or p.sku in ('FC-24083439', 'FC-ND-24083439'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/olnatura-just-omega3%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/metformina-lp-alpharma-500mg-30tab-7502226293929.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502226293929' or p.sku in ('FC-26293929', 'FC-ND-26293929'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/metformina-lp-alpharma-500%'
  );

commit;

select
  p.sku,
  p.codigo_barras,
  left(p.nombre, 40) as nombre,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in (
  '7501349012011',
  '7501349011007',
  '7501022112274',
  '7501853805253',
  '7503024083439',
  '7502226293929'
)
order by p.codigo_barras;
