-- PerfuMax · folio 550937 · 2026-09-18 11:02 · efectivo $1,466.50
-- Comercializadora PerfuMax · RFC PMM211209B57.
-- Canal Rio Churubusco S/N, pasillo F48 A, Central de Abasto, Iztapalapa, CP 09040.
-- Tel 55 7261-7572 · WhatsApp 5534027357 · vendedor ADMIN · 23 piezas.
-- Si el borrador ya existe como F-48 Abasto, este SQL le pone PerfuMax.
-- EAN solo en piezas que ya estaban (Hinds 90 ml, Rexona Efficient 100 g).
-- El resto: alta por SKU FC-F48-* sin código inventado. Toca el renglón.
-- La suma de renglones leídos es $1,466.04; el papel dice $1,466.50.
-- Se respeta el total impreso. No se inventó un centavo en los P.U.
-- 12 alta(s) con stock 0 si el EAN no está. El resto solo costo (PVP si estaba en 0).
-- TODO foto: las altas nuevas no traen packshot en este SQL. No usar placeholder de otra cadena.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_f48_550937 (
  linea integer primary key,
  ean text,
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
  ya boolean not null
) on commit drop;

insert into _fc_f48_550937 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria, forma, marca, laboratorio, presentacion, principio_activo, concentracion, receta, ya
) values

  (1, null, 'FC-F48-LUB750', 'Lubriderm Reparación Intensiva crema 750 ml', 'LUBRIDERM DORADA 750ML REP', 2, 140.00, 175, 'marca', 'Cuidado personal', null, null, 'Lubriderm', null, 'Botella 750 ml', null, null, false, false),
  (2, null, 'FC-F48-LUBA400', 'Lubriderm Aqua crema humectante 400 ml', 'LUBRIDERM AQUA 400ML HUMEC', 2, 90.00, 113, 'marca', 'Cuidado personal', null, null, 'Lubriderm', null, 'Botella 400 ml', null, null, false, false),
  (3, null, 'FC-F48-GRIAV450', 'Grisi shampoo gel avena 450 ml', 'SH GRISI GEL AVENA 450ML', 1, 65.01, 82, 'marca', 'Cuidado personal', null, null, 'Grisi', null, 'Botella 450 ml', null, null, false, false),
  (4, null, 'FC-F48-PIE180', 'Spray pie de atleta 180 ml', 'SPY PIE DE ATLETA 180ML AE', 1, 82.00, 103, 'marca', 'Cuidado personal', null, null, null, null, 'Aerosol 180 ml', null, null, false, false),
  (5, null, 'FC-F48-GRINE450', 'Grisi shampoo gel neutro 450 ml', 'SH GRISI GEL NEUTRO 450ML', 1, 65.01, 82, 'marca', 'Cuidado personal', null, null, 'Grisi', null, 'Botella 450 ml', null, null, false, false),
  (6, null, 'FC-F48-MEX160', 'Mexsana talco 160 g', 'MEXANA 160GR TALCO MEXSANA', 1, 90.00, 113, 'marca', 'Cuidado personal', null, null, 'Mexsana', null, 'Bote 160 g', null, null, false, false),
  (7, null, 'FC-F48-LAC250', 'Lactovit crema corporal 250 ml', 'LACTOVIT (250ML) CREMA', 1, 60.00, 75, 'marca', 'Cuidado personal', null, null, 'Lactovit', null, 'Botella 250 ml', null, null, false, false),
  (8, '037836041297', 'FC-36041297', 'Hinds Inspiración crema 90 ml', 'HINDS INSPIRACION 90', 2, 16.99, 22, 'marca', 'Cuidado personal', null, null, 'Hinds', null, 'Tubo 90 ml', null, null, false, true),
  (9, '7506306257597', 'FC-06257597', 'Talco para pies Rexona Efficient 100 g', 'TCO EFFICIENT 100GR REXONA', 2, 45.01, 57, 'marca', 'Higiene', null, null, 'Rexona', null, 'Bote 100 g', null, null, false, true),
  (10, null, 'FC-F48-LAC400', 'Lactovit crema corporal 400 ml', 'LACTOVIT (400ML) CREMA', 2, 80.01, 101, 'marca', 'Cuidado personal', null, null, 'Lactovit', null, 'Botella 400 ml', null, null, false, false),
  (11, null, 'FC-F48-TAMPREG', 'Tampax Regular', 'TAMPAX REGULAR AMARILLO', 1, 48.00, 60, 'marca', 'Higiene', null, null, 'Tampax', null, 'Caja regular', null, null, false, false),
  (12, null, 'FC-F48-DOVEMEN', 'Dove Men desodorante Invisible', 'DS DOVE MEN INVISIBLE BARR', 2, 53.00, 67, 'marca', 'Higiene', null, null, 'Dove', null, 'Barra', null, null, false, false),
  (13, null, 'FC-F48-REXGEL', 'Rexona Xtracool desodorante gel 80 g', 'DS REXONA XTRACOOL GEL 80G', 2, 65.01, 82, 'marca', 'Higiene', null, null, 'Rexona', null, 'Gel 80 g', null, null, false, false),
  (14, '037836041389', 'FC-36041389', 'Hinds almendras crema 90 ml', 'HINDS ALMENDRA 90ML', 2, 16.99, 22, 'marca', 'Cuidado personal', null, null, 'Hinds', null, 'Tubo 90 ml', null, null, false, true),
  (15, null, 'FC-F48-OLO70', 'Olorex aerosol clásico 70 ml', 'OLOREX AEROSOL CLASICO 70M', 1, 42.00, 53, 'marca', 'Higiene', null, null, 'Olorex', null, 'Aerosol 70 ml', null, null, false, false);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta PerfuMax 550937 · 2026-09-18 · listo para pistola',
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
  t.laboratorio
