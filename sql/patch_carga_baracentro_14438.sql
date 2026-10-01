-- Baracentro · folio 14438 · 2026-09-30 17:25 · Central de Abasto F34 B
-- 1 pieza · total $95.00. P.U. = costo.
-- Piezas ticket (suma qty): 1. Total $95.00.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): ninguno.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bara_14438 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,3) not null,
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

insert into _fc_bara_14438 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501438363321', 'FC-38363321', 'Kuul Fix Me Urban gel fijador', 'KUUL FIX ME URB', 1, 95.00, 119, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'Kuul', null, 'Pieza', null, null, false, false, null, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Baracentro 14438 · 2026-09-30 · listo para pistola',
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
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bara_14438
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bara_14438
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
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
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bara_14438
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Baracentro', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Baracentro')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Baracentro',
  '14438',
  '2026-09-30',
  95.00,
  'borrador',
  'Baracentro 14438 · 30-sep-2026 · Kuul Fix Me Urban · stock al escanear'
where not exists (
  select 1 from public.recepciones
  where folio = '14438'
    and coalesce(proveedor, '') ilike '%Baracentro%'
);

update public.recepciones
set
  total_ticket = 95.00,
  fecha = '2026-09-30',
  proveedor = 'Baracentro',
  notas = 'Baracentro 14438 · 30-sep-2026 · Kuul Fix Me Urban · stock al escanear',
  updated_at = now()
where folio = '14438'
  and coalesce(proveedor, '') ilike '%Baracentro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14438'
  and coalesce(r.proveedor, '') ilike '%Baracentro%'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_bara_14438 t
join public.recepciones r
  on r.folio = '14438'
 and coalesce(r.proveedor, '') ilike '%Baracentro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bara_14438
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '14438'
  and coalesce(r.proveedor, '') ilike '%Baracentro%'
order by i.id;
