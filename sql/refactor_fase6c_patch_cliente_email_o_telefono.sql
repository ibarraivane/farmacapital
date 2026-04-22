-- ============================================================
-- FARMAX — Cliente tienda: registro / login con correo O teléfono
-- ============================================================
-- Antes: login_cliente y registrar_cliente asumían teléfono obligatorio.
-- Ahora: el visitante puede registrarse e iniciar sesión con cualquiera de
-- los dos medios (o ambos), siempre que exista al menos uno.
--
-- Requisitos: ejecutar en Supabase SQL Editor (idempotente en lo posible).
-- ============================================================

begin;

-- Teléfono opcional para cuentas solo-correo (entregas / WhatsApp pueden pedir teléfono después).
alter table public.clientes alter column telefono drop not null;

-- Un correo por cuenta (case-insensitive), ignorando vacíos.
drop index if exists public.clientes_email_unique_ci;
create unique index clientes_email_unique_ci
  on public.clientes (lower(trim(email)))
  where email is not null and btrim(email) <> '';

-- ── login_cliente: primer argumento = teléfono O email (mismo tipo text, mismo orden RPC) ──
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
  v_key     text;
begin
  if p_telefono is null or p_password is null
     or length(trim(p_telefono)) = 0 or length(p_password) = 0 then
    return jsonb_build_object('success', false, 'error', 'Credenciales vacías');
  end if;

  v_key := trim(p_telefono);

  select c.* into v_cliente
  from public.clientes c
  where (c.telefono is not null and trim(c.telefono) = v_key)
     or (c.email is not null and lower(trim(c.email)) = lower(v_key))
  limit 1;

  if v_cliente.id is null then
    return jsonb_build_object('success', false, 'error', 'Correo, teléfono o contraseña incorrectos');
  end if;

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

comment on function public.login_cliente(text, text, text, text) is
  'F6a+: login tienda con teléfono O correo (mismo campo) + contraseña.';

-- ── registrar_cliente: teléfono y/o email; al menos uno obligatorio ──
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
  v_tel    text;
  v_mail   text;
begin
  if p_nombre is null or length(trim(p_nombre)) < 2 then
    return jsonb_build_object('success', false, 'error', 'Nombre requerido');
  end if;
  if p_password is null or length(p_password) < 6 then
    return jsonb_build_object('success', false, 'error', 'Password mínimo 6 caracteres');
  end if;

  v_tel  := nullif(trim(coalesce(p_telefono, '')), '');
  v_mail := nullif(trim(lower(coalesce(p_email, ''))), '');

  if v_tel is not null and position('@' in v_tel) > 1 then
    if v_mail is not null and lower(trim(v_tel)) <> v_mail then
      return jsonb_build_object('success', false, 'error', 'Revisá teléfono y correo: datos contradictorios');
    end if;
    v_mail := coalesce(v_mail, lower(trim(v_tel)));
    v_tel := null;
  end if;

  if v_tel is null and v_mail is null then
    return jsonb_build_object('success', false, 'error', 'Indicá un teléfono o un correo electrónico');
  end if;

  if v_tel is not null and length(v_tel) < 10 then
    return jsonb_build_object('success', false, 'error', 'Teléfono inválido (mínimo 10 dígitos)');
  end if;

  if v_mail is not null and (
       v_mail !~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'
     ) then
    return jsonb_build_object('success', false, 'error', 'Correo electrónico inválido');
  end if;

  if v_tel is not null and exists (select 1 from public.clientes where telefono = v_tel) then
    return jsonb_build_object('success', false, 'error', 'Ya existe una cuenta con ese teléfono');
  end if;

  if v_mail is not null and exists (
    select 1 from public.clientes
    where email is not null and lower(trim(email)) = v_mail
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya existe una cuenta con ese correo');
  end if;

  v_hash := public.fn_hash_cliente(p_password);

  insert into public.clientes (
    nombre, telefono, email, password_hash,
    puntos, consentimiento_privacidad, fecha_consentimiento, notas
  ) values (
    trim(p_nombre), v_tel, v_mail,
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
      'id', v_new_id,
      'nombre', trim(p_nombre),
      'telefono', v_tel,
      'email', v_mail,
      'puntos', 10
    )
  );
end;
$$;

comment on function public.registrar_cliente(text, text, text, text, text, text) is
  'Registro tienda: nombre + password + teléfono y/o email (al menos uno).';

commit;
