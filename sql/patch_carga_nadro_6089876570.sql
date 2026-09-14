-- Pedido Nadro folio 6089876570 (2026-09-09) — altas + cola Recibir.
-- PDF: Archivo_escaneado_20260910-1158.pdf · total $426.83
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
--
-- Altas nuevas stock 0:
--   FC-03477270 Curitas El Gallo parche callos C/6
--   FC-63310269 Metoclopramida 10 mg C/20 (Bioresearch)
-- Corrección ficha (mismo EAN, mal nombre):
--   FC-05405168 Saluk Fashion Sa → Estropajo Saluk Fashion F-Clean clásica
-- Ya existían: Lubriderm, Dirpasid EQ-BRL053, Realdrax EQ-LIF153, Suerox, Odolex.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6089876570
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, receta, alta_nueva)
values
  (1, '7702031244486', 'FC-31244486',
   'Crema Lubriderm piel normal 120 ml',
   'CRA LUBRIDERM P/NORMAL 120ML',
   2, 28.07, 45, 'marca', 'Cuidado personal', false, false),
  (2, '7502208892638', 'EQ-BRL053',
   'Dirpasid (Metoclopramida) 10 mg C/20',
   'DIRPASID 10 MG 20 TAB LGEN',
   2, 7.88, 13, 'generico', 'Medicamentos', false, false),
  (3, '7503005405168', 'FC-05405168',
   'Estropajo Saluk Fashion F-Clean clásica',
   'ESTROPAJO F-CLEAN CLASICA SAL C/1',
   3, 7.53, 19, 'marca', 'Higiene', false, false),
  (4, '7501563310269', 'FC-63310269',
   'Metoclopramida 10 mg C/20 tabletas',
   'METOCLOPRAMIDA 10MG 20 TAB LGEN',
   4, 6.88, 12, 'generico', 'Medicamentos', false, true),
  (5, '7702003477270', 'FC-03477270',
   'Curitas El Gallo parche para callos C/6',
   'PARCHE CURITAS EL GALLO C/6',
   2, 54.34, 67, 'marca', 'Botiquín', false, true),
  (6, '7501836010087', 'EQ-LIF153',
   'Realdrax MXD 20/400 mg C/10',
   'REALDRAX-MXD 20/400MG 10TAB LGEN',
   3, 40.34, 75, 'generico', 'Medicamentos', false, false),
  (7, '650240032295', 'FC-40032295',
   'Suerox 8 iones Mora Azul / Hierbabuena 630 ml',
   'SUEROX 8IONES MORA AZUL HIERB 630ML',
   2, 12.14, 20, 'marca', 'Bebidas', false, false),
  (8, '7501361111501', 'FC-61111501',
   'Talco desodorante Odolex 150 g',
   'TCO DESOD ODOLEX 150 G',
   1, 13.64, 25, 'marca', 'Higiene', false, false);

-- Altas nuevas (solo si el EAN no existe).
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
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha Curitas El Gallo
update public.productos p set
  marca = 'Curitas',
  presentacion = 'Caja con 6 parches',
  forma_farmaceutica = 'Parche cutáneo',
  principio_activo = 'Ácido salicílico',
  subcategoria = 'Material de curación',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'BDF México')
where p.id = public.fc_buscar_producto_escaneo('7702003477270');

-- Ficha Metoclopramida Bioresearch
update public.productos p set
  marca = 'Bioresearch',
  presentacion = 'Caja con 20 tabletas',
  forma_farmaceutica = 'Tableta',
  principio_activo = 'Metoclopramida 10 mg',
  subcategoria = 'Gastrointestinal',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Bioresearch')
where p.id = public.fc_buscar_producto_escaneo('7501563310269');

-- Corregir Saluk Fashion Sa → estropajo F-Clean (mismo EAN 7503005405168).
update public.productos p set
  nombre = 'Estropajo Saluk Fashion F-Clean clásica',
  marca = 'Saluk Fashion',
  presentacion = '1 pieza',
  forma_farmaceutica = 'Estropajo',
  categoria = 'Higiene',
  subcategoria = 'Limpieza / hogar',
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'Lidernova'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(descripcion, '')), ''),
    'Nadro 6089876570 ESTROPAJO F-CLEAN CLASICA SAL C/1 · antes mal nombrado Saluk Fashion Sa'
  ))
where p.id = public.fc_buscar_producto_escaneo('7503005405168')
   or p.sku = 'FC-05405168';

-- Costos del ticket (PVP solo si estaba en 0).
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

-- Suerox: catálogo puede tener check-digit 6502400322958.
update public.productos p
set costo = 12.14
where p.sku = 'FC-40032295'
  and p.costo is distinct from 12.14;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6089876570',
  '2026-09-09',
  426.83,
  'borrador',
  'Pedido Nadro 6089876570 · PDF 10-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6089876570' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 426.83,
  fecha = '2026-09-09',
  proveedor = 'Nadro',
  notas = 'Pedido Nadro 6089876570 · PDF 10-09-26 · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
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
    public.fc_buscar_producto_escaneo(t.sku),
    case
      when t.ean = '650240032295'
        then public.fc_buscar_producto_escaneo('6502400322958')
      else null
    end
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6089876570' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
