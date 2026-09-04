-- Factura Nadro folio 6089573392 (2026-09-01) — altas + cola Recibir.
-- Es la misma compra que se armó antes como folio placeholder 20260901.
-- Foto en mostrador: Folio 6089573392 · NADRO MEXICO SUR · $848.05 · 13 renglones.
--
-- Nombres/marca/foto desde iNadro (ficha), NO el código del ticket (BLOQ ANTHE…).
-- FRABEL 2 / LGEN / UNILEVER mayorista no van como marca de mostrador.
-- SIN bloques dollar-quote. El SQL Editor de Supabase los corta.
-- Stock 0 hasta pistola + MMAA de la caja. No inventar 0000.
-- Idempotente: renombra 20260901 → 6089573392 si sigue en borrador;
--   si el pedido ya cerró, no lo reabre (solo enriquece fichas de catálogo).
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

-- ── 0) Unificar folio placeholder → folio real de la factura ─────
update public.recepciones
set
  folio = '6089573392',
  notas = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(notas, '')), ''),
    'Factura Nadro 6089573392 (antes folio trabajo 20260901)'
  )),
  updated_at = now()
where folio = '20260901'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado in ('borrador', 'pendiente_alta', 'parcial');

update public.recepciones
set
  folio = '6089573392-UVAIR',
  notas = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(notas, '')), ''),
    'Faltante factura Nadro 6089573392 · Anthelios UV Air'
  )),
  updated_at = now()
where folio = '20260901-UVAIR'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado in ('borrador', 'pendiente_alta', 'parcial');

create temp table _fc_nd6089573392 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  marca text,
  presentacion text,
  categoria text not null,
  subcategoria text,
  forma text,
  imagen_url text,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  receta boolean not null
) on commit drop;

insert into _fc_nd6089573392 (
  linea, ean, sku, nombre, snap, marca, presentacion,
  categoria, subcategoria, forma, imagen_url,
  qty, costo, precio, tipo, receta
) values
  (1, '7503014279552', 'FC-14279552',
   'Parches Alfa Medical adhesivos 2 tamaños blanco',
   'PARCHES ALFA MED ADH 2TAM BCO C',
   'Alfa Med', '10 piezas', 'Botiquín', null, null,
   'https://nadro.vtexassets.com/arquivos/ids/168452/7503014279552_01.jpg',
   1, 53.15, 71, 'marca', false),
  (2, '7506494600038', 'FC-94600038',
   'Rumoquin NF 30 tabletas',
   'RUMOQUIN N.F. 30 TAB LGEN',
   'Rumoquin', '30 tabletas', 'Medicamentos', null, 'Tableta',
   'https://nadro.vtexassets.com/arquivos/ids/204648/7506494600038_01.jpg',
   1, 46.94, 118, 'generico', false),
  (3, '7506309873701', 'FC-09873701',
   'Pantene Rizos Definidos 2 en 1 shampoo acondicionador 100 ml',
   'SH ACOND PANT RIZOS DEF2EN1 100ML',
   'Pantene', '100 ml', 'Cuidado personal', null, null,
   'https://nadro.vtexassets.com/arquivos/ids/215526/7506309873701_01.jpg',
   2, 17.56, 24, 'marca', false),
  (4, '7506306256026', 'FC-06256026',
   'Dove Derma Care Hydra Alivio acondicionador 400 ml',
   'ACOND DOVE DERMA CARE H-ALIV400MLN',
   'Dove', '400 ml', 'Cuidado personal', null, null,
   'https://nadro.vtexassets.com/arquivos/ids/218168/7506306256026_01.jpg',
   1, 56.91, 76, 'marca', false),
  (5, '7506306223134', 'FC-06223134',
   'Sedal Liso Perfecto acondicionador 300 ml',
   'ACOND SEDAL LISO PERFECTO 300 ML',
   'Sedal', '300 ml', 'Cuidado personal', null, null,
   'https://nadro.vtexassets.com/arquivos/ids/185522/7506306223134_01.jpg',
   1, 38.48, 52, 'marca', false),
  (6, '7501022150818', 'FC-22150818',
   'Jabón Grisi Concha Nácar 125 g',
   'JBN GRISI CONCHA NACAR 125G',
   'Grisi', '125 g', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/201799/7501022150818_01.jpg',
   1, 22.92, 31, 'marca', false),
  (7, '7501056371159', 'FC-56371159',
   'Jabón Dove Exfoliación diaria 135 g',
   'JBN DOVE EXFOLIAC DIARIA135G',
   'Dove', '135 g', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/208758/7501056371159_01.jpg',
   1, 28.00, 38, 'marca', false),
  (8, '7501943489165', 'FC-43489165',
   'Jabón líquido Escudo blanco neutro 225 ml',
   'JBN LIQ ESCUDO BLANCO NEUT 225ML',
   'Escudo', '225 ml', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/156844/7501943489165_01.jpg',
   1, 28.27, 38, 'marca', false),
  (9, '7501022150092', 'FC-22150092',
   'Jabón Grisi Leche de Burra 125 g',
   'JBN GRISI LECHE DE BURRA 125G',
   'Grisi', '125 g', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/178510/7501022150092_01.jpg',
   1, 22.96, 31, 'marca', false),
  (10, '037836051227', 'FC-36051227',
   'Jabón líquido Grisi Concha Nácar 450 ml',
   'JBN LIQ GRISI CONCHA NACAR 450ML',
   'Grisi', '450 ml', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/203724/37836051227_01.jpg',
   1, 55.31, 74, 'marca', false),
  (11, '7501022105191', 'FC-22105191',
   'Jabón Grisi Neutro 100 g',
   'JBN GRISI NEUTRO 100G',
   'Grisi', '100 g', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/178500/7501022105191_01.jpg',
   2, 16.24, 22, 'marca', false),
  (12, '037836050282', 'FC-36050282',
   'Jabón líquido Grisi Neutro 450 ml',
   'JBN LIQ GRISI NEUTRO 450ML',
   'Grisi', '450 ml', 'Cuidado personal', null, 'Jabón',
   'https://nadro.vtexassets.com/arquivos/ids/201572/37836050282_01.jpg',
   1, 55.31, 74, 'marca', false),
  (13, '3337875917810', 'FC-75917810',
   'La Roche-Posay Anthelios UV Air FPS 50+ Protector Solar Ligero 40 ml',
   'BLOQ ANTHE UVAIR 50+ FLU INV 40ML',
   'La Roche-Posay', '40 ml', 'Cuidado personal', 'Protector solar', 'Fluido',
   'https://nadro.vtexassets.com/arquivos/ids/218211/3337875917810_01.jpg',
   1, 372.20, 497, 'marca', false);

