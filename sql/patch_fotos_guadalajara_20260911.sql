-- Farmacias Guadalajara 11-sep-2026 · fotos a catalogo-propia.
-- Correr DESPUÉS del deploy de Vercel (los JPG viven en public/catalogo-propia/).
-- SIN do $$. Pegar en Supabase → SQL Editor → Run.

begin;

update public.productos set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/lenzetto-1.53mg-6.5ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/lenzetto-1.53mg-6.5ml.jpg'
where codigo_barras = '7506352500128'
   or sku = 'FC-52500128';

update public.productos set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/wegovy-flextouch-1.7mg.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/wegovy-flextouch-1.7mg.jpg'
where codigo_barras = '7503007822970'
   or sku = 'FC-07822970';

commit;

select sku, codigo_barras as ean, left(nombre, 40) as nombre, left(imagen_url, 72) as foto
from public.productos
where codigo_barras in ('7506352500128', '7503007822970')
   or sku in ('FC-52500128', 'FC-07822970')
order by sku;
