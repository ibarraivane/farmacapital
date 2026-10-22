-- ============================================================================
-- Cuatro tickets 21-oct-2026 → cola Recibir (borrador)
--
-- 1) Sahuayo 310545 · Central Abastos · $1,160.20 · 7 pzas (pañales)
-- 2) Farmalive / Club Iztapalapa 1 · 14979 · $1,928.16
-- 3) IFC F8 Tienda · 129846 · $255.00 · sin EAN GS1
-- 4) Equilibrio · folio 211026 (foto sin encabezado; cliente 307513) · $781.65
--
-- Stock 0 hasta pistola + MMAA. No inventar caducidad 0000.
-- Equilibrio: lote de fábrica sí; caducidad null (MMAA de la caja).
-- SIN do $$. Idempotente mientras cada ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- ═══════════════════════════════════════════════════════════
-- Temp: todas las líneas de los 4 tickets
-- ═══════════════════════════════════════════════════════════
create temp table _fc_tk_20261021 (
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
  lote text,
  primary key (ticket, linea)
) on commit drop;

insert into _fc_tk_20261021 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, lote
) values
-- ── Sahuayo 310545 ─────────────────────────────────────────
('sahuayo', 1, '7501019051159', 'FC-19051159',
 'Tena Pants Maxi Protect CH/M', 'PZA.TENA P.MAXI CH/M 13S 1/13',
 2, 151.57, 190, 'marca', 'Higiene', 'Incontinencia', null, 'Tena', 'Essity',
 'Bolsa con 13 piezas talla CH/M', null, null, false, true, null),
('sahuayo', 2, '013117050103', 'FC-11705010',
 'Affective Predoblado protector unitalla C/10', 'PZA.AFFECTIVE PREDOBLADO 1/10',
 2, 70.57, 89, 'marca', 'Higiene', 'Incontinencia', null, 'Affective', 'PI Mabe',
 'Bolsa con 10 protectores unitalla', null, null, false, false, null),
('sahuayo', 3, '7501019051166', 'FC-19051166',
 'Tena Pants Maxi Protect Grande', 'PZA.TENA P.MAXI GDE.13s 1/13 U',
 1, 151.57, 190, 'marca', 'Higiene', 'Incontinencia', null, 'Tena', 'Essity',
 'Bolsa con 13 piezas talla Grande', null, null, false, true, null),
('sahuayo', 4, '7501943441804', 'FC-43441804',
 'Huggies Supreme etapa 5 Niño', 'PZA.HUGGIE SU E5 NIÑO5X36 1/36',
 1, 314.37, 393, 'marca', 'Bebés', 'Pañales', null, 'Huggies', 'Kimberly-Clark',
 'Bolsa con 36 pañales etapa 5', null, null, false, true, null),
('sahuayo', 5, '7501943441767', 'FC-43441767',
 'Huggies Supreme etapa 4 Niño', 'PZA.HUGGIE SU E4 NIÑO5X36 1/36',
 1, 249.98, 313, 'marca', 'Bebés', 'Pañales', null, 'Huggies', 'Kimberly-Clark',
 'Bolsa con 36 pañales etapa 4', null, null, false, true, null),

-- ── Farmalive 14979 (costo = P.U. neto con descuento; promos consolidadas) ──
('farmalive', 1, '7501019006104', null,
 'Saba Íntima Regular sin alas C/10', 'TOA SANIT SABA INTIMA REG S/ALAS C/10 | SCA',
 2, 13.59, 18, 'marca', 'Higiene', 'Toallas femeninas', null, 'Saba', 'SCA',
 'Paquete con 10 toallas', null, null, false, true, null),
('farmalive', 2, '7501573908104', 'EQ-BIO167',
 'Bixen naproxeno 550 mg', 'BIXEN 550 MG TAB C/12 | BIOMEP',
 5, 21.20, 34, 'generico', 'Medicamentos', null, 'Tableta', 'Bixen', 'Biomep',
 'Caja con 12 tabletas', 'Naproxeno', '550 mg', true, false, null),
('farmalive', 3, '7501007459332', 'FC-07459332',
 'Vick VapoRub inhalador', 'VICK VAPORUB INHALADOR C/ 1 | PG OTC',
 3, 84.28, 106, 'marca', 'Medicamentos', 'Respiratorio', 'Inhalador', 'Vick', 'P&G',
 '1 inhalador', 'Alcanfor / mentol', null, false, true, null),
