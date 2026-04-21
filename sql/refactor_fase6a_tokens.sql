-- ============================================================
-- FARMAX — F6a (1/4): Session tokens + RPCs de login
-- ============================================================
-- Objetivo:
--   Introducir autenticación por session token tanto para
--   empleados (tabla usuarios) como para clientes (tabla clientes).
--
-- Flujo:
--   1. Frontend llama RPC login_empleado / login_cliente con
--      credenciales en claro.
--   2. RPC computa hash en DB (replica fórmula JS existente),
--      compara con password_hash, genera token UUID random,
--      inserta en sesiones / sesiones_cliente y devuelve token.
--   3. Frontend guarda token en sessionStorage.
--   4. RPCs protegidas reciben p_session_token y validan contra
--      la tabla de sesiones (ver F6a 2/4).
--
-- Este SQL es IDEMPOTENTE. Puede correrse varias veces.
-- ============================================================

begin;

-- ============================================================
-- 0) pgcrypto para digest() (Supabase: schema extensions)
-- ============================================================
create extension if not exists pgcrypto with schema extensions;

-- ============================================================
-- 1) Tabla sesiones (empleados)
-- ============================================================
create table if not exists public.sesiones (
  token         uuid        primary key default gen_random_uuid(),
  usuario_id    bigint      not null references public.usuarios(id) on delete cascade,
  created_at    timestamptz not null default now(),
  last_used_at  timestamptz not null default now(),
  expires_at    timestamptz not null default now() + interval '24 hours',
  ip            text,
  user_agent    text,
  revoked_at    timestamptz
);

create index if not exists idx_sesiones_usuario on public.sesiones(usuario_id);
create index if not exists idx_sesiones_expires on public.sesiones(expires_at);

comment on table public.sesiones is
  'F6a: sesiones de empleados. Token validado en cada RPC protegida. Expira 24h.';

-- ============================================================
-- 2) Tabla sesiones_cliente (tienda web)
-- ============================================================
create table if not exists public.sesiones_cliente (
  token         uuid        primary key default gen_random_uuid(),
  cliente_id    bigint      not null references public.clientes(id) on delete cascade,
  created_at    timestamptz not null default now(),
  last_used_at  timestamptz not null default now(),
  expires_at    timestamptz not null default now() + interval '30 days',
  ip            text,
  user_agent    text,
  revoked_at    timestamptz
);

create index if not exists idx_sesiones_cli_cliente on public.sesiones_cliente(cliente_id);
create index if not exists idx_sesiones_cli_expires on public.sesiones_cliente(expires_at);

comment on table public.sesiones_cliente is
  'F6a: sesiones de clientes (tienda web). Expira 30d.';

-- ============================================================
-- 3) Hash helpers (replican fórmula JS exacta)
-- ============================================================
-- Empleados: SHA-256(salt + pwd + length(salt)), fallback "farmax_2026_salt"
create or replace function public.fn_hash_empleado(p_pwd text, p_salt text)
returns text
language sql
immutable
set search_path = public, extensions, pg_temp
as $$
  select encode(
    digest(
      coalesce(nullif(p_salt, ''), 'farmax_2026_salt')
        || p_pwd
        || length(coalesce(nullif(p_salt, ''), 'farmax_2026_salt'))::text,
      'sha256'::text
    ),
    'hex'
  );
$$;

-- Clientes: SHA-256(pwd) puro (tienda web, sin salt)
create or replace function public.fn_hash_cliente(p_pwd text)
returns text
language sql
immutable
set search_path = public, extensions, pg_temp
as $$
  select encode(digest(p_pwd, 'sha256'::text), 'hex');
$$;

revoke all on function public.fn_hash_empleado(text, text) from public, anon, authenticated;
revoke all on function public.fn_hash_cliente(text) from public, anon, authenticated;

