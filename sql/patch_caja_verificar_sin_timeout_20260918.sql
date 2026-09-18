-- ============================================================================
-- POS: "No se pudo verificar la caja" / canceling statement due to statement timeout
--
-- Al entrar al POS se disparan a la vez:
--   1) empleado_sesion_caja_abierta  (debería ser un SELECT chico)
--   2) empleado_listar_productos_con_lotes_pos (catálogo + lotes, pesado)
--   3) empleado_jornada_hoy (cortes del día)
--
-- Las tres llaman fn_validar_token_empleado, que hacía UPDATE de sesiones.
-- El catálogo se queda con el renglón del token; la verificación espera
-- el candado hasta que Supabase corta a los ~8 s. La caja NO se cierra.
--
-- Esto:
--   1) Validar token con SELECT. El UPDATE (sliding 8 h) solo si last_used
--      tiene >30 s y con lock_timeout 120 ms: si hay candado, se salta.
--   2) empleado_sesion_caja_abierta solo LEE (sin tocar sesiones).
--   3) cortes_caja: índice + filtro por rango (el AT TIME ZONE no usa índice).
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create index if not exists idx_sesiones_token_vivas
  on public.sesiones (token)
  where revoked_at is null;

create index if not exists idx_cortes_caja_empleado_turno_created
  on public.cortes_caja (empleado_id, turno, created_at)
  where anulado_at is null;

create index if not exists idx_caja_sesiones_empleado_fecha_turno
  on public.caja_sesiones (empleado_id, fecha, turno);

create index if not exists idx_caja_sesiones_empleado_abierta
  on public.caja_sesiones (empleado_id)
  where estado = 'abierta';

create or replace function public.fn_validar_token_empleado(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_lock_prev text;
begin
  if p_token is null then
    return null;
  end if;

  select usuario_id into v_user_id
  from public.sesiones
  where token = p_token
    and revoked_at is null
    and expires_at > now();

  if v_user_id is null then
    return null;
  end if;

  -- Sliding session. No pelear el candado con el catálogo del POS.
  -- lock_timeout es LOCAL: hay que restaurarlo o el catálogo hereda 120 ms.
  v_lock_prev := current_setting('lock_timeout', true);
  begin
    perform set_config('lock_timeout', '120ms', true);
    update public.sesiones
       set last_used_at = now(),
           expires_at = greatest(expires_at, now() + interval '8 hours')
     where token = p_token
       and last_used_at < now() - interval '30 seconds';
  exception
    when lock_not_available then null;
    when query_canceled then null;
  end;
  perform set_config('lock_timeout', coalesce(nullif(v_lock_prev, ''), '0'), true);

  return v_user_id;
end;
$$;

revoke all on function public.fn_validar_token_empleado(uuid) from public, anon, authenticated;

create or replace function public.empleado_sesion_caja_abierta(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_activo boolean;
  v_row public.caja_sesiones%rowtype;
begin
  -- Solo lectura: no UPDATE de sesiones (eso bloqueaba el POS).
  select s.usuario_id, u.activo
    into v_user_id, v_activo
  from public.sesiones s
  join public.usuarios u on u.id = s.usuario_id
  where s.token = p_session_token
    and s.revoked_at is null
    and s.expires_at > now();

  if v_user_id is null then
    raise exception 'Sesión inválida o expirada' using errcode = '28000';
  end if;
  if v_activo is not true then
    raise exception 'Usuario inactivo' using errcode = '42501';
  end if;

  select * into v_row
  from public.caja_sesiones
  where estado = 'abierta'
    and empleado_id = v_user_id
  limit 1;

  if v_row.id is null then
    return jsonb_build_object('abierta', false);
  end if;

  return jsonb_build_object(
    'abierta', true,
    'id', v_row.id,
    'turno', v_row.turno,
    'fecha', v_row.fecha,
    'fondo_contado', v_row.fondo_contado,
    'denominaciones', v_row.denominaciones,
    'nota_apertura', v_row.nota_apertura,
    'abierta_at', v_row.abierta_at
  );
end;
$$;

grant execute on function public.empleado_sesion_caja_abierta(uuid) to anon, authenticated;

-- Cortes del día: rango usable por índice, no (created_at AT TIME ZONE)::date.
create or replace function public.fn_empleado_ya_tuvo_turno_hoy(
  p_user_id bigint,
  p_turno   text,
  p_fecha   date default ((now() at time zone 'America/Mexico_City')::date)
)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select
    p_user_id is not null
    and p_turno in ('matutino', 'vespertino')
    and (
      exists (
        select 1
        from public.caja_sesiones s
        where s.empleado_id = p_user_id
          and s.fecha = p_fecha
          and s.turno = p_turno
          and s.estado = 'cerrada'
      )
      or exists (
        select 1
        from public.cortes_caja cc
        where cc.empleado_id = p_user_id
          and cc.turno = p_turno
          and cc.anulado_at is null
          and cc.created_at >= (p_fecha::timestamp at time zone 'America/Mexico_City')
          and cc.created_at <  ((p_fecha + 1)::timestamp at time zone 'America/Mexico_City')
      )
    );
$$;

grant execute on function public.fn_empleado_ya_tuvo_turno_hoy(bigint, text, date) to anon, authenticated;

notify pgrst, 'reload schema';

commit;
