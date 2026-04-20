-- ============================================================
-- FARMAX — F6b.1: RPCs de autenticación y cuentas
-- ============================================================
-- Wrappers seguros para operaciones que hoy se hacen con
-- INSERT/UPDATE/DELETE directos al cliente Supabase sobre las
-- tablas usuarios, clientes y password_reset_requests.
--
-- Todas validan un session token emitido por F6a antes de
-- permitir la operación. Las de administración requieren
-- rol 'admin' o 'gerente'.
--
-- Corre DESPUES de refactor_fase6a_tokens.sql.
-- Este SQL es IDEMPOTENTE.
-- ============================================================

begin;

-- ============================================================
-- Helpers internos
-- ============================================================

-- Valida token de empleado y exige rol admin/gerente.
-- Retorna usuario_id o lanza excepción.
create or replace function public.fn_require_admin(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol     text;
begin
  v_user_id := public.fn_validar_token_empleado(p_token);
  if v_user_id is null then
    raise exception 'Sesión inválida o expirada' using errcode = '28000';
  end if;

  select rol into v_rol from public.usuarios where id = v_user_id and activo = true;
  if v_rol is null or v_rol not in ('admin', 'gerente') then
    raise exception 'Requiere rol admin o gerente' using errcode = '42501';
  end if;

  return v_user_id;
end;
$$;

comment on function public.fn_require_admin(uuid) is
  'F6b: valida token + exige rol admin/gerente. Lanza excepción si no cumple.';

-- Valida token de empleado (cualquier rol activo).
create or replace function public.fn_require_empleado(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_activo  boolean;
begin
  v_user_id := public.fn_validar_token_empleado(p_token);
  if v_user_id is null then
    raise exception 'Sesión inválida o expirada' using errcode = '28000';
  end if;

  select activo into v_activo from public.usuarios where id = v_user_id;
  if v_activo is null or v_activo = false then
    raise exception 'Usuario inactivo' using errcode = '42501';
  end if;

  return v_user_id;
end;
$$;

-- Valida token de cliente.
create or replace function public.fn_require_cliente(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente_id bigint;
begin
  v_cliente_id := public.fn_validar_token_cliente(p_token);
  if v_cliente_id is null then
    raise exception 'Sesión de cliente inválida o expirada' using errcode = '28000';
  end if;
  return v_cliente_id;
end;
$$;

revoke all on function public.fn_require_admin(uuid)    from public, anon, authenticated;
revoke all on function public.fn_require_empleado(uuid) from public, anon, authenticated;
revoke all on function public.fn_require_cliente(uuid)  from public, anon, authenticated;

-- Helper para generar salt (16 bytes random, 32 chars hex)
create or replace function public.fn_generar_salt()
returns text
language sql
volatile
as $$
  select encode(gen_random_bytes(16), 'hex');
$$;
revoke all on function public.fn_generar_salt() from public, anon, authenticated;

-- ============================================================
-- 1) admin_crear_usuario
-- ============================================================
-- Hashea password con salt random, inserta usuario, upsert perfil.
-- ============================================================
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
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_nombre is null or length(trim(p_nombre)) = 0 then
    raise exception 'Nombre requerido';
  end if;
  if p_password is null or length(p_password) < 6 then
    raise exception 'Password mínimo 6 caracteres';
  end if;
  if p_rol is null or p_rol not in ('admin','gerente','empleado','consultorio','doctora') then
    raise exception 'Rol inválido: %', p_rol;
  end if;

  -- Email único si se proporciona
  if p_email is not null and length(trim(p_email)) > 0 then
    if exists (select 1 from public.usuarios where lower(email) = lower(trim(p_email))) then
      raise exception 'Ya existe un usuario con ese email';
    end if;
  end if;

  v_salt := public.fn_generar_salt();
  v_hash := public.fn_hash_empleado(p_password, v_salt);

  insert into public.usuarios (nombre, email, telefono, password_hash, salt, rol, activo, modulos_custom, notas)
  values (
    trim(p_nombre),
    nullif(trim(coalesce(p_email, '')), ''),
    nullif(trim(coalesce(p_telefono, '')), ''),
    v_hash, v_salt, p_rol, true, p_modulos_custom, p_notas
  )
  returning id into v_new_id;

  -- Perfil asociado (opcional; la tabla perfiles puede existir con otras cols)
  begin
    insert into public.perfiles (usuario_id, nombre, telefono)
    values (v_new_id, trim(p_nombre), nullif(trim(coalesce(p_telefono, '')), ''))
    on conflict (usuario_id) do update
      set nombre = excluded.nombre, telefono = excluded.telefono;
  exception when others then
    -- Si no existe tabla perfiles o tiene otra estructura, continuar
    null;
  end;

  -- Audit
  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_usuario', 'usuarios', v_new_id::text,
      jsonb_build_object('rol', p_rol, 'email', p_email)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'usuario', jsonb_build_object(
      'id', v_new_id, 'nombre', p_nombre, 'rol', p_rol,
      'email', p_email, 'telefono', p_telefono
    )
  );
end;
$$;

-- ============================================================
-- 2) admin_toggle_usuario
-- ============================================================
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
  returning activo into v_nuevo;

  if v_nuevo is null then
    raise exception 'Usuario no encontrado';
  end if;

  -- Si se desactiva, revocar todas sus sesiones
  if v_nuevo = false then
    update public.sesiones set revoked_at = now()
    where usuario_id = p_target_id and revoked_at is null;
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

