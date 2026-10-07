-- Farmalive · ticket 13999 · 2026-10-06 16:41 · Club Iztapalapa 1
-- 8 renglones / 23 unidades. Subtotal $798.10 − desc. $19.41 → neto $778.70.
-- Costo = P.U. neto del renglón (2% o 5%). Sin lote ni MMAA.
-- Ticket trunca Suerox/Asepxia a 12 dígitos; pistola = EAN canónico 650…4.
-- Algodón Dibar 50 g: 12 pzas (cantidad marcada a mano en el ticket).
-- 3 alta(s) stock 0. 5 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_13999 (
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

insert into _fc_fl_13999 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501008409534', 'FC-08409534', 'Saridon EXH', 'SARIDON EXH TAB C/100 | BAYER OTC', 1, 269.50, 337, 'marca', 'Medicamentos', null, 'Tableta', 'Saridon', 'Bayer OTC', 'Caja con 100 tabletas', 'Paracetamol / propyfenazona / cafeína', null, false, false, null, null, null),
  (2, '7502214980350', 'FC-14980350', 'Prudence Lub lubricante íntimo mora azul', 'LUBRICANTE PRUDENCE MORA AZUL 75 ML | DKT MEXICO', 1, 70.17, 88, 'marca', 'Cuidado personal', 'Íntimo', 'Gel', 'Prudence', 'DKT México', 'Tubo 75 mL', null, null, false, true, null, null, null),
  (3, '6502400746914', 'FC-40074691', 'Asepxia jabón suavizante', 'ASEPXIA JABON SUAVIZANTE 100 GR 4PACK | GENOMMA LAB', 1, 49.98, 63, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Asepxia', 'Genomma Lab', 'Paquete con 4 barras de 100 g', null, null, false, false, null, null, null),
  (4, '6502400046434', 'FC-40004643', 'Asepxia jabón exfoliante', 'ASEPXIA JABON EXFOLIANTE 100 GR | GENOMMA LAB', 2, 39.80, 50, 'marca', 'Cuidado personal', 'Piel', 'Jabón', 'Asepxia', 'Genomma Lab', 'Barra 100 g', null, null, false, true, null, null, null),
  (5, '7501008409541', 'FC-84095411', 'Saridon', 'SARIDON TAB C/20 | BAYER OTC', 2, 63.45, 80, 'marca', 'Medicamentos', null, 'Tableta', 'Saridon', 'Bayer OTC', 'Caja con 20 tabletas', 'Paracetamol / propyfenazona / cafeína', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/saridon-c20.jpg', 'catalogo-propia/saridon-c20.jpg', null),
  (6, '6502400322644', 'FC-40032264', 'Suerox 8 iones fresa kiwi', 'SUEROX 8IONES FRESA KIWI 630 ML | GENOMMA LAB', 2, 14.72, 19, 'marca', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (7, '7503003406167', 'FC-03406167', 'Cinta micropore Quirmex piel', 'CINTA MICROPOR QUIRMEX PIEL 2.5CMX10M | QUIRMEX', 2, 17.15, 22, 'marca', 'Botiquín', 'Material de curación', 'Cinta', 'Quirmex', 'Quirmex', 'Rollo 2.5 cm × 10 m', null, null, false, false, null, null, null),
  (8, '7501868910034', 'FC-68910034', 'Dibar algodón', 'ALGODON DIBAR 50 GR | DIBAR', 12, 9.90, 13, 'marca', 'Botiquín', 'Material de curación', 'Algodón', 'Dibar', 'Dibar', 'Bolsa 50 g', null, null, false, true, null, null, null);

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
  'Alta Farmalive 13999 · 2026-10-06 · listo para pistola',
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
  from _fc_fl_13999
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
  from _fc_fl_13999
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
  from _fc_fl_13999
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '13999',
  '2026-10-06',
  778.70,
  'borrador',
  'Ticket Farmalive 13999 · Club Iztapalapa 1 · 06-oct-2026 · cliente FARMACAPITAL · descuentos por renglón 2%/5% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '13999'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 778.70,
  fecha = '2026-10-06',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 13999 · Club Iztapalapa 1 · 06-oct-2026 · cliente FARMACAPITAL · descuentos por renglón 2%/5% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '13999'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '13999'
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
from _fc_fl_13999 t
join public.recepciones r
  on r.folio = '13999'
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
from _fc_fl_13999 t
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
where r.folio = '13999'
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
from _fc_fl_13999 t
order by t.linea;

commit;