('farmalive', 4, '7501298217659', 'FC-98217659',
 'Dolo-Neurobion DC jeringa precargada', 'IV DOLO-NEUROBION DC JGA PRELL C/3 3 ML | P&G HEALTH',
 1, 434.30, null, 'marca', 'Medicamentos', null, 'Solución inyectable', 'Dolo-Neurobion', 'P&G Health',
 'Caja con 3 jeringas 3 mL', null, null, true, false, null),
('farmalive', 5, '7501033956126', 'FC-33956126',
 'Glucerna líquido vainilla 237 mL', 'GLUCERNA LIQ VAINILLA 237 ML | ABBOTT',
 2, 49.66, null, 'marca', 'Suplementos', null, 'Líquido', 'Glucerna', 'Abbott',
 'Brick 237 mL', null, null, false, false, null),
('farmalive', 6, '7501033956140', 'FC-33956140',
 'Glucerna líquido fresa 237 mL', 'GLUCERNA LIQ FRESA 237 ML | ABBOTT',
 2, 49.66, null, 'marca', 'Suplementos', null, 'Líquido', 'Glucerna', 'Abbott',
 'Brick 237 mL', null, null, false, false, null),
('farmalive', 7, '7501033954085', 'FC-33950070',
 'Ensure líquido vainilla 237 mL', 'ENSURE LIQ VAINILLA 237 ML | ABBOTT',
 2, 42.63, null, 'marca', 'Suplementos', null, 'Líquido', 'Ensure', 'Abbott',
 'Brick 237 mL', null, null, false, false, null),
('farmalive', 8, '7501033956133', 'FC-33956133',
 'Glucerna líquido chocolate 237 mL', 'GLUCERNA LIQ CHOCOLATE 237 ML | ABBOTT',
 3, 49.66, null, 'marca', 'Suplementos', null, 'Líquido', 'Glucerna', 'Abbott',
 'Brick 237 mL', null, null, false, false, null),
('farmalive', 9, '650240052545', 'FC-00525451',
 'XL-3 tabletas C/10', 'XL-3 TAB C/10 | GENOMMA LAB',
 5, 28.42, null, 'generico', 'Medicamentos', null, 'Tableta', 'XL-3', 'Genomma',
 'Caja con 10 tabletas', null, null, false, false, null),
-- XL-3 VR: 4×$88.20 + 1×$0.01 → 5 pzas · costo promedio 70.56
('farmalive', 10, '650240017100', 'FC-40017100',
 'XL-3 VR tabletas C/24', 'XL-3 VR TAB C/24 | GENOMMA LAB',
 5, 70.56, null, 'marca', 'Medicamentos', null, 'Tableta', 'XL-3', 'Genomma',
 'Caja con 24 tabletas', null, null, false, false, null),
-- Alli-Triple promo 2×$0.01
('farmalive', 11, '650240053634', 'FC-40053634',
 'Alli-Triple tabletas C/6', 'ALLI-TRIPLE TAB C/6 | GENOMMA LAB',
 2, 0.01, null, 'marca', 'Medicamentos', null, 'Tableta', 'Alli-Triple', 'Genomma',
 'Caja con 6 tabletas', 'Naproxeno', null, false, false, null),
-- XL-3 Xtra: 5×$36.00 + 1×$0.01 → 6 pzas · costo promedio 30.00
('farmalive', 12, '650240017094', 'FC-00170941',
 'XL-3 Xtra tabletas C/12', 'XL-3 XTRA TAB C/12 | GENOMMA LAB',
 6, 30.00, null, 'generico', 'Medicamentos', null, 'Tableta', 'XL-3', 'Genomma',
 'Caja con 12 tabletas', null, null, false, false, null),

-- ── IFC F8 129846 ──────────────────────────────────────────
('ifc', 1, null, 'FC-IFC-81676',
 'Broche para venda económico Saniclip C/12', 'BROCHE VENDA ECONOMICO C/12 SANICLIP',
 5, 12.00, 16, 'marca', 'Material de curación', null, null, 'Saniclip', 'IFC',
 'Paquete con 12 broches', null, null, false, true, null),
('ifc', 2, null, 'FC-IFC-82912A',
 'Venda Stick cohesiva 3 pulg × 4.5 m azul', 'VENDA STICK 3P X 4.5 MTS AZUL 7CM',
 3, 45.00, null, 'marca', 'Material de curación', null, null, 'Venda Stick', 'IFC',
 'Rollo 3 pulg × 4.5 m azul', null, null, false, false, null),
('ifc', 3, null, 'FC-IFC-KINESIO',
 'Cinta kinesiológica 5 cm × 5 m', 'CINTA DE KINESIOLOGICA 5CMX5M P/DEPORTE',
 2, 30.00, 40, 'marca', 'Material de curación', null, null, null, 'IFC',
 'Rollo 5 cm × 5 m', null, null, false, true, null),

