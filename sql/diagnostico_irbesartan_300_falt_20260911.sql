-- Diagnóstico: ¿se vendieron las 3 cajas de Irbesartán 300 mg 28 tab LGEN?
-- Contexto: folio Nadro 1658128647824-01-FALT · renglón gris (falta caducidad).
-- SKU FC-42700629 · EAN 7506442700629
-- Solo lectura. Pegar en Supabase → SQL Editor → Run.

-- 1) Ficha + stock actual + lotes
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras as ean,
  p.stock as stock_catalogo,
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as stock_lotes
from public.productos p
where p.sku = 'FC-42700629'
   or p.codigo_barras = '7506442700629'
   or (
     p.nombre ilike '%irbesart%'
     and p.nombre ilike '%300%'
     and (p.nombre ilike '%28%' or p.presentacion ilike '%28%')
   )
order by p.sku;

-- 2) Lotes vivos de esas fichas
select
  p.sku,
  left(p.nombre, 48) as nombre,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  l.cantidad_inicial,
  l.activo,
  l.created_at
from public.lotes l
join public.productos p on p.id = l.producto_id
where p.sku = 'FC-42700629'
   or p.codigo_barras = '7506442700629'
   or (
     p.nombre ilike '%irbesart%'
     and p.nombre ilike '%300%'
   )
order by l.created_at desc;

-- 3) Ventas (pedido_items) de Irbesartán 300 — todas
select
  ped.id as pedido_id,
  ped.created_at as fecha_venta,
  ped.folio as folio_venta,
  ped.estado,
  ped.total,
  p.sku,
  left(p.nombre, 48) as producto,
  i.cantidad,
  i.precio_unitario,
  i.lote_id
from public.pedido_items i
join public.pedidos ped on ped.id = i.pedido_id
join public.productos p on p.id = i.producto_id
where (
    p.sku = 'FC-42700629'
    or p.codigo_barras = '7506442700629'
    or (
      p.nombre ilike '%irbesart%'
      and p.nombre ilike '%300%'
    )
  )
  and coalesce(ped.estado::text, '') not in ('cancelado', 'anulado')
order by ped.created_at desc
limit 50;

-- 4) Estado del renglón en el FALT (¿ya entró stock o sigue pendiente?)
select
  r.folio,
  r.estado as estado_recepcion,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  i.cantidad,
  i.confirmado,
  i.pendiente_alta,
  i.fecha_caducidad,
  i.numero_lote,
  i.producto_id
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio in ('1658128647824-01-FALT', '1658128647824-01')
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and (
    i.codigo_escaneado = '7506442700629'
    or i.nombre_snapshot ilike '%IRBESARTAN 300%'
    or i.nombre_snapshot ilike '%Irbesartán 300%'
  )
order by r.folio, i.id;

-- 5) Movimientos de inventario del SKU (entradas/salidas)
select
  m.created_at,
  m.tipo,
  m.cantidad,
  left(m.motivo, 80) as motivo,
  p.sku
from public.movimientos_inventario m
join public.productos p on p.id = m.producto_id
where p.sku = 'FC-42700629'
   or p.codigo_barras = '7506442700629'
order by m.created_at desc
limit 40;
