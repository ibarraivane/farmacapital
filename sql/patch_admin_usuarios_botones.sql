-- FarmaCapital — Gestión de Usuarios completa (un solo script).
-- Cubre: listar, crear con correo O teléfono, editar, módulos, activar,
-- reset de contraseña (sin cerrar TU sesión), borrar, y login por teléfono.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
-- Sustituye a sql/patch_admin_eliminar_usuario_fk.sql.

begin;

alter table public.usuarios
  alter column telefono drop not null;

alter table public.usuarios
  add column if not exists eliminado_at timestamptz;

create index if not exists idx_usuarios_eliminado_at
  on public.usuarios (eliminado_at)
  where eliminado_at is not null;

-- Teléfono de empleado: 52 + 10 dígitos (igual que el frontend).
create or replace function public.fn_tel_empleado(p text)
returns text
language sql
immutable
as $$
  select case
    when p is null or length(regexp_replace(p, '\D', '', 'g')) < 10 then null
    else '52' || right(regexp_replace(p, '\D', '', 'g'), 10)
  end;
$$;

do $$
declare
  r record;
begin
  for r in
    select n.nspname as esquema, t.relname as tabla, c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    join pg_class rt on rt.oid = c.confrelid
    join pg_namespace rn on rn.oid = rt.relnamespace
    where c.contype = 'f'
      and n.nspname = 'public'
      and t.relname in ('audit_log', 'audit_log_detallado')
      and rn.nspname = 'public'
      and rt.relname = 'usuarios'
  loop
    execute format('alter table %I.%I drop constraint if exists %I', r.esquema, r.tabla, r.conname);
  end loop;
end $$;


-- ── Crear: el panel envía rol 'vendedor' (antes se rechazaba) ───────────────
create or replace function public.admin_crear_usuario(
  p_session_token uuid,
  p_nombre        text,
  p_password      text,
  p_rol           text,
  p_email         text default null,
  p_telefono      text default null,
  p_modulos_custom jsonb default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_new_id     bigint;
  v_salt       text;
  v_hash       text;
  v_rol        text;
  v_email      text;
  v_tel        text;
  v_user       jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);
  v_rol := lower(trim(coalesce(p_rol, '')));
  if v_rol = 'empleado' then v_rol := 'vendedor'; end if;
  if v_rol = 'consultorio' then v_rol := 'doctora'; end if;

  if p_nombre is null or length(trim(p_nombre)) = 0 then
    raise exception 'Nombre requerido';
  end if;
  if p_password is null or length(p_password) < 6 then
    raise exception 'Password mínimo 6 caracteres';
  end if;
  if v_rol not in ('admin', 'vendedor', 'doctora', 'gerente') then
    raise exception 'Rol inválido: %', p_rol;
  end if;

  v_email := nullif(lower(trim(coalesce(p_email, ''))), '');
  v_tel := public.fn_tel_empleado(p_telefono);

  if v_email is null and v_tel is null then
    raise exception 'Indica correo o teléfono para que pueda iniciar sesión';
  end if;

  if v_email is not null then
    if exists (
      select 1 from public.usuarios
      where lower(email) = v_email and eliminado_at is null
    ) then
      raise exception 'Ya existe un usuario con ese email';
    end if;
  end if;

  if v_tel is not null then
    if exists (
      select 1 from public.usuarios
      where public.fn_tel_empleado(telefono) = v_tel
        and eliminado_at is null
    ) then
      raise exception 'Ya existe un usuario con ese teléfono';
    end if;
  end if;

  v_salt := public.fn_generar_salt();
  v_hash := public.fn_hash_empleado(p_password, v_salt);

  insert into public.usuarios (nombre, email, telefono, password_hash, salt, rol, activo, modulos_custom, notas)
  values (
    trim(p_nombre),
    v_email,
    v_tel,
    v_hash, v_salt, v_rol, true, p_modulos_custom, p_notas
  )
  returning id into v_new_id;

  begin
    insert into public.perfiles (usuario_id, nombre, telefono)
    values (v_new_id, trim(p_nombre), v_tel)
    on conflict (usuario_id) do update
      set nombre = excluded.nombre, telefono = excluded.telefono;
  exception when others then
    null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_usuario', 'usuarios', v_new_id::text,
      jsonb_build_object('rol', v_rol, 'email', p_email)
    );
  exception when others then null;
  end;

  select jsonb_build_object(
    'id', u.id, 'nombre', u.nombre, 'email', u.email, 'telefono', u.telefono,
    'rol', u.rol, 'notas', u.notas, 'activo', u.activo, 'modulos_custom', u.modulos_custom
  ) into v_user
  from public.usuarios u where u.id = v_new_id;

  return jsonb_build_object('success', true, 'user', v_user, 'usuario', v_user);
