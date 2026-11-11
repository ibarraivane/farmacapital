-- ═══════════════════════════════════════════════════════════════
-- TICKETS 24-OCT-2026 · PEGAR EN SUPABASE (uno por uno o todo)
-- Ver LEERME_tickets_20261024.md
-- ═══════════════════════════════════════════════════════════════


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmalive_15586.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farmalive · ticket 15586 · 2026-10-24 13:14 · Club Iztapalapa 1
-- 8 renglones / 13 unidades. Subtotal $2,120.90 − desc. $42.42 → neto $2,078.48.
-- Costo = P.U. neto del renglón (2%). Sin lote ni MMAA.
-- Brillantina Palmolive: ticket trunca a 8 dígitos 75001865 (EAN-8 de catálogo).
-- Oral-B Kids Mickey: papel Importe $50.37 vs 2×$25.19=$50.38 (1¢).
-- 6 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_15586 (
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

insert into _fc_fl_15586 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501058626479', 'FC-58626479', 'NAN 2 Optimal Pro', 'LECHE NAN 2 OPTIMAL PRO 1.2 KG 2PACK | MARCAS NESTLE', 2, 847.70, 1060, 'marca', 'Bebés', 'Fórmula infantil', 'Polvo', 'NAN', 'Nestlé', 'Paquete 2 × 1.2 kg', null, null, false, false, null, null, null),
  (2, '7506425648634', 'FC-25648634', 'Pañal Suavelastic Recién Nacido Etapa 1', 'PAÑAL SUAVELASTIC REC NACIDO E1 C/20 | KIMBERLY CLARK', 1, 47.73, 60, 'marca', 'Bebés', 'Pañales', null, 'Suavelastic', 'Kimberly-Clark', 'Bolsa con 20 pañales', null, null, false, false, null, null, null),
  (3, '7506425608867', 'FC-25608867', 'Toallas húmedas Huggies Pure & Natural', 'TOA HUM HUGGIES PURE NAT 2PACK C/80 | KIMBERLY CLARK', 1, 77.03, 97, 'marca', 'Bebés', 'Toallitas', null, 'Huggies', 'Kimberly-Clark', '2-pack con 80 toallitas', null, null, false, false, null, null, null),
  (4, '7501125174797', 'FC-51747971', 'Electrolit Mora Azul', 'ELECTROLIT MORA AZUL 625 ML | LAB PISA', 3, 19.60, 25, 'marca', 'Bebidas', 'Electrolitos', 'Bebida', 'Electrolit', 'Pisa', 'Botella 625 mL', null, null, false, true, null, null, null),
  (5, '75001865', 'FC-75001865', 'Brillantina Palmolive', 'BRILLANTINA PALMOLIVE LIQ 115 ML | COLGATE PALMOLIVE', 2, 49.39, 62, 'marca', 'Cuidado personal', 'Cabello', 'Brillantina', 'Palmolive', 'Colgate-Palmolive', 'Envase 115 mL', null, null, false, true, null, null, null),
  (6, '7500435127363', 'FC-35127363', 'Oral-B Kids Mickey', 'CREMA DENT ORAL-B KIDS MICKEY 37 ML | PG PERF', 2, 25.19, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Oral-B', 'P&G', 'Tubo 37 mL', null, null, false, false, null, null, null),
  (7, '7500435137737', 'FC-35137737', 'Oral-B Kids Princess', 'CREMA DENT ORAL-B KIDS PRINCESS 37 ML | PG PERF', 1, 25.19, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Oral-B', 'P&G', 'Tubo 37 mL', null, null, false, false, null, null, null),
  (8, '7500435145152', 'FC-35145152', 'Oral-B Kids Spiderman', 'CRE DENT ORAL-B KIDS SPIDERMAN 37 ML | PG PERF', 1, 25.19, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Oral-B', 'P&G', 'Tubo 37 mL', null, null, false, false, null, null, null);

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
  'Alta Farmalive 15586 · 2026-10-24 · listo para pistola',
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
  from _fc_fl_15586
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
  from _fc_fl_15586
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
  from _fc_fl_15586
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '15586',
  '2026-10-24',
  2078.50,
  'borrador',
  'Ticket Farmalive 15586 · Club Iztapalapa 1 · 24-oct-2026 13:14 · cliente FARMACAPITAL · descuento 2% por renglón · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '15586'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 2078.50,
  fecha = '2026-10-24',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 15586 · Club Iztapalapa 1 · 24-oct-2026 13:14 · cliente FARMACAPITAL · descuento 2% por renglón · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '15586'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '15586'
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
from _fc_fl_15586 t
join public.recepciones r
  on r.folio = '15586'
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
from _fc_fl_15586 t
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
where r.folio = '15586'
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
from _fc_fl_15586 t
order by t.linea;

commit;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- INICIO: patch_carga_farmamayoreo_241026.sql
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Farma Mayoreo · folio provisional 241026 · 2026-10-24
-- Foto térmica sin encabezado (sin ID VENTA). Folio = ddmmyy.
-- Cajero Alfredo Luciano Salazar · caja 3 · tarjeta BBVA (mismo POS que 303033).
-- 11 renglones / 16 pzas. SUBTOTAL $638.81 + IVA $98.53 = TOTAL $737.34.
-- P.U. ya trae IVA (suma renglones = TOTAL).
-- GUM Barbie: ticket 70942004428 → EAN canónico 070942004428.
-- Materfol: lote 2610990 del papel; caducidad NO (MMAA de la caja).
-- Fixodent Plus ya en catálogo con foto.
-- 8 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm_241026 (
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

insert into _fc_fm_241026 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506425607808', 'FC-25607808', 'Toallas húmedas Huggies Supreme', 'TOALLAS HUMEDAS HUGGIES SUPREME 80 PIEZAS', 2, 38.50, 49, 'marca', 'Bebés', 'Toallitas', null, 'Huggies', 'Kimberly-Clark', 'Paquete con 80 toallitas', null, null, false, false, null, null, null),
  (2, '7502304290383', 'FC-04290383', 'GUM gel dental Stranger Things', 'GEL DENT GUM STRANGER THINGS 75 ML', 1, 40.02, 51, 'marca', 'Cuidado personal', 'Higiene bucal', 'Gel dental', 'GUM', 'Sunstar', 'Tubo 75 mL', null, null, false, false, null, null, null),
  (3, '7506425648030', 'FC-25648030', 'Pañal KleenBebé Absorsec Ultra Etapa 3 Mediano', 'PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-3 T-M 16 PIEZAS', 1, 50.98, 64, 'marca', 'Bebés', 'Pañales', null, 'KleenBebé', 'Kimberly-Clark', 'Bolsa con 16 pañales', null, null, false, false, null, null, null),
  (4, '7506339394733', 'FC-39394733', 'Fixodent Plus adhesivo dental', 'ADHESIVO FIXODENT PLUS CON TUBO 35ML', 2, 91.97, 115, 'marca', 'Cuidado personal', 'Higiene bucal', 'Adhesivo', 'Fixodent', 'P&G', 'Tubo 35 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/fixodent-plus-35g.jpg', 'catalogo-propia/fixodent-plus-35g.jpg', null),
  (5, '7501943441408', 'FC-43441408', 'Pañal KleenBebé Absorsec Ultra Etapa 5 Jumbo', 'PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-5 T-J 14 PIEZAS', 1, 62.98, 79, 'marca', 'Bebés', 'Pañales', null, 'KleenBebé', 'Kimberly-Clark', 'Bolsa con 14 pañales', null, null, false, false, null, null, null),
  (6, '7898185415114', 'FC-85415114', 'GUM kit viaje Bob Esponja', 'KIT VIAJE GUM CEP DENTAL+GEL BOB ESPONJA', 1, 64.85, 82, 'marca', 'Cuidado personal', 'Higiene bucal', 'Kit', 'GUM', 'Sunstar', 'Cepillo + gel dental', null, null, false, false, null, null, null),
  (7, '070942004428', 'FC-42004428', 'Cepillo dental GUM Barbie', 'CEPILLO DENTAL GUM BARBIE', 2, 28.29, 36, 'marca', 'Cuidado personal', 'Higiene bucal', 'Cepillo', 'GUM', 'Sunstar', '1 cepillo', null, null, false, false, null, null, null),
  (8, '759684152047', 'FC-84152047', 'Jaloma chupón cartera balón', 'JALOMA CHUPON CARTERA BALON C/12 PZ', 2, 33.77, 43, 'marca', 'Bebés', 'Accesorios', null, 'Jaloma', 'Jaloma', 'Caja con 12 piezas', null, null, false, false, null, null, null),
  (9, '7501017375189', 'FC-17375189', 'Pañal KleenBebé Absorsec Ultra Etapa 4 Grande', 'PAÑAL KLEEN BEBE ABSORSEC ULTRA ET-4 T-G 14 PIEZAS', 1, 64.97, 82, 'marca', 'Bebés', 'Pañales', null, 'KleenBebé', 'Kimberly-Clark', 'Bolsa con 14 pañales', null, null, false, false, null, null, null),
  (10, '7501943471900', 'FC-43471900', 'Toallas húmedas KleenBebé Absorsec', 'TOALLAS HUMEDAS KLEEN BEBE ABSORSEC 120 PIEZAS', 2, 22.75, 29, 'marca', 'Bebés', 'Toallitas', null, 'KleenBebé', 'Kimberly-Clark', 'Paquete con 120 toallitas', null, null, false, true, null, null, null),
  (11, '7501590222214', 'EQ-CMD015', 'Materfol ácido fólico 400 mcg', 'MATERFOL ACIDO FOLICO 400 MCG FRASCO CON 90 TABLETAS', 1, 22.98, 37, 'generico', 'Medicamentos', 'Vitaminas', 'Tableta', 'Materfol', 'CMD', 'Frasco con 90 tabletas', 'Ácido fólico', '400 mcg', false, true, null, null, '2610990');

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
  'Alta Farma Mayoreo 241026 · 2026-10-24 · listo para pistola',
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
  from _fc_fm_241026
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
  from _fc_fm_241026
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
  from _fc_fm_241026
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '241026',
  '2026-10-24',
  737.34,
  'borrador',
  'Ticket Farma Mayoreo folio provisional 241026 (foto sin encabezado; fecha ddmmyy) · 24-oct-2026 · tarjeta BBVA $737.34 · cola Recibir; stock al confirmar pistola + MMAA · Materfol lote fábrica 2610990'
where not exists (
  select 1 from public.recepciones
  where folio = '241026'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 737.34,
  fecha = '2026-10-24',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo folio provisional 241026 (foto sin encabezado; fecha ddmmyy) · 24-oct-2026 · tarjeta BBVA $737.34 · cola Recibir; stock al confirmar pistola + MMAA · Materfol lote fábrica 2610990',
  updated_at = now()
where folio = '241026'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '241026'
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
from _fc_fm_241026 t
join public.recepciones r
  on r.folio = '241026'
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
from _fc_fm_241026 t
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
where r.folio = '241026'
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
from _fc_fm_241026 t
order by t.linea;

commit;
