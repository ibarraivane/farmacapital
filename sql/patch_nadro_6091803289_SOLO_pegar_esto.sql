-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Nadro factura 6091803289 · 2026-11-01 · $1,173.88 · 5 renglones / 6 piezas
-- Costo = VALOR UNITARIO de la factura (Actron con OFTA 8% ya aplicado en 118.40).
-- PVP altas = recargo sobre costo (marca ×1.25 / genérico ×1.60). No margen sobre venta.
-- Actron 600 ya existe (FC-18652453). Altas: Aliren jarabe 60/120, Dapagliflozina/Metformina,
-- Ociplos Disper. Nombres de ficha, no del ticket. Sin bloques dollar-quote.
-- Caducidad null: MMAA de la caja. Lote de la factura en numero_lote.
-- Idempotente mientras el ticket siga en borrador.
-- Fotos en public/catalogo-propia/ (tras deploy). Luego patch_fotos_nadro_6091803289.sql
-- =============================================================================

begin;

create temp table _fc_nd6091803289 (
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
  marca text,
  presentacion text,
  forma text,
  laboratorio text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  alta_nueva boolean not null,
  imagen text,
  lote text
) on commit drop;

insert into _fc_nd6091803289
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta,
   alta_nueva, imagen, lote)
values
  (1, '7501318652453', 'FC-18652453', 'Actron 600 mg', 'ACTRON-600 600 MG 10 CAPS', 1, 118.40, 148, 'marca', 'Medicamentos', 'Analgésico', 'Actron', 'Caja con 10 cápsulas', 'Cápsulas', 'Bayer', 'Ibuprofeno', '600 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/actron-600mg-10caps-7501318652453.jpg', 'X26R7T'),
  (2, '7501300420558', 'FC-00420558', 'Aliren jarabe', 'ALIREN 500/.020/3G- 100ML JBE 60ML', 1, 99.38, 125, 'marca', 'Medicamentos', 'Respiratorio', 'Aliren', 'Caja con frasco 60 ml', 'Jarabe', 'Siegfried Rhein', 'Amantadina / clorfenamina / paracetamol', '0.5/0.02/3 g/100 ml', false, true, 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-60ml-7501300420558.jpg', '250115'),
  (3, '7501300422132', 'FC-00422132', 'Aliren jarabe', 'ALIREN 500/.020/3G 100ML JBE 120ML', 1, 121.25, 152, 'marca', 'Medicamentos', 'Respiratorio', 'Aliren', 'Caja con frasco 120 ml', 'Jarabe', 'Siegfried Rhein', 'Amantadina / clorfenamina / paracetamol', '0.5/0.02/3 g/100 ml', false, true, 'https://www.farmacapital.mx/catalogo-propia/aliren-jarabe-120ml-7501300422132.jpg', '260511'),
  (4, '7506513601114', 'FC-13601114', 'Dapagliflozina / Metformina 10/1000 mg', 'DAPAGL/METFO 10/1000MG 14TABLGEN', 1, 344.49, 552, 'generico', 'Medicamentos', 'Diabetes', 'Avivia', 'Caja con frasco 14 tabletas', 'Tableta de liberación prolongada', 'Avivia Pharma', 'Dapagliflozina / metformina', '10/1000 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/dapagliflozina-metformina-10-1000-c14-7506513601114.jpg', 'DRF07633B'),
  (5, '7502227876077', 'FC-27876077', 'Ociplos Disper 30 mg', 'OCIPLOS DISPER 30 MG 30 TAB LGEN', 2, 245.18, 393, 'generico', 'Medicamentos', 'Sistema nervioso', 'Ociplos', 'Caja con 30 tabletas dispersables', 'Tableta dispersable', 'RAAM', 'Mirtazapina', '30 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/ociplos-disper-30mg-c30-7502227876077.jpg', 'RCP107');

-- Altas nuevas (solo si el EAN no existe).
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
  'Alta Nadro 6091803289 · 2026-11-01 · listo para pistola',
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
from _fc_nd6091803289 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían / altas: costo. PVP solo si estaba en 0 / ≤1.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_nd6091803289 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
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
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  tipo = coalesce(nullif(trim(p.tipo), ''), t.tipo),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from _fc_nd6091803289 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091803289',
  '2026-11-01',
  1173.88,
  'borrador',
  'Factura Nadro 6091803289 · 01-nov-2026 · $1,173.88 · 5 renglones / 6 piezas · bolsas 300041390282 y 300041395793 · cola Recibir; stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '6091803289' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 1173.88,
  fecha = '2026-11-01',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091803289 · 01-nov-2026 · $1,173.88 · 5 renglones / 6 piezas · bolsas 300041390282 y 300041395793 · cola Recibir; stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = '6091803289'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091803289'
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
  t.snap,
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
from _fc_nd6091803289 t
join public.recepciones r
  on r.folio = '6091803289'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

-- Diagnóstico renglones
select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote as lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091803289' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '6091803289'
  and coalesce(r.proveedor, '') ilike '%nadro%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;