end;
$$;


-- ── Activar / desactivar ────────────────────────────────────────────────────
create or replace function public.admin_toggle_usuario(
  p_session_token uuid,
  p_target_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nuevo    boolean;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if v_actor_id = p_target_id then
    raise exception 'No puedes desactivarte a ti mismo';
  end if;

  update public.usuarios
     set activo = not coalesce(activo, false)
   where id = p_target_id
     and eliminado_at is null
  returning activo into v_nuevo;

  if v_nuevo is null then
    raise exception 'Usuario no encontrado';
  end if;

  if v_nuevo = false then
    update public.sesiones set revoked_at = now()
     where usuario_id = p_target_id
       and revoked_at is null;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      case when v_nuevo then 'activar_usuario' else 'desactivar_usuario' end,
      'usuarios', p_target_id::text,
      jsonb_build_object('activo', v_nuevo)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'activo', v_nuevo);
end;
$$;


-- ── Reset contraseña: no cierra la sesión de quien lo ejecuta ───────────────
create or replace function public.admin_reset_password(
  p_session_token uuid,
  p_target_id     bigint,
  p_new_password  text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_salt     text;
  v_hash     text;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_new_password is null or length(p_new_password) < 6 then
    raise exception 'Password mínimo 6 caracteres';
  end if;

  v_salt := public.fn_generar_salt();
  v_hash := public.fn_hash_empleado(p_new_password, v_salt);

  update public.usuarios
     set password_hash = v_hash, salt = v_salt
   where id = p_target_id
     and eliminado_at is null;

  if not found then
    raise exception 'Usuario no encontrado';
  end if;

  update public.sesiones
     set revoked_at = now()
   where usuario_id = p_target_id
     and revoked_at is null
     and token is distinct from p_session_token;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'reset_password', 'usuarios', p_target_id::text, '{}'::jsonb
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;


-- ── Borrar ──────────────────────────────────────────────────────────────────
create or replace function public.admin_eliminar_usuario(
  p_session_token uuid,
  p_target_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_rol      text;
  v_admins   int;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if v_actor_id = p_target_id then
    raise exception 'No puedes eliminarte a ti mismo';
  end if;

  select u.nombre, u.rol
    into v_nombre, v_rol
  from public.usuarios u
  where u.id = p_target_id
    and u.eliminado_at is null;

  if v_nombre is null then
    raise exception 'Usuario no encontrado';
  end if;

  if v_rol = 'admin' then
    select count(*)::int into v_admins
    from public.usuarios
    where rol = 'admin'
      and coalesce(activo, false)
      and eliminado_at is null
      and id <> p_target_id;
    if v_admins < 1 then
      raise exception 'No puedes eliminar al último administrador';
    end if;
  end if;

  update public.sesiones
     set revoked_at = now()
   where usuario_id = p_target_id
     and revoked_at is null
     and token is distinct from p_session_token;

  begin
    delete from public.perfiles where usuario_id = p_target_id;
  exception when others then
    null;
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'eliminar_usuario',
      'usuarios',
      p_target_id::text,
      jsonb_build_object('nombre_eliminado', v_nombre, 'rol', v_rol)
    );
  exception when others then
    null;
  end;

  begin
    delete from public.usuarios where id = p_target_id;
    return jsonb_build_object('success', true, 'modo', 'hard');
  exception
    when foreign_key_violation then
      null;
  end;

  perform set_config('app.audit_bypass', 'true', true);
  begin
    update public.audit_log set usuario_id = null where usuario_id = p_target_id;
  exception when others then null;
  end;
  begin
    update public.audit_log_detallado set usuario_id = null where usuario_id = p_target_id;
  exception when others then null;
  end;
  begin
    update public.audit_log_detallado set actor_id = null where actor_id = p_target_id;
  exception when others then null;
  end;

  begin
    delete from public.usuarios where id = p_target_id;
    return jsonb_build_object('success', true, 'modo', 'hard');
  exception
    when foreign_key_violation then
      update public.usuarios
         set activo = false,
             eliminado_at = now()
       where id = p_target_id;
      return jsonb_build_object(
        'success', true,
        'modo', 'soft',
        'mensaje', 'El usuario tenía historial (ventas o caja). Se ocultó del listado y se desactivó.'
      );
  end;
end;
$$;

grant execute on function public.admin_crear_usuario(uuid, text, text, text, text, text, jsonb, text) to anon, authenticated;
grant execute on function public.admin_toggle_usuario(uuid, bigint) to anon, authenticated;
grant execute on function public.admin_reset_password(uuid, bigint, text) to anon, authenticated;
grant execute on function public.admin_eliminar_usuario(uuid, bigint) to anon, authenticated;


-- ── Editar: correo o teléfono (al menos uno) ────────────────────────────────
create or replace function public.admin_actualizar_usuario_datos(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_nombre        text,
  p_email         text,
  p_telefono      text,
  p_rol           text,
  p_notas         text,
  p_activo        boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
  v_email text;
  v_tel   text;
  v_rol   text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_usuario_id is null then
    return jsonb_build_object('success', false, 'error', 'Usuario requerido');
  end if;
  if coalesce(trim(p_nombre), '') = '' then
    return jsonb_build_object('success', false, 'error', 'Nombre obligatorio');
  end if;

  v_email := nullif(lower(trim(coalesce(p_email, ''))), '');
  v_tel := public.fn_tel_empleado(p_telefono);
  if v_email is null and v_tel is null then
    return jsonb_build_object('success', false, 'error', 'Indica correo o teléfono de acceso');
  end if;

  v_rol := lower(trim(coalesce(p_rol, '')));
  if v_rol = 'empleado' then v_rol := 'vendedor'; end if;
  if v_rol = 'consultorio' then v_rol := 'doctora'; end if;
  if v_rol <> '' and v_rol not in ('admin', 'vendedor', 'doctora', 'gerente') then
    return jsonb_build_object('success', false, 'error', 'Rol inválido');
  end if;

  if v_email is not null and exists (
    select 1 from public.usuarios
    where lower(email) = v_email and id <> p_usuario_id and eliminado_at is null
  ) then
    return jsonb_build_object('success', false, 'error', 'Ese correo ya está registrado');
  end if;
  if v_tel is not null and exists (
    select 1 from public.usuarios
    where public.fn_tel_empleado(telefono) = v_tel and id <> p_usuario_id and eliminado_at is null
  ) then
    return jsonb_build_object('success', false, 'error', 'Ese teléfono ya está registrado');
  end if;

  update public.usuarios
     set nombre   = trim(p_nombre),
         email    = v_email,
         telefono = v_tel,
         rol      = case when v_rol = '' then rol else v_rol end,
         notas    = nullif(trim(coalesce(p_notas, '')), ''),
         activo   = coalesce(p_activo, true)
   where id = p_usuario_id
     and eliminado_at is null;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Usuario no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor, (select nombre from public.usuarios where id = v_actor),
            'editar_usuario', 'usuarios', p_usuario_id::text, '{}'::jsonb);
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'user', (
      select jsonb_build_object(
        'id', u.id, 'nombre', u.nombre, 'email', u.email, 'telefono', u.telefono,
        'rol', u.rol, 'notas', u.notas, 'activo', u.activo, 'modulos_custom', u.modulos_custom
      )
      from public.usuarios u where u.id = p_usuario_id
    )
  );
