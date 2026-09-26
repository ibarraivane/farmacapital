-- FarmaCapital — Cotizaciones: foto del catálogo y poder quitar un producto.
-- Ejecutar TODO el archivo en Supabase → SQL Editor → Run. Idempotente.
--
-- Complementa sql/patch_cotizaciones_20260921.sql. No cambia costos ni precios.

begin;

create or replace function public._cotizacion_item_json(p_id bigint, p_con_fuentes boolean default true)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'id', i.id,
    'cotizacion_id', i.cotizacion_id,
    'texto', i.texto,
    'producto_id', i.producto_id,
    'producto_nombre', p.nombre,
    'marca', p.marca,
    'presentacion', p.presentacion,
    'imagen_url', p.imagen_url,
    'ean', i.ean,
    'cantidad', i.cantidad,
    'tipo_margen', i.tipo_margen,
    'fuente_elegida_id', i.fuente_elegida_id,
    'costo_elegido', i.costo_elegido,
    'precio_venta', i.precio_venta,
    'estado', i.estado,
    'notas', i.notas,
    'created_at', i.created_at,
    'updated_at', i.updated_at,
    'fuentes', case
      when p_con_fuentes then coalesce((
        select jsonb_agg(jsonb_build_object(
          'id', f.id,
          'item_id', f.item_id,
          'lugar', f.lugar,
          'precio', f.precio,
          'url', f.url,
          'sku_externo', f.sku_externo,
          'disponible', f.disponible,
          'elegida', f.elegida,
          'notas', f.notas,
          'created_at', f.created_at
        ) order by f.elegida desc, f.precio asc, f.id)
        from public.cotizacion_fuentes f
        where f.item_id = i.id
      ), '[]'::jsonb)
      else '[]'::jsonb
    end
  )
  from public.cotizacion_items i
  left join public.productos p on p.id = i.producto_id
  where i.id = p_id;
$$;


create or replace function public.admin_buscar_productos_cotizacion(
  p_session_token uuid,
  p_busqueda text,
  p_limite int default 8
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_q text;
  v_lim int;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  v_q := trim(coalesce(p_busqueda, ''));
  v_lim := greatest(1, least(coalesce(p_limite, 8), 20));
  if length(v_q) < 2 then
    return '[]'::jsonb;
  end if;
  return coalesce((
    select jsonb_agg(to_jsonb(r) order by r.nombre)
    from (
      select
        p.id,
        p.nombre,
        p.marca,
        p.presentacion,
        p.sku,
        p.codigo_barras,
        p.imagen_url,
        round(coalesce(p.precio, 0), 2) as precio,
        coalesce(p.stock, 0) as stock
      from public.productos p
      where coalesce(p.activo, true) = true
        and (
          p.nombre ilike '%' || v_q || '%'
          or coalesce(p.marca, '') ilike '%' || v_q || '%'
          or coalesce(p.sku, '') ilike '%' || v_q || '%'
          or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
             like '%' || regexp_replace(v_q, '\D', '', 'g') || '%'
        )
      order by p.nombre
      limit v_lim
    ) r
  ), '[]'::jsonb);
end;
$$;


create or replace function public.admin_ligar_producto_cotizacion(
  p_session_token uuid,
  p_item_id       bigint,
  p_producto_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cotiz bigint;
  v_ean   text;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = p_item_id;
  if v_cotiz is null then
    raise exception 'Renglón no encontrado';
  end if;
  if p_producto_id is not null and not exists (
    select 1 from public.productos p where p.id = p_producto_id
  ) then
    raise exception 'Producto no encontrado en el catálogo';
  end if;

  select nullif(regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g'), '')
    into v_ean
  from public.productos p
  where p.id = p_producto_id;

  update public.cotizacion_items i
  set
    producto_id = p_producto_id,
    ean = case
      when p_producto_id is null then i.ean
      when v_ean is null or length(v_ean) < 8 then i.ean
      else v_ean
    end,
    updated_at = now()
  where i.id = p_item_id;

  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;


-- Se puede quitar el último renglón. La cotización queda vacía hasta agregar otro.
create or replace function public.admin_eliminar_cotizacion_item(
  p_session_token uuid,
  p_id            bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cotiz bigint;
begin
  v_dummy := public.fn_require_admin(p_session_token);
  select i.cotizacion_id into v_cotiz from public.cotizacion_items i where i.id = p_id;
  if v_cotiz is null then
    raise exception 'Renglón no encontrado';
  end if;
  delete from public.cotizacion_items where id = p_id;
  update public.cotizaciones set updated_at = now() where id = v_cotiz;
  return public._cotizacion_json(v_cotiz, true);
end;
$$;

grant execute on function public.admin_buscar_productos_cotizacion(uuid, text, int)
  to anon, authenticated;
grant execute on function public.admin_ligar_producto_cotizacion(uuid, bigint, bigint)
  to anon, authenticated;
grant execute on function public.admin_eliminar_cotizacion_item(uuid, bigint)
  to anon, authenticated;

commit;
