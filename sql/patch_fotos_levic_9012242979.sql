-- Fotos Levic A 9012242979 — pegar DESPUÉS del deploy de public/catalogo-propia/
-- Solo rellena si imagen_url está vacía (no pisa foto mejor).
-- Pendientes (sin packshot usable aquí): HT-Bloc 1 amp, Zagapsol, Tinitrend 30/40,
--   Arretin 30 g, Clorofil Jahvs, Carbamazepina (si vacía).

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/breflumar-5mg-7502227876428.jpg',
    updated_at = now()
where codigo_barras = '7502227876428'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/nisolver-100ml-7502009746321.jpg',
    updated_at = now()
where codigo_barras = '7502009746321'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/dolver-600mg-10tab-7502009747274.jpg',
    updated_at = now()
where codigo_barras = '7502009747274'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/pakid-325-200-20tab-7501842951657.jpg',
    updated_at = now()
where codigo_barras = '7501842951657'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/navontec-8mg-3amp-7506022315038.jpg',
    updated_at = now()
where codigo_barras = '7506022315038'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/ferro-4-30grag-7506281106019.jpg',
    updated_at = now()
where codigo_barras = '7506281106019'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/clonixinato-amsa-5amp-7501349020122.jpg',
    updated_at = now()
where codigo_barras = '7501349020122'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/lonixer-125mg-10tab-7501258203593.jpg',
    updated_at = now()
where codigo_barras = '7501258203593'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/laritol-ex-30ml-7502009742798.jpg',
    updated_at = now()
where codigo_barras = '7502009742798'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/gelubrin-600-7503027446279.jpg',
    updated_at = now()
where codigo_barras = '7503027446279'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/alendronico-10-7501349014190.jpg',
    updated_at = now()
where codigo_barras = '7501349014190'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/prochor-40-7501277071685.jpg',
    updated_at = now()
where codigo_barras = '7501277071685'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/diotexona-7502211788690.jpg',
    updated_at = now()
where codigo_barras = '7502211788690'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/tretinoina-biovitol-7501563380415.jpg',
    updated_at = now()
where codigo_barras = '7501563380415'
  and coalesce(nullif(imagen_url, ''), '') = '';

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/metoprolol-bea-7501342804408.jpg',
    updated_at = now()
where codigo_barras = '7501342804408'
  and coalesce(nullif(imagen_url, ''), '') = '';

commit;

select sku, left(nombre, 40) as nombre, codigo_barras, imagen_url
from public.productos
where codigo_barras in (
  '7502227876428','7502009746321','7502009747274','7501842951657',
  '7506022315038','7506281106019','7501349020122','7501258203593',
  '7502009742798','7503027446279','7501349014190','7501277071685',
  '7502211788690','7501563380415','7501342804408'
)
order by codigo_barras;
