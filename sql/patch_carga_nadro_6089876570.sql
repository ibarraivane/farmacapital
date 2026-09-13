-- Pedido Nadro 6089876570 (2026-09-09) — altas + cola Recibir.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0. 6 ya estaban: solo costo (y PVP si estaba en 0).
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- FOTOS PENDIENTES (altas nuevas): Biopram 7501563310269, Curitas El Gallo 7702003477270.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd6089876570 (
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

insert into _fc_nd6089876570 (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta) values
  (1, '7702031244486', 'FC-31244486', 'Crema Lubriderm piel normal 120 ml', 'CRA LUBRIDERM P/NORMAL 120ML', 2, 28.07, 38, 'marca', 'Cuidado personal', false),
  (2, '7502208892638', 'FC-08892638', 'Dirpasid Metoclopramida 10 mg 20 tabletas', 'DIRPASID 10 MG 20 TAB LGEN', 2, 7.89, 20, 'generico', 'Medicamentos', false),
  (3, '7503005405168', 'FC-05405168', 'Estropajo F-Clean clásica', 'ESTROPAJO F-CLEAN CLASICA SAL C/1', 3, 7.53, 11, 'marca', 'Cuidado personal', false),
  (4, '7501563310269', 'FC-63310269', 'Biopram Metoclopramida 10 mg 20 tabletas', 'METOCLOPRAMIDA 10MG 20 TAB LGEN', 4, 6.88, 18, 'generico', 'Medicamentos', false),
  (5, '7702003477270', 'FC-03477270', 'Curitas parche para callos El Gallo 6 piezas', 'PARCHE CURITAS EL GALLO C/6', 2, 54.84, 74, 'marca', 'Botiquín', false),
  (6, '7501836010087', 'EQ-LIF153', 'Realdrax MXD Hioscina/Ibuprofeno 20/400 mg 10 tabletas', 'REALDRAX-MXD 20/400MG 10TAB LGEN', 3, 40.34, 101, 'generico', 'Medicamentos', false),
  (7, '6502400322958', 'FC-40032295', 'Suerox 8 iones Mora Azul 630 ml', 'SUEROX 8IONES MORA AZUL/HIERB 630ML', 2, 12.14, 17, 'marca', 'Cuidado personal', false),
  (8, '7501361111501', 'FC-61111501', 'Talco desodorante Odolex 150 g', 'TCO DESOD ODOLEX 150 G', 1, 13.64, 19, 'marca', 'Cuidado personal', false);

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
  'Alta Nadro 6089876570 · 2026-09-09 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6089876570 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Estropajo: el alta vieja quedó con nombre de ticket/OCR; poner nombre de mostrador.
update public.productos p
set
  nombre = t.nombre,
  updated_at = now()
from _fc_nd6089876570 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7503005405168'
  and (
    p.nombre ilike '%saluk fashion%'
    or p.nombre ilike '%estropajo f-clean%'
  )
  and p.nombre is distinct from t.nombre;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6089876570 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6089876570',
  '2026-09-09',
  426.83,
  'borrador',
  'Pedido Nadro 6089876570 · factura 09-09-26 · EAN corroborados · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6089876570' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 426.83,
  fecha = '2026-09-09',
  proveedor = 'Nadro'
where folio = '6089876570'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6089876570'
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
from _fc_nd6089876570 t
join public.recepciones r
  on r.folio = '6089876570'
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
where r.folio = '6089876570' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
