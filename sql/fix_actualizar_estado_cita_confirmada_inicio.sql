-- Idempotente: al pasar a en_consulta, fija confirmada_inicio_at para duración en doctora_completar_consulta.
-- Ejecutar en Supabase SQL si aún no está aplicado (el front también intenta actualizar la columna).

begin;

create or replace function public.actualizar_estado_cita(
  p_session_token uuid,
  p_cita_id       bigint,
  p_estado        text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_valid text[] := array['agendada','en_consulta','completada','cancelada','no_asistio'];
begin
  perform public.fn_require_empleado(p_session_token);
  if not (p_estado = any(v_valid)) then
    raise exception 'Estado inválido: %', p_estado;
  end if;

  if p_estado = 'en_consulta' then
    update public.citas
    set
      estado = p_estado,
      confirmada_inicio_at = coalesce(confirmada_inicio_at, now())
    where id = p_cita_id;
  else
    update public.citas set estado = p_estado where id = p_cita_id;
  end if;

  if not found then raise exception 'Cita % no encontrada', p_cita_id; end if;
  return jsonb_build_object('success', true);
end;
$$;

commit;
