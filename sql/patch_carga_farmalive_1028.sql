-- Farmalive · ticket 1028 · 2026-10-02 16:35 · Club Iztapalapa 1
-- 8 renglones / 26 unidades. Subtotal $902.00 − 2% $18.04 = $883.96.
-- Costo = P.U. neto (después del 2%). Sin lote ni MMAA.
-- Broncolin vitrolero C/100 EAN ticket 714706903182 (distinto del C/50).
-- 4 alta(s) stock 0. 4 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_1028 (
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

insert into _fc_fl_1028 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '714706903182', 'FC-06903182', 'Broncolin paletas vitrolero surtido', 'BRONCOLIN PALETA VITROLERO SURTIDO C/100 | BRONCOLIN', 1, 201.29, 252, 'marca', 'Respiratorio', 'Garganta', 'Paleta', 'Broncolin', 'Broncolin', 'Vitrolero con 100 paletas', null, null, false, false, null, null, null),
  (2, '714706918964', 'FC-06918964', 'Broncolin Properlas propóleo y eucalipto', 'PROPERLAS PROPOLEO Y EUCALIPTO 50 G | BRONCOLIN', 1, 27.83, 35, 'marca', 'Respiratorio', 'Garganta', 'Perlas', 'Broncolin', 'Broncolin', 'Bolsa 50 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/properlas-eucalipto-50g-714706918964.jpg', 'catalogo-propia/properlas-eucalipto-50g-714706918964.jpg', null),
  (3, '7502214985805', 'FC-14985805', 'Prudence Chicle condones', 'COND PRUDENCE CHICLE C/5 | DKT MEXICO', 3, 47.63, 60, 'marca', 'Higiene', null, 'Condón', 'Prudence', 'DKT México', 'Caja con 5', null, null, false, true, null, null, null),
  (4, '7502214980015', 'FC-49800151', 'Prudence Clásico condones', 'COND PRUDENCE CLASICO C/3 | DKT MEXICO', 5, 33.03, 42, 'marca', 'Higiene', null, 'Condón', 'Prudence', 'DKT México', 'Caja con 3', null, null, false, true, null, null, null),
  (5, '714706918940', 'FC-06918940', 'Broncolin Properlas propóleo y jengibre', 'PROPERLAS BRONCOLIN PROP Y JENGIBRE 50 G | BRONCOLIN', 1, 27.83, 35, 'marca', 'Respiratorio', 'Garganta', 'Perlas', 'Broncolin', 'Broncolin', 'Bolsa 50 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/properlas-jengibre-50g-714706918940.jpg', 'catalogo-propia/properlas-jengibre-50g-714706918940.jpg', null),
  (6, '650240019180', 'FC-40019180', 'Pomada de la Campana Tepezcohuite', 'POMADA DE LA CAMPANA TEPEZCOHUITE 35 GR | GENOMMA LAB', 5, 23.91, 30, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 35 g', 'Tepezcohuite', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/campana-tepezcohuite-35g-650240019180.jpg', 'catalogo-propia/campana-tepezcohuite-35g-650240019180.jpg', null),
  (7, '7501065628145', 'FC-65628145', 'Pomada de la Campana', 'POMADA DE LA CAMPANA 35 GR | GENOMMA LAB', 5, 23.91, 30, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 35 g', null, null, false, true, null, null, null),
  (8, '7501065628121', 'FC-65628121', 'Pomada de la Campana', 'POMADA DE LA CAMPANA 19 GR | GENOMMA LAB', 5, 15.97, 20, 'marca', 'Dermocosmético', null, 'Pomada', 'Pomada de la Campana', 'Genomma Lab', 'Tarro 19 g', null, null, false, true, null, null, null);

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
  'Alta Farmalive 1028 · 2026-10-02 · listo para pistola',
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
  from _fc_fl_1028
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
  from _fc_fl_1028
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
  from _fc_fl_1028
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '1028',
  '2026-10-02',
  883.96,
  'borrador',
  'Ticket Farmalive 1028 · Club Iztapalapa 1 · 02-oct-2026 · cliente FARMACAPITAL · descuento 2% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '1028'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 883.96,
  fecha = '2026-10-02',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 1028 · Club Iztapalapa 1 · 02-oct-2026 · cliente FARMACAPITAL · descuento 2% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '1028'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '1028'
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
from _fc_fl_1028 t
join public.recepciones r
  on r.folio = '1028'
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
from _fc_fl_1028 t
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
where r.folio = '1028'
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
from _fc_fl_1028 t
order by t.linea;

commit;
