-- =============================================================================
-- ALIAS: mismo contenido que
--   sql/patch_quitar_accuchek_softclix_cancelado_SOLO_pegar_esto.sql
-- Usa ese archivo. Este queda por si alguien ya tenía el path v2 abierto.
-- =============================================================================

-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Quitar Accu-Chek Softclix de Recibir (pedido cancelado, nunca llegará)

-- 0) Cola viva AHORA
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
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket, r.notas
order by r.updated_at desc;

begin;

create temporary table _accu_kill on commit drop as
select r.id
from public.recepciones r
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and (
    trim(both from coalesce(r.folio, '')) in ('20260917', '2026-09-17')
    or replace(lower(coalesce(r.proveedor, '')), '-', '') like '%accuchek%'
    or lower(coalesce(r.proveedor, '')) like '%accu%chek%'
    or lower(coalesce(r.proveedor, '')) like '%tienda%accu%'
    or coalesce(r.notas, '') ilike '%tienda oficial accu%'
    or coalesce(r.notas, '') ilike '%4×25%'
    or coalesce(r.notas, '') ilike '%4x25%'
    or r.total_ticket = 626.40
    or (
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

select count(*) as tickets_a_cerrar from _accu_kill;

delete from public.recepcion_items i
where i.recepcion_id in (select id from _accu_kill);

update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, now()),
  notas = trim(both from concat_ws(' · ',
    nullif(btrim(r.notas), ''),
    'Cancelado 08-nov-2026: Accu-Chek Softclix no llegó; quitado de Recibir'
  )),
  updated_at = now()
where r.id in (select id from _accu_kill);

commit;

select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  r.cerrado_en,
  left(coalesce(r.notas, ''), 140) as notas,
  count(i.*) as renglones
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where coalesce(r.proveedor, '') ilike '%accu%'
   or trim(both from coalesce(r.folio, '')) in ('20260917', '2026-09-17')
   or r.total_ticket = 626.40
   or coalesce(r.notas, '') ilike '%softclix%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket, r.cerrado_en, r.notas
order by r.updated_at desc;

select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket
having count(i.*) = 0
    or count(*) filter (where not coalesce(i.confirmado, false)) > 0
order by r.updated_at desc;