-- ============================================================
-- 4) RPC login_empleado
-- ============================================================
-- Args: email o telefono + password plain
-- Returns: jsonb con token + perfil minimo, o error
-- ============================================================
create or replace function public.login_empleado(
  p_identificador text,  -- email o telefono
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
begin
  if p_identificador is null or p_password is null
     or length(trim(p_identificador)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  -- Busca por email o telefono
  select u.* into v_usuario
  from public.usuarios u
  where u.activo = true
    and (lower(u.email) = lower(trim(p_identificador))
         or u.telefono = trim(p_identificador))
  limit 1;

  if v_usuario.id is null then
    return jsonb_build_object('success', false, 'error', 'Credenciales inválidas');
  end if;

  v_hash := public.fn_hash_empleado(p_password, v_usuario.salt);

  if v_hash <> v_usuario.password_hash then
    return jsonb_build_object('success', false, 'error', 'Credenciales inválidas');
  end if;

  -- Limpia sesiones viejas del usuario (opcional: mantiene max 5 activas)
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

comment on function public.login_empleado(text, text, text, text) is
  'F6a: autentica empleado y emite session token. Valida hash SHA-256 con salt.';

-- ============================================================
-- 5) RPC login_cliente (tienda web)
-- ============================================================
create or replace function public.login_cliente(
  p_telefono   text,
  p_password   text,
  p_ip         text default null,
  p_user_agent text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente record;
  v_hash    text;
  v_token   uuid;
begin
  if p_telefono is null or p_password is null
     or length(trim(p_telefono)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  select c.* into v_cliente
  from public.clientes c
  where c.telefono = trim(p_telefono)
  limit 1;

  if v_cliente.id is null then
    return jsonb_build_object('success', false, 'error', 'Teléfono o contraseña incorrectos');
  end if;

  if v_cliente.password_hash is null or length(v_cliente.password_hash) = 0 then
    return jsonb_build_object(
      'success', false,
      'error', 'Tu cuenta necesita una contraseña. Regístrate de nuevo.'
    );
  end if;

  v_hash := public.fn_hash_cliente(p_password);

  if v_hash <> v_cliente.password_hash then
    return jsonb_build_object('success', false, 'error', 'Teléfono o contraseña incorrectos');
  end if;

  delete from public.sesiones_cliente
  where cliente_id = v_cliente.id
    and (expires_at < now() or revoked_at is not null);

  insert into public.sesiones_cliente (cliente_id, ip, user_agent)
  values (v_cliente.id, p_ip, p_user_agent)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token',   v_token,
    'cliente', jsonb_build_object(
      'id',       v_cliente.id,
      'nombre',   v_cliente.nombre,
      'telefono', v_cliente.telefono,
      'email',    v_cliente.email,
      'puntos',   v_cliente.puntos
    )
  );
end;
$$;

comment on function public.login_cliente(text, text, text, text) is
  'F6a: autentica cliente (tienda web) y emite session token.';

-- ============================================================
-- 6) Helpers de validación (usadas por RPCs protegidas en F6b)
-- ============================================================

-- Devuelve usuario_id si el token es válido y no expiró, sino NULL.
-- Además actualiza last_used_at (sliding session opcional).
create or replace function public.fn_validar_token_empleado(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  if p_token is null then return null; end if;

  update public.sesiones
     set last_used_at = now()
   where token = p_token
     and revoked_at is null
     and expires_at > now()
  returning usuario_id into v_user_id;

  return v_user_id;
end;
$$;

create or replace function public.fn_validar_token_cliente(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente_id bigint;
begin
  if p_token is null then return null; end if;

  update public.sesiones_cliente
     set last_used_at = now()
   where token = p_token
     and revoked_at is null
     and expires_at > now()
  returning cliente_id into v_cliente_id;

  return v_cliente_id;
end;
$$;

-- ============================================================
-- 7) RPCs de logout
-- ============================================================
create or replace function public.logout_empleado(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if p_token is null then
    return jsonb_build_object('success', false);
  end if;
  update public.sesiones set revoked_at = now() where token = p_token;
  return jsonb_build_object('success', true);
end;
$$;

create or replace function public.logout_cliente(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if p_token is null then
    return jsonb_build_object('success', false);
  end if;
  update public.sesiones_cliente set revoked_at = now() where token = p_token;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 8) Permisos: RPCs accesibles desde anon/authenticated; tablas NO
-- ============================================================
-- Tablas de sesiones: solo service_role (via SECURITY DEFINER funcs)
revoke all on public.sesiones         from public, anon, authenticated;
revoke all on public.sesiones_cliente from public, anon, authenticated;

-- Habilitar RLS en tablas de sesiones (deny all → solo service role accede)
alter table public.sesiones         enable row level security;
alter table public.sesiones_cliente enable row level security;

drop policy if exists sesiones_deny_all         on public.sesiones;
drop policy if exists sesiones_cliente_deny_all on public.sesiones_cliente;

create policy sesiones_deny_all
  on public.sesiones
  for all
  to anon, authenticated
  using (false) with check (false);

create policy sesiones_cliente_deny_all
  on public.sesiones_cliente
  for all
  to anon, authenticated
  using (false) with check (false);

-- RPCs públicas (callables desde el JS con anon key)
grant execute on function public.login_empleado(text, text, text, text)   to anon, authenticated;
grant execute on function public.login_cliente(text, text, text, text)    to anon, authenticated;
grant execute on function public.logout_empleado(uuid)                    to anon, authenticated;
grant execute on function public.logout_cliente(uuid)                     to anon, authenticated;

-- Helpers de validación: solo service_role / funciones internas
revoke all on function public.fn_validar_token_empleado(uuid) from public, anon, authenticated;
revoke all on function public.fn_validar_token_cliente(uuid)  from public, anon, authenticated;

commit;

-- ============================================================
-- FIN F6a (1/4)
-- ============================================================
-- Verificación rápida:
--   select public.login_empleado('email@ejemplo.com', 'mi_password');
--   -> debe retornar { success: true, token: '...', usuario: {...} }
-- ============================================================
