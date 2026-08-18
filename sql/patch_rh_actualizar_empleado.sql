-- FarmaCapital — Editar ficha de empleado ya registrada (RH).
-- Ejecutar en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.admin_actualizar_empleado(
  p_session_token      uuid,
  p_empleado_id        bigint,
  p_nombre             text,
  p_telefono           text default null,
  p_rol                text default 'vendedor',
  p_turno              text default 'matutino',
  p_salario_quincenal  numeric default 0
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
         salario_quincenal = coalesce(p_salario_quincenal, salario_quincenal)
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
      jsonb_build_object('nombre', p_nombre, 'turno', v_turno)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', p_empleado_id);
end;
$$;

grant execute on function public.admin_actualizar_empleado(uuid, bigint, text, text, text, text, numeric)
  to anon, authenticated;

commit;
