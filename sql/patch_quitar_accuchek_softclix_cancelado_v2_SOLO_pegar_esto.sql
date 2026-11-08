-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Quitar Accu-Chek Softclix de Recibir (v2 — match amplio)
--
-- Motivo: pedido cancelado, nunca llegará.
-- v1 pudo no matchear si el proveedor no traía exactamente "accu-chek".
-- Este Run: 1) muestra TODO lo abierto Accu/Softclix  2) cierra  3) verifica.
-- NO toca stock. Idempotente. Sin dollar-quote.
-- =============================================================================

begin;

-- 1) ¿Qué hay abierto que huela a Accu / Softclix?
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  left(coalesce(r.notas, ''), 100) as notas,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  coalesce(string_agg(distinct i.codigo_escaneado, ', '), '') as eans
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    r.folio in ('20260917', 'S324509')
    or coalesce(r.proveedor, '') ilike '%accu%'
    or coalesce(r.proveedor, '') ilike '%roche%'
    or coalesce(r.notas, '') ilike '%accu%'
    or coalesce(r.notas, '') ilike '%softclix%'
    or exists (
      select 1 from public.recepcion_items x
      where x.recepcion_id = r.id
        and x.codigo_escaneado in (
          '4015630018277',  -- Softclix 25
          '4015630018284',  -- Softclix 100
          '4015630082988',  -- Active glucómetro
          '799192067426'    -- Instant kit
        )
    )
  )
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket, r.notas
order by r.updated_at desc;

-- 2) Borrar renglones: Tienda Accu-Chek Softclix (NO Cityfarma S324509 ni Nadro)
delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    r.folio = '20260917'
    or coalesce(r.proveedor, '') ilike '%accu%'
    or coalesce(r.notas, '') ilike '%tienda oficial accu%'
    or coalesce(r.notas, '') ilike '%4×25%'
    or coalesce(r.notas, '') ilike '%4x25%'
    or (
      -- Solo Softclix 25+100 (sin Active/Instant/otros)
      exists (
        select 1 from public.recepcion_items x
        where x.recepcion_id = r.id
          and x.codigo_escaneado in ('4015630018277', '4015630018284')
      )
      and not exists (
        select 1 from public.recepcion_items y
        where y.recepcion_id = r.id
          and coalesce(y.codigo_escaneado, '') not in ('4015630018277', '4015630018284', '')
      )
    )
  );

-- 3) Cerrar encabezados (confirmada = sale de la cola)
update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, now()),
  notas = trim(both from concat_ws(' · ',
    nullif(btrim(r.notas), ''),
    'Cancelado 08-nov-2026 v2: Accu-Chek Softclix no llegó; quitado de Recibir'
  )),
  updated_at = now()
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    r.folio = '20260917'
    or coalesce(r.proveedor, '') ilike '%accu%'
    or coalesce(r.notas, '') ilike '%tienda oficial accu%'
    or coalesce(r.notas, '') ilike '%4×25%'
    or coalesce(r.notas, '') ilike '%4x25%'
    or (
      not exists (select 1 from public.recepcion_items z where z.recepcion_id = r.id)
      and (
        coalesce(r.proveedor, '') ilike '%accu%'
        or coalesce(r.notas, '') ilike '%accu%'
        or coalesce(r.notas, '') ilike '%softclix%'
        or r.folio = '20260917'
      )
    )
  );

commit;

-- VERIFICACION A: tickets Accu/Softclix (deben estar confirmada o no existir abiertos)
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  left(coalesce(r.notas, ''), 120) as notas,
  count(i.*) as renglones
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%accu%'
   or r.folio in ('20260917', 'S324509')
   or coalesce(r.notas, '') ilike '%softclix%'
group by r.id
order by r.updated_at desc;

-- VERIFICACION B: cola viva (no debe salir Accu)
select
  r.proveedor,
  r.folio,
  r.estado,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.id, r.proveedor, r.folio, r.estado
having count(i.*) > 0
   and count(*) filter (where not coalesce(i.confirmado, false)) > 0
order by r.updated_at desc;
