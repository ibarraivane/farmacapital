-- ============================================================
-- Sesión de caja: no pedir abrir de nuevo si ya está abierta.
-- Token de empleado: 16 h + se alarga mientras venden.
-- 21 ago 2026. Idempotente. Pegar en el SQL Editor de Supabase.
-- ============================================================

begin;

alter table public.sesiones
  alter column expires_at set default (now() + interval '16 hours');

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
     set last_used_at = now(),
         expires_at = greatest(expires_at, now() + interval '8 hours')
   where token = p_token
     and revoked_at is null
     and expires_at > now()
  returning usuario_id into v_user_id;

  return v_user_id;
end;
$$;

revoke all on function public.fn_validar_token_empleado(uuid) from public, anon, authenticated;


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

  insert into public.sesiones (usuario_id, ip, user_agent, expires_at)
  values (v_usuario.id, p_ip, p_user_agent, now() + interval '16 hours')
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
      'turno',          v_usuario.turno,
      'dia_descanso',   v_usuario.dia_descanso,
      'modulos_custom', v_usuario.modulos_custom
    )
  );
end;
$$;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;


-- Si el vendedor ya tiene caja abierta (recarga / token nuevo), reanuda.
-- No vuelve a contar el fondo ni pisa el arqueo de la mañana.
create or replace function public.abrir_sesion_caja(
  p_session_token uuid,
  p_denominaciones jsonb,
  p_nota text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_nombre text;
  v_ahora timestamp;
  v_minutos int;
  v_turno text;
  v_asignado text;
  v_fondo numeric;
  v_id bigint;
  v_ocupada text;
  v_sesion public.caja_sesiones%rowtype;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_user_id and estado = 'abierta'
  limit 1;
  if v_sesion.id is not null then
    return jsonb_build_object(
      'success', true,
      'abierta', true,
      'reanudada', true,
      'id', v_sesion.id,
      'turno', v_sesion.turno,
      'fondo_contado', v_sesion.fondo_contado,
      'abierta_at', v_sesion.abierta_at,
      'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
    );
  end if;

  select u.nombre into v_ocupada
  from public.caja_sesiones s
  join public.usuarios u on u.id = s.empleado_id
  where s.estado = 'abierta'
  limit 1;
  if v_ocupada is not null then
    return jsonb_build_object(
      'success', false,
      'error', format('Hay una caja abierta de %s. Debe cerrar turno antes de que abras la tuya.', v_ocupada)
    );
  end if;

  v_ahora := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;
  v_asignado := public.fn_turno_caja_de(v_user_id);

  if coalesce(v_rol, '') = 'vendedor' then
    if coalesce(public.fn_es_descanso_hoy(v_user_id), false) then
      return jsonb_build_object(
        'success', false,
        'error', 'Hoy es tu día de descanso. La caja la abre quien cubre ambos turnos.'
      );
    end if;
    v_turno := public.fn_turno_abrir_hoy(v_user_id);
    if v_turno is null then
      if v_asignado is null then
        return jsonb_build_object(
          'success', false,
          'error', 'RH debe asignarte un turno (matutino o vespertino) antes de abrir caja.'
        );
      end if;
      return jsonb_build_object(
        'success', false,
        'error', 'Ya cerraste los turnos que te tocan hoy.'
      );
    end if;
  else
    v_turno := coalesce(
      public.fn_turno_abrir_hoy(v_user_id),
      v_asignado,
      case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end
    );
  end if;

  v_fondo := public.fn_sumar_denominaciones(p_denominaciones);

  insert into public.caja_sesiones (
    empleado_id, turno, fecha, fondo_contado, denominaciones, nota_apertura, abierta_at, estado
  ) values (
    v_user_id, v_turno, v_ahora::date, v_fondo,
    coalesce(p_denominaciones, '{}'::jsonb),
    nullif(btrim(coalesce(p_nota, '')), ''),
    now(),
    'abierta'
  ) returning id into v_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_user_id, v_nombre,
      'abrir_caja', 'caja_sesiones', v_id::text,
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo, 'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id))
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'abierta', true,
    'reanudada', false,
    'id', v_id,
    'turno', v_turno,
    'fondo_contado', v_fondo,
    'abierta_at', now(),
    'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
  );
end;
$$;

grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;

commit;
