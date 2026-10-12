-- ═══════════════════════════════════════════════════════════════
-- TICKETS 12-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261012.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s330922.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Cityfarma Iztapalapa · orden S330922 · 2026-10-12 17:16
-- Ticket térmico. IVA 0%. Pagado tarjeta = $789.82.
-- Eutirox 25 mcg / 50 mcg C/50 (ticket dice «50 MG» = 50 mcg).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s330922 (
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

insert into _fc_cf_s330922 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501298234809', 'FC-98234809', 'Eutirox 25 mcg', 'EUTIROX 25MCG T50 AG', 3, 127.00, 159, 'marca', 'Medicamentos', null, 'Tableta', 'Eutirox', 'Merck', 'Caja con 50 tabletas', 'Levotiroxina sódica', '25 mcg', true, false, null, null, null),
  (2, '7501298234908', 'FC-98234908', 'Eutirox 50 mcg', 'EUTIROX 50 MG C 50 T', 2, 204.41, 256, 'marca', 'Medicamentos', null, 'Tableta', 'Eutirox', 'Merck', 'Caja con 50 tabletas', 'Levotiroxina sódica', '50 mcg', true, false, null, null, null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta Cityfarma Iztapalapa S330922 · 2026-10-12 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330922
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330922
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330922
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S330922',
  '2026-10-12',
  789.82,
  'borrador',
  'Ticket Cityfarma S330922 · 12-oct-2026 17:16 · foto térmica · pagado tarjeta $789.82 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S330922'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 789.82,
  fecha = '2026-10-12',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S330922 · 12-oct-2026 17:16 · foto térmica · pagado tarjeta $789.82 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S330922'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S330922'
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
  t.ean,
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
    )
  ),
  null
from _fc_cf_s330922 t
join public.recepciones r
  on r.folio = 'S330922'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_cf_s330922 t
join public.productos p on p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = 'S330922'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match,
  t.ya as marcado_ya
from _fc_cf_s330922 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s330971.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Cityfarma Iztapalapa · orden S330971 · 2026-10-12 17:14
-- Ticket térmico. IVA 0%. Pendiente de pago = $942.64.
-- Neurobión C/30 tabs + Neurobión DC inyección C/1.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s330971 (
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

insert into _fc_cf_s330971 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501298221397', 'FC-98221397', 'Neurobión', 'NEUROBION C30 TABS V', 2, 272.73, 341, 'marca', 'Vitaminas', null, 'Tableta', 'Neurobión', 'Procter & Gamble Health', 'Caja con 30 tabletas', 'Tiamina / piridoxina / cianocobalamina', '100 mg / 5 mg / 50 mcg', false, false, null, null, null),
  (2, '7501298223810', 'FC-98223810', 'Neurobión DC inyectable', 'NEUROBION DC INY C1', 2, 198.59, 249, 'marca', 'Vitaminas', null, 'Inyectable', 'Neurobión DC', 'Procter & Gamble Health', 'Caja con 1 jeringa prellenada doble cámara', 'Tiamina / piridoxina / cianocobalamina', '100 mg / 100 mg / 1 mg', true, false, null, null, null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta Cityfarma Iztapalapa S330971 · 2026-10-12 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330971
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330971
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s330971
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S330971',
  '2026-10-12',
  942.64,
  'borrador',
  'Ticket Cityfarma S330971 · 12-oct-2026 17:14 · foto térmica · Pendiente de pago $942.64 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S330971'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 942.64,
  fecha = '2026-10-12',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S330971 · 12-oct-2026 17:14 · foto térmica · Pendiente de pago $942.64 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S330971'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S330971'
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
  t.ean,
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
    )
  ),
  null
from _fc_cf_s330971 t
join public.recepciones r
  on r.folio = 'S330971'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_cf_s330971 t
join public.productos p on p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = 'S330971'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match,
  t.ya as marcado_ya
