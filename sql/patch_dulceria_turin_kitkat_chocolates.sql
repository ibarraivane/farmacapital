-- Turin y KitKat: que «chocolate» y «chocolates» los encuentren en POS y tienda.
-- El ticket T270040861 ya está cargado. Este archivo solo cambia nombre y categoría.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- No toca el borrador ni el stock.

begin;

update public.productos p
set
  nombre = t.nombre,
  categoria = t.categoria,
  subcategoria = t.subcategoria
from (
  values
  ('FC-LV-TURIN600'::text, 'Turin Conejo foco chocolate 600 g'::text, 'Chocolates'::text, 'Chocolates'::text),
  ('FC-LV-KITKAT22'::text, 'KitKat Extra Milk & Cocoa chocolate'::text, 'Chocolates'::text, 'Chocolates'::text)
) as t(sku, nombre, categoria, subcategoria)
where p.sku = t.sku;

select sku, nombre, categoria, subcategoria
from public.productos
where sku in ('FC-LV-TURIN600', 'FC-LV-KITKAT22')
order by sku;

commit;
