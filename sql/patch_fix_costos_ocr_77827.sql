-- ============================================================
-- Corrige costos OCR erróneos del ticket 77827 (Bodega F-42)
--
-- El parser asignó $405.32 (= fragmento del TOTAL $8,405.32) a:
--   FC-48690909  Tensolastic 7 cm × 5 m  → ticket: $21.14
--   FC-40171550  Sensodyne Rápido Alivio  → ticket: $106.44
--
-- Ejecutar en Supabase SQL Editor.
-- ============================================================

begin;

-- Tensolastic Plus 7 cm × 5 m (barcode 7501048690909)
update public.productos
set
  costo = 21.14,
  precio = 32.00
where sku = 'FC-48690909';

update public.lotes
set costo_unitario = 21.14
where producto_id = (select id from public.productos where sku = 'FC-48690909' limit 1)
  and numero_lote = 'TK-77827-184';

-- Sensodyne Rápido Alivio 100 g (barcode 7794640171550)
update public.productos
set
  costo = 106.44,
  precio = 149.00
where sku = 'FC-40171550';

update public.lotes
set costo_unitario = 106.44
where producto_id = (select id from public.productos where sku = 'FC-40171550' limit 1)
  and numero_lote = 'TK-77827-183';

commit;

-- Verificación
select sku, left(nombre, 45) as nombre, costo, precio,
       round((precio - costo) / nullif(costo, 0) * 100, 1) as margen_pct
from public.productos
where sku in ('FC-48690909', 'FC-40171550', 'FC-48690800', 'FC-48691005', 'FC-48691104')
order by sku;