from _fc_cf_s330971 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_ifc_128440.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- IFC F8 Tienda · ticket 128440 · 2026-10-12 17:27 · cliente LUIS
-- Menudeo. 20 pzas / 3 productos · total $187.50.
-- Jarabe granada: código distribuidor 3311000001612 (Mayfar/DISA).
-- Pomada Manzana / Pan puerco: sin EAN público; match por SKU.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 1 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_ifc_128440 (
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

insert into _fc_ifc_128440 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '3311000001612', 'FC-DFF99C3F', 'Mercurio jarabe de granada', 'MERCURIO JARABE DE GRANADA C/25 1750827 84611', 10, 7.00, 9, 'marca', 'Cuidado personal', 'Bucal', 'Jarabe', 'Mercurio', 'Mercurio', 'Frasco 50 mL', null, null, false, true, 'https://acdn-us.mitiendanube.com/stores/004/824/171/products/mer128-8c5715a7144487dbd317373352570961-640-0.webp', null, null),
  (2, null, 'FC-MER-MANZANA', 'Mercurio pomada de manzana', 'MERCURIO POMADA MANZANA C/25 2530427 84404', 5, 10.50, 14, 'marca', 'Cuidado personal', 'Pomada', 'Pomada', 'Mercurio', 'Mercurio', 'Tarro 50 g', null, null, false, true, 'https://acdn-us.mitiendanube.com/stores/004/824/171/products/mer010-3391c4a7525545e5be17194451807817-640-0.webp', null, null),
  (3, '7506313000278', 'FC-MAD-PANPUERCO', 'Madrid pomada pan de puerco', 'MADRID POMADA PAN PUERCO C/25 2712017 D22', 5, 13.00, 17, 'marca', 'Cuidado personal', 'Pomada', 'Pomada', 'Madrid', 'Madrid', 'Tarro 50 g', null, null, false, false, null, null, null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta IFC F8 Tienda 128440 · 2026-10-12 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_128440
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_128440
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_128440
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '128440',
  '2026-10-12',
  187.50,
  'borrador',
  'Ticket IFC F8 128440 · 12-oct-2026 17:27 · MENUDEO · cliente LUIS · cola Recibir; stock al confirmar pistola · pomadas sin EAN GS1: ligar caja'
where not exists (
  select 1 from public.recepciones
  where folio = '128440'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 187.50,
  fecha = '2026-10-12',
  proveedor = 'IFC F8 Tienda',
  notas = 'Ticket IFC F8 128440 · 12-oct-2026 17:27 · MENUDEO · cliente LUIS · cola Recibir; stock al confirmar pistola · pomadas sin EAN GS1: ligar caja',
  updated_at = now()
where folio = '128440'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '128440'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
    )
  ),
  null
from _fc_ifc_128440 t
join public.recepciones r
  on r.folio = '128440'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_ifc_128440 t
join public.productos p on p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = '128440'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match,
  t.ya as marcado_ya
from _fc_ifc_128440 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_equilibrio_447795.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Equilibrio · ticket 447795 · 2026-10-12 17:09 · sucursal Iztapalapa 2
-- Pedido online WER-220084. Total $263.04 · 3 renglones / 8 pzas.
-- Claves EQF → EAN ficha/Levic/Sufarmed. Lote de fábrica sí.
-- Caducidad NO: MMAA de la caja. 0000 inválido.
-- SON098 FENIMETH → EAN 7502001164697 (EQ-SON096 en catálogo).
-- 1 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_447795 (
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

insert into _fc_eq_447795 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502001164413', 'EQ-SON220', 'Clotrimazol 500 mg óvulo', 'SON220 CLOTRIMAZOL 1 OV 500 MG', 3, 29.74, 48, 'generico', 'Medicamentos', null, 'Óvulo', 'Son''s', 'Son''s', 'Caja con 1 óvulo', 'Clotrimazol', '500 mg', true, true, null, null, '26061474'),
  (2, '7503000422863', 'EQ-MAV006', 'Cefalver cefalexina 500 mg', 'MAV006 CEFALVER 12 CAPS 500 MG', 3, 32.88, 53, 'generico', 'Medicamentos', null, 'Cápsula', 'Cefalver', 'Maver', 'Caja con 12 cápsulas', 'Cefalexina', '500 mg', true, false, null, null, '263343'),
  (3, '7502001164697', 'EQ-SON096', 'Fenimeth V metronidazol/nistatina', 'SON098 FENIMETH V 12 OVS 500MG/100,000 UI', 2, 37.59, 61, 'generico', 'Medicamentos', null, 'Óvulo', 'Fenimeth V', 'Son''s', 'Caja con 12 óvulos', 'Metronidazol / nistatina', '500 mg / 100,000 UI', true, true, null, null, '26030746');

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta Equilibrio 447795 · 2026-10-12 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_447795
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_447795
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_447795
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '447795',
  '2026-10-12',
  263.04,
  'borrador',
  'Ticket Equilibrio 447795 · pedido online WER-220084 · 12-oct-2026 · Iztapalapa 2 · 8 pzas · $263.04 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '447795'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 263.04,
  fecha = '2026-10-12',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 447795 · pedido online WER-220084 · 12-oct-2026 · Iztapalapa 2 · 8 pzas · $263.04 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '447795'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '447795'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
    )
  ),
  null
from _fc_eq_447795 t
join public.recepciones r
  on r.folio = '447795'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_eq_447795 t
