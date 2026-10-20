-- Nadro · folio 6091278111 · 2026-10-18 · NADRO MÉXICO SUR
-- Entrega FARMACAPITAL. 13 pzas · total conceptos $1,008.73 (IVA 0%).
-- DEXAL = ceftibuteno (Maver), no ceftriaxona. Timolol Exakta EAN corto 75049612.
-- Fosfomicina susp EAN 7506513601039 (PVO 7506513601053).
-- Sin caducidad en cola (MMAA de la caja). No inventar 0000.
-- 9 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd_6091278111 (
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

insert into _fc_nd_6091278111 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009745352', 'FC-09745352', 'Dexal ceftibuteno 400 mg', 'DEXAL 400 MG 5 CAPS LGEN', 1, 210.45, 337, 'generico', 'Medicamentos', null, 'Cápsula', 'Dexal', 'Maver', 'Caja con 5 cápsulas', 'Ceftibuteno', '400 mg', true, false, null, null, null),
  (2, '7503049078291', 'FC-49078291', 'Dexlansoprazol 60 mg', 'DEXLANSOPRAZOL 60 MG 7 CAPS LGEN', 1, 94.12, 151, 'generico', 'Medicamentos', null, 'Cápsula', null, 'Avivia', 'Caja con 7 cápsulas', 'Dexlansoprazol', '60 mg', true, false, null, null, null),
  (3, '7502231321709', 'FC-31321709', 'Dorzolamida 20 mg/mL solución oftálmica', 'DORZOLAMIDA 20MG/ML SOL OFT LGEN', 1, 66.08, 106, 'generico', 'Medicamentos', null, 'Solución oftálmica', null, 'Microgrp', 'Frasco gotero', 'Dorzolamida', '20 mg/mL', true, false, null, null, null),
  (4, '7506513601053', 'FC-13601053', 'Fosfomicina polvo para solución 3 g', 'FOSFOMICINA PVO P/SOL 3 G LGEN', 1, 158.93, 255, 'generico', 'Medicamentos', null, 'Polvo', null, 'Avivia', 'Sobre 3 g', 'Fosfomicina trometamol', '3 g', true, false, null, null, null),
  (5, '7506513601039', 'FC-13601039', 'Fosfomicina suspensión 120 mL', 'FOSFOMICINA SUSP FCO 120 ML LGEN', 1, 174.24, 279, 'generico', 'Medicamentos', null, 'Suspensión', null, 'Avivia', 'Frasco 120 mL', 'Fosfomicina', null, true, false, null, null, null),
  (6, '7501349025387', 'FC-49025387', 'Gentamicina 80 mg/2 mL', 'GENTAMICINA 80MG 5 INY 2ML LGEN', 3, 8.47, 14, 'generico', 'Medicamentos', null, 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 5 ampolletas', 'Gentamicina', '80 mg/2 mL', true, false, null, null, null),
  (7, '7506449300372', 'FC-49300372', 'Guaifenesina/oxeladina jarabe', 'GUAIFE/OXOLA 2/1G JBE 140ML LGEN', 1, 31.76, 51, 'generico', 'Medicamentos', null, 'Jarabe', null, 'ADN Pharma', 'Frasco 140 mL', 'Guaifenesina / oxeladina', '2 g/1 g', false, false, null, null, null),
  (8, '7501075727159', 'FC-75727159', 'Moxifloxacino 400 mg', 'MOXIFLOXACINO 400 MG 7 TAB LGEN', 2, 92.65, 149, 'generico', 'Medicamentos', null, 'Tableta', null, 'Novag', 'Caja con 7 tabletas', 'Moxifloxacino', '400 mg', true, false, null, null, null),
  (9, '75049612', 'FC-75049612', 'Timolol 0.50% solución oftálmica', 'TIMOL 0.50% FCO GOT 5ML SOL LGEN', 2, 31.22, 50, 'generico', 'Medicamentos', null, 'Solución oftálmica', 'Exakta', 'Exakta', 'Frasco gotero 5 mL', 'Timolol', '0.50%', true, false, null, null, null);

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
  'Alta Nadro 6091278111 · 2026-10-18 · listo para pistola',
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
  from _fc_nd_6091278111
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
  from _fc_nd_6091278111
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
  from _fc_nd_6091278111
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091278111',
  '2026-10-18',
  1008.73,
  'borrador',
  'Factura Nadro 6091278111 · 18-oct-2026 · entrega FarmaCapital · 9 renglones LGEN · $1,008.73 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091278111'
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1008.73,
  fecha = '2026-10-18',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091278111 · 18-oct-2026 · entrega FarmaCapital · 9 renglones LGEN · $1,008.73 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '6091278111'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091278111'
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
from _fc_nd_6091278111 t
join public.recepciones r
  on r.folio = '6091278111'
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
from _fc_nd_6091278111 t
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
where r.folio = '6091278111'
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
from _fc_nd_6091278111 t
order by t.linea;

commit;
