-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Crea en Recibir (merge a GitHub NO los crea):
--   1) Nadro 6092065037 · 2026-11-08 · $1,507.27 · 3 renglones
--   2) Fanasa B49518623 · 2026-11-09 · $257.67 · 1 renglón
-- Sin bloques dollar-quote. Sin galeria extra. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Stock 0 hasta pistola + confirmar.
-- Al final: VERIFICACION con esos 2 folios en borrador.
-- Luego: tablet Recibir → recargar → aparecen las tarjetas.
-- =============================================================================


-- ========== NADRO 6092065037 ==========
-- Factura Nadro · 08-nov-2026 · CFDI 74991B89-39FB-4CF5-BFC6-BB6EBB4F7352
-- Subtotal $1,449.83 + IVA 16% $57.44 (solo Transvital) = $1,507.27
-- Costo = valor unitario (sin IVA). PVP = genérico ×1.60 / marca ×1.25.
-- Ficha de proveedor / packshot, no el código LGEN del ticket.

begin;

create temp table _fc_nd6092065037 (
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
  principio_activo text,
  concentracion text,
  receta boolean not null,
  imagen text
) on commit drop;

insert into _fc_nd6092065037 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '7501349029460', 'FC-49029460',
 'Diosmina Hesperidina 450/50 mg',
 'DIOSMIPHESPE 450/50MG 20TAB LGEN',
 1, 49.88, 80, 'generico', 'Medicamentos',
 'Cardiovascular', 'Tableta', 'AMSA', 'AMSA',
 'Caja con 20 tabletas', 'Diosmina / hesperidina', '450 mg / 50 mg', false,
 'https://www.farmacapital.mx/catalogo-propia/diosmina-hesperidina-450-50-20tab-7501349029460.jpg'),
(2, '7502235760276', 'FC-35760276',
 'Transvital D',
 'TRANSVITAL D 46.83G SUP ALIM 30CAPS',
 1, 358.97, 449, 'marca', 'Vitaminas',
 'Suplementos', 'Cápsula', 'Transvital', 'Exeltis',
 'Caja con 30 cápsulas', 'Omega-3 / extracto de verdolaga / vitaminas y minerales', null, false,
 'https://www.farmacapital.mx/catalogo-propia/transvital-d-30caps-7502235760276.jpg'),
(3, '7501101600630', 'FC-01600630',
 'Vaxtifen 20/160 mg',
 'VAXTIFEN 20/160 MG 30 TAB',
 1, 1040.98, 1302, 'marca', 'Medicamentos',
 'Lípidos', 'Tableta', 'Vaxtifen', 'Silanes',
 'Caja con 30 tabletas', 'Atorvastatina / fenofibrato', '20 mg / 160 mg', true,
 'https://www.farmacapital.mx/catalogo-propia/vaxtifen-20-160-30tab-7501101600630.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Nadro 6092065037 · 2026-11-08 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_nd6092065037 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_nd6092065037 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '(LGEN|DIOSMIPHESPE|SUP ALIM)'
      then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when t.receta then true else p.requiere_receta end
from _fc_nd6092065037 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6092065037',
  '2026-11-08',
  1507.27,
  'borrador',
  'Factura Nadro 6092065037 · 08-nov-2026 · Diosmina AMSA · Transvital D · Vaxtifen Silanes · $1,507.27 · CFDI 74991B89-39FB-4CF5-BFC6-BB6EBB4F7352 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6092065037' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1507.27,
  fecha = '2026-11-08',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6092065037 · 08-nov-2026 · Diosmina AMSA · Transvital D · Vaxtifen Silanes · $1,507.27 · CFDI 74991B89-39FB-4CF5-BFC6-BB6EBB4F7352 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6092065037'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6092065037'
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
from _fc_nd6092065037 t
join public.recepciones r
  on r.folio = '6092065037'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
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
where r.folio = '6092065037' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;


-- ========== FANASA B49518623 ==========
-- Factura Fanasa · 09-nov-2026 · pedido 57125564 · efectivo
-- Entrega FarmaCapital La Capi. Costo = PRECIO FARMACIA.
-- Meladinina (Chinoin). Lab ticket PRO = Productos Farmacéuticos Chinoin.
-- Packshot Farmasmart (mismo producto; su CDN lista EAN hermano 7501088542855).

begin;

create temp table _fc_fnb49518623 (
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
  principio_activo text,
  concentracion text,
  receta boolean not null,
  imagen text
) on commit drop;

insert into _fc_fnb49518623 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '7501088542865', 'FC-88542865',
 'Meladinina 10 mg',
 'MELADININA AMMOIDIN (METOXALENO) 10 mg 30 TAB',
 1, 257.67, 323, 'marca', 'Medicamentos',
 'Dermatológico', 'Tableta', 'Meladinina', 'Chinoin',
 'Caja con 30 tabletas', 'Metoxaleno (ammoidin)', '10 mg', false,
 'https://www.farmacapital.mx/catalogo-propia/meladinina-10mg-30tab-7501088542865.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Fanasa B49518623 · 2026-11-09 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_fnb49518623 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_fnb49518623 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* 'AMMOIDIN|METOXALENO'
      then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when t.receta then true else p.requiere_receta end
from _fc_fnb49518623 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Fanasa',
  'B49518623',
  '2026-11-09',
  257.67,
  'borrador',
  'Pedido Fanasa B49518623 · pedido 57125564 · 09-11-26 · $257.67 · Meladinina 10 mg · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'B49518623' and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = 257.67,
  fecha = '2026-11-09',
  proveedor = 'Fanasa',
  notas = 'Pedido Fanasa B49518623 · pedido 57125564 · 09-11-26 · $257.67 · Meladinina 10 mg · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'B49518623'
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'B49518623'
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
from _fc_fnb49518623 t
join public.recepciones r
  on r.folio = 'B49518623'
 and coalesce(r.proveedor, '') ilike '%fanasa%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
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
where r.folio = 'B49518623' and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;


-- VERIFICACION FINAL
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    (r.folio = '6092065037' and coalesce(r.proveedor, '') ilike '%nadro%')
    or (r.folio = 'B49518623' and coalesce(r.proveedor, '') ilike '%fanasa%')
  )
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;
