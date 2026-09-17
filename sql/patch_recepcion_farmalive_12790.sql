-- Pedido Farmalive 12790 (2026-09-15) — cola Recibir, borrador.
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- No suma stock: las piezas entran al escanear con pistola y poner MMAA de la caja.
-- El pedido no trae lote ni caducidad; se quedan en null. No inventar 0000.
-- Idempotente mientras el ticket siga en borrador.
-- Si ya está confirmado/cerrado, no crea otro ni toca renglones.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_rx_farmalive12790 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  qty integer not null,
  costo numeric(12,2) not null
) on commit drop;

insert into _fc_rx_farmalive12790 (linea, ean, sku, nombre, qty, costo) values
  (1, '7501065065322', null, 'Advil 12 Horas ibuprofeno 600 mg C/6 | Haleon', 3, 74.15),
  (2, '7501108763468', null, 'Advil ibuprofeno 200 mg cápsulas C/10 | Haleon', 1, 138.18),
  (3, '020800600347', null, 'Tampax Super Plus tampones C/10 | P&G', 2, 43.12),
  (4, '7501017362998', null, 'Kleenex pañuelos pack C/8 | Kimberly-Clark', 1, 32.83),
  (5, '7501008499245', null, 'Aspirina GO sobres C/10 | Bayer', 10, 58.80),
  (6, '7501065028785', null, 'Mejoral tabletas C/12 | Haleon', 4, 27.14),
  (7, '7501008499429', null, 'Aspirina tabletas C/40 3-pack | Bayer', 1, 115.15),
  (8, '7502214983207', null, 'Lubricante Prudence uva 75 mL | DKT', 1, 70.17),
  (9, '7506460101460', null, 'Condón Durex Sico Retardante C/3 | RB Health', 1, 46.75),
  (10, '7501369200085', null, 'Estomaquil sobres C/10 | Lab Higia', 2, 60.53),
  (11, '7501098603867', null, 'Losec A omeprazol 20 mg C/14 | Genomma', 1, 29.40),
  (12, '3614225108785', null, 'Tinte Koleston #50 castaño claro | Wella', 2, 53.90),
  (13, '7501033954061', null, 'Ensure líquido chocolate 237 mL | Abbott', 1, 42.63),
  (14, '7501122962816', null, 'Espaven Alcalino suspensión 360 mL | Bausch + Lomb', 1, 173.26),
  (15, '7501088509926', null, 'Gotinal spray adulto 15 mL | Chinoin', 1, 127.30),
  (16, '780083144302', null, 'Collifrin solución nasal adulto 20 mL | Collins', 3, 35.38),
  (17, '3600542641074', null, 'Parche Garnier anti-acné invisible C/22 | L''Oréal', 2, 106.23),
  (18, '650240036187', null, 'Kaopectate tabletas C/10 | Genomma', 1, 57.53),
  (19, '7502214986031', null, 'Lubricante Prudence gel natural 100 mL | DKT', 1, 101.33),
  (20, '650240013898', null, 'Crema Teatrical rosa (lanolina) 52 g | Genomma', 3, 31.07),
  (21, '650240078996', null, 'Crema Teatrical azul 19 g | Genomma', 3, 15.11),
  (22, '650240013850', null, 'Crema Teatrical azul 52 g | Genomma', 3, 31.07),
  (23, '7501033954078', null, 'Ensure líquido fresa 237 mL | Abbott', 1, 42.63),
  (24, '650240079009', null, 'Crema Teatrical rosa (lanolina) 19 g | Genomma', 3, 15.11),
  (25, '7502214982446', null, 'Anillo vibrador Prudence | DKT', 1, 86.04),
  (26, '7501065013767', null, 'Advil ibuprofeno 200 mg tabletas C/12 | Haleon', 1, 42.14),
  (27, '650240069277', null, 'QG5 tabletas C/30 | Genomma', 1, 15.68),
  (28, '650240028335', null, 'Gargax bucofaríngeo solución 60 mL | Genomma', 2, 121.12),
  (29, '7502214982477', null, 'Condón Prudence fresa C/3 | DKT', 3, 34.30),
  (30, '7502214982477', null, 'Condón Prudence fresa C/3 (promo) | DKT', 1, 0.01),
  (31, '7502214982439', null, 'Condón Prudence retardante C/3 | DKT', 5, 47.63),
  (32, '7502214982439', null, 'Condón Prudence retardante C/3 (promo) | DKT', 1, 0.01);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '12790',
  '2026-09-15',
  3534.11,
  'borrador',
  'Pedido Farmalive 12790 · Club Iztapalapa 1 · 15-sep-2026 · EAN del ticket (Advil PR346 Compra 3 @$222.46 → 3×$74.15 · PR347 → EAN Haleon) · precio neto (2%/5%/8%) · promos Prudence @$0.01 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '12790' and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 3534.11,
  fecha = '2026-09-15',
  proveedor = 'Farmalive',
  notas = 'Pedido Farmalive 12790 · Club Iztapalapa 1 · 15-sep-2026 · EAN del ticket (Advil PR346 Compra 3 @$222.46 → 3×$74.15 · PR347 → EAN Haleon) · precio neto (2%/5%/8%) · promos Prudence @$0.01 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '12790'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '12790'
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
from _fc_rx_farmalive12790 t
join public.recepciones r
  on r.folio = '12790'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
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
where r.folio = '12790'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
where r.folio = '12790' and coalesce(r.proveedor, '') ilike '%farmalive%'
order by i.id;
