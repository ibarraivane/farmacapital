-- Cityfarma Iztapalapa · orden S3210855 · 2026-09-06 17:07 (impreso 2026-09-08 17:13)
-- Ticket térmico Central de Abastos. P.U. ya trae IVA.
-- Total impreso $1413.98. Suma de 9 renglones $1413.74 (24¢ de redondeo).
-- 3 altas stock 0: Microlax C/4, Sico Sensitive C/9, TempraFen 400 mg C/10.
-- 6 ya estaban. Costo solo si este ticket es más barato (o no había).
--   Baja: Bedoyecta 273.42→225.00 · Bepanthen 131.81→64.37 · Softlube 94.75→80.82
--   No pisa: Sico Cereza 95.79 / Sico Rojo 54.71 / Tums 37.48
-- Tums se renombra (estaba 'TUMS') para no confundirlo con el C/48.
-- Bepanthen se renombra si quedó como 'Bepanthen Cutanea'.
-- Softlube: nombre cortado + quita 'Latex' (es gel, no condón).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos nuevas en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s3210855 (
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
  foto_file text
) on commit drop;

insert into _fc_cf_s3210855 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file
) values
  (1, '7501123013302', 'FC-30133021', 'Bedoyecta Tri ampolleta', 'BEDOYECTA TRI AMP', 1, 225.00, 360, 'marca', 'Vitaminas', null, 'Ampolleta', 'Bedoyecta', 'BAUSCH LOMB MEXICO', 'Ampolleta inyectable', 'Hidroxocobalamina / tiamina / piridoxina', null, false, true, null, null),
  (2, '7501008498798', 'FC-08498798', 'Bepanthen Multiusos pomada 30 g', 'BEPANTHEN 30G MULTI', 2, 64.37, 103, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'BAYER OTC', 'Tubo 30 g', 'Dexpantenol', null, false, true, null, null),
  (3, '7501007532387', 'FC-07532387', 'Microlax laxante C/4 microenemas', 'MICROLAX ENEMAS C4', 1, 179.33, 287, 'marca', 'Gastro', 'Laxante', 'Microenema', 'Microlax', 'KENVUE', 'Caja con 4 microenemas de 5 ml', 'Citrato de sodio + laurilsulfato de sodio', '90 mg / 9 mg/ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/microlax-c4-7501007532387.jpg', 'catalogo-propia/microlax-c4-7501007532387.jpg'),
  (4, '7501058368133', 'FC-58368133', 'Sico Sensitive condones delgados C/9', 'SICO C9 ROJO SENSITIVE', 1, 156.62, 251, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Sico', 'RB HEALTH', 'Cartera con 9', 'Látex', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sico-sensitive-c9-7501058368133.jpg', 'catalogo-propia/sico-sensitive-c9-7501058368133.jpg'),
  (5, '7501058793232', 'FC-87932321', 'Sico lubricante cereza 50 ml', 'SICO LUBRIC CEREZA', 3, 96.59, 155, 'marca', 'Cuidado personal', 'Salud sexual', 'Lubricante', 'Sico', 'RB HEALTH', 'Frasco 50 ml', null, null, false, true, null, null),
  (6, '7501058368126', 'FC-83683367', 'Sico Rojo Feel condones C/3', 'SICO ROJO SENS C3', 2, 55.74, 90, 'marca', 'Cuidado personal', 'Salud sexual', 'Condón', 'Sico', 'RB HEALTH', 'Cartera con 3', 'Látex', null, false, true, null, null),
  (7, '7506460101514', 'FC-01015141', 'Sico Softlube gel lubricante original 56.7 g', 'SICO SOFTLUBE GEL', 2, 80.82, 130, 'marca', 'Cuidado personal', 'Salud sexual', 'Lubricante', 'Sico', 'RB HEALTH', 'Tubo 56.7 g', null, null, false, true, null, null),
  (8, '7506460101002', 'FC-60101002', 'TempraFen ibuprofeno 400 mg C/10', 'TEMPRA FEN 400MG C10', 2, 60.86, 98, 'marca', 'Analgésico', null, 'Cápsulas', 'TempraFen', 'RB HEALTH', 'Caja con 10 cápsulas', 'Ibuprofeno', '400 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/tempra-fen-400mg-c10-7506460101002.jpg', 'catalogo-propia/tempra-fen-400mg-c10-7506460101002.jpg'),
  (9, '7501065054043', 'FC-65054135', 'Tums Extra surtido 750 mg C/3 (3 rollos × 8)', 'TUMS SURT C3', 1, 39.44, 64, 'marca', 'Gastro', 'Antiácido', 'Tableta masticable', 'Tums', 'HALEON', '3 rollos × 8 tabletas', 'Carbonato de calcio', '750 mg', false, true, null, null);

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
    ) then 'FC-CF-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma S3210855 · 2026-09-06 · listo para pistola',
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
from _fc_cf_s3210855 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo solo si el ticket es más barato (o no había). PVP solo si está en 0.
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
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    coalesce(p.costo, 0) <= 0
    or t.costo < p.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Tums C/3: el nombre corto choca con el C/48 y no dice la presentación.
update public.productos p
set nombre = t.nombre,
    marca = t.marca,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
    concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
    laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501065054043'
  and (
    p.nombre ~* '^tums$'
    or length(trim(p.nombre)) <= 8
    or coalesce(p.presentacion, '') ~* '^8 tabletas$'
  );

-- Bepanthen 30 g: 'Cutanea' no es el nombre de mostrador.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
    categoria = case
      when coalesce(p.categoria, '') ~* '^(otro|general)$' then t.categoria
      else p.categoria
    end,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501008498798'
  and (
    p.nombre ~* 'cutanea'
    or length(trim(p.nombre)) <= 20
  );

-- Softlube: nombre cortado 'Origin'. El principio 'Latex' es del condón, no del gel.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
    principio_activo = case
      when coalesce(p.principio_activo, '') ~* 'latex' then null
      else p.principio_activo
    end,
    categoria = case
      when coalesce(p.categoria, '') ~* '^(otro|general)$' then t.categoria
      else p.categoria
    end,
    subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
from _fc_cf_s3210855 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7506460101514';

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S3210855',
  '2026-09-06',
  1413.98,
  'borrador',
  'Ticket Cityfarma S3210855 · 2026-09-06 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'S3210855' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1413.98,
  fecha = '2026-09-06',
  proveedor = 'Cityfarma Iztapalapa'
where folio = 'S3210855'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S3210855'
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
from _fc_cf_s3210855 t
join public.recepciones r
  on r.folio = 'S3210855'
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cf_s3210855 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = 'S3210855' and coalesce(r.proveedor, '') ilike '%cityfarma%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7501123013302',
  '7501008498798',
  '7501007532387',
  '7501058368133',
  '7501058793232',
  '7501058368126',
  '7506460101514',
  '7506460101002',
  '7501065054043'
)
order by p.nombre;
