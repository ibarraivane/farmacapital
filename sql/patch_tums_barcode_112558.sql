-- TUMS Extra surtido (ticket 112558 L27)
-- OCR leyó mal: ATUMS / TB 3 SURT / barcode 7501065054135
-- Barcode real del empaque: 7501065054043 (Sanborns, FaHorro, etc.)

update public.productos
set
  nombre = 'Tums Extra surtido 750 mg C/24 (3 rollos x 8)',
  marca = 'Tums',
  codigo_barras = '7501065054043',
  categoria = 'Gastro',
  forma_farmaceutica = 'Tableta masticable',
  presentacion = 'C/24',
  principio_activo = 'Carbonato de calcio',
  descripcion = 'Tums Extra surtido antiácido — ticket 112558'
where sku = 'FC-65054135'
   or codigo_barras in ('7501065054135', '7501065054043')
   or nombre ilike '%tubos surtidos%'
   or nombre ilike '%tb 3 surt%';

select sku, codigo_barras, nombre, marca, stock, costo, precio
from public.productos
where sku = 'FC-65054135' or codigo_barras = '7501065054043';
