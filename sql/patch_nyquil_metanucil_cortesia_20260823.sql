-- Equilibrio 440393: NyQuil Z y Metanucil vinieron de cortesía (gratis).
-- El OCR del ticket los dejó cobrados ($281.55 / $545.81). Corregido a costo 0.
-- No toca precio de venta ni caducidad.

begin;

update public.productos
   set costo = 0
 where sku in ('FC-5145497', 'EQ-PYG016');

update public.lotes l
   set costo_unitario = 0
 where l.producto_id in (
   select p.id from public.productos p
    where p.sku in ('FC-5145497', 'EQ-PYG016')
 );

commit;

select p.sku, p.nombre, p.costo, p.precio,
       l.numero_lote, l.costo_unitario, l.fecha_caducidad, l.cantidad_actual
  from public.productos p
  left join public.lotes l
    on l.producto_id = p.id
 where p.sku in ('FC-5145497', 'EQ-PYG016')
 order by p.sku, l.id;
