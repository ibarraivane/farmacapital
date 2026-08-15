-- Eliminar clientes desde Admin (hard delete sin historial; soft/anónimo si tiene pedidos o citas).
-- Ejecutar en Supabase SQL Editor.

begin;

alter table public.clientes
  add column if not exists eliminado_at timestamptz;

create index if not exists idx_clientes_eliminado_at
  on public.clientes (eliminado_at)
  where eliminado_at is not null;


create or replace function public.admin_eliminar_cliente(
  p_session_token uuid,
  p_cliente_id    bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_nombre text;
  v_telefono text;
  v_pedidos integer := 0;
  v_citas integer := 0;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select c.nombre, c.telefono
  into v_nombre, v_telefono
  from public.clientes c
  where c.id = p_cliente_id
    and c.eliminado_at is null;

  if not found then
    raise exception 'Cliente % no encontrado o ya fue eliminado', p_cliente_id;
  end if;

  select count(*)::integer into v_pedidos
  from public.pedidos p
  where p.cliente_id = p_cliente_id;

  select count(*)::integer into v_citas
  from public.citas c
  where c.cliente_id = p_cliente_id;

  if coalesce(v_pedidos, 0) = 0 and coalesce(v_citas, 0) = 0 then
    delete from public.clientes
    where id = p_cliente_id;

    begin
      insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
      values (
        v_actor,
        (select nombre from public.usuarios where id = v_actor),
        'eliminar_cliente',
        'clientes',
        p_cliente_id::text,
        jsonb_build_object(
          'modo', 'hard',
          'nombre', v_nombre,
          'telefono', v_telefono
        )
      );
    exception when others then null;
    end;

    return jsonb_build_object(
      'success', true,
      'modo', 'hard',
      'cliente_id', p_cliente_id
    );
  end if;

  update public.clientes
  set
    nombre = coalesce(nullif(btrim(v_nombre), ''), 'Cliente') || ' (eliminado)',
    telefono = 'DEL-' || p_cliente_id::text,
    email = null,
    notas = null,
    password_hash = null,
    puntos = 0,
    eliminado_at = now()
  where id = p_cliente_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'eliminar_cliente',
      'clientes',
      p_cliente_id::text,
      jsonb_build_object(
        'modo', 'soft',
        'nombre', v_nombre,
        'telefono', v_telefono,
        'pedidos', v_pedidos,
        'citas', v_citas
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'modo', 'soft',
    'cliente_id', p_cliente_id,
    'pedidos', v_pedidos,
    'citas', v_citas,
    'mensaje', format(
      'Cliente oculto del listado. Se conserva historial (%s compra(s), %s cita(s)). El teléfono queda libre para un registro nuevo.',
      v_pedidos,
      v_citas
    )
  );
end;
$$;

grant execute on function public.admin_eliminar_cliente(uuid, bigint) to anon, authenticated;


-- Ocultar eliminados del listado admin
drop function if exists public.admin_listar_clientes(uuid);

create function public.admin_listar_clientes(
  p_session_token uuid
)
returns table (
  id                integer,
  nombre            text,
  telefono          text,
  email             text,
  puntos            integer,
  notas             text,
  alergias          text,
  antecedentes      text,
  direccion         text,
  fecha_nacimiento  date,
  genero            text,
  created_at        timestamptz,
  updated_at        timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  has_email    boolean;
  has_puntos   boolean;
  has_notas    boolean;
  has_created  boolean;
  has_updated  boolean;
  has_eliminado boolean;
  expr_email   text;
  expr_puntos  text;
  expr_notas   text;
  expr_ca      text;
  expr_upd     text;
  filtro_elim  text;
begin
  perform public.fn_require_empleado(p_session_token);

  select
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'email' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'puntos' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'notas' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'created_at' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'updated_at' and a.attnum > 0 and not a.attisdropped
    ),
    exists (
      select 1 from pg_catalog.pg_attribute a
      join pg_catalog.pg_class c on c.oid = a.attrelid
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'clientes'
        and a.attname = 'eliminado_at' and a.attnum > 0 and not a.attisdropped
    )
  into has_email, has_puntos, has_notas, has_created, has_updated, has_eliminado;

  expr_email  := case when has_email  then 'c.email::text' else 'null::text' end;
  expr_puntos := case when has_puntos then 'round(coalesce(c.puntos, 0))::integer' else '0::integer' end;
  expr_notas  := case when has_notas  then 'c.notas::text' else 'null::text' end;
  filtro_elim := case when has_eliminado then 'where c.eliminado_at is null' else '' end;

  if has_created then
    expr_ca := 'c.created_at::timestamptz';
  elsif has_updated then
    expr_ca := 'c.updated_at::timestamptz';
  else
    expr_ca := 'now()::timestamptz';
  end if;

  if has_updated and has_created then
    expr_upd := 'coalesce(c.updated_at, c.created_at)::timestamptz';
  elsif has_updated then
    expr_upd := 'c.updated_at::timestamptz';
  elsif has_created then
    expr_upd := 'c.created_at::timestamptz';
  else
    expr_upd := 'now()::timestamptz';
  end if;

  return query execute format(
    $q$
    select
      c.id::integer,
      c.nombre,
      c.telefono,
      %s,
      %s,
      %s,
      null::text,
      null::text,
      null::text,
      null::date,
      null::text,
      %s,
      %s
    from public.clientes c
    %s
    order by c.nombre
    $q$,
    expr_email,
    expr_puntos,
    expr_notas,
    expr_ca,
    expr_upd,
    filtro_elim
  );
end;
$$;

grant execute on function public.admin_listar_clientes(uuid) to anon, authenticated;


-- No reutilizar clientes ya eliminados al buscar por teléfono (consultorio / POS)
create or replace function public.admin_obtener_cliente_por_telefono(
  p_session_token uuid,
  p_telefono      text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_json jsonb;
begin
  perform public.fn_require_empleado(p_session_token);

  select jsonb_build_object(
    'id',       c.id,
    'nombre',   c.nombre,
    'telefono', c.telefono,
    'email',    c.email,
    'puntos',   coalesce(c.puntos, 0),
    'notas',    c.notas
  ) into v_json
  from public.clientes c
  where c.telefono = trim(p_telefono)
    and coalesce(c.eliminado_at, null) is null
  limit 1;

  return coalesce(v_json, 'null'::jsonb);
end;
$$;

grant execute on function public.admin_obtener_cliente_por_telefono(uuid, text) to anon, authenticated;

commit;
