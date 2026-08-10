-- PASO FINAL 4/4 — Verificación (debe cuadrar)

select count(*) as productos_ticket
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select sum(cantidad_actual) as stock_lotes from public.lotes;

select count(*) filter (where codigo_barras is not null and btrim(codigo_barras) <> '') as con_barcode
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';
