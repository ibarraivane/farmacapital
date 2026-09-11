-- Pedido Farmacias Guadalajara 531527 (2026-09-11) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

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

commit;

-- Diagnóstico: si renglones = 0 y estado <> borrador → ya estaba cerrada.
-- Si 0 filas → no se insertó (revisa error arriba).
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '531527'
  and coalesce(r.proveedor, '') ilike '%guadalajara%'
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '531527' and coalesce(r.proveedor, '') ilike '%guadalajara%'
order by i.id;
