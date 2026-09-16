-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/acido-folico-valdecasas-5mg-50tab-7501446000553.jpg
--   public/catalogo-propia/cboost-colageno-90gomitas-7501022112250.jpg
--   public/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg
--   public/catalogo-propia/garnier-express-aclara-serum-30ml-7509552875461.jpg
--   public/catalogo-propia/vivioptal-30-caps-7501587010404.jpg
-- Origen: nadro.vtexassets.com (packshot iNadro).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/acido-folico-valdecasas-5mg-50tab-7501446000553.jpg'
where (codigo_barras = '7501446000553' or sku in ('FC-46000553', 'FC-ND-46000553'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/acido-folico-valdecasas-5mg-50tab%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/cboost-colageno-90gomitas-7501022112250.jpg'
where (codigo_barras = '7501022112250' or sku in ('FC-22112250', 'FC-ND-22112250'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/cboost-colageno-90gomitas%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg'
where (codigo_barras = '7502009746321' or sku in ('FC-09746321', 'FC-ND-09746321'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/nisolver-prednisolona-1mg-ml-100ml%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/garnier-express-aclara-serum-30ml-7509552875461.jpg'
where (codigo_barras = '7509552875461' or sku in ('FC-52875461', 'FC-ND-52875461'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/garnier-express-aclara-serum-30ml%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/vivioptal-30-caps-7501587010404.jpg'
where (codigo_barras = '7501587010404' or sku in ('FC-87010404', 'FC-ND-87010404'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/vivioptal-30-caps%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/acido-folico-valdecasas-5mg-50tab-7501446000553.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501446000553' or p.sku in ('FC-46000553', 'FC-ND-46000553'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/acido-folico-valdecasas-5mg-50tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/cboost-colageno-90gomitas-7501022112250.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501022112250' or p.sku in ('FC-22112250', 'FC-ND-22112250'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/cboost-colageno-90gomitas%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502009746321' or p.sku in ('FC-09746321', 'FC-ND-09746321'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/nisolver-prednisolona-1mg-ml-100ml%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/garnier-express-aclara-serum-30ml-7509552875461.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7509552875461' or p.sku in ('FC-52875461', 'FC-ND-52875461'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/garnier-express-aclara-serum-30ml%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/vivioptal-30-caps-7501587010404.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7501587010404' or p.sku in ('FC-87010404', 'FC-ND-87010404'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/vivioptal-30-caps%'
  );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.imagen_url
from public.productos p
where p.codigo_barras in (
  '7501446000553',
  '7501022112250',
  '7502009746321',
  '7509552875461',
  '7501587010404'
)
order by p.nombre;
