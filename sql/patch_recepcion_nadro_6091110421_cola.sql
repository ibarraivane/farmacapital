-- SOLO cola Recibir · Nadro folio 6091110421 · $720.23 · 11 piezas.
-- Sin altas de catálogo (esas van aparte). Si el patch_carga falló a medias,
-- este archivo fuerza el borrador + 6 renglones grises.
-- SIN do $$. Pegar TODO → Supabase SQL Editor → Run.
-- Al final DEBEN salir 6 filas. Si salen 0, copia el error de arriba.

begin;

create temp table _fc_rx_nd6091110421 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_nd6091110421 (linea, ean, sku, nombre, qty, costo) values
  (1, '7501349012011', 'FC-49012011', 'AMCEF CEFTRIA 1G SI FA 10ML LGEN', 1, 19.80),
  (2, '7501349011007', 'FC-07F04F88', 'AMCEF IM CEFT500MG SI FA 2ML LGEN', 4, 16.10),
  (3, '7501022112274', 'FC-22112274', 'C-BOOST SUP ALIM OMEGA3 FCO 90GOM', 1, 118.18),
  (4, '7501853805253', 'FC-53805253', 'COLAG/BIOTA HIA S ALIM FSA 14GOM', 2, 49.01),
  (5, '7503024083439', 'FC-24083439', 'JUST OMEGA3 S ALIM DHA EPA 120 GOM', 1, 188.48),
  (6, '7502226293929', 'FC-26293929', 'METFORMINA LP 500 MG 30 TAB LGEN', 2, 77.82);

-- Si ya hay recepción Nadro con este folio y NINGÚN renglón confirmado,
-- la reabrimos a borrador (así no queda “fantasma” fuera de la lista).
update public.recepciones r
set
  estado = 'borrador',
  proveedor = 'Nadro',
  folio = '6091110421',
  fecha = '2026-10-13',
  total_ticket = 720.23,
  notas = 'Factura Nadro 6091110421 · cola Recibir forzada · stock al escanear + MMAA',
  updated_at = now()
where r.folio = '6091110421'
  and coalesce(r.proveedor, '') ilike '%nadro%'
  and r.estado is distinct from 'borrador'
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id and coalesce(i.confirmado, false)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091110421',
  '2026-10-13',
  720.23,
  'borrador',
  'Factura Nadro 6091110421 · cola Recibir forzada · stock al escanear + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091110421' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 720.23,
  fecha = '2026-10-13',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091110421 · cola Recibir forzada · stock al escanear + MMAA',
  updated_at = now()
where folio = '6091110421'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091110421'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_rx_nd6091110421 t
join public.recepciones r
  on r.folio = '6091110421'
 and coalesce(r.proveedor, '') ilike '%nadro%'
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

-- Debe devolver 1 fila: estado borrador, renglones 6, sin_confirmar 6.
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '6091110421'
  and coalesce(r.proveedor, '') ilike '%nadro%'
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
where r.folio = '6091110421' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
