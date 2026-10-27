-- ============================================================================
-- Tickets 26-oct-2026 → cola Recibir (borrador)
--
-- 1) Farmalive / Club Iztapalapa 1 · 13677 · $2,892.07
-- 2) Cityfarma Iztapalapa · S335144 · $1,101.47
-- 3) Cityfarma Iztapalapa · S335145 · $191.14
-- 4) Cityfarma Iztapalapa · S335151 · $270.97
--
-- Stock 0 hasta pistola + MMAA. No inventar caducidad 0000.
-- Farmalive: costo = P.U. neto con descuento; promos $0.01 consolidadas.
-- SIN do $$. Idempotente mientras cada ticket siga en borrador.
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_tk_20261026 (
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

insert into _fc_tk_20261026 (
  ticket, linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
-- ── Farmalive 13677 (Club Iztapalapa 1 · 26/10/2026 16:27) ──
('farmalive', 1, '3664798059601', 'FC-80596011',
 'Aderogyl', 'ADEROGYL AMP ING C/4 | OPELLA',
 2, 98.00, 123, 'marca', 'Vitaminas', null, 'Ampolleta', 'Aderogyl', 'Opella',
 'Caja con 4 ampolletas', 'Vitamina A / C / D3 / complejo B', null, false, true, null),
('farmalive', 2, '7501165010789', 'FC-15010789',
 'Aderogyl C Infantil', 'ADEROGYL C GOTAS INF 30 ML | OPELLA',
 3, 132.89, 167, 'marca', 'Vitaminas', null, 'Gotas', 'Aderogyl', 'Opella',
 'Frasco 30 mL con gotero', 'Vitamina A / C / D', null, false, true, null),
('farmalive', 3, '7506306249042', 'FC-56323059',
 'Vaseline Original', 'VASELINE ORIGINAL 85GR | UNILEVER',
 2, 53.51, 67, 'marca', 'Cuidado personal', 'Piel', 'Vaselina', 'Vaseline', 'Unilever',
 'Tarro 85 g', null, null, false, true, null),
('farmalive', 4, '7501298219370', 'FC-98219370',
 'Iliadin Lub Infantil', 'ILIADIN LUB SPRAY INF 20 ML | P&G HEALTH',
 1, 136.71, 171, 'marca', 'Medicamentos', 'Respiratorio', 'Spray nasal', 'Iliadin', 'P&G Health',
 'Frasco spray 20 mL', 'Oximetazolina / dexpantenol', '0.025%', false, true, null),
('farmalive', 5, '7501298223773', 'FC-98223773',
 'Iliadin Adulto', 'ILIADIN SPRAY ADTO 20 ML | P&G HEALTH',
 1, 137.13, 172, 'marca', 'Medicamentos', 'Respiratorio', 'Spray nasal', 'Iliadin', 'P&G Health',
 'Frasco spray 20 mL', 'Oximetazolina', '0.05%', false, true, null),
('farmalive', 6, '7501032931865', 'FC-32931865',
 'OFF! Defense', 'REPELENTE OFF DEFENSE AER 170 GR | SC JOHNSON',
 2, 94.02, 118, 'marca', 'Cuidado personal', 'Repelente', 'Aerosol', 'OFF!', 'SC Johnson',
 'Lata 170 g', 'DEET', '25%', false, true, null),
('farmalive', 7, '7501032911454', 'FC-32911454',
 'OFF! Extra Duración', 'REPELENTE OFF EXT DURACION AER 170 GR | SC JOHNSON',
 4, 61.25, 77, 'marca', 'Cuidado personal', 'Repelente', 'Aerosol', 'OFF!', 'SC Johnson',
 'Lata 170 g', 'DEET', '25%', false, true, null),
-- Neo-Melubrina: 1 + 2 renglones → 3 pzas @ $123.68
('farmalive', 8, '7501165000315', 'FC-50003151',
 'Neo-Melubrina jarabe infantil', 'IV NEOMELUBRINA JBE 100 ML | OPELLA',
 3, 123.68, 155, 'marca', 'Medicamentos', null, 'Jarabe', 'Neo-Melubrina', 'Opella',
 'Frasco 100 mL', 'Metamizol sódico', '250 mg/5 mL', false, true,
 'https://www.farmacapital.mx/catalogo-propia/neo-melubrina-jarabe-100ml.jpg'),
('farmalive', 9, '7501032901851', 'FC-32901851',
 'OFF! Family', 'REPELENTE OFF FAMILY SPRAY 177 ML | SC JOHNSON',
 2, 58.59, 74, 'marca', 'Cuidado personal', 'Repelente', 'Spray', 'OFF!', 'SC Johnson',
 'Botella 177 mL', null, null, false, true, null),
('farmalive', 10, '7501080921573', 'FC-80921573',
 'Nair Vello Grueso', 'CRE DEPILADORA NAIR VELLO GRUSO 150 ML | CHURCH & DWIGHTND',
 1, 94.08, 118, 'marca', 'Cuidado personal', 'Depilación', 'Crema', 'Nair', 'Church & Dwight',
 'Tubo 150 mL', null, null, false, true, null),
('farmalive', 11, '7501080921139', 'FC-80921139',
 'Nair Piel Sensible', 'CRE DEPILADORA NAIR P SENSIBLE 150 ML | CHURCH & DWIGHTND',
 1, 94.08, 118, 'marca', 'Cuidado personal', 'Depilación', 'Crema', 'Nair', 'Church & Dwight',
 'Tubo 150 mL', null, null, false, true,
 'https://www.farmacapital.mx/catalogo-propia/nair-piel-sensible-150ml.jpg'),
('farmalive', 12, '7501033953361', 'FC-33953361',
 'Ensure polvo chocolate', 'ENSURE PVO CHOCOLATE 400 GR | ABBOTT',
 1, 293.02, 367, 'marca', 'Suplementos', null, 'Polvo', 'Ensure', 'Abbott',
 'Lata 400 g', null, null, false, true, null),
('farmalive', 13, '7501033953354', 'FC-33953354',
 'Ensure polvo vainilla', 'ENSURE PVO VAINILLA 400 GR | ABBOTT',
 1, 293.02, 367, 'marca', 'Suplementos', null, 'Polvo', 'Ensure', 'Abbott',
 'Lata 400 g', null, null, false, true, null),
-- Advance White: 4 @ $55.27 + 1 promo $0.01 → 5 pzas · costo promedio 44.22
-- Ticket imprime 33200186601; canónico UPC 033200186601
('farmalive', 14, '033200186601', 'FC-32001866',
 'Arm & Hammer Advance White Extreme', 'CRE DENT ADVANCE WHITE BLANC EXTR 121 GR | CHURCH & DWIGHTND',
 5, 44.22, 56, 'marca', 'Cuidado personal', 'Bucal', 'Pasta dental', 'Arm & Hammer', 'Church & Dwight',
 'Tubo 121 g', null, null, false, true, null),
-- Pharmaton promo $0.01 — no pisar costo de catálogo
('farmalive', 15, '3664798062243', 'FC-98062243',
 'Pharmaton Complete', 'PHARMATON COMPLETE TAB C/100 | OPELLA',
 1, 0.01, 459, 'marca', 'Vitaminas', null, 'Tableta', 'Pharmaton', 'Opella',
 'Caja con 100 tabletas', 'Multivitaminas + ginseng G115', null, false, true,
 'https://www.farmacapital.mx/catalogo-propia/pharmaton-complete-100tab.jpg'),

-- ── Cityfarma S335144 ──
('cityfarma144', 1, '354312225010', 'FC-2225010',
 'Derman', 'DERMAN CRA 25 GR',
 3, 26.05, 42, 'generico', 'Medicamentos', 'Dermatológico', 'Crema', 'Derman', 'KSK',
 'Tubo 25 g', 'Ácido undecilénico / undecilenato de zinc', null, false, true, null),
('cityfarma144', 2, '7501871720590', 'FC-71720590',
 'Vartalon Compositum', 'VARTALON COMP C30 SO',
 1, 1023.32, 1280, 'marca', 'Medicamentos', null, 'Polvo', 'Vartalon', 'Asofarma',
 'Caja con 30 sobres', 'Glucosamina / condroitina', '1500/1200 mg', true, true, null),

-- ── Cityfarma S335145 ──
('cityfarma145', 1, '7506295337454', 'FC-95337454',
 'Clearblue Digital', 'PBA EMB CLEAR BLUE D',
 1, 191.14, 239, 'marca', 'Dispositivos', 'Prueba de embarazo', 'Dispositivo', 'Clearblue', 'P&G',
 'Caja con 1 prueba', null, null, false, true,
 'https://www.farmacapital.mx/catalogo-propia/clearblue-digital-semanas-7506295337454.jpg'),

-- ── Cityfarma S335151 ──
('cityfarma151', 1, '7501088504150', 'FC-88504150',
 'Ferranina', 'FERRANINA GOTAS PED',
 1, 270.97, 339, 'marca', 'Medicamentos', null, 'Gotas', 'Ferranina', 'Takeda',
 'Frasco gotero 20 mL', 'Complejo polimaltosado férrico', '50 mg/mL', true, true, null);

-- ═══════════════════════════════════════════════════════════
-- Altas (solo es_alta y aún no existen)
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
  'Alta ticket 26-oct-2026 · ' || t.ticket || ' · listo para pistola',
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
  from _fc_tk_20261026
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
  from _fc_tk_20261026
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_tk_20261026
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

-- ═══════════════════════════════════════════════════════════
-- Recepciones
-- ═══════════════════════════════════════════════════════════

-- ── Farmalive 13677 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '13677',
  '2026-10-26',
  2892.07,
  'borrador',
  'Ticket Farmalive 13677 · Club Iztapalapa 1 · 26-oct-2026 16:27 · $2,892.07 · Neo-Melubrina ×3 y Advance White ×5 consolidados · Pharmaton promo $0.01 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '13677'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 2892.07,
  fecha = '2026-10-26',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 13677 · Club Iztapalapa 1 · 26-oct-2026 16:27 · $2,892.07 · Neo-Melubrina ×3 y Advance White ×5 consolidados · Pharmaton promo $0.01 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '13677'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '13677'
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
from _fc_tk_20261026 t
join public.recepciones r
  on r.folio = '13677'
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


-- ── Cityfarma S335144 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S335144',
  '2026-10-26',
  1101.47,
  'borrador',
  'Ticket Cityfarma S335144 · 26-oct-2026 16:44 · Derman ×3 + Vartalon Compositum · $1,101.47 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S335144'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1101.47,
  fecha = '2026-10-26',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S335144 · 26-oct-2026 16:44 · Derman ×3 + Vartalon Compositum · $1,101.47 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S335144'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S335144'
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
from _fc_tk_20261026 t
join public.recepciones r
  on r.folio = 'S335144'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'cityfarma144'
order by t.linea;


-- ── Cityfarma S335145 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S335145',
  '2026-10-26',
  191.14,
  'borrador',
  'Ticket Cityfarma S335145 · 26-oct-2026 16:47 · Clearblue Digital · tarjeta $191.14 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S335145'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 191.14,
  fecha = '2026-10-26',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S335145 · 26-oct-2026 16:47 · Clearblue Digital · tarjeta $191.14 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S335145'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S335145'
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
from _fc_tk_20261026 t
join public.recepciones r
  on r.folio = 'S335145'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'cityfarma145'
order by t.linea;


-- ── Cityfarma S335151 ──
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S335151',
  '2026-10-26',
  270.97,
  'borrador',
  'Ticket Cityfarma S335151 · 26-oct-2026 17:00 · Ferranina gotas · $270.97 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S335151'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 270.97,
  fecha = '2026-10-26',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Ticket Cityfarma S335151 · 26-oct-2026 17:00 · Ferranina gotas · $270.97 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'S335151'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S335151'
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
from _fc_tk_20261026 t
join public.recepciones r
  on r.folio = 'S335151'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
where t.ticket = 'cityfarma151'
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
where r.folio in ('13677', 'S335144', 'S335145', 'S335151')
  and (
    coalesce(r.proveedor, '') ilike '%farmalive%'
    or coalesce(r.proveedor, '') ilike '%cityfarma%'
  )
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.folio;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.pendiente_alta,
  i.producto_id
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio in ('13677', 'S335144', 'S335145', 'S335151')
  and r.estado = 'borrador'
order by r.folio, i.id;
