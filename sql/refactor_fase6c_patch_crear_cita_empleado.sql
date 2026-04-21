-- FARMAX — Alinear RPC crear_cita (mostrador/POS) con el frontend y con citas.canal / cliente_id / pago_estado.
-- Ejecutar en Supabase SQL Editor si al guardar cita ves: "Could not find the function public.crear_cita(...)".
-- Si el error es consumibles_consulta*.nombre does not exist → ejecutar refactor_fase6c_patch_consumibles_consulta_nombre.sql
-- Idempotente.

begin;

alter table public.citas
  add column if not exists cliente_id bigint references public.clientes(id) on delete set null;

drop function if exists public.crear_cita(uuid, text, text, date, text, text, bigint, text);
drop function if exists public.crear_cita(uuid, text, text, date, text, text, text, bigint);

create or replace function public.crear_cita(
  p_session_token uuid,
  p_nombre        text,
  p_telefono      text,
  p_fecha         date,
  p_hora          text,
  p_motivo        text default null,
  p_canal         text default 'mostrador',
  p_paciente_id   bigint default null,
  p_medico_id     bigint default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_cita_id bigint;
  v_canal text;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_nombre is null or length(trim(p_nombre))=0 then raise exception 'Nombre requerido'; end if;
  if p_telefono is null or length(trim(p_telefono))=0 then raise exception 'Teléfono requerido'; end if;
  if p_fecha is null then raise exception 'Fecha requerida'; end if;

  v_canal := lower(trim(coalesce(p_canal, 'mostrador')));
  if v_canal not in ('web', 'mostrador', 'pos') then
    v_canal := 'mostrador';
  end if;

  insert into public.citas (
    nombre, telefono, fecha, hora, motivo, medico_id, notas, estado,
    canal, cliente_id, pago_estado
  )
  values (
    trim(p_nombre), trim(p_telefono), p_fecha, p_hora, p_motivo, p_medico_id, p_notas, 'agendada',
    v_canal, p_paciente_id, 'pendiente'
  )
  returning id into v_cita_id;

  return jsonb_build_object('success', true, 'cita_id', v_cita_id);
end;
$$;

grant execute on function public.crear_cita(uuid, text, text, date, text, text, text, bigint, bigint, text) to anon, authenticated;

commit;
