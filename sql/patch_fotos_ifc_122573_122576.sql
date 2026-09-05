-- Farma Centre IFC · pasar fotos a catalogo-propia (DESPUÉS del deploy Vercel).
-- Antes: URLs Mayfar/Kohn en patch_carga_ifc_122573_122576.sql.
-- SIN do $$. Pegar en Supabase → SQL Editor → Run.

begin;

update public.productos set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/reomatolum-del-viejito-60g.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/reomatolum-del-viejito-60g.jpg'
where sku = 'FC-1FBF5206' or codigo_barras = '7503002045008';

update public.productos set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/kohn-lavaojos-plastico.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/kohn-lavaojos-plastico.jpg'
where sku = 'FC-46604917' or codigo_barras = '7506346604917';

update public.productos set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg'
where sku = 'FC-MER-MANZANA';

commit;

select sku, left(nombre, 36) as nombre, left(imagen_url, 72) as foto
from public.productos
where sku in ('FC-1FBF5206', 'FC-46604917', 'FC-MER-MANZANA')
   or codigo_barras in ('7503002045008', '7506346604917')
order by sku;
