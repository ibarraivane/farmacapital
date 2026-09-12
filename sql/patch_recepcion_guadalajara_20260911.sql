-- Farmacias Guadalajara · 2 tickets vivos en Recibir (11-sep-2026).
-- 531527 Lenzetto + AUT-764870 Wegovy.
-- SIN do $$. Stock al escanear + MMAA. No inventar 0000.
-- Idempotente en borrador. Pegar TODO en Supabase → SQL Editor → Run.
-- Si aún no corriste las altas: primero patch_carga_guadalajara_20260911.sql

begin;

-- ── Ticket 531527 · Lenzetto ─────────────────────────────────


create temp table _fc_rx_guadalajara531527 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_guadalajara531527 (linea, ean, sku, nombre, qty, costo) values
  (1, '7506352500128', 'FC-52500128', 'LENZETTO 1.53MG/DS 6.5ML 56D SOL', 1, 578.76);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmacias Guadalajara',
  '531527',
  '2026-09-11',
  578.76,
  'borrador',
  'Ticket FG 531527 · SUC SN Lorenzo Iztapalapa · FOLIO FACTURA 599104-181830-424489 · 2026-09-11 15:50 · Lenzetto · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '531527' and coalesce(proveedor, '') ilike '%guadalajara%'
);

update public.recepciones
set
  total_ticket = 578.76,
  fecha = '2026-09-11',
  proveedor = 'Farmacias Guadalajara',
  notas = 'Ticket FG 531527 · SUC SN Lorenzo Iztapalapa · FOLIO FACTURA 599104-181830-424489 · 2026-09-11 15:50 · Lenzetto · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '531527'
  and coalesce(proveedor, '') ilike '%guadalajara%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '531527'
  and coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  null,
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
from _fc_rx_guadalajara531527 t
join public.recepciones r
  on r.folio = '531527'
 and coalesce(r.proveedor, '') ilike '%guadalajara%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;


-- ── Ticket AUT-764870 · Wegovy ────────────────────────────────


create temp table _fc_rx_guadalajaraaut764870 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_guadalajaraaut764870 (linea, ean, sku, nombre, qty, costo) values
  (1, '7503007822970', 'FC-07822970', 'WEGOVY 1.7MG SOL INY 1 PLUMA/PRE', 1, 4650.00);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmacias Guadalajara',
  'AUT-764870',
  '2026-09-11',
  4650.00,
  'borrador',
  'Ticket FG Wegovy · SUC SN Lorenzo Iztapalapa · AUT Bancomer 764870 (NO TICKET no visible en foto) · cola Recibir; stock al confirmar pistola · cadena de frío 2–8 °C'
where not exists (
  select 1 from public.recepciones
  where folio = 'AUT-764870' and coalesce(proveedor, '') ilike '%guadalajara%'
);

update public.recepciones
set
  total_ticket = 4650.00,
  fecha = '2026-09-11',
  proveedor = 'Farmacias Guadalajara',
  notas = 'Ticket FG Wegovy · SUC SN Lorenzo Iztapalapa · AUT Bancomer 764870 (NO TICKET no visible en foto) · cola Recibir; stock al confirmar pistola · cadena de frío 2–8 °C',
  updated_at = now()
where folio = 'AUT-764870'
  and coalesce(proveedor, '') ilike '%guadalajara%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'AUT-764870'
  and coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  null,
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
from _fc_rx_guadalajaraaut764870 t
join public.recepciones r
  on r.folio = 'AUT-764870'
 and coalesce(r.proveedor, '') ilike '%guadalajara%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;

commit;

select r.folio, r.estado, r.total_ticket, count(i.*) as renglones
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.folio in ('531527', 'AUT-764870')
group by r.id, r.folio, r.estado, r.total_ticket
order by r.folio;

select r.folio, i.codigo_escaneado as ean, left(i.nombre_snapshot, 48) as snap,
  i.cantidad, i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.folio in ('531527', 'AUT-764870')
order by r.folio, i.id;
