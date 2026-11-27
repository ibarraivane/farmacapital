-- Inventario: "canceling statement due to statement timeout" al guardar un precio.
--
-- La celda de precio se queda abierta (el 59 de la foto) porque
-- admin_editar_producto no alcanzó a terminar. Supabase corta a los ~8 s.
--
-- Qué lo alargaba, en la misma sesión del admin:
--   1) Cada guardado leía information_schema.columns (lento en Supabase).
--   2) El listado de lotes armaba un solo JSON con to_jsonb de TODOS los
--      lotes. Esa lectura llama fn_validar_token_empleado. Si el token hacía
--      UPDATE de sesiones y no soltaba el candado, el guardado del precio
--      esperaba esa fila hasta que Postgres cancelaba.
--   3) El trigger de auditoría comparaba to_jsonb de la fila completa en
--      cada UPDATE, también cuando solo cambió stock. Eso alarga ventas y
--      recepciones, que dejan el renglón bloqueado.
--
-- Esto:
--   1) Valida el token sin pelear el candado (mismo arreglo que la caja).
--   2) admin_editar_producto mira pg_attribute, no information_schema, y
--      tiene 20 s propios para salir de un candado corto.
--   3) Los lotes salen por páginas chicas, sin to_jsonb de la fila entera.
--   4) La auditoría de productos no arma JSON si solo cambió stock/updated_at.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

create index if not exists idx_sesiones_token_vivas
  on public.sesiones (token)
  where revoked_at is null;

create index if not exists idx_lotes_activos_id
  on public.lotes (id)
  where activo is distinct from false;

-- ── Token: SELECT, y el UPDATE de la sesión no retiene el candado ───────────
create or replace function public.fn_validar_token_empleado(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_lock_prev text;
begin
  if p_token is null then
    return null;
  end if;

  select usuario_id into v_user_id
  from public.sesiones
  where token = p_token
    and revoked_at is null
    and expires_at > now();

  if v_user_id is null then
    return null;
  end if;

  v_lock_prev := current_setting('lock_timeout', true);
  begin
    perform set_config('lock_timeout', '120ms', true);
    update public.sesiones
       set last_used_at = now(),
           expires_at = greatest(expires_at, now() + interval '8 hours')
     where token = p_token
       and last_used_at < now() - interval '30 seconds';
  exception
    when lock_not_available then null;
    when query_canceled then null;
  end;
  perform set_config('lock_timeout', coalesce(nullif(v_lock_prev, ''), '0'), true);

  return v_user_id;
end;
$$;

revoke all on function public.fn_validar_token_empleado(uuid) from public, anon, authenticated;

-- ── Guardar ficha / precio sin escanear information_schema ──────────────────
alter table public.productos
  add column if not exists manual_price_override boolean not null default false;

alter table public.productos
  add column if not exists precio_blister numeric not null default 0;

create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
set statement_timeout = '20s'
as $$
declare
  v_actor_id bigint;
  v_allowed  text[] := array[
    'nombre','sku','codigo_barras','categoria','subcategoria',
    'marca','tipo','descripcion','precio','costo','stock_minimo',
    'descuento_pct','imagen_url','imagen_mobile_url',
    'presentacion','principio_activo','denominacion_generica',
    'denominacion_distintiva','concentracion','forma_farmaceutica',
    'ubicacion_texto','laboratorio',
    'requiere_receta','notas','activo',
    'controlado','grupo_controlado','visible_tienda',
    'venta_unidad','unidades_por_caja','precio_unidad','stock_unidades',
    'piezas_por_blister','precio_blister','stock_blisters',
    'precio_similares','precio_del_ahorro','fecha_actualizacion_precios',
    'manual_price_override'
  ];
  v_cols      text[];
  v_key       text;
  v_set_parts text[] := array[]::text[];
  v_sql       text;
  v_count     int;
  v_id        bigint;
  v_precio    numeric;
  v_costo     numeric;
  v_precio_unidad numeric;
  v_precio_blister numeric;
  v_override  boolean;
  v_toca_precio boolean := false;
  v_did_proveedor boolean := false;
  v_prov jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if p_patch ? 'proveedor' then
    v_prov := public.admin_guardar_proveedor_producto(
      p_session_token,
      p_producto_id,
      p_patch->>'proveedor'
    );
    v_did_proveedor := true;
  end if;

  select coalesce(array_agg(a.attname::text), array[]::text[])
    into v_cols
  from pg_attribute a
  where a.attrelid = 'public.productos'::regclass
    and a.attnum > 0
    and not a.attisdropped;

  for v_key in select jsonb_object_keys(p_patch)
  loop
    if v_key = any(v_allowed) and v_key = any(v_cols) then
      if v_key in ('precio', 'costo', 'precio_unidad') then
        v_toca_precio := true;
      end if;
      v_set_parts := array_append(
        v_set_parts,
        format('%I = ($1 ->> %L)::text::%s',
               v_key, v_key,
               case v_key
                 when 'precio' then 'numeric'
                 when 'costo'  then 'numeric'
                 when 'descuento_pct' then 'numeric'
                 when 'precio_unidad' then 'numeric'
                 when 'precio_blister' then 'numeric'
                 when 'precio_similares' then 'numeric'
                 when 'precio_del_ahorro' then 'numeric'
                 when 'fecha_actualizacion_precios' then 'date'
                 when 'stock_minimo' then 'integer'
                 when 'unidades_por_caja' then 'integer'
                 when 'stock_unidades' then 'integer'
                 when 'piezas_por_blister' then 'integer'
                 when 'stock_blisters' then 'integer'
                 when 'activo' then 'boolean'
                 when 'requiere_receta' then 'boolean'
                 when 'controlado' then 'boolean'
                 when 'visible_tienda' then 'boolean'
                 when 'venta_unidad' then 'boolean'
                 when 'manual_price_override' then 'boolean'
                 else 'text'
               end
              )
      );
    end if;
  end loop;

  if v_toca_precio and 'manual_price_override' = any(v_cols)
     and not exists (
       select 1 from unnest(v_set_parts) s
       where s like 'manual_price_override =%'
     ) then
    v_set_parts := array_append(v_set_parts, 'manual_price_override = true');
  end if;

  if array_length(v_set_parts, 1) is null then
    if v_did_proveedor then
      return jsonb_build_object(
        'success', true,
        'proveedor', v_prov
      );
    end if;
    raise exception 'No hay campos permitidos para actualizar';
  end if;

  v_sql := format(
    'update public.productos set %s where id = $2',
    array_to_string(v_set_parts, ', ')
  );

  execute v_sql using p_patch, p_producto_id;
  get diagnostics v_count = row_count;
  if v_count = 0 then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  select p.id, p.precio, p.costo, p.precio_unidad, p.precio_blister, p.manual_price_override
    into v_id, v_precio, v_costo, v_precio_unidad, v_precio_blister, v_override
  from public.productos p
  where p.id = p_producto_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_producto', 'productos', p_producto_id::text, p_patch
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'producto', jsonb_build_object(
      'id', v_id,
      'precio', v_precio,
      'costo', v_costo,
      'precio_unidad', v_precio_unidad,
      'precio_blister', v_precio_blister,
      'manual_price_override', v_override
    ),
    'proveedor', v_prov
  );