-- ============================================================
-- 3) admin_reset_password
-- ============================================================
-- Admin cambia password de otro usuario. También lo usa el
-- usuario para cambiar su propia password (aunque existe flujo
-- dedicado: ver abajo).
-- ============================================================
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
   where id = p_target_id;

  if not found then
    raise exception 'Usuario no encontrado';
  end if;

  -- Invalidar todas las sesiones del target (forzar re-login)
  update public.sesiones set revoked_at = now()
  where usuario_id = p_target_id and revoked_at is null;

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

-- ============================================================
-- 4) admin_eliminar_usuario
-- ============================================================
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
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if v_actor_id = p_target_id then
    raise exception 'No puedes eliminarte a ti mismo';
  end if;

  select nombre into v_nombre from public.usuarios where id = p_target_id;
  if v_nombre is null then
    raise exception 'Usuario no encontrado';
  end if;

  delete from public.usuarios where id = p_target_id;
  -- Sesiones se borran en cascada por FK on delete cascade.

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'eliminar_usuario', 'usuarios', p_target_id::text,
      jsonb_build_object('nombre_eliminado', v_nombre)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 5) solicitar_reset_password
-- ============================================================
-- Pública (anon). Inserta una solicitud en password_reset_requests.
-- Rate-limit: máx 3 solicitudes en 1h por identificador.
-- No revela si el usuario existe (devuelve success siempre).
-- ============================================================
create or replace function public.solicitar_reset_password(
  p_identificador text,  -- email o telefono
  p_ip            text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_recientes int;
begin
  if p_identificador is null or length(trim(p_identificador)) = 0 then
    return jsonb_build_object('success', true);  -- no revelar
  end if;

  select count(*) into v_recientes
  from public.password_reset_requests
  where email_o_telefono = trim(p_identificador)
    and created_at > now() - interval '1 hour';

  if v_recientes >= 3 then
    -- Silencioso: retornamos success pero no insertamos
    return jsonb_build_object('success', true);
  end if;

  insert into public.password_reset_requests (email_o_telefono, ip, estado)
  values (trim(p_identificador), p_ip, 'pendiente');

  return jsonb_build_object('success', true);
exception when undefined_column then
  -- Si la tabla tiene otra estructura, inserta al menos el identificador
  insert into public.password_reset_requests (email_o_telefono)
  values (trim(p_identificador));
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 6) registrar_cliente
-- ============================================================
-- RPC pública para que un visitante cree cuenta en la tienda web.
-- Inmediatamente emite un session token (auto-login).
-- ============================================================
create or replace function public.registrar_cliente(
  p_nombre     text,
  p_telefono   text,
  p_password   text,
  p_email      text default null,
  p_ip         text default null,
  p_user_agent text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_new_id bigint;
  v_hash   text;
  v_token  uuid;
begin
  if p_nombre is null or length(trim(p_nombre)) < 2 then
    return jsonb_build_object('success', false, 'error', 'Nombre requerido');
  end if;
  if p_telefono is null or length(trim(p_telefono)) < 10 then
    return jsonb_build_object('success', false, 'error', 'Teléfono inválido');
  end if;
  if p_password is null or length(p_password) < 6 then
    return jsonb_build_object('success', false, 'error', 'Password mínimo 6 caracteres');
  end if;

  if exists (select 1 from public.clientes where telefono = trim(p_telefono)) then
    return jsonb_build_object('success', false, 'error', 'Ya existe una cuenta con ese teléfono');
  end if;

  v_hash := public.fn_hash_cliente(p_password);

  insert into public.clientes (
    nombre, telefono, email, password_hash,
    puntos, consentimiento_privacidad, fecha_consentimiento, notas
  ) values (
    trim(p_nombre), trim(p_telefono), nullif(trim(coalesce(p_email, '')), ''),
    v_hash, 10, true, now(),
    'Consentimiento LFPDPPP aceptado: ' || to_char(now(), 'YYYY-MM-DD HH24:MI:SS')
  )
  returning id into v_new_id;

  insert into public.sesiones_cliente (cliente_id, ip, user_agent)
  values (v_new_id, p_ip, p_user_agent)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token',   v_token,
    'cliente', jsonb_build_object(
      'id', v_new_id, 'nombre', p_nombre, 'telefono', p_telefono,
      'email', p_email, 'puntos', 10
    )
  );
