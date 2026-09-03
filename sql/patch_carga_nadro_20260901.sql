-- Pedido Nadro 20260901 (2026-09-01) — altas + cola Recibir.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 10 altas stock 0. 3 ya estaban: solo costo, no PVP.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd20260901 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  receta boolean not null
) on commit drop;

insert into _fc_nd20260901 (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta) values
  (1, '7503014279552', 'FC-14279552', 'Parches adhesivos Alfa Med 2 tamaños blanco', 'PARCHES ALFA MED ADH 2TAM BCO C', 1, 53.15, 71, 'marca', 'Botiquín', false),
  (2, '7506494600038', 'FC-94600038', 'Rumoquin NF 30 tabletas LGEN', 'RUMOQUIN N.F. 30 TAB LGEN', 1, 46.94, 118, 'generico', 'Medicamentos', false),
  (3, '7506309873701', 'FC-09873701', 'Pantene Rizos Definidos 2en1 100 ml', 'SH ACOND PANT RIZOS DEF2EN1 100ML', 2, 17.56, 24, 'marca', 'Cuidado personal', false),
  (4, '7506306256026', 'FC-06256026', 'Dove Derma Care Hidratación + Alivio acondicionador 400 ml', 'ACOND DOVE DERMA CARE H-ALIV400MLN', 1, 56.91, 76, 'marca', 'Cuidado personal', false),
  (5, '7506306223134', 'FC-06223134', 'Sedal Liso Perfecto acondicionador 300 ml', 'ACOND SEDAL LISO PERFECTO 300 ML', 1, 38.48, 52, 'marca', 'Cuidado personal', false),
  (6, '7501022150818', 'FC-22150818', 'Jabón Grisi Concha Nácar 125 g', 'JBN GRISI CONCHA NACAR 125G', 1, 22.92, 31, 'marca', 'Cuidado personal', false),
  (7, '7501056371159', 'FC-56371159', 'Jabón Dove Exfoliación diaria 135 g', 'JBN DOVE EXFOLIAC DIARIA135G', 1, 28.00, 38, 'marca', 'Cuidado personal', false),
  (8, '7501943489165', 'FC-43489165', 'Jabón líquido Escudo blanco neutro 225 ml', 'JBN LIQ ESCUDO BLANCO NEUT 225ML', 1, 28.27, 38, 'marca', 'Cuidado personal', false),
  (9, '7501022150092', 'FC-22150092', 'Jabón Grisi Leche de Burra 125 g', 'JBN GRISI LECHE DE BURRA 125G', 1, 22.96, 31, 'marca', 'Cuidado personal', false),
  (10, '037836051227', 'FC-36051227', 'Jabón líquido Grisi Concha Nácar 450 ml', 'JBN LIQ GRISI CONCHA NACAR 450ML', 1, 55.31, 74, 'marca', 'Cuidado personal', false),
  (11, '7501022105191', 'FC-22105191', 'Jabón Grisi Neutro 100 g', 'JBN GRISI NEUTRO 100G', 2, 16.24, 22, 'marca', 'Cuidado personal', false),
  (12, '037836050282', 'FC-36050282', 'Jabón líquido Grisi Neutro 450 ml', 'JBN LIQ GRISI NEUTRO 450ML', 1, 55.31, 74, 'marca', 'Cuidado personal', false),
  (13, '3337875917810', 'FC-75917810', 'Anthelios UV Air fluido invisible 50+ 40 ml', 'BLOQ ANTHE UVAIR 50+ FLU INV 40ML', 1, 372.20, 497, 'marca', 'Cuidado personal', false);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Nadro 20260901 · 2026-09-01 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd20260901 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set costo = t.costo
from _fc_nd20260901 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and p.costo is distinct from t.costo;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '20260901',
  '2026-09-01',
  848.05,
  'borrador',
  'Pedido Nadro 20260901 · PDF 01-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '20260901' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 848.05,
  fecha = '2026-09-01',
  proveedor = 'Nadro'
where folio = '20260901'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260901'
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
  t.ean,
  t.snap,
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
from _fc_nd20260901 t
join public.recepciones r
  on r.folio = '20260901'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260901' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
