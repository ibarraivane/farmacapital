-- ═══════════════════════════════════════════════════════════════
-- TICKETS 02-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261002.md
-- ═══════════════════════════════════════════════════════════════

-- Nadro · factura 6090680530 · 2026-10-01 · 10 pzas · $777.49
-- Bepanthen = pomada regeneradora 5% 30 g EAN 7501008498798 (ficha Farmatodo/Fahorro).
-- Budesonida LGEN Dankel = Dankial-B 0.250 mg/2 mL C/5 EAN 7502256040517.
-- Derman 25 g EAN 354312225010 (no es el de 50 g).
-- Histiacil NF AD = EAN canónico 7501328979502 (OCR del papel confundía dígitos).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 2 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_6090680530 (
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

insert into _fc_nd_6090680530 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501008498798', 'FC-08498798', 'Bepanthen pomada regeneradora 5%', 'BEPANTHEN 5% PIPEL REGENE 30G POM', 2, 63.25, 80, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer OTC', 'Tubo 30 g', 'Dexpantenol', '5%', false, true, 'https://www.farmacapital.mx/catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', 'catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', null),
  (2, '7502256040517', 'FC-56040517', 'Dankial-B budesonida 0.250 mg/2 mL C/5', 'BUDESONIDA 250MG 5X2ML AMP LGEN', 3, 88.24, 142, 'generico', 'Respiratorio', null, 'Suspensión para nebulizar', 'Dankial-B', 'Dankel', 'Caja con 5 ampolletas de 2 mL', 'Budesonida', '0.250 mg/2 mL', true, false, 'https://www.farmacapital.mx/catalogo-propia/dankial-b-budesonida-0250-c5-7502256040517.jpg', 'catalogo-propia/dankial-b-budesonida-0250-c5-7502256040517.jpg', null),
  (3, '354312225010', 'FC-12225010', 'Derman crema antimicótica', 'DERMAN 25 G CRA', 2, 27.46, 35, 'marca', 'Dermocosmético', 'Antimicótico', 'Crema', 'Derman', 'Int. Comercio', 'Tubo 25 g', 'Ácido undecilénico / undecilenato de zinc', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/derman-crema-25g-354312225010.jpg', 'catalogo-propia/derman-crema-25g-354312225010.jpg', null),
  (4, '7501328979502', 'FC-28979502', 'Histiacil NF adulto jarabe', 'HISTIACIL-NF AD 150ML JBE', 3, 110.45, 139, 'marca', 'Respiratorio', null, 'Jarabe', 'Histiacil', 'Sanofi / Opella', 'Frasco 150 mL', 'Dextrometorfano / ambroxol', '225 mg / 225 mg por 100 mL', false, true, 'https://www.farmacapital.mx/catalogo-propia/histiacil-nf-adulto-150ml-7501328979502.jpg', 'catalogo-propia/histiacil-nf-adulto-150ml-7501328979502.jpg', null);

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
  'Alta Nadro 6090680530 · 2026-10-01 · listo para pistola',
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
  from _fc_nd_6090680530
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
  from _fc_nd_6090680530
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
  from _fc_nd_6090680530
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6090680530',
  '2026-10-01',
  777.49,
  'borrador',
  'Factura Nadro 6090680530 · 01-oct-2026 · UUID 2FCABA… · sucursal México Sur · Palillero · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6090680530'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 777.49,
  fecha = '2026-10-01',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6090680530 · 01-oct-2026 · UUID 2FCABA… · sucursal México Sur · Palillero · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6090680530'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6090680530'
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
from _fc_nd_6090680530 t
join public.recepciones r
  on r.folio = '6090680530'
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
from _fc_nd_6090680530 t
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
where r.folio = '6090680530'
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
from _fc_nd_6090680530 t
order by t.linea;

commit;


-- Equilibrio · ticket 446721 · 2026-10-02 · sucursal Iztapalapa 2
-- Pedido online. Total $970.74 · 6 renglones / 22 pzas.
-- Claves EQF → EAN Levic: MAI158→785118754242 · MAV073→7503000422498 ·
-- MAV167→7502009742392 · MAV134→7502009741487 · MAV401→7502009749421.
-- Redalip 2 lotes (260148×3 + 260149×1). Lote sí. Caducidad NO (MMAA caja).
-- 0 alta(s) stock 0. 6 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_446721 (
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

insert into _fc_eq_446721 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '785118754242', 'FC-1FFBB505', 'Supratex DAC ambroxol/levodropropizina', 'MAI158 SUPRATEX DAC 1 SOL 300/600 MG 120 ML', 3, 42.80, 69, 'generico', 'Medicamentos', null, 'Solución', 'Supratex', 'MAVI', 'Frasco 120 mL', 'Ambroxol / levodropropizina', '300/600 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/supratex-dac-120ml-785118754242.jpg', 'catalogo-propia/supratex-dac-120ml-785118754242.jpg', '5K2102'),
  (2, '7503000422498', 'FC-6074BB64', 'Redalip bezafibrato 200 mg', 'MAV073 REDALIP 30 TAB 200 MG', 3, 25.21, 41, 'generico', 'Medicamentos', null, 'Tableta', 'Redalip', 'MAVI', 'Caja con 30 tabletas', 'Bezafibrato', '200 mg', true, true, null, null, '260148'),
  (3, '7503000422498', 'FC-6074BB64', 'Redalip bezafibrato 200 mg', 'MAV073 REDALIP 30 TAB 200 MG', 1, 25.21, 41, 'generico', 'Medicamentos', null, 'Tableta', 'Redalip', 'MAVI', 'Caja con 30 tabletas', 'Bezafibrato', '200 mg', true, true, null, null, '260149'),
  (4, '7502009742392', 'EQ-MAV167', 'Doltrix clonixinato/hioscina 125/10 mg', 'MAV167 DOLTRIX 20 TAB 125/10 MG', 5, 71.69, 115, 'generico', 'Medicamentos', null, 'Tableta', 'Doltrix', 'Maver', 'Caja con 20 tabletas', 'Clonixinato de lisina / butilhioscina', '125/10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/doltrix-125-10-c20-7502009742392.jpg', 'catalogo-propia/doltrix-125-10-c20-7502009742392.jpg', '263123'),
  (5, '7502009741487', 'EQ-MAV134', 'Doltrix clonixinato/hioscina 250/10 mg', 'MAV134 DOLTRIX 10 TAB 250/10 MG', 5, 56.46, 91, 'generico', 'Medicamentos', null, 'Tableta', 'Doltrix', 'Maver', 'Caja con 10 tabletas', 'Clonixinato de lisina / butilhioscina', '250/10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/doltrix-250-10-c10-7502009741487.jpg', 'catalogo-propia/doltrix-250-10-c10-7502009741487.jpg', '263116'),
  (6, '7502009749421', 'FC-09749421', 'Dexpantenol crema 5%', 'MAV401 DEXPANTENOL 1 CMA 5% 30 G', 5, 20.15, 33, 'generico', 'Dermocosmético', null, 'Crema', 'Maver', 'Maver', 'Tubo 30 g', 'Dexpantenol', '5%', false, true, 'https://www.farmacapital.mx/catalogo-propia/dexpantenol-5-30g-7502009749421.jpg', 'catalogo-propia/dexpantenol-5-30g-7502009749421.jpg', '264542');

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
  'Alta Equilibrio 446721 · 2026-10-02 · listo para pistola',
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
  from _fc_eq_446721
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
  from _fc_eq_446721
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
  from _fc_eq_446721
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '446721',
  '2026-10-02',
  970.74,
  'borrador',
  'Ticket Equilibrio 446721 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 02-oct-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '446721'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 970.74,
  fecha = '2026-10-02',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 446721 · Iztapalapa 2 · pedido online · cliente 307513 Palillero · 02-oct-2026 · lote de fábrica en papel · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '446721'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446721'
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
from _fc_eq_446721 t
join public.recepciones r
  on r.folio = '446721'
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
from _fc_eq_446721 t
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
where r.folio = '446721'
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
from _fc_eq_446721 t
order by t.linea;

commit;


-- Bodega F-42 Ejidos del Moral · Caja 2/83017 · 2026-10-02 17:13
-- Ticket térmico. Subtotal $267.20 + impuestos $42.75 = $309.95.
-- Costo = P.U. impreso. EAN Grisi con dígito verificador (037…0 / 810…6).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 4 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_83017 (
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

insert into _fc_bf42_83017 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '0378360404500', 'FC-36040450', 'Grisi concha nácar crema para manos', 'CRA GRISI CONCHNAC P/MANOS 80 ML', 2, 43.64, 55, 'marca', 'Cuidado personal', null, 'Crema', 'Grisi', 'Grisi', 'Tubo 80 mL', null, null, false, true, null, null, null),
  (2, '8101205017656', 'FC-20501765', 'Grisi aloe vera crema para manos', 'CRA GRISI ALOE VERA P/MANOS 80 ML', 2, 45.15, 57, 'marca', 'Cuidado personal', null, 'Crema', 'Grisi', 'Grisi', 'Tubo 80 mL', null, null, false, true, null, null, null),
  (3, '0378360405354', 'FC-60405354', 'Ricitos de Oro crema corporal lavanda', 'RICITOS DE ORO 100ML CRA CORP LAVANDA', 2, 17.58, 22, 'marca', 'Cuidado personal', 'Bebé', 'Crema', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, false, null, null, null),
  (4, '7501082722116', 'FC-82722116', 'Nuvel crema para manos suaves', 'CRA NUVEL P/MANOS SUAVES 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', null, 'Crema', 'Nuvel', 'Nuvel', 'Tubo 65 mL', null, null, false, false, null, null, null),
  (5, '0378360415940', 'FC-60415940', 'Ricitos de Oro colonia avena y vainilla', 'RICITOS DE ORO 100ML COLONIA AVENA Y VNLLA', 2, 19.90, 25, 'marca', 'Cuidado personal', 'Bebé', 'Colonia', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, false, null, null, null),
  (6, '7501082722123', 'FC-82722123', 'Nuvel crema para manos hidratada', 'CRA NUVEL P/MANOS HIDRATADA 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', null, 'Crema', 'Nuvel', 'Nuvel', 'Tubo 65 mL', null, null, false, false, null, null, null),
  (7, '7501022104248', 'FC-21042481', 'Ricitos de Oro crema corporal', 'CRA RICITOS DE ORO 100ML', 1, 30.43, 39, 'marca', 'Cuidado personal', 'Bebé', 'Crema', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, true, null, null, null);

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
  'Alta Bodega F-42 83017 · 2026-10-02 · listo para pistola',
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
  from _fc_bf42_83017
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
  from _fc_bf42_83017
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
  from _fc_bf42_83017
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '83017',
  '2026-10-02',
  309.95,
  'borrador',
  'Ticket Bodega F-42 Caja 2/83017 · 02-oct-2026 · tarjeta $309.95 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '83017'
    and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = 309.95,
  fecha = '2026-10-02',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 Caja 2/83017 · 02-oct-2026 · tarjeta $309.95 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '83017'
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '83017'
  and coalesce(r.proveedor, '') ilike '%bodega%'
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
from _fc_bf42_83017 t
join public.recepciones r
  on r.folio = '83017'
 and coalesce(r.proveedor, '') ilike '%bodega%'
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
from _fc_bf42_83017 t
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
where r.folio = '83017'
  and coalesce(r.proveedor, '') ilike '%bodega%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_83017 t
order by t.linea;

commit;


-- Farmalive · ticket 1028 · 2026-10-02 16:35 · Club Iztapalapa 1
-- 8 renglones / 26 unidades. Subtotal $902.00 − 2% $18.04 = $883.96.
-- Costo = P.U. neto (después del 2%). Sin lote ni MMAA.
-- Broncolin vitrolero C/100 EAN ticket 714706903182 (distinto del C/50).
-- 4 alta(s) stock 0. 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_1028 (
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

insert into _fc_fl_1028 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '714706903182', 'FC-06903182', 'Broncolin paletas vitrolero surtido', 'BRONCOLIN PALETA VITROLERO SURTIDO C/100 | BRONCOLIN', 1, 201.29, 252, 'marca', 'Respiratorio', 'Garganta', 'Paleta', 'Broncolin', 'Broncolin', 'Vitrolero con 100 paletas', null, null, false, false, null, null, null),
  (2, '714706918964', 'FC-06918964', 'Broncolin Properlas propóleo y eucalipto', 'PROPERLAS PROPOLEO Y EUCALIPTO 50 G | BRONCOLIN', 1, 27.83, 35, 'marca', 'Respiratorio', 'Garganta', 'Perlas', 'Broncolin', 'Broncolin', 'Bolsa 50 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/properlas-eucalipto-50g-714706918964.jpg', 'catalogo-propia/properlas-eucalipto-50g-714706918964.jpg', null),
  (3, '7502214985805', 'FC-14985805', 'Prudence Chicle condones', 'COND PRUDENCE CHICLE C/5 | DKT MEXICO', 3, 47.63, 60, 'marca', 'Higiene', null, 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, true, null, null, null),
  (4, '7502214980015', 'FC-49800151', 'Prudence Clásico condones', 'COND PRUDENCE CLASICO C/3 | DKT MEXICO', 5, 33.03, 42, 'marca', 'Higiene', null, 'Condón', 'Prudence', 'DKT México', 'Caja con 3', null, null, false, true, null, null, null),
  (5, '714706918940', 'FC-06918940', 'Broncolin Properlas propóleo y jengibre', 'PROPERLAS BRONCOLIN PROP Y JENGIBRE 50 G | BRONCOLIN', 1, 27.83, 35, 'marca', 'Respiratorio', 'Garganta', 'Perlas', 'Broncolin', 'Broncolin', 'Bolsa 50 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/properlas-jengibre-50g-714706918940.jpg', 'catalogo-propia/properlas-jengibre-50g-714706918940.jpg', null),
  (6, '650240019180', 'FC-40019180', 'Pomada de la Campana Tepezcohuite', 'POMADA DE LA CAMPANA TEPEZCOHUITE 35 GR | GENOMMA LAB', 5, 23.91, 30, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 35 g', 'Tepezcohuite', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/campana-tepezcohuite-35g-650240019180.jpg', 'catalogo-propia/campana-tepezcohuite-35g-650240019180.jpg', null),
  (7, '7501065628145', 'FC-65628145', 'Pomada de la Campana', 'POMADA DE LA CAMPANA 35 GR | GENOMMA LAB', 5, 23.91, 30, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 35 g', null, null, false, true, null, null, null),
  (8, '7501065628121', 'FC-65628121', 'Pomada de la Campana', 'POMADA DE LA CAMPANA 19 GR | GENOMMA LAB', 5, 15.97, 20, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 19 g', null, null, false, true, null, null, null);

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
  'Alta Farmalive 1028 · 2026-10-02 · listo para pistola',
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
  from _fc_fl_1028
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
  from _fc_fl_1028
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
  from _fc_fl_1028
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '1028',
  '2026-10-02',
  883.96,
  'borrador',
  'Ticket Farmalive 1028 · Club Iztapalapa 1 · 02-oct-2026 · cliente FARMACAPITAL · descuento 2% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '1028'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 883.96,
  fecha = '2026-10-02',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 1028 · Club Iztapalapa 1 · 02-oct-2026 · cliente FARMACAPITAL · descuento 2% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '1028'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '1028'
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
from _fc_fl_1028 t
join public.recepciones r
  on r.folio = '1028'
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
from _fc_fl_1028 t
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
where r.folio = '1028'
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
from _fc_fl_1028 t
order by t.linea;

commit;


-- Cityfarma Iztapalapa · orden S328174 · 2026-10-02 17:19
-- Ticket térmico. IVA 0%. Pendiente de pago = $200.46.
-- Autevazen levetiracetam 1 g C/30 EAN 7506331301173 (Aurovida).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s328174 (
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

insert into _fc_cf_s328174 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506331301173', 'FC-31301173', 'Autevazen levetiracetam 1 g', 'AUTEVAZEN 1G LEVETIR', 2, 100.23, 161, 'generico', 'Medicamentos', 'Antiepiléptico', 'Tableta', 'Autevazen', 'Aurovida', 'Caja con 30 tabletas', 'Levetiracetam', '1 g', true, false, 'https://www.farmacapital.mx/catalogo-propia/autevazen-levetiracetam-1g-c30-7506331301173.jpg', 'catalogo-propia/autevazen-levetiracetam-1g-c30-7506331301173.jpg', null);

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
  'Alta Cityfarma Iztapalapa S328174 · 2026-10-02 · listo para pistola',
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
  from _fc_cf_s328174
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
  from _fc_cf_s328174
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
  from _fc_cf_s328174
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S328174',
  '2026-10-02',
  200.46,
  'borrador',
  'Ticket Cityfarma S328174 · 02-oct-2026 · foto térmica · Pendiente de pago $200.46 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S328174'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 200.46,
  fecha = '2026-10-02',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S328174 · 02-oct-2026 · foto térmica · Pendiente de pago $200.46 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S328174'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S328174'
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
from _fc_cf_s328174 t
join public.recepciones r
  on r.folio = 'S328174'
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
from _fc_cf_s328174 t
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
where r.folio = 'S328174'
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
from _fc_cf_s328174 t
order by t.linea;

commit;


-- Cityfarma Iztapalapa · orden S328169 · 2026-10-02 17:01
-- Ticket térmico. Subtotal $763.29 + IVA 16% $76.35 = $839.64 (pendiente).
-- Bepanthen Multiusos EAN 7501008498798 · Italviron Kids 7501390912988 alta.
-- XL-3 VR EAN ticket 650240017100 (canónico catálogo también 6502400171006).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 1 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s328169 (
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

insert into _fc_cf_s328169 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501008498798', 'FC-08498798', 'Bepanthen pomada regeneradora 5%', 'BEPANTHEN 30GR MULTI', 3, 64.37, 81, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer OTC', 'Tubo 30 g', 'Dexpantenol', '5%', false, true, 'https://www.farmacapital.mx/catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', 'catalogo-propia/bepanthen-regeneradora-30g-7501008498798.jpg', null),
  (2, '7501390912988', 'FC-90912988', 'Italviron Kids suplemento alimenticio', 'ITALVIRON KIDS C30 S', 1, 553.52, 692, 'marca', 'Vitaminas', 'Suplemento', 'Polvo', 'Italviron', 'Italmex', 'Caja con 30 sobres', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/italviron-kids-30-sobres-7501390912988.jpg', 'catalogo-propia/italviron-kids-30-sobres-7501390912988.jpg', null),
  (3, '650240017100', 'FC-40017100', 'XL-3 VR antigripal', 'XL3 VR C 24 TABL', 1, 93.01, 117, 'marca', 'Medicamentos', 'Antigripal', 'Tableta', 'XL-3', 'Genomma Lab', 'Caja con 24 tabletas', 'Paracetamol / amantadina / clorfenamina', '375/50/3 mg', false, true, null, null, null);

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
  'Alta Cityfarma Iztapalapa S328169 · 2026-10-02 · listo para pistola',
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
  from _fc_cf_s328169
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
  from _fc_cf_s328169
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
  from _fc_cf_s328169
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S328169',
  '2026-10-02',
  839.64,
  'borrador',
  'Ticket Cityfarma S328169 · 02-oct-2026 · foto térmica · Pendiente de pago $839.64 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S328169'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 839.64,
  fecha = '2026-10-02',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S328169 · 02-oct-2026 · foto térmica · Pendiente de pago $839.64 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S328169'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S328169'
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
from _fc_cf_s328169 t
join public.recepciones r
  on r.folio = 'S328169'
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
from _fc_cf_s328169 t
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
where r.folio = 'S328169'
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
from _fc_cf_s328169 t
order by t.linea;

commit;


-- Mayorista de Dulces Iztapalapa · nota T620721328 · 2026-10-02 16:41
-- HS Comercial (www.hscomercial.com.mx). Total tarjeta $335.20.
-- Chupa Chups Mini 6/240: 1 bolsa → 240 pzas mostrador · EAN 076350614570.
-- Vero Mix Clásico 6/1.5kg: 1 bolsa 1.5 kg · sin EAN en papel (no inventar).
-- Sin lote ni caducidad. No inventar 0000.
-- 2 alta(s) stock 0. 0 ya estaban.
-- Nombres de ficha, no del ticket. Vero Mix sin EAN hasta escanear la bolsa.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_dulces_t620721328 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_dulces_t620721328 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '076350614570', 'FC-50614570', 'Chupa Chups Mini paleta', 'ch.MINI paleta Chupa Chups 6/240pzs', 240, 0.7779, 2, 'marca', 'Impulso', null, 'Paleta', 'Chupa Chups', 'Perfetti', 'Bolsa 240 piezas', null, null, false, false, null, null, null),
  (2, null, 'FC-HS-VEROMIX15', 'Vero Mix Clásico surtido', 'vero MIX Clasico 6/1.5kg', 1, 148.5000, 186, 'marca', 'Impulso', null, 'Surtido', 'Vero', 'Vero', 'Bolsa 1.5 kg', null, null, false, false, null, null, null);

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
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(nullif(t.ean, ''), t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Mayorista de Dulces T620721328 · 2026-10-02 · listo para pistola',
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
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where public.fc_buscar_producto_escaneo(t.sku) is null
  and (
    nullif(t.ean, '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), nullif(t.ean, ''))
from (
  select distinct on (sku) *
  from _fc_dulces_t620721328
  order by sku, linea
) t
where p.id = coalesce(
  case when nullif(t.ean, '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Mayorista de Dulces',
  'T620721328',
  '2026-10-02',
  335.20,
  'borrador',
  'Nota Mayorista de Dulces T620721328 · SUC Iztapalapa II · HS Comercial · 02-oct-2026 · Chupa Chups Mini 240 pzas + Vero Mix 1.5 kg · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'T620721328'
    and coalesce(proveedor, '') ilike '%dulces%'
);

update public.recepciones
set
  total_ticket = 335.20,
  fecha = '2026-10-02',
  proveedor = 'Mayorista de Dulces',
  notas = 'Nota Mayorista de Dulces T620721328 · SUC Iztapalapa II · HS Comercial · 02-oct-2026 · Chupa Chups Mini 240 pzas + Vero Mix 1.5 kg · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'T620721328'
  and coalesce(proveedor, '') ilike '%dulces%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T620721328'
  and coalesce(r.proveedor, '') ilike '%dulces%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(t.ean, ''),
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_dulces_t620721328 t
join public.recepciones r
  on r.folio = 'T620721328'
 and coalesce(r.proveedor, '') ilike '%dulces%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(t.ean, '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

select
  r.folio, r.proveedor, r.estado, r.total_ticket,
  count(i.*) as renglones, sum(i.cantidad) as piezas
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'T620721328'
  and coalesce(r.proveedor, '') ilike '%dulces%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
