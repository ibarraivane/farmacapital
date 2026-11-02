-- Pedido Fanasa folio B49445264 (2026-11-02) — altas + cola Recibir.
-- Factura · pedido 57020464 · total $667.19.
-- CANT=1 por renglón (columna BUL ≠ cantidad). Costo = PRECIO FARMACIA.
-- PVP = recargo marca ×1.25. Ficha Carnot (PCI en ticket = Productos Científicos).
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_fanasa_b49445264.sql

begin;

create temp table _fc_fnb49445264 (
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
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_fnb49445264
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva)
values
  (1, '7501070903237', 'FC-70903237', 'Fluxedan 6/12 mg', 'FLUXEDAN BROMHEXINA OXELADINA 24 COM', 1, 313.41, 392, 'marca', 'Medicamentos', 'Respiratorio', 'Fluxedan', 'Caja con 24 comprimidos', 'Comprimido', 'Carnot', 'Bromhexina / oxeladina', '6 mg / 12 mg', true, true),
  (2, '7501070900441', 'FC-70900441', 'Fluxedan jarabe', 'FLUXEDAN CLORHIDRATO DE BROMHEXINA 6/12 mg/10 ml 1 JBE 225 ml', 1, 353.78, 443, 'marca', 'Medicamentos', 'Respiratorio', 'Fluxedan', 'Frasco 225 ml con medida', 'Jarabe', 'Carnot', 'Bromhexina / oxeladina', '6 mg / 12 mg por 10 ml', true, true);

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
  'Alta Fanasa B49445264 · 2026-11-02 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_fnb49445264 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

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
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_fnb49445264 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_fnb49445264 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Fanasa',
  'B49445264',
  '2026-11-02',
  667.19,
  'borrador',
  'Pedido Fanasa B49445264 · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'B49445264' and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = 667.19,
  fecha = '2026-11-02',
  proveedor = 'Fanasa',
  notas = 'Pedido Fanasa B49445264 · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'B49445264'
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'B49445264'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
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
from _fc_fnb49445264 t
join public.recepciones r
  on r.folio = 'B49445264'
 and coalesce(r.proveedor, '') ilike '%fanasa%'
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = 'B49445264' and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;
