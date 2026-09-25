-- ═══════════════════════════════════════════════════════════════
-- TICKETS 24-SEP-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20260924.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━ INICIO: patch_carga_cityfarma_s325583.sql ━━━

-- Cityfarma Iztapalapa · orden S325583 · 2026-09-24 17:14
-- Ticket térmico. Pendiente de pago $1,051.12 (= suma renglones; pie: sub $954.67 + IVA $96.45).
-- Barmicil EAN 7502001166066 · Hipebe 0.4 mg (ticket dice 4MG) · Menazan 7501573902720.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 3 alta(s) stock 0. 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s325583 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_cf_s325583 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '4015630064076', 'FC-30064076', 'Accu-Chek Active tiras reactivas C/50', 'ACCU CHEK C50 TIRAS', 1, 261.09, 327, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Tiras', 'Accu-Chek', 'Roche', 'Caja con 50 tiras', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/tiras-reactivas-accu-chek-active-50pzas-4015630064076.jpg', 'catalogo-propia/tiras-reactivas-accu-chek-active-50pzas-4015630064076.jpg', null),
  (2, '7501008494226', 'FC-08494226', 'Aspirina Junior ácido acetilsalicílico 100 mg C/60', 'ASPIRINA JR 100MG 60', 1, 65.59, 82, 'marca', 'Medicamentos', null, 'Tableta masticable', 'Aspirina', 'Bayer', 'Caja con 60 tabletas', 'Ácido acetilsalicílico', '100 mg', false, true, null, null, null),
  (3, '7502001166066', 'FC-01166066', 'Barmicil compuesto crema 40 g', 'BARMICIL 40G SONS BE', 5, 19.82, 25, 'marca', 'Medicamentos', null, 'Crema', 'Barmicil', 'Son''s', 'Tubo 40 g', 'Betametasona / Gentamicina / Clotrimazol', null, false, true, null, null, null),
  (4, '7502308871274', 'FC-08871274', 'Baumanómetro digital de muñeca HomeCare KF-75D Plus', 'BAUMA MUNECA KF 75DP', 1, 438.22, 548, 'marca', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 'HomeCare', null, '1 pieza', null, null, false, false, null, null, null),
  (5, '7501075710786', 'EQ-NOV004', 'Cirulan metoclopramida 10 mg C/20', 'CIRULAN 10MG C 20 TA', 4, 7.57, 13, 'generico', 'Medicamentos', null, 'Tableta', 'Cirulan', 'Novag', 'Caja con 20 tabletas', 'Metoclopramida', '10 mg', true, true, null, null, null),
  (6, '7502225094275', 'FC-25094275', 'Hipebe tamsulosina 0.4 mg C/20', 'HIPEBE O 4MG CAP C20', 4, 33.71, 54, 'generico', 'Medicamentos', null, 'Cápsula', 'Hipebe', 'Landsteiner', 'Caja con 20 cápsulas', 'Tamsulosina', '0.4 mg', true, false, null, null, null),
  (7, '7501573902720', 'FC-73902720', 'Menazan miconazol 2% crema 20 g', 'MENAZAN CRA 20G MICO', 2, 11.00, 18, 'generico', 'Medicamentos', null, 'Crema', 'Menazan', 'Biomep', 'Tubo 20 g', 'Nitrato de miconazol', '2%', false, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa S325583 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_cf_s325583
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_cf_s325583
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_cf_s325583
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S325583',
  '2026-09-24',
  1051.12,
  'borrador',
  'Ticket Cityfarma S325583 · 24-sep-2026 17:14 · foto térmica · Pendiente de pago $1,051.12 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S325583'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1051.12,
  fecha = '2026-09-24',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S325583 · 24-sep-2026 17:14 · foto térmica · Pendiente de pago $1,051.12 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'S325583'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S325583'
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
from _fc_cf_s325583 t
join public.recepciones r
  on r.folio = 'S325583'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_cf_s325583 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = 'S325583'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cf_s325583 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_cityfarma_s325583.sql ━━━


-- ━━━ INICIO: patch_carga_surtidor_134730.sql ━━━

-- El Surtidor de su Farmacia · venta 134730 · 2026-09-24 17:04
-- Ticket térmico. Total $152.01 (8 × $19.00; centavo del POS).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 0 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur_134730 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_sur_134730 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501677620056', 'FC-77620056', 'Agua destilada La Flor 1 L', 'AGUA DESTILADA LA FLOR 1 LT', 8, 19.00, 24, 'marca', 'Botiquín', null, 'Agua destilada', 'La Flor', null, '1 L', null, null, false, true, null, null, null);

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
  'Alta El Surtidor de su Farmacia 134730 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_sur_134730
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_sur_134730
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_sur_134730
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor de su Farmacia',
  '134730',
  '2026-09-24',
  152.01,
  'borrador',
  'Ticket El Surtidor 134730 · 24-sep-2026 17:04 · foto térmica · 8 pzas agua destilada · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '134730'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 152.01,
  fecha = '2026-09-24',
  proveedor = 'El Surtidor de su Farmacia',
  notas = 'Ticket El Surtidor 134730 · 24-sep-2026 17:04 · foto térmica · 8 pzas agua destilada · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '134730'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '134730'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
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
from _fc_sur_134730 t
join public.recepciones r
  on r.folio = '134730'
 and coalesce(r.proveedor, '') ilike '%surtidor%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_sur_134730 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = '134730'
  and coalesce(r.proveedor, '') ilike '%surtidor%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_sur_134730 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_surtidor_134730.sql ━━━


-- ━━━ INICIO: patch_carga_equilibrio_445679.sql ━━━

-- Equilibrio · ticket 445679 · 2026-09-24 17:28 · sucursal Iztapalapa 2
-- Pedido online. Subtotal $832.78 + IVA $42.74 = $875.52 · 10 renglones / 22 pzas.
-- Foto partida (inicio + continuación). P.U. = costo neto post-descuento.
-- Lote de fábrica sí. Caducidad NO: Recibir pide MMAA de la caja. 0000 inválido.
-- 0 alta(s) stock 0. 10 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_445679 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_eq_445679 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502214985805', 'FC-14985805', 'Prudence Chicle condones C/5', 'DKT040 PRUDENCE CHICLE 1 CAJA 5 PZAS', 2, 46.57, 59, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 5 piezas', null, null, false, true, null, null, 'PB563201'),
  (2, '7503004908738', 'FC-04908738', 'Lidocaína unguento 5% tubo 35 g', 'ALP0380 LIDOCAINA 1 UNG 5% 35 G', 4, 23.33, 38, 'generico', 'Medicamentos', null, 'Ungüento', 'Alpharma', 'Alpharma', 'Tubo 35 g', 'Lidocaína', '5%', false, true, null, null, '2606516'),
  (3, '7501075723137', 'FC-75723137', 'Novakosid senósidos A-B 8.6 mg C/20', 'NOV138 NOVAKOSID 20 TAB 8.6 MG', 5, 13.93, 23, 'generico', 'Medicamentos', null, 'Tableta', 'Novakosid', 'Novag', 'Caja con 20 tabletas', 'Senósidos A-B', '8.6 mg', false, true, null, null, '540286'),
  (4, '7502009748912', 'EQ-MAV380', 'Esomeprazol 40 mg C/14', 'MAV380 ESOMEPRAZOL 14 TAB 40 MG', 2, 51.65, 83, 'generico', 'Medicamentos', null, 'Tableta', 'Maver', 'Maver', 'Caja con 14 tabletas', 'Esomeprazol', '40 mg', true, true, null, null, '263687'),
  (5, '0780083144302', 'FC-83144302', 'Collifrin Adulto oximetazolina 0.05% 20 mL', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 3, 33.69, 54, 'generico', 'Medicamentos', null, 'Solución nasal', 'Collifrin', 'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', false, true, null, null, '26140881'),
  (6, '7502214982491', 'FC-49824911', 'Prudence Uva condones C/3', 'DKT009 PRUDENCE UVA 1 CJA 3 PZAS', 1, 34.48, 44, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'PG577501'),
  (7, '7502214980275', 'FC-4980275', 'Prudence Soda condones C/3', 'DKT063 PRUDENCE SODA 1 CJA 3 PZA', 1, 32.96, 42, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'BC503404'),
  (8, '7502214982514', 'FC-14982514', 'Prudence Chocolate condones C/3', 'DKT008 PRUDENCE CHOCOLATE 1 CJA 3 PZAS', 1, 34.14, 43, 'marca', 'Cuidado personal', 'Higiene', 'Condón', 'Prudence', 'DKT', 'Caja con 3 piezas', null, null, false, true, null, null, 'BCH508001'),
  (9, '7502214983207', 'FC-14983207', 'Prudence lubricante uva 75 mL', 'DKT023 LUBRICANTE UVA 1 GEL 75 ML', 1, 72.42, 91, 'marca', 'Cuidado personal', 'Higiene', 'Gel', 'Prudence', 'DKT', 'Frasco 75 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/prudence-lub-uva-75ml.jpg', 'catalogo-propia/prudence-lub-uva-75ml.jpg', '3P186057'),
  (10, '7502009749292', 'EQ-MAV415', 'Esomeprazol 40 mg C/28', 'MAV415 ESOMEPRAZOL 28 TAB 40 MG', 2, 99.15, 159, 'generico', 'Medicamentos', null, 'Tableta', 'Maver', 'Maver', 'Caja con 28 tabletas', 'Esomeprazol', '40 mg', true, true, null, null, '263551');

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
  'Alta Equilibrio 445679 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_eq_445679
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_eq_445679
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_eq_445679
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '445679',
  '2026-09-24',
  875.52,
  'borrador',
  'Ticket Equilibrio 445679 · Iztapalapa 2 · 24-sep-2026 17:28 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '445679'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 875.52,
  fecha = '2026-09-24',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 445679 · Iztapalapa 2 · 24-sep-2026 17:28 · pedido online · cliente 307513 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '445679'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '445679'
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
from _fc_eq_445679 t
join public.recepciones r
  on r.folio = '445679'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_eq_445679 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = '445679'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_445679 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_equilibrio_445679.sql ━━━


