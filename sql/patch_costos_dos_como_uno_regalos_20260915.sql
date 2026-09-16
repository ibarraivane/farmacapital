-- Costo de UNA pieza.
-- Bodega F-42 a veces guarda el importe de 2 en "precio_unitario"
-- (Sedal: 2 × $9.08 → CSV $18.17). Speed Stick se quedó con el de dos.
-- Pert kera no venía en ese ticket: le pegaron el $14.80 del oliva
-- (2 pzas). El oliva ya está en $7.40.
--
-- Mercurio óxido de zinc C/50: se compró la CAJA ($54) y se vende
-- por pieza. 54 / 50 = $1.08. No se inventa caducidad.
--
-- Metamucil y Pharmaton: regalos en paquetes que ya van a caducar.
-- Costo $0. No se inventa caducidad.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

-- Pert kera + aguacate 100 ml · le pegaron el importe de 2 del oliva
update public.productos
   set costo = 7.40
 where sku = 'FC-20500164'
   and activo = true
   and costo >= 14.60
   and costo <= 15.00;
update public.lotes
   set costo_unitario = 7.40
 where producto_id = (select id from public.productos where sku = 'FC-20500164' limit 1)
   and costo_unitario >= 14.60
   and costo_unitario <= 15.00;

-- Speed Stick sensitive protect · Bodega qty 2, CSV $29.91 (importe)
-- Unitario $14.95. El PVP $63 no se toca.
update public.productos
   set costo = 14.95
 where sku = 'FC-46682815'
   and activo = true
   and costo >= 29.70
   and costo <= 30.20;
update public.lotes
   set costo_unitario = 14.95
 where producto_id = (select id from public.productos where sku = 'FC-46682815' limit 1)
   and costo_unitario >= 29.70
   and costo_unitario <= 30.20;

-- Mercurio óxido de zinc C/50 · caja $54, se vende por pieza
-- El $9 era el unitario de la pomada C/25 pegado a este SKU.
update public.productos
   set
     costo = 1.08,
     presentacion = 'pieza (caja C/50)'
 where sku = 'FC-C4530823'
   and activo = true
   and costo >= 8.50
   and costo <= 55.00;
update public.lotes
   set costo_unitario = 1.08
 where producto_id = (select id from public.productos where sku = 'FC-C4530823' limit 1)
   and costo_unitario >= 8.50
   and costo_unitario <= 55.00;

-- Metamucil 504 g · regalo por caducar. El $0.01 era placeholder.
update public.productos
   set
     costo = 0,
     descripcion = trim(both from coalesce(descripcion, '') ||
       case
         when coalesce(descripcion, '') ilike '%regalo%caduc%' then ''
         else ' · regalo en paquete por caducar · costo 0'
       end)
 where sku = 'EQ-PYG016'
   and activo = true
   and costo > 0
   and costo <= 0.05;
update public.lotes
   set costo_unitario = 0
 where producto_id = (select id from public.productos where sku = 'EQ-PYG016' limit 1)
   and costo_unitario > 0
   and costo_unitario <= 0.05;

-- Pharmaton C/100 · Farmalive 97 a $0.01 porque venía de regalo.
update public.productos
   set
     costo = 0,
     descripcion = trim(both from coalesce(descripcion, '') ||
       case
         when coalesce(descripcion, '') ilike '%regalo%caduc%' then ''
         else ' · regalo en paquete por caducar · costo 0'
       end)
 where sku = 'FC-98062243'
   and activo = true
   and costo >= 0
   and costo <= 0.05;
update public.lotes
   set costo_unitario = 0
 where producto_id = (select id from public.productos where sku = 'FC-98062243' limit 1)
   and costo_unitario > 0
   and costo_unitario <= 0.05;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', v.unit, date '2026-09-15', v.quien, 100, 'manual', v.nota
from public.productos p
join (
  values
    ('FC-20500164', 7.40::numeric, 'Bodega', 'Pert oliva 2 pzas importe $14.80 · unitario $7.40 (misma presentación)'),
    ('FC-46682815', 14.95, 'Bodega', 'Bodega F-42 · 2 pzas importe $29.91 · unitario $14.95'),
    ('FC-C4530823', 1.08, 'IFC', 'Caja C/50 $54 · se vende por pieza · 54/50 = $1.08'),
    ('EQ-PYG016', 0, 'regalo', 'Regalo en paquete por caducar · costo 0'),
    ('FC-98062243', 0, 'regalo', 'Regalo en paquete por caducar · costo 0')
) as v(sku, unit, quien, nota)
  on p.sku = v.sku
where p.activo = true
  and abs(coalesce(p.costo, 0) - v.unit) <= 0.02;

commit;

select sku, left(nombre, 48) as nombre, presentacion, costo, precio, stock
from public.productos
where sku in (
  'FC-20500164', 'FC-20500171', 'FC-46682815',
  'FC-C4530823', 'FC-0ACC5B6A',
  'EQ-PYG016', 'FC-98062243'
)
order by sku;
