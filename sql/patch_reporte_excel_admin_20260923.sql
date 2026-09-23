-- ============================================================================
-- Excel / reporte mensual: el admin real recibía ACCESO_DENEGADO
--
-- Causa: fn_rep_es_admin leía un GUC y, si CUALQUIER cosa fallaba
-- (fn_validar_token_empleado, columna, etc.), tragaba la excepción y
-- devolvía false → "solo el administrador". El resto del admin ya usa
-- fn_require_admin(p_session_token), que sí funciona.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- ============================================================================

begin;

create or replace function public.fn_rep_es_admin()
returns boolean
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_tok text;
begin
  v_tok := nullif(current_setting('farmacapital.session_token', true), '');
  if v_tok is null then
    return false;
  end if;
  begin
    perform public.fn_require_admin(v_tok::uuid);
    return true;
  exception
    when sqlstate '28000' then -- sesión inválida / expirada
      return false;
    when sqlstate '42501' then -- no es admin/gerente
      return false;
  end;
end;
$$;

create or replace function public.fn_rep_exige_admin()
returns void
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
begin
  if not public.fn_rep_es_admin() then
    raise exception 'ACCESO_DENEGADO: este reporte es exclusivo del rol admin'
      using errcode = '42501';
  end if;
end;
$$;

-- El wrapper valida el token directo (mismo camino que el resto del admin)
-- y además setea el GUC por si algún bloque interno lo vuelve a pedir.
create or replace function public.empleado_rpc_reporte_mensual(
  p_session_token uuid,
  p_anio int,
  p_mes int
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  perform set_config('farmacapital.session_token', p_session_token::text, true);
  return public.rpc_reporte_mensual(p_anio, p_mes);
end;
$$;

create or replace function public.empleado_rpc_transacciones_mes(
  p_session_token uuid,
  p_anio int,
  p_mes int,
  p_hoja text,
  p_offset int default 0,
  p_limit int default 5000
)
returns setof jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  perform set_config('farmacapital.session_token', p_session_token::text, true);
  return query
    select * from public.rpc_transacciones_mes(p_anio, p_mes, p_hoja, p_offset, p_limit);
end;
$$;

revoke all on function public.empleado_rpc_reporte_mensual(uuid, int, int) from public;
revoke all on function public.empleado_rpc_transacciones_mes(uuid, int, int, text, int, int) from public;
grant execute on function public.empleado_rpc_reporte_mensual(uuid, int, int) to anon, authenticated;
grant execute on function public.empleado_rpc_transacciones_mes(uuid, int, int, text, int, int) to anon, authenticated;

commit;
