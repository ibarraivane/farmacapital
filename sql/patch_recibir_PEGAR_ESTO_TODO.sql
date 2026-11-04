-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Revisa + crea / reabre tickets recientes en Recibir.
-- Merge a GitHub NO crea las tarjetas. Este Run si.
-- Sin bloques dollar-quote. Sin galeria extra.
--
-- IMPORTANTE:
--  - Si un folio YA se recibio con stock (lote_id), NO lo toca.
--  - Si existe cerrado/confirmado SIN stock, lo reabre a borrador.
--  - Si no existe, lo crea.
--  - Nadro 6091723171: solo arregla BPOllen (el ticket ya esta en cola).
-- Al final: VERIFICACION. Luego tablet Recibir - recargar (Tickets, no Historia).
-- =============================================================================
-- Incluye:
--   BPOllen (Nadro 6091723171 amarillos)
--   Nadro 6091546907 (Dove / Memantina / Zolufen) — faltaba
--   Tenorio 3838940 · Fanasa B49445264 · Nadro 6091110421
--   Levic 9012545305 + 9012442706
--   Equilibrio 450233 · 450041
--   Cityfarma S336478 / S336493
--   Bodega F-42 76370
--   Farmalive 11104
--   Fanasa B49397867 (Lubrex)
-- =============================================================================

-- ========== 0) DIAGNOSTICO ANTES ==========
with esperados(proveedor_like, folio, etiqueta) as (
  values
    ('%tenorio%', '3838940', 'Tenorio $1,148.52'),
    ('%fanasa%', 'B49445264', 'Fanasa Fluxedan $667.19'),
    ('%fanasa%', 'B49397867', 'Fanasa Lubrex'),
    ('%nadro%', '6091110421', 'Nadro $644.52'),
    ('%nadro%', '6091723171', 'Nadro Softclix/BPOllen $1,119.31'),
    ('%nadro%', '6091546907', 'Nadro Dove/Memantina $312.34'),
    ('%levic%', '9012545305', 'Levic $1,844.92'),
    ('%levic%', '9012442706', 'Levic $943.81'),
    ('%equilibrio%', '450233', 'Equilibrio $1,125.10'),
    ('%equilibrio%', '450041', 'Equilibrio $152.64'),
    ('%cityfarma%', 'S336478', 'Cityfarma $1,880.68'),
    ('%cityfarma%', 'S336493', 'Cityfarma $716.58'),
    ('%bodega%f-42%', '76370', 'Bodega F-42 / Citymark'),
    ('%farmalive%', '11104', 'Farmalive')
)
select
  e.folio,
  e.etiqueta,
  r.id as recepcion_id,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado,false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado,false)) as sin_confirmar,
  count(*) filter (where i.lote_id is not null) as con_stock_lote,
  case
    when r.id is null then 'NO EXISTE — este SQL lo crea'
    when count(i.*) = 0 then 'SIN RENGLONES — este SQL los pone'
    when count(*) filter (where i.lote_id is not null) = count(i.*)
      and count(i.*) > 0
      and count(*) filter (where not coalesce(i.confirmado,false)) = 0
      then 'YA RECIBIDO (con stock) — no se toca'
    when r.estado = 'borrador'
      and count(*) filter (where not coalesce(i.confirmado,false)) > 0
      then 'EN COLA — ya deberia verse'
    when r.estado is distinct from 'borrador'
      and count(*) filter (where i.lote_id is not null) = 0
      then 'CERRADO SIN STOCK — se reabre'
    else 'REVISAR'
  end as veredicto
from esperados e
left join public.recepciones r
  on r.folio = e.folio
 and (e.folio = '76370' or coalesce(r.proveedor,'') ilike e.proveedor_like)
left join public.recepcion_items i on i.recepcion_id = r.id
group by e.folio, e.etiqueta, r.id, r.proveedor, r.estado, r.total_ticket
order by
  case
    when r.id is null then 0
    when count(*) filter (where i.lote_id is not null) = 0 then 1
    else 2
  end,
  e.folio;

-- ========== 1) REOPEN SEGURO (solo sin stock en lote) ==========
begin;

update public.recepciones r
set estado = 'borrador', updated_at = now()
where r.estado is distinct from 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and i.lote_id is not null
  );

update public.recepcion_items i
set confirmado = false
from public.recepciones r
where i.recepcion_id = r.id
  and coalesce(i.confirmado, false) = true
  and i.lote_id is null
  and i.fecha_caducidad is null
  and r.estado = 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  );

commit;

-- ========== BPOLLEN amarillos Nadro ==========
-- =============================================================================
-- PEGAR SOLO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Arregla los 2 amarillos BPOllen del Nadro (5% y 2.5%).
-- Sin tablas temporales. Sin bloques dollar-quote. Sin producto_imagenes.
-- =============================================================================

-- 0) Estado actual (informativo)
select 'ANTES' as momento, sku, codigo_barras as ean, left(nombre,40) as nombre, activo
from public.productos
where codigo_barras in ('7502002461306', '7502002461290')
   or sku in ('FC-02461306', 'FC-02461290')
order by sku;

select 'ANTES_ITEMS' as momento, r.folio, r.estado, i.codigo_escaneado as ean,
       i.pendiente_alta, i.producto_id, i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.codigo_escaneado in ('7502002461306', '7502002461290')
order by r.id desc, i.id;

-- 1) BPOllen 5%  EAN 7502002461306
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  'BPOllen gel 5%',
  'FC-02461306',
  '7502002461306',
  'Dermatologia',
  'Acne',
  'marca',
  'Alta Recibir BPOllen 5% Nadro 6091723171',
  185.63,
  233,
  0,
  1,
  true,
  false,
  'BPOllen',
  'Farmapiel',
  'Tubo 60 g',
  'Gel',
  'Peroxido de benzoilo',
  '5%',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'
where not exists (
  select 1 from public.productos
  where codigo_barras = '7502002461306' or sku = 'FC-02461306'
);

update public.productos
set
  codigo_barras = '7502002461306',
  nombre = case when length(trim(coalesce(nombre,''))) < 8 then 'BPOllen gel 5%' else nombre end,
  marca = coalesce(nullif(trim(marca), ''), 'BPOllen'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Farmapiel'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Tubo 60 g'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Gel'),
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Peroxido de benzoilo'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '5%'),
  costo = 185.63,
  precio = case when coalesce(precio, 0) <= 0 then 233 else precio end,
  imagen_url = coalesce(nullif(trim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'),
  activo = true,
  tipo = coalesce(nullif(trim(tipo), ''), 'marca')
where sku = 'FC-02461306' or codigo_barras = '7502002461306';

-- 2) BPOllen 2.5%  EAN 7502002461290
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  'BPOllen gel 2.5%',
  'FC-02461290',
  '7502002461290',
  'Dermatologia',
  'Acne',
  'marca',
  'Alta Recibir BPOllen 2.5% Nadro 6091723171',
  170.78,
  214,
  0,
  1,
  true,
  false,
  'BPOllen',
  'Farmapiel',
  'Tubo 60 g',
  'Gel',
  'Peroxido de benzoilo',
  '2.5%',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg',
  'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'
where not exists (
  select 1 from public.productos
  where codigo_barras = '7502002461290' or sku = 'FC-02461290'
);

update public.productos
set
  codigo_barras = '7502002461290',
  nombre = case when length(trim(coalesce(nombre,''))) < 8 then 'BPOllen gel 2.5%' else nombre end,
  marca = coalesce(nullif(trim(marca), ''), 'BPOllen'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Farmapiel'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Tubo 60 g'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Gel'),
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Peroxido de benzoilo'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '2.5%'),
  costo = 170.78,
  precio = case when coalesce(precio, 0) <= 0 then 214 else precio end,
  imagen_url = coalesce(nullif(trim(imagen_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'),
  imagen_mobile_url = coalesce(nullif(trim(imagen_mobile_url), ''), 'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'),
  activo = true,
  tipo = coalesce(nullif(trim(tipo), ''), 'marca')
where sku = 'FC-02461290' or codigo_barras = '7502002461290';

-- 3) Enlaza amarillos (por codigo de barras exacto)
update public.recepcion_items i
set
  producto_id = p.id,
  pendiente_alta = false,
  nombre_snapshot = coalesce(nullif(trim(i.nombre_snapshot), ''), p.nombre),
  costo_estimado = coalesce(nullif(i.costo_estimado, 0), p.costo)
from public.productos p
where p.codigo_barras = i.codigo_escaneado
  and i.codigo_escaneado in ('7502002461306', '7502002461290')
  and coalesce(i.confirmado, false) = false;

-- 3b) Enlace extra por funcion de escaneo (por si el EAN tiene ceros de mas)
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
where i.codigo_escaneado in ('7502002461306', '7502002461290')
  and coalesce(i.confirmado, false) = false
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null
  and (i.producto_id is null or coalesce(i.pendiente_alta, false));

-- 4) Verificacion
select 'DESPUES' as momento, sku, codigo_barras as ean, left(nombre,40) as nombre, costo, precio, activo
from public.productos
where codigo_barras in ('7502002461306', '7502002461290')
   or sku in ('FC-02461306', 'FC-02461290')
order by sku;

select 'DESPUES_ITEMS' as momento, r.folio, r.estado, i.codigo_escaneado as ean,
       i.pendiente_alta, i.producto_id, i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.codigo_escaneado in ('7502002461306', '7502002461290')
order by r.id desc, i.id;

-- ========== Tenorio 3838940 + Fanasa B49445264 + Nadro 6091110421 ==========
-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Crea en Recibir los tickets que faltan (merge a GitHub NO los crea):
--   1) Tenorio 3838940 · $1,148.52 · 6 renglones
--   2) Fanasa B49445264 · $667.19 · 2 renglones (Fluxedan)
--   3) Nadro 6091110421 · $644.52 · 6 renglones
-- Sin bloques dollar-quote. Sin galeria extra. Idempotente en borrador.
-- Al final debe salir VERIFICACION con esos 3 folios en borrador.
-- Luego: tablet Recibir - recargar - aparecen las tarjetas.
-- =============================================================================


