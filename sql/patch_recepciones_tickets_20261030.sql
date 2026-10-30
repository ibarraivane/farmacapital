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
-- SIN do $$. Idempotente mientras cada ticket siga en borrador.
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
