-- ============================================================================
-- Accu-Chek · split $681 → 3 SKUs con PVP dueño · 27-sep-2026
--
-- Cajas físicas (fotos):
--   Active 50 tiras     EAN 4015630064076  REF 07124112047  → $262 / $349
--   Instant medidor     EAN 4015630083855  REF 09221832020  → $300 / $399
--   Softclix + 25       EAN 4015630018239  REF 03307450001  → $119 / $159
--
-- Costos asignados (proporcionales al PVP) sobre compra total $681.
-- Softclix / Active pueden existir de Farma Integral (precio cotizar / $270);
-- este patch pisa costo+PVP con los del dueño.
-- Instant medidor es alta nueva (FC-30083855).
--
-- Stock 0 hasta pistola en Recibir. Softclix/Active: MMAA de la caja.
-- Instant: caducidad 2028-08-05 y lote 407868 de la etiqueta UDI.
-- Fotos en public/catalogo-propia/ (visibles tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_accuchek_20260927 (
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
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  receta boolean not null,
  caducidad date,
  lote text,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_accuchek_20260927 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, receta,
  caducidad, lote, imagen, foto_file
) values
  (
    1,
    '4015630064076',
    'FC-30064076',
    'Accu-Chek Active',
    'Accu-Chek Active tiras 50',
    1,
    262,
    349,
    'marca',
    'Diabetes',
    'Tiras',
    'Tiras',
    'Accu-Chek',
    'Roche Diabetes Care',
    '50 tiras',
    false,
    null,
    null,
    'https://www.farmacapital.mx/catalogo-propia/accu-chek-active-tiras-50-4015630064076.jpg',
    'catalogo-propia/accu-chek-active-tiras-50-4015630064076.jpg'
  ),
  (
    2,
    '4015630083855',
    'FC-30083855',
    'Accu-Chek Instant',
    'Accu-Chek Instant medidor',
    1,
    300,
    399,
    'marca',
    'Diabetes',
    'Diagnóstico',
    'Aparato',
    'Accu-Chek',
    'Roche Diabetes Care',
    '1 medidor',
    false,
    '2028-08-05',
    '407868',
    'https://www.farmacapital.mx/catalogo-propia/medidor-accu-chek-instant-4015630083855.jpg',
    'catalogo-propia/medidor-accu-chek-instant-4015630083855.jpg'
  ),
  (
    3,
    '4015630018239',
    'FC-30018239',
    'Accu-Chek Softclix',
    'Accu-Chek Softclix puncionador + 25 lancetas',
    1,
    119,
    159,
    'marca',
    'Diabetes',
    'Lancetas',
    'Dispositivo',
    'Accu-Chek',
    'Roche Diabetes Care',
    '1 puncionador + 25 lancetas',
    false,
    null,
    null,
    'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-puncionador-25-4015630018239.jpg',
    'catalogo-propia/accu-chek-softclix-puncionador-25-4015630018239.jpg'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url,
  disponible, visible_tienda
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
  t.subcategoria,
  t.tipo,
  case t.ean
    when '4015630064076' then
      'Tiras reactivas Accu-Chek Active · medición en 5 s · solo medidor Active · alta split 20260927 · listo para pistola'
    when '4015630083855' then
      'Medidor de glucemia inalámbrico Accu-Chek Instant · indicador de intervalo ideal · Bluetooth mySugr · REF 09221832020 · alta split 20260927 · listo para pistola'
    else
      'Sistema de punción Accu-Chek Softclix · 1 puncionador + 25 lancetas · Clixmotion · prácticamente indoloro · REF 03307450001 · alta split 20260927 · listo para pistola'
  end,
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.laboratorio,
  t.imagen,
  t.imagen,
  'inmediato',
  true
from _fc_accuchek_20260927 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Dueño fijó costo asignado y PVP de mostrador. Pisa ambos.
update public.productos p
set
  costo = t.costo,
  precio = t.precio,
  activo = true,
  tipo = coalesce(nullif(trim(p.tipo), ''), t.tipo),
  categoria = case
    when coalesce(nullif(trim(p.categoria), ''), '') in ('', 'Otro', 'Dispositivo médico')
      then t.categoria
    else p.categoria
  end,
  nombre = t.nombre,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = t.presentacion,
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  disponible = coalesce(nullif(trim(p.disponible), ''), 'inmediato'),
  visible_tienda = true,
  requiere_receta = false
from _fc_accuchek_20260927 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Accu-Chek split',
  '20260927',
  '2026-09-27',
  681,
  'borrador',
  'Split compra $681 · Active 50 ($262→$349) + Instant medidor ($300→$399) + Softclix+25 ($119→$159) = $907 · cola Recibir; stock al confirmar pistola · Softclix/Active MMAA de caja · Instant LOT 407868 cad 2028-08-05'
where not exists (
  select 1 from public.recepciones
  where folio = '20260927'
    and coalesce(proveedor, '') ilike '%accu-chek%split%'
);

update public.recepciones
set
  total_ticket = 681,
  fecha = '2026-09-27',
  proveedor = 'Accu-Chek split',
  notas = 'Split compra $681 · Active 50 ($262→$349) + Instant medidor ($300→$399) + Softclix+25 ($119→$159) = $907 · cola Recibir; stock al confirmar pistola · Softclix/Active MMAA de caja · Instant LOT 407868 cad 2028-08-05',
  updated_at = now()
where folio = '20260927'
  and coalesce(proveedor, '') ilike '%accu-chek%split%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260927'
  and coalesce(r.proveedor, '') ilike '%accu-chek%split%'
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
  t.caducidad,
  t.lote,
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
from _fc_accuchek_20260927 t
join public.recepciones r
  on r.folio = '20260927'
 and coalesce(r.proveedor, '') ilike '%accu-chek%split%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_accuchek_20260927 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
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
where r.folio = '20260927'
  and coalesce(r.proveedor, '') ilike '%accu-chek%split%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.precio,
  p.sku as sku_vivo,
  p.stock,
  p.precio as precio_vivo,
  case when p.id is null then 'PENDIENTE_ALTA' else 'OK' end as match
from _fc_accuchek_20260927 t
left join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
order by t.linea;

commit;
