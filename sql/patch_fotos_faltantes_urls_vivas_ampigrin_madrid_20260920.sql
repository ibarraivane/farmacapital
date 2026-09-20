-- Cierre del lote vivo 20-sep-2026.
-- 1) Ampigrin PFC cápsulas: el ilike %caps% no matchea "cápsulas".
-- 2) Madrid 125 ml: se le pegó el packshot de Flor de Aire (otra marca).
-- Pegar YA. No toca stock ni precio. No pisa Broxtorfan infantil ni jarabe Ampigrin.

begin;

-- Ampigrin PFC cápsulas C/24 (EAN 780083148676 / SKU FC-83148676)
update public.productos p
set imagen_url = 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg',
    imagen_mobile_url = 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg'
where p.sku = 'FC-83148676'
   or p.codigo_barras = '780083148676'
   or (
     p.nombre ilike '%ampigrin pfc%'
     and p.nombre ilike '%c_psul%'
     and p.nombre not ilike '%jarabe%'
   );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg',
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'distribuidor'
from public.productos p
where (p.sku = 'FC-83148676' or p.codigo_barras = '780083148676')
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url = 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg'
  );

update public.producto_imagenes i
set es_principal = false
from public.productos p
where i.producto_id = p.id
  and (p.sku = 'FC-83148676' or p.codigo_barras = '780083148676')
  and i.es_principal
  and i.url <> 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg';

update public.producto_imagenes i
set es_principal = true
from public.productos p
where i.producto_id = p.id
  and (p.sku = 'FC-83148676' or p.codigo_barras = '780083148676')
  and i.url = 'https://cdn.jsdelivr.net/gh/ibarraivane/farmacapital@7576424/public/catalogo-propia/ampigrin-pfc-capsulas-c-24.jpg'
  and not i.es_principal;

-- Madrid 125 ml: quitar packshot de Flor de Aire. La ficha Madrid no tenía
-- foto viva propia (catalogo-propia también responde HTML).
update public.productos p
set imagen_url = null,
    imagen_mobile_url = null
where (p.sku = 'FC-313000513' or p.codigo_barras = '7506313000513')
  and coalesce(p.imagen_url, '') ilike '%flor-de-aire%';

update public.producto_imagenes i
set es_principal = false
from public.productos p
where i.producto_id = p.id
  and (p.sku = 'FC-313000513' or p.codigo_barras = '7506313000513')
  and i.url ilike '%flor-de-aire%';

select p.id, p.sku, p.codigo_barras, left(p.nombre, 56) as nombre,
       left(coalesce(p.imagen_url, ''), 120) as imagen
from public.productos p
where p.sku in ('FC-83148676', 'FC-313000513', 'FC-28017051')
   or p.codigo_barras in ('780083148676', '7506313000513', '7502280170501')
order by p.nombre;

commit;
