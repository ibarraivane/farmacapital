-- Fotos catalogo-propia · corrida DESPUÉS del deploy de Vercel.
-- Archivos en public/catalogo-propia/ (rama cursor/foto-productos-nadro-no-estan-c7d2).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/carticap-for-60-caps.jpg'
where (codigo_barras = '7502227426067' or sku = 'FC-27426067')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/carticap-for-60-caps%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/oral-b-gingivitis-350-ml.jpg'
where (codigo_barras = '7501086453221' or sku = 'FC-08645322')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/oral-b-gingivitis-350-ml%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/estomaquil-exper3-240.jpg'
where (codigo_barras = '7501369200108' or sku = 'FC-69200108')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/estomaquil-exper3-240%'
  );

update public.productos
set imagen_url = 'https://www.farmacapital.mx/catalogo-propia/neo-melubrina-infantil-100ml.jpg'
where (codigo_barras in ('7501165000315', '75011650003151') or sku = 'FC-50003151')
  and (
    imagen_url is null
    or btrim(imagen_url) = ''
    or imagen_url not like '%catalogo-propia/neo-melubrina-infantil%'
  );

commit;

select sku, codigo_barras, nombre, left(coalesce(imagen_url, ''), 90) as imagen
from public.productos
where codigo_barras in (
  '7502227426067', '7501086453221', '7501369200108', '7501165000315'
)
   or sku in ('FC-27426067', 'FC-08645322', 'FC-69200108', 'FC-50003151')
order by nombre;
