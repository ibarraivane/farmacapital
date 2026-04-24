-- FARMAX — productos.imagen_mobile_url + RPCs
-- Ejecutar en Supabase después de patch_tienda_imagenes_banners_productos.sql (u otras migraciones de productos).
-- Permite guardar URL de variante móvil (Storage) además de imagen_url.

alter table public.productos add column if not exists imagen_url text;
alter table public.productos add column if not exists imagen_mobile_url text;

comment on column public.productos.imagen_url is 'URL pública foto principal del producto (tienda)';
comment on column public.productos.imagen_mobile_url is 'URL pública foto recorte/tamaño móvil (tienda); si null, usar imagen_url';

-- ============================================================
-- admin_editar_producto — whitelist imagen_mobile_url
-- (misma lógica que refactor_fase6b_patch_producto_fields.sql)
-- ============================================================
create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_allowed  text[] := array[
    'nombre','sku','codigo_barras','categoria','subcategoria',
    'marca','tipo','descripcion','precio','costo','stock_minimo',
    'proveedor','descuento_pct','imagen_url','imagen_mobile_url','presentacion',
    'principio_activo','requiere_receta','notas','activo',
    'controlado','grupo_controlado','visible_tienda',
    'venta_unidad','unidades_por_caja','precio_unidad','stock_unidades',
    'precio_similares','precio_del_ahorro','fecha_actualizacion_precios'
  ];
  v_cols      text[];
  v_key       text;
  v_set_parts text[] := array[]::text[];
  v_sql       text;
  v_count     int;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  select array_agg(column_name::text) into v_cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'productos';

  for v_key in select jsonb_object_keys(p_patch)
  loop
    if v_key = any(v_allowed) and v_key = any(v_cols) then
      v_set_parts := array_append(
        v_set_parts,
        format('%I = ($1 ->> %L)::text::%s',
               v_key, v_key,
               case v_key
                 when 'precio' then 'numeric'
                 when 'costo'  then 'numeric'
                 when 'descuento_pct' then 'numeric'
                 when 'precio_unidad' then 'numeric'
                 when 'precio_similares' then 'numeric'
                 when 'precio_del_ahorro' then 'numeric'
                 when 'fecha_actualizacion_precios' then 'date'
                 when 'stock_minimo' then 'integer'
                 when 'unidades_por_caja' then 'integer'
                 when 'stock_unidades' then 'integer'
                 when 'activo' then 'boolean'
                 when 'requiere_receta' then 'boolean'
                 when 'controlado' then 'boolean'
                 when 'visible_tienda' then 'boolean'
                 when 'venta_unidad' then 'boolean'
                 else 'text'
               end
              )
      );
    end if;
  end loop;

  if array_length(v_set_parts, 1) is null then
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

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'editar_producto', 'productos', p_producto_id::text, p_patch
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb) to anon, authenticated;

-- ============================================================
-- create_producto_with_lote — incluir imagen_mobile_url al alta
-- (compatible con cuerpo de patch_tienda_imagenes_banners_productos.sql)
-- ============================================================
create or replace function public.create_producto_with_lote(
  p_producto_data jsonb,
  p_cantidad_inicial integer default 0,
  p_numero_lote text default null,
  p_fecha_caducidad date default null,
  p_costo_unitario numeric default null,
  p_user_id bigint default null
)
returns table(producto_id bigint, lote_id bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_producto_id bigint;
  v_lote_id bigint := null;
  v_lote_numero text;
begin
  if p_producto_data is null then
    raise exception 'producto_data requerido';
  end if;
  if (p_producto_data->>'nombre') is null or btrim(p_producto_data->>'nombre') = '' then
    raise exception 'nombre requerido';
  end if;

  insert into public.productos (
    nombre, sku, codigo_barras, categoria, tipo, descripcion,
    precio, costo, precio_unidad, precio_similares, precio_del_ahorro,
    stock, stock_minimo, stock_unidades, unidades_por_caja,
    venta_unidad, proveedor, descuento_pct,
    receta, requiere_receta, activo, imagen_url, imagen_mobile_url
  ) values (
    p_producto_data->>'nombre',
    p_producto_data->>'sku',
    p_producto_data->>'codigo_barras',
    p_producto_data->>'categoria',
    p_producto_data->>'tipo',
    p_producto_data->>'descripcion',
    nullif(p_producto_data->>'precio', '')::numeric,
    nullif(p_producto_data->>'costo', '')::numeric,
    nullif(p_producto_data->>'precio_unidad', '')::numeric,
    nullif(p_producto_data->>'precio_similares', '')::numeric,
    nullif(p_producto_data->>'precio_del_ahorro', '')::numeric,
    0,
    coalesce(nullif(p_producto_data->>'stock_minimo', '')::integer, 0),
    coalesce(nullif(p_producto_data->>'stock_unidades', '')::integer, 0),
    nullif(p_producto_data->>'unidades_por_caja', '')::integer,
    coalesce(nullif(p_producto_data->>'venta_unidad', '')::boolean, false),
    p_producto_data->>'proveedor',
    coalesce(nullif(p_producto_data->>'descuento_pct', '')::numeric, 0),
    nullif(p_producto_data->>'receta', '')::boolean,
    nullif(p_producto_data->>'requiere_receta', '')::boolean,
    coalesce(nullif(p_producto_data->>'activo', '')::boolean, true),
    nullif(trim(p_producto_data->>'imagen_url'), ''),
    nullif(trim(p_producto_data->>'imagen_mobile_url'), '')
  ) returning id into v_producto_id;

  if coalesce(p_cantidad_inicial, 0) > 0 then
    v_lote_numero := coalesce(
      p_numero_lote,
      'INICIAL-' || to_char(now(), 'YYYYMMDD-HH24MISS')
    );

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      v_producto_id,
      v_lote_numero,
      p_cantidad_inicial, p_cantidad_inicial,
      p_fecha_caducidad,
      coalesce(p_costo_unitario, nullif(p_producto_data->>'costo', '')::numeric),
      true
    ) returning id into v_lote_id;

    insert into public.movimientos_inventario (
      producto_id, tipo, cantidad, motivo, usuario_id
    ) values (
      v_producto_id, 'entrada', p_cantidad_inicial,
      'Alta de producto con stock inicial',
      p_user_id
    );
  end if;

  return query select v_producto_id, v_lote_id;
end;
$$;

grant execute on function public.create_producto_with_lote(
  jsonb, integer, text, date, numeric, bigint
) to service_role;
