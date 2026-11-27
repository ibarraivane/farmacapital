-- Factura Nadro folio 6090936556 (2026-10-08) — altas + cola Recibir.
-- CFDI 08-oct-2026 · NADRO MEXICO SUR · UUID 40B36653-DBBA-42FC-B94B-AE0074E75C9D
-- Total $778.42 · 7 renglones · 25 piezas
-- EAN de caja (no OCR sucio del papel: varios fallan check GS1).
-- Ficha de mostrador: Vandix / Mexapin / Bonglixan / Bresaltec. LGEN no es marca.
-- LIFEFACTOR / JAYOR del ticket = casa Nadro, no laboratorio de caja.
-- Recargo genérico +60% sobre costo. PVP existente no se pisa.
-- 5 altas stock 0. 2 ya en catálogo (FC-49021570, FC-F82A6E4B).
-- Bonglixan: cadena fría. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Fotos en public/catalogo-propia/ (visibles tras deploy Vercel).
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_nd6090936556 (
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
  foto_file text
) on commit drop;

insert into _fc_nd6090936556
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion,
   receta, alta_nueva, imagen, foto_file)
values
  (1, '7503001007281', 'FC-01007281', 'Vandix 250 mg', 'AMOXICILINA 250 MG 12 CAPS LGEN', 5, 15.48, 25, 'generico', 'Medicamentos', 'Antibióticos', 'Vandix', 'C/12 cápsulas', 'Cápsulas', 'Wandel', 'Amoxicilina', '250 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/vandix-amoxicilina-250mg-c12-7503001007281.jpg', 'catalogo-propia/vandix-amoxicilina-250mg-c12-7503001007281.jpg'),
  (2, '7501349021570', 'FC-49021570', 'Amoxicilina 500 mg', 'AMOXICILINA 500 MG 12 CAPS LGEN', 5, 18.76, 31, 'generico', 'Medicamentos', 'Antibióticos', null, 'C/12 cápsulas', 'Cápsulas', 'AMSA', 'Amoxicilina', '500 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/amoxicilina-500mg-c12-amsa-7501349021570.jpg', 'catalogo-propia/amoxicilina-500mg-c12-amsa-7501349021570.jpg'),
  (3, '7501349022881', 'FC-F82A6E4B', 'Ampicilina 1 g', 'AMPICILINA 1 G 10 TAB LGEN', 4, 24.63, 40, 'generico', 'Medicamentos', 'Antibióticos', null, 'C/10 tabletas', 'Tabletas', 'AMSA', 'Ampicilina', '1 g', true, false, 'https://www.farmacapital.mx/catalogo-propia/ampicilina-1g-c10-amsa-7501349022881.jpg', 'catalogo-propia/ampicilina-1g-c10-amsa-7501349022881.jpg'),
  (4, '7503001007137', 'FC-01007137', 'Mexapin 250 mg/5 ml', 'AMPICILINA 250 MG 60 ML SUSP LGEN', 4, 16.71, 27, 'generico', 'Medicamentos', 'Antibióticos', 'Mexapin', 'Frasco 60 ml', 'Suspensión', 'Wandel', 'Ampicilina', '250 mg/5 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/mexapin-ampicilina-250mg-susp-60ml-7503001007137.jpg', 'catalogo-propia/mexapin-ampicilina-250mg-susp-60ml-7503001007137.jpg'),
  (5, '7503001007168', 'FC-01007168', 'Mexapin 500 mg', 'AMPICILINA 500 MG 20 CAPS LGEN', 3, 29.35, 47, 'generico', 'Medicamentos', 'Antibióticos', 'Mexapin', 'C/20 cápsulas', 'Cápsulas', 'Wandel', 'Ampicilina', '500 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/mexapin-ampicilina-500mg-c20-7503001007168.jpg', 'catalogo-propia/mexapin-ampicilina-500mg-c20-7503001007168.jpg'),
  (6, '7502247375543', 'FC-47375543', 'Bonglixan 100 UI', 'BONGLIXAN 100UI S I FA 10ML LGEN', 1, 224.99, 360, 'generico', 'Medicamentos', 'Diabetes', 'Bonglixan', 'Frasco ámpula 10 ml', 'Solución inyectable', 'Landsteiner Scientific', 'Insulina glargina', '100 UI/ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/bonglixan-insulina-glargina-100ui-10ml-7502247375543.jpg', 'catalogo-propia/bonglixan-insulina-glargina-100ui-10ml-7502247375543.jpg'),
  (7, '7506022327635', 'FC-22327635', 'Bresaltec 100 µg', 'BRESALTEC 100 UG INH 200 DOSIS LGEN', 3, 42.94, 69, 'generico', 'Medicamentos', 'Respiratorio', 'Bresaltec', '200 dosis', 'Aerosol', 'BiosynTec', 'Salbutamol', '100 µg/dosis', true, true, 'https://www.farmacapital.mx/catalogo-propia/bresaltec-salbutamol-100ug-200dosis-7506022327635.jpg', 'catalogo-propia/bresaltec-salbutamol-100ug-200dosis-7506022327635.jpg');

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
  'Alta Nadro 6090936556 · 2026-10-08 · listo para pistola',
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
from _fc_nd6090936556 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN / LIFEFACTOR / JAYOR).
update public.productos p set
  marca = coalesce(nullif(btrim(t.marca), ''), p.marca),
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = t.concentracion,
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(t.laboratorio), ''), nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Foto si falta (no pisa packshot que ya esté).
update public.productos p
set
  imagen_url = t.imagen,
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''), t.imagen)
from _fc_nd6090936556 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.imagen is not null
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url not like '%catalogo-propia/%'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6090936556',
  '2026-10-08',
  778.42,
  'borrador',
  'Factura Nadro 6090936556 · 08-10-26 · EAN caja · Bonglixan cadena fría · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6090936556' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 778.42,
  fecha = '2026-10-08',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6090936556 · 08-10-26 · EAN caja · Bonglixan cadena fría · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '6090936556'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6090936556'
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
from _fc_nd6090936556 t
join public.recepciones r
  on r.folio = '6090936556'
 and coalesce(r.proveedor, '') ilike '%nadro%'
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
from _fc_nd6090936556 t
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
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6090936556' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 40) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7503001007281',
  '7501349021570',
  '7501349022881',
  '7503001007137',
  '7503001007168',
  '7502247375543',
  '7506022327635'
)
order by p.nombre;
