-- Recibir: el patch de caducidad del 8-sep reabrió tickets YA recibidos.
--
-- Qué pasó: un UPDATE puso estado=borrador en confirmada/descuadre si
-- algún renglón no tenía MMAA. El historial (Bodega F-42, Farmalive 9861,
-- IFC, El Surtidor, Equilibrio 440393…) y tickets ya cerrados volvieron
-- a la cola. El avance de pistola (confirmado, lote, caducidad) NO se
-- tocó; solo el estado del ticket.
--
-- Esto:
--   1) Cierra otra vez el historial y lo ya recibido.
--   2) Deja vivos solo tickets con cajas pendientes (gris o MMAA de anaquel).
--   3) Recibir ya no lista el historial aunque el estado haya quedado mal.
--
-- NO inventa caducidad. NO resetea renglones verdes.
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

-- 1) Historial de compras: nunca es cola Recibir
update public.recepciones
set
  estado = 'confirmada',
  cerrado_en = coalesce(cerrado_en, fecha::timestamptz, updated_at)
where estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and coalesce(notas, '') like 'backfill ticket inicial%';

-- 2) Nadro 1658128647824-01 ya se recibió (46/50). Los 4 faltantes
--    viven en el folio …-FALT. No reabrir el original.
update public.recepciones
set
  estado = 'descuadre',
  cerrado_en = coalesce(cerrado_en, updated_at)
where folio = '1658128647824-01'
  and coalesce(proveedor, '') ilike '%nadro%'
  and estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad');

-- 3) Todo verde, sin alta pendiente, sin MMAA de anaquel → ya se recibió
update public.recepciones r
set
  estado = 'confirmada',
  cerrado_en = coalesce(r.cerrado_en, r.updated_at)
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and exists (
    select 1 from public.recepcion_items i where i.recepcion_id = r.id
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and not coalesce(i.confirmado, false)
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and coalesce(i.pendiente_alta, false)
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and i.lote_id is not null
      and i.fecha_caducidad is null
  );

-- 4) Lo escaneable ya está verde; solo quedan altas de catálogo
update public.recepciones r
set
  estado = 'pendiente_alta',
  cerrado_en = coalesce(r.cerrado_en, r.updated_at)
where r.estado = 'borrador'
  and exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id and coalesce(i.pendiente_alta, false)
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and not coalesce(i.confirmado, false)
      and not coalesce(i.pendiente_alta, false)
  )
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = r.id
      and i.lote_id is not null
      and i.fecha_caducidad is null
  );

-- 5) La lista de Recibir solo muestra cajas pendientes. El historial no.
create or replace function public.recepcion_listar_abiertas(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_out jsonb;
begin
  v_user := public.fn_require_empleado(p_session_token);
  select coalesce(jsonb_agg(row_to_json(x)::jsonb order by x.updated_at desc), '[]'::jsonb)
  into v_out
  from (
    select
      r.id,
      r.proveedor,
      r.folio,
      r.fecha,
      r.total_ticket,
      r.estado,
      r.updated_at,
      count(i.id)::int as renglones,
      coalesce(sum(i.cantidad), 0)::int as piezas,
      count(*) filter (where i.pendiente_alta)::int as pendientes_alta,
      count(*) filter (where not i.confirmado)::int as sin_confirmar,
      count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null)::int as sin_caducidad_anaquel,
      coalesce(
        array_remove(array_agg(distinct i.codigo_escaneado), null),
        array[]::text[]
      ) as codigos
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
  ) x;
  return v_out;
end;
$$;

grant execute on function public.recepcion_listar_abiertas(uuid)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;

-- Cola que debe quedar: City Mark / Farma City / Farmalive / etc. con cajas
-- pendientes. Bodega F-42, Farmalive 9861, IFC 1182xx NO deben salir.
select
  r.id,
  r.proveedor,
  r.folio,
  r.estado,
  count(i.*) as renglones,
  count(*) filter (where coalesce(i.confirmado, false)) as confirmados,
  count(*) filter (where not coalesce(i.confirmado, false)) as pendientes_pistola
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.estado in ('borrador', 'pendiente_alta', 'pendiente_caducidad')
  and coalesce(r.notas, '') not like 'backfill ticket inicial%'
group by r.id
having count(i.*) > 0
   and (
     count(*) filter (where not coalesce(i.confirmado, false)) > 0
     or count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null) > 0
   )
order by r.updated_at desc;
