-- Inventario: el precio que pone el admin se queda.
-- 1) admin_editar_producto marca override y devuelve lo que quedó guardado.
-- 2) La regla de pieza ($7 en gasa C/100, etc.) ya no pisa un precio manual.
-- Ejecutar TODO en Supabase → SQL Editor → Run. Idempotente.

begin;

alter table public.productos
  add column if not exists manual_price_override boolean not null default false;

-- Pieza suelta: si el admin fijó el precio a mano, no subir al mínimo de la regla.
create or replace function public.trg_enforce_precio_unidad()
returns trigger
language plpgsql
as $$
begin
  if coalesce(new.venta_unidad, false)
     and coalesce(new.unidades_por_caja, 0) > 0 then
    if coalesce(new.manual_price_override, false) then
      if coalesce(new.precio_unidad, 0) <= 0 then
        new.precio_unidad := public.precio_unidad_efectivo(
          new.costo, new.precio, new.unidades_por_caja,
          new.categoria, new.tipo, new.precio_unidad
        );
      end if;
    else
      new.precio_unidad := public.precio_unidad_efectivo(
        new.costo, new.precio, new.unidades_por_caja,
        new.categoria, new.tipo, new.precio_unidad
      );
    end if;
  elsif not coalesce(new.venta_unidad, false) then
    new.precio_unidad := 0;
    new.unidades_por_caja := 0;
  end if;
  return new;
end;
$$;

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
begin
  v_actor_id := public.fn_require_admin(p_session_token);

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
    )
  );
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
