-- Inventario no estaba grabando el precio del blister.
-- admin_editar_producto (la versión anterior a la venta por blister) ignora
-- precio_blister, piezas_por_blister y stock_blisters. El botón Guardar
-- responde bien y la pieza sí se queda, pero el blister vuelve al número
-- que dejó el SQL del punto medio.
--
-- Pegar TODO en Supabase → SQL Editor → Run.
-- Cafiaspirina Tartrato FC-08491096 queda en $20 (lo que ya escribiste).
-- El SELECT final tiene que mostrar precio_blister = 20.
-- Si sale 32, un trigger lo está reescribiendo: copia ese resultado.

begin;

-- Si algún trigger reescribe el blister al punto medio, quitarlo.
do $drop$
declare
  r record;
  v_src text;
begin
  for r in
    select t.tgname, p.oid as fn
      from pg_trigger t
      join pg_proc p on p.oid = t.tgfoid
      join pg_class c on c.oid = t.tgrelid
      join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public'
       and c.relname = 'productos'
       and not t.tgisinternal
  loop
    begin
      v_src := pg_get_functiondef(r.fn);
    exception when others then
      v_src := '';
    end;
    if v_src ~* 'new\.precio_blister\s*:='
       or v_src ilike '%precio_blister_intermedio%' then
      execute format('drop trigger if exists %I on public.productos', r.tgname);
    end if;
  end loop;
end
$drop$;

-- ── Inventario puede guardar las tres columnas ──────────────────────────────
-- Cuerpo vigente: patch_admin_guardar_proveedor_producto.sql
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
    'piezas_por_blister','precio_blister','stock_blisters',
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
      'precio_blister', v_row.precio_blister,
      'manual_price_override', v_row.manual_price_override
    ),
    'proveedor', v_prov
  );
end;
$$;

grant execute on function public.admin_editar_producto(uuid, bigint, jsonb)
  to anon, authenticated;


update public.productos
   set precio_blister = 20
 where sku = 'FC-08491096'
   and precio_blister = 32;

notify pgrst, 'reload schema';

commit;

select sku, precio as caja, precio_unidad as pieza, precio_blister,
       piezas_por_blister, stock_blisters, stock_unidades
  from public.productos
 where sku = 'FC-08491096';
