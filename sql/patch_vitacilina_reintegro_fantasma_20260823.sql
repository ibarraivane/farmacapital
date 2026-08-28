-- Vitacilina 28 Crema (FC-03430721): el pedido en línea #58 nunca descontó lote
-- (lote_id null, sin movimiento de salida). Al cancelarlo se inventó
-- REINTEGRO-20260822-061030 (+1). El tubo real salió en el POS #62.
-- Quita el fantasma. Idempotente.

begin;

update public.lotes
   set cantidad_actual = 0,
       activo = false
 where id = 1523
   and producto_id = 593
   and numero_lote = 'REINTEGRO-20260822-061030';

update public.productos
   set stock = 0
 where id = 593
   and sku = 'FC-03430721';

commit;

select p.sku, p.nombre, p.stock,
       l.id, l.numero_lote, l.cantidad_actual, l.activo
  from public.productos p
  left join public.lotes l on l.producto_id = p.id
 where p.id = 593;
