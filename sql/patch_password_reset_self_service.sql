-- FarmaCapital — Reset de contraseña tienda: búsqueda flexible + self-service + reglas
-- Ejecutar en Supabase SQL Editor.

begin;

-- ── Normalización teléfono MX (últimos 10 dígitos) ───────────────────────────
create or replace function public.fn_digits_mx(p_text text)
returns text
language sql
immutable
as $$
  select case
    when p_text is null then ''
    else right(regexp_replace(p_text, '\D', '', 'g'), 10)
  end;
$$;

-- ── Validación contraseña tienda ─────────────────────────────────────────────
create or replace function public.fn_validar_password_tienda(p_password text)
returns jsonb
language plpgsql
immutable
as $$
begin
  if p_password is null or length(p_password) < 8 then
    return jsonb_build_object(
      'success', false,
      'error', 'La contraseña debe tener al menos 8 caracteres'
    );
  end if;
  if p_password !~ '[A-Za-zÁÉÍÓÚáéíóúÑñ]' then
    return jsonb_build_object('success', false, 'error', 'Incluye al menos una letra');
  end if;
  if p_password !~ '\d' then
    return jsonb_build_object('success', false, 'error', 'Incluye al menos un número');
  end if;
  if p_password ~ '\s' then
    return jsonb_build_object('success', false, 'error', 'No uses espacios en la contraseña');
  end if;
  return jsonb_build_object('success', true);
end;
$$;

-- ── Resolver cliente por teléfono (10 dígitos) o correo ──────────────────────
create or replace function public.fn_resolver_cliente_id_por_identificador(p_identificador text)
returns bigint
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_key   text := trim(coalesce(p_identificador, ''));
  v_digits text;
  v_id    bigint;
begin
  if v_key = '' then
    return null;
  end if;

  if position('@' in v_key) > 0 then
    select c.id into v_id
    from public.clientes c
    where c.email is not null
      and lower(trim(c.email)) = lower(v_key)
    limit 1;
    return v_id;
  end if;

  v_digits := public.fn_digits_mx(v_key);
  if length(v_digits) < 10 then
    return null;
  end if;

  select c.id into v_id
  from public.clientes c
  where c.telefono is not null
    and (
      trim(c.telefono) = v_key
      or public.fn_digits_mx(c.telefono) = v_digits
    )
  order by c.id
  limit 1;

  return v_id;
end;
$$;

revoke all on function public.fn_resolver_cliente_id_por_identificador(text) from public, anon, authenticated;

