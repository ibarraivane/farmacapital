-- FarmaCapital — Teléfono MX alineado con Meta Developer (52 + 10 dígitos)
-- Ejecutar en Supabase SQL Editor.

begin;

-- Formato interno: 52XXXXXXXXXX (como la lista de prueba de Meta Getting Started).
create or replace function public.fn_telefono_mx_whatsapp(p_text text)
returns text
language plpgsql
immutable
as $$
declare
  d text;
  local10 text;
begin
  if p_text is null then
    return null;
  end if;

  d := regexp_replace(trim(p_text), '\D', '', 'g');
  if d = '' then
    return null;
  end if;

  if length(d) = 11 and d like '1%' then
    return d;
  end if;

  local10 := right(d, 10);
  if length(local10) = 10 then
    return '52' || local10;
  end if;

  return d;
end;
$$;

-- 521… → 52… (formato anterior)
update public.clientes c
set telefono = public.fn_telefono_mx_whatsapp(c.telefono)
where c.telefono is not null
  and regexp_replace(c.telefono, '\D', '', 'g') like '521%'
  and public.fn_telefono_mx_whatsapp(c.telefono) is distinct from trim(c.telefono);

update public.citas c
set telefono = public.fn_telefono_mx_whatsapp(c.telefono)
where c.telefono is not null
  and regexp_replace(c.telefono, '\D', '', 'g') like '521%'
  and public.fn_telefono_mx_whatsapp(c.telefono) is distinct from trim(c.telefono);

-- admin_crear_cliente_manual: guardar normalizado + evitar duplicados por últimos 10 dígitos
create or replace function public.admin_crear_cliente_manual(
  p_session_token uuid,
  p_nombre        text,
  p_telefono      text,
  p_email         text default null,
  p_notas         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_new_id bigint;
  v_tel text;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if coalesce(trim(p_nombre),'') = '' or coalesce(trim(p_telefono),'') = '' then
    raise exception 'Nombre y teléfono son obligatorios';
  end if;

  v_tel := public.fn_telefono_mx_whatsapp(p_telefono);
  if v_tel is null or length(public.fn_digits_mx(v_tel)) < 10 then
    return jsonb_build_object('success', false, 'error', 'Teléfono inválido');
  end if;

  if exists(
    select 1 from public.clientes c
    where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_tel)
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya existe un cliente con ese teléfono');
  end if;

  insert into public.clientes(nombre, telefono, email, notas, puntos)
  values (trim(p_nombre), v_tel,
          nullif(trim(coalesce(p_email,'')),''),
          nullif(trim(coalesce(p_notas,'')),''),
          0)
  returning id into v_new_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id = v_actor),
            'crear_cliente_manual', 'clientes', v_new_id::text,
            jsonb_build_object('nombre',p_nombre,'telefono',v_tel));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'cliente_id', v_new_id,
           'cliente', (select to_jsonb(c) from public.clientes c where c.id = v_new_id));
end;
$$;

-- registrar_cliente (tienda web)
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
begin
  if p_nombre is null or length(trim(p_nombre)) < 2 then
    return jsonb_build_object('success', false, 'error', 'Nombre requerido');
  end if;

  v_tel := public.fn_telefono_mx_whatsapp(p_telefono);
  if v_tel is null or length(public.fn_digits_mx(v_tel)) < 10 then
    return jsonb_build_object('success', false, 'error', 'Teléfono inválido');
  end if;

  if p_password is null or length(p_password) < 6 then
    return jsonb_build_object('success', false, 'error', 'Password mínimo 6 caracteres');
  end if;

  if exists(
    select 1 from public.clientes c
    where public.fn_digits_mx(c.telefono) = public.fn_digits_mx(v_tel)
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya existe una cuenta con ese teléfono');
  end if;

  v_hash := public.fn_hash_cliente(p_password);

  insert into public.clientes (
    nombre, telefono, email, password_hash,
    puntos, consentimiento_privacidad, fecha_consentimiento, notas
  ) values (
    trim(p_nombre), v_tel, nullif(trim(coalesce(p_email, '')), ''),
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
      'id', v_new_id, 'nombre', p_nombre, 'telefono', v_tel,
      'email', p_email, 'puntos', 10
    )
  );
