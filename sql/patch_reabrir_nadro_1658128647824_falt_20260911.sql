-- Reabrir Nadro 1658128647824-01-FALT en cola Recibir (borrador).
--
-- Contexto: al quitar el Irbesartán (no aparece físicamente) y guardar,
-- el ticket salió de pedidos vivos / dio error. Este SQL:
--   1) Lo vuelve a estado borrador (si estaba confirmada / pendiente_alta / descuadre).
--   2) Restaura los 4 renglones que se veían en pantalla.
--   3) NO inventa MMAA ni 0000. Irbesartán queda gris (pistola + caducidad).
--   4) Si Pioglitazona / Suerox / Omeprazol ya tenían lote_id, los deja confirmados
--      (no vuelve a meter stock).
--
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.

begin;

-- ── 0) Diagnóstico previo ──────────────────────────────────────
select
  r.id,
  r.folio,
  r.estado,
  r.cerrado_en,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as verdes,
  count(*) filter (where not coalesce(i.confirmado, false)) as grises
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in ('1658128647824-01', '1658128647824-01-FALT')
group by r.id, r.folio, r.estado, r.cerrado_en
order by r.id;

-- ── 1) Asegurar cabecera FALT ──────────────────────────────────
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '1658128647824-01-FALT',
  '2026-08-30',
  316.96,
  'borrador',
  'Faltantes Nadro 1658128647824-01 · reabierto 2026-09-11 · stock al escanear + MMAA · no inventar 0000'
where not exists (
  select 1 from public.recepciones
  where folio = '1658128647824-01-FALT'
    and coalesce(proveedor, '') ilike '%nadro%'
);

-- Reabrir aunque ya estuviera confirmada / pendiente_alta / descuadre.
update public.recepciones
set
  estado = 'borrador',
  cerrado_en = null,
  proveedor = 'Nadro',
  fecha = coalesce(fecha, '2026-08-30'),
  total_ticket = coalesce(nullif(total_ticket, 0), 316.96),
  notas = 'Faltantes Nadro 1658128647824-01 · reabierto 2026-09-11 · 4 renglones vivos · Irbesartán sigue pendiente de pistola si no llegó',
  updated_at = now()
where folio = '1658128647824-01-FALT'
  and coalesce(proveedor, '') ilike '%nadro%';

-- ── 2) Catálogo de los 4 renglones que estaban en pantalla ─────
create temp table _fc_falt4 (
  linea integer primary key,
  ean text not null,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_falt4 (linea, ean, sku, nombre, qty, costo) values
  (1, '7506442700629', 'FC-42700629', 'IRBESARTAN 300 MG 28 TAB LGEN', 3, 59.66),
  (2, '7502216798878', 'FC-16798878', 'PIOGLITAZONA 30MG 7 TAB ULT LGEN', 6, 17.76),
  (3, '6502400323252', 'FC-40032325', 'SUEROX 8IONES LIMA-LIMON 630ML', 1, 12.42),
  (4, '7502216792555', 'FC-16792555', 'OMEPRAZOL 20 MG 14 CAPS LGEN', 2, 9.50);

-- ── 3) Insertar solo lo que falta (no pisa verdes con lote) ────
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
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_falt4 t
join public.recepciones r
  on r.folio = '1658128647824-01-FALT'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where not exists (
  select 1
  from public.recepcion_items i
  where i.recepcion_id = r.id
    and (
      i.codigo_escaneado = t.ean
      or (v.pid is not null and i.producto_id = v.pid)
    )
);

-- Si el Irbesartán quedó borrado pero el EAN está con otro producto_id, ya se
-- reinsertó arriba. Actualiza qty/costo de grises sin lote (no toca verdes).
update public.recepcion_items i
set
  cantidad = t.qty,
  costo_estimado = t.costo,
  nombre_snapshot = t.nombre,
  codigo_escaneado = coalesce(nullif(btrim(i.codigo_escaneado), ''), t.ean),
  pendiente_alta = (i.producto_id is null)
from _fc_falt4 t
join public.recepciones r
  on r.folio = '1658128647824-01-FALT'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
where i.recepcion_id = r.id
  and i.codigo_escaneado = t.ean
  and i.lote_id is null
  and not coalesce(i.confirmado, false);

commit;

-- ── 4) Verificación ────────────────────────────────────────────
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as verdes,
  count(*) filter (where not coalesce(i.confirmado, false)) as grises_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio = '1658128647824-01-FALT'
group by r.id, r.folio, r.estado, r.total_ticket;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 42) as nombre,
  i.cantidad,
  i.costo_estimado,
  case
    when coalesce(i.confirmado, false) and i.lote_id is not null then 'VERDE (ya en stock)'
    when coalesce(i.confirmado, false) then 'VERDE (sin lote — re-escanea)'
    else 'GRIS — pistola + MMAA'
  end as estado,
  i.fecha_caducidad,
  i.numero_lote
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '1658128647824-01-FALT'
  and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
