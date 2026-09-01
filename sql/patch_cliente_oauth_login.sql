-- ============================================================
-- FARMAX — Login social (Google / Facebook / Apple) para tienda
-- ============================================================
-- Puente: Supabase Auth OAuth → fila en public.clientes + token
-- en sesiones_cliente (mismo esquema que login_cliente).
--
-- Seguridad: service_login_cliente_oauth SOLO con service_role
-- (la API /api/auth/oauth-bridge valida el JWT de Auth antes).
-- Ejecutar en SQL Editor de Supabase (idempotente).
-- ============================================================

begin;

alter table public.clientes
  add column if not exists auth_provider text,
  add column if not exists auth_subject  text;

comment on column public.clientes.auth_provider is
  'Proveedor OAuth: google | facebook | apple (null = solo contraseña / mostrador).';
comment on column public.clientes.auth_subject is
  'Subject estable del proveedor (sub / id). Unicidad por (provider, subject).';

create unique index if not exists clientes_auth_provider_subject_uidx
  on public.clientes (auth_provider, auth_subject)
  where auth_provider is not null
    and auth_subject is not null
    and btrim(auth_provider) <> ''
    and btrim(auth_subject) <> '';

-- Un correo por cuenta (si el índice ya existe, no falla).
create unique index if not exists clientes_email_unique_ci
  on public.clientes (lower(trim(email)))
  where email is not null and btrim(email) <> '';

create or replace function public.service_login_cliente_oauth(
  p_provider   text,
  p_subject    text,
  p_email      text default null,
  p_nombre     text default null,
  p_ip         text default null,
  p_user_agent text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_provider text;
  v_subject  text;
  v_email    text;
  v_nombre   text;
  v_cliente  record;
  v_token    uuid;
  v_new_id   bigint;
  v_created  boolean := false;
begin
  v_provider := lower(trim(coalesce(p_provider, '')));
  v_subject  := trim(coalesce(p_subject, ''));
  v_email    := nullif(trim(lower(coalesce(p_email, ''))), '');
  v_nombre   := nullif(trim(coalesce(p_nombre, '')), '');

  if v_provider not in ('google', 'facebook', 'apple') then
    return jsonb_build_object('success', false, 'error', 'Proveedor no soportado');
  end if;

  if length(v_subject) < 3 then
    return jsonb_build_object('success', false, 'error', 'Identidad OAuth incompleta');
  end if;

  if v_email is not null and v_email !~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$' then
    return jsonb_build_object('success', false, 'error', 'Correo OAuth inválido');
  end if;

  -- 1) Match por (provider, subject)
  select c.* into v_cliente
  from public.clientes c
  where c.auth_provider = v_provider
    and c.auth_subject = v_subject
  limit 1;

  -- 2) Si no, vincular por email (cuenta mostrador / registro previo)
  if v_cliente.id is null and v_email is not null then
    select c.* into v_cliente
    from public.clientes c
    where c.email is not null
      and lower(trim(c.email)) = v_email
    limit 1;

    if v_cliente.id is not null then
      -- Evitar robar una cuenta ya ligada a otro subject del mismo provider
      if v_cliente.auth_provider is not null
         and v_cliente.auth_subject is not null
         and (
           v_cliente.auth_provider <> v_provider
           or v_cliente.auth_subject <> v_subject
         ) then
        return jsonb_build_object(
          'success', false,
          'error', 'Ese correo ya está vinculado a otra cuenta social. Entrá con tu método habitual o escribinos.'
        );
      end if;

      update public.clientes
         set auth_provider = v_provider,
             auth_subject  = v_subject,
             email = coalesce(nullif(trim(email), ''), v_email),
             nombre = case
               when nombre is null or btrim(nombre) = '' or lower(btrim(nombre)) in ('cliente', 'guest', 'invitado')
                 then coalesce(v_nombre, nombre)
               else nombre
             end
       where id = v_cliente.id;

      select c.* into v_cliente from public.clientes c where c.id = v_cliente.id;
    end if;
  end if;

  -- 3) Alta nueva (OAuth-only: sin password_hash)
  if v_cliente.id is null then
    if v_email is null and v_provider <> 'apple' then
      return jsonb_build_object(
        'success', false,
        'error', 'El proveedor no compartió un correo. Probá otro método o regístrate con teléfono.'
      );
    end if;

    insert into public.clientes (
      nombre, telefono, email, password_hash,
      puntos, consentimiento_privacidad, fecha_consentimiento, notas,
      auth_provider, auth_subject
    ) values (
      coalesce(v_nombre, 'Cliente FarmaCapital'),
      null,
      v_email,
      null,
      10,
      true,
      now(),
      'Alta OAuth (' || v_provider || ') ' || to_char(now(), 'YYYY-MM-DD HH24:MI:SS'),
      v_provider,
      v_subject
    )
    returning id into v_new_id;

    select c.* into v_cliente from public.clientes c where c.id = v_new_id;
    v_created := true;
  end if;

  delete from public.sesiones_cliente
  where cliente_id = v_cliente.id
    and (expires_at < now() or revoked_at is not null);

  insert into public.sesiones_cliente (cliente_id, ip, user_agent)
  values (v_cliente.id, p_ip, p_user_agent)
  returning token into v_token;

  return jsonb_build_object(
    'success', true,
    'created', v_created,
    'token',   v_token,
    'cliente', jsonb_build_object(
      'id',       v_cliente.id,
      'nombre',   v_cliente.nombre,
      'telefono', v_cliente.telefono,
      'email',    v_cliente.email,
      'puntos',   v_cliente.puntos,
      'auth_provider', v_cliente.auth_provider
    )
  );
