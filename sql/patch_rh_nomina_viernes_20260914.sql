-- RH: la ficha guarda salario semanal (pago los viernes).
-- Idempotente. Si aún no corriste el de asistencia/SPEI:
--   sql/patch_rh_pago_semanal_20260822.sql
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run.

begin;

alter table public.empleados
  add column if not exists salario_semanal numeric(12,2) not null default 0;

comment on column public.empleados.salario_semanal is
  'Pago de una semana completa sábado–viernes (se deposita el viernes). Diario = este monto / 7. No define horario ni permiso de caja.';


drop function if exists public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric);
drop function if exists public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric, numeric);

create or replace function public.admin_actualizar_empleado(
  p_session_token      uuid,
  p_empleado_id        bigint,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0,
  p_salario_semanal    numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_turno text;
  v_tel   text;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;
  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  v_turno := lower(trim(coalesce(p_turno, 'matutino')));
  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_tel := public.fn_tel_empleado(p_telefono);

  update public.empleados
     set nombre = trim(p_nombre),
         telefono = v_tel,
         rol = coalesce(nullif(trim(p_rol), ''), rol),
         turno = v_turno,
         salario_quincenal = coalesce(p_salario_quincenal, salario_quincenal),
         salario_semanal = coalesce(p_salario_semanal, salario_semanal)
   where id = p_empleado_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    raise exception 'Empleado no encontrado';
  end if;

  begin
    perform public.fn_sync_turno_caja(null, p_empleado_id, v_turno);
  exception when others then null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_empleado', 'empleados', p_empleado_id::text,
      jsonb_build_object('nombre', p_nombre, 'turno', v_turno, 'salario_semanal', p_salario_semanal)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', p_empleado_id);
end;
$$;

grant execute on function public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric, numeric)
  to anon, authenticated;


drop function if exists public.admin_crear_empleado(uuid, text, text, text, text, numeric);
drop function if exists public.admin_crear_empleado(uuid, text, text, text, text, numeric, numeric);

create or replace function public.admin_crear_empleado(
  p_session_token      uuid,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0,
  p_salario_semanal    numeric default 0
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_new_id bigint;
  v_turno text;
  v_tel text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  v_turno := lower(trim(coalesce(p_turno, 'matutino')));
  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_tel := public.fn_tel_empleado(p_telefono);

  insert into public.empleados(
    nombre, telefono, rol, turno, salario_quincenal, salario_semanal, estado
  ) values (
    trim(p_nombre), v_tel,
    p_rol, v_turno,
    coalesce(p_salario_quincenal, 0),
    coalesce(p_salario_semanal, 0),
    true
  )
  returning id into v_new_id;

  begin
    perform public.fn_sync_turno_caja(null, v_new_id, v_turno);
  exception when others then null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'crear_empleado', 'empleados', v_new_id::text,
      jsonb_build_object('nombre', p_nombre, 'rol', p_rol, 'turno', v_turno)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', v_new_id);
end;
$$;

grant execute on function public.admin_crear_empleado(uuid, text, text, text, text, numeric, numeric)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
