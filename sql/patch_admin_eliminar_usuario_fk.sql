-- Permite borrar usuarios aunque tengan filas en audit_log (inmutable).
-- El log conserva usuario_nombre; la FK a usuarios no debe bloquear el borrado.
-- Si el usuario tiene historial operativo (caja, ventas, etc.), se oculta (soft-delete).
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

alter table public.usuarios
  add column if not exists eliminado_at timestamptz;

create index if not exists idx_usuarios_eliminado_at
  on public.usuarios (eliminado_at)
  where eliminado_at is not null;

-- Quitar FKs de tablas de auditoría hacia usuarios (append-only: no deben
-- impedir borrar al actor; el nombre ya quedó denormalizado).
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
     and revoked_at is null;

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

  -- audit_log es inmutable: SET NULL requiere bypass explícito.
  perform set_config('app.audit_bypass', 'true', true);
  begin
    update public.audit_log
       set usuario_id = null
     where usuario_id = p_target_id;
  exception when others then
    null;
  end;
  begin
    update public.audit_log_detallado
       set usuario_id = null
     where usuario_id = p_target_id;
  exception when others then
    null;
  end;
  begin
    update public.audit_log_detallado
       set actor_id = null
     where actor_id = p_target_id;
  exception when others then
    null;
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

grant execute on function public.admin_eliminar_usuario(uuid, bigint) to anon, authenticated;

commit;

-- Ocultar soft-deletes del listado. Transacción aparte: si el RETURNS
-- de producción no coincide, el borrado de arriba ya quedó aplicado.
begin;

create or replace function public.admin_listar_usuarios(
  p_session_token uuid
)
returns table (
  id         integer,
  nombre     text,
  email      text,
  rol        text,
  activo     boolean,
  created_at timestamptz,
  updated_at timestamptz
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
    u.rol,
    coalesce(u.activo, false),
    u.created_at,
    u.created_at
  from public.usuarios u
  where u.eliminado_at is null
  order by u.nombre;
end;
$$;

grant execute on function public.admin_listar_usuarios(uuid) to anon, authenticated;

commit;
