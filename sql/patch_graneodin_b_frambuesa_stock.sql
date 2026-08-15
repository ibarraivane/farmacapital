-- Graneodin B Frambuesa: corregir barcode y stock (2 cajas fisicas)
-- Antes: FC-58715517 barcode 7501058715517 stock 5 (otro EAN / ticket FL-080826)
-- Ahora: barcode 7501095409004 stock 2

UPDATE public.productos
SET
  codigo_barras = '7501095409004',
  nombre = 'Graneodin B Frambuesa (benzocaina)',
  presentacion = 'C/24 pastillas sabor frambuesa',
  stock = 2,
  stock_unidades = 2,
  descripcion = 'Graneodin B Frambuesa C/24 - barcode 7501095409004. Stock corregido a conteo fisico (2 cajas).'
WHERE sku = 'FC-58715517';

SELECT sku, nombre, codigo_barras, stock, costo, precio
FROM public.productos
WHERE sku = 'FC-58715517';
