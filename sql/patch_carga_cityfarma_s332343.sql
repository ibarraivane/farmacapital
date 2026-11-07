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