-- ━━━ INICIO: patch_carga_farmamayoreo_306277.sql ━━━

-- Farma Mayoreo · ID VENTA 306277 · 2026-09-24 16:35 · Central de Abastos
-- Ticket térmico partido (3 fotos). Subtotal $2,841.58 + impuestos $136.85 = $2,978.43.
-- P.U. ya trae IVA (suma renglones = total). Kotex Unika EAN 7506425625536 (línea sobreimpresa).
-- Oral-B Stages: Toy Story+Princesas comparten EAN 3014260279264 (×2); Frozen es 3014260278922 (×1).
-- Lote de fábrica del papel cuando es legible. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 23 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm_306277 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_fm_306277 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '3014260279264', 'FC-60279264', 'Oral-B Stages cepillo dental infantil 3+ Disney/Pixar', 'ORAL B CEPILLO S', 2, 51.83, 65, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Oral-B', 'P&G', '1 pieza', null, null, false, false, null, null, '6041833520'),
  (2, '3014260278922', 'FC-60278922', 'Oral-B Stages cepillo dental infantil 3+ Frozen', 'ORAL B CEPILLO F', 1, 50.97, 64, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Oral-B', 'P&G', '1 pieza', null, null, false, false, null, null, '6037833520'),
  (3, '7501050623766', 'FC-05062376', 'Afrin No Drip solución nasal 15 mL', 'AFRIN NODRIP CSE', 2, 107.90, 135, 'marca', 'Medicamentos', null, 'Solución nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, '2601390'),
  (4, '7501050624732', 'FC-06247327', 'Afrin No Drip spray nasal extra humectante 15 mL', 'AFRIN NODRIP SPR', 2, 101.98, 128, 'marca', 'Medicamentos', null, 'Spray nasal', 'Afrin', 'Bayer', 'Frasco 15 mL', 'Oximetazolina', null, false, true, null, null, '251279EA'),
  (5, '7500435246309', 'FC-35246309', 'Vick Drops jengibre pastillas C/20', 'VICK DROPS SABOR', 1, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'C/20', null, null, false, true, null, null, '516202'),
  (6, '7509546072272', 'FC-46072272', 'Colgate Kids pasta dental', 'COLGATE CD KIDS', 1, 24.98, 32, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, '516202'),
  (7, '7891024034095', 'FC-24034095', 'Colgate Kids pasta dental (import)', 'COLGATE CD KIDS', 1, 20.95, 27, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, '4268'),
  (8, '7501054550150', 'FC-54550150', 'Curitas animales apósitos adhesivos', 'CURITAS ANIMALES', 1, 45.98, 58, 'marca', 'Botiquín', 'Material de curación', 'Apósito', 'Curitas', 'Johnson & Johnson', 'Caja', null, null, false, false, null, null, '4268'),
  (9, '7501048623044', 'FC-48623044', 'Pads faciales Protec con glicerina', 'PADS FACIALES PR', 1, 28.50, 36, 'marca', 'Cuidado personal', 'Higiene', 'Pads', 'Protec', null, 'Bolsa', null, null, false, false, null, null, '52647'),
  (10, '7501943490598', 'FC-43490598', 'Jabón líquido Escudo para manos', 'JBN LIQ ESCUDO P', 4, 28.00, 35, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Escudo', 'P&G', null, null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/escudo-jabon-liquido.jpg', 'catalogo-propia/escudo-jabon-liquido.jpg', null),
  (11, '7590002037843', 'FC-02037843', 'Vick Pyrena miel jarabe', 'VICK PYRENA MIEL', 2, 89.98, 113, 'marca', 'Medicamentos', null, 'Jarabe', 'Vick', 'P&G', 'Frasco', null, null, false, false, null, null, '60494354U0'),
  (12, '7501125100116', 'FC-25100116', 'Solución CS Pisa cloruro de sodio 0.9% 250 mL', 'SOLUCION CLORURO', 4, 26.90, 44, 'generico', 'Medicamentos', null, 'Solución', 'CS Pisa', 'Pisa', 'Frasco 250 mL', 'Cloruro de sodio', '0.9%', false, true, null, null, 'P26Y317'),
  (13, '7501125115479', 'FC-25115479', 'Solución CS Pisa cloruro de sodio 0.9% 100 mL', 'SOLUCION CLORURO', 3, 22.98, 37, 'generico', 'Medicamentos', null, 'Solución', 'CS Pisa', 'Pisa', 'Frasco 100 mL', 'Cloruro de sodio', '0.9%', false, false, null, null, 'V26J530'),
  (14, '7503017500769', 'FC-17500769', 'Jabón líquido para manos (variante A)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '437032'),
  (15, '7503017500776', 'FC-17500776', 'Jabón líquido para manos (variante B)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '439036'),
  (16, '7503017500783', 'FC-17500783', 'Jabón líquido para manos (variante C)', 'JABON LIQUIDO PA', 1, 16.91, 22, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', null, null, 'Botella', null, null, false, false, null, null, '438033'),
  (17, '7501088509766', 'FC-85097661', 'Antiflu-Des Junior jarabe infantil 60 mL', 'ANTIFLUDES SOL J', 3, 124.98, 157, 'marca', 'Medicamentos', null, 'Jarabe', 'Antiflu-Des', 'Chinoin', 'Frasco 60 mL', null, null, false, true, null, null, 'BFB081'),
  (18, '7501065085191', 'FC-65085191', 'Voltaren Emulgel diclofenaco 1% 50 g', 'VOLTAREN EMULGEL', 1, 76.98, 97, 'marca', 'Medicamentos', null, 'Gel', 'Voltaren', 'GSK', 'Tubo 50 g', 'Diclofenaco', '1%', false, false, null, null, 'UC2L'),
  (19, '7501088509810', 'FL-8509810', 'Antiflu-Des pediátrico solución 30 mL', 'ANTIFLUDES SOL P', 1, 138.98, 174, 'marca', 'Medicamentos', null, 'Solución', 'Antiflu-Des', 'Chinoin', 'Frasco 30 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'BEK114'),
  (20, '7501065024688', 'FC-65024688', 'Voltaren Dolo 25 mg C/20', 'VOLTAREN DOLO 25', 1, 195.98, 245, 'marca', 'Medicamentos', null, 'Tableta', 'Voltaren', 'GSK', 'Caja con 20 tabletas', 'Diclofenaco', '25 mg', false, false, null, null, '35826'),
  (21, '7501065085528', 'FC-65085528', 'Voltaren Emulgel diclofenaco 1% 100 g', 'VOLTAREN EMULGEL', 1, 111.98, 140, 'marca', 'Medicamentos', null, 'Gel', 'Voltaren', 'GSK', 'Tubo 100 g', 'Diclofenaco', '1%', false, false, null, null, 'F19T'),
  (22, '7509546068558', 'FC-46068558', 'Colgate cepillo dental', 'COLGATE CEPILLO', 2, 45.98, 58, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Colgate', null, '1 pieza', null, null, false, false, null, null, null),
  (23, '7509546079493', 'FC-46079493', 'Colgate cepillos dentales (pack)', 'COLGATE CEPILLOS', 2, 30.97, 39, 'marca', 'Cuidado personal', 'Bucal', 'Cepillo', 'Colgate', null, 'Pack', null, null, false, false, null, null, null),
  (24, '7509546066776', 'FC-46066776', 'Colgate crema dental', 'COLGATE CREMA DE', 3, 45.98, 58, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, null),
  (25, '7500435246293', 'FC-35246293', 'Vick Drops caramelo mentol pastillas', 'DROPS CARAMELO M', 2, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'Caja', null, null, false, false, null, null, '505700'),
  (26, '7500435246286', 'FC-35246286', 'Vick Drops caramelo mentol pastillas (lote B)', 'DROPS CARAMELO M', 2, 37.98, 48, 'marca', 'Botiquín', null, 'Pastilla', 'Vick', 'P&G', 'Caja', null, null, false, false, null, null, '514101'),
  (27, '7501943493940', 'FC-43493940', 'Toallitas húmedas Escudo', 'TAS HUMEDAS ESC', 3, 12.98, 17, 'marca', 'Cuidado personal', 'Higiene', 'Toallitas', 'Escudo', 'P&G', 'Paquete', null, null, false, false, null, null, null),
  (28, '7506425625536', 'FC-25625536', 'Kotex Unika tampones regular C/12', 'KOTEX TAMPONES R', 2, 32.50, 41, 'marca', 'Cuidado personal', 'Higiene íntima', 'Tampones', 'Kotex', null, 'Caja con 12', null, null, false, false, null, null, null),
  (29, '7501417515956', 'FC-17515956', 'Bocasan Econopack polvo', 'BOCASAN ECONOPA', 2, 60.95, 77, 'marca', 'Cuidado personal', 'Bucal', 'Polvo', 'Bocasan', null, 'Caja', null, null, false, false, null, null, '25D03'),
  (30, '7506195102640', 'FC-95102640', 'Vick Pyrena manzana jarabe', 'VICK PYRENA MANZ', 2, 78.98, 99, 'marca', 'Medicamentos', null, 'Jarabe', 'Vick', 'P&G', 'Frasco', null, null, false, false, null, null, '008435400');

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
  'Alta Farma Mayoreo 306277 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_fm_306277
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_fm_306277
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_fm_306277
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '306277',
  '2026-09-24',
  2978.43,
  'borrador',
  'Ticket Farma Mayoreo 306277 · Central · 24-sep-2026 16:35 · tarjeta · 30 arts / 55 pzas · foto en 3 partes (sobreimpresión en Colgate/Kotex) · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '306277'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 2978.43,
  fecha = '2026-09-24',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo 306277 · Central · 24-sep-2026 16:35 · tarjeta · 30 arts / 55 pzas · foto en 3 partes (sobreimpresión en Colgate/Kotex) · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '306277'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '306277'
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
from _fc_fm_306277 t
join public.recepciones r
  on r.folio = '306277'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_fm_306277 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = '306277'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fm_306277 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_farmamayoreo_306277.sql ━━━


-- ━━━ INICIO: patch_carga_farmalive_13395.sql ━━━

-- Farmalive · ticket 13395 · 2026-09-24 16:52 · Club Iztapalapa 1
-- Total $1,359.31 · 18 artículos / 46 unidades · tarjeta crédito.
-- Foto partida (inicio + pie). Costo = P.U. neto post-descuento.
-- Suerox naranja-mango: EAN botella 7501048607214 (no el 650… interno).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 11 alta(s) stock 0. 7 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_13395 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_fl_13395 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '6502400721541', 'FC-00721541', 'Suerox Vitamins manzana y limón 630 mL', 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (2, '6502400663068', 'FC-40066306', 'Suerox 8 iones fresa 630 mL', 'SUEROX 8 IONES FRESA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (3, '7501048607214', 'FC-00721471', 'Suerox Vitamins naranja-mango 630 mL', 'SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (4, '7501033956690', 'FC-33956690', 'Pedialyte SR45 fresa 500 mL', 'PEDIALYTE SR45 FRESA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (5, '7501033954740', 'FC-33954740', 'Pedialyte SR60 manzana 500 mL', 'PEDIALYTE SR60 MANZANA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (6, '7501033956775', 'FC-33956775', 'Pedialyte SR60 uva 500 mL', 'PEDIALYTE SR60 UVA 500 ML | ABBOTT', 2, 23.81, 30, 'marca', 'Bebidas', 'Electrolitos', 'Suero oral', 'Pedialyte', 'Abbott', 'Frasco 500 mL', null, null, false, true, null, null, null),
  (7, '7509546058962', 'FC-46058962', 'Caprice Naturals sábila spray 316 mL', 'SPRAY CAPRICE NATURALS SABILA 316 ML | COLGATE PALMOLIVE', 1, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (8, '7509546058979', 'FC-46058979', 'Caprice algas spray 316 mL', 'SPRAY CAPRICE ALGAS 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (9, '7509546058986', 'FC-46058986', 'Caprice kiwi lavanda spray 316 mL', 'SPRAY CAPRICE KIWI LAVANDA 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (10, '7509546059006', 'FC-46059006', 'Caprice granada spray 316 mL', 'SPRAY CAPRICE GRANADA 316 ML | COLGATE PALMOLIVE', 2, 48.80, 61, 'marca', 'Cuidado personal', 'Capilar', 'Spray', 'Caprice', 'Colgate-Palmolive', '316 mL', null, null, false, false, null, null, null),
  (11, '7891024179925', 'FC-24179925', 'Colgate PerioGard enjuague bucal 250 mL', 'ENJ BUCAL COLGATE PERIO GARD 250 ML | COLGATE PALMOLIVE', 1, 182.28, 228, 'marca', 'Cuidado personal', 'Bucal', 'Enjuague', 'Colgate', 'Colgate-Palmolive', '250 mL', null, null, false, false, null, null, null),
  (12, '7502275701659', 'FC-75701659', 'Cubrebocas Alfa Medical kids azul C/10', 'CUBREBOCAS ALFA MEDICAL KIDS AZUL C/10 | ALFA MEDICAL', 2, 22.05, 28, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Alfa Medical', null, 'C/10', null, null, false, false, null, null, null),
  (13, '7501048780235', 'FC-48780235', 'Cubrebocas Protec plegado C/10', 'CUBREBOCAS PROTEC PLEGADO C/10 | DEGASA', 1, 18.03, 23, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Protec', 'Degasa', 'C/10', null, null, false, false, null, null, null),
  (14, '7502275701642', 'FC-75701642', 'Cubrebocas Alfa Medical kids rosa C/10', 'CUBREBOCAS KIDS ROSA BOLSA C/10 | ALFA MEDICAL', 2, 22.05, 28, 'marca', 'Botiquín', 'Material de curación', 'Cubrebocas', 'Alfa Medical', null, 'C/10', null, null, false, false, null, null, null),
  (15, '7501868902008', 'FC-68902008', 'Venda Dibar 5 cm', 'VENDA DIBAR 5 CM | DIBAR', 3, 7.15, 9, 'marca', 'Botiquín', 'Material de curación', 'Venda', 'Dibar', null, '5 cm', null, null, false, false, null, null, null),
  (16, '7702018072439', 'FC-18072439', 'Gillette Simply Venus 3 mujer C/1', 'RASTRILLO GILLETTE SIMPLY VENUS 3 MUJ C/1 | PG PERF', 4, 18.23, 23, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', 'C/1', null, null, false, false, null, null, null),
  (17, '7500435011303', 'FC-35011303', 'Gillette Prestobarba Ultra Grip3 C/1', 'RASTRILLO PRESTOBARBA ULTRA GRIP3 C/1 | PG PERF', 12, 20.78, 26, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', 'C/1', null, null, false, false, null, null, null),
  (18, '7702018874729', 'FC-18874729', 'Gillette Prestobarba3 hombre 2-pack', 'RAST GILLETTE PRESTOBARBA3 HOMBRE 2PACK | PG PERF', 2, 77.13, 97, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Gillette', 'P&G', '2-pack', null, null, false, true, null, null, null);

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
  'Alta Farmalive 13395 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_fl_13395
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_fl_13395
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_fl_13395
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '13395',
  '2026-09-24',
  1359.31,
  'borrador',
  'Ticket Farmalive 13395 · Club Iztapalapa 1 · 24-sep-2026 16:52 · precio neto (2–5% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '13395'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1359.31,
  fecha = '2026-09-24',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 13395 · Club Iztapalapa 1 · 24-sep-2026 16:52 · precio neto (2–5% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '13395'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '13395'
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
from _fc_fl_13395 t
join public.recepciones r
  on r.folio = '13395'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_fl_13395 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = '13395'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_13395 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_farmalive_13395.sql ━━━


-- ━━━ INICIO: patch_carga_nadro_605425063.sql ━━━

-- Nadro · factura 605425063 · 2026-09-24 · sucursal México Sur
-- CFDI · subtotal $341.45 + IVA 16% $41.97 = $383.42 · 2 renglones / 2 pzas.
-- Costo = valor unitario (PR FAR). Ureadin lleva IVA; Nido IVA 0%.
-- Ureadin lote fábrica L022029 (del CFDI). Caducidad NO: MMAA de la caja. 0000 inválido.
-- Ficha: Nido Nestlé · Isdin Ureadin Ultra 20 (no el código del renglón).
-- 0 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_605425063 (
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
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_nd_605425063 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501059225411', 'FC-59225411', 'Nido Kinder 1+ leche en polvo 360 g', 'NIDO KINDER 1+ LECHE 360 G', 1, 79.16, 99, 'marca', 'Nutrición', 'Fórmula láctea', 'Polvo', 'Nido', 'Nestlé', 'Bolsa 360 g', null, null, false, true, null, null, null),
  (2, '8470001541871', 'FC-01541871', 'Isdin Ureadin Ultra 20 crema anti-rugosidades 100 ml', 'UREADIN ULTRA 20CRA ANTI-RUG100ML', 1, 262.29, 328, 'marca', 'Cuidado personal', 'Dermatología', 'Crema', 'Ureadin', 'Isdin', 'Tubo 100 ml', null, null, false, true, null, null, 'L022029');

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
  'Alta Nadro 605425063 · 2026-09-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_nd_605425063
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
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
  select distinct on (ean) *
  from _fc_nd_605425063
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
  select distinct on (ean) *
  from _fc_nd_605425063
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '605425063',
  '2026-09-24',
  383.42,
  'borrador',
  'Factura Nadro 605425063 · México Sur · 24-sep-2026 · entrega FarmaCapital · efectivo · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '605425063'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 383.42,
  fecha = '2026-09-24',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 605425063 · México Sur · 24-sep-2026 · entrega FarmaCapital · efectivo · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '605425063'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '605425063'
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
from _fc_nd_605425063 t
join public.recepciones r
  on r.folio = '605425063'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
from _fc_nd_605425063 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
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
where r.folio = '605425063'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_nd_605425063 t
order by t.linea;

commit;


-- ━━━ FIN: patch_carga_nadro_605425063.sql ━━━


-- ━━━ INICIO: patch_carga_ifc_125448.sql ━━━

-- IFC F8 Tienda · folio 125448 · 2026-09-24
-- Códigos IFC del ticket NO son EAN GS1 (salvo Tensolastic 7501048690909).
-- Altas stock 0. Pegar en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-83733 | Dibar venda cohesiva 7.5 cm colores C/24
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Dibar venda cohesiva 7.5 cm colores C/24',
  'FC-IFC-83733',
  null,
  'Botiquín',
  'marca',
  'Ticket IFC 125448 · DIBAR VENDA 7.5 CM COLORES C/24 5C025C02 83733',
  318.00, 398, 0, 1, true, false,
  'Dibar',
  'Paquete C/24',
  'Venda',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-83733') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-83733');

update public.productos set
  costo = 318.00,
  precio = case when coalesce(precio, 0) <= 0 then 398 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Dibar'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Paquete C/24'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-83733'
;

-- FC-48690909 | Venda elástica Protec Tensolastic Plus 7 cm × 5 m
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Venda elástica Protec Tensolastic Plus 7 cm × 5 m',
  'FC-48690909',
  '7501048690909',
  'Botiquín',
  'marca',
  'Ticket IFC 125448 · PROTEC VENDA TENSOLASTIC PLUS 7CMX5M 2A301071 83217',
  21.50, 27, 0, 1, true, false,
  'Protec',
  '7 cm × 5 m',
  'Venda',
  null
where public.fc_buscar_producto_escaneo('7501048690909') is null
  and not exists (select 1 from public.productos where sku = 'FC-48690909');

update public.productos set
  costo = 21.50,
  precio = case when coalesce(precio, 0) <= 0 then 27 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Protec'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '7 cm × 5 m'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Venda'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-48690909'
   or codigo_barras = '7501048690909';

commit;


-- ━━━ FIN: patch_carga_ifc_125448.sql ━━━


-- ━━━ INICIO: patch_recepcion_ifc_125448.sql ━━━

-- Pedido IFC F8 Tienda 125448 (2026-09-24) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_ifc125448 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_ifc125448 (linea, ean, sku, nombre, qty, costo) values
  (1, null, 'FC-IFC-83733', 'Dibar venda cohesiva 7.5 cm colores C/24', 1, 318.00),
  (2, '7501048690909', 'FC-48690909', 'Venda elástica Protec Tensolastic Plus 7 cm × 5 m', 4, 21.50);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '125448',
  '2026-09-24',
  404.00,
  'borrador',
  'Farma Centre / IFC F8 Tienda · folio 125448 · 2026-09-24 16:47 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '125448' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 404.00,
  fecha = '2026-09-24',
  proveedor = 'IFC F8 Tienda',
  notas = 'Farma Centre / IFC F8 Tienda · folio 125448 · 2026-09-24 16:47 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '125448'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '125448'
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
from _fc_rx_ifc125448 t
join public.recepciones r
  on r.folio = '125448'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;

commit;

-- Diagnóstico: si renglones = 0 y estado <> borrador → ya estaba cerrada.
-- Si 0 filas → no se insertó (revisa error arriba).
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '125448'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '125448' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;


-- ━━━ FIN: patch_recepcion_ifc_125448.sql ━━━


-- ━━━ INICIO: patch_carga_ifc_125445.sql ━━━

-- IFC F8 Tienda · folio 125445 · 2026-09-24
-- Códigos IFC del ticket NO son EAN GS1 (salvo Tensolastic 7501048690909).
-- Altas stock 0. Pegar en Supabase → SQL Editor → Run.

begin;

-- FC-IFC-1570818 | Mercurio magnesia calcinada C/50
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio magnesia calcinada C/50',
  'FC-IFC-1570818',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO MAGNESIA CALCINADA C/50 1570818 06AGO25',
  55.50, 70, 0, 1, true, false,
  'Mercurio',
  'C/50',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1570818') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1570818');

update public.productos set
  costo = 55.50,
  precio = case when coalesce(precio, 0) <= 0 then 70 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1570818'
;

-- FC-IFC-ESPEJITO | Espejito redondo económico
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Espejito redondo económico',
  'FC-IFC-ESPEJITO',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · ESPEJITO REDONDO ECONOMICO',
  6.00, 8, 0, 1, true, false,
  null,
  'Pieza',
  'Accesorio',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-ESPEJITO') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-ESPEJITO');

update public.productos set
  costo = 6.00,
  precio = case when coalesce(precio, 0) <= 0 then 8 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Accesorio'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-ESPEJITO'
;

-- FC-IFC-PARCHE-ACNE | Parches para acné hidrocoloide
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Parches para acné hidrocoloide',
  'FC-IFC-PARCHE-ACNE',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · PARCHES P/ACNE FIGS HIDROCOLOIDE',
  16.50, 21, 0, 1, true, false,
  null,
  'Pieza',
  'Parche',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-PARCHE-ACNE') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-PARCHE-ACNE');

update public.productos set
  costo = 16.50,
  precio = case when coalesce(precio, 0) <= 0 then 21 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), null),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'Pieza'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Parche'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-PARCHE-ACNE'
;

-- FC-IFC-82912 | Benzal Wash líquido 240 mL
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Benzal Wash líquido 240 mL',
  'FC-IFC-82912',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · BENZAL WASH LIQUIDO 240ML R101100 82912',
  102.50, 129, 0, 1, true, false,
  'Benzal',
  '240 mL',
  'Jabón líquido',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-82912') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-82912');

update public.productos set
  costo = 102.50,
  precio = case when coalesce(precio, 0) <= 0 then 129 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Benzal'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), '240 mL'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Jabón líquido'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-82912'
;

-- FC-IFC-1490724 | Mercurio rosa de Castilla C/50
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio rosa de Castilla C/50',
  'FC-IFC-1490724',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ROSA DE CASTILLA C/50 1490724 83490',
  75.00, 94, 0, 1, true, false,
  'Mercurio',
  'C/50',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1490724') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1490724');

update public.productos set
  costo = 75.00,
  precio = case when coalesce(precio, 0) <= 0 then 94 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1490724'
;

-- FC-IFC-1330723 | Mercurio almidón cajita C/10
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio almidón cajita C/10',
  'FC-IFC-1330723',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ALMIDON CAJITA C/10 1330723 83125',
  91.50, 115, 0, 1, true, false,
  'Mercurio',
  'C/10',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1330723') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1330723');

update public.productos set
  costo = 91.50,
  precio = case when coalesce(precio, 0) <= 0 then 115 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/10'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1330723'
;

-- FC-IFC-1660824 | Mercurio anís estrella C/25
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio anís estrella C/25',
  'FC-IFC-1660824',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO ANIS ESTRELLA C/25 1660824 83521',
  131.00, 164, 0, 1, true, false,
  'Mercurio',
  'C/25',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1660824') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1660824');

update public.productos set
  costo = 131.00,
  precio = case when coalesce(precio, 0) <= 0 then 164 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/25'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1660824'
;

-- FC-IFC-1400724 | Mercurio bórax polvo C/50
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio bórax polvo C/50',
  'FC-IFC-1400724',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO BORAX POLVO C/50 1400724',
  53.00, 67, 0, 1, true, false,
  'Mercurio',
  'C/50',
  'Polvo',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-1400724') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-1400724');

update public.productos set
  costo = 53.00,
  precio = case when coalesce(precio, 0) <= 0 then 67 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/50'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-1400724'
;

-- FC-IFC-PULEFIN100 | Lima de uñas Pulefin C/100
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Lima de uñas Pulefin C/100',
  'FC-IFC-PULEFIN100',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · LIMA UNAS PULEFIN C/100',
  94.50, 119, 0, 1, true, false,
  'Pulefin',
  'C/100',
  'Lima',
  null
where public.fc_buscar_producto_escaneo('FC-IFC-PULEFIN100') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-PULEFIN100');

update public.productos set
  costo = 94.50,
  precio = case when coalesce(precio, 0) <= 0 then 119 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Pulefin'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/100'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Lima'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), null)
where sku = 'FC-IFC-PULEFIN100'
;

-- FC-IFC-82943 | Mercurio pomada manzana C/25
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  'Mercurio pomada manzana C/25',
  'FC-IFC-82943',
  null,
  'Cuidado personal',
  'marca',
  'Ticket IFC 125445 · MERCURIO POMADA MANZANA C/25 2530123 82943',
  9.50, 12, 0, 1, true, false,
  'Mercurio',
  'C/25',
  'Pomada',
  'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg'
where public.fc_buscar_producto_escaneo('FC-IFC-82943') is null
  and not exists (select 1 from public.productos where sku = 'FC-IFC-82943');

update public.productos set
  costo = 9.50,
  precio = case when coalesce(precio, 0) <= 0 then 12 else precio end,
  marca = coalesce(nullif(btrim(marca), ''), 'Mercurio'),
  presentacion = coalesce(nullif(btrim(presentacion), ''), 'C/25'),
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Pomada'),
  imagen_url = coalesce(nullif(btrim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg')
where sku = 'FC-IFC-82943'
;

commit;


-- ━━━ FIN: patch_carga_ifc_125445.sql ━━━


-- ━━━ INICIO: patch_recepcion_ifc_125445.sql ━━━

-- Pedido IFC F8 Tienda 125445 (2026-09-24) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_ifc125445 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_ifc125445 (linea, ean, sku, nombre, qty, costo) values
  (1, null, 'FC-IFC-1570818', 'Mercurio magnesia calcinada C/50', 1, 55.50),
  (2, null, 'FC-IFC-ESPEJITO', 'Espejito redondo económico', 5, 6.00),
  (3, null, 'FC-IFC-PARCHE-ACNE', 'Parches para acné hidrocoloide', 6, 16.50),
  (4, null, 'FC-IFC-82912', 'Benzal Wash líquido 240 mL', 1, 102.50),
  (5, null, 'FC-IFC-1490724', 'Mercurio rosa de Castilla C/50', 1, 75.00),
  (6, null, 'FC-IFC-1330723', 'Mercurio almidón cajita C/10', 1, 91.50),
  (7, null, 'FC-IFC-1660824', 'Mercurio anís estrella C/25', 1, 131.00),
  (8, null, 'FC-IFC-1400724', 'Mercurio bórax polvo C/50', 1, 53.00),
  (9, null, 'FC-IFC-PULEFIN100', 'Lima de uñas Pulefin C/100', 1, 94.50),
  (10, null, 'FC-IFC-82943', 'Mercurio pomada manzana C/25', 4, 9.50);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '125445',
  '2026-09-24',
  770.00,
  'borrador',
  'Farma Centre / IFC F8 Tienda · folio 125445 · 2026-09-24 16:41 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '125445' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 770.00,
  fecha = '2026-09-24',
  proveedor = 'IFC F8 Tienda',
  notas = 'Farma Centre / IFC F8 Tienda · folio 125445 · 2026-09-24 16:41 · MAYOREO/MENUDEO · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '125445'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '125445'
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
from _fc_rx_ifc125445 t
join public.recepciones r
  on r.folio = '125445'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;

commit;

-- Diagnóstico: si renglones = 0 y estado <> borrador → ya estaba cerrada.
-- Si 0 filas → no se insertó (revisa error arriba).
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '125445'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '125445' and coalesce(r.proveedor, '') ilike '%ifc%'
order by i.id;


-- ━━━ FIN: patch_recepcion_ifc_125445.sql ━━━