-- ========== TENORIO 3838940 ==========
-- Farmaceuticos Tenorio · folio 3838940 · 2026-11-02 07:43
-- Cliente 20077 Palillero Ventura Luis Angel. Ref 2150638. Ruta Puebla. 1 caja.
-- Subtotal 1148.52 + IVA 0.00 = 1148.52. Costo = importe / cantidad.
-- Lote de la factura. Caducidad null: MMAA de la caja. No inventar 0000.
-- Gelubrin ya existía (FC-5C8C9C11). Altas: Raypid, Doxon C/10 y C/20,
-- Dexketoprofeno sobres (marca no confirmada), Aliren.
-- 5 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_tn_3838940 (
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

insert into _fc_tn_3838940 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7503027446279', 'FC-5C8C9C11', 'Gelubrin 600 mg', 'GELUBRIN 600MG CAP C/10 *PRO*', 30, 18.11, 29, 'generico', 'Antiinflamatorio', null, 'Cápsulas', 'Gelubrin', 'Progela', 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/gelubrin-600-7503027446279.jpg', 'catalogo-propia/gelubrin-600-7503027446279.jpg', 'U0591'),
  (2, '7502003386547', 'FC-03386547', 'Raypid 600 mg', 'GEMFIBROZILO 600MG TAB C/14 *RAY*', 2, 89.19, 143, 'generico', 'Medicamentos', 'Lípidos', 'Tabletas', 'Raypid', 'Rayere', 'Caja con 14 tabletas', 'Gemfibrozilo', '600 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/raypid-600-c14-7502003386547.jpg', 'catalogo-propia/raypid-600-c14-7502003386547.jpg', '26104'),
  (3, '7502009746222', 'FC-09746222', 'Doxon 25 mg', 'DEXKETOPROFENO 25MG TAB C/10 *MVE*', 2, 59.00, 95, 'generico', 'Analgésico', null, 'Tabletas', 'Doxon', 'Maver', 'Caja con 10 tabletas', 'Dexketoprofeno', '25 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/doxon-25mg-c10-7502009746222.jpg', 'catalogo-propia/doxon-25mg-c10-7502009746222.jpg', '263460'),
  (4, '7502009748844', 'FC-09748844', 'Doxon 25 mg', 'DEXKETOPROFENO 25MG TAB C/20 *MVE*', 1, 113.77, 183, 'generico', 'Analgésico', null, 'Tabletas', 'Doxon', 'Maver', 'Caja con 20 tabletas', 'Dexketoprofeno', '25 mg', true, false, null, null, '262635'),
  (5, '7503045798336', 'FC-45798336', 'Dexketoprofeno 25 mg/10 ml', 'DEXKETOPROFENO 25MG/10ML SOBRES', 1, 80.96, 130, 'generico', 'Analgésico', null, 'Solución', null, null, 'Sobres', 'Dexketoprofeno', '25 mg/10 ml', true, false, null, null, '266319'),
  (6, '7501300420541', 'FC-00420541', 'Aliren 50/3/300 mg', 'ALIREN 50/3/300MG CAP C/24 *SGF*', 1, 114.11, 143, 'marca', 'Medicamentos', 'Respiratorio', 'Cápsulas', 'Aliren', 'Siegfried Rhein', 'Caja con 24 cápsulas', 'Amantadina / clorfenamina / paracetamol', '50/3/300 mg', false, false, 'https://www.farmacapital.mx/catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg', 'catalogo-propia/aliren-50-3-300-c24-7501300420541.jpg', '261358');

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
  'Alta Farmaceuticos Tenorio 3838940 · 2026-11-02 · listo para pistola',
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
  from _fc_tn_3838940
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
  from _fc_tn_3838940
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
  from _fc_tn_3838940
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmaceuticos Tenorio',
  '3838940',
  '2026-11-02',
  1148.52,
  'borrador',
  'Factura Farmaceuticos Tenorio folio 3838940 · 02-nov-2026 07:43 · cliente 20077 Palillero Ventura · ref 2150638 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '3838940'
    and coalesce(proveedor, '') ilike '%tenorio%'
);

update public.recepciones
set
  total_ticket = 1148.52,
  fecha = '2026-11-02',
  proveedor = 'Farmaceuticos Tenorio',
  notas = 'Factura Farmaceuticos Tenorio folio 3838940 · 02-nov-2026 07:43 · cliente 20077 Palillero Ventura · ref 2150638 · ruta Puebla · 1 caja · cola Recibir, stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = '3838940'
  and coalesce(proveedor, '') ilike '%tenorio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '3838940'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
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
from _fc_tn_3838940 t
join public.recepciones r
  on r.folio = '3838940'
 and coalesce(r.proveedor, '') ilike '%tenorio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '3838940'
  and coalesce(r.proveedor, '') ilike '%tenorio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_tn_3838940 t
order by t.linea;

commit;

-- ========== FANASA B49445264 ==========
-- Pedido Fanasa folio B49445264 (2026-11-02) — altas + cola Recibir.
-- Factura · pedido 57020464 · total $667.19.
-- CANT=1 por renglón (columna BUL ≠ cantidad). Costo = PRECIO FARMACIA.
-- PVP = recargo marca ×1.25. Ficha Carnot (PCI en ticket = Productos Científicos).
-- SIN bloques dollar-quote (dollar-quote). El SQL Editor de Supabase los corta.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_fanasa_b49445264.sql

begin;

create temp table _fc_fnb49445264 (
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
  alta_nueva boolean not null
) on commit drop;

