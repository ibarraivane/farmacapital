-- Borrar producto de prueba FC-TEST-1 (id 936 si no cambió)

delete from public.movimientos_inventario
where producto_id in (select id from public.productos where sku = 'FC-TEST-1');

delete from public.lotes
where producto_id in (select id from public.productos where sku = 'FC-TEST-1');

delete from public.productos where sku = 'FC-TEST-1';
