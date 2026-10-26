-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos:
--   public/catalogo-propia/dove-dermac-skin-calming-spray-150ml-7506306241206.jpg
--   public/catalogo-propia/dove-original-spray-150ml-7506306241183.jpg
--   public/catalogo-propia/memantina-10mg-28tab-7502242701200.jpg
--   public/catalogo-propia/zolufen-omeprazol-20mg-30caps-7502223553477.jpg
-- Packshots iNadro (no placeholder competencia).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dove-dermac-skin-calming-spray-150ml-7506306241206.jpg'
where (codigo_barras = '7506306241206' or sku in ('FC-06241206', 'FC-ND-06241206'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/dove-dermac-skin-calming%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dove-original-spray-150ml-7506306241183.jpg'
where (codigo_barras = '7506306241183' or sku in ('FC-06241183', 'FC-ND-06241183'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/dove-original-spray%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/memantina-10mg-28tab-7502242701200.jpg'
where (codigo_barras = '7502242701200' or sku in ('FC-42701200', 'FC-ND-42701200'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/memantina-10mg-28tab%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/zolufen-omeprazol-20mg-30caps-7502223553477.jpg'
where (codigo_barras = '7502223553477' or sku in ('FC-23553477', 'FC-ND-23553477'))
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/zolufen-omeprazol-20mg%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/dove-dermac-skin-calming-spray-150ml-7506306241206.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7506306241206' or p.sku in ('FC-06241206', 'FC-ND-06241206'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/dove-dermac-skin-calming%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/dove-original-spray-150ml-7506306241183.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7506306241183' or p.sku in ('FC-06241183', 'FC-ND-06241183'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/dove-original-spray%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/memantina-10mg-28tab-7502242701200.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502242701200' or p.sku in ('FC-42701200', 'FC-ND-42701200'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/memantina-10mg-28tab%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/zolufen-omeprazol-20mg-30caps-7502223553477.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where (p.codigo_barras = '7502223553477' or p.sku in ('FC-23553477', 'FC-ND-23553477'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/zolufen-omeprazol-20mg%'
  );

commit;

select sku, codigo_barras, left(nombre, 40) as nombre, left(imagen_url, 80) as imagen
from public.productos
where codigo_barras in (
  '7506306241206', '7506306241183', '7502242701200', '7502223553477'
)
order by codigo_barras;