-- ── Equilibrio 211026 (cliente 307513) ─────────────────────
('equilibrio', 1, '7502227870532', 'EQ-RAM038',
 'Voydol ketorolaco 10 mg', 'RAM038 VOYDOL 10 TAB 10 MG',
 5, 6.24, 10, 'generico', 'Medicamentos', null, 'Tableta', 'Voydol', 'RAAM',
 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, true, 'RVD226'),
('equilibrio', 2, '7502009740244', 'EQ-MAV043',
 'Lorotec ketorolaco 10 mg', 'MAV043 LOROTEC 10 TAB 10 MG',
 10, 5.95, 10, 'generico', 'Medicamentos', null, 'Tableta', 'Lorotec', 'Maver',
 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, false, '261231'),
('equilibrio', 3, '7502009746154', 'EQ-MAV289',
 'Lorotec F ketorolaco 30 mg sublingual', 'MAV289 LOROTEC F 6 TAB 30 MG',
 6, 10.08, 17, 'generico', 'Medicamentos', null, 'Tableta', 'Lorotec F', 'Maver',
 'Caja con 6 tabletas sublinguales', 'Ketorolaco', '30 mg', true, true, '262603'),
('equilibrio', 4, '7502208891549', 'FC-88915491',
 'Tarmin clonazepam 2 mg', 'BRL043 TARMIN 12 TAB 2 MG',
 15, 5.89, 10, 'generico', 'Medicamentos', null, 'Tableta', 'Tarmin', 'Bruluagsa',
 'Caja con 12 tabletas', 'Clonazepam', '2 mg', true, false, '6081227'),
('equilibrio', 5, '7503002047811', 'EQ-GEP039',
 'Geldako ketorolaco 10 mg', 'GEP039 GELDAKO 10 CAPS 10 MG',
 6, 21.53, 35, 'generico', 'Medicamentos', null, 'Cápsula', 'Geldako', 'Gelpharma',
 'Caja con 10 cápsulas', 'Ketorolaco', '10 mg', true, true, '261317'),
('equilibrio', 6, '7503001007106', 'EQ-WAN001',
 'Amifarin dicloxacilina 500 mg C/12', 'WAN001 AMIFARIN 12 CAPS 500 MG',
 3, 33.02, 53, 'generico', 'Medicamentos', null, 'Cápsula', 'Amifarin', 'Wandel',
 'Caja con 12 cápsulas', 'Dicloxacilina', '500 mg', true, true, 'C6201'),
('equilibrio', 7, '7501075713718', 'FC-AEA8C8DA',
 'Namifen ácido mefenámico 500 mg', 'NOV013 NAMIFEN 20 TAB 500 MG',
 3, 24.28, 39, 'generico', 'Medicamentos', null, 'Tableta', 'Namifen', 'Novag',
 'Caja con 20 tabletas', 'Ácido mefenámico', '500 mg', true, false, '440096'),
('equilibrio', 8, '7501349021532', 'FC-E9C38DC4',
 'Ciprofloxacino G.I. 500 mg', 'AMS184 CIPROFLOXACINO G.I. 14 TAB 500 MG',
 3, 19.54, 32, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA',
 'Caja con 14 tabletas', 'Ciprofloxacino', '500 mg', true, false, 'U26E151'),
('equilibrio', 9, '7501573900443', 'EQ-BIO037',
 'Quitadol paracetamol 500 mg', 'BIO037 QUITADOL 10 TAB 500 MG',
 10, 4.76, 8, 'generico', 'Medicamentos', null, 'Tableta', 'Quitadol', 'Biomep',
 'Caja con 10 tabletas', 'Paracetamol', '500 mg', false, true, 'SI2609'),
('equilibrio', 10, '7503001007113', 'FC-D5AC44CA',
 'Amifarin dicloxacilina 500 mg C/20', 'WAN024 AMIFARIN 20 CAPS 500 MG',
 3, 44.94, 72, 'generico', 'Medicamentos', null, 'Cápsula', 'Amifarin', 'Wandel',
 'Caja con 20 cápsulas', 'Dicloxacilina', '500 mg', true, false, 'C6227');