from _fc_f48_550937 t
where (
    t.ean is not null and public.fc_buscar_producto_escaneo(t.ean) is null
  ) or (
    t.ean is null and public.fc_buscar_producto_escaneo(t.sku) is null
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_f48_550937 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  )
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_f48_550937 t
where p.id = coalesce(
    case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'PerfuMax',
  '550937',
  '2026-09-18',
  1466.50,
  'borrador',
  'Ticket PerfuMax folio 550937 · 18-sep-2026 11:02 · efectivo $1,466.50 · RFC PMM211209B57 · pasillo F48 A Central de Abasto Iztapalapa · tel 55 7261-7572 · WhatsApp 5534027357 · Hinds y Rexona Efficient sí tienen EAN; el resto se toca en el renglón'
where not exists (
  select 1 from public.recepciones
  where folio = '550937'
    and (coalesce(proveedor, '') ilike '%perfumax%' or coalesce(proveedor, '') ilike '%f-48%')
);

update public.recepciones
set
  total_ticket = 1466.50,
  fecha = '2026-09-18',
  proveedor = 'PerfuMax',
  notas = 'Ticket PerfuMax folio 550937 · 18-sep-2026 11:02 · efectivo $1,466.50 · RFC PMM211209B57 · pasillo F48 A Central de Abasto Iztapalapa · tel 55 7261-7572 · WhatsApp 5534027357 · Hinds y Rexona Efficient sí tienen EAN; el resto se toca en el renglón',
  updated_at = now()
where folio = '550937'
  and (coalesce(proveedor, '') ilike '%perfumax%' or coalesce(proveedor, '') ilike '%f-48%')
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '550937'
  and (coalesce(r.proveedor, '') ilike '%perfumax%' or coalesce(r.proveedor, '') ilike '%f-48%')
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
from _fc_f48_550937 t
join public.recepciones r
  on r.folio = '550937'
 and (coalesce(r.proveedor, '') ilike '%perfumax%' or coalesce(r.proveedor, '') ilike '%f-48%')
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) else null end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '550937'
  and (coalesce(r.proveedor, '') ilike '%perfumax%' or coalesce(r.proveedor, '') ilike '%f-48%')
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
