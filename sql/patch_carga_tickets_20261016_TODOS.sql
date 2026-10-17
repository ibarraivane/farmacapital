-- ═══════════════════════════════════════════════════════════════
-- TICKETS 16-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261016.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_hacienda_143865.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- La Hacienda Pets · Bodega G-71 · ticket 143865 · 2026-10-16 16:47
-- 1 renglón / 2 piezas. Efectivo $290.00. Cambio $0.
-- Ficha Pet's Pharma: shampoo insecticida deltametrina 0.058%, 250 ml.
-- El papel no trae código. Botella EAN 7506343804129 (dígito verificador ok).
-- SKU FarmaCapital FC-1792190821000. M26125 es código de fábrica, no se usa como SKU.
-- Sin lote ni caducidad. No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_hda_143865 (
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

insert into _fc_hda_143865 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506343804129', 'FC-1792190821000', 'Kannes Delta shampoo', 'FAR SHAMPOO KANNES DELTA 250ML', 2, 145.00, 182, 'marca', 'Mascotas', 'Antiparasitario', 'Shampoo', 'Kannes', 'Pet''s Pharma', '250 ml', 'Deltametrina', '0.058%', false, false, 'https://www.farmacapital.mx/catalogo-propia/kannes-delta-shampoo-250ml.png', 'catalogo-propia/kannes-delta-shampoo-250ml.png', null);

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
  'Alta La Hacienda Pets 143865 · 2026-10-16 · listo para pistola',
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
  from _fc_hda_143865
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
  from _fc_hda_143865
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
  from _fc_hda_143865
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'La Hacienda Pets',
  '143865',
  '2026-10-16',
  290.00,
  'borrador',
  'Ticket Bodega G-71 La Hacienda Pets 143865 · 16-oct-2026 16:47 · efectivo $290.00 · sello PAGADO · cola Recibir. El papel no trae código. La botella es EAN 7506343804129. M26125 es el código de fábrica, no el SKU. Pon MMAA de la botella.'
where not exists (
  select 1 from public.recepciones
  where folio = '143865'
    and coalesce(proveedor, '') ilike '%hacienda%'
);

update public.recepciones
set
  total_ticket = 290.00,
  fecha = '2026-10-16',
  proveedor = 'La Hacienda Pets',
  notas = 'Ticket Bodega G-71 La Hacienda Pets 143865 · 16-oct-2026 16:47 · efectivo $290.00 · sello PAGADO · cola Recibir. El papel no trae código. La botella es EAN 7506343804129. M26125 es el código de fábrica, no el SKU. Pon MMAA de la botella.',
  updated_at = now()
where folio = '143865'
  and coalesce(proveedor, '') ilike '%hacienda%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '143865'
  and coalesce(r.proveedor, '') ilike '%hacienda%'
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
from _fc_hda_143865 t
join public.recepciones r
  on r.folio = '143865'
 and coalesce(r.proveedor, '') ilike '%hacienda%'
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
from _fc_hda_143865 t
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
where r.folio = '143865'
  and coalesce(r.proveedor, '') ilike '%hacienda%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_hda_143865 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_surtidor_146002.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- El Surtidor de su Farmacia · venta 146002 · 2026-10-16 16:49 · MAESTRO F48
-- Agua destilada: 15 × $19.00 = $285.01 en el papel (1 centavo de redondeo).
-- Jardianz: lista $2,717.46 − descuento $1,725.59 = neto $991.87 (63.5%).
-- Costo = total del renglón ÷ piezas, no el precio de lista.
-- Total ticket $1,276.88. Sin lote ni caducidad. No inventar 0000.
-- 1 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_sur_146002 (
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

insert into _fc_sur_146002 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501677620056', 'FC-77620056', 'Agua destilada La Flor', 'AGUA DESTILADA LA FLOR 1 LT', 15, 19.00, 24, 'marca', 'Botiquín', 'Agua destilada', 'Solución', 'La Flor', null, '1 L', null, null, false, true, null, null, null),
  (2, '7501034605115', 'FC-34605115', 'Jardianz empagliflozina 25 mg', 'JARDIANZ TAB 25MG C/30 EMPAGLIFOZINA', 1, 991.87, 1240, 'marca', 'Medicamentos', 'Diabetes', 'Tabletas', 'Jardianz', 'Boehringer Ingelheim', 'Caja con 30 tabletas', 'Empagliflozina', '25 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/jardianz-25mg-c30-7501034605115.jpg', 'catalogo-propia/jardianz-25mg-c30-7501034605115.jpg', null);

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
  'Alta El Surtidor 146002 · 2026-10-16 · listo para pistola',
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
  from _fc_sur_146002
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
  from _fc_sur_146002
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
  from _fc_sur_146002
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'El Surtidor',
  '146002',
  '2026-10-16',
  1276.88,
  'borrador',
  'Ticket El Surtidor venta 146002 · caja 1 · 16-oct-2026 16:49 · bodega F48 Central de Abasto · sello PAGADO · costo = total neto del renglón (ya con descuento) · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '146002'
    and coalesce(proveedor, '') ilike '%surtidor%'
);

update public.recepciones
set
  total_ticket = 1276.88,
  fecha = '2026-10-16',
  proveedor = 'El Surtidor',
  notas = 'Ticket El Surtidor venta 146002 · caja 1 · 16-oct-2026 16:49 · bodega F48 Central de Abasto · sello PAGADO · costo = total neto del renglón (ya con descuento) · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '146002'
  and coalesce(proveedor, '') ilike '%surtidor%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '146002'
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
from _fc_sur_146002 t
join public.recepciones r
  on r.folio = '146002'
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
from _fc_sur_146002 t
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
where r.folio = '146002'
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
from _fc_sur_146002 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_equilibrio_448303.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Equilibrio Farmacéutico · ticket 448303 · 2026-10-16 17:08 · Iztapalapa 2
-- Pedido online. Clave ALPO608 = ALP0608 Alpharma EAN 7501384541163.
-- 10 cajas × P.U. neto $18.11 = $181.10. Ahorro de lista $718.90.
-- Lote de fábrica 7230526 sí. Caducidad NO: el papel dice 31/05/2029; MMAA se captura de la caja. 0000 inválido.
-- 0 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_448303 (
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

insert into _fc_eq_448303 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501384541163', 'EQ-ALP0608', 'Carbamazepina Alpharma 200 mg', 'ALPO608 CARBAMAZEPINA 20 TAB 200 MG', 10, 18.11, 29, 'generico', 'Medicamentos', 'Anticonvulsivo', 'Tabletas', 'Alpharma', 'Alpharma', 'Caja con 20 tabletas', 'Carbamazepina', '200 mg', true, true, null, null, '7230526');

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
  'Alta Equilibrio 448303 · 2026-10-16 · listo para pistola',
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
  from _fc_eq_448303
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
  from _fc_eq_448303
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
  from _fc_eq_448303
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '448303',
  '2026-10-16',
  181.10,
  'borrador',
  'Ticket Equilibrio 448303 · pedido online · sucursal Iztapalapa 2 · 16-oct-2026 17:08 · cliente Luis Angel Palillero Ventura · lote de fábrica 7230526 · caducidad del papel 31/05/2029 no se guarda (MMAA de la caja) · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '448303'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 181.10,
  fecha = '2026-10-16',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 448303 · pedido online · sucursal Iztapalapa 2 · 16-oct-2026 17:08 · cliente Luis Angel Palillero Ventura · lote de fábrica 7230526 · caducidad del papel 31/05/2029 no se guarda (MMAA de la caja) · cola Recibir',
  updated_at = now()
where folio = '448303'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '448303'
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
from _fc_eq_448303 t
join public.recepciones r
  on r.folio = '448303'
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
from _fc_eq_448303 t
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
where r.folio = '448303'
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
from _fc_eq_448303 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_bodega_f42_86064.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Bodega F-42 Ejidos del Moral · Caja 3/86064 · 2026-10-16 17:24
-- 32 renglones. Total en letra: mil ochocientos doce pesos 74/100.
-- Costo = P.U. impreso redondeado a 2 decimales (el papel trae 3).
-- La suma de importes de renglón es el total pagado. No se vuelve a sumar IVA.
-- Sin lote ni caducidad. No inventar 0000.
-- Esponja redonda 793969378180: el ticket no dice marca.
-- 30 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_86064 (
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

insert into _fc_bf42_86064 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501032938215', 'FC-32938215', 'Glade aerosol Campos de lavanda', 'GLADE 400ML SPY AROM CAMPOS LAVAND', 1, 62.16, 78, 'marca', 'Hogar', 'Aromatizante', 'Aerosol', 'Glade', 'SC Johnson', '400 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/glade-campos-lavanda-400ml-7501032938215.jpg', 'catalogo-propia/glade-campos-lavanda-400ml-7501032938215.jpg', null),
  (2, '7501032907075', 'FC-32907075', 'Glade aerosol Fresh Lemon', 'GLADE 400ML SPY AROM FRESH LEMON', 1, 54.84, 69, 'marca', 'Hogar', 'Aromatizante', 'Aerosol', 'Glade', 'SC Johnson', '400 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/glade-fresh-lemon-400ml-7501032907075.jpg', 'catalogo-propia/glade-fresh-lemon-400ml-7501032907075.jpg', null),
  (3, '7501014501406', 'FC-14501406', 'BIC Flex 5 Titanium', 'BIC FLEX5 TITANIUM BL C/2 OFERTA 15%', 1, 79.05, 99, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'BIC', null, 'Blíster con 2 rastrillos', null, null, false, false, null, null, null),
  (4, '070330736580', 'FC-30736580', 'BIC Flex 3', 'BIC FLEX 3 BL C/2 OFERTA 15%', 2, 51.85, 65, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'BIC', null, 'Blíster con 2 rastrillos', null, null, false, false, null, null, null),
  (5, '7503005405168', 'FC-05405168', 'Estropajo Saluk Fashion F-Clean clásica', 'ESTROPAJO F-CLEAN CLASICA SAL C/1', 3, 12.31, 16, 'marca', 'Higiene', 'Limpieza', 'Estropajo', 'Saluk Fashion', 'Lidernova', '1 pieza', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/estropajo-fclean-clasica-7503005405168.jpg', 'catalogo-propia/estropajo-fclean-clasica-7503005405168.jpg', null),
  (6, '7500435250689', 'FC-35250689', 'Secret spray Cherry Blossom', 'DEO SECRET 150ML SPY CHERRY BLOSSOM', 1, 57.51, 72, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Secret', 'Procter & Gamble', '150 ml', null, null, false, false, null, null, null),
  (7, '7500435259187', 'FC-35259187', 'Secret spray Berry', 'DESOD SECRET 150ML SPY BERRY', 1, 57.52, 72, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Secret', 'Procter & Gamble', '150 ml', null, null, false, false, null, null, null),
  (8, '7500435180665', 'FC-35180665', 'Secret aerosol Orange Blossom', 'DEO SECRET AERO ANT ORANGE', 1, 56.24, 71, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'Secret', 'Procter & Gamble', '93 g', null, null, false, false, null, null, null),
  (9, '037836051562', 'FC-36051562', 'Grisi jabón líquido algas rojas', 'JBN LIQ GRISI CORP ALGA ROJA 450ML', 1, 53.74, 68, 'marca', 'Cuidado personal', 'Baño', 'Jabón líquido', 'Grisi', null, '450 ml', null, null, false, false, null, null, null),
  (10, '037836051227', 'FC-36051227', 'Grisi jabón líquido concha nácar', 'JBN LIQ GRISI CONCHA NACAR 450ML', 1, 53.74, 68, 'marca', 'Cuidado personal', 'Baño', 'Jabón líquido', 'Grisi', null, '450 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/grisi-concha-nacar-liq-450ml.jpg', 'catalogo-propia/grisi-concha-nacar-liq-450ml.jpg', null),
  (11, '7506306251847', 'FC-06251847', 'Axe Black Remixed', 'DESOD AXE BLACK REMIX SPY 210 ML', 1, 68.73, 86, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'Axe', 'Unilever', '210 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/axe-black-remixed-210ml-7506306251847.jpg', 'catalogo-propia/axe-black-remixed-210ml-7506306251847.jpg', null),
  (12, '7506306250604', 'FC-06250604', 'Axe Dark Temptation', 'DESOD AXE MEN DARK TEM SPY 210ML', 2, 68.73, 86, 'marca', 'Cuidado personal', 'Desodorante', 'Aerosol', 'Axe', 'Unilever', '210 ml', null, null, false, false, null, null, null),
  (13, '850040940046', 'FC-40940046', 'Ricitos de Oro shampoo y gel lavanda y lechuga', 'SH Y GEL RICITOS DE ORO LAV Y LECH 500ML C 12', 1, 70.66, 89, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Ricitos de Oro', 'Grisi', '500 ml', null, null, false, false, null, null, null),
  (14, '7501165009486', 'FC-65009486', 'Lactacyd Pro-Bio shampoo íntimo', 'LACTACYD PRO-BIO FEMINA 200ML SH', 1, 72.37, 91, 'marca', 'Cuidado personal', 'Higiene íntima', 'Shampoo', 'Lactacyd', 'Sanofi', '200 ml', null, null, false, true, null, null, null),
  (15, '7502245720208', 'FC-45720208', 'Silkhair quitaesmalte manzana', 'SILKHAIR QUITA ESMALTE MANZANA 100ML', 1, 17.20, 22, 'marca', 'Cuidado personal', 'Uñas', 'Líquido', 'Silkhair', null, '100 ml', null, null, false, false, null, null, null),
  (16, '7502245720574', 'FC-45720574', 'Silkhair quitaesmalte uva', 'SILKHAIR QUITA ESMALTE UVA 100ML', 1, 17.20, 22, 'marca', 'Cuidado personal', 'Uñas', 'Líquido', 'Silkhair', null, '100 ml', null, null, false, false, null, null, null),
  (17, '7502245720567', 'FC-45720567', 'Silkhair quitaesmalte coco', 'SILKHAIR QUITA ESMALTE COCO 100 ML', 1, 17.20, 22, 'marca', 'Cuidado personal', 'Uñas', 'Líquido', 'Silkhair', null, '100 ml', null, null, false, false, null, null, null),
  (18, '7501001169091', 'FC-01169091', 'Pantene Pro-V rizos definidos', 'SH PANTENE PRO-V RIZOS DEFI 200ML', 2, 37.80, 48, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Pantene', 'Procter & Gamble', '200 ml', null, null, false, false, null, null, null),
  (19, '7500435142564', 'FC-35142564', 'Head & Shoulders hidratación aceite de coco', 'SH H&S HIDRATACION AC COCO 180ML', 2, 36.55, 46, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Head & Shoulders', 'Procter & Gamble', '180 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/hs-hidratacion-coco-180ml-7500435142564.jpg', 'catalogo-propia/hs-hidratacion-coco-180ml-7500435142564.jpg', null),
  (20, '7500435258425', 'FC-35258425', 'Head & Shoulders anticaída romero', 'SH H&S 90ML ROMERO ANTI CAIDA C24', 2, 17.05, 22, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Head & Shoulders', 'Procter & Gamble', '90 ml', null, null, false, false, null, null, null),
  (21, '7500435257084', 'FC-35257084', 'Head & Shoulders anti comezón menta', 'SH H&S 90ML ANTI COMEZON', 2, 17.05, 22, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Head & Shoulders', 'Procter & Gamble', '90 ml', null, null, false, false, null, null, null),
  (22, '7501943490994', 'FC-43490994', 'Kotex Slim con alas', 'TAS SANIT KOTEX ULTRADELG ALAS 10', 1, 15.90, 20, 'marca', 'Cuidado personal', 'Protección femenina', 'Toalla sanitaria', 'Kotex', null, '10 toallas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kotex-ultradelgada-alas-10-7501943490994.jpg', 'catalogo-propia/kotex-ultradelgada-alas-10-7501943490994.jpg', null),
  (23, '7501019030611', 'FC-19030611', 'Saba confort manzanilla delgada', 'TAS SANIT SABA CONF MZLLA DELG 10', 1, 18.47, 24, 'marca', 'Cuidado personal', 'Protección femenina', 'Toalla sanitaria', 'Saba', null, '10 toallas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/saba-confort-manzanilla-10-7501019030611.jpg', 'catalogo-propia/saba-confort-manzanilla-10-7501019030611.jpg', null),
  (24, '7501103306691', 'FC-03306691', 'T.Taio esponja Bathtime suave animal', 'ESPONJA T.TAIO BATHTIME SVE ANIMAL', 1, 15.16, 19, 'marca', 'Cuidado personal', 'Baño', 'Esponja', 'T.Taio', null, '1 pieza', null, null, false, false, null, null, null),
  (25, '793969378180', 'FC-69378180', 'Esponja redonda', 'ESPONJA REDONDA BLISTER', 1, 12.74, 16, 'marca', 'Higiene', 'Baño', 'Esponja', null, null, 'Blíster 1 pieza', null, null, false, false, null, null, null),
  (26, '7501027551047', 'FC-27551047', 'Evenflo escobillón Basic', 'ESCOBILLON BASIC EVENFLO', 2, 33.70, 43, 'marca', 'Bebé', 'Biberón', 'Cepillo', 'Evenflo', null, '1 pieza', null, null, false, false, null, null, null),
  (27, '7500435140591', 'FC-35140591', 'Gillette gel aloe', 'DESOD GTTE HYDR-GEL ALOE STICK 82G', 1, 69.58, 87, 'marca', 'Cuidado personal', 'Desodorante', 'Gel', 'Gillette', 'Procter & Gamble', '82 g', null, null, false, false, null, null, null),
  (28, '7506309862057', 'FC-09862057', 'Gillette Sport Triumph gel', 'DESOD GTTE SPORT TRIUMPH GEL 82G', 1, 70.40, 88, 'marca', 'Cuidado personal', 'Desodorante', 'Gel', 'Gillette', 'Procter & Gamble', '82 g', null, null, false, false, null, null, null),
  (29, '7500435129947', 'FC-35129947', 'Gillette Cool Wave', 'DESOD GTTE COOLWAVE STICK 45G', 2, 50.65, 64, 'marca', 'Cuidado personal', 'Desodorante', 'Barra', 'Gillette', 'Procter & Gamble', '45 g', null, null, false, false, null, null, null),
  (30, '7702018913664', 'FC-18913664', 'Gillette Clear Cool Wave gel', 'DESOD GTTE 3XAP CL COOL-W GEL 82G', 2, 65.23, 82, 'marca', 'Cuidado personal', 'Desodorante', 'Gel', 'Gillette', 'Procter & Gamble', '82 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/gillette-clear-cool-wave-gel-82g-7702018913664.jpg', 'catalogo-propia/gillette-clear-cool-wave-gel-82g-7702018913664.jpg', null),
  (31, '7506195160466', 'FC-95160466', 'Pantene Pro-V cuidado clásico 2 en 1', 'SH. PANTENE CUIDADO CLASICO 2EN1 100ML', 3, 15.93, 20, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Pantene', 'Procter & Gamble', '100 ml', null, null, false, false, null, null, null),
  (32, '7506195148686', 'FC-95148686', 'Head & Shoulders limpieza renovadora', 'SH H&S LIMP RENOV 90ML', 2, 15.19, 19, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Head & Shoulders', 'Procter & Gamble', '90 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/hs-limpieza-renovadora-90ml-7506195148686.jpg', 'catalogo-propia/hs-limpieza-renovadora-90ml-7506195148686.jpg', null);

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
  'Alta Bodega F-42 86064 · 2026-10-16 · listo para pistola',
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
  from _fc_bf42_86064
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
  from _fc_bf42_86064
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
  from _fc_bf42_86064
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '86064',
  '2026-10-16',
  1812.74,
  'borrador',
  'Ticket Bodega F-42 Caja 3/86064 · 16-oct-2026 17:24 · tarjeta de crédito $1,812.74 · costo = P.U. del renglón a 2 decimales · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '86064'
    and coalesce(proveedor, '') ilike '%f-42%'
);

update public.recepciones
set
  total_ticket = 1812.74,
  fecha = '2026-10-16',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 Caja 3/86064 · 16-oct-2026 17:24 · tarjeta de crédito $1,812.74 · costo = P.U. del renglón a 2 decimales · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '86064'
  and coalesce(proveedor, '') ilike '%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '86064'
  and coalesce(r.proveedor, '') ilike '%f-42%'
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
from _fc_bf42_86064 t
join public.recepciones r
  on r.folio = '86064'
 and coalesce(r.proveedor, '') ilike '%f-42%'
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
from _fc_bf42_86064 t
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
where r.folio = '86064'
  and coalesce(r.proveedor, '') ilike '%f-42%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_86064 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s332343.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Cityfarma Iztapalapa · orden S332343 · 2026-10-16 17:01
-- Subtotal $1,124.61 + IVA 16% $42.76 = pendiente $1,167.37.
-- El IVA del pie está en el renglón de Kitoscell (3 × $103.33 = $310.00).
-- Costo = P.U. impreso. Kitoscell a 2 decimales cierra $309.99 (1 centavo).
-- Flanax EAN 7501008498866 es caja con 6 tabletas.
-- Groobe: el papel dice TABS; la caja es 24 cápsulas.
-- Sin lote ni caducidad. No inventar 0000.
-- 3 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s332343 (
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

insert into _fc_cf_s332343 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501298206455', 'FC-98206455', 'Dabex XR metformina 500 mg', 'DABEX XR 500MG T30', 1, 270.88, 339, 'marca', 'Medicamentos', 'Diabetes', 'Tabletas', 'Dabex', 'Merck', 'Caja con 30 tabletas', 'Metformina', '500 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/dabex-xr-metformina-500mg-c30-7501298206455.jpg', 'catalogo-propia/dabex-xr-metformina-500mg-c30-7501298206455.jpg', null),
  (2, '7501008498866', 'FC-08498866', 'Flanax naproxeno sódico 550 mg', 'FLANAX 550MG C6 TABS', 3, 99.54, 125, 'marca', 'Medicamentos', 'Analgésico', 'Tabletas', 'Flanax', 'Bayer', 'Caja con 6 tabletas', 'Naproxeno sódico', '550 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/flanax-550mg-c6-7501008498866.jpg', 'catalogo-propia/flanax-550mg-c6-7501008498866.jpg', null),
  (3, '7502227425008', 'FC-27425008', 'Groobe dimenhidrinato 50 mg', 'GROOBE 50MG C24 TABS', 5, 27.53, 45, 'generico', 'Medicamentos', 'Antiemético', 'Cápsulas', 'Groobe', 'Gelpharma', 'Caja con 24 cápsulas', 'Dimenhidrinato', '50 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/groobe-dimenhidrinato-50mg-c24-7502227425008.jpg', 'catalogo-propia/groobe-dimenhidrinato-50mg-c24-7502227425008.jpg', null),
  (4, '7502224228060', 'FC-24228060', 'Kitoscell', 'KITOSCELL 3.5GR GEL', 3, 103.33, 130, 'marca', 'Dermocosmético', 'Cicatrices', 'Gel', 'Kitoscell', 'Cell Pharma', 'Tubo 3.5 g', 'Pirfenidona', '8 g/100 g', false, false, null, null, null),
  (5, '7501101614026', 'FC-01614026', 'Malival indometacina 25 mg', 'MALIVAL 25 MG C 30CA', 1, 150.22, 188, 'marca', 'Medicamentos', 'Analgésico', 'Cápsulas', 'Malival', 'Silanes', 'Caja con 30 cápsulas', 'Indometacina', '25 mg', false, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa S332343 · 2026-10-16 · listo para pistola',
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
  from _fc_cf_s332343
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
  from _fc_cf_s332343
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
  from _fc_cf_s332343
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S332343',
  '2026-10-16',
  1167.37,
  'borrador',
  'Ticket Cityfarma S332343 · 16-oct-2026 17:01 · vendedor Eduardo Nicanor · cliente Luis Angel Palillero Ventura · pendiente de pago $1,167.37 · P.U. ya trae IVA · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S332343'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1167.37,
  fecha = '2026-10-16',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S332343 · 16-oct-2026 17:01 · vendedor Eduardo Nicanor · cliente Luis Angel Palillero Ventura · pendiente de pago $1,167.37 · P.U. ya trae IVA · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S332343'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S332343'
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
from _fc_cf_s332343 t
join public.recepciones r
  on r.folio = 'S332343'
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
from _fc_cf_s332343 t
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
where r.folio = 'S332343'
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
from _fc_cf_s332343 t
order by t.linea;

commit;
