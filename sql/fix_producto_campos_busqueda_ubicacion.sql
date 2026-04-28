-- FARMAX: campos farmacéuticos de búsqueda + ubicación física en productos.
-- Idempotente y seguro: agrega columnas faltantes y amplía whitelist del RPC admin_editar_producto.

begin;

alter table if exists public.productos
  add column if not exists denominacion_generica text,
  add column if not exists denominacion_distintiva text,
  add column if not exists concentracion text,
  add column if not exists forma_farmaceutica text,
  add column if not exists ubicacion_texto text;

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
    'proveedor','descuento_pct','imagen_url','imagen_mobile_url',
    'presentacion','principio_activo','denominacion_generica',
    'denominacion_distintiva','concentracion','forma_farmaceutica',
    'ubicacion_texto',
    'requiere_receta','notas','activo',
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

commit;
