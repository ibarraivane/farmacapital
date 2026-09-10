-- Pedido IFC F8 Tienda 123443 (2026-09-10) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_ifc123443 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_ifc123443 (linea, ean, sku, nombre, qty, costo) values
  (1, null, 'FC-IFC-82084', 'Brocha para tinte con peine de cola', 4, 5.50),
  (2, null, 'FC-IFC-83947', 'Guantes de nitrilo negro mediano C/100', 1, 104.00),
  (3, null, 'FC-IFC-83490', 'Guantes de nitrilo azul chico C/100', 1, 92.00),
  (4, null, 'FC-IFC-82912P', 'Venda Stick cohesiva 3 pulg × 4.5 m piel', 1, 45.00),
  (5, null, 'FC-IFC-82912A', 'Venda Stick cohesiva 3 pulg × 4.5 m azul', 1, 47.50),
  (6, null, 'FC-IFC-83613', 'Venditas adhesivas redondas Jayor C/100', 1, 52.50),
  (7, null, 'FC-IFC-83552', 'Venda Stick cohesiva 2 pulg × 4.5 m rojo', 2, 29.50),
  (8, null, 'FC-IFC-83125', 'Guantes de nitrilo azul grande C/100', 1, 92.00),
  (9, null, 'FC-IFC-83368', 'Gel sanitizante Dibar 50 ml', 5, 11.50);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '123443',
  '2026-09-10',
  571.50,
  'borrador',
  'Farma Centre / IFC F8 Tienda · folio 123443 · MAYOREO+MENUDEO · 10-sep-2026 16:51 · sin EAN GS1 (códigos IFC) · cola Recibir; stock al confirmar pistola · ligar EAN de caja'
where not exists (
  select 1 from public.recepciones
  where folio = '123443' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 571.50,
  fecha = '2026-09-10',
  proveedor = 'IFC F8 Tienda',
  notas = 'Farma Centre / IFC F8 Tienda · folio 123443 · MAYOREO+MENUDEO · 10-sep-2026 16:51 · sin EAN GS1 (códigos IFC) · cola Recibir; stock al confirmar pistola · ligar EAN de caja',
  updated_at = now()
where folio = '123443'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '123443'
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
from _fc_rx_ifc123443 t
join public.recepciones r
  on r.folio = '123443'
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
where r.folio = '123443'
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
where r.folio = '123443' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;
