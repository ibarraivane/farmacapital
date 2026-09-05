-- Fotos nítidas · mismos productos y presentaciones, más píxeles.
-- Corrida DESPUÉS del deploy de Vercel (los JPG viven en public/catalogo-propia/).
-- ?v=2 para que el aparato no se quede con el JPEG de 250–480 px.
-- No toca stock, costo, PVP ni caducidad.
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fotos_nitidas (
  ean text,
  sku text,
  archivo text not null,
  url text not null
) on commit drop;

insert into _fc_fotos_nitidas (ean, sku, archivo, url) values
  ('7502227872697', 'EQ-RAM147',
   'preslopin-amlodipino-5-30-raam.jpg',
   'https://www.farmacapital.mx/catalogo-propia/preslopin-amlodipino-5-30-raam.jpg?v=2'),
  ('7501369200108', 'FC-69200108',
   'estomaquil-exper3-240ml.jpg',
   'https://www.farmacapital.mx/catalogo-propia/estomaquil-exper3-240ml.jpg?v=2'),
  ('7501369200108', 'FC-69200108',
   'estomaquil-exper3-240.jpg',
   'https://www.farmacapital.mx/catalogo-propia/estomaquil-exper3-240.jpg?v=2'),
  ('7502227426067', 'FC-27426067',
   'carticap-for-60-caps.jpg',
   'https://www.farmacapital.mx/catalogo-propia/carticap-for-60-caps.jpg?v=2'),
  ('7502227426067', 'FC-27426067',
   'carticap-for-c60.jpg',
   'https://www.farmacapital.mx/catalogo-propia/carticap-for-c60.jpg?v=2'),
  ('7501086453221', 'FC-86453221',
   'oral-b-gingivitis-350-ml.jpg',
   'https://www.farmacapital.mx/catalogo-propia/oral-b-gingivitis-350-ml.jpg?v=2'),
  ('7501086453221', 'FC-08645322',
   'oral-b-enjuague-gingivitis-350ml.jpg',
   'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-gingivitis-350ml.jpg?v=2'),
  ('7501349020542', 'EQ-AMS425',
   'irbesartan-300-28-amsa.jpg',
   'https://www.farmacapital.mx/catalogo-propia/irbesartan-300-28-amsa.jpg?v=2'),
  ('7502274791064', 'EQ-SOF040',
   'vixgoplisol-1000-30-solfran.jpg',
   'https://www.farmacapital.mx/catalogo-propia/vixgoplisol-1000-30-solfran.jpg?v=2'),
  ('7501075720365', 'EQ-NOV132',
   'danovag-omeprazol-20-14-novag.jpg',
   'https://www.farmacapital.mx/catalogo-propia/danovag-omeprazol-20-14-novag.jpg?v=2'),
  ('780083144296', 'EQ-COL146',
   'collifrin-infantil-oximetazolina-20ml.jpg',
   'https://www.farmacapital.mx/catalogo-propia/collifrin-infantil-oximetazolina-20ml.jpg?v=2'),
  (null, 'FC-MER-MANZANA',
   'mercurio-pomada-manzana-50g.jpg',
   'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg?v=2'),
  ('7503002045008', 'FC-1FBF5206',
   'reomatolum-del-viejito-60g.jpg',
   'https://www.farmacapital.mx/catalogo-propia/reomatolum-del-viejito-60g.jpg?v=2');

-- Una URL por producto: la primera fila del EAN/SKU.
update public.productos p
set
  imagen_url = t.url,
  imagen_mobile_url = t.url
from (
  select distinct on (coalesce(ean, ''), coalesce(sku, ''))
    ean, sku, url
  from _fc_fotos_nitidas
  order by coalesce(ean, ''), coalesce(sku, '')
) t
where (t.ean is not null and p.codigo_barras = t.ean)
   or (t.sku is not null and p.sku = t.sku);

-- La galería manda sobre imagen_url: reescribe la misma pieza.
update public.producto_imagenes i
set url = t.url
from _fc_fotos_nitidas t
where i.url like '%/catalogo-propia/' || t.archivo || '%'
  and i.url is distinct from t.url;

insert into public.producto_imagenes (
  producto_id, url, posicion, es_principal, origen
)
select
  p.id,
  t.url,
  0,
  not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and x.es_principal
  ),
  'propia'
from public.productos p
join (
  select distinct on (coalesce(ean, ''), coalesce(sku, ''))
    ean, sku, url
  from _fc_fotos_nitidas
  order by coalesce(ean, ''), coalesce(sku, '')
) t
  on (t.ean is not null and p.codigo_barras = t.ean)
  or (t.sku is not null and p.sku = t.sku)
where not exists (
  select 1 from public.producto_imagenes x
  where x.producto_id = p.id
    and (
      x.url = t.url
      or x.url like '%/catalogo-propia/' ||
         split_part(split_part(t.url, '/catalogo-propia/', 2), '?', 1) || '%'
    )
);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 42) as nombre,
  left(p.imagen_url, 90) as foto
from public.productos p
where p.codigo_barras in (
    '7502227872697', '7501369200108', '7502227426067', '7501086453221',
    '7501349020542', '7502274791064', '7501075720365', '780083144296',
    '7503002045008'
  )
   or p.sku in (
    'EQ-RAM147', 'FC-69200108', 'FC-27426067', 'FC-86453221', 'FC-08645322',
    'EQ-AMS425', 'EQ-SOF040', 'EQ-NOV132', 'EQ-COL146',
    'FC-MER-MANZANA', 'FC-1FBF5206'
  )
order by p.nombre;