-- ── Admin: buscar cliente por identificador (tel normalizado o email) ────────
create or replace function public.admin_resolver_cliente_por_identificador(
  p_session_token uuid,
  p_identificador text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_id bigint;
  v_json jsonb;
begin
  perform public.fn_require_empleado(p_session_token);

  v_id := public.fn_resolver_cliente_id_por_identificador(p_identificador);
  if v_id is null then
    return null;
  end if;

  select jsonb_build_object(
    'id', c.id,
    'nombre', c.nombre,
    'telefono', c.telefono,
    'email', c.email
  ) into v_json
  from public.clientes c
  where c.id = v_id;

  return v_json;
end;
$$;

grant execute on function public.admin_resolver_cliente_por_identificador(uuid, text) to anon, authenticated;

create or replace function public.admin_obtener_cliente_por_telefono(
  p_session_token uuid,
  p_telefono      text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_empleado(p_session_token);
  return public.admin_resolver_cliente_por_identificador(p_session_token, p_telefono);
end;
$$;

-- ── Tokens de reset (self-service) ───────────────────────────────────────────
create table if not exists public.cliente_password_reset_tokens (
  id          uuid primary key default gen_random_uuid(),
  token       uuid not null unique default gen_random_uuid(),
  cliente_id  bigint not null references public.clientes(id) on delete cascade,
  request_id  uuid null,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default (now() + interval '2 hours'),
  used_at     timestamptz null
);

create index if not exists cliente_password_reset_tokens_cliente_idx
  on public.cliente_password_reset_tokens (cliente_id, created_at desc);

alter table public.cliente_password_reset_tokens enable row level security;
revoke all on table public.cliente_password_reset_tokens from anon, authenticated;

-- ── Servidor: iniciar reset (API con service role) ───────────────────────────
create or replace function public.service_iniciar_reset_password(
  p_identificador text,
  p_ip            text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_key      text := trim(coalesce(p_identificador, ''));
  v_cliente  bigint;
  v_token    uuid;
  v_tel      text;
  v_req_id   uuid;
  v_recientes int;
begin
  if v_key = '' then
    return jsonb_build_object('success', true, 'found', false);
  end if;

  -- Cola admin (siempre genérico al cliente)
  perform public.solicitar_reset_password(v_key, p_ip);

  select count(*) into v_recientes
  from public.cliente_password_reset_tokens t
  join public.clientes c on c.id = t.cliente_id
  where t.created_at > now() - interval '15 minutes'
    and t.used_at is null
    and (
      (position('@' in v_key) > 0 and lower(trim(c.email)) = lower(v_key))
      or (position('@' in v_key) = 0 and public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_key))
    );

  if v_recientes >= 3 then
    return jsonb_build_object('success', true, 'found', false, 'rate_limited', true);
  end if;

  v_cliente := public.fn_resolver_cliente_id_por_identificador(v_key);
  if v_cliente is null then
    return jsonb_build_object('success', true, 'found', false);
  end if;

  select c.telefono into v_tel from public.clientes c where c.id = v_cliente;

  update public.cliente_password_reset_tokens
     set used_at = now()
   where cliente_id = v_cliente
     and used_at is null
     and expires_at > now();

  insert into public.cliente_password_reset_tokens (cliente_id)
  values (v_cliente)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'found', true,
    'token', v_token,
    'telefono', v_tel,
    'cliente_id', v_cliente
  );
end;
$$;

revoke all on function public.service_iniciar_reset_password(text, text) from public, anon, authenticated;
grant execute on function public.service_iniciar_reset_password(text, text) to service_role;

-- ── Validar token (página pública de reset) ──────────────────────────────────
create or replace function public.cliente_validar_reset_token(p_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row record;
begin
  if p_token is null then
    return jsonb_build_object('valid', false, 'error', 'Token inválido');
  end if;

  select t.*, c.nombre
    into v_row
  from public.cliente_password_reset_tokens t
  join public.clientes c on c.id = t.cliente_id
  where t.token = p_token
  limit 1;

  if v_row.token is null then
    return jsonb_build_object('valid', false, 'error', 'Enlace no válido o expirado');
  end if;
  if v_row.used_at is not null then
    return jsonb_build_object('valid', false, 'error', 'Este enlace ya fue utilizado');
  end if;
  if v_row.expires_at < now() then
    return jsonb_build_object('valid', false, 'error', 'El enlace expiró. Solicita uno nuevo.');
  end if;

  return jsonb_build_object(
    'valid', true,
    'nombre', split_part(trim(coalesce(v_row.nombre, 'Cliente')), ' ', 1)
  );
end;
$$;

grant execute on function public.cliente_validar_reset_token(uuid) to anon, authenticated;

-- ── Completar reset con token ────────────────────────────────────────────────
create or replace function public.cliente_completar_reset_password(
  p_token   uuid,
  p_password text,
  p_confirm  text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row record;
  v_val jsonb;
begin
  if p_password is distinct from p_confirm then
    return jsonb_build_object('success', false, 'error', 'Las contraseñas no coinciden');
  end if;

  v_val := public.fn_validar_password_tienda(p_password);
  if coalesce((v_val->>'success')::boolean, false) is not true then
    return jsonb_build_object('success', false, 'error', coalesce(v_val->>'error', 'Contraseña inválida'));
  end if;

  select t.* into v_row
  from public.cliente_password_reset_tokens t
  where t.token = p_token
  limit 1;

  if v_row.token is null or v_row.used_at is not null or v_row.expires_at < now() then
    return jsonb_build_object('success', false, 'error', 'Enlace no válido o expirado');
  end if;

  update public.clientes
     set password_hash = public.fn_hash_cliente(p_password)
   where id = v_row.cliente_id;

  update public.cliente_password_reset_tokens
     set used_at = now()
   where id = v_row.id;

  update public.sesiones_cliente
     set revoked_at = now()
   where cliente_id = v_row.cliente_id
     and revoked_at is null;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.cliente_completar_reset_password(uuid, text, text) to anon, authenticated;

-- ── Admin: generar link para enviar manualmente ──────────────────────────────
create or replace function public.admin_generar_link_reset_password(
  p_session_token uuid,
  p_request_id    uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_req record;
  v_cliente bigint;
  v_token uuid;
  v_tel text;
begin
  perform public.fn_require_admin(p_session_token);

  select * into v_req
  from public.password_reset_requests
  where id = p_request_id
  limit 1;

  if v_req.id is null then
    return jsonb_build_object('success', false, 'error', 'Solicitud no encontrada');
  end if;

  v_cliente := public.fn_resolver_cliente_id_por_identificador(v_req.email_o_telefono);
  if v_cliente is null then
    return jsonb_build_object(
      'success', false,
      'error', 'No hay cuenta de tienda con ese teléfono o correo. Verifica el dato o crea la cuenta en Clientes.'
    );
  end if;

  select telefono into v_tel from public.clientes where id = v_cliente;

  update public.cliente_password_reset_tokens
     set used_at = now()
   where cliente_id = v_cliente
     and used_at is null
     and expires_at > now();

  insert into public.cliente_password_reset_tokens (cliente_id, request_id)
  values (v_cliente, v_req.id)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'token', v_token,
    'telefono', v_tel,
    'cliente_id', v_cliente
  );
end;
$$;

grant execute on function public.admin_generar_link_reset_password(uuid, uuid) to anon, authenticated;

-- ── Actualizar asignación admin con reglas ───────────────────────────────────
create or replace function public.admin_asignar_password_cliente(
  p_session_token  uuid,
  p_cliente_id     bigint,
  p_nueva_password text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_updated bigint;
  v_val jsonb;
begin
  perform public.fn_require_admin(p_session_token);

  v_val := public.fn_validar_password_tienda(p_nueva_password);
  if coalesce((v_val->>'success')::boolean, false) is not true then
    return jsonb_build_object('success', false, 'error', coalesce(v_val->>'error', 'Contraseña inválida'));
  end if;

  if p_cliente_id is null then
    return jsonb_build_object('success', false, 'error', 'Cliente no válido');
  end if;

  update public.clientes
     set password_hash = public.fn_hash_cliente(p_nueva_password)
   where id = p_cliente_id
   returning id into v_updated;

  if v_updated is null then
    return jsonb_build_object('success', false, 'error', 'Cliente no encontrado');
  end if;

  update public.sesiones_cliente
     set revoked_at = now()
   where cliente_id = p_cliente_id
     and revoked_at is null;

  return jsonb_build_object('success', true);
end;
$$;

-- ── Login tienda: teléfono con normalización MX ──────────────────────────────
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
  v_id      bigint;
begin
  if p_telefono is null or p_password is null
     or length(trim(p_telefono)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  v_id := public.fn_resolver_cliente_id_por_identificador(trim(p_telefono));
  if v_id is null then
    return jsonb_build_object('success', false, 'error', 'Correo, teléfono o contraseña incorrectos');
  end if;

  select c.* into v_cliente from public.clientes c where c.id = v_id;

  if v_cliente.password_hash is null or length(v_cliente.password_hash) = 0 then
    return jsonb_build_object(
      'success', false,
      'error', 'Tu cuenta necesita una contraseña. Usa recuperar acceso o regístrate de nuevo.'
    );
  end if;

  v_hash := public.fn_hash_cliente(p_password);
  if v_hash <> v_cliente.password_hash then
    return jsonb_build_object('success', false, 'error', 'Correo, teléfono o contraseña incorrectos');
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

-- ── Cambio de contraseña logueado ────────────────────────────────────────────
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
  v_val         jsonb;
begin
  v_cliente_id := public.fn_require_cliente(p_session_token);

  v_val := public.fn_validar_password_tienda(p_nueva);
  if coalesce((v_val->>'success')::boolean, false) is not true then
    return jsonb_build_object('success', false, 'error', coalesce(v_val->>'error', 'Contraseña inválida'));
  end if;

  select password_hash into v_stored from public.clientes where id = v_cliente_id;

  v_hash_actual := public.fn_hash_cliente(p_actual);
  if v_hash_actual <> v_stored then
    return jsonb_build_object('success', false, 'error', 'Contraseña actual incorrecta');
  end if;

  v_hash_nuevo := public.fn_hash_cliente(p_nueva);
  update public.clientes set password_hash = v_hash_nuevo where id = v_cliente_id;

  update public.sesiones_cliente
     set revoked_at = now()
   where cliente_id = v_cliente_id
     and token <> p_session_token
     and revoked_at is null;

  return jsonb_build_object('success', true);
end;
$$;

commit;
