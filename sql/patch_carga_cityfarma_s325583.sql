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
