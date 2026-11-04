-- =============================================================================
-- FORZAR cola Recibir visible + diagnostico
-- Pegar TODO en Supabase → SQL Editor → Run
-- 1) Reabre folios a borrador (si quedaron cerrados / otro estado)
-- 2) Vuelve a pegar el SQL grande de tickets DESPUES de este (o corre
--    el bloque REINYECTAR al final si ya estan los productos)
-- Sin $$ / do $$.
-- =============================================================================

-- A) QUE HAY HOY (antes)
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.id) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  case
    when count(i.id) = 0 then 'SIN RENGLONES — no sale en Recibir'
    when count(*) filter (where not coalesce(i.confirmado, false)) = 0
      and count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null) = 0
      then 'TODO CONFIRMADO — no sale en Recibir'
    when r.estado not in ('borrador','pendiente_alta','pendiente_caducidad')
      then 'ESTADO MAL — no sale: ' || r.estado
    else 'DEBERIA SALIR en Recibir'
  end as veredicto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where
     (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
  or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
  or (r.folio in ('6091110421','6091723171') and coalesce(r.proveedor,'') ilike '%nadro%')
  or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
  or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
  or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
  or (r.folio = '76370')
  or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
order by r.proveedor, r.folio;

-- Folios que NI EXISTEN (faltan del todo)
with esperados(proveedor_like, folio) as (
  values
    ('%tenorio%', '3838940'),
    ('%fanasa%', 'B49445264'),
    ('%fanasa%', 'B49397867'),
    ('%nadro%', '6091110421'),
    ('%levic%', '9012545305'),
    ('%levic%', '9012442706'),
    ('%equilibrio%', '450233'),
    ('%equilibrio%', '450041'),
    ('%cityfarma%', 'S336478'),
    ('%cityfarma%', 'S336493'),
    ('%bodega%f-42%', '76370'),
    ('%farmalive%', '11104')
)
select e.folio, e.proveedor_like,
  case when exists (
    select 1 from public.recepciones r
    where r.folio = e.folio
      and (e.folio = '76370' or coalesce(r.proveedor,'') ilike e.proveedor_like)
  ) then 'existe' else 'NO EXISTE — el SQL grande no creo este ticket' end as estado
from esperados e
order by e.folio;

begin;

-- B) REABRIR a borrador (sin tocar renglones todavia)
update public.recepciones r
set
  estado = 'borrador',
  updated_at = now()
where r.estado is distinct from 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  );

-- C) Si hay renglones ya confirmados por error (ticket recien pegado, sin stock),
--    y NO tienen lote_id, volverlos a gris para que salgan en la cola.
update public.recepcion_items i
set confirmado = false
from public.recepciones r
where i.recepcion_id = r.id
  and coalesce(i.confirmado, false) = true
  and i.lote_id is null
  and i.fecha_caducidad is null
  and r.estado = 'borrador'
  and (
       (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
    or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
    or (r.folio in ('6091110421','6091723171') and coalesce(r.proveedor,'') ilike '%nadro%')
    or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
    or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
    or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
    or (r.folio = '76370' and coalesce(r.proveedor,'') ilike '%bodega%f-42%')
    or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
  );

commit;

-- D) QUE QUEDO (despues del reopen)
select
  r.proveedor,
  r.folio,
  r.estado,
  count(i.id) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  case
    when count(i.id) = 0 then 'FALTA RENGLONES — corre de nuevo el SQL grande PEGAR_ESTO_TODO'
    when count(*) filter (where not coalesce(i.confirmado, false)) > 0 then 'OK visible en Recibir'
    else 'Revisa confirmados'
  end as veredicto
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where
     (r.folio = '3838940' and coalesce(r.proveedor,'') ilike '%tenorio%')
  or (r.folio in ('B49445264','B49397867') and coalesce(r.proveedor,'') ilike '%fanasa%')
  or (r.folio in ('6091110421','6091723171') and coalesce(r.proveedor,'') ilike '%nadro%')
  or (r.folio in ('9012545305','9012442706') and coalesce(r.proveedor,'') ilike '%levic%')
  or (r.folio in ('450233','450041') and coalesce(r.proveedor,'') ilike '%equilibrio%')
  or (r.folio in ('S336478','S336493') and coalesce(r.proveedor,'') ilike '%cityfarma%')
  or (r.folio = '76370')
  or (r.folio = '11104' and coalesce(r.proveedor,'') ilike '%farmalive%')
group by r.id, r.proveedor, r.folio, r.estado
order by r.proveedor, r.folio;

-- E) Simula la cola de la tablet (sin sesion)
select
  r.proveedor,
  r.folio,
  r.estado,
  count(i.id)::int as renglones,
  count(*) filter (where not coalesce(i.confirmado, false))::int as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and coalesce(r.notas, '') not like 'backfill ticket inicial%'
group by r.id
having count(i.id) > 0
   and (
     count(*) filter (where not coalesce(i.confirmado, false)) > 0
     or count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null) > 0
   )
order by r.updated_at desc
limit 40;