end;
$$;

grant execute on function public.admin_actualizar_usuario_datos(uuid, bigint, text, text, text, text, text, boolean)
  to anon, authenticated;


create or replace function public.admin_set_usuario_modulos_custom(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_modulos_custom jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_n     int;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_usuario_id is null then
    return jsonb_build_object('success', false, 'error', 'Usuario requerido');
  end if;

  update public.usuarios
     set modulos_custom = p_modulos_custom
   where id = p_usuario_id
     and eliminado_at is null;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Usuario no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor, (select nombre from public.usuarios where id = v_actor),
            'modulos_custom', 'usuarios', p_usuario_id::text,
            coalesce(jsonb_build_object('payload', p_modulos_custom), '{}'::jsonb));
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_set_usuario_modulos_custom(uuid, bigint, jsonb)
  to anon, authenticated;

commit;


-- Listado con los campos que usa el panel. DROP porque cambia el RETURNS.
begin;

drop function if exists public.admin_listar_usuarios(uuid);

create function public.admin_listar_usuarios(
  p_session_token uuid
)
returns table (
  id             integer,
  nombre         text,
  email          text,
  telefono       text,
  rol            text,
  notas          text,
  activo         boolean,
  modulos_custom jsonb,
  created_at     timestamptz,
  updated_at     timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);

  return query
  select
    u.id,
    u.nombre,
    u.email,
    u.telefono,
    u.rol,
    u.notas,
    coalesce(u.activo, false),
    u.modulos_custom,
    u.created_at::timestamptz,
    u.created_at::timestamptz
  from public.usuarios u
  where u.eliminado_at is null
  order by u.nombre;
