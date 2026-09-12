-- City Mark · folio 20260912 (2026-09-12) — altas con foto + cola Recibir.
-- Ticket PUBLICO EN GENERAL (encabezado cortado). Total $1486.47.
-- P.U. = costo. Sin lote ni caducidad: MMAA de la caja. No inventar 0000.
-- 14 altas stock 0 + 3 ya existían (Pert oliva, Listerine Care/Zero).
-- Fotos en public/catalogo-propia/ (URLs tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cm_20260912 (
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
  ya boolean not null,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_cm_20260912 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, ya, imagen, foto_file
) values

  (1, '7501943476271', 'FC-43476271', 'Kleenex pañuelos bote C/50',
   'KLENNEX PAÑ BOTE C50', 2, 29.14, 47,
   'marca', 'Cuidado personal', 'Pañuelos',
   'Pañuelos', 'Kleenex', 'Kimberly-Clark',
   'Bote con 50 pañuelos',
   false,
   'https://www.farmacapital.mx/catalogo-propia/kleenex-panuelos-bote-50.jpg', 'catalogo-propia/kleenex-panuelos-bote-50.jpg'),
  (2, '070330731813', 'FC-30731813', 'BIC Soleil 3 Color Collection 12 pzas',
   'BIC SOLEIL 3 COLOR COLLECTION 12 PZS OFERTA 20%', 1, 155.32, 249,
   'marca', 'Cuidado personal', 'Afeitado',
   'Rastrillo', 'BIC', 'BIC',
   'Paquete 12 piezas',
   false,
   'https://www.farmacapital.mx/catalogo-propia/bic-soleil-3-color-12.jpg', 'catalogo-propia/bic-soleil-3-color-12.jpg'),
  (3, '070330717541', 'FC-30717541', 'BIC Advance tira rastrillo 12 pzas',
   'BIC TIRA ADVANC TIRA RASTRILLO 12 PZS OFERTA 20%', 1, 169.60, 272,
   'marca', 'Cuidado personal', 'Afeitado',
   'Rastrillo', 'BIC', 'BIC',
   'Tira 12 piezas',
   false,
   'https://www.farmacapital.mx/catalogo-propia/bic-advance-tira-12.jpg', 'catalogo-propia/bic-advance-tira-12.jpg'),
  (4, '850040940602', 'FC-40940602', 'Grisi Organogal Silver shampoo 400 ml + canas 130 ml',
   'GRISI 400ML SH ORGAN SILVER + 130ML CANAS P LATI', 1, 87.35, 140,
   'marca', 'Cuidado personal', 'Cabello',
   'Kit', 'Grisi', 'Grisi',
   'Shampoo 400 ml + tratamiento 130 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/grisi-organogal-silver-kit.jpg', 'catalogo-propia/grisi-organogal-silver-kit.jpg'),
  (5, '810120500164', 'FC-20500164', 'Pert crema peinar keratina + aguacate 100 ml',
   'CRA PERT KERA+AC AGU P/PEIN 100 ML', 2, 14.80, 24,
   'marca', 'Cuidado personal', 'Cabello',
   'Crema', 'Pert', 'Grisi',
   'Frasco 100 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/pert-crema-kera-aguacate-100.jpg', 'catalogo-propia/pert-crema-kera-aguacate-100.jpg'),
  (6, '7502254073371', 'FC-54073371', 'Seda Pure silica argán spray 300 ml',
   'SILICA SEDA PURE ARGAN SPY 300ML', 1, 69.04, 111,
   'marca', 'Cuidado personal', 'Cabello',
   'Spray', 'Seda Pure', 'Seda Pure',
   'Spray 300 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-argan-300.jpg', 'catalogo-propia/seda-pure-silica-argan-300.jpg'),
  (7, '7502254073357', 'FC-54073357', 'Seda Pure silica uva spray 300 ml',
   'SILICA SEDA PURE UVA SPY300ML', 1, 69.05, 111,
   'marca', 'Cuidado personal', 'Cabello',
   'Spray', 'Seda Pure', 'Seda Pure',
   'Spray 300 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-uva-300.jpg', 'catalogo-propia/seda-pure-silica-uva-300.jpg'),
  (8, '7506306208315', 'FC-06208315', 'St Ives colágeno y elastina 200 ml',
   'CRA S TIVES COLAGENO Y ELAS 200ML OCT26', 1, 32.31, 52,
   'marca', 'Cuidado personal', 'Corporal',
   'Crema', 'St. Ives', 'Unilever',
   'Tubo 200 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/st-ives-colageno-elastina-200.jpg', 'catalogo-propia/st-ives-colageno-elastina-200.jpg'),
  (9, '7501080111455', 'FC-80111455', 'Just For Men tinte barba/bigote negro',
   'TIN JUST F-MEN BARBA/B NEGRO', 2, 171.14, 274,
   'marca', 'Cuidado personal', 'Tinte',
   'Kit', 'Just For Men', 'Combe',
   'Kit barba/bigote negro',
   false,
   'https://www.farmacapital.mx/catalogo-propia/just-for-men-barba-negro.jpg', 'catalogo-propia/just-for-men-barba-negro.jpg'),
  (10, '7502254073715', 'FC-54073715', 'Seda Pure acondicionador kerat bifásico 250 ml',
   'ACOND SEDA PURE KERAT BIFAS 250ML', 1, 55.10, 89,
   'marca', 'Cuidado personal', 'Cabello',
   'Acondicionador', 'Seda Pure', 'Seda Pure',
   'Frasco 250 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/seda-pure-acond-kerat-250.jpg', 'catalogo-propia/seda-pure-acond-kerat-250.jpg'),
  (11, '810120500171', 'FC-20500171', 'Pert crema peinar oliva + aguacate 100 ml',
   'CRA PERT OLIV+AC AGU P/PEIN 100 ML', 2, 14.80, 24,
   'marca', 'Cuidado personal', 'Cabello',
   'Crema', 'Pert', 'Grisi',
   'Frasco 100 ml',
   true,
   null, null),
  (12, '7702031887928', 'FC-31887928', 'Listerine Care Zero menta 250 ml',
   'ENJ BUC LIST CARE ZERO MTA 250ML', 1, 63.53, 102,
   'marca', 'Cuidado personal', 'Bucal',
   'Enjuague', 'Listerine', 'J&J',
   'Frasco 250 ml',
   true,
   null, null),
  (13, '7891010974329', 'FC-10974329', 'Listerine Zero menta suave 250 ml',
   'ENJ BUC LIST ZERO MTA SVE 250ML', 1, 54.06, 87,
   'marca', 'Cuidado personal', 'Bucal',
   'Enjuague', 'Listerine', 'J&J',
   'Frasco 250 ml',
   true,
   null, null),
  (14, '7702035433299', 'FC-35433299', 'Listerine Defense 250 ml',
   'ENJ BUC LIST DEF/DYENC 250ML', 1, 63.86, 103,
   'marca', 'Cuidado personal', 'Bucal',
   'Enjuague', 'Listerine', 'J&J',
   'Frasco 250 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/listerine-defense-250.jpg', 'catalogo-propia/listerine-defense-250.jpg'),
  (15, '7501027233974', 'FC-27233974', 'L''Oréal Fix Inv ultra fijación gel 180 g',
   'GEL LOREAL FIX INV U/FIJ 180G', 1, 58.10, 93,
   'marca', 'Cuidado personal', 'Cabello',
   'Gel', 'L''Oréal', 'L''Oréal',
   'Tubo 180 g',
   false,
   'https://www.farmacapital.mx/catalogo-propia/loreal-fix-inv-ultra-180.jpg', 'catalogo-propia/loreal-fix-inv-ultra-180.jpg'),
  (16, '7502254072831', 'FC-54072831', 'Seda Pure silica brillo extremo 125 ml',
   'SILICA SEDA PURE BRILLO EXTRE 125ML', 2, 58.54, 94,
   'marca', 'Cuidado personal', 'Cabello',
   'Spray', 'Seda Pure', 'Seda Pure',
   'Spray 125 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/seda-pure-silica-brillo-125.jpg', 'catalogo-propia/seda-pure-silica-brillo-125.jpg'),
  (17, '7506306208353', 'FC-06208353', 'St Ives avena y karité 200 ml',
   'CRA ST IVES AVENA Y KARITE 200ML NOV26', 1, 32.31, 52,
   'marca', 'Cuidado personal', 'Corporal',
   'Crema', 'St. Ives', 'Unilever',
   'Tubo 200 ml',
   false,
   'https://www.farmacapital.mx/catalogo-propia/st-ives-avena-karite-200.jpg', 'catalogo-propia/st-ives-avena-karite-200.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-CM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta City Mark 20260912 · 2026-09-12 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_cm_20260912 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_cm_20260912 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_cm_20260912 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'City Mark',
  '20260912',
  '2026-09-12',
  1486.47,
  'borrador',
  'Pedido City Mark 20260912 · ticket PUBLICO EN GENERAL · encabezado cortado (folio/fecha estimados 12-sep-2026) · EAN del ticket · cola Recibir; stock al confirmar pistola · altas con ficha+foto en catalogo-propia'
where not exists (
  select 1 from public.recepciones
  where folio = '20260912' and coalesce(proveedor, '') ilike '%city mark%'
);

update public.recepciones
set
  total_ticket = 1486.47,
  fecha = '2026-09-12',
  proveedor = 'City Mark',
  notas = 'Pedido City Mark 20260912 · ticket PUBLICO EN GENERAL · encabezado cortado (folio/fecha estimados 12-sep-2026) · EAN del ticket · cola Recibir; stock al confirmar pistola · altas con ficha+foto en catalogo-propia',
  updated_at = now()
where folio = '20260912'
  and coalesce(proveedor, '') ilike '%city mark%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260912'
  and coalesce(r.proveedor, '') ilike '%city mark%'
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
from _fc_cm_20260912 t
join public.recepciones r
  on r.folio = '20260912'
 and coalesce(r.proveedor, '') ilike '%city mark%'
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
  ), -1) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from _fc_cm_20260912 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = p.id and x.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260912' and coalesce(r.proveedor, '') ilike '%city mark%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, '(sin foto)'), 64) as foto
from public.productos p
where p.codigo_barras in ('7501943476271', '070330731813', '070330717541', '850040940602', '810120500164', '7502254073371', '7502254073357', '7506306208315', '7501080111455', '7502254073715', '810120500171', '7702031887928', '7891010974329', '7702035433299', '7501027233974', '7502254072831', '7506306208353')
order by p.sku;
