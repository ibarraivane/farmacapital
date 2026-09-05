-- Farma Mayoreo · ID VENTA 303033 · 2026-09-05 12:51 · caja 3 · Alfred L. S.
-- RFC FMA180119D55 · sucursal FARMAMAYOREO CENTRAL (Canal de Apatlaco, CEDA).
-- Pago tarjeta. SUBTOTAL $1,725.16 + IVA $118.00 = TOTAL $1,843.16.
-- Los P.U. ya traen IVA (suma de renglones = total). 27 renglones / 33 pzas.
-- 22 altas stock 0. 5 ya estaban: solo costo, no PVP.
-- Fichas de Fahorro / marca / Open Beauty Facts, no el recorte del térmico.
-- Lote de fábrica sí (si no se repite en el renglón de abajo). Caducidad NO:
-- Recibir pide MMAA de la caja. 0000 es inválido.
-- Ting 45 g: el papel dice FecCad 30-04-2026 (vencido el día de la compra).
-- Afrin Adulto del ticket es EAN 7501004100435; el del catálogo 7501050613453
-- no se junta. Palillos GUM se guardan 070942306805 (el ticket recorta el 0).
-- Foto TODO (alta sin packshot en repo): 7501258216029, 7506306254503.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fm303033 (
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

insert into _fc_fm303033 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7503007859648', 'FC-07859648', 'Blumen jabón líquido Cherry Blossom 525 ml', 'BLUMEN JABON LIQ', 1, 35.98, 45, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 525 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/blumen-jabon-liquido-cherry-525ml.jpg', 'catalogo-propia/blumen-jabon-liquido-cherry-525ml.jpg', null),
  (2, '7501943490598', 'FC-43490598', 'Jabón líquido Escudo para manos', 'JBN LIQ ESCUDO P', 1, 28.00, 35, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Escudo', 'P&G', null, null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/escudo-jabon-liquido.jpg', 'catalogo-propia/escudo-jabon-liquido.jpg', null),
  (3, '7503002163023', 'FC-02163023', 'Xtreme gel Professional 250 g', 'XTREME GEL PROFE', 3, 22.98, 29, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'Xtreme', null, 'Envase 250 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/xtreme-gel-profesional-250g.jpg', 'catalogo-propia/xtreme-gel-profesional-250g.jpg', 'K72556L428'),
  (4, '7501007528427', 'FC-07528427', 'Lubriderm Reparación Intensiva 400 ml', 'LUBRIDERM REPARA', 1, 90.98, 114, 'marca', 'Cuidado personal', 'Piel', 'Crema', 'Lubriderm', 'Kenvue', 'Frasco 400 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/lubriderm-reparacion-intensiva-400ml.jpg', 'catalogo-propia/lubriderm-reparacion-intensiva-400ml.jpg', null),
  (5, '7501004100435', 'FC-04100435', 'Afrin Adulto spray nasal 20 ml', 'AFRIN AD 20 ML +', 1, 83.92, 105, 'marca', 'Medicamentos', 'Respiratorio', 'Spray nasal', 'Afrin', 'Bayer', 'Frasco 20 ml', 'Oximetazolina', '0.050%', false, false, 'https://www.farmacapital.mx/catalogo-propia/afrin-adulto-20ml.jpg', 'catalogo-propia/afrin-adulto-20ml.jpg', '20K0128'),
  (6, '7501008499795', 'FC-08499795', 'Afrin No Drip Niños suspensión nasal 15 ml', 'AFRIN NODRIP NIÑ', 1, 96.98, 122, 'marca', 'Medicamentos', 'Respiratorio', 'Suspensión nasal', 'Afrin', 'Bayer', 'Frasco nebulizador 15 ml', 'Oximetazolina', '0.50 mg/ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/afrin-nodrip-ninos-15ml.jpg', 'catalogo-propia/afrin-nodrip-ninos-15ml.jpg', '2605493'),
  (7, '7501088509810', 'FL-8509810', 'Antiflu-Des pediátrico solución 30 ml', 'ANTIFLUDES SOL P', 1, 145.98, 183, 'marca', 'Medicamentos', 'Respiratorio', 'Solución', 'Antiflu-Des', 'CHINOIN', 'Frasco 30 ml', 'Paracetamol + clorfenamina + fenilefrina', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'catalogo-propia/antiflu-des-pediatrico-30ml.jpg', 'BEK113'),
  (8, '7501258216029', 'FC-58216029', 'Protector solar Serral FPS 50+ 60 g', 'SERRAL PROTECTOR', 1, 37.98, 48, 'marca', 'Cuidado personal', 'Protector solar', 'Crema', 'Serral', 'Laboratorios Serral', 'Tubo 60 g', null, 'FPS 50+', false, false, null, null, '250653'),
  (9, '7506267905186', 'FC-67905186', 'Blumen jabón líquido Coconut 221 ml', 'JBN BLUMEN JL CP', 2, 17.69, 23, 'marca', 'Cuidado personal', 'Higiene', 'Jabón líquido', 'Blumen', null, 'Botella 221 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/blumen-coconut-221ml.jpg', 'catalogo-propia/blumen-coconut-221ml.jpg', null),
  (10, '7501001116187', 'FC-01116187', 'Vick 44 jarabe todo tipo de tos 120 ml', 'VICK 44 JBE 120M', 1, 115.98, 145, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Vick', 'P&G', 'Frasco 120 ml', 'Guaifenesina / dextrometorfano', '1.33 g / 0.133 g / 100 ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/vick-44-jarabe-120ml.jpg', 'catalogo-propia/vick-44-jarabe-120ml.jpg', '60984354B0'),
  (11, '7503002163610', 'FC-02163610', 'Xtreme gel Attraction hombre 250 g', 'XTREME GEL ATTRA', 3, 23.94, 30, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'Xtreme', null, 'Envase 250 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/xtreme-gel-attraction-250g.jpg', 'catalogo-propia/xtreme-gel-attraction-250g.jpg', 'K72185L419'),
  (12, '070942306805', 'FC-42306805', 'Palillos GUM con hilo dental C/20', 'PALILLOS GUM C/HIL', 1, 24.83, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'GUM', 'Sunstar', 'Caja con 20', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/palillos-gum-hilo-c20.jpg', 'catalogo-propia/palillos-gum-hilo-c20.jpg', null),
  (13, '7501065053121', 'FC-65053121', 'Emulsión de Scott naranja 200 ml', 'EMULSION DE SCOT', 1, 91.97, 115, 'marca', 'Vitaminas', 'Suplemento', 'Emulsión', 'Scott', 'GSK', 'Frasco 200 ml', 'Vitamina A / D / calcio / fósforo', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/emulsion-scott-naranja-200ml.jpg', 'catalogo-propia/emulsion-scott-naranja-200ml.jpg', '6U26'),
  (14, '7501001116200', 'FC-01116200', 'Vick 44 Exp Infantil jarabe 120 ml', 'VICK 44 EXP JBE', 1, 115.98, 145, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Vick', 'P&G', 'Frasco 120 ml', 'Guaifenesina', '1.33 g / 100 ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/vick-44-exp-infantil-120ml.jpg', 'catalogo-propia/vick-44-exp-infantil-120ml.jpg', '60834354B1'),
  (15, '7501070613006', 'FC-70613006', 'Andantol isotipendilo 4 mg C/20', 'ANDANTOL 4MG C/2', 1, 162.98, 204, 'marca', 'Medicamentos', 'Alergia', 'Tableta', 'Andantol', 'Sanfer', 'Caja con 20 tabletas', 'Isotipendilo', '4 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/andantol-4mg-c20.jpg', 'catalogo-propia/andantol-4mg-c20.jpg', '170BD005V'),
  (16, '7702031244493', 'FC-31244493', 'Lubriderm Humectación Diaria piel normal 200 ml', 'CRA LUBRIDERM P/', 1, 49.98, 63, 'marca', 'Cuidado personal', 'Piel', 'Crema', 'Lubriderm', 'Kenvue', 'Frasco 200 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/lubriderm-humectacion-diaria-200ml.jpg', 'catalogo-propia/lubriderm-humectacion-diaria-200ml.jpg', null),
  (17, '7506339394733', 'FC-39394733', 'Fixodent Plus adhesivo dental 35 g', 'FIXODENT PLUS 35', 1, 91.97, 115, 'marca', 'Cuidado personal', 'Higiene bucal', 'Adhesivo', 'Fixodent', 'P&G', 'Tubo 35 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/fixodent-plus-35g.jpg', 'catalogo-propia/fixodent-plus-35g.jpg', '6044028890'),
  (18, '5000174003963', 'FC-74003963', 'Fixodent Fresh adhesivo dental 40 g', 'FIXODENT FRESH 4', 1, 101.95, 128, 'marca', 'Cuidado personal', 'Higiene bucal', 'Adhesivo', 'Fixodent', 'P&G', 'Tubo 40 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/fixodent-fresh-40g.jpg', 'catalogo-propia/fixodent-fresh-40g.jpg', '6054028890'),
  (19, '7509552844160', 'FC-52844160', 'Garnier Fructis Hair Food Banana acondicionador 300 ml', 'AC. FRUCTIS HAIR', 1, 57.98, 73, 'marca', 'Cuidado personal', 'Cabello', 'Acondicionador', 'Garnier Fructis', 'L''Oréal', 'Frasco 300 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/fructis-hair-food-banana-300ml.jpg', 'catalogo-propia/fructis-hair-food-banana-300ml.jpg', null),
  (20, '7506306247468', 'FC-06247468', 'Gel Ego Fresh 200 g', 'GEL EGO FRESH 20', 2, 19.98, 25, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'Ego', null, 'Envase 200 g', null, null, false, true, null, null, '010528'),
  (21, '7501417006133', 'FC-17006133', 'Pasta de Lassar óxido de zinc 145 g', 'PASTA DE LASSAR', 1, 44.94, 57, 'marca', 'Cuidado personal', 'Piel', 'Pasta', 'Pasta de Lassar', null, 'Tarro 145 g', 'Óxido de zinc', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/pasta-de-lassar-145g.jpg', 'catalogo-propia/pasta-de-lassar-145g.jpg', 'LAS050125'),
  (22, '7501008409541', 'FC-84095411', 'Saridon C/20 tabletas', 'SARIDON C/20 COM', 1, 58.99, 74, 'marca', 'Medicamentos', 'Dolor', 'Tableta', 'Saridon', 'Bayer', 'Caja con 20 tabletas', 'Paracetamol / propyfenazona / cafeína', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/saridon-c20.jpg', 'catalogo-propia/saridon-c20.jpg', 'X26VD7'),
  (23, '7506192506120', 'FC-92506120', 'Savilé shampoo Colágeno control caída 180 ml', 'SH SAVILE COLAGE', 1, 15.89, 20, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Savilé', null, 'Frasco 180 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/savile-colageno-180ml.jpg', 'catalogo-propia/savile-colageno-180ml.jpg', '20260880'),
  (24, '7506306254503', 'FC-06254503', 'Savilé shampoo Células Madre 180 ml', 'SH SAVILE CELULA', 1, 15.89, 20, 'marca', 'Cuidado personal', 'Cabello', 'Shampoo', 'Savilé', null, 'Frasco 180 ml', null, null, false, false, null, null, '2026008'),
  (25, '7509552844184', 'FC-52844184', 'Garnier Fructis Hair Food Aloe Vera acondicionador 300 ml', 'AC. FRUCTIS HAIR', 1, 57.98, 73, 'marca', 'Cuidado personal', 'Cabello', 'Acondicionador', 'Garnier Fructis', 'L''Oréal', 'Frasco 300 ml', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/fructis-hair-food-aloe-300ml.jpg', 'catalogo-propia/fructis-hair-food-aloe-300ml.jpg', null),
  (26, '7501072300164', 'FC-72300164', 'Ting polvo 45 g', 'TING POLVO 45G', 1, 69.95, 88, 'marca', 'Medicamentos', 'Dermatología', 'Polvo', 'Ting', 'Hormona', 'Bote 45 g', 'Ácido undecilénico / undecilenato de zinc', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ting-polvo-45g.jpg', 'catalogo-propia/ting-polvo-45g.jpg', '378028'),
  (27, '7702031244486', 'FC-31244486', 'Lubriderm crema piel normal 120 ml', 'CRA LUBRIDERM P/', 1, 29.98, 38, 'marca', 'Cuidado personal', 'Piel', 'Crema', 'Lubriderm', 'Kenvue', 'Frasco 120 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/lubriderm-piel-normal-120ml.jpg', 'catalogo-propia/lubriderm-piel-normal-120ml.jpg', null);

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
    ) then 'FC-FM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farma Mayoreo 303033 · 2026-09-05 · listo para pistola',
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
from _fc_fm303033 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ya existían: costo de este ticket. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Saridon C/20: el nombre corto / 120 tabletas choca con esta presentación.
update public.productos p
set nombre = t.nombre,
    presentacion = t.presentacion,
    forma_farmaceutica = t.forma,
    categoria = t.categoria
from _fc_fm303033 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and t.ean = '7501008409541'
  and (
    p.nombre ~* '^saridon$'
    or p.nombre ~* '120'
    or coalesce(p.presentacion, '') ~* '120'
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  '303033',
  '2026-09-05',
  1843.16,
  'borrador',
  'Ticket Farma Mayoreo 303033 · 05-sep-2026 · CEDA · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '303033' and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 1843.16,
  fecha = '2026-09-05',
  proveedor = 'Farma Mayoreo',
  notas = 'Ticket Farma Mayoreo 303033 · 05-sep-2026 · CEDA · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja',
  updated_at = now()
where folio = '303033'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '303033'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm303033 t
join public.recepciones r
  on r.folio = '303033'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm303033 t
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
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '303033' and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
  '7503007859648',
  '7501943490598',
  '7503002163023',
  '7501007528427',
  '7501004100435',
  '7501008499795',
  '7501088509810',
  '7501258216029',
  '7506267905186',
  '7501001116187',
  '7503002163610',
  '070942306805',
  '7501065053121',
  '7501001116200',
  '7501070613006',
  '7702031244493',
  '7506339394733',
  '5000174003963',
  '7509552844160',
  '7506306247468',
  '7501417006133',
  '7501008409541',
  '7506192506120',
  '7506306254503',
  '7509552844184',
  '7501072300164',
  '7702031244486'
)
order by p.nombre;
