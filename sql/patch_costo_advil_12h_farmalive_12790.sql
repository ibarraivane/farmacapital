-- Farmalive Club Iztapalapa 1 · TICKET DE VENTA No. 12790 · 15-sep-2026
-- Recibir guardó el IMPORTE del pack «Compra 3 a Precio Especial» como
-- costo de UNA caja. Solo PR346 y PR347 (Advil). El resto del ticket
-- ya traía qty real o es empaque de fábrica (Aspirina 3PACK, Kleenex C/8).
--
-- PR346 Advil 12H 600 mg C/6 · FC-65065322 · EAN 7501065065322
--   qty impresa 1 · lista $227.00 · 2% · neto $222.46 → 3 × $74.15
--   Calle C/6 $83–$104. PVP $89 no se toca.
--
-- PR347 Advil 200 mg cápsulas · FC-08763468 · EAN 7501108763468
--   qty impresa 1 · lista $141.00 · 2% · neto $138.18 → 3 × $46.06
--   Ticket: C/10 Compra 3. Calle C/10 $56–$81. $138 no es de UNA caja.
--   El alta lo nombró C/20 (ese EAN es C/20). El costo sí se parte:
--   compraron 3 cajas. PVP $116 no se toca.
--
-- NO partir:
--   Advil 200 mg TAB C/12 EAN 7501065013767 · 1 × $42.14 (sin «Compra 3»)
--   Aspirina C/40 3PACK EAN 7501008499429 · 1 × $115.15 (empaque Bayer,
--     calle $135–$177 el pack; PVP $165)
--
-- Cafiaspirina C/100 FC-08491096 · Farmalive 9861 / FL-080826:
--   ticket «C/100 2 PACK» $217.46. Se abrió (stock 2) y el costo se
--   quedó en el pack. Unitario = 217.46 / 2 = $108.73.
--   Sep-3 dejó esto pendiente. PVP no se toca.
--
-- No inventa stock ni MMAA.
-- Idempotente: solo pisa si el costo sigue en el valor malo.
-- Folio vivo 12790 o 127790. Supabase → SQL Editor → Run.

begin;

-- ── Advil 12H C/6 · pack $222.46 / 3 ────────────────────────────────

update public.productos
   set costo = 74.15
 where sku = 'FC-65065322'
   and activo = true
   and costo >= 222.00
   and costo <= 223.00;

update public.lotes
   set costo_unitario = 74.15
 where producto_id = (select id from public.productos where sku = 'FC-65065322' limit 1)
   and costo_unitario >= 222.00
   and costo_unitario <= 223.00;

update public.recepcion_items i
   set costo_estimado = 74.15
  from public.recepciones r
 where i.recepcion_id = r.id
   and coalesce(r.proveedor, '') ilike '%farmalive%'
   and r.folio in ('12790', '127790')
   and (
     regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501065065322'
     or i.producto_id = (select id from public.productos where sku = 'FC-65065322' limit 1)
   )
   and i.costo_estimado >= 222.00
   and i.costo_estimado <= 223.00;

update public.recepcion_items i
   set cantidad = 3
  from public.recepciones r
 where i.recepcion_id = r.id
   and coalesce(r.proveedor, '') ilike '%farmalive%'
   and r.folio in ('12790', '127790')
   and r.estado = 'borrador'
   and (
     regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501065065322'
     or i.producto_id = (select id from public.productos where sku = 'FC-65065322' limit 1)
   )
   and i.cantidad = 1;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', 74.15, date '2026-09-15', 'Farmalive', 100, 'manual',
       'Farmalive 12790 · PR346 Compra 3 a Precio Especial · pack $222.46 / 3 = $74.15'
  from public.productos p
 where p.sku = 'FC-65065322'
   and p.activo = true
   and abs(p.costo - 74.15) <= 0.02;

-- ── Advil 200 mg cápsulas · pack $138.18 / 3 ─────────────────────────

update public.productos
   set costo = 46.06
 where sku = 'FC-08763468'
   and activo = true
   and costo >= 137.50
   and costo <= 139.00;

update public.lotes
   set costo_unitario = 46.06
 where producto_id = (select id from public.productos where sku = 'FC-08763468' limit 1)
   and costo_unitario >= 137.50
   and costo_unitario <= 139.00;

update public.recepcion_items i
   set costo_estimado = 46.06
  from public.recepciones r
 where i.recepcion_id = r.id
   and coalesce(r.proveedor, '') ilike '%farmalive%'
   and r.folio in ('12790', '127790')
   and (
     regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501108763468'
     or i.producto_id = (select id from public.productos where sku = 'FC-08763468' limit 1)
   )
   and i.costo_estimado >= 137.50
   and i.costo_estimado <= 139.00;

update public.recepcion_items i
   set cantidad = 3
  from public.recepciones r
 where i.recepcion_id = r.id
   and coalesce(r.proveedor, '') ilike '%farmalive%'
   and r.folio in ('12790', '127790')
   and r.estado = 'borrador'
   and (
     regexp_replace(coalesce(i.codigo_escaneado, ''), '\D', '', 'g') = '7501108763468'
     or i.producto_id = (select id from public.productos where sku = 'FC-08763468' limit 1)
   )
   and i.cantidad = 1;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', 46.06, date '2026-09-15', 'Farmalive', 100, 'manual',
       'Farmalive 12790 · PR347 Compra 3 a Precio Especial · pack $138.18 / 3 = $46.06'
  from public.productos p
 where p.sku = 'FC-08763468'
   and p.activo = true
   and abs(p.costo - 46.06) <= 0.02;

-- ── Cafiaspirina C/100 · 2-pack $217.46 / 2 (ticket 9861 / FL-080826)

update public.productos
   set costo = 108.73
 where sku = 'FC-08491096'
   and activo = true
   and costo >= 217.00
   and costo <= 218.00;

update public.lotes
   set costo_unitario = 108.73
 where producto_id = (select id from public.productos where sku = 'FC-08491096' limit 1)
   and costo_unitario >= 217.00
   and costo_unitario <= 218.00;

insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, notas
)
select p.id, 'ultima_compra', 'compra', 108.73, date '2026-08-08', 'Farmalive', 100, 'manual',
       'Farmalive 9861 / FL-080826 · C/100 2 PACK $217.46 / 2 = $108.73'
  from public.productos p
 where p.sku = 'FC-08491096'
   and p.activo = true
   and abs(p.costo - 108.73) <= 0.02;

commit;

select sku, left(nombre, 48) as nombre, costo, precio, stock,
       round((precio - costo) / nullif(precio, 0) * 100, 1) as margen_pct
  from public.productos
 where sku in ('FC-65065322', 'FC-08763468', 'FC-08491096', 'FC-65013767')
 order by sku;
