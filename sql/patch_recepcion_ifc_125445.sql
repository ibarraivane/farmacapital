-- Pedido IFC F8 Tienda 125445 (2026-09-24) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_ifc125445 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_ifc125445 (linea, ean, sku, nombre, qty, costo) values
  (1, null, 'FC-IFC-1570818', 'Mercurio magnesia calcinada C/50', 1, 55.50),
  (2, null, 'FC-IFC-ESPEJITO', 'Espejito redondo económico', 5, 6.00),
  (3, null, 'FC-IFC-PARCHE-ACNE', 'Parches para acné hidrocoloide', 6, 16.50),
  (4, null, 'FC-IFC-82912', 'Benzal Wash líquido 240 mL', 1, 102.50),
  (5, null, 'FC-IFC-1490724', 'Mercurio rosa de Castilla C/50', 1, 75.00),
  (6, null, 'FC-IFC-1330723', 'Mercurio almidón cajita C/10', 1, 91.50),
  (7, null, 'FC-IFC-1660824', 'Mercurio anís estrella C/25', 1, 131.00),
  (8, null, 'FC-IFC-1400724', 'Mercurio bórax polvo C/50', 1, 53.00),
  (9, null, 'FC-IFC-PULEFIN100', 'Lima de uñas Pulefin C/100', 1, 94.50),
  (10, null, 'FC-IFC-82943', 'Mercurio pomada manzana C/25', 4, 9.50);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '125445',
  '2026-09-24',
  770.00,
  'borrador',
  'Farma Centre / IFC F8 Tienda · folio 125445 · 2026-09-24 16:41 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '125445' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 770.00,
  fecha = '2026-09-24',
  proveedor = 'IFC F8 Tienda',
  notas = 'Farma Centre / IFC F8 Tienda · folio 125445 · 2026-09-24 16:41 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '125445'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '125445'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
from _fc_rx_ifc125445 t
join public.recepciones r
  on r.folio = '125445'
 and coalesce(r.proveedor, '') ilike '%ifc%'
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
where r.folio = '125445'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
where r.folio = '125445' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;