insert into _fc_fnb49445264
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva)
values
  (1, '7501070903237', 'FC-70903237', 'Fluxedan 6/12 mg', 'FLUXEDAN BROMHEXINA OXELADINA 24 COM', 1, 313.41, 392, 'marca', 'Medicamentos', 'Respiratorio', 'Fluxedan', 'Caja con 24 comprimidos', 'Comprimido', 'Carnot', 'Bromhexina / oxeladina', '6 mg / 12 mg', true, true),
  (2, '7501070900441', 'FC-70900441', 'Fluxedan jarabe', 'FLUXEDAN CLORHIDRATO DE BROMHEXINA 6/12 mg/10 ml 1 JBE 225 ml', 1, 353.78, 443, 'marca', 'Medicamentos', 'Respiratorio', 'Fluxedan', 'Frasco 225 ml con medida', 'Jarabe', 'Carnot', 'Bromhexina / oxeladina', '6 mg / 12 mg por 10 ml', true, true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  'Alta Fanasa B49445264 · 2026-11-02 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_fnb49445264 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = coalesce(t.concentracion, p.concentracion),
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_fnb49445264 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_fnb49445264 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Fanasa',
  'B49445264',
  '2026-11-02',
  667.19,
  'borrador',
  'Pedido Fanasa B49445264 · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = 'B49445264' and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = 667.19,
  fecha = '2026-11-02',
  proveedor = 'Fanasa',
  notas = 'Pedido Fanasa B49445264 · pedido 57020464 · 02-11-26 · $667.19 · Fluxedan Comp + Jarabe · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = 'B49445264'
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'B49445264'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
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
from _fc_fnb49445264 t
join public.recepciones r
  on r.folio = 'B49445264'
 and coalesce(r.proveedor, '') ilike '%fanasa%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = 'B49445264' and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;

-- ========== NADRO 6091110421 ==========
-- Pedido Nadro folio 6091110421 (2026-10-13) — altas + cola Recibir.
-- Factura · total $644.52 · costo = VALOR UNITARIO (Amcef con OFTA 15%).
-- PVP = recargo sobre costo (marca ×1.25 / genérico ×1.60). No margen sobre venta.
-- Amcef IV 1 g EAN 7501349012011 ≠ Amcef IM 1 g 7501349012004 (FC-BE76D409).
-- Amcef IM 500 mg ya existe (FC-07F04F88); solo costo + ficha.
-- SIN bloques dollar-quote (dollar-quote). El SQL Editor de Supabase los corta.
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091110421.sql

begin;

create temp table _fc_nd6091110421 (
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
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091110421
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, receta, alta_nueva)
values
  (1, '7501349012011', 'FC-49012011', 'Amcef IV 1 g', 'AMCEF CEFTRIA 1G SI FA 10ML LGEN', 1, 19.80, 32, 'generico', 'Medicamentos', 'Antibióticos', 'Amcef', 'Caja con frasco ámpula y diluyente 10 ml', 'Solución inyectable', 'AMSA', 'Ceftriaxona', '1 g', true, true),
  (2, '7501349011007', 'FC-49011007', 'Amcef IM 500 mg', 'AMCEF IM CEFT500MG SI FA2ML LGEN', 4, 16.10, 26, 'generico', 'Medicamentos', 'Antibióticos', 'Amcef', 'Caja con frasco ámpula y diluyente 2 ml', 'Solución inyectable', 'AMSA', 'Ceftriaxona', '500 mg', true, false),
  (3, '7501022112274', 'FC-22112274', 'C-Boost Omega 3 + vitaminas C, D y E', 'C-BOOST SUP ALIM OMEGA3 FCO 90GOM', 1, 118.18, 148, 'marca', 'Vitaminas', 'Omega 3', 'C-Boost', 'Frasco con 90 gomitas', 'Gomita', 'Grisi', 'Omega 3 / vitamina C / D / E', null, false, true),
  (4, '7501853805253', 'FC-53805253', 'Natural Health colágeno + biotina + ácido hialurónico', 'COLAG/BIOT/A HIA S ALIM FSA 14GOM', 2, 49.01, 62, 'marca', 'Vitaminas', 'Colágeno', 'Natural Health', 'Envase con 14 gomitas', 'Gomita', 'Natural Health', 'Colágeno / biotina / ácido hialurónico', null, false, true),
  (5, '7503024083439', 'FC-24083439', 'Just Omega 3 DHA y EPA', 'JUST OMEGA3 S ALIM DHA EPA 120 GOM', 1, 188.48, 236, 'marca', 'Vitaminas', 'Omega 3', 'Olnatura Just', 'Frasco con 120 gomitas', 'Gomita', 'Olnatura', 'Omega 3 DHA / EPA', null, false, true),
  (6, '7502226293929', 'FC-26293929', 'Metformina LP 500 mg', 'METFORMINA LP 500 MG 30 TAB LGEN', 2, 77.82, 125, 'generico', 'Medicamentos', 'Diabetes', 'Alpharma', 'Caja con frasco 30 tabletas', 'Tableta de liberación prolongada', 'Alpharma', 'Metformina', '500 mg', true, true);

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  'Alta Nadro 6091110421 · 2026-10-13 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091110421 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real, no casa Nadro LGEN).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = coalesce(t.concentracion, p.concentracion),
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_nd6091110421 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0 / ≤1).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end
from _fc_nd6091110421 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091110421',
  '2026-10-13',
  644.52,
  'borrador',
  'Pedido Nadro 6091110421 · factura 13-10-26 · $644.52 · Amcef IV nuevo · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '6091110421' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 644.52,
  fecha = '2026-10-13',
  proveedor = 'Nadro',
  notas = 'Pedido Nadro 6091110421 · factura 13-10-26 · $644.52 · Amcef IV nuevo · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '6091110421'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091110421'
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
from _fc_nd6091110421 t
join public.recepciones r
  on r.folio = '6091110421'
 and coalesce(r.proveedor, '') ilike '%nadro%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku),
    -- Amcef IM 500 mg histórico sin EAN en algunos renglones
    case
      when t.ean = '7501349011007'
        then public.fc_buscar_producto_escaneo('FC-07F04F88')
      else null
    end
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
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 48) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091110421' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

-- VERIFICACION: deben salir estos 3 (mas Nadro 6091723171 si ya estaba)
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
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    (r.folio = '3838940' and coalesce(r.proveedor, '') ilike '%tenorio%')
    or (r.folio = 'B49445264' and coalesce(r.proveedor, '') ilike '%fanasa%')
    or (r.folio = '6091110421' and coalesce(r.proveedor, '') ilike '%nadro%')
    or (r.folio = '6091723171' and coalesce(r.proveedor, '') ilike '%nadro%')
  )
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;

-- ========== Levic 9012545305 + 9012442706 ==========
-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Levic que faltan en Recibir (merge a GitHub NO crea las tarjetas):
--   1) A 9012545305 · $1,844.92 · 12 renglones (BEA215 = caja AMSA iny)
--   2) A 9012442706 · $943.81 · 11 renglones
-- Sin bloques dollar-quote. Idempotente en borrador.
-- Al final: VERIFICACION con esos 2 folios en borrador.
-- Luego tablet Recibir - recargar.
-- =============================================================================


-- ========== LEVIC 9012545305 ==========
-- Levic · factura interna A 9012545305 · CFDI 2026-10-26
-- Folio fiscal B57229E5-7DBB-4B9F-A23E-B1D28E33B872 (OCR foto) · PUE efectivo $1844.92
-- Receptor LUIS ANGEL PALILLERO VENTURA · 12 renglones · 59 pzas (TOT 59 hoja 1).
-- Subtotal CFDI $1750.53 + IVA $94.39 (Cintapore $20.07 + Microdacyn $74.32) = $1844.92.
-- Costo = Precio neto. Lote de fabrica en el papel (excepto AMSA: MMAA de la caja).
-- Caducidad del papel NO se escribe: Recibir captura MMAA de la caja. 0000 invalido.
-- BEA215 en papel = caja AMSA Diclofenaco iny 75 mg/3 mL C/2 (EAN 7501349025929 / EQ-AMS362).
-- SIN bloques dollar-quote (Supabase los corta). Sin galeria extra.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase - SQL Editor - Run.

begin;

