-- FarmaCapital — 6 días de trabajo + 1 de descanso.
-- Ese día la compañera cubre matutino y vespertino (abre, corta, vuelve a abrir).
-- 0 = lunes … 6 = domingo (igual que el calendario de RH).
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

alter table public.usuarios
  add column if not exists dia_descanso smallint;

do $$ begin
  if not exists (
    select 1 from pg_constraint where conname = 'usuarios_dia_descanso_chk'
  ) then
    alter table public.usuarios
      add constraint usuarios_dia_descanso_chk
      check (dia_descanso is null or dia_descanso between 0 and 6);
  end if;
end $$;

comment on column public.usuarios.dia_descanso is
  'Día libre semanal: 0=lun … 6=dom. Ese día otra vendedora cubre ambos turnos.';


-- ── Índices de día ──────────────────────────────────────────────────────────

create or replace function public.fn_dia_idx_cdmx(p_ts timestamptz default now())
returns smallint
language sql
stable
as $$
  -- JS getDay(): 0=dom. Aquí 0=lun … 6=dom → (dow + 6) % 7
  select ((extract(dow from (coalesce(p_ts, now()) at time zone 'America/Mexico_City'))::int + 6) % 7)::smallint;
$$;


create or replace function public.fn_es_descanso_hoy(p_user_id bigint)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select u.dia_descanso is not null
     and u.dia_descanso = public.fn_dia_idx_cdmx()
  from public.usuarios u
  where u.id = p_user_id
$$;


create or replace function public.fn_cubre_ambos_hoy(p_user_id bigint)
returns boolean
language sql
stable
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.usuarios yo
    where yo.id = p_user_id
      and yo.activo is true
      and yo.eliminado_at is null
      and (yo.dia_descanso is distinct from public.fn_dia_idx_cdmx())
      and exists (
        select 1
        from public.usuarios otra
        where otra.id <> yo.id
          and otra.activo is true
          and otra.eliminado_at is null
          and otra.rol in ('vendedor', 'gerente')
          and otra.dia_descanso = public.fn_dia_idx_cdmx()
      )
  )
$$;


-- Turno que debe abrir AHORA (reloj CDMX + si ya cortó el matutino hoy).
create or replace function public.fn_turno_abrir_hoy(p_user_id bigint)
returns text
language plpgsql
volatile
set search_path = public, pg_temp
as $$
declare
  v_asignado text;
  v_ahora    timestamp;
  v_minutos  int;
  v_turno    text;
begin
  if public.fn_es_descanso_hoy(p_user_id) then
    return null;
  end if;

  v_asignado := public.fn_turno_caja_de(p_user_id);
  v_ahora := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;

  if public.fn_cubre_ambos_hoy(p_user_id) then
    if exists (
      select 1 from public.caja_sesiones s
      where s.empleado_id = p_user_id
        and s.fecha = v_ahora::date
        and s.turno = 'matutino'
        and s.estado = 'cerrada'
    ) then
      return 'vespertino';
    end if;
    if exists (
      select 1 from public.caja_sesiones s
      where s.empleado_id = p_user_id
        and s.fecha = v_ahora::date
        and s.turno = 'vespertino'
        and s.estado = 'cerrada'
    ) then
      return null;
    end if;
    return case when v_minutos < (15 * 60 + 30) then 'matutino' else 'vespertino' end;
  end if;

  return v_asignado;
end;
$$;