end;
$$;

revoke all on function public.admin_editar_producto(uuid, bigint, jsonb) from public;
grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)
  to anon, authenticated;

-- ── Lotes por páginas (Inventario, Lotes PEPS, POS, Reabasto) ───────────────
create or replace function public.empleado_listar_lotes_inventario_pagina(
  p_session_token uuid,
  p_offset integer default 0,
  p_limite integer default 500
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
set statement_timeout = '20s'
as $$
declare
  v_dummy bigint;
  v_off integer := greatest(coalesce(p_offset, 0), 0);
  v_lim integer := greatest(1, least(coalesce(p_limite, 500), 800));
  v_filas jsonb := '[]'::jsonb;
  v_hay boolean := false;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  with page as (
    select
      l.id,
      l.producto_id,
      l.numero_lote,
      l.fecha_caducidad,
      l.cantidad_actual,
      l.costo_unitario,
      l.activo,
      l.fecha_recepcion,
      pr.id as prod_id,
      pr.nombre,
      pr.sku,
      pr.codigo_barras,
      pr.marca,
      pr.presentacion,
      pr.forma_farmaceutica,
      pr.categoria,
      pv.id as prov_id,
      pv.nombre as prov_nombre
    from public.lotes l
    join public.productos pr on pr.id = l.producto_id
    left join public.proveedores pv on pv.id = l.proveedor_id
    where l.activo is distinct from false
    order by l.id
    offset v_off
    limit v_lim + 1
  )
  select
    coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', s.id,
          'producto_id', s.producto_id,
          'numero_lote', s.numero_lote,
          'fecha_caducidad', s.fecha_caducidad,
          'cantidad_actual', s.cantidad_actual,
          'costo_unitario', s.costo_unitario,
          'activo', s.activo,
          'fecha_recepcion', s.fecha_recepcion,
          'productos', jsonb_build_object(
            'id', s.prod_id,
            'nombre', s.nombre,
            'sku', s.sku,
            'codigo_barras', s.codigo_barras,
            'marca', s.marca,
            'presentacion', s.presentacion,
            'forma_farmaceutica', s.forma_farmaceutica,
            'categoria', s.categoria
          ),
          'proveedores', case
            when s.prov_id is null then null
            else jsonb_build_object('id', s.prov_id, 'nombre', s.prov_nombre)
          end
        )
        order by s.id
      )
      from (
        select *
        from page
        order by id
        limit v_lim
      ) s
    ), '[]'::jsonb),
    (select count(*) > v_lim from page)
  into v_filas, v_hay;

  return jsonb_build_object(
    'filas', coalesce(v_filas, '[]'::jsonb),
    'hay_mas', coalesce(v_hay, false)
  );