create temp table _fc_rx_levic9012545305 (
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

insert into _fc_rx_levic9012545305 (
  linea, clave, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  forma, marca, presentacion, principio_activo, concentracion, receta,
  stock_minimo, lote, imagen, foto_file
) values
  (1, 'ALP0598', '7503004908721', 'FC-1BF03D35', 'Acetonido de fluocinolona Alpharma crema 0.01%', 'ACETONIDO DE FLUOCINOLONA CMA 40/01/100G', 5, 19.79, 32, 'generico', 'Medicamentos', 'Crema', 'Alpharma', 'Tubo 40 g', 'Acetonido de fluocinolona', '0.01%', true, 2, '2605164', null, null),
  (2, 'ALP0673', '7502226294476', 'EQ-ALP0673', 'Acetonido de fluocinolona Alpharma crema 0.01%', 'ACETONIDO DE FLUOCINOLONA CMA 20/01/100G', 5, 11.46, 19, 'generico', 'Medicamentos', 'Crema', 'Alpharma', 'Tubo 20 g', 'Acetonido de fluocinolona', '0.01%', true, 2, '2609272', 'https://www.farmacapital.mx/catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg', 'catalogo-propia/acetonido-fluocinolona-alpharma-20g-7502226294476.jpg'),
  (3, 'BEA215', '7501349025929', 'EQ-AMS362', 'Diclofenaco 75 mg/3 ml C/2 ampolletas AMSA', 'DICLOFENACO 2 FA 75MG/3 ML | AMSA (factura BEA215; caja AMSA)', 5, 7.67, 13, 'generico', 'Medicamentos', 'Solucion inyectable', 'AMSA', 'Caja con 2 ampolletas de 3 ml', 'Diclofenaco sodico', '75 mg/3 ml', true, 2, null, null, null),
  (4, 'BIO149', '7501573906407', 'FC-73906407', 'Lozamir-V clotrimazol crema 2%', 'LOZAMIR V C/3 APLICS 1 CMA 2% 20G', 5, 22.52, 29, 'marca', 'Medicamentos', 'Crema', 'Biomep', 'Tubo 20 g con 3 aplicadores', 'Clotrimazol', '2%', true, 2, 'CE2607', null, null),
  (5, 'BIO213', '7501573909859', 'FC-73909859', 'Sarox omeprazol 20 mg', 'SAROX 28 CAPS 20 MG', 5, 15.00, 19, 'marca', 'Medicamentos', 'Capsulas', 'Biomep', 'Caja con 28 capsulas', 'Omeprazol', '20 mg', true, 2, 'SG2653', null, null),
  (6, 'BRU053', '7501537102845', 'EQ-BRU053', 'Nediclon diclofenaco 100 mg', 'NEDICLON 20 GRAG 100 MG', 20, 8.84, 15, 'generico', 'Medicamentos', 'Grageas', 'Bruluart', 'Caja con 20 grageas de liberacion prolongada', 'Diclofenaco', '100 mg', true, 4, '807352', null, null),
  (7, 'BRU070', '7501537102067', 'EQ-BRU070', 'Soltrim trimetoprima/sulfametoxazol 40/200', 'SOLTRIM 1 SUSP 40/200/5/120 ML', 2, 28.00, 35, 'marca', 'Medicamentos', 'Suspension', 'Bruluart', 'Frasco suspension 120 mL', 'Trimetoprima / Sulfametoxazol', '40 mg / 200 mg / 5 mL', true, 2, '2605486', 'https://www.farmacapital.mx/catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg', 'catalogo-propia/soltrim-suspension-40-200-120ml-bruluart-7501537102067.jpg'),
  (8, 'CHI029', '7501088545658', 'EQ-CHI029', 'Mydocalm-A paracetamol/tolperisona 300/50 mg', 'MYDOCALM A 30 CAPS 300 MG/50 MG', 1, 363.75, 455, 'marca', 'Medicamentos', 'Capsulas', 'Chinoin', 'Caja con 30 capsulas', 'Paracetamol / Tolperisona', '300 mg / 50 mg', true, 1, 'BFC021', 'https://www.farmacapital.mx/catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg', 'catalogo-propia/mydocalm-a-paracetamol-tolperisona-300-50-30-caps-7501088545658.jpg'),
  (9, 'COD106', '7506484500034', 'FC-84500034', 'Cintapore micropore piel', 'CINTAPORE PIEL 12 PZAS 2.5 CM X 5 M', 1, 125.43, 157, 'marca', 'Botiquin', 'Cinta', 'Codifarma', 'Caja con 12 rollos 2.5 cm x 5 m', null, null, false, 1, '2804022', 'https://www.farmacapital.mx/catalogo-propia/cintapore-piel-2.5x5.jpg', 'catalogo-propia/cintapore-piel-2.5x5.jpg'),
  (10, 'FAC0059', '7502006920021', 'FC-06920021', 'Motilaxil-T picosulfato de sodio 5 mg', 'MOTILAXIL 20 TAB 5 MG', 5, 17.95, 23, 'marca', 'Medicamentos', 'Tabletas', 'Farmacos Continentales', 'Caja con 20 tabletas', 'Picosulfato de sodio', '5 mg', false, 2, 'ITG265092', null, null),
  (11, 'RAM092', '7502227874417', 'EQ-RAM092', 'Raamcedo aceclofenaco 100 mg', 'RAAMCEDO 10 TAB 100 MG', 2, 46.04, 58, 'marca', 'Medicamentos', 'Tabletas', 'Raam', 'Caja con 10 tabletas', 'Aceclofenaco', '100 mg', true, 2, 'RMD033', 'https://www.farmacapital.mx/catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg', 'catalogo-propia/raamcedo-aceclofenaco-100mg-10-raam-7502227874417.jpg'),
  (12, 'SFE159', '7503006698316', 'FC-06698316', 'Microdacyn 60 solucion antiseptica 120 ml', 'MICRODACYN 1 SOL 120 ML', 3, 154.84, 194, 'marca', 'Botiquin', 'Solucion', 'Microdacyn', 'Frasco spray 120 mL', 'Acido hipocloroso', null, false, 2, '209GD984', 'https://www.farmacapital.mx/catalogo-propia/microdacyn-60-solucion-120ml.jpg', 'catalogo-propia/microdacyn-60-solucion-120ml.jpg');

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
  'Factura Levic 9012545305 · clave ' || t.clave || ' · lote ' || coalesce(t.lote, 'caja'),
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
from _fc_rx_levic9012545305 t
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
from _fc_rx_levic9012545305 t
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
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen)
from _fc_rx_levic9012545305 t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(nullif(t.ean, '')),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Si se habia ligado EAN Beadvance a EQ-BEA215 por error, soltarlo.
update public.productos
set codigo_barras = null
where sku = 'EQ-BEA215'
  and codigo_barras in ('7501342802145', '7501349025929');

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012545305',
  '2026-10-26',
  1844.92,
  'borrador',
  'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012545305' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 1844.92,
  fecha = '2026-10-26',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja',
  updated_at = now()
where folio = '9012545305'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012545305'
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
        and (t.lote is null or l.numero_lote is distinct from t.lote)
    )
  ),
  null
from _fc_rx_levic9012545305 t
join public.recepciones r
  on r.folio = '9012545305'
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
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012545305' and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;

-- ========== BEA215 -> AMSA (si quedo Beadvance) ==========
-- ============================================================================
-- Levic 9012545305 · renglón BEA215 → caja real AMSA
--
-- Factura: BEA215 DICLOFENACO 20 TAB 100 MG (Beadvance)
-- Caja en mostrador: AMSA Diclofenaco iny 75 mg/3 mL C/2 · EAN 7501349025929
--                    (EQ-AMS362)
--
-- NO usar 7501342802145 (Beadvance). Si ya se pegó ese patch, este lo revierte.
-- Stock 0 hasta pistola + MMAA de la caja AMSA. No inventar 0000.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- Si se ligó el EAN Beadvance por error, quitarlo de EQ-BEA215.
update public.productos
set codigo_barras = null
where sku = 'EQ-BEA215'
  and codigo_barras = '7501342802145';

-- Asegurar EAN AMSA en el SKU correcto (ya debería estar).
update public.productos
set codigo_barras = '7501349025929'
where sku = 'EQ-AMS362'
  and (
    codigo_barras is null
    or btrim(codigo_barras) = ''
  )
  and not exists (
    select 1 from public.productos p2
    where p2.codigo_barras = '7501349025929'
      and p2.sku is distinct from 'EQ-AMS362'
  );

-- Renglón vivo del ticket: apunta a AMSA, no a Beadvance.
update public.recepcion_items i
set
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7501349025929'),
    public.fc_buscar_producto_escaneo('EQ-AMS362')
  ),
  codigo_escaneado = '7501349025929',
  nombre_snapshot = 'DICLOFENACO 2 FA 75MG/3 ML | AMSA (factura BEA215; caja AMSA)',
  numero_lote = null,
  fecha_caducidad = null,
  pendiente_alta = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501349025929'),
      public.fc_buscar_producto_escaneo('EQ-AMS362')
    ) is null
  ),
  confirmado = false,
  lote_id = null,
  lote_distinto = (
    coalesce(
      public.fc_buscar_producto_escaneo('7501349025929'),
      public.fc_buscar_producto_escaneo('EQ-AMS362')
    ) is not null
    and exists (
      select 1 from public.lotes l
      where l.producto_id = coalesce(
          public.fc_buscar_producto_escaneo('7501349025929'),
          public.fc_buscar_producto_escaneo('EQ-AMS362')
        )
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  )
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador'
  and not coalesce(i.confirmado, false)
  and (
    i.codigo_escaneado in ('EQ-BEA215', 'BEA215', '7501342802145')
    or i.nombre_snapshot ilike '%beadvance%'
    or i.producto_id = public.fc_buscar_producto_escaneo('EQ-BEA215')
  );

update public.recepciones
set
  notas = 'Factura Levic A 9012545305 · CFDI B57229E5-7DBB-4B9F-A23E-B1D28E33B872 · BEA215 en papel pero caja AMSA iny 7501349025929 · cola Recibir; MMAA de la caja AMSA',
  updated_at = now()
where folio = '9012545305'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

commit;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  i.pendiente_alta,
  i.confirmado,
  p.sku,
  p.marca
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012545305'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and (
    i.codigo_escaneado = '7501349025929'
    or i.nombre_snapshot ilike '%AMSA%'
    or i.nombre_snapshot ilike '%beadvance%'
  );

-- ========== LEVIC 9012442706 ==========
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
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.folio in ('9012545305', '9012442706')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;

-- ========== Equilibrio 450233 ==========
-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Equilibrio folio 450233 · 02-nov-2026 · $1,125.10 · 15 renglones / 42 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run si.
-- Sin bloques dollar-quote. Sin galeria extra. Idempotente en borrador.
-- Al final: VERIFICACION con folio 450233 en borrador.
-- Luego: tablet Recibir - recargar - tarjeta Equilibrio 450233.
-- =============================================================================