create or replace function public.empleado_jornada_hoy(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_descanso boolean;
  v_ambos boolean;
  v_abrir text;
  v_habitual text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  v_descanso := coalesce(public.fn_es_descanso_hoy(v_user_id), false);
  v_ambos := coalesce(public.fn_cubre_ambos_hoy(v_user_id), false);
  v_abrir := public.fn_turno_abrir_hoy(v_user_id);
  v_habitual := public.fn_turno_caja_de(v_user_id);

  return jsonb_build_object(
    'dia_idx_hoy', public.fn_dia_idx_cdmx(),
    'dia_descanso', (select dia_descanso from public.usuarios where id = v_user_id),
    'es_descanso', v_descanso,
    'cubre_ambos', v_ambos,
    'turno_habitual', v_habitual,
    'turno_abrir', v_abrir
  );
end;
$$;

grant execute on function public.fn_dia_idx_cdmx(timestamptz) to anon, authenticated;
grant execute on function public.fn_es_descanso_hoy(bigint) to anon, authenticated;
grant execute on function public.fn_cubre_ambos_hoy(bigint) to anon, authenticated;
grant execute on function public.fn_turno_abrir_hoy(bigint) to anon, authenticated;
grant execute on function public.empleado_jornada_hoy(uuid) to anon, authenticated;


-- ── Abrir caja: descanso bloquea; día de cobertura = ambos turnos ───────────

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
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol, nombre into v_rol, v_nombre from public.usuarios where id = v_user_id;

  if exists (
    select 1 from public.caja_sesiones
    where empleado_id = v_user_id and estado = 'abierta'
  ) then
    return jsonb_build_object('success', false, 'error', 'Ya tienes una caja abierta.');
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
    'id', v_id,
    'turno', v_turno,
    'fondo_contado', v_fondo,
    'abierta_at', now(),
    'cubre_ambos', public.fn_cubre_ambos_hoy(v_user_id)
  );
end;
$$;


-- Historial del vendedor: sus cortes, aunque ese día haya cubierto ambos.
create or replace function public.empleado_listar_cortes_caja(
  p_session_token uuid,
  p_limite int default 40,
  p_fecha_desde date default null,
  p_fecha_hasta date default null,
  p_turno text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  return coalesce((
    select jsonb_agg(row_js order by ord desc nulls last)
    from (
      select
        jsonb_build_object(
          'id',                 c.id,
          'fecha',             (c.fecha + coalesce(c.hora_cierre, c.hora_apertura)),
          'turno',              c.turno,
          'cajero',             u.nombre,
          'contado_por',        c.contado_por,
          'fondo_inicial',      c.fondo_inicial,
          'efectivo_declarado', c.efectivo_declarado,
          'efectivo_sistema',   case when coalesce(v_rol,'') = 'vendedor' then null else c.efectivo_sistema end,
          'esperado',           case when coalesce(v_rol,'') = 'vendedor' then null else (c.fondo_inicial + c.efectivo_sistema) end,
          'diferencia',         c.diferencia,
          'tarjeta',            c.total_tarjeta,
          'spei',               c.total_spei,
          'mercadopago',        c.total_mercadopago,
          'total_general',      case when coalesce(v_rol,'') = 'vendedor' then null else c.total_general end,
          'denominaciones',     c.denominaciones,
          'notas',              c.notas
        ) as row_js,
        c.created_at as ord
      from public.cortes_caja c
      left join public.usuarios u on u.id = c.empleado_id
      where (p_fecha_desde is null or c.fecha >= p_fecha_desde)
        and (p_fecha_hasta is null or c.fecha <= p_fecha_hasta)
        and (
          coalesce(v_rol, '') = 'vendedor'
          or p_turno is null or p_turno = '' or p_turno = 'todos' or c.turno = p_turno
        )
        and (
          coalesce(v_rol, '') <> 'vendedor'
          or c.empleado_id = v_user_id
        )
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.admin_set_usuario_descanso(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_dia_descanso  smallint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_dia   smallint;
begin
  v_actor := public.fn_require_admin(p_session_token);
  v_dia := p_dia_descanso;
  if v_dia is not null and (v_dia < 0 or v_dia > 6) then
    raise exception 'Día de descanso inválido';
  end if;

  update public.usuarios
     set dia_descanso = v_dia
   where id = p_usuario_id
     and eliminado_at is null;
  if not found then
    raise exception 'Usuario % no encontrado', p_usuario_id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'asignar_descanso', 'usuarios', p_usuario_id::text,
      jsonb_build_object('dia_descanso', v_dia)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'dia_descanso', v_dia);
end;
$$;

grant execute on function public.admin_set_usuario_descanso(uuid, bigint, smallint)
  to anon, authenticated;


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
  turno          text,
  dia_descanso   smallint,
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
    u.turno,
    u.dia_descanso,
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
      'turno',          v_usuario.turno,
      'dia_descanso',   v_usuario.dia_descanso,
      'modulos_custom', v_usuario.modulos_custom
    )
  );
end;
$$;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;

commit;