-- ── 1) Catálogo: altas faltantes ─────────────────────────────────
insert into public.productos (
  nombre, sku, codigo_barras, marca, presentacion,
  categoria, subcategoria, forma_farmaceutica, imagen_url,
  tipo, descripcion, costo, precio, stock, stock_minimo, activo, requiere_receta
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
  t.marca,
  t.presentacion,
  t.categoria,
  t.subcategoria,
  t.forma,
  t.imagen_url,
  t.tipo,
  'Factura Nadro 6089573392 · 2026-09-01 · ficha iNadro · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta
from _fc_nd6089573392 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- ── 2) Enriquecer fichas ya existentes (nombre real, no BLOQ ANTHE…) ─
update public.productos p
set
  nombre = t.nombre,
  marca = coalesce(nullif(t.marca, ''), p.marca),
  presentacion = coalesce(nullif(t.presentacion, ''), p.presentacion),
  categoria = coalesce(nullif(t.categoria, ''), p.categoria),
  subcategoria = coalesce(t.subcategoria, p.subcategoria),
  forma_farmaceutica = coalesce(t.forma, p.forma_farmaceutica),
  imagen_url = coalesce(nullif(p.imagen_url, ''), t.imagen_url),
  costo = t.costo,
  activo = true,
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from _fc_nd6089573392 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
       p.nombre is distinct from t.nombre
    or coalesce(p.marca, '') is distinct from coalesce(t.marca, '')
    or coalesce(p.imagen_url, '') = ''
    or p.costo is distinct from t.costo
    or coalesce(p.activo, false) = false
  );

-- PVP solo si está vacío / 1 (no pisa precios ya fijados en mostrador)
update public.productos p
set precio = t.precio
from _fc_nd6089573392 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and coalesce(p.precio, 0) <= 1;

-- ── 3) Cola Recibir con folio real ───────────────────────────────
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Nadro',
  '6089573392',
  '2026-09-01',
  848.05,
  'borrador',
  'Factura Nadro 6089573392 · 01-sep-2026 · PDF/foto · EAN iNadro · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio in ('6089573392', '20260901')
    and coalesce(proveedor, '') ilike '%nadro%'
);

update public.recepciones
set
  folio = '6089573392',
  total_ticket = 848.05,
  fecha = '2026-09-01',
  proveedor = 'Nadro',
  notas = 'Factura Nadro 6089573392 · 01-sep-2026 · PDF/foto · EAN iNadro · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio in ('6089573392', '20260901')
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado = 'borrador';

-- Solo regenera renglones si el ticket sigue en borrador (no toca pistola hecha)
delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '6089573392'
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
from _fc_nd6089573392 t
join public.recepciones r
  on r.folio = '6089573392'
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

-- Diagnóstico
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where i.confirmado) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%nadro%'
  and r.folio in ('6089573392', '6089573392-UVAIR', '20260901', '20260901-UVAIR')
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 56) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.confirmado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '6089573392'
  and coalesce(r.proveedor, '') ilike '%nadro%'
order by i.id;

select
  p.codigo_barras as ean,
  p.sku,
  left(p.nombre, 56) as nombre,
  p.marca,
  p.presentacion,
  p.precio,
  p.stock
from public.productos p
where p.codigo_barras in (
  '7503014279552','7506494600038','7506309873701','7506306256026','7506306223134',
  '7501022150818','7501056371159','7501943489165','7501022150092','037836051227',
  '7501022105191','037836050282','3337875917810'
)
order by p.codigo_barras;
