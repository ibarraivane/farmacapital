-- HS Comercial · nota T610241957 · 2026-10-24 13:24
-- Ticket imprime «MAYORISTA DE DULCES IZTAPALAPA, S.A. DE C.V.»
-- (Central de Abasto Sec.2 Bodega E-17, RFC MDI0803131A9).
-- Negocio: HS Comercial · www.hscomercial.mx · WhatsApp 55 4412 5724.
-- Total tarjeta $396.66 (bruto $430.20 − desc. $33.54).
-- Mayoreo → piezas de mostrador. Costo = línea neta / piezas.
-- EAN de fotos de caja (ver también sql/patch_ean_hs_comercial_T610241957.sql).
-- Stock al confirmar en Recibir + MMAA de la caja. No poner caducidad 0000.
--
-- Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- Ver sql/LEERME_hs_comercial_T610241957.md

begin;

insert into public.proveedores (nombre, activo)
select 'HS Comercial', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('HS Comercial')
);

create temp table _fc_hs_t610241957 (
  linea integer primary key,
  sku text not null,
  ean text,
  snap text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  tipo text not null,
  qty integer not null,
  costo numeric(12,4) not null,
  precio numeric(12,2) not null
) on commit drop;

insert into _fc_hs_t610241957
  (linea, sku, ean, snap, nombre, marca, presentacion, categoria, tipo, qty, costo, precio)
values
  (1, 'FC-HS-BOCADIN50', '025046501052', 'Bimbo BOCADIN Bolsa 12/50pzs', 'Bocadin', 'Bimbo', 'Bolsa 50 piezas (525 g)', 'Impulso', 'marca', 50, 1.0990, 2.00),
  (2, 'FC-HS-CHIKIBOT40', '799583006003', 'alv.Chiki BOTELLA 32/40pzs', 'Chiki Botella', 'Alvher', 'Botella (bolsa mayoreo 40)', 'Impulso', 'marca', 40, 0.8115, 2.00),
  (3, 'FC-LV-ORBITMEN40', '7502271913353', 'wrigley Orbit 4is Menta 24/40pzs', 'Orbit 4''s Menta', 'Orbit', 'Pack 4 pastillas (exhibidor 40)', 'Impulso', 'marca', 40, 1.9363, 3.00),
  (4, 'FC-HS-SKITTLES220', '7502226816937', 'wrigley Skittles PAQUETE Original 220g', 'Skittles Original', 'Skittles', 'Caja 10 sobres 22 g (220 g)', 'Impulso', 'marca', 10, 6.6390, 10.00),
  (5, 'FC-HS-MMCAFE6', '7502271917641', 'effem m&m CHOCOLATE cafe 32/6pzs', 'M&M''s Chocolate', 'M&M''s', '6 pack 37.8 g (226.8 g)', 'Impulso', 'marca', 6, 13.5233, 19.00),
  (6, 'FC-HS-KITCHUNKY6', '7501058626554', 'nest.KIT KAT Chunky 40g 12/6pzs', 'Kit Kat Chunky', 'Kit Kat', 'Caja 6 barras 40 g', 'Impulso', 'marca', 6, 14.0450, 20.00);

-- Soltar EAN de otro SKU si chocaría UNIQUE.
update public.productos p
set codigo_barras = null
where nullif(btrim(p.codigo_barras), '') in (
  select nullif(btrim(t.ean), '') from _fc_hs_t610241957 t where t.ean is not null
)
and p.sku not in (select t.sku from _fc_hs_t610241957 t);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  marca, presentacion, costo, precio, stock, stock_minimo,
  activo, requiere_receta
)
select
  t.nombre,
  t.sku,
  t.ean,
  t.categoria,
  t.tipo,
  'Alta HS Comercial T610241957 · 2026-10-24 · ticket Mayorista de Dulces Iztapalapa',
  t.marca,
  t.presentacion,
  t.costo,
  t.precio,
  0,
  greatest(2, least(t.qty / 4, 10)),
  true,
  false
from _fc_hs_t610241957 t
where not exists (
  select 1 from public.productos p where p.sku = t.sku
);

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end,
  marca = coalesce(nullif(btrim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), t.presentacion),
  categoria = t.categoria,
  codigo_barras = case
    when nullif(btrim(p.codigo_barras), '') is null then t.ean
    else p.codigo_barras
  end
from _fc_hs_t610241957 t
where p.sku = t.sku;

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'HS Comercial',
  'T610241957',
  '2026-10-24',
  396.66,
  'borrador',
  'Nota T610241957 · Mayorista de Dulces Iztapalapa Bodega E-17 · HS Comercial · 6 renglones impulso · EAN de fotos de caja · stock al confirmar pistola · descuento ticket prorrateado'
where not exists (
  select 1 from public.recepciones
  where folio = 'T610241957'
    and coalesce(proveedor, '') ilike '%hs comercial%'
);

update public.recepciones
set
  total_ticket = 396.66,
  fecha = '2026-10-24',
  proveedor = 'HS Comercial',
  notas = 'Nota T610241957 · Mayorista de Dulces Iztapalapa Bodega E-17 · HS Comercial · 6 renglones impulso · EAN de fotos de caja · stock al confirmar pistola · descuento ticket prorrateado',
  updated_at = now()
where folio = 'T610241957'
  and coalesce(proveedor, '') ilike '%hs comercial%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T610241957'
  and coalesce(r.proveedor, '') ilike '%hs comercial%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  p.id,
  t.ean,
  t.snap,
  t.qty,
  null,
  null,
  t.costo,
  false,
  'pdf',
  false,
  (
    exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_hs_t610241957 t
join public.recepciones r
  on r.folio = 'T610241957'
 and coalesce(r.proveedor, '') ilike '%hs comercial%'
 and r.estado = 'borrador'
join public.productos p on p.sku = t.sku
order by t.linea;

commit;

select
  i.id,
  p.sku,
  p.codigo_barras as ean,
  left(i.nombre_snapshot, 40) as snap,
  left(p.nombre, 36) as nombre,
  i.cantidad as pzas,
  i.costo_estimado,
  p.precio as pvp,
  case when p.codigo_barras is null then 'EAN PENDIENTE' else 'OK' end as ean_estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
join public.productos p on p.id = i.producto_id
where r.folio = 'T610241957' and coalesce(r.proveedor, '') ilike '%hs comercial%'
order by i.id;
