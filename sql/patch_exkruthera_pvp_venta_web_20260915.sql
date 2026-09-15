-- Exkruthera Fruquintinib 1 mg · PVP mostrador/web y ficha limpia.
-- El alta dejó costo/PVP en 0.01 (placeholder). En tienda ya se ve $22,700.
-- Receta se mantiene (se pide al entregar). No es controlado.
-- Ejecutar en Supabase → SQL Editor → Run.

begin;

update public.productos p
set
  precio = case
    when coalesce(p.precio, 0) <= 0.01 then 22700
    else p.precio
  end,
  descripcion = case
    when p.descripcion ilike 'Alta mostrador%'
      or p.descripcion ilike '%PVP 0.01%'
      or p.descripcion ilike '%por definir%'
    then null
    else p.descripcion
  end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true
where p.codigo_barras = '7501092723424'
   or p.sku = 'FC-09272342';

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.precio,
  p.costo,
  p.requiere_receta,
  p.controlado,
  p.visible_tienda,
  p.activo,
  p.stock,
  left(coalesce(p.descripcion, ''), 60) as descripcion
from public.productos p
where p.codigo_barras = '7501092723424'
   or p.sku = 'FC-09272342';
