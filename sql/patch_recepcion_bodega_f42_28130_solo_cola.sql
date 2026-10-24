-- ============================================================================
-- Bodega F-42 · Caja 4/28130 · SOLO cola Recibir (sin INSERT en productos)
-- ============================================================================
-- Si el SQL completo de altas falló por SKU/EAN, este archivo solo crea el
-- pedido en borrador con 73 renglones. Los que no estén en catálogo quedan
-- pendiente_alta; se dan de alta al escanear / desde el recuadro rojo.
-- Sin caducidad inventada. Pegar TODO en Supabase → Run.
-- ============================================================================

-- Pedido Bodega F-42 28130 (2026-10-24) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_bodega28130 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_bodega28130 (linea, ean, sku, nombre, qty, costo) values
  (1, '7506078972292', null, 'Obao Piel Delicada spray 150 ml', 1, 43.41),
  (2, '7509552909814', null, 'Obao Rosa Tentación 48h spray 150 ml', 1, 43.41),
  (3, '7506306226722', null, 'Axe Men Young spray 150 ml', 2, 45.83),
  (4, '7509552844795', null, 'Obao Ritual Natural Coco spray 150 ml', 1, 42.41),
  (5, '7506306226739', null, 'Axe Men Conviction spray 150 ml', 1, 45.83),
  (6, '7506306213081', null, 'Axe Music Fresh 48h spray 150 ml', 2, 45.83),
  (7, '75062804', null, 'Rexona Antibacterial + Aclarante roll-on 50 ml', 1, 33.74),
  (8, '7506306245686', null, 'Axe Men Epic Fresh 48h spray 150 ml', 2, 45.83),
  (9, '7501868920163', null, 'Dibar gel antibacterial 500 ml', 2, 35.24),
  (10, '75085513', null, 'Rexona Men Invisible Balm Milk & Peonia barra 41 g', 2, 55.68),
  (11, '7506306244795', null, 'Axe Intense 48h spray 150 ml', 1, 45.83),
  (12, '75081669', null, 'Rexona Powder Dry roll-on 50 ml', 1, 30.13),
  (13, '7506376000284', null, 'Vitacilina agua micelar rosa-sábila 500 ml', 1, 81.47),
  (14, '7506078928565', null, 'L''Oréal desmaquillante bifásico 200 ml', 1, 118.13),
  (15, '75075996', null, 'Rexona Happy Morning 48h roll-on 50 ml', 1, 34.79),
  (16, '78924345', null, 'Rexona Women Bamboo roll-on 50 ml', 1, 30.13),
  (17, '7502254073821', null, 'Glesol Fresh desinfectante antibacterial 443 ml', 2, 68.19),
  (18, '759684154140', null, 'Jaloma gel antibacterial 120 ml', 3, 18.18),
  (19, '037836051555', null, 'Grisi jabón líquido para manos neutro 480 ml', 1, 45.98),
  (20, '7501022151198', null, 'Grisi jabón líquido para manos fresia 480 ml', 1, 45.98),
  (21, '7501082731064', null, 'Nuvel Soft Woman spray 170 ml', 2, 32.73),
  (22, '7501082731071', null, 'Nuvel Tropic Woman spray 170 ml', 2, 32.73),
  (23, '7500435107389', null, 'Old Spice Bearglove spray 150 ml', 2, 59.45),
  (24, '7500435257008', null, 'Old Spice Paradise spray 150 ml', 2, 59.48),
  (25, '7506309839141', null, 'Old Spice Wolfthorn Anti spray 150 ml', 2, 56.23),
  (26, '7506339349146', null, 'Old Spice Wolfthorn spray 150 ml', 2, 59.84),
  (27, '7501082731057', null, 'Nuvel Fusion Men spray 160 ml', 1, 32.72),
  (28, '75085537', null, 'Rexona Men Invisible Balm Mint Fresh barra 41 g', 2, 55.68),
  (29, '75085520', null, 'Rexona Men Invisible Balm Ocean Fresh barra 41 g', 2, 55.68),
  (30, '7501082731040', null, 'Nuvel Devotion Men spray 170 ml', 1, 32.72),
  (31, '7501082736021', null, 'Nuvel Aclarante Woman spray 150 ml', 2, 35.45),
  (32, '7791293036052', null, 'Rexona Women Flores Blancas spray 150 ml', 2, 54.68),
  (33, '7501054504535', null, 'Nivea Body Milk Extra Seca 400 ml', 2, 84.50),
  (34, '4005900581341', null, 'Nivea Milk Nutritiva piel extra seca 625 ml', 2, 113.64),
  (35, '7506306202832', null, 'Axe Collision spray 150 ml', 1, 45.83),
  (36, '4005808802836', null, 'Nivea Soft Milk seca 400 ml', 2, 84.50),
  (37, '7501082790504', null, 'Nuvel desmaquillante bifásico oil 125 ml', 3, 27.75),
  (38, '810120501673', null, 'Hinds Agave Azul crema líquida 400 ml', 1, 42.25),
  (39, '037836041273', null, 'Hinds Rosa crema corporal 400 ml', 1, 49.97),
  (40, '037836041259', null, 'Hinds Rosa crema líquida 90 ml', 2, 18.74),
  (41, '7791293036045', null, 'Rexona Women Pomelo / Toronja spray 150 ml', 1, 54.55),
  (42, '7501082790474', null, 'Nuvel desmaquillante oil-free piel mixta 235 ml', 1, 43.65),
  (43, '759684154232', null, 'Jaloma gel antibacterial 60 ml', 3, 13.01),
  (44, '7501022140543', null, 'Ricitos de Oro Lavanda kit C/4', 1, 106.64),
  (45, '037836041426', null, 'Hinds Hidratación Extrema con avena 400 ml', 1, 49.97),
  (46, '7791293032412', null, 'Rexona Women Sexy Bouquet spray 150 ml', 1, 54.68),
  (47, '037836041341', null, 'Hinds Natural crema líquida piel reseca 90 ml', 2, 18.74),
  (48, '037836041365', null, 'Hinds Natural crema líquida piel reseca 400 ml', 1, 49.97),
  (49, '7506306216907', null, 'Rexona Efficient pies talco dúo 200 g', 1, 120.00),
  (50, '7501022188507', null, 'Ricitos de Oro Lavanda y Leche shampoo 400 ml + crema 100 ml', 1, 77.52),
  (51, '7501082790450', null, 'Nuvel gel limpiador facial 235 ml', 1, 42.36),
  (52, '7791293025810', null, 'Axe Men Fusion spray 150 ml', 1, 45.83),
  (53, '7501082790498', null, 'Nuvel desmaquillante bifásico rostro/ojos 235 ml', 1, 43.65),
  (54, '7791293025797', null, 'Axe Men Dark Temptation spray 150 ml', 1, 45.83),
  (55, '7509546052632', null, 'Colgate Total Advanced Clean 75 ml', 3, 23.90),
  (56, '037836040368', null, 'Ricitos de Oro agua de colonia spray 100 ml', 2, 39.07),
  (57, '7501082722123', null, 'Nuvel crema para manos hidratada 65 ml', 1, 13.49),
  (58, '7798140258490', null, 'Tío Nacho Ultra Hidratación Coco shampoo 415 ml', 1, 85.84),
  (59, '7506295388487', null, 'Oral-B 3D White Brilliance Fresh pasta 53 ml', 3, 24.61),
  (60, '7791293032429', null, 'Rexona Women Happy Morning spray 150 ml', 1, 54.68),
  (61, '7896009498091', null, 'Sensodyne Protección Completa limpieza efectiva 90 g', 1, 72.62),
  (62, '7896009419324', null, 'Sensodyne Original pasta dental 90 g', 1, 72.62),
  (63, '7509546687353', null, 'Colgate Máxima Protección Anticaries Calci-Protect 90 ml', 1, 33.34),
  (64, '7509546054032', null, 'Colgate Luminous White pasta dental', 3, 17.54),
  (65, '7506306257597', null, 'Rexona Efficient Original talco para pies 100 g', 2, 40.24),
  (66, '7501027280657', null, 'Kids 2 en 1 Smoothie Manzana shampoo 265 ml', 1, 77.23),
  (67, '7506078941755', null, 'L''Oréal Kids 3 en 1 Explosión Frambuesa shampoo 265 ml', 1, 77.00),
  (68, '7506306257580', null, 'Rexona Efficient polvo desodorante pies 50 g', 2, 29.68),
  (69, '7501082722116', null, 'Nuvel crema para manos suaves 65 ml', 1, 13.49),
  (70, '7501846506198', null, 'Xiomara Elastik cera 100 g', 2, 78.14),
  (71, '7509552874952', null, 'Elvive Hidra Hialurónico Pure shampoo 370 ml', 1, 71.44),
  (72, '7501054558682', null, 'Nivea Milk crema corporal 400 ml + 100 ml', 1, 85.87),
  (73, '7509552525427', null, 'Obao Frescura Suave / Piel Delicada roll-on 65 g 3-pack', 1, 58.95);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '28130',
  '2026-10-24',
  5282.50,
  'borrador',
  'Ticket Bodega F-42 Caja 4/28130 · 24-oct-2026 · foto térmica · tarjeta $5,282.50 · SOLO cola Recibir (sin altas catálogo en este SQL); stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '28130' and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = 5282.50,
  fecha = '2026-10-24',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 Caja 4/28130 · 24-oct-2026 · foto térmica · tarjeta $5,282.50 · SOLO cola Recibir (sin altas catálogo en este SQL); stock al confirmar pistola',
  updated_at = now()
where folio = '28130'
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '28130'
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
  nullif(btrim(t.ean), ''),
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
from _fc_rx_bodega28130 t
join public.recepciones r
  on r.folio = '28130'
 and coalesce(r.proveedor, '') ilike '%bodega%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    case when nullif(btrim(t.sku), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), ''))
      else null end
  ) as pid
) v on true
order by t.linea;

commit;

-- Diagnóstico: si renglones = 0 y estado <> borrador → ya estaba cerrada.
-- Si 0 filas → no se insertó (revisa error arriba).
select
  r.id as recepcion_id,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '28130'
  and coalesce(r.proveedor, '') ilike '%bodega%'
group by r.id, r.folio, r.estado, r.total_ticket
order by r.id;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '28130' and coalesce(r.proveedor, '') ilike '%bodega%'
order by i.id;