end;
$$;

comment on function public.service_login_cliente_oauth(text, text, text, text, text, text) is
  'Service-role only: crea/vincula cliente desde identidad OAuth y emite sesiones_cliente.';

revoke all on function public.service_login_cliente_oauth(text, text, text, text, text, text)
  from public, anon, authenticated;
grant execute on function public.service_login_cliente_oauth(text, text, text, text, text, text)
  to service_role;

-- Completar WhatsApp tras OAuth (solo si aún no hay teléfono).
create or replace function public.cliente_completar_telefono(
  p_session_token uuid,
  p_telefono      text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente_id bigint;
  v_tel        text;
  v_actual     text;
begin
  if p_session_token is null then
    return jsonb_build_object('success', false, 'error', 'Sesión inválida');
  end if;

  v_tel := regexp_replace(coalesce(p_telefono, ''), '\D', '', 'g');
  if length(v_tel) = 11 and left(v_tel, 1) = '1' then
    v_tel := substr(v_tel, 2);
  end if;
  if length(v_tel) = 12 and left(v_tel, 2) = '52' then
    v_tel := substr(v_tel, 3);
  end if;
  if length(v_tel) <> 10 then
    return jsonb_build_object('success', false, 'error', 'Teléfono inválido (10 dígitos)');
  end if;

  select sc.cliente_id into v_cliente_id
  from public.sesiones_cliente sc
  where sc.token = p_session_token
    and sc.revoked_at is null
    and sc.expires_at > now()
  limit 1;

  if v_cliente_id is null then
    return jsonb_build_object('success', false, 'error', 'Sesión expirada. Volvé a iniciar sesión.');
  end if;

  select nullif(trim(c.telefono), '') into v_actual
  from public.clientes c
  where c.id = v_cliente_id;

  if v_actual is not null and v_actual <> v_tel then
    return jsonb_build_object(
      'success', false,
      'error', 'Tu cuenta ya tiene un teléfono. Para cambiarlo escribinos por WhatsApp.'
    );
  end if;

  if exists (
    select 1 from public.clientes c
    where c.id <> v_cliente_id
      and c.telefono is not null
      and regexp_replace(c.telefono, '\D', '', 'g') = v_tel
  ) then
    return jsonb_build_object(
      'success', false,
      'error', 'Ese teléfono ya está en otra cuenta. Entrá con ese método o escribinos.'
    );
  end if;

  update public.clientes
     set telefono = v_tel
   where id = v_cliente_id;

  update public.sesiones_cliente
     set last_used_at = now()
   where token = p_session_token;

  return jsonb_build_object(
    'success', true,
    'telefono', v_tel
  );
end;
$$;

comment on function public.cliente_completar_telefono(uuid, text) is
  'Cliente autenticado: carga WhatsApp/teléfono la primera vez tras login OAuth.';

revoke all on function public.cliente_completar_telefono(uuid, text) from public;
grant execute on function public.cliente_completar_telefono(uuid, text) to anon, authenticated;

commit;