end;
$$;

revoke all on function public.empleado_listar_lotes_inventario_pagina(uuid, integer, integer) from public;
grant execute on function public.empleado_listar_lotes_inventario_pagina(uuid, integer, integer)
  to anon, authenticated;

-- El RPC viejo sigue existiendo (POS en caché). Ya no hace to_jsonb(l.*).
create or replace function public.empleado_listar_lotes_inventario(
  p_session_token uuid
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
set statement_timeout = '20s'
as $$
declare
  v_off integer := 0;
  v_chunk jsonb;
  v_all jsonb := '[]'::jsonb;
  v_guard integer := 0;
begin
  loop
    v_guard := v_guard + 1;
    exit when v_guard > 40;
    v_chunk := public.empleado_listar_lotes_inventario_pagina(p_session_token, v_off, 500);
    v_all := v_all || coalesce(v_chunk->'filas', '[]'::jsonb);
    exit when coalesce((v_chunk->>'hay_mas')::boolean, false) is not true;
    v_off := v_off + 500;
  end loop;
  return v_all;
end;
$$;

revoke all on function public.empleado_listar_lotes_inventario(uuid) from public;
grant execute on function public.empleado_listar_lotes_inventario(uuid)
  to anon, authenticated;

-- ── Auditoría: un cambio de solo stock no arma el JSON de toda la ficha ─────
create or replace function public.fn_audit_trigger()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_actor_tipo text;
  v_actor_ip   text;
  v_old        jsonb;
  v_new        jsonb;
  v_pk         text;
  v_changed    text[];
  v_sens_cols  text[] := array['password_hash','salt','token','session_token','password'];
  v_col        text;
  v_cmp        text;
  v_real       boolean;
begin
  if tg_table_name = 'productos' and tg_op = 'UPDATE' then
    select string_agg(
      format('($1).%I is distinct from ($2).%I', a.attname, a.attname),
      ' or '
    )
      into v_cmp
    from pg_attribute a
    where a.attrelid = tg_relid
      and a.attnum > 0
      and not a.attisdropped
      and a.attname not in ('stock', 'updated_at');

    if v_cmp is not null then
      execute 'select ' || v_cmp into v_real using old, new;
      if not coalesce(v_real, false) then
        return new;
      end if;
    end if;
  end if;

  begin
    v_actor_id := nullif(current_setting('app.actor_id', true), '')::bigint;
  exception when others then v_actor_id := null; end;

  v_actor_tipo := nullif(current_setting('app.actor_tipo', true), '');
  v_actor_ip   := nullif(current_setting('app.actor_ip',   true), '');

  if (TG_OP = 'DELETE') then
    v_old := to_jsonb(OLD);
    v_new := null;
  elsif (TG_OP = 'INSERT') then
    v_old := null;
    v_new := to_jsonb(NEW);
  else
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
  end if;

  foreach v_col in array v_sens_cols
  loop
    if v_old is not null and v_old ? v_col then v_old := v_old - v_col; end if;
    if v_new is not null and v_new ? v_col then v_new := v_new - v_col; end if;
  end loop;

  if TG_OP = 'UPDATE' then
    select array_agg(key)
      into v_changed
    from (
      select key
      from jsonb_each(coalesce(v_new, '{}'::jsonb))
      where (v_new->key) is distinct from (v_old->key)
    ) t;

    if v_changed is null or array_length(v_changed, 1) is null then
      return coalesce(NEW, OLD);
    end if;
  end if;

  if TG_OP = 'DELETE' then
    v_pk := coalesce(v_old->>'id', null);
  else
    v_pk := coalesce(v_new->>'id', v_old->>'id');
  end if;

  insert into public.audit_log_detallado (
    tabla, operacion, registro_id,
    actor_id, actor_tipo, actor_ip,
    valores_antes, valores_despues, campos_cambiados
  ) values (
    TG_TABLE_NAME, TG_OP, v_pk,
    v_actor_id, v_actor_tipo, v_actor_ip,
    v_old, v_new, v_changed
  );

  return coalesce(NEW, OLD);
exception when others then
  return coalesce(NEW, OLD);
end;
$$;

revoke execute on function public.fn_audit_trigger() from public, anon, authenticated;

-- Un solo trigger de UPDATE. Si el viejo seguía siendo INSERT OR UPDATE OR DELETE,
-- dejarlo haría dos auditorías por cada precio.
drop trigger if exists trg_audit_productos on public.productos;
drop trigger if exists trg_audit_productos_upd on public.productos;

create trigger trg_audit_productos
  after insert or delete on public.productos
  for each row
  execute function public.fn_audit_trigger();

create trigger trg_audit_productos_upd
  after update on public.productos
  for each row
  execute function public.fn_audit_trigger();

notify pgrst, 'reload schema';

commit;
