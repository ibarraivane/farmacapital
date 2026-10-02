-- Diagnóstico: Bepanthen Pomada Protectora con stock 30232 (fantasma).
-- SKU FC-08427330 · id 445 · EAN 7501008427347 (tubo 30 g).
-- Confirmado en prod 2-oct-2026: productos.stock = 30232 (único ≥1000).
-- Solo lectura. Pegar en Supabase → SQL Editor → Run.

-- 1) Ficha + stock catálogo vs suma de lotes
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras as ean,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock as stock_catalogo,
  p.stock_minimo,
  p.updated_at,
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
  ), 0) as stock_lotes_activos
from public.productos p
where p.sku = 'FC-08427330'
   or p.id = 445
   or p.codigo_barras in ('7501008427347', '7501008427330')
   or p.nombre ilike '%bepanthen%'
order by p.sku;

-- 2) Lotes (aquí debería aparecer la cantidad absurda)
select
  p.sku,
  left(p.nombre, 48) as nombre,
  l.id as lote_id,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_inicial,
  l.cantidad_actual,
  l.costo_unitario,
  l.activo,
  l.fecha_recepcion,
  l.created_at,
  l.updated_at
from public.lotes l
join public.productos p on p.id = l.producto_id
where p.sku = 'FC-08427330'
   or p.id = 445
   or p.codigo_barras in ('7501008427347', '7501008427330')
order by coalesce(l.cantidad_actual, 0) desc, l.id desc;

-- 3) Movimientos recientes (quién/qué infló el stock)
select
  m.id,
  m.created_at,
  m.tipo,
  m.cantidad,
  m.motivo,
  m.usuario_id
from public.movimientos_inventario m
where m.producto_id = 445
order by m.id desc
limit 50;

-- 4) Otros stocks altos (¿hay más fantasmas?)
select
  p.id,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras,
  p.stock,
  p.stock_minimo
from public.productos p
where coalesce(p.activo, true)
  and coalesce(p.stock, 0) >= 100
order by p.stock desc
limit 40;

-- 5) Recepción / ticket: ¿entró cantidad rara por pistola?
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.proveedor_nombre,
  r.created_at,
  i.id as item_id,
  i.codigo_escaneado,
  left(i.nombre_snapshot, 48) as snap,
  i.cantidad,
  i.confirmado,
  i.producto_id
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.producto_id = 445
   or i.codigo_escaneado in ('7501008427347', '7501008427330')
   or i.nombre_snapshot ilike '%bepanthen%pomada%rozadur%'
order by r.created_at desc, i.id
limit 50;
