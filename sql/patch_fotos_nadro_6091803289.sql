-- Fotos Nadro 6091803289 — pegar DESPUES del deploy de catalogo-propia/
-- No va en el mismo txn que la recepcion. Solo si imagen_url esta vacia o no es catalogo-propia.

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-60ml-7501300420558.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-60ml-7501300420558.jpg'
where codigo_barras = '7501300420558'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/aliren-jarabe-60ml%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-120ml-7501300422132.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-120ml-7501300422132.jpg'
where codigo_barras = '7501300422132'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/aliren-jarabe-120ml%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dapagliflozina-metformina-10-1000-c14-7506513601114.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/dapagliflozina-metformina-10-1000-c14-7506513601114.jpg'
where codigo_barras = '7506513601114'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/dapagliflozina-metformina-10-1000-c14%'
  );

update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/ociplos-disper-30mg-c30-7502227876077.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/ociplos-disper-30mg-c30-7502227876077.jpg'
where codigo_barras = '7502227876077'
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/ociplos-disper-30mg-c30%'
  );

-- Actron ya tenia foto; solo rellena si falta.
update public.productos
set
  imagen_url = coalesce(
    nullif(btrim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/actron-600mg-10caps-7501318652453.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/actron-600mg-10caps-7501318652453.jpg'
  )
where codigo_barras = '7501318652453';

select
  codigo_barras as ean,
  sku,
  left(nombre, 48) as nombre,
  left(coalesce(imagen_url, ''), 110) as imagen
from public.productos
where codigo_barras in (
  '7501318652453',
  '7501300420558',
  '7501300422132',
  '7506513601114',
  '7502227876077'
)
order by codigo_barras;
