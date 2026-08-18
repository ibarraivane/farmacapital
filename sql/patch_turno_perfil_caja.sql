-- FarmaCapital — Turno de caja por perfil (se asigna en RH).
-- El vendedor abre y cierra SOLO su turno; no puede cortar el del relevo.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.

begin;

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

alter table public.usuarios
  add column if not exists eliminado_at timestamptz;

alter table public.usuarios
  add column if not exists turno text;

do $$ begin
  if not exists (
    select 1 from pg_constraint where conname = 'usuarios_turno_caja_chk'
  ) then
    alter table public.usuarios
      add constraint usuarios_turno_caja_chk
      check (turno is null or turno in ('matutino', 'vespertino'));
  end if;
end $$;

comment on column public.usuarios.turno is
  'Turno de caja del perfil (matutino/vespertino). Lo asigna RH. El vendedor no cierra el otro.';

alter table public.empleados
  add column if not exists usuario_id bigint references public.usuarios(id) on delete set null;

create unique index if not exists empleados_usuario_id_uidx
  on public.empleados (usuario_id)
  where usuario_id is not null;

-- Relleno: si RH ya tenía el turno en empleados, cópialo al perfil de acceso.
update public.usuarios u
   set turno = e.turno
  from public.empleados e
 where u.turno is null
   and e.turno in ('matutino', 'vespertino')
   and u.eliminado_at is null
   and (
     (public.fn_tel_empleado(u.telefono) is not null
      and public.fn_tel_empleado(u.telefono) = public.fn_tel_empleado(e.telefono))
     or lower(trim(u.nombre)) = lower(trim(e.nombre))
   );

update public.empleados e
   set usuario_id = x.uid
  from (
    select distinct on (e2.id) e2.id as eid, u.id as uid
    from public.empleados e2
    join public.usuarios u
      on u.eliminado_at is null
     and (
       (public.fn_tel_empleado(e2.telefono) is not null
        and public.fn_tel_empleado(e2.telefono) = public.fn_tel_empleado(u.telefono))
       or lower(trim(e2.nombre)) = lower(trim(u.nombre))
     )
    where e2.usuario_id is null
    order by e2.id,
      case when public.fn_tel_empleado(e2.telefono) = public.fn_tel_empleado(u.telefono) then 0 else 1 end,
      u.id
  ) x
 where e.id = x.eid
   and e.usuario_id is null
   and not exists (
     select 1 from public.empleados z where z.usuario_id = x.uid
   );

create or replace function public.fn_turno_caja_de(p_user_id bigint)
returns text
language sql
stable
set search_path = public, pg_temp
as $$
  select case
    when u.turno in ('matutino', 'vespertino') then u.turno
    else null
  end
  from public.usuarios u
  where u.id = p_user_id
$$;

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
  v_turno text;
  v_uid   bigint;
  v_eid   bigint;
begin
  v_turno := nullif(lower(trim(coalesce(p_turno, ''))), '');
  if v_turno is not null and v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido: %', p_turno;
  end if;

  v_uid := p_usuario_id;
  v_eid := p_empleado_id;

  if v_uid is null and v_eid is not null then
    select e.usuario_id into v_uid from public.empleados e where e.id = v_eid;
    if v_uid is null then
      select u.id into v_uid
      from public.empleados e
      join public.usuarios u on u.eliminado_at is null
        and (
          (public.fn_tel_empleado(e.telefono) is not null
           and public.fn_tel_empleado(e.telefono) = public.fn_tel_empleado(u.telefono))
          or lower(trim(e.nombre)) = lower(trim(u.nombre))
        )
      where e.id = v_eid
      order by case
        when public.fn_tel_empleado(e.telefono) = public.fn_tel_empleado(u.telefono) then 0
        else 1
      end
      limit 1;
    end if;
  end if;

  if v_eid is null and v_uid is not null then
    select e.id into v_eid
    from public.empleados e
    where e.usuario_id = v_uid
       or (public.fn_tel_empleado(e.telefono) is not null
           and public.fn_tel_empleado(e.telefono) = (
             select public.fn_tel_empleado(u.telefono) from public.usuarios u where u.id = v_uid
           ))
       or lower(trim(e.nombre)) = (
         select lower(trim(u.nombre)) from public.usuarios u where u.id = v_uid
       )
    order by case when e.usuario_id = v_uid then 0 else 1 end
    limit 1;
  end if;

  if v_uid is not null then
    update public.usuarios
       set turno = v_turno
     where id = v_uid
       and eliminado_at is null;
  end if;

  if v_eid is not null then
    update public.empleados
       set turno = coalesce(v_turno, turno),
           usuario_id = coalesce(usuario_id, v_uid)
     where id = v_eid;
  end if;
