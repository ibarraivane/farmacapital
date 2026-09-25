-- Farmalive · ticket 14173 · 2026-09-21 17:25 · Club Iztapalapa 1
-- Total $1,538.69 · 19 artículos / 39 unidades.
-- Ticket trunca Suerox a 12 dígitos; pistola = EAN 650…2 del catálogo.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 6 alta(s) stock 0. 13 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_14173 (
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

insert into _fc_fl_14173 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506306215689', 'FC-06215689', 'Ego Alfa Control caída gel 200 mL', 'GEL EGO ALFA CONT CAIDA 200 ML | UNILEVER', 3, 17.21, 22, 'marca', 'Cuidado personal', 'Capilar', 'Gel', 'Ego', 'Unilever', 'Frasco 200 mL', null, null, false, false, null, null, null),
  (2, '7501033956331', 'FC-33950063', 'Pediasure Plus líquido fresa 237 mL', 'PEDIASURE PLUS LIQ FRESA 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg', 'pediasure-plus-vainilla-237ml.jpg', null),
  (3, '7501033956317', 'FC-33951008', 'Pediasure Plus líquido chocolate 237 mL', 'PEDIASURE PLUS LIQ CHOCOLATE 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-chocolate-237ml.jpg', 'pediasure-plus-chocolate-237ml.jpg', null),
  (4, '7501033956294', 'FC-33950209', 'Pediasure Plus líquido vainilla 237 mL', 'PEDIASURE PLUS LIQ VAINILLA 237 ML | ABBOTT', 2, 46.08, 58, 'marca', 'Suplemento', null, 'Líquido', 'Pediasure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pediasure-plus-vainilla-237ml.jpg', 'pediasure-plus-vainilla-237ml.jpg', null),
  (5, '7501033954085', 'FC-33954085', 'Ensure líquido vainilla 237 mL', 'ENSURE LIQ VAINILLA 237 ML | ABBOTT', 4, 42.63, 54, 'marca', 'Suplemento', null, 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-fresa-237ml.jpg', 'ensure-singles-fresa-237ml.jpg', null),
  (6, '7501033954061', 'FC-33954061', 'Ensure líquido chocolate 237 mL', 'ENSURE LIQ CHOCOLATE 237 ML | ABBOTT', 4, 42.63, 54, 'marca', 'Suplemento', null, 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-chocolate-237ml.jpg', 'ensure-singles-chocolate-237ml.jpg', null),
  (7, '7501019006647', 'FC-19006647', 'Saba buenas noches delgada C/10', 'TOA SANIT SABA U DELGADA NOCT C/A 10 | SCA', 2, 29.83, 38, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'SCA', 'Paquete 10 toallas', null, null, false, false, null, null, null),
  (8, '6502400744552', 'FC-40074455', 'Suerox 8 iones uva mora azul 630 mL', 'SUEROX 8 IONES UVA MORA AZUL 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (9, '6502400322571', 'FC-00322571', 'Suerox 8 iones manzana 630 mL', 'SUEROX 8 IONES MANZANA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (10, '7501048607214', 'FC-00721471', 'Suerox Vitamins naranja-mango 630 mL', 'SUEROX VITAMINS NARANJA-MANGO 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (11, '6502400322712', 'FC-40032271', 'Suerox 8 iones uva 630 mL', 'SUEROX 8 IONES UVA 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (12, '6502400721541', 'FC-00721541', 'Suerox Vitamins manzana y limón 630 mL', 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (13, '7500435231237', 'FC-35231237', 'Head & Shoulders anti comezón shampoo 375 mL', 'SHAM HEAD & S ANTI-COMEZON 375 ML | PG PERF', 1, 86.07, 108, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 375 mL', null, null, false, true, null, null, null),
  (14, '7500435162586', 'FC-35162586', 'Head & Shoulders protección caída shampoo 650 mL', 'SHAM HEAD & S PROT CAIDA 650 ML | PG PERF', 1, 123.03, 154, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 650 mL', null, null, false, false, null, null, null),
  (15, '7500435249348', 'FC-35249348', 'Head & Shoulders anti resequedad shampoo 375 mL', 'SHAM HEAD & S ANTI RESEQUEDAD 375 ML | PG PERF', 1, 86.07, 108, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 375 mL', null, null, false, false, null, null, null),
  (16, '7891051037878', 'FC-51037878', 'Oral-B Complete enjuague bucal 250 mL', 'ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF', 2, 47.75, 60, 'marca', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'Oral-B', 'P&G', 'Botella 250 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-complet-250ml.jpg', 'oral-b-enjuague-complet-250ml.jpg', null),
  (17, '7500435231244', 'FC-35231244', 'Head & Shoulders anti comezón shampoo 180 mL', 'SHAM HEAD & S ANTI-COMEZON 180 ML | PG PERF', 2, 39.43, 50, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 180 mL', null, null, false, true, null, null, null),
  (18, '7503003406181', 'FC-03406181', 'Cinta micropore Quirmex blanca 2.5 cm × 10 m', 'CINTA MICROPOR QUIRMEX BCO 2.5CMX10M | QUIRMEX', 2, 16.83, 22, 'marca', 'Botiquín', 'Material de curación', 'Cinta', 'Quirmex', 'Quirmex', 'Rollo 2.5 cm × 10 m', null, null, false, false, null, null, null),
  (19, '7506022301789', 'FC-22301789', 'Jeringa Sensimedical 3 mL azul C/100', 'JERINGA SENSIMEDICAL 3 ML AZUL C/100 | JAYOR', 1, 159.50, 200, 'marca', 'Botiquín', 'Material médico', 'Jeringas', 'Sensimedical', 'Jayor', 'Caja 100 jeringas 3 mL', null, null, false, false, null, null, null);

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
  'Alta Farmalive 14173 · 2026-09-21 · listo para pistola',
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
  from _fc_fl_14173
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
  from _fc_fl_14173
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
  from _fc_fl_14173
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '14173',
  '2026-09-21',
  1538.69,
  'borrador',
  'Ticket Farmalive 14173 · Club Iztapalapa 1 · 21-sep-2026 · precio neto (2–7% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '14173'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1538.69,
  fecha = '2026-09-21',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 14173 · Club Iztapalapa 1 · 21-sep-2026 · precio neto (2–7% desc.) · Suerox naranja-mango EAN botella 7501048607214 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '14173'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14173'
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
from _fc_fl_14173 t
join public.recepciones r
  on r.folio = '14173'
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
from _fc_fl_14173 t
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
where r.folio = '14173'
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
from _fc_fl_14173 t
order by t.linea;

commit;
