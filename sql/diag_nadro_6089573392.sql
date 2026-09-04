-- SOLO DIAGNÓSTICO — no escribe nada.
-- Factura Nadro foto Folio 6089573392 (= ticket trabajo 20260901).
-- Pegar en Supabase → SQL Editor → Run y mirar el resultado.
--
-- Cómo leerlo:
--   0 filas en "pedido"     → FALTA cargar. Pega patch_carga_nadro_6089573392.sql
--   estado = borrador/parcial → YA está en Recibir, NO vuelvas a cargar.
--                               Solo falta pistola en los no confirmados.
--   estado = confirmado/cerrado y confirmados = renglones → YA recibida. No hagas nada.
--   estado cerrado pero confirmados < renglones → parcial; usa el faltante UVAIR si aplica.

-- 1) Pedido(s) Nadro de esta factura
select
  r.id,
  r.folio,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola,
  left(coalesce(r.notas, ''), 80) as notas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in (
    '6089573392', '6089573392-UVAIR',
    '20260901', '20260901-UVAIR'
  )
group by r.id, r.folio, r.estado, r.fecha, r.total_ticket, r.notas
order by r.id;

-- 2) Detalle de renglones (si hay pedido)
select
  r.folio,
  r.estado as estado_pedido,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.confirmado,
  i.pendiente_alta,
  i.fecha_caducidad,
  i.numero_lote
from public.recepciones r
join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in (
    '6089573392', '6089573392-UVAIR',
    '20260901', '20260901-UVAIR'
  )
order by r.folio, i.id;

-- 3) Anthelios (el que a veces quedó sin lote)
select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 56) as nombre,
  p.stock,
  (select coalesce(sum(l.cantidad_actual), 0)
     from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)) as piezas_lote
from public.productos p
where p.codigo_barras = '3337875917810'
   or p.sku in ('FC-75917810', 'FC-ND-75917810')
   or p.nombre ilike '%Anthelios UV Air%'
   or p.nombre ilike '%BLOQ ANTHE UVAIR%';
