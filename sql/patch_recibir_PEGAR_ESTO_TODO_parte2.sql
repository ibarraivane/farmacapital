-- PARTE 2 de 2 — pegar despues de la Parte 1

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
