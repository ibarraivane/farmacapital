-- Super Acertijo · remisión 000140 · pedido 614698 · 08-sep-2026 16:19
-- Bodega F38 · Pasillo F · Central de Abastos · PAGADO / ENTREGADO · tarjeta $214.00
-- 4 kits Koleston individuales (C/12 = línea de mayoreo; qty 1.00 PZA = 1 kit, no caja).
-- Sin lote/caducidad en el papel → MMAA al escanear. No inventar 0000.
-- EAN de ficha DAX/Soriana (361422510…), no el código interno 001123/001120/…
--
-- IMPORTANTE: dos transacciones. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Elige UNA vía: este SQL o Importar CSV. No las dos.

-- ═══════════════════════════════════════════════════════════
-- A) Altas / ficha + costos (transacción 1)
-- ═══════════════════════════════════════════════════════════
begin;

create temp table _fc_sa000140 (
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
  imagen_url text,
  receta boolean not null,
  es_alta boolean not null
) on commit drop;

insert into _fc_sa000140 (
  linea, ean, sku, nombre, snap, qty, costo, precio,
  tipo, categoria, marca, presentacion, subcategoria,
  imagen_url, receta, es_alta
) values
  (1, '3614225108853', 'FC-25108853',
   'Koleston tinte permanente 67 Chocolate',
   'KOLESTON TINTE # 67 C/12', 1, 53.50, 86,
   'marca', 'Cuidado personal', 'Koleston', 'Kit coloración 1 aplicación',
   'Tintes',
   'https://www.farmacapital.mx/catalogo-propia/koleston-67-chocolate-3614225108853.jpg',
   false, true),
  (2, '3614225109003', 'FC-25109003',
   'Koleston tinte permanente 64 Caoba Cobrizo',
   'KOLESTON TINTE # 64 C/12', 1, 53.50, 86,
   'marca', 'Cuidado personal', 'Koleston', 'Kit coloración 1 aplicación',
   'Tintes',
   'https://www.farmacapital.mx/catalogo-propia/koleston-64-caoba-cobrizo-3614225109003.jpg',
   false, true),
  (3, '3614225108860', 'FC-25108860',
   'Koleston tinte permanente 674 Tabaco Cobrizo',
   'KOLESTON TINTE # 674 C/12', 1, 53.50, 86,
   'marca', 'Cuidado personal', 'Koleston', 'Kit coloración 1 aplicación',
   'Tintes',
   'https://www.farmacapital.mx/catalogo-propia/koleston-674-tabaco-cobrizo-3614225108860.jpg',
   false, true),
  (4, '3614225108914', 'FC-25108914',
   'Koleston tinte permanente 77 Castaño Bambi',
   'KOLESTON TINTE # 77 C/12', 1, 53.50, 86,
   'marca', 'Cuidado personal', 'Koleston', 'Kit coloración 1 aplicación',
   'Tintes',
   'https://www.farmacapital.mx/catalogo-propia/koleston-77-castano-bambi-3614225108914.jpg',
   false, true);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, imagen_url
)
select
  t.nombre,
  t.sku,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Super Acertijo 000140 · pedido 614698 · 2026-09-08 · Bodega F38 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.imagen_url
from _fc_sa000140 t
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
from _fc_sa000140 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
   or p.id = public.fc_buscar_producto_escaneo(t.sku);

commit;

-- ═══════════════════════════════════════════════════════════
-- B) Cola Recibir (transacción 2)
-- ═══════════════════════════════════════════════════════════
begin;

create temp table _fc_sa000140b (
  linea integer primary key,
  ean text not null,
  sku text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_sa000140b (linea, ean, sku, snap, qty, costo) values
  (1, '3614225108853', 'FC-25108853', 'KOLESTON TINTE # 67 C/12', 1, 53.50),
  (2, '3614225109003', 'FC-25109003', 'KOLESTON TINTE # 64 C/12', 1, 53.50),
  (3, '3614225108860', 'FC-25108860', 'KOLESTON TINTE # 674 C/12', 1, 53.50),
  (4, '3614225108914', 'FC-25108914', 'KOLESTON TINTE # 77 C/12', 1, 53.50);

update public.recepciones
set estado = 'borrador'
where folio = '000140'
  and coalesce(proveedor, '') ilike '%acertijo%'
  and estado in ('pendiente_alta', 'pendiente_caducidad');

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Super Acertijo',
  '000140',
  '2026-09-08',
  214.00,
  'borrador',
  'Remisión Super Acertijo 000140 · pedido 614698 · 08-09-2026 · Bodega F38 · 4 kits Koleston · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '000140' and coalesce(proveedor, '') ilike '%acertijo%'
);

update public.recepciones
set
  total_ticket = 214.00,
  fecha = '2026-09-08',
  proveedor = 'Super Acertijo',
  notas = 'Remisión Super Acertijo 000140 · pedido 614698 · 08-09-2026 · Bodega F38 · 4 kits Koleston · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '000140'
  and coalesce(proveedor, '') ilike '%acertijo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '000140'
  and coalesce(r.proveedor, '') ilike '%acertijo%'
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
from _fc_sa000140b t
join public.recepciones r
  on r.folio = '000140'
 and coalesce(r.proveedor, '') ilike '%acertijo%'
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
where r.folio = '000140' and coalesce(r.proveedor, '') ilike '%acertijo%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 40) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.producto_id,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as match
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '000140' and coalesce(r.proveedor, '') ilike '%acertijo%'
order by i.id;