-- Equilibrio · ticket 450233 · 2026-11-02 · cliente 307513 Palillero · pedido online Iztapalapa 2 · Total $1,125.10 (subtotal P.U. $1,059.92 + IVA $65.18) · 15 renglones / 42 pzas. Claves EQF → EAN ficha/BuscaMed/Costofarma. Lote de fábrica sí. Caducidad NO: MMAA de la caja. 0000 inválido.
-- 7 alta(s) stock 0. 8 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_450233 (
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

insert into _fc_eq_450233 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7502009749698', 'FC-09749698', 'Bromhexina/oxeladina', 'MAV414 BROMHE/OXELAD 1 JBE 60/120MG/100/120', 2, 70.81, 89, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Maver', 'Maver', 'Frasco 225 ml', 'Bromhexina / oxeladina', '60 mg/100 ml / 120 mg/100 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg', 'catalogo-propia/verxolin-bromhexina-oxeladina-maver-7502009749698.jpg', '265229'),
  (2, '7503003406402', 'FC-34064021', 'Cotonetes Quirmex', 'QIR016 HISOPOS 1 ENVASE 100 PZAS', 7, 9.29, 12, 'marca', 'Higiene', 'Curación', 'Cotonetes', 'Quirmex', 'Quirmex', 'Envase 100 pzas', null, null, false, true, null, null, 'H1402226'),
  (3, '7503003406402', 'FC-34064021', 'Cotonetes Quirmex', 'QIR016 HISOPOS 1 ENVASE 100 PZAS', 3, 9.29, 12, 'marca', 'Higiene', 'Curación', 'Cotonetes', 'Quirmex', 'Quirmex', 'Envase 100 pzas', null, null, false, true, null, null, 'H1402026'),
  (4, '7502223112445', 'EQ-QUM052', 'Quimikan benzocaína 200 mg/mL', 'QUM052 QUIMIKAN 1 SOL C/ APLI 10 ML 200MG/ 1 ML', 3, 71.10, 114, 'generico', 'Medicamentos', null, 'Solución bucal', 'Quimikan', 'Quimpharma', 'Frasco 10 mL con aplicador', 'Benzocaína', '200 mg/mL', false, true, null, null, '26FS34'),
  (5, '7503003406051', 'FC-03406051', 'Gasa estéril Quirmex 10×10', 'QIR023 GASA ESTERILIZADA 10 SOB 10CMX10CM', 10, 9.89, 13, 'marca', 'Higiene', 'Curación', 'Gasa', 'Quirmex', 'Quirmex', 'Caja con 10 sobres 10×10 cm', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/quirmex-gasa-esteril-10x10-c10-7503003406051.jpg', 'catalogo-propia/quirmex-gasa-esteril-10x10-c10-7503003406051.jpg', 'GS2922826'),
  (6, '0780083144302', 'FC-83144302', 'Collifrin Adulto oximetazolina 0.05%', 'COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML', 5, 33.73, 54, 'generico', 'Medicamentos', 'Respiratorio', 'Solución nasal', 'Collifrin', 'Collins', 'Frasco 20 mL', 'Oximetazolina', '0.05%', false, true, null, null, '26140881'),
  (7, '7502009747052', 'FC-09747052', 'Coriver paracetamol 750 mg', 'MAV344 CORIVER 10 TAB 750 MG', 2, 8.04, 11, 'marca', 'Analgésico', null, 'Tableta', 'Coriver', 'Maver', 'Caja con 10 tabletas', 'Paracetamol', '750 mg', false, true, null, null, '263137'),
  (8, '7502001164697', 'EQ-SON096', 'Fenimeth V óvulos 500 mg / 100000 UI', 'SON098 FENIMETH V 12 OVS 500MG/100,000 UI', 3, 37.59, 61, 'generico', 'Medicamentos', 'Ginecología', 'Óvulo', 'Fenimeth', 'Son''s', 'Caja con 12 óvulos', 'Metronidazol / nistatina', '500 mg / 100000 UI', true, true, null, null, '26071744'),
  (9, '7503014377883', 'FC-14377883', 'Max Sens Uva', 'PBY019 MAX SENS UVA 1 CARTERA 3+1', 1, 28.12, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Cartera 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-uva-3plus1-7503014377883.jpg', 'catalogo-propia/max-sens-uva-3plus1-7503014377883.jpg', 'MUV070626'),
  (10, '7503014377890', 'FC-14377890', 'Max Sens Chocomenta', 'PBY021 MAX SENS CHOCOMENTA 1 CARTERA 3+1', 1, 28.11, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Cartera 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-chocomenta-3plus1-7503014377890.jpg', 'catalogo-propia/max-sens-chocomenta-3plus1-7503014377890.jpg', 'MCH010226'),
  (11, '7503014377197', 'EQ-PBY007', 'Max Sens Tropicana Mix', 'PBY007 MAX SENS TROPICANA MIX 1 BLISTER 3+1', 1, 28.13, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/max-sens-tropicana-mix-3plus1-7503014377197.jpg', 'catalogo-propia/max-sens-tropicana-mix-3plus1-7503014377197.jpg', 'TRP110726'),
  (12, '75034498', 'FC-75034498', 'Playboy Texturizado', 'PBY003 PLAYBOY TEXTURIZADO 1 BLISTER C/3 PZAS', 1, 37.53, 47, 'marca', 'Salud sexual', null, 'Preservativo', 'Playboy', 'Playboy', 'Blíster con 3 pzas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/playboy-texturizado-c3-75034498.jpg', 'catalogo-propia/playboy-texturizado-c3-75034498.jpg', '1330626'),
  (13, '75034481', 'FC-75034481', 'Playboy Extra Sensible', 'PBY002 PLAYBOY EXTRA SENSIBLE 1 BLISTER 3 PZAS', 1, 37.51, 47, 'marca', 'Salud sexual', null, 'Preservativo', 'Playboy', 'Playboy', 'Blíster con 3 pzas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/playboy-extra-sensible-c3-75034481.jpg', 'catalogo-propia/playboy-extra-sensible-c3-75034481.jpg', '2050426'),
  (14, '7503014377876', 'FC-14377876', 'Max Sens Fresa', 'PBY018 MAX SENS FRESA 1 BLISTER 3+1', 1, 28.15, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/max-sens-fresa-3plus1-7503014377876.jpg', 'catalogo-propia/max-sens-fresa-3plus1-7503014377876.jpg', 'MFR090726'),
  (15, '7503014377180', 'EQ-PBY008', 'Max Sens Passion Mix', 'PBY008 MAX SENS PASSION MIX 1 BLISTER 3+1', 1, 28.15, 36, 'marca', 'Salud sexual', null, 'Preservativo', 'Max Sens', 'Playboy', 'Blíster 3+1', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/max-sens-passion-mix-3plus1-7503014377180.jpg', 'catalogo-propia/max-sens-passion-mix-3plus1-7503014377180.jpg', 'PAS210626');

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
  'Alta Equilibrio 450233 · 2026-11-02 · listo para pistola',
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
  from _fc_eq_450233
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
  from _fc_eq_450233
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
  from _fc_eq_450233
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '450233',
  '2026-11-02',
  1125.10,
  'borrador',
  'Ticket Equilibrio folio 450233 · cliente 307513 Luis Angel · 02-nov-2026 · 42 pzas · $1,125.10 · lote de fábrica en renglón; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '450233'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 1125.10,
  fecha = '2026-11-02',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 450233 · cliente 307513 Luis Angel · 02-nov-2026 · 42 pzas · $1,125.10 · lote de fábrica en renglón; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '450233'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '450233'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
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
from _fc_eq_450233 t
join public.recepciones r
  on r.folio = '450233'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

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
where r.folio = '450233'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_eq_450233 t
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
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '450233'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

-- ========== Cityfarma S336478/S336493 + Equilibrio 450041 (30-oct) ==========
-- ============================================================================
-- Tickets 30-oct-2026 → cola Recibir (borrador)
--
-- 1) Cityfarma Iztapalapa · S336478 · $1,880.68
-- 2) Equilibrio Iztapalapa 2 · 450041 · $152.64
-- 3) Cityfarma Iztapalapa · S336493 · $716.58 (pendiente de pago en papel)
--
-- Stock 0 hasta pistola + MMAA. No inventar caducidad 0000.
-- Cityfarma: P.U. ya con IVA (suma de renglones = total).
-- Equilibrio: costo neto tras descuento; lote/cad del ticket no se guarda.
-- SIN bloques dollar-quote. Idempotente mientras cada ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_tk_20261030 (
  ticket text not null,
  linea integer not null,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_20261030 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
-- ── Cityfarma S336478 ──
('cityfarma478', 1, '7501318652293', 'FC-18652293',
 'Actron 400 mg', 'ACTRON 400 MG C/10 B',
 2, 110.67, 139, 'marca', 'Medicamentos',
 null, 'Cápsula', 'Actron', 'Bayer',
 'Caja con 10 cápsulas', 'Ibuprofeno', '400 mg', false, true,
 'https://www.farmacapital.mx/catalogo-propia/actron-400mg-10caps-7501318652293.jpg'),
('cityfarma478', 2, '7501318652453', 'FC-18652453',
 'Actron 600 mg', 'ACTRON 600MG 10CAPS',
 2, 124.63, 156, 'marca', 'Medicamentos',
 null, 'Cápsula', 'Actron', 'Bayer',
 'Caja con 10 cápsulas', 'Ibuprofeno', '600 mg', false, true,
 'https://www.farmacapital.mx/catalogo-propia/actron-600mg-10caps-7501318652453.jpg'),
('cityfarma478', 3, '7501318658189', 'FC-18658189',
 'Actron Plus 400/100 mg', 'ACTRON PLUS 400/100M',
 2, 148.64, 186, 'marca', 'Medicamentos',
 null, 'Cápsula', 'Actron', 'Bayer',
 'Caja con 10 cápsulas', 'Ibuprofeno / cafeína', '400/100 mg', false, true,
 'https://www.farmacapital.mx/catalogo-propia/actron-plus-400-100mg-10caps-7501318658189.jpg'),
('cityfarma478', 4, '7501299303047', 'FC-9303047',
 'Cicloferon crema', 'CICLOFERON BCO 2GR C',
 2, 49.14, 62, 'marca', 'Medicamentos',
 'Dermatológico', 'Crema', 'Cicloferon', 'Liomont',
 'Tubo 2 g', 'Aciclovir', '5%', false, true,
 'https://www.farmacapital.mx/catalogo-propia/cicloferon-crema-2g-7501299303047.jpg'),
('cityfarma478', 5, '5000174305449', 'FC-74305449',
 'Fixodent Original', 'FIXODENT ORG 40ML AD',
 3, 78.89, 99, 'marca', 'Cuidado personal',
 'Bucal', 'Adhesivo dental', 'Fixodent', 'P&G',
 'Tubo 40 ml', null, null, false, true,
 'https://www.farmacapital.mx/catalogo-propia/fixodent-original-40ml-5000174305449.jpg'),
('cityfarma478', 6, '7506339394733', 'FC-39394733',
 'Fixodent Plus', 'FIXODENT PLUS',
 3, 78.50, 99, 'marca', 'Cuidado personal',
 'Bucal', 'Adhesivo dental', 'Fixodent', 'P&G',
 'Tubo 35 ml', null, null, false, true,
 'https://www.farmacapital.mx/catalogo-propia/fixodent-plus-35ml-7506339394733.jpg'),
('cityfarma478', 7, '7501008497340', 'FC-84973401',
 'Flanax 550 mg', 'FLANAX 550 C 12 TABS',
 2, 173.02, 217, 'marca', 'Medicamentos',
 null, 'Tableta', 'Flanax', 'Bayer',
 'Caja con 12 tabletas', 'Naproxeno sódico', '550 mg', false, true,
 'https://www.farmacapital.mx/catalogo-propia/flanax-550mg-12tab-7501008497340.jpg'),
('cityfarma478', 8, '7501008498866', 'FC-08498866',
 'Flanax 550 mg', 'FLANAX 550MG C6 TABS',
 2, 98.16, 123, 'marca', 'Medicamentos',
 null, 'Tableta', 'Flanax', 'Bayer',
 'Caja con 6 tabletas', 'Naproxeno sódico', '550 mg', false, true,
 'https://www.farmacapital.mx/catalogo-propia/flanax-550mg-6tab-7501008498866.jpg'),

-- ── Equilibrio 450041 ──
('equilibrio', 1, '7501349021570', 'FC-49021570',
 'Amoxicilina 500 mg', 'AMOXICILINA 12 CAPS 500 MG | AMS265',
 8, 19.08, 31, 'generico', 'Medicamentos',
 null, 'Cápsula', 'AMSA', 'AMSA',
 'Caja con 12 cápsulas', 'Amoxicilina', '500 mg', true, true,
 'https://www.farmacapital.mx/catalogo-propia/amoxicilina-500mg-12caps-amsa-7501349021570.jpg'),

-- ── Cityfarma S336493 ──
('cityfarma493', 1, '7501258215046', 'FC-58215046',
 'Binotal 1 g', 'BINOTAL 1GR C28 LAKE',
 2, 263.41, 330, 'marca', 'Medicamentos',
 null, 'Tableta', 'Binotal', 'Lakeside',
 'Caja con 28 tabletas', 'Ampicilina', '1 g', true, true,
 'https://www.farmacapital.mx/catalogo-propia/binotal-1g-28tab-7501258215046.jpg'),
('cityfarma493', 2, '7501258214520', 'FC-58214520',
 'Binotal 500 mg', 'BINOTAL 500MG C20 CA',
 2, 94.88, 119, 'marca', 'Medicamentos',
 null, 'Cápsula', 'Binotal', 'Lakeside',
 'Caja con 20 cápsulas', 'Ampicilina', '500 mg', true, true,
 'https://www.farmacapital.mx/catalogo-propia/binotal-500mg-20caps-7501258214520.jpg');

-- Altas
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 30-oct-2026 · ' || t.ticket || ' · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_20261030
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

-- Costos (no baja PVP bueno)
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_20261030
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- Ficha / foto si falta
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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_20261030
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- ═══════════════════════════════════════════════════════════
-- Recepciones
-- ═══════════════════════════════════════════════════════════

-- Cityfarma S336478
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S336478',
  '2026-10-30',
  1880.68,
  'borrador',
  'Ticket Cityfarma S336478 · 30-oct-2026 16:14 · Actron · Cicloferon · Fixodent · Flanax · tarjeta $1,880.68 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S336478' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1880.68,
  fecha = '2026-10-30',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S336478 · 30-oct-2026 16:14 · Actron · Cicloferon · Fixodent · Flanax · tarjeta $1,880.68 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S336478'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S336478'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_tk_20261030 t
join public.recepciones r
  on r.folio = 'S336478' and coalesce(r.proveedor, '') ilike '%cityfarma%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'cityfarma478'
order by t.linea;

-- Equilibrio 450041
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '450041',
  '2026-10-30',
  152.64,
  'borrador',
  'Pedido Equilibrio 450041 · Iztapalapa 2 · 30-oct-2026 17:08 · Amoxicilina AMSA 500 mg ×8 @ $19.08 · $152.64 · cola Recibir; stock al confirmar pistola + MMAA (no pegar lote del ticket)'
where not exists (
  select 1 from public.recepciones
  where folio = '450041' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 152.64,
  fecha = '2026-10-30',
  proveedor = 'Equilibrio',
  notas = 'Pedido Equilibrio 450041 · Iztapalapa 2 · 30-oct-2026 17:08 · Amoxicilina AMSA 500 mg ×8 @ $19.08 · $152.64 · cola Recibir; stock al confirmar pistola + MMAA (no pegar lote del ticket)',
  updated_at = now()
where folio = '450041'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '450041'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_tk_20261030 t
join public.recepciones r
  on r.folio = '450041' and coalesce(r.proveedor, '') ilike '%equilibrio%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'equilibrio'
order by t.linea;

-- Cityfarma S336493
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S336493',
  '2026-10-30',
  716.58,
  'borrador',
  'Ticket Cityfarma S336493 · 30-oct-2026 16:56 · Binotal 1 g + 500 mg · pendiente de pago en papel $716.58 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S336493' and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 716.58,
  fecha = '2026-10-30',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S336493 · 30-oct-2026 16:56 · Binotal 1 g + 500 mg · pendiente de pago en papel $716.58 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S336493'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S336493'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_tk_20261030 t
join public.recepciones r
  on r.folio = 'S336493' and coalesce(r.proveedor, '') ilike '%cityfarma%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'cityfarma493'
order by t.linea;

commit;

-- ========== Bodega F-42 / Citymark 76370 ==========
-- ============================================================================
-- Bodega F-42 / Citymark · Caja 1/76370 · 2026-10-30 16:54 · $1,192.28 → cola Recibir
--
-- Ticket térmico Citymark Ejidos del Moral. P.U. ya con IVA (suma = total tarjeta).
-- 12 renglones · 27 piezas. Stock al escanear + MMAA. No inventar 0000.
-- Nombres de mostrador, no del ticket. Fotos en catalogo-propia/.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_bf42_76370 (
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
  receta boolean not null default false,
  imagen text
) on commit drop;

insert into _fc_bf42_76370 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '070942507240', 'FC-42507240',
 'GUM cera ortodoncia menta',
 'CERA DENT GUM P/ORTODON MENT',
 2, 56.51, 71, 'marca', 'Cuidado personal',
 'Bucal', 'Cera', 'GUM', 'Sunstar',
 'Caja con 5 barras', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-cera-ortodoncia-menta-070942507240.jpg'),
(2, '7502221012303', 'FC-21012303',
 'Claris toallas desmaquillantes aloe',
 'TAS HUM CLARIS DESMAQ ALOE C/40',
 4, 18.86, 24, 'marca', 'Cuidado personal',
 'Desmaquillante', 'Toallas húmedas', 'Claris', 'Betone',
 'Caja con 40 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/claris-toallas-desmaquillantes-aloe-40-7502221012303.jpg'),
(3, '7506306217669', 'FC-06217669',
 'Pond''s gel limpiador facial sandía',
 'GEL LIM PONDS FAC 2EN1 SAND 200ML',
 1, 104.83, 132, 'marca', 'Cuidado personal',
 'Limpieza facial', 'Gel', 'Pond''s', 'Unilever',
 'Botella 200 ml', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/ponds-gel-limpiador-sandia-200ml-7506306217669.jpg'),
(4, '7506306248175', 'FC-06248175',
 'Pond''s gel limpiador facial Vs Manchas',
 'GEL LIMP PONDS VS MANCHA2-1 200ML',
 1, 107.21, 135, 'marca', 'Cuidado personal',
 'Limpieza facial', 'Gel', 'Pond''s', 'Unilever',
 'Botella 200 ml', 'Vitamina C', null, false,
 'https://www.farmacapital.mx/catalogo-propia/ponds-gel-limpiador-vs-manchas-200ml-7506306248175.jpg'),
(5, '7501565603345', 'FC-65603345',
 'Venda enyesada Galia 20 cm',
 'VENDA ENYESADA GALIA 20 CM X 2.75 M',
 1, 36.69, 46, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '20 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-20cm-7501565603345.jpg'),
(6, '7502304290307', 'FC-04290307',
 'GUM kit ortodoncia Bob Esponja',
 'KIT GUM ORTODONCIA BOB ESPONJA',
 1, 105.65, 133, 'marca', 'Cuidado personal',
 'Bucal', 'Kit', 'GUM', 'Sunstar',
 'Kit (cepillo, cera, interdentales, protector)', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-kit-ortodoncia-bob-esponja-7502304290307.jpg'),
(7, '070942125352', 'FC-42125352',
 'GUM kit ortodoncia 6 piezas',
 'KIT DE ORTODONCIA GUM 6PZAS',
 1, 130.02, 163, 'marca', 'Cuidado personal',
 'Bucal', 'Kit', 'GUM', 'Sunstar',
 'Kit con 6 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-kit-ortodoncia-6pzas-070942125352.jpg'),
(8, '070942304542', 'FC-42304542',
 'GUM hilo dental + enhebrador',
 'HILO DENT GUM + ENHEBRADOR 22.9M',
 1, 97.54, 122, 'marca', 'Cuidado personal',
 'Bucal', 'Hilo dental', 'GUM', 'Sunstar',
 '22.9 m con enhebrador', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/gum-hilo-dental-enhebrador-22.9m-070942304542.jpg'),
(9, '7501565603338', 'FC-65603338',
 'Venda enyesada Galia 15 cm',
 'VENDA GALIA ENYESADA 15CMX2.75M N',
 4, 26.79, 34, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '15 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-15cm-7501565603338.jpg'),
(10, '7501565603314', 'FC-65603314',
 'Venda enyesada Galia 5 cm',
 'VENDA ENYESADA GALIA 5 CM X 2.75 M',
 8, 14.21, 18, 'marca', 'Botiquín',
 'Material de curación', 'Venda', 'Galia', 'Gal Tex',
 '5 cm × 2.75 m', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/galia-venda-enyesada-5cm-7501565603314.jpg'),
(11, '7800005064020', 'FC-05064020',
 'Oral-B Super Floss',
 'HILO DENT ORAL-B SUPER-FLOSS C/50',
 2, 70.02, 88, 'marca', 'Cuidado personal',
 'Bucal', 'Hilo dental', 'Oral-B', 'P&G',
 'Caja con 50 hilos', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/oral-b-super-floss-50-7800005064020.jpg'),
(12, '7501026462078', 'FC-26462078',
 'Ternura chupón flor-balón con miel',
 'TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL',
 1, 61.02, 77, 'marca', 'Cuidado personal',
 'Bebé', 'Chupón', 'Ternura', 'Carter',
 'Exhibidor con 18 piezas', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-flor-balon-miel-18-7501026462078.jpg');

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
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 76370 · 2026-10-30 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_bf42_76370 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_bf42_76370 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '^(CERA DENT|TAS HUM|GEL LIM|VENDA |KIT |HILO DENT|TERNURA )'
      then t.nombre
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
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from _fc_bf42_76370 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '76370',
  '2026-10-30',
  1192.28,
  'borrador',
  'Ticket Citymark / Bodega F-42 Caja 1/76370 · 30-oct-2026 16:54 · GUM ortodoncia · Pond''s · Galia · Oral-B Super Floss · Ternura · $1,192.28 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '76370' and coalesce(proveedor, '') ilike '%bodega%f-42%'
);

update public.recepciones
set
  total_ticket = 1192.28,
  fecha = '2026-10-30',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Citymark / Bodega F-42 Caja 1/76370 · 30-oct-2026 16:54 · GUM ortodoncia · Pond''s · Galia · Oral-B Super Floss · Ternura · $1,192.28 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '76370'
  and coalesce(proveedor, '') ilike '%bodega%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '76370'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
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
from _fc_bf42_76370 t
join public.recepciones r
  on r.folio = '76370'
 and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

-- select folio, proveedor, total_ticket, estado from recepciones where folio = '76370';
-- select codigo_escaneado, nombre_snapshot, cantidad, costo_estimado, pendiente_alta
-- from recepcion_items where recepcion_id = (select id from recepciones where folio = '76370' limit 1)
-- order by id;

-- ========== Farmalive 11104 ==========
-- ============================================================================
-- Farmalive Club Iztapalapa 1 · ticket 11104 · 2026-10-30 · $496.47 → cola Recibir
--
-- Costo = P.U. neto con descuento 2%. 14 unidades · tarjeta.
-- Altas nuevas: Vitacilina Facial PDRN + Exosomas (ficha oficial vitacilina.mx).
-- Glucerna / Electrolit ya en catálogo: costo ticket, no baja PVP bueno.
-- Stock al escanear + MMAA. No inventar 0000.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_fl11104 (
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
  receta boolean not null default false,
  imagen text
) on commit drop;

insert into _fc_fl11104 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, imagen
) values
(1, '7502250343232', 'FC-50343232',
 'Vitacilina Facial PDRN',
 'CRE VITACILINA FACIAL PDRN 100 GR | KSK',
 1, 97.90, 123, 'marca', 'Cuidado personal',
 'Facial', 'Crema', 'Vitacilina', 'KSK',
 'Tarro 100 g', 'PDRN / ácido hialurónico', null, false,
 'https://www.farmacapital.mx/catalogo-propia/vitacilina-facial-pdrn-100g-7502250343232.jpg'),
(2, '7502250343249', 'FC-50343249',
 'Vitacilina Facial Exosomas',
 'CRE VITACILINA FACIAL EXOSOMAS 100 GR | KSK',
 1, 97.90, 123, 'marca', 'Cuidado personal',
 'Facial', 'Crema', 'Vitacilina', 'KSK',
 'Tarro 100 g', 'Exosomas / retinol', null, false,
 'https://www.farmacapital.mx/catalogo-propia/vitacilina-facial-exosomas-100g-7502250343249.jpg'),
(3, '7501033956126', 'FC-33956126',
 'Glucerna líquido vainilla',
 'GLUCERNA LIQ VAINILLA 237 ML | ABBOTT',
 2, 52.33, 66, 'marca', 'Suplementos',
 null, 'Líquido', 'Glucerna', 'Abbott',
 'Frasco 237 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/glucerna-liquido-vainilla-237ml-7501033956126.jpg'),
(4, '7501125144851', 'FC-51448511',
 'Electrolit Uva',
 'ELECTROLIT UVA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-uva-625ml-7501125144851.jpg'),
(5, '7501125187179', 'FC-25187179',
 'Electrolit Guayaba',
 'ELECTROLIT GUAYABA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-guayaba-625ml-7501125187179.jpg'),
(6, '7503046131224', 'FC-46131224',
 'Electrolit Ponche de frutas',
 'ELECTROLIT PONCHE FRUTAS 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-ponche-frutas-625ml-7503046131224.jpg'),
(7, '7501125103582', 'FC-25103582',
 'Electrolit Piña',
 'ELECTROLIT PIÑA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-pina-625ml-7501125103582.jpg'),
(8, '7501125104688', 'FC-25104688',
 'Electrolit Naranja-Mandarina',
 'ELECTROLIT NJA/MANDARINA 625 ML | LAB PISA',
 2, 19.60, 25, 'marca', 'Bebidas',
 'Electrolitos', 'Suero oral', 'Electrolit', 'Pisa',
 'Botella 625 mL', null, null, false,
 'https://www.farmacapital.mx/catalogo-propia/electrolit-naranja-mandarina-625ml-7501125104688.jpg');

-- Altas (solo si EAN / SKU no existen)
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
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmalive 11104 · 2026-10-30 · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, t.receta,
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion,
  t.laboratorio, t.imagen, t.imagen
from _fc_fl11104 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

-- Costos del ticket (no baja PVP bueno)
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from _fc_fl11104 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 1
    or nullif(btrim(p.codigo_barras), '') is null
  );

-- Completar ficha / foto si falta
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* '^(CRE |GLUCERNA LIQ|ELECTROLIT )'
      then t.nombre
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
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from _fc_fl11104 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Recepción borrador
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '11104',
  '2026-10-30',
  496.47,
  'borrador',
  'Ticket Farmalive 11104 · Club Iztapalapa 1 · 30-oct-2026 15:24 · Vitacilina Facial PDRN/Exosomas · Glucerna · Electrolit ×5 sabores · $496.47 · descto 2% · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '11104' and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 496.47,
  fecha = '2026-10-30',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 11104 · Club Iztapalapa 1 · 30-oct-2026 15:24 · Vitacilina Facial PDRN/Exosomas · Glucerna · Electrolit ×5 sabores · $496.47 · descto 2% · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '11104'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '11104'
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
from _fc_fl11104 t
join public.recepciones r
  on r.folio = '11104'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

commit;

-- select folio, proveedor, total_ticket, estado from recepciones where folio = '11104';
-- select codigo_escaneado, nombre_snapshot, cantidad, costo_estimado, pendiente_alta
-- from recepcion_items where recepcion_id = (select id from recepciones where folio = '11104' limit 1)
-- order by id;

-- ========== Fanasa B49397867 Lubrex ==========
-- ============================================================================
-- Ticket Fanasa B49397867 → cola Recibir (borrador)
--
-- Factura 28-oct-2026 · FARMACAPITAL LA CAPI · $224.18 · 1 pza
-- EAN 7502231320665 · Lubrex (factura imprime LIBREX) · MPM
-- Costo farmacia $224.18 · PVP sugerido +25% marca = $281
-- Stock 0 hasta pistola + MMAA. No inventar caducidad 0000.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: public/catalogo-propia/lubrex-0.5-10ml.jpg (después del deploy).
-- ============================================================================

begin;

create temp table _fc_tk_fanasa_20261028 (
  ticket text not null,
  linea integer not null,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default false,
  imagen text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_fanasa_20261028 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
('fanasa', 1, '7502231320665', 'FC-31320665',
 'Lubrex', 'LIBREX CARBOXIMETILCELULOSA SODICA 0.5 % 1 SOL 10 ml | MPM',
 1, 224.18, 281, 'marca', 'Medicamentos', 'Oftalmología', 'Solución oftálmica',
 'Lubrex', 'Micro Pharmaceuticals', 'Frasco gotero 10 ml',
 'Carboximetilcelulosa sódica', '0.5%', false, true,
 'https://www.farmacapital.mx/catalogo-propia/lubrex-0.5-10ml.jpg');

-- ═══════════════════════════════════════════════════════════
-- Alta (solo si aún no existe)
-- ═══════════════════════════════════════════════════════════
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket Fanasa B49397867 · 28-oct-2026 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_20261028
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

-- Costo de ticket en ficha ya existente (no baja PVP bueno).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_20261028
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or upper(trim(coalesce(p.nombre, ''))) like 'LIBREX%'
      then t.nombre
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_fanasa_20261028
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- ═══════════════════════════════════════════════════════════
-- Recepción Fanasa B49397867
-- ═══════════════════════════════════════════════════════════
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Fanasa',
  'B49397867',
  '2026-10-28',
  224.18,
  'borrador',
  'Factura Fanasa B49397867 · 28-oct-2026 · pedido 56961663 · Lubrex 0.5% 10 ml ×1 · $224.18 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'B49397867'
    and coalesce(proveedor, '') ilike '%fanasa%'
);

update public.recepciones
set
  total_ticket = 224.18,
  fecha = '2026-10-28',
  proveedor = 'Fanasa',
  notas = 'Factura Fanasa B49397867 · 28-oct-2026 · pedido 56961663 · Lubrex 0.5% 10 ml ×1 · $224.18 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'B49397867'
  and coalesce(proveedor, '') ilike '%fanasa%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'B49397867'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
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
from _fc_tk_fanasa_20261028 t
join public.recepciones r
  on r.folio = 'B49397867'
 and coalesce(r.proveedor, '') ilike '%fanasa%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'fanasa'
order by t.linea;

commit;

-- Diagnóstico
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where i.pendiente_alta) as sin_alta,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = 'B49397867'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 60) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.pendiente_alta,
  i.producto_id,
  p.nombre as ficha,
  p.sku,
  p.precio
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = 'B49397867'
  and r.estado = 'borrador'
  and coalesce(r.proveedor, '') ilike '%fanasa%'
order by i.id;



-- ========== NADRO 6091546907 (Dove / Memantina / Zolufen) ==========
-- Pedido Nadro folio 6091546907 (2026-10-25) — altas + cola Recibir.
-- Factura CFDI · total $312.34 · UUID 02768924-…
-- Ficha iNadro (no código del PDF). LGEN no va como marca.
-- SIN bloques dollar-quote (do XX). El SQL Editor de Supabase los corta.
--
-- Ya existía (renombrar ficha + costo):
--   FC-06241206 Dove Dermoaclarant Skin Calming spray 150 ml
-- Altas nuevas stock 0:
--   FC-06241183 Dove Original spray 150 ml
--   FC-42701200 Memantina 10 mg C/28 (Corne)
--   FC-23553477 Zolufen (Omeprazol) 20 mg C/30 (Synthon / Novo Nafar)
-- Ticket borrador. Stock al escanear + MMAA de la caja. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Fotos: tras deploy, pegar sql/patch_fotos_nadro_6091546907.sql

begin;

create temp table _fc_nd6091546907 (
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
  lote text,
  receta boolean not null,
  alta_nueva boolean not null
) on commit drop;

insert into _fc_nd6091546907
  (linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria, subcategoria,
   marca, presentacion, forma, laboratorio, principio_activo, concentracion, lote,
   receta, alta_nueva)
values
  (1, '7506306241206', 'FC-06241206',
   'Dove Dermoaclarant Skin Calming',
   'DESOD DOVE DERMAC SK-C 48H SPY150ML',
   1, 41.35, 52, 'marca', 'Cuidado personal', 'Desodorantes',
   'Dove', 'Spray 150 ml', 'Spray', 'Unilever', null, null, null,
   false, false),
  (2, '7506306241183', 'FC-06241183',
   'Dove Original',
   'DESOD DOVE ORIGINAL 48H SPY150ML',
   2, 41.04, 52, 'marca', 'Cuidado personal', 'Desodorantes',
   'Dove', 'Spray 150 ml', 'Spray', 'Unilever', null, null, null,
   false, true),
  (3, '7502242701200', 'FC-42701200',
   'Memantina 10 mg',
   'MEMANTINA 10 MG 28 TAB LGEN',
   1, 90.41, 145, 'generico', 'Medicamentos', 'Sistema nervioso',
   null, 'Caja con 28 tabletas', 'Tableta', 'Corne', 'Memantina', '10 mg', '252570',
   true, true),
  (4, '7502223553477', 'FC-23553477',
   'Zolufen (Omeprazol) 20 mg',
   'OMEPRAZOL 20 MG 30 CAPS LGEN',
   5, 15.75, 26, 'generico', 'Medicamentos', 'Gastrointestinal',
   'Zolufen', 'Frasco con 30 cápsulas', 'Cápsula', 'Synthon', 'Omeprazol', '20 mg', 'ZZ8011A',
   false, true);

-- Altas nuevas (solo si el EAN no existe).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta
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
  'Alta Nadro 6091546907 · 2026-10-25 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6091546907 t
where t.alta_nueva
  and public.fc_buscar_producto_escaneo(t.ean) is null;

-- Ficha de mostrador (marca real; no LGEN).
update public.productos p set
  marca = t.marca,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio_activo,
  concentracion = coalesce(t.concentracion, p.concentracion),
  subcategoria = t.subcategoria,
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  nombre = t.nombre,
  categoria = t.categoria,
  tipo = t.tipo,
  requiere_receta = t.receta
from _fc_nd6091546907 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Costos del ticket (PVP solo si estaba en 0).
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from _fc_nd6091546907 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6091546907',
  '2026-10-25',
  312.34,
  'borrador',
  'Factura Nadro 6091546907 · 25-oct-2026 · CFDI · EAN iNadro · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '6091546907' and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  total_ticket = 312.34,
  fecha = '2026-10-25',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6091546907 · 25-oct-2026 · CFDI · EAN iNadro · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '6091546907'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6091546907'
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
  nullif(btrim(t.lote), ''),
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
from _fc_nd6091546907 t
join public.recepciones r
  on r.folio = '6091546907'
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

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote as lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado,
  p.sku,
  left(p.nombre, 40) as nombre_catalogo
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '6091546907' and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;
-- VERIFICACION global (folios de este pegado)
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  count(*) filter (where i.lote_id is not null) as con_stock_lote,
  case
    when count(i.*) = 0 then 'FALTA RENGLONES'
    when count(*) filter (where not coalesce(i.confirmado, false)) > 0 then 'OK visible en Recibir'
    when count(*) filter (where i.lote_id is not null) = count(i.*) then 'YA RECIBIDO'
    else 'REVISAR'
  end as veredicto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio = 'B49445264' and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio = 'B49397867' and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171','6091546907') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  )
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.proveedor, r.folio;

with esperados(folio) as (
  values
    ('3838940'),('B49445264'),('B49397867'),('6091110421'),('6091723171'),
    ('6091546907'),('9012545305'),('9012442706'),('450233'),('450041'),
    ('S336478'),('S336493'),('76370'),('11104')
)
select e.folio, 'NO EXISTE despues del Run — manda captura del error rojo' as problema
from esperados e
where not exists (select 1 from public.recepciones r where r.folio = e.folio);
