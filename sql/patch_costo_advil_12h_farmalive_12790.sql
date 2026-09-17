-- Advil 12 horas 600 mg C/6 · FC-65065322 · EAN 7501065065322
-- Farmalive Club Iztapalapa 1 · TICKET DE VENTA No. 12790 · 15-sep-2026
--
-- El ticket imprimió PR346 «Advil 12 Horas 600 Mg C/6 Compra 3 a Precio Especial»:
--   qty impresa = 1 (SKU promo) · lista $227.00 · desc 2% · neto $222.46 el pack.
-- 3 cajas físicas. Unitario = 222.46 / 3 = $74.15
-- Calle C/6: Fahorro $83.30–$98 · HEB $97 · Fleming $94. $222.46 no es de UNA caja.
-- Recibir guardó el importe del pack como costo de una. Por eso margen −60%.
--
-- No toca PVP $89. No inventa stock ni MMAA.
-- Idempotente: solo pisa si el costo sigue en ~$222.46.
-- Folio vivo puede ser 12790 o 127790. Supabase → SQL Editor → Run.

begin;

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

-- Renglón del ticket: el costo estimado era el pack, no la caja.
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

-- Si el ticket sigue en borrador, Recibir espera 3 cajas (no 1 pack).
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

commit;

select sku, left(nombre, 48) as nombre, costo, precio, stock,
       round((precio - costo) / nullif(precio, 0) * 100, 1) as margen_pct
  from public.productos
 where sku = 'FC-65065322';

-- PR347 del mismo ticket («Advil 200 Mg Caps Compra 3 a Precio Especial»
-- lista $141.00 · 2% · neto $138.18 · qty impresa 1) NO se parte aquí:
-- el alta lo dejó como C/20 (EAN 7501108763468). Confirmar cajas antes de /3.
