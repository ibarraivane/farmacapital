-- Farma Mayoreo · ID VENTA 306978 · 2026-09-28 16:00 · caja 1 · Rosalba Medel
-- RFC FMA180119D55 · FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).
-- Pago tarjeta. SUBTOTAL $465.34 + IVA $74.40 = TOTAL $539.74.
-- Los P.U. ya traen IVA (suma renglones = total). 12 renglones / 27 pzas.
-- Blumen 525: coco 9624 · cherry 9648 · kiwi 9617. 221 ml: cherry/coco/kiwi.
-- Aceite/Acetona Madrid: ticket «MADRID ACEITE DE» / «ACETONA MADRID 4» —
-- no se inventa tipo ni ml (mismo criterio que almendras 305016).
-- Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 9 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): ninguno.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm_306978 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_fm_306978 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7503007859624', 'FC-07859624', 'Blumen jabón líquido Coconut Paradise 525 ml', 'BLUMEN JABON LIQ', 1, 35.98, 45, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 525 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/blumen-jabon-liquido-coco-525ml-7503007859624.jpg', 'catalogo-propia/blumen-jabon-liquido-coco-525ml-7503007859624.jpg', null),
  (2, '7503007859648', 'FC-07859648', 'Blumen jabón líquido Cherry Blossom 525 ml', 'BLUMEN JABON LIQ', 2, 35.98, 45, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 525 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/blumen-jabon-liquido-cherry-525ml.jpg', 'catalogo-propia/blumen-jabon-liquido-cherry-525ml.jpg', null),
  (3, '7503007859617', 'FC-07859617', 'Blumen jabón líquido Kiwi 525 ml', 'BLUMEN JABON LIQ', 2, 35.98, 45, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 525 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/blumen-jabon-liquido-kiwi-525ml-7503007859617.jpg', 'catalogo-propia/blumen-jabon-liquido-kiwi-525ml-7503007859617.jpg', null),
  (4, '7506267905131', 'FC-67905131', 'Blumen jabón líquido Cherry Blossom 221 ml', 'JABON BLUMEN JL', 2, 17.69, 23, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 221 ml', null, null, false, true, null, null, null),
  (5, '7503008344617', 'FC-08344617', 'Vitamina E Progela 850 mg C/30', 'VITAMINA PROGELA', 2, 44.97, 57, 'marca', 'Vitaminas', 'Suplemento', 'Cápsula', 'Progela', 'Progela', 'Caja con 30 cápsulas', 'Vitamina E / aceite de germen de trigo', '850 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/progela-vitamina-e-850mg-c30-7503008344617.jpg', 'catalogo-propia/progela-vitamina-e-850mg-c30-7503008344617.jpg', '0040U'),
  (6, '7506313000377', 'FC-13000377', 'Acetona Madrid', 'ACETONA MADRID 4', 2, 10.00, 13, 'marca', 'Cuidado personal', 'Uñas', 'Acetona', 'Madrid', 'AMSA', null, null, null, false, false, null, null, '03-05-19'),
  (7, '7506313000810', 'FC-13000810', 'Aceite Madrid', 'MADRID ACEITE DE', 3, 11.98, 15, 'marca', 'Cuidado personal', 'Piel', 'Aceite', 'Madrid', 'AMSA', null, null, null, false, false, null, null, '03-05-19'),
  (8, '7506313000230', 'FC-13000230', 'Aceite Madrid', 'MADRID ACEITE DE', 3, 11.98, 15, 'marca', 'Cuidado personal', 'Piel', 'Aceite', 'Madrid', 'AMSA', null, null, null, false, false, null, null, '2712-017'),
  (9, '7506313000155', 'FC-13000155', 'Aceite Madrid', 'MADRID ACEITE DE', 3, 11.98, 15, 'marca', 'Cuidado personal', 'Piel', 'Aceite', 'Madrid', 'AMSA', null, null, null, false, false, null, null, '2712-017'),
  (10, '7506267905186', 'FC-67905186', 'Blumen jabón líquido Coconut 221 ml', 'JBN BLUMEN JL CP', 2, 17.69, 23, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 221 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/blumen-coconut-221ml.jpg', 'catalogo-propia/blumen-coconut-221ml.jpg', null),
  (11, '7506267905148', 'FC-67905148', 'Blumen jabón líquido Kiwi Starfruit 221 ml', 'JABON BLUMEN JL', 2, 17.69, 23, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 221 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/blumen-jabon-liquido-kiwi-221ml-7506267905148.jpg', 'catalogo-propia/blumen-jabon-liquido-kiwi-221ml-7506267905148.jpg', null),
  (12, '7506313000972', 'FC-13000972', 'Aceite Madrid', 'MADRID ACEITE DE', 3, 11.98, 15, 'marca', 'Cuidado personal', 'Piel', 'Aceite', 'Madrid', 'AMSA', null, null, null, false, false, null, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farma Mayoreo 306978 · 2026-09-28 · listo para pistola',
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
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_fm_306978
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_fm_306978
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_fm_306978
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '306978',
  '2026-09-28',
  539.74,
  'borrador',
  'Ticket Farma Mayoreo 306978 · 28-sep-2026 16:00 · CEDA · tarjeta · cola Recibir; stock al confirmar pistola · lote de fábrica en papel; MMAA de la caja · Aceite/Acetona Madrid: tipo/ml al escanear (ticket corta)'
where not exists (
  select 1 from public.recepciones
  where folio = '306978'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 539.74,
  fecha = '2026-09-28',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo 306978 · 28-sep-2026 16:00 · CEDA · tarjeta · cola Recibir; stock al confirmar pistola · lote de fábrica en papel; MMAA de la caja · Aceite/Acetona Madrid: tipo/ml al escanear (ticket corta)',
  updated_at = now()
where folio = '306978'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '306978'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_fm_306978 t
join public.recepciones r
  on r.folio = '306978'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_fm_306978
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '306978'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
order by i.id;
