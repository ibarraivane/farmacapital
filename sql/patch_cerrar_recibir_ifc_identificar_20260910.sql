-- Quitar de Recibir: IFC (122573 / 122576) y el ticket «por identificar».
--
-- Motivo (mostrador, 10-sep-2026): el stock ya se consideró y la caducidad
-- se capturó a mano en Inventario. Si se escanean ahora, se DUPLICA stock.
--
-- Este patch NO llama receive_merchandise_lote ni toca lotes/productos.stock.
-- Solo cierra el encabezado (estado = confirmada) para que salgan de la cola.
-- Los renglones se quedan como están (gris / sin lote_id) a propósito:
-- si se marcaran verdes, el arreglo de «verde sin stock» volvería a sumar.
--
-- Idempotente. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Revisa las dos primeras consultas del resultado antes de fiarte:
--   1) cola viva
--   2) cruce ticket vs stock / caducidad de lotes

begin;

-- ── 1) Cola viva ahora ──────────────────────────────────────────
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.fecha,
  count(i.id) as renglones,
  count(*) filter (where i.confirmado) as verdes,
  count(*) filter (where not coalesce(i.confirmado, false)) as grises,
  count(*) filter (where i.lote_id is not null) as con_lote_recibir
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.id
order by r.updated_at desc;

-- ── 2) Cruce: IFC + por identificar vs inventario ───────────────
select
  r.proveedor,
  r.folio,
  i.codigo_escaneado as ean,
  left(coalesce(p.nombre, i.nombre_snapshot), 48) as producto,
  p.sku,
  i.cantidad as qty_ticket,
  i.confirmado as verde_recibir,
  i.lote_id as lote_recibir,
  i.fecha_caducidad as cad_recibir,
  coalesce(p.stock, 0) as stock_producto,
  coalesce((
    select sum(l.cantidad_actual)
    from public.lotes l
    where l.producto_id = p.id and coalesce(l.activo, true)
  ), 0) as suma_lotes,
  (
    select min(l.fecha_caducidad)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
      and l.fecha_caducidad is not null
  ) as cad_lote_vivo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    coalesce(r.proveedor, '') ilike '%ifc%'
    or r.folio in ('122573', '122576')
    or coalesce(r.proveedor, '') ilike '%identificar%'
    or coalesce(r.folio, '') ilike '%identificar%'
    or coalesce(r.notas, '') ilike '%identificar%'
  )
order by r.folio, i.id;

-- ── 3) Cerrar sin sumar stock ───────────────────────────────────
update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, now()),
  notas = trim(both from concat_ws(' · ',
    nullif(btrim(r.notas), ''),
    'Cerrado 2026-09-10: stock y caducidad ya estaban en Inventario; no se volvió a recibir'
  )),
  updated_at = now()
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    coalesce(r.proveedor, '') ilike '%ifc%'
    or r.folio in ('122573', '122576')
    or coalesce(r.proveedor, '') ilike '%identificar%'
    or coalesce(r.folio, '') ilike '%identificar%'
    or coalesce(r.notas, '') ilike '%identificar%'
  );

commit;

-- ── 4) Ya no deben salir en Recibir ─────────────────────────────
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.cerrado_en,
  left(r.notas, 120) as notas
from public.recepciones r
where r.folio in ('122573', '122576')
   or coalesce(r.proveedor, '') ilike '%ifc%'
   or coalesce(r.proveedor, '') ilike '%identificar%'
   or coalesce(r.folio, '') ilike '%identificar%'
order by r.id;

select
  r.id,
  r.proveedor,
  r.folio,
  r.estado
from public.recepciones r
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
order by r.updated_at desc;
