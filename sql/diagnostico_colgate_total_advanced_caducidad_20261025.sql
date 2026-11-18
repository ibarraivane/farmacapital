-- Diagnóstico: Colgate Total Advanced Clean 75 ml · caducidad sospechosa
-- EAN 7509546052632 · SKU FC-46052632 · producto_id 20250
-- Recibido Bodega F-42 folio 28130 (24-oct-2026). Ticket: …75ML OCT26
-- Solo lectura. Pegar en Supabase → SQL Editor → Run.

-- 1) Ficha
select
  p.id,
  p.sku,
  p.nombre,
  p.codigo_barras as ean,
  p.stock,
  p.costo,
  p.precio,
  p.created_at,
  p.updated_at,
  p.descripcion
from public.productos p
where p.id = 20250
   or p.sku = 'FC-46052632'
   or p.codigo_barras = '7509546052632';

-- 2) Lotes vivos (hoy: lote 3056 · RX-28130-5942 · caduca 2026-10-31 · 3 pza)
select
  l.id as lote_id,
  l.numero_lote,
  l.fecha_caducidad,
  l.cantidad_actual,
  l.costo_unitario,
  l.activo,
  l.created_at,
  (l.fecha_caducidad - current_date) as dias_restantes
from public.lotes l
where l.producto_id = 20250
order by l.id;

-- 3) Renglón en la recepción Bodega F-42 / 28130
select
  r.id as recepcion_id,
  r.folio,
  r.proveedor,
  r.estado,
  r.fecha_documento,
  r.created_at as recepcion_creada,
  i.id as item_id,
  i.codigo_escaneado,
  left(i.nombre_snapshot, 64) as snap,
  i.cantidad,
  i.confirmado,
  i.fecha_caducidad as caducidad_item,
  i.numero_lote,
  i.lote_id,
  i.costo_estimado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where (
    i.producto_id = 20250
    or i.codigo_escaneado = '7509546052632'
    or i.nombre_snapshot ilike '%COLGATE%TA+C%'
    or i.nombre_snapshot ilike '%7509546052632%'
  )
  and (
    r.folio::text ilike '%28130%'
    or coalesce(r.proveedor, '') ilike '%bodega%f-42%'
    or coalesce(r.proveedor, '') ilike '%bodega%f42%'
  )
order by i.id;

-- 4) Comparar otras pastas del mismo ticket 28130 (misma pistola)
select
  i.id as item_id,
  i.codigo_escaneado,
  left(coalesce(p.nombre, i.nombre_snapshot), 48) as nombre,
  i.cantidad,
  i.fecha_caducidad,
  i.numero_lote,
  i.lote_id,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio::text ilike '%28130%'
  and (
    i.nombre_snapshot ilike '%COLGATE%'
    or i.nombre_snapshot ilike '%ORAL-B%'
    or i.nombre_snapshot ilike '%SENSODYNE%'
    or coalesce(p.forma_farmaceutica, '') ilike '%Crema dental%'
  )
order by i.id;
