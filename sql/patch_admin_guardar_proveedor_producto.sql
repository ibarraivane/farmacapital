-- Inventario: el "Proveedor" de la tabla no es productos.proveedor
-- (esa columna no existe). Vive en lotes.proveedor_id → proveedores.nombre.
--
-- Sintoma: al editar la celda, "No hay campos permitidos para actualizar".
-- Este patch:
--   1) admin_guardar_proveedor_producto — escribe el lote (y completa quién
--      de última compra si ya hay precio).
--   2) admin_editar_producto — si el patch trae solo/también "proveedor",
--      lo desvía al lote en vez de fallar.
--
-- Ejecutar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.fc_resolver_proveedor_tienda(p_nombre text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
  v_nombre text;
begin
  v_nombre := nullif(btrim(p_nombre), '');
  if v_nombre is null then
    return null;
  end if;

  select p.id
  into v_id
  from public.proveedores p
  where lower(btrim(p.nombre)) = lower(v_nombre)
  limit 1;

  if v_id is not null then
    return v_id;
  end if;

  insert into public.proveedores (nombre, activo)
  values (v_nombre, true)
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.admin_guardar_proveedor_producto(
  p_session_token uuid,
  p_producto_id   bigint,
  p_proveedor     text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_nombre text;
  v_proveedor_id bigint;
  v_lotes int := 0;
  v_lid bigint;
  v_stock integer;
  v_costo numeric;
  v_sku text;
  v_numero text;
  v_accion text := 'editar';
  v_precio numeric;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if not exists (select 1 from public.productos where id = p_producto_id) then
    raise exception 'Producto % no encontrado', p_producto_id;
  end if;

  v_nombre := nullif(btrim(coalesce(p_proveedor, '')), '');
  if v_nombre is not null and lower(v_nombre) = 'sin proveedor' then
    v_nombre := null;
  end if;
  v_proveedor_id := public.fc_resolver_proveedor_tienda(v_nombre);

  update public.lotes
  set proveedor_id = v_proveedor_id
  where producto_id = p_producto_id
    and coalesce(activo, true) = true;
  get diagnostics v_lotes = row_count;

  if v_lotes = 0 and v_proveedor_id is not null then
    select p.stock, p.costo, p.sku
    into v_stock, v_costo, v_sku
    from public.productos p
    where p.id = p_producto_id
    for update;

    v_numero := coalesce(nullif(btrim(v_sku), ''), p_producto_id::text);

    if coalesce(v_stock, 0) <= 0 then
      v_numero := 'REF-' || v_numero || '-' || to_char(now(), 'YYYYMMDD');
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        costo_unitario, proveedor_id, activo
      ) values (
        p_producto_id, v_numero, 0, 0,
        coalesce(v_costo, 0), v_proveedor_id, true
      )
      returning id into v_lid;
      v_accion := 'crear_referencia';
    else
      v_numero := 'INV-' || v_numero || '-' || to_char(now(), 'YYYYMMDD');
      insert into public.lotes (
        producto_id, numero_lote, cantidad_inicial, cantidad_actual,
        costo_unitario, proveedor_id, activo
      ) values (
        p_producto_id, v_numero, v_stock, v_stock,
        coalesce(v_costo, 0), v_proveedor_id, true
      )
      returning id into v_lid;
      v_accion := 'crear';
    end if;
    v_lotes := 1;
  elsif v_lotes = 0 then
    v_accion := 'sin_lote';
  end if;

  if v_nombre is not null
     and to_regclass('public.producto_precios_referencia') is not null
     and to_regclass('public.producto_precios_referencia_actual') is not null then
    select a.precio
      into v_precio
    from public.producto_precios_referencia_actual a
    where a.producto_id = p_producto_id
      and a.fuente = 'ultima_compra'
      and a.precio is not null
      and a.precio > 0
    limit 1;

    if v_precio is not null then
      insert into public.producto_precios_referencia (
        producto_id, fuente, tipo, precio, fecha, nombre_fuente,
        confianza, origen, notas
      )
      select
        p_producto_id,
        'ultima_compra',
        'compra',
        v_precio,
        current_date,
        v_nombre,
        100,
        'manual',
        'edicion inventario proveedor'
      where not exists (
        select 1
        from public.producto_precios_referencia_actual a
        where a.producto_id = p_producto_id
          and a.fuente = 'ultima_compra'
          and lower(btrim(coalesce(a.nombre_fuente, ''))) = lower(v_nombre)
      );
    end if;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'guardar_proveedor_producto',
      'lotes',
      p_producto_id::text,
      jsonb_build_object(
        'proveedor', v_nombre,
        'proveedor_id', v_proveedor_id,
        'lotes', v_lotes,
        'accion', v_accion
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'proveedor', v_nombre,
    'proveedor_id', v_proveedor_id,
    'lotes', v_lotes,
    'lote_id', v_lid,
    'accion', v_accion
  );
end;
$$;

grant execute on function public.fc_resolver_proveedor_tienda(text)
  to anon, authenticated, service_role;
grant execute on function public.admin_guardar_proveedor_producto(uuid, bigint, text)
  to anon, authenticated;

-- Misma whitelist que patch_precio_manual + laboratorio.
-- Si el único campo es proveedor, ya no truena: se guarda en el lote.
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

  select array_agg(column_name::text) into v_cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'productos';

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

  execute v_sql using p_patch, p_producto_id into v_row;
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
