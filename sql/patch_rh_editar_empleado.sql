-- FarmaCapital — RH: alta sin chocar con otro perfil, y edición de ficha.
-- El error "empleados_usuario_id_uidx" salía porque al registrar a Erika con
-- el mismo teléfono que Mary, se intentaba colgar las dos fichas del mismo
-- usuarios.id. Un perfil de acceso = un empleado ligado, no al revés.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run.

begin;

create or replace function public.fn_sync_turno_caja(
  p_usuario_id  bigint,
  p_empleado_id bigint,
  p_turno       text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_turno  text;
  v_uid    bigint;
  v_eid    bigint;
  v_linked bigint;
begin
  v_turno := nullif(lower(trim(coalesce(p_turno, ''))), '');
  if v_turno is not null and v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido: %', p_turno;
  end if;

  v_uid := p_usuario_id;
  v_eid := p_empleado_id;
  v_linked := null;

  if v_eid is not null then
    select e.usuario_id into v_linked from public.empleados e where e.id = v_eid;
  end if;

  if v_uid is null then
    v_uid := v_linked;
  end if;

  -- Auto-vínculo sólo si el usuario todavía no está tomado por otra ficha.
  if v_uid is null and v_eid is not null then
    select u.id into v_uid
    from public.empleados e
    join public.usuarios u
      on u.eliminado_at is null
     and public.fn_tel_empleado(e.telefono) is not null
     and public.fn_tel_empleado(e.telefono) = public.fn_tel_empleado(u.telefono)
    where e.id = v_eid
      and not exists (
        select 1 from public.empleados x
         where x.usuario_id = u.id
      )
    limit 1;
  end if;

  if v_eid is null and v_uid is not null then
    select e.id into v_eid
    from public.empleados e
    where e.usuario_id = v_uid
    limit 1;
    if v_eid is null then
      select e.id into v_eid
      from public.empleados e
      where e.usuario_id is null
        and public.fn_tel_empleado(e.telefono) is not null
        and public.fn_tel_empleado(e.telefono) = (
          select public.fn_tel_empleado(u.telefono) from public.usuarios u where u.id = v_uid
        )
      limit 1;
    end if;
  end if;

  if v_uid is not null and (
       p_usuario_id is not null
    or v_linked is not null
    or (v_eid is not null and v_uid is not null)
  ) then
    -- No reasignar el turno de un perfil ajeno: sólo si esta ficha ya está
    -- ligada o acabamos de encontrarla libre.
    if p_usuario_id is not null
       or v_linked is not null
       or not exists (
            select 1 from public.empleados x
             where x.usuario_id = v_uid and (v_eid is null or x.id <> v_eid)
          )
    then
      update public.usuarios
         set turno = v_turno
       where id = v_uid
         and eliminado_at is null;
    end if;
  end if;

  if v_eid is not null then
    update public.empleados
       set turno = coalesce(v_turno, turno)
     where id = v_eid;

    if v_uid is not null
       and not exists (
         select 1 from public.empleados x
          where x.usuario_id = v_uid and x.id <> v_eid
       )
    then
      update public.empleados
         set usuario_id = coalesce(usuario_id, v_uid)
       where id = v_eid;
    end if;
  end if;
end;
$$;


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

  perform public.fn_sync_turno_caja(null, p_empleado_id, v_turno);

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
