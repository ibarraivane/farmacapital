-- Farmacias Guadalajara · tickets 11-sep-2026 — altas + cola Recibir.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- 2 altas stock 0 (Lenzetto + Wegovy). Tickets borrador separados.
-- Stock al escanear + MMAA de la caja. No inventar 0000.
-- Folio Wegovy = AUT-764870: el NO TICKET no salió en la foto; corregir si aparece.
-- Fotos en catalogo-propia: visibles tras deploy → patch_fotos_guadalajara_20260911.sql
-- Idempotente mientras los tickets sigan en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_gdl20260911 (
  linea integer primary key,
  folio text not null,
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
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  forma_farmaceutica text,
  imagen_url text,
  descripcion text,
  receta boolean not null
) on commit drop;

insert into _fc_gdl20260911 (
  linea, folio, ean, sku, nombre, snap, qty, costo, precio, tipo,
  categoria, subcategoria, marca, laboratorio, presentacion,
  principio_activo, concentracion, forma_farmaceutica, imagen_url,
  descripcion, receta
) values
  (1, '531527', '7506352500128', 'FC-52500128', 'Lenzetto estradiol 1.53 mg/dosis solución aerosol 6.5 ml (56 dosis)', 'LENZETTO 1.53MG/DS 6.5ML 56D SOL', 1, 578.76, 724, 'marca', 'Medicamentos', 'Terapia hormonal', 'Lenzetto', 'Gedeon Richter', 'Caja con frasco 6.5 ml (56 dosis)', 'Estradiol', '1.53 mg/dosis', 'Solución aerosol transdérmica', 'https://www.farmacapital.mx/catalogo-propia/lenzetto-1.53mg-6.5ml.jpg', 'Ticket FG 531527 · LENZETTO 1.53MG/DS 6.5ML 56D SOL · ficha SFE/Herrera EAN 7506352500128', true),
  (2, 'AUT-764870', '7503007822970', 'FC-07822970', 'Wegovy FlexTouch semaglutida 1.7 mg/dosis pluma 3 ml + 4 agujas', 'WEGOVY 1.7MG SOL INY 1 PLUMA/PRE', 1, 4650.00, 5813, 'marca', 'Medicamentos', 'Control de peso', 'Wegovy', 'Novo Nordisk', 'Caja con 1 pluma FlexTouch 3 ml y 4 agujas NovoFine Plus', 'Semaglutida', '1.7 mg/dosis (2.27 mg/mL)', 'Solución inyectable', 'https://www.farmacapital.mx/catalogo-propia/wegovy-flextouch-1.7mg.jpg', 'Ticket FG AUT-764870 · WEGOVY 1.7MG SOL INY 1 PLUMA/PRE · ficha Novo Nordisk/Fahorro EAN 7503007822970 · refrigerar 2–8 °C', true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, principio_activo, concentracion,
  forma_farmaceutica, subcategoria, imagen_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-GDL-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.tipo,
  t.descripcion,
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.principio_activo,
  t.concentracion,
  t.forma_farmaceutica,
  t.subcategoria,
  t.imagen_url
from _fc_gdl20260911 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  nombre = t.nombre,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), t.laboratorio),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), t.concentracion),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), t.forma_farmaceutica),
  categoria = coalesce(nullif(btrim(p.categoria), ''), t.categoria),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), t.subcategoria),
  requiere_receta = t.receta,
  activo = true,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''), t.imagen_url)
from _fc_gdl20260911 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- ── Ticket 531527 ──────────────────────────────────────────
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmacias Guadalajara',
  '531527',
  '2026-09-11',
  578.76,
  'borrador',
  'Ticket FG 531527 · SUC SN Lorenzo Iztapalapa · FOLIO FACTURA 599104-181830-424489 · 2026-09-11 15:50 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '531527'
    and coalesce(proveedor, '') ilike '%guadalajara%'
);

update public.recepciones
set
  total_ticket = 578.76,
  fecha = '2026-09-11',
  proveedor = 'Farmacias Guadalajara',
  notas = 'Ticket FG 531527 · SUC SN Lorenzo Iztapalapa · FOLIO FACTURA 599104-181830-424489 · 2026-09-11 15:50 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '531527'
  and coalesce(proveedor, '') ilike '%guadalajara%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '531527'
  and coalesce(r.proveedor, '') ilike '%guadalajara%'
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
from _fc_gdl20260911 t
join public.recepciones r
  on r.folio = '531527'
 and coalesce(r.proveedor, '') ilike '%guadalajara%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.folio = '531527'
order by t.linea;

-- ── Ticket AUT-764870 ──────────────────────────────────────────
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmacias Guadalajara',
  'AUT-764870',
  '2026-09-11',
  4650.00,
  'borrador',
  'Ticket FG Wegovy · SUC SN Lorenzo Iztapalapa · AUT Bancomer 764870 (NO TICKET no visible en foto) · misma caja 2 / misma tarjeta · cola Recibir; stock al confirmar pistola · cadena de frío 2–8 °C'
where not exists (
  select 1 from public.recepciones
  where folio = 'AUT-764870'
    and coalesce(proveedor, '') ilike '%guadalajara%'
);

update public.recepciones
set
  total_ticket = 4650.00,
  fecha = '2026-09-11',
  proveedor = 'Farmacias Guadalajara',
  notas = 'Ticket FG Wegovy · SUC SN Lorenzo Iztapalapa · AUT Bancomer 764870 (NO TICKET no visible en foto) · misma caja 2 / misma tarjeta · cola Recibir; stock al confirmar pistola · cadena de frío 2–8 °C',
  updated_at = now()
where folio = 'AUT-764870'
  and coalesce(proveedor, '') ilike '%guadalajara%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'AUT-764870'
  and coalesce(r.proveedor, '') ilike '%guadalajara%'
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
from _fc_gdl20260911 t
join public.recepciones r
  on r.folio = 'AUT-764870'
 and coalesce(r.proveedor, '') ilike '%guadalajara%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.folio = 'AUT-764870'
order by t.linea;

commit;

select
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.folio in ('531527', 'AUT-764870')
group by r.id, r.folio, r.estado, r.total_ticket
order by r.folio;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  left(p.nombre, 56) as catalogo,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where coalesce(r.proveedor, '') ilike '%guadalajara%'
  and r.folio in ('531527', 'AUT-764870')
order by r.folio, i.id;