end;
$$;

-- crear_cita (empleado)
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
  v_tel text;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_nombre is null or length(trim(p_nombre))=0 then raise exception 'Nombre requerido'; end if;
  if p_telefono is null or length(trim(p_telefono))=0 then raise exception 'Teléfono requerido'; end if;
  if p_fecha is null then raise exception 'Fecha requerida'; end if;

  v_tel := public.fn_telefono_mx_whatsapp(p_telefono);
  if v_tel is null or length(public.fn_digits_mx(v_tel)) < 10 then
    raise exception 'Teléfono inválido';
  end if;

  v_canal := lower(trim(coalesce(p_canal, 'mostrador')));
  if v_canal not in ('web', 'mostrador', 'pos') then
    v_canal := 'mostrador';
  end if;

  insert into public.citas (
    nombre, telefono, fecha, hora, motivo, medico_id, notas, estado,
    canal, cliente_id, pago_estado
  )
  values (
    trim(p_nombre), v_tel, p_fecha, p_hora, p_motivo, p_medico_id, p_notas, 'agendada',
    v_canal, p_paciente_id, 'pendiente'
  )
  returning id into v_cita_id;

  return jsonb_build_object('success', true, 'cita_id', v_cita_id);
end;
$$;

-- cliente_agendar_cita (tienda)
create or replace function public.cliente_agendar_cita(
  p_session_token uuid,
  p_nombre        text,
  p_telefono      text,
  p_fecha         date,
  p_hora          text,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id   bigint;
  v_cita_id  bigint;
  v_ocupada  boolean;
  v_tel      text;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  end if;

  if p_nombre is null or length(trim(p_nombre)) = 0 then
    raise exception 'Nombre requerido';
  end if;
  if p_telefono is null or length(trim(p_telefono)) = 0 then
    raise exception 'Teléfono requerido';
  end if;
  if p_fecha is null then raise exception 'Fecha requerida'; end if;
  if p_hora  is null or length(trim(p_hora)) = 0 then raise exception 'Hora requerida'; end if;

  v_tel := public.fn_telefono_mx_whatsapp(p_telefono);
  if v_tel is null or length(public.fn_digits_mx(v_tel)) < 10 then
    raise exception 'Teléfono inválido';
  end if;

  if p_fecha < current_date then
    raise exception 'No se puede agendar en una fecha pasada';
  end if;

  if (
    select count(*) from public.citas
    where public.fn_digits_mx(telefono) = public.fn_digits_mx(v_tel)
      and fecha between current_date and current_date + interval '60 days'
      and estado not in ('cancelada','no_asistio')
  ) >= 3 then
    raise exception 'Ya tienes 3 citas activas. Cancela alguna antes de agendar otra.';
  end if;

  select exists (
    select 1 from public.citas
    where fecha = p_fecha and hora = p_hora
      and estado <> 'cancelada'
  ) into v_ocupada;

  if v_ocupada then
    raise exception 'Ese horario ya no está disponible';
  end if;

  insert into public.citas (
    nombre, telefono, fecha, hora, motivo,
    cliente_id, canal, pago_estado, estado
  ) values (
    trim(p_nombre), v_tel, p_fecha, p_hora, p_motivo,
    v_cli_id, 'web', 'pendiente', 'agendada'
  ) returning id into v_cita_id;

  return jsonb_build_object('success', true, 'cita_id', v_cita_id);
end;
$$;

grant execute on function public.fn_telefono_mx_whatsapp(text) to anon, authenticated;
grant execute on function public.admin_crear_cliente_manual(uuid, text, text, text, text) to anon, authenticated;
grant execute on function public.registrar_cliente(text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.crear_cita(uuid, text, text, date, text, text, text, bigint, bigint, text) to anon, authenticated;
grant execute on function public.cliente_agendar_cita(uuid, text, text, date, text, text) to anon, authenticated;

commit;