join public.productos p on p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = '447795'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match,
  t.ya as marcado_ya
from _fc_eq_447795 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmalive_1537.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farmalive · ticket 1537 · 2026-10-12 16:59 · Club Iztapalapa 1
-- 20 renglones / 36 unidades. Papel: subtotal $2,842.01 − desc. $147.25 = $2,694.76 · tarjeta $2,697.78 (cambio $3).
-- Costo = P.U. neto del renglón a 2 decimales (importe impreso).
-- Tabcin Pods = 2PACK (EAN 7501008491157 / 7501008491140), no la caja suelta.
-- Levonorgestrel: 5 pzas + 1 promo $0.01 (igual que FarmaLive 12790).
-- 14 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_1537 (
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

insert into _fc_fl_1537 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501100088217', 'FC-00088217', 'Tylenol gotas infantiles', 'TYLENOL GOTAS 15 ML | JOHNSON JOHNSON', 1, 86.93, 109, 'marca', 'Medicamentos', null, 'Gotas', 'Tylenol', 'Johnson & Johnson', 'Frasco 15 mL', 'Paracetamol', null, false, false, null, null, null),
  (2, '7501088505829', 'FC-88505829', 'Troferit Flow jarabe', 'IV TROFERIT FLOW JARABE 120 ML | CHINOIN', 1, 188.70, 236, 'marca', 'Medicamentos', null, 'Jarabe', 'Troferit Flow', 'Chinoin', 'Frasco 120 mL', null, null, false, false, null, null, null),
  (3, '7501019036590', 'FC-19036590', 'Saba Buenas Noches Extra', 'TOA SANIT SABA BUENAS NOCHES EXTRA C/12 | ESSITY', 1, 43.04, 54, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Saba', 'Essity', 'Paquete con 12 toallas', null, null, false, false, null, null, null),
  (4, '7501019006104', 'FC-19006104', 'Saba Íntima Regular sin alas', 'TOA SANIT SABA INTIMA REG S/ALAS C/10 | SCA', 2, 13.59, 17, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toalla', 'Saba', 'Essity', 'Paquete con 10 toallas', null, null, false, false, null, null, null),
  (5, '7501008491157', 'FC-08491157', 'Tabcin Pods Noche 2-pack', 'TABCIN PODS NOCHE CAPS C/12 2PACK | BAYER OTC', 2, 115.20, 144, 'marca', 'Medicamentos', null, 'Cápsula', 'Tabcin', 'Bayer OTC', '2 empaques con 12 cápsulas cada uno', null, null, false, false, null, null, null),
  (6, '7501008491140', 'FC-08491140', 'Tabcin Pods Active 2-pack', 'TABCIN PODS ACTIVE CAPS C/12 2PACK | BAYER OTC', 2, 115.20, 144, 'marca', 'Medicamentos', null, 'Cápsula', 'Tabcin', 'Bayer OTC', '2 empaques con 12 cápsulas cada uno', null, null, false, false, null, null, null),
  (7, '7501836009661', 'FC-36009661', 'Dualgos paracetamol/ibuprofeno', 'DUALGOS TAB C/20 | LIFERPAL', 4, 29.20, 47, 'generico', 'Medicamentos', null, 'Tableta', 'Dualgos', 'Liferpal', 'Caja con 20 tabletas', 'Paracetamol / ibuprofeno', '325/200 mg', false, true, null, null, null),
  (8, '7501088505836', 'FC-88505836', 'Troferit Flow', 'IV TROFERIT FLOW TAB C/15 | CHINOIN', 1, 209.72, 263, 'marca', 'Medicamentos', null, 'Tableta', 'Troferit Flow', 'Chinoin', 'Caja con 15 tabletas', null, null, false, false, null, null, null),
  (9, '7501008485316', 'FC-08485316', 'Tabcin efervescente', 'TABCIN EFERV TAB C/12 | BAYER OTC', 2, 36.96, 47, 'marca', 'Medicamentos', null, 'Tableta efervescente', 'Tabcin', 'Bayer OTC', 'Caja con 12 tabletas', null, null, false, true, null, null, null),
  (10, '7501008485408', 'FC-08485408', 'Tabcin 500', 'TABCIN 500 TAB C/12 | BAYER OTC', 2, 45.12, 57, 'marca', 'Medicamentos', null, 'Tableta', 'Tabcin', 'Bayer OTC', 'Caja con 12 tabletas', null, '500 mg', false, true, null, null, null),
  (11, '7501019030048', 'FC-19030048', 'Tena Maxi Protec chico/mediano', 'PAÑAL TENA MAXI PROTEC CH/MED C/10 | ESSITY', 1, 152.00, 190, 'marca', 'Cuidado personal', 'Incontinencia', 'Pañal', 'Tena', 'Essity', 'Paquete con 10 piezas', null, null, false, false, null, null, null),
  (12, '7501100088170', 'FC-00088170', 'Tylenol suspensión infantil', 'TYLENOL SUSP INF 120 ML | JOHNSON JOHNSON', 1, 148.47, 186, 'marca', 'Medicamentos', null, 'Suspensión', 'Tylenol', 'Johnson & Johnson', 'Frasco 120 mL', 'Paracetamol', null, false, false, null, null, null),
  (13, '7501065008473', 'FC-5008473', 'Theraflu TD limón resfriado severo', 'THERAFLU VERDE SOB C/10 | HALEON', 2, 153.54, 192, 'marca', 'Medicamentos', null, 'Sobre', 'Theraflu', 'Haleon', 'Caja con 10 sobres', null, null, false, true, null, null, null),
  (14, '033200011309', 'FC-00011309', 'Arm & Hammer bicarbonato de sodio', 'BICARBONATO DE SODIO ARM & HAMMER 227 GR | CHURCH & DWIGHT', 2, 19.45, 25, 'marca', 'Cuidado personal', null, 'Polvo', 'Arm & Hammer', 'Church & Dwight', 'Caja 227 g', null, null, false, false, null, null, null),
  (15, '7501008495339', 'FC-08495339', 'Tabcin 500 exhibidor', 'TABCIN 500 TAB EXH C/60 | BAYER OTC', 1, 197.76, 248, 'marca', 'Medicamentos', null, 'Tableta', 'Tabcin', 'Bayer OTC', 'Exhibidor con 60 tabletas', null, '500 mg', false, false, null, null, null),
  (16, '7501008485378', 'FC-08485378', 'Tabcin efervescente exhibidor', 'TABCIN EFERV EXH TAB C/60 | BAYER OTC', 1, 151.68, 190, 'marca', 'Medicamentos', null, 'Tableta efervescente', 'Tabcin', 'Bayer OTC', 'Exhibidor con 60 tabletas', null, null, false, false, null, null, null),
  (17, '7501017362998', 'FC-73629981', 'Kleenex pañuelos pack', 'PAÑUELOS KLEENEX PACK C/8 | KIMBERLY CLARK', 2, 32.83, 42, 'marca', 'Cuidado personal', 'Higiene', 'Pañuelo', 'Kleenex', 'Kimberly-Clark', 'Pack con 8 paquetes', null, null, false, true, null, null, null),
  (18, '7501088509766', 'FC-85097661', 'Antiflu-Des Jr jarabe infantil', 'ANTIFLU-DES JR. JBE INF 60 ML | CHINOIN', 2, 118.94, 149, 'marca', 'Medicamentos', null, 'Jarabe', 'Antiflu-Des', 'Chinoin', 'Frasco 60 mL', null, null, false, true, null, null, null),
  (19, '7502214983375', 'FC-14983375', 'Levonorgestrel 1.5 mg Prudence', 'IV LEVONORGESTREL 1.5 MG TAB C/1 (PRUDENCE) | DKT MEXICO', 5, 19.60, 25, 'marca', 'Medicamentos', null, 'Tableta', 'Prudence', 'DKT México', 'Caja con 1 tableta', 'Levonorgestrel', '1.5 mg', false, false, null, null, null),
  (20, '7502214983375', 'FC-14983375', 'Levonorgestrel 1.5 mg Prudence', 'IV LEVONORGESTREL 1.5 MG TAB C/1 (PRUDENCE) promo | DKT', 1, 0.01, 1, 'marca', 'Medicamentos', null, 'Tableta', 'Prudence', 'DKT México', 'Caja con 1 tableta', 'Levonorgestrel', '1.5 mg', false, false, null, null, null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta Farmalive 1537 · 2026-10-12 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_1537
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_1537
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_fl_1537
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '1537',
  '2026-10-12',
  2694.79,
  'borrador',
  'Ticket Farmalive 1537 · Club Iztapalapa 1 · 12-oct-2026 16:59 · 20 artículos / 36 unidades · descuentos por renglón · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '1537'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 2694.79,
  fecha = '2026-10-12',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 1537 · Club Iztapalapa 1 · 12-oct-2026 16:59 · 20 artículos / 36 unidades · descuentos por renglón · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '1537'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '1537'
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
  t.ean,
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
    )
  ),
  null
from _fc_fl_1537 t
join public.recepciones r
  on r.folio = '1537'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_fl_1537 t
join public.productos p on p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = '1537'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA'
    else 'OK'
  end as match,
  t.ya as marcado_ya
from _fc_fl_1537 t
order by t.linea;

commit;
