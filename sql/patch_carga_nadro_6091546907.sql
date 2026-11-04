-- Pedido Nadro folio 6091546907 (2026-10-25) — altas + cola Recibir.
-- Factura CFDI · total $312.34 · UUID 02768924-…
-- Ficha iNadro (no código del PDF). LGEN no va como marca.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
--
-- Ya existía (renombrar ficha + costo):
--   FC-06241206 Dove Dermoaclarant Skin Calming spray 150 ml
-- Altas nuevas stock 0:
--   FC-06241183 Dove Original spray 150 ml
--   FC-42701200 Memantina 10 mg C/28 (Corne)
--   FC-23553477 Zolufen (Omeprazol) 20 mg C/30 (Synthon / Novo Nafar)
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091546907.sql

begin;

create temp table _fc_nd6091546907 (
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
  subcategoria text,
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  lote text,
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091546907
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, lote,
   receta, alta_nueva)
values
  (1, '7506306241206', 'FC-06241206',
   'Dove Dermoaclarant Skin Calming',
   'DESOD DOVE DERMAC SK-C 48H SPY150ML',
   1, 41.35, 52, 'marca', 'Cuidado personal', 'Desodorantes',
   'Dove', 'Spray 150 ml', 'Spray', 'Unilever', null, null, null,
   false, false),
  (2, '7506306241183', 'FC-06241183',
   'Dove Original',
   'DESOD DOVE ORIGINAL 48H SPY150ML',
   2, 41.04, 52, 'marca', 'Cuidado personal', 'Desodorantes',
   'Dove', 'Spray 150 ml', 'Spray', 'Unilever', null, null, null,
   false, true),
  (3, '7502242701200', 'FC-42701200',
   'Memantina 10 mg',
   'MEMANTINA 10 MG 28 TAB LGEN',
   1, 90.41, 145, 'generico', 'Medicamentos', 'Sistema nervioso',
   null, 'Caja con 28 tabletas', 'Tableta', 'Corne', 'Memantina', '10 mg', '252570',
   true, true),
  (4, '7502223553477', 'FC-23553477',
   'Zolufen (Omeprazol) 20 mg',
   'OMEPRAZOL 20 MG 30 CAPS LGEN',
   5, 15.75, 26, 'generico', 'Medicamentos', 'Gastrointestinal',
   'Zolufen', 'Frasco con 30 cápsulas', 'Cápsula', 'Synthon', 'Omeprazol', '20 mg', 'ZZ8011A',
   false, true);

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
  'Alta Nadro 6091546907 · 2026-10-25 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091546907 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real; no LGEN).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = coalesce(t.concentracion, p.concentracion),
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6091546907 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6091546907 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091546907',
  '2026-10-25',
  312.34,
  'borrador',
  'Factura Nadro 6091546907 · 25-oct-2026 · CFDI · EAN iNadro · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '6091546907' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 312.34,
  fecha = '2026-10-25',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091546907 · 25-oct-2026 · CFDI · EAN iNadro · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '6091546907'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091546907'
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
  nullif(btrim(t.lote), ''),
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
from _fc_nd6091546907 t
join public.recepciones r
  on r.folio = '6091546907'
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
  i.numero_lote as lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091546907' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
