-- ═══════════════════════════════════════════════════════════════
-- TICKETS 06-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261006.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_ifc_127425.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- IFC F8 · ticket 127425 · 2026-10-06 17:08 · cliente IVAN
-- Mayoreo. 1 paquete · total $238.00.
-- CINTAPORE MICROPORE PIEL GRANDE C/12 → EAN caja 7506484500034 (Codifarma 2.5 cm × 9.1 m × 12; código IFC 84129).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_ifc_127425 (
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

insert into _fc_ifc_127425 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506484500034', 'FC-84500034', 'Cintapore micropore piel', 'CINTAPORE MICROPORE PIEL GRANDE C/12 | 260402-4 84129', 1, 238.00, 298, 'marca', 'Botiquín', 'Material de curación', 'Cinta', 'Cintapore', 'Codifarma', 'Caja con 12 rollos 2.5 cm × 9.1 m', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg', 'catalogo-propia/cintapore-piel-2.5x5.jpg', null);

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
  'Alta IFC 127425 · 2026-10-06 · listo para pistola',
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
  from _fc_ifc_127425
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
  from _fc_ifc_127425
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
  from _fc_ifc_127425
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC',
  '127425',
  '2026-10-06',
  238.00,
  'borrador',
  'Ticket IFC F8 127425 · 06-oct-2026 17:08 · foto térmica · Cintapore micropore piel grande C/12 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '127425'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 238.00,
  fecha = '2026-10-06',
  proveedor = 'IFC',
  notas = 'Ticket IFC F8 127425 · 06-oct-2026 17:08 · foto térmica · Cintapore micropore piel grande C/12 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '127425'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '127425'
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
from _fc_ifc_127425 t
join public.recepciones r
  on r.folio = '127425'
 and coalesce(r.proveedor, '') ilike '%ifc%'
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
from _fc_ifc_127425 t
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
where r.folio = '127425'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_ifc_127425 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_zorro_T01696085.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Grupo Zorro E-9 · ticket T01696085 · 2026-10-06 17:20:22
-- Menudeo. 1 pza · total $161.67 (IVA incluido en ticket).
-- RASTRILLOS SCHICK XTREME 3 12-12 PZ → EAN bolsa 7502274881475 (no confundir con pieza suelta 7591066701015).
-- Sin lote ni caducidad. No inventar 0000.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_zorro_T01696085 (
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

insert into _fc_zorro_T01696085 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502274881475', 'FC-274881475', 'Schick Xtreme 3', 'RASTRILLOS SCHICK XTREME 3 12-12 PZ', 1, 161.67, 203, 'marca', 'Cuidado personal', 'Afeitado', 'Rastrillo', 'Schick', 'Edgewell', 'Bolsa con 12 rastrillos', null, null, false, false, null, null, null);

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
  'Alta Grupo Zorro T01696085 · 2026-10-06 · listo para pistola',
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
  from _fc_zorro_T01696085
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
  from _fc_zorro_T01696085
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
  from _fc_zorro_T01696085
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Grupo Zorro',
  'T01696085',
  '2026-10-06',
  161.67,
  'borrador',
  'Ticket Grupo Zorro ZE9 T01696085 · 06-oct-2026 17:20 · Schick Xtreme 3 bolsa 12 pzas · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'T01696085'
    and coalesce(proveedor, '') ilike '%zorro%'
);

update public.recepciones
set
  total_ticket = 161.67,
  fecha = '2026-10-06',
  proveedor = 'Grupo Zorro',
  notas = 'Ticket Grupo Zorro ZE9 T01696085 · 06-oct-2026 17:20 · Schick Xtreme 3 bolsa 12 pzas · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'T01696085'
  and coalesce(proveedor, '') ilike '%zorro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T01696085'
  and coalesce(r.proveedor, '') ilike '%zorro%'
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
from _fc_zorro_T01696085 t
join public.recepciones r
  on r.folio = 'T01696085'
 and coalesce(r.proveedor, '') ilike '%zorro%'
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
from _fc_zorro_T01696085 t
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
where r.folio = 'T01696085'
  and coalesce(r.proveedor, '') ilike '%zorro%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_zorro_T01696085 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_equilibrio_447156.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Equilibrio · ticket 447156 · 2026-10-06 · sucursal Iztapalapa 2
