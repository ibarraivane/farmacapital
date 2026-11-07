-- Inventario: al quitar el laboratorio del nombre (AMSA, etc.) sale
-- "canceling statement due to statement timeout".
--
-- admin_editar_producto preguntaba information_schema.columns en cada
-- guardado. Esa vista revisa privilegios de todo el catálogo y, con el
-- tope de ~8 s de la API, Postgres cancela el UPDATE del nombre.
--
-- Ahora las columnas salen de pg_attribute (el catálogo de la tabla, al
-- instante). Si el renglón está tomado por una venta, espera 2 s y suelta
-- el candado para que la pantalla pueda reintentar, en vez de quedarse
-- los 8 s enteros.
--
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
-- No cambia precios, stock ni la whitelist de campos.

begin;

create or replace function public.admin_editar_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_patch         jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
set statement_timeout = '15s'
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
    'precio_similares','precio_del_ahorro','fecha_actualizacion_precios',
    'manual_price_override'
  ];
  v_cols      text[];
  v_key       text;
  v_set_parts text[] := array[]::text[];
  v_sql       text;
  v_count     int;
  v_row       public.productos%rowtype;
  v_toca_precio boolean := false;
  v_did_proveedor boolean := false;
  v_prov jsonb;
  v_lock_prev text;
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

  -- pg_attribute es el catálogo de esta tabla. information_schema.columns
  -- recorre privilegios de todas las columnas del proyecto y se come el timeout.
  select coalesce(array_agg(attname::text), array[]::text[])
    into v_cols
  from pg_attribute
  where attrelid = 'public.productos'::regclass
    and attnum > 0
    and not attisdropped;

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
    'update public.productos set %s where id = $2 returning *',
    array_to_string(v_set_parts, ', ')
  );

  -- Si una venta tiene el renglón, no esperar los 8 s del statement_timeout.
  v_lock_prev := current_setting('lock_timeout', true);
  begin
    perform set_config('lock_timeout', '2s', true);
    execute v_sql using p_patch, p_producto_id into v_row;
    get diagnostics v_count = row_count;
  exception
    when others then
      perform set_config('lock_timeout', coalesce(nullif(v_lock_prev, ''), '0'), true);
      raise;
  end;
  perform set_config('lock_timeout', coalesce(nullif(v_lock_prev, ''), '0'), true);
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

  return jsonb_build_object(
    'success', true,
    'producto', jsonb_build_object(
      'id', v_row.id,
      'precio', v_row.precio,
      'costo', v_row.costo,
      'precio_unidad', v_row.precio_unidad,
      'manual_price_override', v_row.manual_price_override
    ),
    'proveedor', v_prov
  );
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
