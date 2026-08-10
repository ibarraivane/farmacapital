-- Diagnóstico rápido post-carga (comparar con objetivo ~612 productos, ~1031 pzas)

select count(*) as productos_ticket
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select count(*) as lotes from public.lotes;

select sum(cantidad_actual) as stock_lotes from public.lotes;

-- Objetivo con SQL actual: 612 lineas, 1031 piezas (15 lineas del Excel nunca se exportaron)
select 612 as lineas_sql_objetivo, 1031 as pzas_sql_objetivo, 1046 as pzas_excel_bruto;

-- Si stock_lotes ~940 → faltó _EJECUTAR_4 completo
-- Si stock_lotes ~972 → _EJECUTAR_4 parcial + posible timeout
-- Si productos_ticket ~612 y stock ~1031 → carga OK