-- Pedido online. Total $2,643.87 · 21 renglones / 75 pzas.
-- Claves EQF → EAN ficha/Levic/mayoreo. Lote de fábrica sí.
-- Caducidad NO: MMAA de la caja. 0000 inválido.
-- 10 alta(s) stock 0. 11 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_447156 (
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

insert into _fc_eq_447156 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501537164638', 'EQ-BRU029', 'Butifeno ketotifeno solución', 'BRU029 BUTIFENO 1 SOL 20MG/5/120 ML', 2, 19.80, 32, 'generico', 'Medicamentos', null, 'Solución', 'Butifeno', 'Bruluart', 'Frasco 120 mL', 'Ketotifeno', '20 mg/5 mL', false, false, null, null, '2511999'),
  (2, '7501573904403', 'EQ-BIO138', 'Lozamir-C clotrimazol crema 1%', 'BIO138 LOZAMIR-C 1 CMA 1/30 G', 3, 14.31, 23, 'generico', 'Dermocosmético', null, 'Crema', 'Lozamir-C', 'Biomep', 'Tubo 30 g', 'Clotrimazol', '1%', false, true, null, null, 'CE2604'),
  (3, '7502001166110', 'EQ-SON247', 'Femitab clindamicina/ketoconazol', 'SON247 FEMITAB 7 OVS 100/400 MG', 2, 63.63, 102, 'generico', 'Medicamentos', null, 'Óvulo', 'Femitab', 'Son''s', 'Caja con 7 óvulos', 'Clindamicina / ketoconazol', '100/400 mg', true, false, null, null, '25123575'),
  (4, '7501478316226', 'EQ-VIT061', 'Bocetix levocetirizina 5 mg', 'VIT061 BOCETIX 10 TAB 5 MG', 5, 43.63, 70, 'generico', 'Medicamentos', null, 'Tableta', 'Bocetix', 'Vitae', 'Caja con 10 tabletas', 'Levocetirizina', '5 mg', false, false, null, null, 'T2607355'),
  (5, '7503004908714', 'EQ-ALP0520', 'Miconazol crema 2%', 'ALP0520 MICONAZOL 1 CMA DE 20 G', 5, 10.67, 18, 'generico', 'Dermocosmético', null, 'Crema', 'Alpharma', 'Alpharma', 'Tubo 20 g', 'Miconazol', '2%', false, true, null, null, '2601222'),
  (6, '7501836006042', 'EQ-LIF160', 'Virindrez Adulto oximetazolina 0.050%', 'LIF160 VIRINDREZ ADULTO 1 ATOM 50 MG/20 ML', 5, 23.37, 38, 'generico', 'Medicamentos', null, 'Atomizador', 'Virindrez', 'Liferpal', 'Frasco atomizador 20 mL', 'Oximetazolina', '0.050%', false, true, null, null, '26F031'),
  (7, '7503001007120', 'FC-50587FA6', 'Mexapin amoxicilina suspensión 125 mg/5 mL', 'WAN006 MEXAPIN 1 SUSP 125MG/5/60 ML', 6, 13.32, 22, 'generico', 'Medicamentos', null, 'Suspensión', 'Mexapin', 'Wandel', 'Frasco 60 mL', 'Amoxicilina', '125 mg/5 mL', true, true, null, null, '56113'),
  (8, '7501573902584', 'EQ-BIO067', 'Sarox omeprazol 20 mg', 'BIO067 SAROX 14 CAPS 20 MG', 5, 8.18, 14, 'generico', 'Medicamentos', null, 'Cápsula', 'Sarox', 'Biomep', 'Caja con 14 cápsulas', 'Omeprazol', '20 mg', false, true, null, null, '5F2637'),
  (9, '7502009740213', 'FC-F48FF7EF', 'Clamoxin amoxicilina/clavulánico suspensión 250/62.5', 'MAV012 CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML', 3, 35.05, 57, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'Maver', 'Frasco 60 mL', 'Amoxicilina / ácido clavulánico', '250/62.5 mg/5 mL', true, true, null, null, '260031'),
  (10, '7501075727180', 'EQ-NOV175', 'Lia drospirenona/etinilestradiol', 'NOV175 LIA 28 COMP 3/.03 MG', 1, 156.43, 196, 'marca', 'Medicamentos', null, 'Comprimido', 'Lia', 'Novag', 'Caja con 28 comprimidos', 'Drospirenona / etinilestradiol', '3/0.03 mg', true, false, null, null, '16737'),
  (11, '7502009744570', 'EQ-MAV201', 'Sinfonil oxcarbazepina 300 mg', 'MAV201 SINFONIL 20 TAB 300 MG', 2, 75.97, 122, 'generico', 'Medicamentos', null, 'Tableta', 'Sinfonil', 'Maver', 'Caja con 20 tabletas', 'Oxcarbazepina', '300 mg', true, false, null, null, '262434'),
  (12, '7502213040871', 'EQ-HIS045', 'Cifhir bencidamina gel 5%', 'HIS045 CIFHIR 1 GEL 60G/5 %', 1, 44.77, 72, 'generico', 'Dermocosmético', null, 'Gel', 'Cifhir', 'Hispanoamericana', 'Tubo 60 g', 'Bencidamina', '5%', false, true, null, null, '5M326'),
  (13, '7502009744587', 'EQ-MAV202', 'Sinfonil oxcarbazepina 600 mg', 'MAV202 SINFONIL 20 TAB 600 MG', 2, 138.11, 221, 'generico', 'Medicamentos', null, 'Tableta', 'Sinfonil', 'Maver', 'Caja con 20 tabletas', 'Oxcarbazepina', '600 mg', true, false, null, null, '262430'),
  (14, '7501075722604', 'EQ-NOV154', 'Belazix levocetirizina 5 mg', 'NOV154 BELAZIX C/20 TAB 5MG', 4, 63.67, 80, 'marca', 'Medicamentos', null, 'Tableta', 'Belazix', 'Novag', 'Caja con 20 tabletas', 'Levocetirizina', '5 mg', false, true, null, null, '880086'),
  (15, '7501573902928', 'EQ-BIO081', 'Ketoconazol crema 2%', 'BIO081 KETOCONAZOL 1 CMA 2%/30 G', 5, 15.68, 26, 'generico', 'Dermocosmético', null, 'Crema', 'Biomep', 'Biomep', 'Tubo 30 g', 'Ketoconazol', '2%', false, false, null, null, 'CG2610'),
  (16, '7502227427408', 'EQ-GEP050', 'Esgaro levocetirizina 5 mg', 'GEP050 ESGARO 10 CAPS 5 MG', 5, 53.48, 86, 'generico', 'Medicamentos', null, 'Cápsula', 'Esgaro', 'Gelpharma', 'Caja con 10 cápsulas', 'Levocetirizina', '5 mg', false, false, null, null, '260910'),
  (17, '7502001165311', 'FC-830BF3FB', 'Diviltac 150/10 mg/mL', 'SON189 DIVILTAC 1 FA 150/10MG/1 ML', 2, 37.48, 60, 'generico', 'Medicamentos', null, 'Frasco ámpula', 'Diviltac', 'Son''s', 'Frasco ámpula 1 mL', null, '150/10 mg/mL', true, true, null, null, 'H26040037'),
  (18, '7501349014190', 'EQ-AMS147', 'Ácido alendrónico 10 mg', 'AMS147 ACIDO ALENDRONICO 30 TAB 10 MG', 8, 25.65, 42, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 30 tabletas', 'Ácido alendrónico', '10 mg', true, true, null, null, 'U26A275'),
  (19, '7503001007113', 'FC-D5AC44CA', 'Amifarin dicloxacilina 500 mg', 'WAN024 AMIFARIN 20 CAPS 500 MG', 5, 44.31, 71, 'generico', 'Medicamentos', null, 'Cápsula', 'Amifarin', 'Wandel', 'Caja con 20 cápsulas', 'Dicloxacilina', '500 mg', true, true, null, null, 'C6227'),
  (20, '7501349020153', 'EQ-AMS326', 'Levotiroxina sódica 100 mcg', 'AMS326 LEVOTIROXINA SODICA 100 TAB 100 MCG', 1, 43.21, 70, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 100 tabletas', 'Levotiroxina sódica', '100 mcg', true, false, null, null, 'U25G450'),
  (21, '7502001165748', 'EQ-SON244', 'Exbenzol mebendazol 100 mg', 'SON244 EXBENZOL 6 TAB 100 MG', 3, 15.00, 24, 'generico', 'Medicamentos', null, 'Tableta', 'Exbenzol', 'Son''s', 'Caja con 6 tabletas', 'Mebendazol', '100 mg', false, false, null, null, '26040942');

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
  'Alta Equilibrio 447156 · 2026-10-06 · listo para pistola',
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
  from _fc_eq_447156
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
  from _fc_eq_447156
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
  from _fc_eq_447156
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '447156',
  '2026-10-06',
  2643.87,
  'borrador',
  'Ticket Equilibrio 447156 · 06-oct-2026 · pedido online Iztapalapa 2 · 75 pzas · $2,643.87 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '447156'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 2643.87,
  fecha = '2026-10-06',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio 447156 · 06-oct-2026 · pedido online Iztapalapa 2 · 75 pzas · $2,643.87 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '447156'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '447156'
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
from _fc_eq_447156 t
join public.recepciones r
  on r.folio = '447156'
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
from _fc_eq_447156 t
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
where r.folio = '447156'
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
from _fc_eq_447156 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmalive_13999.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farmalive · ticket 13999 · 2026-10-06 16:41 · Club Iztapalapa 1
-- 8 renglones / 23 unidades. Subtotal $798.10 − desc. $19.41 → neto $778.70.
-- Costo = P.U. neto del renglón (2% o 5%). Sin lote ni MMAA.
-- Ticket trunca Suerox/Asepxia a 12 dígitos; pistola = EAN canónico 650…4.
-- Algodón Dibar 50 g: 12 pzas (cantidad marcada a mano en el ticket).
-- 3 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_13999 (
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

insert into _fc_fl_13999 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501008409534', 'FC-08409534', 'Saridon EXH', 'SARIDON EXH TAB C/100 | BAYER OTC', 1, 269.50, 337, 'marca', 'Medicamentos', null, 'Tableta', 'Saridon', 'Bayer OTC', 'Caja con 100 tabletas', 'Paracetamol / propyfenazona / cafeína', null, false, false, null, null, null),
  (2, '7502214980350', 'FC-14980350', 'Prudence Lub lubricante íntimo mora azul', 'LUBRICANTE PRUDENCE MORA AZUL 75 ML | DKT MEXICO', 1, 70.17, 88, 'marca', 'Cuidado personal', 'Íntimo', 'Gel', 'Prudence', 'DKT México', 'Tubo 75 mL', null, null, false, true, null, null, null),
  (3, '6502400746914', 'FC-40074691', 'Asepxia jabón suavizante', 'ASEPXIA JABON SUAVIZANTE 100 GR 4PACK | GENOMMA LAB', 1, 49.98, 63, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Asepxia', 'Genomma Lab', 'Paquete con 4 barras de 100 g', null, null, false, false, null, null, null),
  (4, '6502400046434', 'FC-40004643', 'Asepxia jabón exfoliante', 'ASEPXIA JABON EXFOLIANTE 100 GR | GENOMMA LAB', 2, 39.80, 50, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Asepxia', 'Genomma Lab', 'Barra 100 g', null, null, false, true, null, null, null),
  (5, '7501008409541', 'FC-84095411', 'Saridon', 'SARIDON TAB C/20 | BAYER OTC', 2, 63.45, 80, 'marca', 'Medicamentos', null, 'Tableta', 'Saridon', 'Bayer OTC', 'Caja con 20 tabletas', 'Paracetamol / propyfenazona / cafeína', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/saridon-c20.jpg', 'catalogo-propia/saridon-c20.jpg', null),
  (6, '6502400322644', 'FC-40032264', 'Suerox 8 iones fresa kiwi', 'SUEROX 8IONES FRESA KIWI 630 ML | GENOMMA LAB', 2, 14.72, 19, 'marca', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (7, '7503003406167', 'FC-03406167', 'Cinta micropore Quirmex piel', 'CINTA MICROPOR QUIRMEX PIEL 2.5CMX10M | QUIRMEX', 2, 17.15, 22, 'marca', 'Botiquín', 'Material de curación', 'Cinta', 'Quirmex', 'Quirmex', 'Rollo 2.5 cm × 10 m', null, null, false, false, null, null, null),
  (8, '7501868910034', 'FC-68910034', 'Dibar algodón', 'ALGODON DIBAR 50 GR | DIBAR', 12, 9.90, 13, 'marca', 'Botiquín', 'Material de curación', 'Algodón', 'Dibar', 'Dibar', 'Bolsa 50 g', null, null, false, true, null, null, null);

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
  'Alta Farmalive 13999 · 2026-10-06 · listo para pistola',
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
  from _fc_fl_13999
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
  from _fc_fl_13999
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
  from _fc_fl_13999
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '13999',
  '2026-10-06',
  778.70,
  'borrador',
  'Ticket Farmalive 13999 · Club Iztapalapa 1 · 06-oct-2026 · cliente FARMACAPITAL · descuentos por renglón 2%/5% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '13999'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 778.70,
  fecha = '2026-10-06',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 13999 · Club Iztapalapa 1 · 06-oct-2026 · cliente FARMACAPITAL · descuentos por renglón 2%/5% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '13999'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '13999'
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
from _fc_fl_13999 t
join public.recepciones r
  on r.folio = '13999'
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
from _fc_fl_13999 t
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
where r.folio = '13999'
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
from _fc_fl_13999 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_cityfarma_s329263.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Cityfarma Iztapalapa · orden S329263 · 2026-10-06 17:33
-- Ticket térmico. IVA 0%. Pendiente de pago = $1,425.01.
-- DOXICICLINA 100MG C1 → Randall C/10 EAN 7501563380026.
-- Zivata-Duo dutasterida/tamsulosina 0.5/0.4 mg (Siegfried).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 5 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s329263 (
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

insert into _fc_cf_s329263 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501318645080', 'FC-8645080', 'Canesten V crema', 'CANESTEN V CRA 20 GR', 2, 141.95, 178, 'marca', 'Dermocosmético', null, 'Crema', 'Canesten', 'Bayer OTC', 'Tubo 20 g con aplicadores', 'Clotrimazol', '1%', false, true, null, null, null),
  (2, '7501563380026', 'FC-63380026', 'Doxiciclina 100 mg', 'DOXICICLINA 100MG C1', 2, 24.13, 39, 'generico', 'Medicamentos', null, 'Cápsula', 'Randall', 'Randall', 'Caja con 10 cápsulas', 'Doxiciclina', '100 mg', true, false, null, null, null),
  (3, '7501165000315', 'FC-50003151', 'Neo-Melubrina jarabe infantil', 'NEO MELUBRINA JBE', 2, 118.48, 149, 'marca', 'Medicamentos', null, 'Jarabe', 'Neo-Melubrina', 'Opella', 'Frasco 100 mL', 'Metamizol sódico', '250 mg/5 mL', false, true, 'https://www.farmacapital.mx/catalogo-propia/neo-melubrina-jarabe-100ml.jpg', 'catalogo-propia/neo-melubrina-jarabe-100ml.jpg', null),
  (4, '7501384543983', 'FC-84543983', 'Risperidona 2 mg', 'RISPERIDONA 2MG 40', 2, 62.40, 100, 'generico', 'Medicamentos', null, 'Tableta', 'Alpharma', 'Alpharma', 'Caja con 40 tabletas', 'Risperidona', '2 mg', true, false, null, null, null),
  (5, '7501825300786', 'FC-25300786', 'Sediclon dicicloverina 10 mg', 'SEDICLON DICICLOVERI', 5, 21.24, 34, 'generico', 'Medicamentos', null, 'Tableta', 'Sediclon', 'Degort''s', 'Caja con 30 tabletas', 'Dicicloverina', '10 mg', true, false, null, null, null),
  (6, '7501088576495', 'FC-88576495', 'Troferit 30 mg', 'TROFERIT 30 MG C 15', 1, 150.79, 189, 'marca', 'Medicamentos', null, 'Tableta', 'Troferit', null, 'Caja con 15 tabletas', null, '30 mg', true, false, null, null, null),
  (7, '7501300421821', 'FC-00421821', 'Zivata-Duo dutasterida/tamsulosina', 'ZIVATA-DUO DUTASTERI', 1, 474.10, 593, 'marca', 'Medicamentos', null, 'Cápsula', 'Zivata-Duo', 'Siegfried Rhein', 'Caja con 30 cápsulas', 'Dutasterida / tamsulosina', '0.5/0.4 mg', true, false, null, null, null);

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
  'Alta Cityfarma Iztapalapa S329263 · 2026-10-06 · listo para pistola',
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
  from _fc_cf_s329263
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
  from _fc_cf_s329263
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
  from _fc_cf_s329263
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S329263',
  '2026-10-06',
  1425.01,
  'borrador',
  'Ticket Cityfarma S329263 · 06-oct-2026 · foto térmica · Pendiente de pago $1,425.01 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S329263'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1425.01,
  fecha = '2026-10-06',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S329263 · 06-oct-2026 · foto térmica · Pendiente de pago $1,425.01 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S329263'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S329263'
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
from _fc_cf_s329263 t
join public.recepciones r
  on r.folio = 'S329263'
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
from _fc_cf_s329263 t
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
where r.folio = 'S329263'
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
from _fc_cf_s329263 t
order by t.linea;

commit;
