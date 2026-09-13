-- Pedido City Mark 20260912 (2026-09-12) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_citymark20260912 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_citymark20260912 (linea, ean, sku, nombre, qty, costo) values
  (1, '7501943476271', 'FC-43476271', 'Kleenex pañuelos bote C/50', 2, 29.14),
  (2, '070330731813', 'FC-30731813', 'BIC Soleil 3 Color Collection 12 pzas', 1, 155.32),
  (3, '070330717541', 'FC-30717541', 'BIC Advance tira rastrillo 12 pzas', 1, 169.60),
  (4, '850040940602', 'FC-40940602', 'Grisi Organogal Silver shampoo 400 ml + canas 130 ml', 1, 87.35),
  (5, '810120500164', 'FC-20500164', 'Pert crema peinar keratina + aguacate 100 ml', 2, 14.80),
  (6, '7502254073371', 'FC-54073371', 'Seda Pure silica argán spray 300 ml', 1, 69.04),
  (7, '7502254073357', 'FC-54073357', 'Seda Pure silica uva spray 300 ml', 1, 69.05),
  (8, '7506306208315', 'FC-06208315', 'St Ives colágeno y elastina 200 ml', 1, 32.31),
  (9, '7501080111455', 'FC-80111455', 'Just For Men tinte barba/bigote negro', 2, 171.14),
  (10, '7502254073715', 'FC-54073715', 'Seda Pure acondicionador kerat bifásico 250 ml', 1, 55.10),
  (11, '810120500171', 'FC-20500171', 'Pert crema peinar oliva + aguacate 100 ml', 2, 14.80),
  (12, '7702031887928', 'FC-31887928', 'Listerine Care Zero menta 250 ml', 1, 63.53),
  (13, '7891010974329', 'FC-10974329', 'Listerine Zero menta suave 250 ml', 1, 54.06),
  (14, '7702035433299', 'FC-35433299', 'Listerine Defense 250 ml', 1, 63.86),
  (15, '7501027233974', 'FC-27233974', 'L''Oréal Fix Inv ultra fijación gel 180 g', 1, 58.10),
  (16, '7502254072831', 'FC-54072831', 'Seda Pure silica brillo extremo 125 ml', 2, 58.54),
  (17, '7506306208353', 'FC-06208353', 'St Ives avena y karité 200 ml', 1, 32.31);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'City Mark',
  '20260912',
  '2026-09-12',
  1486.47,
  'borrador',
  'Pedido City Mark 20260912 · ticket PUBLICO EN GENERAL · encabezado cortado (folio/fecha estimados 12-sep-2026) · EAN del ticket · cola Recibir; stock al confirmar pistola · altas con ficha+foto en catalogo-propia'
where not exists (
  select 1 from public.recepciones
  where folio = '20260912' and coalesce(proveedor, '') ilike '%city mark%'
);

update public.recepciones
set
  total_ticket = 1486.47,
  fecha = '2026-09-12',
  proveedor = 'City Mark',
  notas = 'Pedido City Mark 20260912 · ticket PUBLICO EN GENERAL · encabezado cortado (folio/fecha estimados 12-sep-2026) · EAN del ticket · cola Recibir; stock al confirmar pistola · altas con ficha+foto en catalogo-propia',
  updated_at = now()
where folio = '20260912'
  and coalesce(proveedor, '') ilike '%city mark%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260912'
  and coalesce(r.proveedor, '') ilike '%city mark%'
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
from _fc_rx_citymark20260912 t
join public.recepciones r
  on r.folio = '20260912'
 and coalesce(r.proveedor, '') ilike '%city mark%'
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
where r.folio = '20260912'
  and coalesce(r.proveedor, '') ilike '%city mark%'
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
where r.folio = '20260912' and coalesce(r.proveedor, '') ilike '%city mark%'
order by i.id;
