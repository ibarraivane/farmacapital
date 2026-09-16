-- Márgenes negativos: el catálogo guardó el IMPORTE del renglón
-- (qty × unitario) como si fuera el costo de UNA pieza.
-- No es precio de paquete. Ticket Exprezo 1279718 y Farmalive PACK C/8.
--
-- Catálogo vivo 15-sep-2026: 13 SKUs con precio < costo. De esos:
--   10 = importe de N piezas (o el importe de OTRO renglón del mismo ticket)
--   1  = Kleenex: Farmalive cobró el C/8; el EAN es el sellapack de 15
--   1  = Oxatech: el costo $26.46 SÍ es de una; el PVP $8.27 es de Erispan
--   1  = Just For Men: sin ticket; $171 está en rango de 1 kit — no se parte
--
-- Idempotente. Solo pisa si el costo (o el PVP de Oxatech) sigue en el valor malo.
-- Supabase → SQL Editor → Run.

begin;

-- ── Exprezo 1279718: unitario = precio_unitario del ticket ──────────────

-- Dove blanco 90 g · 6 × $18.63 = $111.80
update public.productos
   set costo = 18.63
 where sku = 'FC-06246652'
   and activo = true
   and costo >= 111.50
   and costo <= 112.10;
update public.lotes
   set costo_unitario = 18.63
 where producto_id = (select id from public.productos where sku = 'FC-06246652' limit 1)
   and costo_unitario >= 111.50
   and costo_unitario <= 112.10;

-- Gerber Etapa 2 frutas 100 g · 3 × $10.68 = $32.04
update public.productos
   set costo = 10.68
 where sku in ('FC-75102421', 'FC-75102452', 'FC-75102469', 'FC-75102476')
   and activo = true
   and costo >= 31.80
   and costo <= 32.30;
update public.lotes
   set costo_unitario = 10.68
 where producto_id in (
         select id from public.productos
          where sku in ('FC-75102421', 'FC-75102452', 'FC-75102469', 'FC-75102476')
       )
   and costo_unitario >= 31.80
   and costo_unitario <= 32.30;

-- Gerber Etapa 2 comida casera · 4 × $10.68 = $42.72
update public.productos
   set costo = 10.68
 where sku in ('FC-75102520', 'FC-75102537')
   and activo = true
   and costo >= 42.40
   and costo <= 43.00;
update public.lotes
   set costo_unitario = 10.68
 where producto_id in (
         select id from public.productos
          where sku in ('FC-75102520', 'FC-75102537')
       )
   and costo_unitario >= 42.40
   and costo_unitario <= 43.00;

-- Gerber Junior pouch frutas mixtas 95 g · 3 × $12.79 = $38.38
update public.productos
   set costo = 12.79
 where sku = 'FC-58651129'
   and activo = true
   and costo >= 38.10
   and costo <= 38.60;
update public.lotes
   set costo_unitario = 12.79
 where producto_id = (select id from public.productos where sku = 'FC-58651129' limit 1)
   and costo_unitario >= 38.10
   and costo_unitario <= 38.60;

-- Heinz pouch manzana 113 g · unitario $14.40 (3 pzas = $43.19).
-- El $32.04 del catálogo es el importe de Gerber Etapa 2, no de Heinz.
update public.productos
   set costo = 14.40
 where sku = 'FC-75005092'
   and activo = true
   and costo >= 31.80
   and costo <= 32.30;
update public.lotes
   set costo_unitario = 14.40
 where producto_id = (select id from public.productos where sku = 'FC-75005092' limit 1)
   and costo_unitario >= 31.80
   and costo_unitario <= 32.30;

-- Enfagrow Premium etapa 3 800 g · 1 × $306.00.
-- El $568.96 del catálogo es el importe de Flanax 3 × $189.65 del mismo ticket.
update public.productos
   set costo = 306.00
 where sku = 'FC-05809248'
   and activo = true
   and costo >= 568.50
   and costo <= 569.50;
update public.lotes
   set costo_unitario = 306.00
 where producto_id = (select id from public.productos where sku = 'FC-05809248' limit 1)
   and costo_unitario >= 568.50
   and costo_unitario <= 569.50;

-- Kleenex Sellapack 15 pañuelos · EAN 7501017362998.
-- Farmalive cobró PACK C/8: $32.83 (folio 97) / $32.63 (folio 9861).
-- El EAN es de UNA pieza. Unitario = 32.83 / 8 = $4.10.
update public.productos
   set costo = 4.10
 where sku = 'FC-73629981'
   and activo = true
   and costo >= 32.50
   and costo <= 33.20;
update public.lotes
   set costo_unitario = 4.10
 where producto_id = (select id from public.productos where sku = 'FC-73629981' limit 1)
   and costo_unitario >= 32.50
   and costo_unitario <= 33.20;

-- Oxatech 14 tab 10 mg · Equilibrio 440393: 1 × $26.46. El costo está bien.
-- El PVP $8.27 es el unitario de Erispan Comp 10 tab (mismo ticket, 3 pzas).
-- Recargo alta genérico 60% → ceil(26.46 × 1.6) = $43.
update public.productos
   set precio = 43
 where sku = 'EQ-MAV198'
   and activo = true
   and costo between 26.00 and 27.00
   and precio <= 9;

-- ── última compra: insertar el unitario (la vista toma la fecha más nueva)

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', v.unit, date '2026-09-15', v.quien, 100, 'manual', v.nota
from public.productos p
join (
  values
    ('FC-06246652', 18.63::numeric, 'Exprezo', 'Exprezo 1279718 · 6 pzas · unitario no el importe $111.80'),
    ('FC-75102421', 10.68, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario no el importe $32.04'),
    ('FC-75102452', 10.68, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario no el importe $32.04'),
    ('FC-75102469', 10.68, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario no el importe $32.04'),
    ('FC-75102476', 10.68, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario no el importe $32.04'),
    ('FC-75102520', 10.68, 'Exprezo', 'Exprezo 1279718 · 4 pzas · unitario no el importe $42.72'),
    ('FC-75102537', 10.68, 'Exprezo', 'Exprezo 1279718 · 4 pzas · unitario no el importe $42.72'),
    ('FC-58651129', 12.79, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario no el importe $38.38'),
    ('FC-75005092', 14.40, 'Exprezo', 'Exprezo 1279718 · 3 pzas · unitario $14.40 (el $32.04 era Gerber)'),
    ('FC-05809248', 306.00, 'Exprezo', 'Exprezo 1279718 · 1 pza $306 (el $568.96 era Flanax 3×)'),
    ('FC-73629981', 4.10, 'Farmalive', 'Farmalive PACK C/8 $32.83 · EAN sellapack · 32.83/8')
) as v(sku, unit, quien, nota)
  on p.sku = v.sku
where p.activo = true
  and abs(p.costo - v.unit) <= 0.02;

commit;

-- Just For Men FC-08011145: costo $171.14 / PVP $165 / stock 2. Sin ticket.
-- Calle $192–$302 el kit. No se parte a $85.57. Queda para confirmar compra.

select sku, left(nombre, 48) as nombre, costo, precio, stock,
       round((precio - costo) / nullif(precio, 0) * 100, 1) as margen_pct
from public.productos
where sku in (
  'FC-06246652', 'FC-75102421', 'FC-75102452', 'FC-75102469', 'FC-75102476',
  'FC-75102520', 'FC-75102537', 'FC-58651129', 'FC-75005092', 'FC-05809248',
  'FC-73629981', 'EQ-MAV198', 'FC-08011145'
)
order by sku;
