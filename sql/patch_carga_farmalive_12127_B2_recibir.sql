-- Farmalive 12127 · B2 · cola Recibir (despues de B1 altas + costos)
-- Join por codigo_barras / sku (sin fc_buscar en masa).

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive', '12127', '2026-09-28', 11696.80, 'borrador',
  'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 · 238 pzas · $11,696.80'
where not exists (
  select 1 from public.recepciones
  where folio = '12127' and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set total_ticket = 11696.80,
    fecha = '2026-09-28',
    proveedor = 'Farmalive',
    notas = 'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 · 238 pzas · $11,696.80',
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
  p.id,
  t.ean,
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (p.id is null),
  'pdf',
  false,
  false,
  null
from public._fc_fl_12127_staging t
join public.recepciones r
  on r.folio = '12127'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join public.productos p
  on p.codigo_barras = t.ean
  or p.sku = t.sku
order by t.linea;

select
  r.folio, r.estado, r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(i.*) filter (where i.pendiente_alta) as pendientes_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '12127'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.estado, r.total_ticket;
