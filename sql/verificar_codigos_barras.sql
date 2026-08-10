-- Verificación códigos de barras para pistola POS
-- Ejecutar después de carga + actualizar_codigos_barras_tickets.sql

-- Totales
select
  count(*) filter (where sku like 'FC-%' and sku not like 'FC100%') as lineas_ticket,
  count(*) filter (
    where sku like 'FC-%' and sku not like 'FC100%'
      and codigo_barras is not null and btrim(codigo_barras) <> ''
  ) as con_barcode,
  count(*) filter (
    where sku like 'FC-%' and sku not like 'FC100%'
      and (codigo_barras is null or btrim(codigo_barras) = '')
  ) as sin_barcode
from public.productos;

-- Por ticket (descripción contiene "Ticket XXXXX")
select
  substring(p.descripcion from 'Ticket ([^ ]+)') as ticket,
  count(*) as productos,
  count(*) filter (where p.codigo_barras is not null and btrim(p.codigo_barras) <> '') as con_barcode
from public.productos p
where p.sku like 'FC-%' and p.sku not like 'FC100%'
group by 1
order by 1;

-- Productos sin barcode (escaneo manual pendiente) — primeros 30
select p.sku, p.nombre, p.descripcion
from public.productos p
where p.sku like 'FC-%' and p.sku not like 'FC100%'
  and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
order by p.descripcion
limit 30;

-- Barcodes duplicados (debe ser 0 filas)
select codigo_barras, count(*) as n
from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> ''
group by codigo_barras
having count(*) > 1;
