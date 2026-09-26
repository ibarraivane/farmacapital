-- Cityfarma Iztapalapa · orden S323594 · 2026-09-18 10:49:23
-- Pasillo E-F 44A · vendedor Jonathan Moreno.
-- Cliente LUIS ANGEL PALILLERO VENTURA.
-- Pendiente de pago $546.54. IVA 0. 3 x $182.18.
-- EAN 7501058715555: Tempra Fen infantil ibuprofeno 200 mg/5 ml, frasco 100 ml.
-- No es Tempra paracetamol 80 mg ni TempraFen 400 mg (7506460101002).
-- El papel no trae lote. No inventar MMAA ni 0000.
-- TODO foto: packshot del frasco. No usar placeholder de otra cadena.
-- 1 alta(s) con stock 0 si el EAN no está. El resto solo costo (PVP si estaba en 0).
-- TODO foto: las altas nuevas no traen packshot en este SQL. No usar placeholder de otra cadena.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s323594 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null
) on commit drop;

insert into _fc_cf_s323594 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria, forma, marca, laboratorio, presentacion, principio_activo, concentracion, receta, ya
) values

  (1, '7501058715555', 'FC-58715555', 'Tempra Fen infantil ibuprofeno 200 mg/5 ml suspensión 100 ml', 'TEMPRA FEN INF 100ML', 3, 182.18, 228, 'marca', 'Analgésico', 'Infantil', 'Suspensión', 'Tempra', 'RB Health', 'Caja con frasco 100 ml sabor fresa', 'Ibuprofeno', '200 mg/5 ml', false, false);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma Iztapalapa S323594 · 2026-09-18 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio
from _fc_cf_s323594 t
where (
    t.ean is not null and public.fc_buscar_producto_escaneo(t.ean) is null
  ) or (
    t.ean is null and public.fc_buscar_producto_escaneo(t.sku) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s323594 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  )
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_cf_s323594 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S323594',
  '2026-09-18',
  546.54,
  'borrador',
  'Ticket Cityfarma S323594 · 18-sep-2026 10:49 · Jonathan Moreno · cliente Luis Angel Palillero Ventura · Pasillo E-F 44A · Pendiente de pago $546.54 · Tempra Fen infantil 100 ml ×3 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S323594'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 546.54,
  fecha = '2026-09-18',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S323594 · 18-sep-2026 10:49 · Jonathan Moreno · cliente Luis Angel Palillero Ventura · Pasillo E-F 44A · Pendiente de pago $546.54 · Tempra Fen infantil 100 ml ×3 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'S323594'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S323594'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s323594 t
join public.recepciones r
  on r.folio = 'S323594'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'S323594'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
