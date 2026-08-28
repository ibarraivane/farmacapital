-- ============================================================================
-- ¿Existe el floroglucinol y en qué estado? Sin efectos secundarios.
-- ============================================================================

-- 1) Por código de barras y por nombre, sin filtrar por activo
select
  id, sku, nombre, codigo_barras, costo, precio, stock, activo
from public.productos
where codigo_barras = '7501471800210'
   or nombre ilike '%floroglu%'
   or descripcion ilike '%floroglu%';

-- 2) Cuántos productos hay en total y cuántos están apagados
select
  count(*)                                   as productos_totales,
  count(*) filter (where activo)             as activos,
  count(*) filter (where not activo)         as inactivos,
  count(*) filter (where codigo_barras is null) as sin_codigo_de_barras
from public.productos;

-- 3) Cuánto del lote 4 llegó realmente al inventario
select
  count(*)                              as renglones_del_lote4,
  count(p.id)                           as encontrados_en_productos,
  count(*) filter (where p.id is null)  as faltantes,
  count(*) filter (where p.activo)      as activos,
  count(*) filter (where not p.activo)  as apagados
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean;

-- 4) Si en el punto 3 salen faltantes, aquí están cuáles
select c.ean, c.nombre, c.costo
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean
where p.id is null
order by c.nombre;
