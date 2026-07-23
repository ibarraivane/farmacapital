-- Admin: marcar solicitud de reset de contraseña como atendida
-- Ejecutar en Supabase SQL Editor.

begin;

create or replace function public.admin_atender_password_reset(
  p_session_token uuid,
  p_request_id    bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_has_estado   boolean;
  v_has_atendido boolean;
begin
  perform public.fn_require_admin(p_session_token);

  if p_request_id is null then
    return jsonb_build_object('success', false, 'error', 'Solicitud no válida');
  end if;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests' and column_name='estado'
  ) into v_has_estado;

  select exists(
    select 1 from information_schema.columns
    where table_schema='public' and table_name='password_reset_requests' and column_name='atendido'
  ) into v_has_atendido;

  if v_has_estado then
    update public.password_reset_requests
    set estado = 'atendido'
    where id = p_request_id;
  elsif v_has_atendido then
    update public.password_reset_requests
    set atendido = true
    where id = p_request_id;
  else
    delete from public.password_reset_requests where id = p_request_id;
  end if;

  if not found then
    return jsonb_build_object('success', false, 'error', 'Solicitud no encontrada');
  end if;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_atender_password_reset(uuid, bigint) to anon, authenticated;

commit;
