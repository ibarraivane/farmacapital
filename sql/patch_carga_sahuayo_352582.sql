-- Sahuayo · ticket 352582 · 08-sep-2026 04:54 · Central de Abastos (locales F26/F28)
-- Impulsora Sahuayo S.A. de C.V. · tarjeta crédito $429.79 · 11 artículos
-- 8 renglones comprados. NO incluir regalos no entregados (BB Tips toallitas).
-- Sin lote/caducidad en el papel → MMAA al escanear. No inventar 0000.
-- EAN/UPC de ficha retail (YZA / Farmapronto / Digit-Eyes), no del ticket.
-- Fotos en public/catalogo-propia/ (E2/E4/E5 Classic reusan packshot E1 de momento).
--
-- IMPORTANTE: dos transacciones. Si el alta falla, el ticket en Recibir
-- igual queda. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Elige UNA vía: este SQL o Importar CSV. No las dos.

-- ═══════════════════════════════════════════════════════════
-- A) Altas / ficha + costos (transacción 1)
-- ═══════════════════════════════════════════════════════════
begin;

create temp table _fc_sah352582 (
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
  marca text,
  presentacion text,
  subcategoria text,
  forma_farmaceutica text,
  imagen_url text,
  receta boolean not null,
  es_alta boolean not null
) on commit drop;

insert into _fc_sah352582 (
  linea, ean, sku, nombre, snap, qty, costo, precio,
  tipo, categoria, marca, presentacion, subcategoria, forma_farmaceutica,
  imagen_url, receta, es_alta
) values
  (1, '013117054149', 'FC-11705414',
   'Chicolastic Classic etapa 4 Grande pañal 14 piezas',
   'PZA.CHICOLASTIC CLASS.GDE 1/14', 1, 53.24, 85,
   'marca', 'Bebés', 'Chicolastic', 'Bolsa con 14 pañales talla Grande (9-12 kg)',
   'Pañales', null,
   'https://www.farmacapital.mx/catalogo-propia/chicolastic-classic-e4-14-013117054149.jpg',
   false, true),
  (2, '013117050103', 'FC-11705010',
   'Affective Predoblado protector unitalla C/10',
   'PZA.AFFECTIVE PREDOBLADO 1/10', 2, 70.57, 113,
   'marca', 'Higiene', 'Affective', 'Bolsa con 10 protectores unitalla 90×60 cm',
   'Incontinencia', null,
   'https://www.farmacapital.mx/catalogo-propia/affective-predoblado-10-013117050103.jpg',
   false, true),
  (3, '013117010879', 'FC-11701087',
   'Chicolastic Classic etapa 2 Chico pañal 14 piezas',
   'PZA.CHICOLASTIC CLAS.CHIC 1/14', 1, 38.92, 62,
   'marca', 'Bebés', 'Chicolastic', 'Bolsa con 14 pañales talla Chico (5-8 kg)',
   'Pañales', null,
   'https://www.farmacapital.mx/catalogo-propia/chicolastic-classic-e2-14-013117010879.jpg',
   false, true),
  (4, '013117012682', 'FC-11701268',
   'Chicolastic Classic etapa 1 Pequeño pañal 14 piezas',
   'PZA.CHICOLAS.CLASSIC R/N 1/14', 1, 35.96, 58,
   'marca', 'Bebés', 'Chicolastic', 'Bolsa con 14 pañales talla Pequeño/RN (3-6 kg)',
   'Pañales', null,
   'https://www.farmacapital.mx/catalogo-propia/chicolastic-classic-e1-14-013117012682.jpg',
   false, true),
  (5, '013117011746', 'FC-11701174',
   'Chicolastic Classic etapa 5 Extra Grande pañal 14 piezas',
   'PZA.CHICOLASTIC CLAS.E/GD 1/14', 1, 61.96, 99,
   'marca', 'Bebés', 'Chicolastic', 'Bolsa con 14 pañales talla Extra Grande (11-14 kg)',
   'Pañales', null,
   'https://www.farmacapital.mx/catalogo-propia/chicolastic-classic-e5-14-013117011746.jpg',
   false, true),
  (6, '013117053142', 'FC-11705314',
   'Chicolastic Classic etapa 3 Mediano pañal 14 piezas',
   'PZA.CHICOLASTIC CLASS.MED 1/14', 1, 34.97, 56,
   'marca', 'Bebés', 'Chicolastic', 'Bolsa con 14 pañales talla Mediano (7-10 kg)',
   'Pañales', null,
   'https://www.farmacapital.mx/catalogo-propia/chicolastic-classic-e3-14-013117053142.jpg',
   false, true),
  (7, '7501943411449', 'FC-43411449',
   'Kotex Maxi Nocturna con alas C/10',
   'PZA.KOTEX MAXI NOC.ALA10s 1/10', 2, 16.00, 26,
   'marca', 'Higiene', 'Kotex', 'Paquete con 10 toallas maxi nocturna con alas',
   'Toallas femeninas', null,
   'https://www.farmacapital.mx/catalogo-propia/kotex-maxi-nocturna-alas-10-7501943411449.jpg',
   false, true),
  (8, '7501943418509', 'FC-43418509',
   'Kotex Nocturna con alas C/8',
   'PZA.KOTEX NOCTU.C/A 8s 1/8 UNI', 2, 15.80, 25,
   'marca', 'Higiene', 'Kotex', 'Paquete con 8 toallas nocturna con alas',
   'Toallas femeninas', null,
   'https://www.farmacapital.mx/catalogo-propia/kotex-nocturna-alas-8-7501943418509.jpg',
   false, true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url
)
select
  t.nombre,
  t.sku,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Sahuayo 352582 · 2026-09-08 · Central de Abastos · listo para pistola',
  t.costo,
  t.precio,
  0,
  2,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.imagen_url
