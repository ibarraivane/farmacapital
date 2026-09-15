-- Exkruthera Fruquintinib 1 mg · PVP y ficha limpia.
-- En producción NO hay columna visible_tienda: no la uses.
-- Receta se mantiene (se pide al entregar).
-- Supabase → SQL Editor → Run.

begin;

update public.productos
set
  precio = case
    when coalesce(precio, 0) <= 0.01 then 22700
    else precio
  end,
  descripcion = null,
  requiere_receta = true,
  activo = true
where nombre ilike '%Exkruthera%'
   or codigo_barras = '7501092723424'
   or sku = 'FC-09272342';

commit;

select
  sku,
  codigo_barras as ean,
  nombre,
  precio,
  costo,
  requiere_receta,
  activo,
  stock,
  left(coalesce(descripcion, ''), 40) as descripcion
from public.productos
where nombre ilike '%Exkruthera%'
   or codigo_barras = '7501092723424'
   or sku = 'FC-09272342';
