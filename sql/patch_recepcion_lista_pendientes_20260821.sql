-- Recibir: lista de tickets abiertos + Nuevo ticket no pisa el anterior.
-- 21-ago-2026. Idempotente. No vuelve a cargar Cityfarma/Farmalive.
-- Pegar en Supabase SQL Editor.

begin;

create or replace function public.recepcion_abrir(
  p_session_token uuid,
  p_proveedor text default null,
  p_folio text default null,
  p_total_ticket numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_id bigint;
begin
  v_user := public.fn_require_empleado(p_session_token);

  insert into public.recepciones (proveedor, folio, total_ticket, capturado_por, estado)
  values (
    nullif(btrim(p_proveedor), ''),
    nullif(btrim(p_folio), ''),
    p_total_ticket,
    v_user,
    'borrador'
  )
  returning id into v_id;

  return public.fc_recepcion_json(v_id);
end;
$$;

create or replace function public.recepcion_abrir_existente(
  p_session_token uuid,
  p_recepcion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user bigint;
  v_estado text;
begin
  v_user := public.fn_require_empleado(p_session_token);
  if p_recepcion_id is null then
    raise exception 'recepcion_id requerido';
  end if;
  select estado into v_estado from public.recepciones where id = p_recepcion_id;
  if not found then
    raise exception 'recepcion no existe';
  end if;
  if v_estado not in ('borrador', 'pendiente_alta', 'pendiente_caducidad') then
    raise exception 'esa recepcion ya esta cerrada';
  end if;
  update public.recepciones set updated_at = now() where id = p_recepcion_id;
  return public.fc_recepcion_json(p_recepcion_id);
end;
$$;

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
    group by r.id
    having count(i.id) > 0
       and (
         count(*) filter (where not i.confirmado) > 0
         or count(*) filter (where i.lote_id is not null and i.fecha_caducidad is null) > 0
         or r.estado in ('borrador', 'pendiente_caducidad')
       )
  ) x;
  return v_out;
end;
$$;

grant execute on function public.recepcion_abrir(uuid, text, text, numeric) to anon, authenticated;
grant execute on function public.recepcion_abrir_existente(uuid, bigint) to anon, authenticated;
grant execute on function public.recepcion_listar_abiertas(uuid) to anon, authenticated;

commit;
