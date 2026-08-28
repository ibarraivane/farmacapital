-- ============================================================================
-- FARMA CAPITAL — Ibupro-Cafe EAN 7501478316813  17-ago-2026
--
-- Ya existía FC-3D0F54B7 (ticket VIT068, 10 cap 400/100, $30.06 / $41,
-- stock 2, cad. 2028-03-30). Sin código de barras. No se crea otro SKU.
--
-- Pega el EAN de la foto 0050, llena PA / unidades / caducidad si están
-- vacíos, y deja el nombre buscable. No pisa costo, precio ni stock.
-- ============================================================================

update public.productos set
  codigo_barras = case
    when coalesce(codigo_barras, '') = '' then '7501478316813'
    else codigo_barras
  end,
  principio_activo = coalesce(nullif(principio_activo, ''), 'Ibuprofeno / Cafeína'),
  denominacion_generica = coalesce(nullif(denominacion_generica, ''), 'Ibuprofeno / Cafeína'),
  unidades_por_caja = case
    when unidades_por_caja is null or unidades_por_caja = 0 then 10
    else unidades_por_caja
  end,
  fecha_caducidad = coalesce(fecha_caducidad, '2028-03-30'::date),
  lote = coalesce(nullif(lote, ''), 'M26052'),
  nombre = case
    when nombre = 'Ibupro-Cafe' then 'Ibupro-Cafe ibuprofeno/cafeína 400/100 C/10'
    else nombre
  end,
  activo = true
where sku = 'FC-3D0F54B7'
  and not exists (
    select 1 from public.productos o
    where o.codigo_barras = '7501478316813' and o.sku <> 'FC-3D0F54B7'
  );

select sku, nombre, codigo_barras, presentacion, concentracion,
       costo, precio, stock, lote, fecha_caducidad
from public.productos
where sku = 'FC-3D0F54B7'
   or codigo_barras = '7501478316813';
