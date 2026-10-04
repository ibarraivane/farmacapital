-- Foto de caja: Aktyzar Omeprazol 20 mg C/14 (Solfrán).
-- La foto la mandó el dueño el 02-oct-2026. Quedó en el PR #416
-- (rama cursor/fotos-caja-lote-20261002-47f0, borrador, sin merge)
-- apuntando a un SKU nuevo FC-74792207 que nunca se dio de alta.
-- En catálogo el producto vivo es EQ-SOF066 (stock 3, imagen_url null).
-- El C/120 (FC-82200016) ya tiene su propia foto; no se toca.
-- El EAN 7502274792207 hoy está en FC-16792555 (LGEN C/14). No se usa
-- para el match: pondría la caja Aktyzar en el genérico equivocado.
-- ORDEN: 1) merge/deploy del JPG  2) este SQL.
-- Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg',
    imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg'
where sku = 'EQ-SOF066'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207%'
  );

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id,
       'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207.jpg',
       coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
       not exists (
         select 1 from public.producto_imagenes i
         where i.producto_id = p.id and i.es_principal
       ),
       'propia'
from public.productos p
where p.sku = 'EQ-SOF066'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207%'
  );

update public.producto_imagenes i
set es_principal = true
from public.productos p
where p.sku = 'EQ-SOF066'
  and i.producto_id = p.id
  and i.url like '%catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207%'
  and not i.es_principal
  and not exists (
    select 1 from public.producto_imagenes o
    where o.producto_id = p.id
      and o.es_principal
      and o.url not like '%catalogo-propia/aktyzar-omeprazol-20mg-c-14-capsulas-7502274792207%'
  );

commit;

select id, sku, codigo_barras, nombre, presentacion, stock,
       left(coalesce(imagen_url, ''), 120) as imagen
from public.productos
where sku = 'EQ-SOF066';
