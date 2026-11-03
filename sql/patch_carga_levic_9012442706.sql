-- Levic · factura interna A 9012442706 · CFDI 2026-10-12 · entrega 833148360
-- Receptor LUIS ANGEL PALILLERO VENTURA · 11 renglones · 25 pzas (TOT 25).
-- Subtotal $930.48 + IVA $13.33 (Seltz Magnesio Complex) = $943.81.
-- Costo = Precio neto. Lote = de fábrica. Caducidad del papel NO se escribe (MMAA de la caja).
-- 0000 es inválido. Altas stock 0. En existentes solo costo (no el PVP).
-- Nombres de packshot Visoti, no del renglón del ticket.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Tras deploy Vercel: sql/patch_fotos_levic_9012442706.sql

begin;

create temp table _fc_rx_levic9012442706 (
  linea integer primary key,
  clave text not null,
  ean text,
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
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  stock_minimo integer not null,
  lote text,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_rx_levic9012442706 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen, foto_file
) values
  (1, 'ALP0609', '7501384541620', 'FC-84541620', 'Gabapentina 400 mg', 'Gabapentina 400 mg', 1, 54.16, 87, 'generico', 'Medicamentos', 'Cápsulas', 'Psicofarma', 'Caja con 15 cápsulas', 'Gabapentina', '400 mg', true, 1, '6080726', 'https://www.farmacapital.mx/catalogo-propia/gabapentina-psicofarma-400-7501384541620.jpg', 'catalogo-propia/gabapentina-psicofarma-400-7501384541620.jpg'),
  (2, 'ALP0675', null, 'EQ-ALP0675', 'Rosuvastatina 20 mg', 'Rosuvastatina 20 mg', 1, 43.85, 71, 'generico', 'Medicamentos', 'Tabletas', 'Alpharma', 'Caja con 15 tabletas', 'Rosuvastatina', '20 mg', true, 1, '2609123', 'https://www.farmacapital.mx/catalogo-propia/rosuvastatina-alpharma-20mg-15tab.jpg', 'catalogo-propia/rosuvastatina-alpharma-20mg-15tab.jpg'),
  (3, 'AMS322', '7501349021181', 'EQ-AMS322', 'Cefalexina 500 mg', 'Cefalexina 500 mg', 4, 39.58, 64, 'generico', 'Medicamentos', 'Cápsulas', 'AMSA', 'Caja con 20 cápsulas', 'Cefalexina', '500 mg', true, 2, 'J26A067', 'https://www.farmacapital.mx/catalogo-propia/cefalexina-amsa-500-7501349021181.jpg', 'catalogo-propia/cefalexina-amsa-500-7501349021181.jpg'),
  (4, 'AMS329', '7501349020436', 'FC-49020436', 'Gabapentina 300 mg', 'Gabapentina 300 mg', 2, 23.27, 38, 'generico', 'Medicamentos', 'Cápsulas', 'AMSA', 'Caja con 15 cápsulas', 'Gabapentina', '300 mg', true, 2, 'U26E313', 'https://www.farmacapital.mx/catalogo-propia/gabapentina-amsa-300-7501349020436.jpg', 'catalogo-propia/gabapentina-amsa-300-7501349020436.jpg'),
  (5, 'BEA394', '7501342803715', 'FC-42803715', 'Telmisartán 40 mg', 'Telmisartán 40 mg', 2, 39.35, 63, 'generico', 'Medicamentos', 'Tabletas', 'beadvance', 'Caja con frasco con 30 tabletas', 'Telmisartán', '40 mg', true, 2, 'U26F330', 'https://www.farmacapital.mx/catalogo-propia/telmisartan-beadvance-40-7501342803715.jpg', 'catalogo-propia/telmisartan-beadvance-40-7501342803715.jpg'),
  (6, 'CHI055', '7501088505485', 'FC-88505485', 'Synalar-O', 'Synalar-O', 1, 188.05, 236, 'marca', 'Medicamentos', 'Solución ótica', 'Synalar-O', 'Frasco gotero 15 mL', 'Fluocinolona / lidocaína / neomicina / polimixina B', '0.25 mg/mL', false, 1, 'BEK048', 'https://www.farmacapital.mx/catalogo-propia/synalar-otico-15ml-7501088505485.jpg', 'catalogo-propia/synalar-otico-15ml-7501088505485.jpg'),
  (7, 'GEN002', '7501842900105', 'FC-42900105', 'Adopren 600 mg', 'Adopren 600 mg', 5, 15.93, 20, 'marca', 'Medicamentos', 'Tabletas', 'Adopren', 'Caja con 10 tabletas', 'Ibuprofeno', '600 mg', false, 4, '602015A', 'https://www.farmacapital.mx/catalogo-propia/adopren-600-7501842900105.jpg', 'catalogo-propia/adopren-600-7501842900105.jpg'),
  (8, 'GEN003', '7501842952890', 'FC-42952890', 'Adopren 800 mg', 'Adopren 800 mg', 3, 19.60, 25, 'marca', 'Medicamentos', 'Tabletas', 'Adopren', 'Caja con 10 tabletas', 'Ibuprofeno', '800 mg', false, 2, '603025A', 'https://www.farmacapital.mx/catalogo-propia/adopren-800-7501842952890.jpg', 'catalogo-propia/adopren-800-7501842952890.jpg'),
  (9, 'NOV125', '7501075721249', 'FC-75721249', 'Natrazim 40 mg', 'Natrazim 40 mg', 2, 21.73, 28, 'marca', 'Medicamentos', 'Tabletas', 'Natrazim', 'Caja con 14 tabletas', 'Telmisartán', '40 mg', true, 2, '881976', 'https://www.farmacapital.mx/catalogo-propia/natrazim-40-7501075721249.jpg', 'catalogo-propia/natrazim-40-7501075721249.jpg'),
  (10, 'SET021', null, 'EQ-SET021', 'Magnesio Complex', 'Magnesio Complex', 1, 83.34, 105, 'marca', 'Suplementos', 'Tabletas efervescentes', 'Seltz', '20 tabletas efervescentes', 'Bisglicinato / citrato / malato de magnesio', null, false, 1, 'L60639', 'https://www.farmacapital.mx/catalogo-propia/seltz-magnesio-complex-20tab.jpg', 'catalogo-propia/seltz-magnesio-complex-20tab.jpg'),
  (11, 'VIT068', '7501478316813', 'EQ-VIT068', 'Ibuprofeno cafeína 400/100 mg', 'Ibuprofeno cafeína 400/100 mg', 3, 31.87, 40, 'marca', 'Medicamentos', 'Cápsulas', 'Gel Pharma', 'Caja con 10 cápsulas', 'Ibuprofeno / cafeína', '400 mg / 100 mg', false, 2, 'M26091', 'https://www.farmacapital.mx/catalogo-propia/ibuprofeno-cafeina-gelpharma-7501478316813.jpg', 'catalogo-propia/ibuprofeno-cafeina-gelpharma-7501478316813.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, replace(t.sku, 'EQ-', '')), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Factura Levic 9012442706 · clave ' || t.clave || ' · lote ' || coalesce(t.lote, ''),
  t.costo,
  t.precio,
  0,
  t.stock_minimo,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_rx_levic9012442706 t
where coalesce(
        public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
        public.fc_buscar_producto_escaneo(t.sku)
      ) is null;

update public.productos p
set
  costo = t.costo,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), t.stock_minimo),
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), nullif(t.ean, '')),
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_rx_levic9012442706 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from _fc_rx_levic9012442706 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012442706',
  '2026-10-12',
  943.81,
  'borrador',
  'Factura Levic A 9012442706 · entrega 833148360 · PUE efectivo $943.81 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012442706' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 943.81,
  fecha = '2026-10-12',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012442706 · entrega 833148360 · PUE efectivo $943.81 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja',
  updated_at = now()
where folio = '9012442706'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012442706'
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
  coalesce(nullif(t.ean, ''), t.sku),
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
from _fc_rx_levic9012442706 t
join public.recepciones r
  on r.folio = '9012442706'
 and coalesce(r.proveedor, '') ilike '%levic%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '9012442706' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
