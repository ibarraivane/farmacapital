-- Pedido Farmalive 97 (2026-09-10) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_farmalive97 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_farmalive97 (linea, ean, sku, nombre, qty, costo) values
  (1, '7501017362998', null, 'PAÑUELOS KLEENEX PACK C/8 | KIMBERLY CLARK', 1, 32.83),
  (2, '7501287630506', null, 'ANT (WA) TERRAMICINA TROCISCOS C/24 | UPJOHN PHARMA', 2, 186.59),
  (3, '7500435182041', null, 'MOUSSE HERBAL ESSENCES RIZOS 200 R 2PACK | PG PERF', 1, 114.95),
  (4, '7501048335305', null, 'AGUA OXIGENADA DERMOCLEEN 480ML | DEGASA', 3, 14.70),
  (5, '7500435179980', null, 'ENJ BUCAL ORAL B 100% 250 ML | P&G PERF', 3, 49.29),
  (6, '7891051037878', null, 'ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF', 2, 49.00),
  (7, '7506552900247', null, 'ALMOHADILLAS RETANGULARES QUIRMEX C/100 | QUIRMEX', 2, 32.83),
  (8, '7503003406785', null, 'TORUNDA DE ALGODON QUIRMEX 75 GR | QUIRMEX', 4, 17.54),
  (9, '7501048621408', null, 'TORUNDA PROTEC C/150 BOLITAS | DEGASA', 2, 20.19),
  (10, '056100024798', null, 'TOA SANIT ALWAYS NOC ALAS C/8 | P&G PERF', 2, 27.25),
  (11, '7501019068911', null, 'PROTECTORES SABA TRADICIONAL LARGO C/28 | SCA', 2, 25.77),
  (12, '7501058368126', null, 'COND SICO ROJO FEEL CART C/3 | RB HEALTH', 1, 62.23),
  (13, '7502208891549', null, 'TARMIN 2 MG C/12 TAB | BRULUAGSA', 3, 6.37),
  (14, '7501006719932', null, 'CEPILLO ORAL-B COMPLET MED 2X1 | PG PERF', 2, 30.38),
  (15, '7501086494286', null, 'CEPILLO ORAL-B CLASICO 60 SUAVE | PG PERF', 2, 22.93),
  (16, '037836041266', null, 'CRE HINDS ROSA RESECA 230 ML | GRISI HNOS', 1, 35.28),
  (17, '7501048335169', null, 'AGUA OXIGENADA DERMOCLEEN 230ML | DEGASA', 3, 10.19),
  (18, '037836041358', null, 'CRE HINDS NAT RESECA 230 ML | GRISI HNOS', 1, 35.28),
  (19, '7503006698316', null, 'MICRODACYN 60 SOL 120 ML | MORE PHARMA', 1, 168.56),
  (20, '7501080921139', null, 'CRE DEPILADORA NAIR P SENSIBLE 150 ML | CHURCH & DWIGHTND', 1, 81.60),
  (21, '650240072154', null, 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.72),
  (22, '650240032271', null, 'SUEROX 8IONES UVA 630 ML | GENOMMA LAB', 2, 14.72),
  (23, '7501868950702', null, 'VASO RECOLECTOR DIBAR 100ml | DIBAR', 5, 5.00),
  (24, '7506552900322', null, 'VASO RECOLECTOR QUIRMEX | QUIRMEX', 4, 3.73),
  (25, '7501165011656', null, 'BUSCAPINA FEM TAB C/10 | OPELLA', 3, 130.34),
  (26, '3664798062243', null, 'PHARMATON COMPLETE TAB C/100 | OPELLA', 2, 0.01),
  (27, '7501165000230', null, 'IV NEOMELUBRINA TAB C/10 | OPELLA', 5, 72.23);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '97',
  '2026-09-10',
  2483.41,
  'borrador',
  'Pedido Farmalive 97 · Club Iztapalapa 1 · EAN del ticket · precio neto (2%/5%/15%) · Pharmaton promo consolidada · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '97' and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 2483.41,
  fecha = '2026-09-10',
  proveedor = 'Farmalive',
  notas = 'Pedido Farmalive 97 · Club Iztapalapa 1 · EAN del ticket · precio neto (2%/5%/15%) · Pharmaton promo consolidada · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '97'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '97'
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
from _fc_rx_farmalive97 t
join public.recepciones r
  on r.folio = '97'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
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
where r.folio = '97'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
where r.folio = '97' and coalesce(r.proveedor, '') ilike '%farmalive%'
order by i.id;
