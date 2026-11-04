-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Levic A 9012600253 · 02-nov-2026 · $649.90 · 1 renglón / 2 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run si.
-- Sin bloques dollar-quote. Sin galeria extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio 9012600253 en borrador.
-- Luego: tablet Recibir - recargar.
-- =============================================================================
-- CFDI UUID B7385380-DAD5-497D-AAEE-05AA746339DA · PUE efectivo.
-- Receptor LUIS ANGEL PALILLERO VENTURA · entrega Chinampac.
-- Clave MAV381 = Gladiatron (Maver) glucosamina/condroitina 1500/1200 mg C/30.
-- EAN ficha 7502009749018. Costo = precio neto $324.95. PVP marca +25% = $407.
-- Lote de fabrica en el papel. Caducidad null: MMAA de la caja. No inventar 0000.
-- Foto: public/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg (tras deploy).

begin;

create temp table _fc_rx_levic9012600253 (
  linea integer primary key,
  clave text not null,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  lote text,
  imagen text
) on commit drop;

insert into _fc_rx_levic9012600253 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, laboratorio, presentacion, principio_activo, concentracion,
  receta, lote, imagen
) values
  (
    1,
    'MAV381',
    '7502009749018',
    'FC-09749018',
    'Gladiatron 1500/1200 mg',
    'GLUCOSAM/CONDOITRIN 30 SOB 1500/1200 MG *MAV*',
    2,
    324.95,
    407,
    'marca',
    'Medicamentos',
    'Polvo',
    'Gladiatron',
    'Maver',
    'Caja con 30 sobres',
    'Glucosamina / condroitina',
    '1500/1200 mg',
    false,
    '264793',
    'https://www.farmacapital.mx/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
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
  t.tipo,
  'Alta Levic 9012600253 · clave ' || t.clave || ' · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_rx_levic9012600253 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean),
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_rx_levic9012600253 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012600253',
  '2026-11-02',
  649.90,
  'borrador',
  'Factura Levic A 9012600253 · CFDI B7385380-DAD5-497D-AAEE-05AA746339DA · Gladiatron MAV381 · $649.90 · cola Recibir; stock al confirmar pistola · lote de fabrica; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012600253' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 649.90,
  fecha = '2026-11-02',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012600253 · CFDI B7385380-DAD5-497D-AAEE-05AA746339DA · Gladiatron MAV381 · $649.90 · cola Recibir; stock al confirmar pistola · lote de fabrica; MMAA de la caja',
  updated_at = now()
where folio = '9012600253'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_rx_levic9012600253 t
join public.recepciones r
  on r.folio = '9012600253'
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  bool_or(coalesce(i.pendiente_alta, false)) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote as lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'OK' end as estado,
  p.sku,
  p.precio
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