end;
$$;


-- ── RH: asignar turno al perfil de acceso ───────────────────────────────────
create or replace function public.admin_set_usuario_turno(
  p_session_token uuid,
  p_usuario_id    bigint,
  p_turno         text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_usuario_id is null then
    raise exception 'Usuario requerido';
  end if;
  if not exists (
    select 1 from public.usuarios where id = p_usuario_id and eliminado_at is null
  ) then
    raise exception 'Usuario no encontrado';
  end if;

  perform public.fn_sync_turno_caja(p_usuario_id, null, p_turno);

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'asignar_turno', 'usuarios', p_usuario_id::text,
      jsonb_build_object('turno', p_turno)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'turno', public.fn_turno_caja_de(p_usuario_id)
  );
end;
$$;

grant execute on function public.admin_set_usuario_turno(uuid, bigint, text) to anon, authenticated;


create or replace function public.admin_set_empleado_turno(
  p_session_token uuid,
  p_empleado_id   bigint,
  p_turno         text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_empleado_id is null then
    raise exception 'Empleado requerido';
  end if;
  if not exists (select 1 from public.empleados where id = p_empleado_id) then
    raise exception 'Empleado no encontrado';
  end if;

  perform public.fn_sync_turno_caja(null, p_empleado_id, p_turno);

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'asignar_turno', 'empleados', p_empleado_id::text,
      jsonb_build_object('turno', p_turno)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'turno', p_turno);
end;
$$;

grant execute on function public.admin_set_empleado_turno(uuid, bigint, text) to anon, authenticated;


create or replace function public.admin_crear_empleado(
  p_session_token      uuid,
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
  v_new_id bigint;
  v_turno text;
  v_tel text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if coalesce(trim(p_nombre), '') = '' then
    raise exception 'El nombre es obligatorio';
  end if;

  v_turno := lower(trim(coalesce(p_turno, 'matutino')));
  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_tel := public.fn_tel_empleado(p_telefono);

  insert into public.empleados(
    nombre, telefono, rol, turno, salario_quincenal, estado
  ) values (
    trim(p_nombre), v_tel,
    p_rol, v_turno, coalesce(p_salario_quincenal, 0), true
  )
  returning id into v_new_id;

  perform public.fn_sync_turno_caja(null, v_new_id, v_turno);

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (v_actor,
            (select nombre from public.usuarios where id = v_actor),
            'crear_empleado', 'empleados', v_new_id::text,
            jsonb_build_object('nombre', p_nombre, 'rol', p_rol, 'turno', v_turno));
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'empleado_id', v_new_id);
end;
$$;

grant execute on function public.admin_crear_empleado(uuid, text, text, text, text, numeric) to anon, authenticated;


-- ── Login: el cliente necesita el turno para bloquear el corte ajeno ────────
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
      'modulos_custom', v_usuario.modulos_custom
    )
  );
end;
$$;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;

commit;


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
  turno          text,
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


-- ── Caja: el vendedor no elige turno; usa el de su perfil ───────────────────
begin;

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

  v_asignado := public.fn_turno_caja_de(v_user_id);
  v_ahora := now() at time zone 'America/Mexico_City';
  v_minutos := (extract(hour from v_ahora)::int * 60) + extract(minute from v_ahora)::int;

  if coalesce(v_rol, '') = 'vendedor' then
    if v_asignado is null then
      return jsonb_build_object(
        'success', false,
        'error', 'RH debe asignarte un turno (matutino o vespertino) antes de abrir caja.'
      );
    end if;
    v_turno := v_asignado;
  else
    v_turno := coalesce(
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
      jsonb_build_object('turno', v_turno, 'fondo', v_fondo)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'abierta', true,
    'id', v_id,
    'turno', v_turno,
    'fondo_contado', v_fondo,
    'abierta_at', now()
  );
end;
$$;


