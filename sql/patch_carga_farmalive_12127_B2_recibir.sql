-- Farmalive 12127 · PARTE B2 · cola Recibir (despues de B1)
-- Crea/actualiza borrador folio 12127 e inserta 109 renglones.

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '12127',
  '2026-09-28',
  11696.80,
  'borrador',
  'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 16:24 · 109 art / 238 pzas · $11,696.80 · precio neto · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '12127'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 11696.80,
  fecha = '2026-09-28',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 16:24 · 109 art / 238 pzas · $11,696.80 · precio neto · cola Recibir',
  updated_at = now()
where folio = '12127'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '12127'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from public._fc_fl_12127_staging t
join public.recepciones r
  on r.folio = '12127'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '12127'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;
