-- SOLO DIAGNÓSTICO — no escribe nada.
-- Tickets de los últimos días (fin-oct / 1-3 nov) + Tenorio 3838940.
-- Pegar en Supabase → SQL Editor → Run.
--
-- Cómo leerlo:
--   0 filas del folio            → el SQL de carga nunca se pegó
--   estado = borrador            → vivo en Recibir (falta pistola / MMAA)
--   estado = confirmada/descuadre → ya se cerró en Recibir
--   confirmados < piezas         → parcial: faltan cajas por escanear

with folios(proveedor_ilike, folio, esperado) as (
  values
    -- Merged a main (SQL en repo); verificar si se pegó y se recibió
    ('fanasa',   'B49445264',   'merged #517 · 02-nov · $667.19'),
    ('nadro',    '6091110421',  'merged #516 · 13-oct · $644.52'),
    ('farmalive','13677',       'merged #501 · 26-oct · $2,892.07'),
    ('cityfarma','S335144',     'merged #501 · 26-oct'),
    ('cityfarma','S335145',     'merged #501 · 26-oct'),
    ('cityfarma','S335151',     'merged #501 · 26-oct'),
    ('levic',    '9012545305',  'merged #500 · 26-oct · AMSA BEA215'),
    ('levic',    '9012442706',  'nuevo · 12-oct · $943.81'),
    ('hs',       'T610241957',  'merged #490 · 24-oct'),
    ('equilibrio','241026',     'merged #491 · 24-oct'),
    ('bodega',   '28130',       'merged #486 · 24-oct'),
    -- Este PR
    ('tenorio',  '3838940',     'nuevo · 02-nov · $1,148.52'),
    -- Tenorio anterior (PR #473 abierto; puede o no estar en DB)
    ('tenorio',  '3811849',     'PR #473 abierto · 15-oct · $1,393.88'),
    -- PRs abiertos recientes (SQL no está en main)
    ('nadro',    '6091723171',  'PR #505 abierto · 29-oct'),
    ('farmalive','11104',       'PR #506 abierto · 30-oct'),
    ('citymark', '76370',       'PR #507 abierto · 30-oct'),
    ('cityfarma','S336478',     'PR #508 abierto · 30-oct'),
    ('cityfarma','S336493',     'PR #508 abierto · 30-oct'),
    ('equilibrio','450041',     'PR #508 abierto · 30-oct'),
    ('equilibrio','450233',     'merged · 02-nov · $1,125.10'),
    ('fanasa',   'B49397867',   'PR #504 abierto · Lubrex'),
    ('nadro',    '6091546907',  'PR #499 abierto · 26-oct'),
    ('cityfarma','S334713',     'PR #494 abierto · 24-oct'),
    ('farmalive','15586',       'PR #489 abierto · 24-oct'),
    ('nadro',    '6091460910',  'PR #482 abierto · 23-oct')
)
select
  f.folio,
  f.esperado,
  r.id as recepcion_id,
  r.proveedor,
  r.estado,
  r.fecha,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola,
  bool_or(coalesce(i.pendiente_alta, false)) as tiene_pendiente_alta,
  case
    when r.id is null then 'NO CARGADO'
    when r.estado = 'borrador' and count(*) filter (where coalesce(i.confirmado, false)) = 0
      then 'EN COLA — sin escanear'
    when r.estado = 'borrador' and count(*) filter (where not coalesce(i.confirmado, false)) > 0
      then 'EN COLA — parcial'
    when r.estado in ('confirmada', 'descuadre')
      then 'RECIBIDO'
    else 'REVISAR: ' || coalesce(r.estado, '?')
  end as veredicto
from folios f
left join public.recepciones r
  on r.folio = f.folio
 and coalesce(r.proveedor, '') ilike '%' || f.proveedor_ilike || '%'
left join public.recepcion_items i on i.recepcion_id = r.id
group by
  f.folio, f.esperado, r.id, r.proveedor, r.estado, r.fecha, r.total_ticket
order by
  case when r.id is null then 0 when r.estado = 'borrador' then 1 else 2 end,
  f.folio;