create or replace function public.registrar_corte_caja(
  p_session_token      uuid,
  p_turno              text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema   numeric,
  p_tarjeta            numeric,
  p_mercadopago        numeric,
  p_diferencia         numeric,
  p_total_general      numeric,
  p_spei               numeric default 0,
  p_notas              text default null,
  p_fondo_inicial      numeric default 0,
  p_contado_por        text default null,
  p_denominaciones     jsonb default null
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
  v_corte_id bigint;
  v_ahora    timestamp;
  v_apertura time;
  v_sistema  numeric;
  v_fila     public.cortes_caja%rowtype;
  v_sesion   public.caja_sesiones%rowtype;
  v_fondo    numeric;
  v_turno    text;
  v_decl     numeric;
  v_asignado text;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre, rol into v_nombre, v_rol from public.usuarios where id = v_actor_id;
  v_asignado := public.fn_turno_caja_de(v_actor_id);

  v_ahora := now() at time zone 'America/Mexico_City';
  v_decl  := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_actor_id and estado = 'abierta'
  limit 1;

  if v_sesion.id is not null then
    v_fondo := v_sesion.fondo_contado;
    v_turno := v_sesion.turno;
    v_apertura := (v_sesion.abierta_at at time zone 'America/Mexico_City')::time;
  else
    if coalesce(v_rol, '') = 'vendedor' then
      if v_asignado is null then
        raise exception 'RH debe asignarte un turno antes de cerrar caja'
          using errcode = 'P0001';
      end if;
      v_turno := v_asignado;
    else
      v_turno := coalesce(nullif(p_turno, ''), v_asignado, 'matutino');
    end if;
    v_fondo := coalesce(p_fondo_inicial, 0);
    v_apertura := case when v_turno = 'matutino' then time '08:00' else time '15:00' end;
  end if;

  if v_turno not in ('matutino', 'vespertino') then
    raise exception 'Turno inválido';
  end if;

  v_sistema := coalesce(
    (public.reconcile_shift_cash(v_turno, v_ahora::date)->>'efectivo_sistema')::numeric, 0);

  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    v_decl, v_sistema, v_fondo,
    coalesce(p_tarjeta, 0), coalesce(p_spei, 0), coalesce(p_mercadopago, 0),
    nullif(btrim(coalesce(p_contado_por, '')), ''), p_denominaciones, p_notas
  ) returning * into v_fila;

  v_corte_id := v_fila.id;

  if v_sesion.id is not null then
    update public.caja_sesiones
       set estado = 'cerrada',
           cerrada_at = now(),
           corte_id = v_corte_id
     where id = v_sesion.id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', v_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success',          true,
    'corte_id',         v_corte_id,
    'efectivo_sistema', v_fila.efectivo_sistema,
    'fondo_inicial',    v_fila.fondo_inicial,
    'esperado',         v_fila.fondo_inicial + v_fila.efectivo_sistema,
    'diferencia',       v_fila.diferencia,
    'total_general',    v_fila.total_general,
    'hora_apertura',    v_fila.hora_apertura,
    'hora_cierre',      v_fila.hora_cierre,
    'turno',            v_turno
  );
end;
$$;


create or replace function public.empleado_totales_electronicos_turno(
  p_session_token uuid,
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_turno text;
  v_r jsonb;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  v_turno := p_turno;
  if coalesce(v_rol, '') = 'vendedor' then
    v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
  end if;
  v_r := public.reconcile_shift_cash(v_turno, p_fecha);
  return jsonb_build_object(
    'tarjeta',     v_r->'tarjeta',
    'mercadopago', v_r->'mercadopago'
  );
end;
$$;


create or replace function public.empleado_corte_turno_en_fecha(
  p_session_token uuid,
  p_fecha date,
  p_turno text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol text;
  v_turno text;
  v_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  v_turno := p_turno;
  if coalesce(v_rol, '') = 'vendedor' then
    v_turno := coalesce(public.fn_turno_caja_de(v_user_id), p_turno);
  end if;
  select cc.id into v_id
  from public.cortes_caja cc
  where cc.turno = v_turno
    and ((cc.created_at at time zone 'America/Mexico_City')::date) = p_fecha
    and (coalesce(v_rol, '') <> 'vendedor' or cc.empleado_id = v_user_id)
  limit 1;
  return jsonb_build_object('existe', v_id is not null, 'id', v_id);
end;
$$;


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
  v_asignado text;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  select rol into v_rol from public.usuarios where id = v_user_id;
  v_asignado := public.fn_turno_caja_de(v_user_id);
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
          or (
            c.empleado_id = v_user_id
            and (v_asignado is null or c.turno = v_asignado)
          )
        )
      order by c.created_at desc nulls last
      limit greatest(1, least(coalesce(p_limite, 40), 120))
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.fn_turno_caja_de(bigint) to anon, authenticated;
grant execute on function public.abrir_sesion_caja(uuid, jsonb, text) to anon, authenticated;
grant execute on function public.registrar_corte_caja(uuid, text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, numeric, text, jsonb) to anon, authenticated;
grant execute on function public.empleado_totales_electronicos_turno(uuid, text, date) to anon, authenticated;
grant execute on function public.empleado_corte_turno_en_fecha(uuid, date, text) to anon, authenticated;
grant execute on function public.empleado_listar_cortes_caja(uuid, int, date, date, text) to anon, authenticated;

commit;
