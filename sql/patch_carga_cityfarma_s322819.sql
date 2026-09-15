-- =============================================================================
-- ESTE es el archivo para Supabase (SQL). NO pegues scripts/generar_carga_*.py
-- Archivo: sql/patch_carga_cityfarma_s322819.sql
-- Pegar TODO abajo en Supabase → SQL Editor → Run.
-- =============================================================================
-- Cityfarma Iztapalapa · orden S322819 · 2026-09-14
-- Ticket térmico Central de Abastos. Total $0.00 / Pendiente $738.06 → suma de renglones. Lotes BT1ALD1/AX4250 no se cargan.
-- 2 renglones · 0 altas stock 0 · 2 ya en catálogo.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- Pendientes de foto: ninguna.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s322819 (
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

insert into _fc_cf_s322819 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
  (1, '7501008499412', 'FC-08499412', 'Flanax 660 mg liberación prolongada C/8 tabletas', 'FLANAXPRO 660MG C8 T', 2, 225.16, 361, 'marca', 'Analgésico', null, 'Tableta de liberación prolongada', 'Flanax', 'BAYER', 'Caja con 8 tabletas', 'Naproxeno sódico', '660 mg', false, 'https://www.farmacapital.mx/catalogo-propia/flanax-660mg-8tab-7501008499412.jpg'),
  (2, '7501057002663', 'FC-57002663', 'Lomotil loperamida 2 mg C/8 tabletas', 'LOMOTIL 2 MG C 8 TAB', 2, 143.87, 231, 'marca', 'Gastro', 'Antidiarreico', 'Tableta', 'Lomotil', 'JANSSEN', 'Caja con 8 tabletas', 'Loperamida', '2 mg', false, 'https://www.farmacapital.mx/catalogo-propia/lomotil-2mg-8tab-7501057002663.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-CF-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta Cityfarma S322819 · 2026-09-14 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_cf_s322819 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = case
    when coalesce(p.costo, 0) <= 0 then t.costo
    when t.costo < p.costo then t.costo
    else p.costo
  end,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cf_s322819 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s322819 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S322819',
  '2026-09-14',
  738.06,
  'borrador',
  'Ticket Cityfarma S322819 · 2026-09-14 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S322819' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 738.06,
  fecha = '2026-09-14',
  proveedor = 'Cityfarma Iztapalapa',
  estado = 'borrador',
  notas = 'Ticket Cityfarma S322819 · 2026-09-14 · cola Recibir; stock al confirmar pistola'
where folio = 'S322819'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad');

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S322819'
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
from _fc_cf_s322819 t
join public.recepciones r
  on r.folio = 'S322819'
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
  (producto_id, url, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s322819 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  r.id, r.proveedor, r.folio, r.estado, r.total_ticket,
  (select count(*) from public.recepcion_items i where i.recepcion_id = r.id) as renglones
from public.recepciones r
where r.folio = 'S322819'
order by r.id desc;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'EN CATALOGO' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S322819' and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku, p.codigo_barras as ean, left(p.nombre, 52) as nombre,
  p.marca, p.costo, p.precio, p.stock, left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7501008499412',
  '7501057002663'
)
order by p.nombre;