end;
$$;

grant execute on function public.admin_listar_usuarios(uuid) to anon, authenticated;

commit;


-- Login de empleado: correo o teléfono (10 dígitos, con o sin 52).
begin;

create or replace function public.login_empleado(
  p_identificador text,
  p_password      text,
  p_ip            text default null,
  p_user_agent    text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_usuario record;
  v_hash    text;
  v_token   uuid;
  v_id      text;
  v_tel     text;
begin
  if p_identificador is null or p_password is null
     or length(trim(p_identificador)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  v_id := trim(p_identificador);
  v_tel := public.fn_tel_empleado(v_id);

  select u.* into v_usuario
  from public.usuarios u
  where u.activo = true
    and u.eliminado_at is null
    and (
      (u.email is not null and lower(u.email) = lower(v_id))
      or (v_tel is not null and public.fn_tel_empleado(u.telefono) = v_tel)
      or (u.telefono is not null and u.telefono = v_id)
    )
  limit 1;

  if v_usuario.id is null then
    return jsonb_build_object('success', false, 'error', 'Credenciales inválidas');
  end if;

  v_hash := public.fn_hash_empleado(p_password, v_usuario.salt);

  if v_hash <> v_usuario.password_hash then
    return jsonb_build_object('success', false, 'error', 'Credenciales inválidas');
  end if;

  delete from public.sesiones
  where usuario_id = v_usuario.id
    and (expires_at < now() or revoked_at is not null);

  insert into public.sesiones (usuario_id, ip, user_agent)
  values (v_usuario.id, p_ip, p_user_agent)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token',   v_token,
    'usuario', jsonb_build_object(
      'id',             v_usuario.id,
      'nombre',         v_usuario.nombre,
      'email',          v_usuario.email,
      'telefono',       v_usuario.telefono,
      'rol',            v_usuario.rol,
      'modulos_custom', v_usuario.modulos_custom
    )
  );
end;
$$;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;

commit;