from _fc_sah352582 t
where t.es_alta
  and public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    when coalesce(p.precio, 0) < (t.costo * 1.25) then t.precio
    else p.precio
  end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), t.subcategoria),
  categoria = coalesce(nullif(btrim(p.categoria), ''), t.categoria),
  imagen_url = case
    when nullif(btrim(p.imagen_url), '') is null then t.imagen_url
    else p.imagen_url
  end
from _fc_sah352582 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
   or p.id = public.fc_buscar_producto_escaneo(t.sku);

commit;

-- ═══════════════════════════════════════════════════════════
-- B) Cola Recibir (transacción 2 — independiente del alta)
-- ═══════════════════════════════════════════════════════════
begin;

create temp table _fc_sah352582b (
  linea integer primary key,
  ean text not null,
  sku text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_sah352582b (linea, ean, sku, snap, qty, costo) values
  (1, '013117054149', 'FC-11705414', 'PZA.CHICOLASTIC CLASS.GDE 1/14', 1, 53.24),
  (2, '013117050103', 'FC-11705010', 'PZA.AFFECTIVE PREDOBLADO 1/10', 2, 70.57),
  (3, '013117010879', 'FC-11701087', 'PZA.CHICOLASTIC CLAS.CHIC 1/14', 1, 38.92),
  (4, '013117012682', 'FC-11701268', 'PZA.CHICOLAS.CLASSIC R/N 1/14', 1, 35.96),
  (5, '013117011746', 'FC-11701174', 'PZA.CHICOLASTIC CLAS.E/GD 1/14', 1, 61.96),
  (6, '013117053142', 'FC-11705314', 'PZA.CHICOLASTIC CLASS.MED 1/14', 1, 34.97),
  (7, '7501943411449', 'FC-43411449', 'PZA.KOTEX MAXI NOC.ALA10s 1/10', 2, 16.00),
  (8, '7501943418509', 'FC-43418509', 'PZA.KOTEX NOCTU.C/A 8s 1/8 UNI', 2, 15.80);

update public.recepciones
set estado = 'borrador'
where folio = '352582'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado in ('pendiente_alta', 'pendiente_caducidad');

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Sahuayo',
  '352582',
  '2026-09-08',
  429.79,
  'borrador',
  'Ticket Sahuayo 352582 · 08-09-2026 · Central de Abastos F26/F28 · tarjetacred · cola Recibir; stock al confirmar pistola · MMAA de la caja · sin regalos no entregados'
where not exists (
  select 1 from public.recepciones
  where folio = '352582' and coalesce(proveedor, '') ilike '%sahuayo%'
);

update public.recepciones
set
  total_ticket = 429.79,
  fecha = '2026-09-08',
  proveedor = 'Sahuayo',
  notas = 'Ticket Sahuayo 352582 · 08-09-2026 · Central de Abastos F26/F28 · tarjetacred · cola Recibir; stock al confirmar pistola · MMAA de la caja · sin regalos no entregados',
  updated_at = now()
where folio = '352582'
  and coalesce(proveedor, '') ilike '%sahuayo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '352582'
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
from _fc_sah352582b t
join public.recepciones r
  on r.folio = '352582'
 and coalesce(r.proveedor, '') ilike '%sahuayo%'
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
  r.id as recepcion_id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '352582' and coalesce(r.proveedor, '') ilike '%sahuayo%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 42) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.producto_id,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as match
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '352582' and coalesce(r.proveedor, '') ilike '%sahuayo%'
order by i.id;