-- ═══════════════════════════════════════════════════════════
-- Altas (solo es_alta y aún no existen)
-- ═══════════════════════════════════════════════════════════
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio
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
  'Alta ticket 21-oct-2026 · ' || t.ticket || ' · listo para pistola',
  t.costo,
  coalesce(t.precio, ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_20261021
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

-- Costos de ticket en fichas ya existentes (no baja PVP bueno).
-- Ignora renglones promo @$0.01 para no pisar el costo real del catálogo.
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
  from _fc_tk_20261021
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- ═══════════════════════════════════════════════════════════
-- Helper: crear / refrescar una recepción
-- ═══════════════════════════════════════════════════════════

-- ── Sahuayo 310545 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Sahuayo',
  '310545',
  '2026-10-21',
  1160.2,
  'borrador',
  'Ticket Sahuayo 310545 · 21-oct-2026 04:36 · Central Abastos F26/F28 · tarjeta · 7 pzas · $1,160.20 · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '310545'
    and coalesce(proveedor, '') ilike '%sahuayo%'
);

update public.recepciones
set
  total_ticket = 1160.2,
  fecha = '2026-10-21',
  proveedor = 'Sahuayo',
  notas = 'Ticket Sahuayo 310545 · 21-oct-2026 04:36 · Central Abastos F26/F28 · tarjeta · 7 pzas · $1,160.20 · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '310545'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '310545'
  and coalesce(r.proveedor, '') ilike '%sahuayo%'
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
from _fc_tk_20261021 t
join public.recepciones r
  on r.folio = '310545'
 and coalesce(r.proveedor, '') ilike '%sahuayo%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'sahuayo'
order by t.linea;


-- ── Farmalive 14979 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '14979',
  '2026-10-21',
  1928.16,
  'borrador',
  'Ticket Farmalive 14979 · Club Iztapalapa 1 · 21-oct-2026 16:50 · $1,928.16 · XL-3 VR/Xtra y Alli con promo $0.01 consolidados · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '14979'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 1928.16,
  fecha = '2026-10-21',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 14979 · Club Iztapalapa 1 · 21-oct-2026 16:50 · $1,928.16 · XL-3 VR/Xtra y Alli con promo $0.01 consolidados · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '14979'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14979'
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
  nullif(btrim(t.ean), ''),
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
from _fc_tk_20261021 t
join public.recepciones r
  on r.folio = '14979'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'farmalive'
order by t.linea;


-- ── IFC F8 Tienda 129846 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '129846',
  '2026-10-21',
  255.0,
  'borrador',
  'IFC F8 Tienda · folio 129846 · MAYOREO · 21-oct-2026 16:26 · $255 · sin EAN GS1 (códigos IFC) · cola Recibir; ligar EAN de caja al escanear'
where not exists (
  select 1 from public.recepciones
  where folio = '129846'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 255.0,
  fecha = '2026-10-21',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 Tienda · folio 129846 · MAYOREO · 21-oct-2026 16:26 · $255 · sin EAN GS1 (códigos IFC) · cola Recibir; ligar EAN de caja al escanear',
  updated_at = now()
where folio = '129846'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '129846'
  and coalesce(r.proveedor, '') ilike '%ifc%'
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
from _fc_tk_20261021 t
join public.recepciones r
  on r.folio = '129846'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'ifc'
order by t.linea;


-- ── Equilibrio 211026 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '211026',
  '2026-10-21',
  781.65,
  'borrador',
  'Ticket Equilibrio folio 211026 (foto sin encabezado; cliente 307513 Luis Angel) · 21-oct-2026 · 64 pzas · $781.65 · lote de fábrica en renglón; MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '211026'
    and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 781.65,
  fecha = '2026-10-21',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio folio 211026 (foto sin encabezado; cliente 307513 Luis Angel) · 21-oct-2026 · 64 pzas · $781.65 · lote de fábrica en renglón; MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = '211026'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '211026'
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
  nullif(btrim(t.ean), ''),
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
from _fc_tk_20261021 t
join public.recepciones r
  on r.folio = '211026'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'equilibrio'
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
where (r.folio, lower(coalesce(r.proveedor,''))) in (
  ('310545', 'sahuayo'),
  ('14979', 'farmalive'),
  ('129846', 'ifc f8 tienda'),
  ('211026', 'equilibrio')
)
or (
  r.folio in ('310545','14979','129846','211026')
  and (
    coalesce(r.proveedor,'') ilike '%sahuayo%'
    or coalesce(r.proveedor,'') ilike '%farmalive%'
    or coalesce(r.proveedor,'') ilike '%ifc%'
    or coalesce(r.proveedor,'') ilike '%equilibrio%'
  )
)
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  i.pendiente_alta,
  i.producto_id
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio in ('310545','14979','129846','211026')
  and r.estado = 'borrador'
order by r.folio, i.id;