end;
$$;

-- ============================================================
-- 7) cliente_cambiar_password
-- ============================================================
-- Cliente logueado cambia su propia password.
-- ============================================================
create or replace function public.cliente_cambiar_password(
  p_session_token uuid,
  p_actual        text,
  p_nueva         text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente_id bigint;
  v_hash_actual text;
  v_hash_nuevo  text;
  v_stored      text;
begin
  v_cliente_id := public.fn_require_cliente(p_session_token);

  if p_nueva is null or length(p_nueva) < 6 then
    return jsonb_build_object('success', false, 'error', 'Password mínimo 6 caracteres');
  end if;

  select password_hash into v_stored from public.clientes where id = v_cliente_id;

  v_hash_actual := public.fn_hash_cliente(p_actual);
  if v_hash_actual <> v_stored then
    return jsonb_build_object('success', false, 'error', 'Contraseña actual incorrecta');
  end if;

  v_hash_nuevo := public.fn_hash_cliente(p_nueva);
  update public.clientes set password_hash = v_hash_nuevo where id = v_cliente_id;

  -- Revocar otras sesiones (mantiene la actual)
  update public.sesiones_cliente
     set revoked_at = now()
   where cliente_id = v_cliente_id
     and token <> p_session_token
     and revoked_at is null;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- Grants
-- ============================================================
-- Públicas (sin token): registro cliente, solicitar reset
grant execute on function public.registrar_cliente(text, text, text, text, text, text)      to anon, authenticated;
grant execute on function public.solicitar_reset_password(text, text)                       to anon, authenticated;

-- Requieren token (la función valida)
grant execute on function public.admin_crear_usuario(uuid, text, text, text, text, text, jsonb, text) to anon, authenticated;
grant execute on function public.admin_toggle_usuario(uuid, bigint)                        to anon, authenticated;
grant execute on function public.admin_reset_password(uuid, bigint, text)                  to anon, authenticated;
grant execute on function public.admin_eliminar_usuario(uuid, bigint)                      to anon, authenticated;
grant execute on function public.cliente_cambiar_password(uuid, text, text)                to anon, authenticated;

commit;

-- ============================================================
-- FIN F6b.1
-- ============================================================
-- Siguiente: refactor_fase6b_rpcs_transacciones.sql
-- ============================================================
