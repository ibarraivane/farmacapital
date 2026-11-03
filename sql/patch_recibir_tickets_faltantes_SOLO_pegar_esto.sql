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
