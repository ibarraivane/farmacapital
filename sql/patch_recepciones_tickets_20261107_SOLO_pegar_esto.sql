-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Tickets 07-nov-2026 → cola Recibir (borrador)
--
-- 1) Equilibrio · 450987 · $697.11 · 6 renglones / 22 pzas
-- 2) Cityfarma Iztapalapa · S338883 · $1,884.14 · 10 renglones / 16 pzas
-- 3) Bodega F-42 · 86837 · $451.12 · 9 renglones / 12 pzas
--
-- Merge a GitHub NO crea la tarjeta. Este Run sí.
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Caducidad null (MMAA de la caja). No inventar 0000.
-- Equilibrio: lote de fábrica en renglón. Cityfarma/Bodega: lote null.
-- =============================================================================

begin;

create temp table _fc_tk_20261107 (
  ticket text not null,
  linea integer not null,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
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
  lote text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_20261107 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen, lote
) values
('equilibrio', 1, '7502211786788', 'EQ-LOE096', 'Vidalol Plus', 'LOE096 VILADOL PLUS 20 TAB 10/500 MG', 5, 47.91, 77, 'generico', 'Medicamentos', 'Gastro', 'Tableta', 'Vidalol', 'Loeffler', 'Caja con 20 tabletas', 'Butilhioscina / paracetamol', '10/500 mg', true, false, null, 'R2606704'),
('equilibrio', 2, '7501349022515', 'FC-22B18244', 'Cefotaxima IM 1 g', 'AMS263 CEFOTAXIMA I.M. 1 FA 1G/4 ML', 3, 33.23, 54, 'generico', 'Medicamentos', 'Antibióticos', 'Solución inyectable', 'AMSA', 'AMSA', 'Frasco ámpula con diluyente 4 ml', 'Cefotaxima', '1 g / 4 ml', true, false, null, 'J26M085'),
('equilibrio', 3, '7502009747281', 'FC-09747281', 'Dolver ibuprofeno 800 mg', 'MAV343 DOLVER 10 TAB 800 MG', 5, 20.79, 34, 'generico', 'Analgésico', null, 'Tableta', 'Dolver', 'Maver', 'Caja con 10 tabletas', 'Ibuprofeno', '800 mg', false, true, null, '261657'),
('equilibrio', 4, '7502001161511', 'EQ-SON024', 'Bentix', 'SON024 BENTIX 1 CMA 40G 3/0.0 %', 3, 29.20, 47, 'generico', 'Medicamentos', 'Dermatológico', 'Crema', 'Bentix', 'Son''s', 'Tubo 40 g', 'Clioquinol / fluocinolona', '3% / 0.01%', true, false, null, '26071952'),
('equilibrio', 5, '7502001160019', 'EQ-SON033', 'Busconet inyectable', 'SON033 BUSCONET 1 FA 250/20MG/5ML', 3, 35.57, 57, 'generico', 'Medicamentos', 'Gastro', 'Solución inyectable', 'Busconet', 'Son''s', 'Frasco ámpula 5 ml', 'Metamizol sódico / butilhioscina', '250/20 mg / 5 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/busconet-inyectable-5ml.jpg', '26051306'),
('equilibrio', 6, '7501349012004', 'FC-BE76D409', 'Amcef IM 1 g', 'AMS004 AMCEF I.M. 1 FA 1G/3.5 ML', 3, 19.87, 32, 'generico', 'Medicamentos', 'Antibióticos', 'Solución inyectable', 'Amcef', 'AMSA', 'Frasco ámpula con diluyente 3.5 ml', 'Ceftriaxona', '1 g / 3.5 ml', true, false, null, 'J25N051'),
('cityfarma', 1, '7500462746698', 'FC-62746698', 'Ajolotius Reforzado', 'AJOLOTIUS REFORZADO', 2, 55.10, 69, 'marca', 'Suplementos', null, 'Jarabe', 'Ajolotius', 'Bioalimentos', 'Frasco 250 ml', null, null, false, false, null, null),
('cityfarma', 2, '7502321440013', 'FC-21440013', 'Buscapina Duo', 'BUSCAPINA DUO C10 TA', 3, 106.44, 134, 'marca', 'Medicamentos', 'Gastro', 'Tableta', 'Buscapina', 'Sanofi', 'Caja con 10 tabletas', 'Hioscina / paracetamol', '10/500 mg', false, true, null, null),
('cityfarma', 3, '7501070615277', 'FC-70615277', 'Daflon 500 mg', 'DAFLON 500M C 20 TAB', 1, 430.00, 538, 'marca', 'Medicamentos', 'Circulatorio', 'Tableta', 'Daflon', 'Sanfer', 'Caja con 20 tabletas', 'Diosmina / hesperidina', '450/50 mg', false, true, null, null),
('cityfarma', 4, '7501075727890', 'FC-75727890', 'Duosym', 'DUOSYM TRIMEBUTINA/S', 2, 123.94, 155, 'marca', 'Medicamentos', 'Gastro', 'Comprimido', 'Duosym', 'Novag', 'Caja con 24 comprimidos', 'Trimebutina / simeticona', '200/75 mg', false, true, null, null),
('cityfarma', 5, '7501064560163', 'FC-64560163', 'Iodex Cristal', 'IQDEX CRISTAL 24', 1, 72.77, 91, 'marca', 'Cuidado personal', 'Ungüento', 'Ungüento', 'Iodex', 'Haleon', 'Tubo 60 g', 'Mentol / eucalipto', null, false, false, null, null),
('cityfarma', 6, '7501300408259', 'FC-00408259', 'Plidan 10 mg', 'PLIDAN 10 MG C 20 CO', 1, 239.12, 299, 'marca', 'Medicamentos', 'Gastro', 'Comprimido', 'Plidan', 'Siegfried Rhein', 'Caja con 20 comprimidos', 'Pargeverina', '10 mg', false, true, null, null),
('cityfarma', 7, '7501300408204', 'FC-00408204', 'Plidan Compuesto', 'PLIDAN COMPUESTO C20', 1, 253.08, 317, 'marca', 'Medicamentos', 'Gastro', 'Comprimido', 'Plidan', 'Siegfried Rhein', 'Caja con 20 comprimidos', 'Pargeverina / clonixinato de lisina', '10/125 mg', false, true, null, null),
('cityfarma', 8, '7501349028364', 'EQ-AMS279', 'Popram pantoprazol 40 mg', 'POPRAM 40MG C14 TABS', 2, 27.93, 45, 'generico', 'Medicamentos', 'Gastro', 'Tableta', 'Popram', 'AMSA', 'Caja con 14 tabletas', 'Pantoprazol', '40 mg', true, false, null, null),
('cityfarma', 9, '714908100228', 'EQ-SAN025', 'Revenox melatonina 3 mg', 'REVENDX 3MG C60 TABS', 1, 70.43, 89, 'marca', 'Suplementos', null, 'Tableta', 'Revenox', 'Salud Natural', 'Frasco con 60 tabletas', 'Melatonina', '3 mg', false, false, null, null),
('cityfarma', 10, '7501349029729', 'FC-49029729', 'Telmisartán / hidroclorotiazida 80/12.5 mg', 'TELMISARTAN HIDROCLO', 2, 42.74, 69, 'generico', 'Medicamentos', 'Cardiovascular', 'Tableta', 'AMSA', 'AMSA', 'Caja con 14 tabletas', 'Telmisartán / hidroclorotiazida', '80/12.5 mg', true, true, null, null),
('bodega', 1, '7501026462078', 'FC-26462078', 'Ternura chupón flor-balón con miel', 'TERNURA FLOR-BALON 18 PZS CHUPON CON MIEL', 1, 61.02, 77, 'marca', 'Cuidado personal', 'Infantil', 'Chupón', 'Ternura', 'Ternura', 'Exhibidor 18 piezas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ternura-chupon-flor-balon-miel-18-7501026462078.jpg', null),
('bodega', 2, '7501056342227', 'FC-56342227', 'Sedal Rizos Obedientes', 'CRA SEDAL RIZOS OBEDIENTES 135ML', 2, 17.96, 23, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 135 ml', null, null, false, false, null, null),
('bodega', 3, '7506306251373', 'FC-06251373', 'Sedal Ceramidas', 'SEDAL 135ML CRA P/PEIN CERAMIDAS', 2, 19.68, 25, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 135 ml', null, null, false, true, null, null),
('bodega', 4, '7506306258013', 'FC-06258013', 'Sedal Mega Crecimiento', 'CRA SEDAL P/PEI MEGA CRECIM 300ML', 1, 52.48, 66, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 300 ml', null, null, false, true, null, null),
('bodega', 5, '7506306224780', 'FC-06224780', 'Sedal Prebiótico + Biotina', 'CRA SEDAL P/PEI PREB+BIOTIN 300ML', 1, 50.07, 63, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 300 ml', null, null, false, true, null, null),
('bodega', 6, '7501056340025', 'FC-56340025', 'Sedal SOS Restauración Instantánea', 'CRA SEDAL SOS RECON-ESTRU 300ML', 1, 50.07, 63, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 300 ml', null, null, false, false, null, null),
('bodega', 7, '7506306210905', 'FC-06210905', 'Sedal Micelar Arroz', 'CRA SEDAL P/PEI MICEL -ARROZ 300ML', 1, 50.07, 63, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 300 ml', null, null, false, true, null, null),
('bodega', 8, '7501056340100', 'FC-56340100', 'Sedal Anti-esponjado', 'CRA SEDAL ANTI SPONGE 300 ML', 1, 50.07, 63, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Crema para peinar', 'Sedal', 'Unilever', 'Tubo 300 ml', null, null, false, true, null, null),
('bodega', 9, '7501086494262', 'FC-86494262', 'Oral-B Indicator 35 suave', 'CEP DENT ORAL-B INDICAT35SVE', 2, 31.02, 39, 'marca', 'Cuidado personal', 'Higiene bucal', 'Cepillo dental', 'Oral-B', 'P&G', '1 pieza', null, null, false, false, null, null);

-- Altas (stock 0 hasta pistola)
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
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 07-nov-2026 · ' || t.ticket || ' · listo para pistola',
  t.costo,
  t.precio,
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (ean) *
  from _fc_tk_20261107
  where es_alta
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

-- Costos (no baja PVP bueno)
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 then t.precio
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_tk_20261107
  where costo >= 1
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Ficha / foto si falta (no pisa foto buena)
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
  select distinct on (ean) *
  from _fc_tk_20261107
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- ── Equilibrio · 450987 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '450987',
  '2026-11-07',
  697.11,
  'borrador',
  'Ticket Equilibrio folio 450987 · cliente 307513 Luis Angel · pedido online Iztapalapa 2 · 07-nov-2026 15:01 · 22 pzas · $697.11 · lote de fábrica en renglón; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '450987'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 697.11,
  fecha = '2026-11-07',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 450987 · cliente 307513 Luis Angel · pedido online Iztapalapa 2 · 07-nov-2026 15:01 · 22 pzas · $697.11 · lote de fábrica en renglón; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '450987'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '450987'
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
from _fc_tk_20261107 t
join public.recepciones r
  on r.folio = '450987'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.ticket = 'equilibrio'
order by t.linea;


-- ── Cityfarma Iztapalapa · S338883 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S338883',
  '2026-11-07',
  1884.14,
  'borrador',
  'Ticket Cityfarma S338883 · 07-nov-2026 14:58 · cliente Luis Angel · prioridad ALTA · surtido sin certificar · $1,884.14 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S338883'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1884.14,
  fecha = '2026-11-07',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S338883 · 07-nov-2026 14:58 · cliente Luis Angel · prioridad ALTA · surtido sin certificar · $1,884.14 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S338883'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S338883'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_tk_20261107 t
join public.recepciones r
  on r.folio = 'S338883'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.ticket = 'cityfarma'
order by t.linea;


-- ── Bodega F-42 · 86837 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '86837',
  '2026-11-07',
  451.12,
  'borrador',
  'Ticket Bodega F-42 / Citymark · Caja 2/86837 · Ejidos del Moral · 07-nov-2026 15:22 · 12 pzas · $451.12 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '86837'
    and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = 451.12,
  fecha = '2026-11-07',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 / Citymark · Caja 2/86837 · Ejidos del Moral · 07-nov-2026 15:22 · 12 pzas · $451.12 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '86837'
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '86837'
  and coalesce(r.proveedor, '') ilike '%bodega%'
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
from _fc_tk_20261107 t
join public.recepciones r
  on r.folio = '86837'
 and coalesce(r.proveedor, '') ilike '%bodega%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.ticket = 'bodega'
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
where (r.folio = '450987' and coalesce(r.proveedor, '') ilike '%equilibrio%')
   or (r.folio = 'S338883' and coalesce(r.proveedor, '') ilike '%cityfarma%')
   or (r.folio = '86837' and coalesce(r.proveedor, '') ilike '%bodega%')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;
