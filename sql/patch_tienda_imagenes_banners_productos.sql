-- FARMAX — Imágenes en tienda: columnas en BD + RPCs
-- Ejecutar en Supabase SQL Editor DESPUÉS de sql/storage_farmax_tienda.sql (buckets + políticas).
--
-- Incluye:
--   • banners.imagen_url, banners.imagen_mobile_url
--   • productos.imagen_url (si no existe)
--   • admin_upsert_banner con soporte imagen
--   • create_producto_with_lote incluye imagen_url en el INSERT

alter table public.banners add column if not exists imagen_url text;
alter table public.banners add column if not exists imagen_mobile_url text;

alter table public.productos add column if not exists imagen_url text;

comment on column public.banners.imagen_url is 'URL pública (Storage) imagen desktop / principal del banner';
comment on column public.banners.imagen_mobile_url is 'URL pública imagen móvil opcional';
comment on column public.productos.imagen_url is 'URL pública foto principal del producto (tienda)';

-- ============================================================
-- admin_upsert_banner (imágenes + limpieza de claves en patch)
-- ============================================================
create or replace function public.admin_upsert_banner(
  p_session_token uuid,
  p_id            bigint,
  p_payload       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_actor bigint; v_banner_id bigint;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_id is null then
    insert into public.banners (
      titulo, subtitulo, descripcion, emoji, bg, cta, pagina, orden, activo, slot,
      imagen_url, imagen_mobile_url
    )
    values (
      p_payload->>'titulo', p_payload->>'subtitulo', p_payload->>'descripcion',
      p_payload->>'emoji', p_payload->>'bg', p_payload->>'cta',
      p_payload->>'pagina', coalesce((p_payload->>'orden')::int, 0),
      coalesce((p_payload->>'activo')::boolean, true),
      coalesce(p_payload->>'slot', 'hero'),
      nullif(trim(p_payload->>'imagen_url'), ''),
      nullif(trim(p_payload->>'imagen_mobile_url'), '')
    ) returning id into v_banner_id;
  else
    update public.banners set
      titulo      = coalesce(p_payload->>'titulo', titulo),
      subtitulo   = coalesce(p_payload->>'subtitulo', subtitulo),
      descripcion = coalesce(p_payload->>'descripcion', descripcion),
      emoji       = coalesce(p_payload->>'emoji', emoji),
      bg          = coalesce(p_payload->>'bg', bg),
      cta         = coalesce(p_payload->>'cta', cta),
      pagina      = coalesce(p_payload->>'pagina', pagina),
      orden       = coalesce((p_payload->>'orden')::int, orden),
      activo      = coalesce((p_payload->>'activo')::boolean, activo),
      slot        = coalesce(p_payload->>'slot', slot),
      imagen_url = case when p_payload ? 'imagen_url'
        then nullif(trim(p_payload->>'imagen_url'), '') else imagen_url end,
      imagen_mobile_url = case when p_payload ? 'imagen_mobile_url'
        then nullif(trim(p_payload->>'imagen_mobile_url'), '') else imagen_mobile_url end
    where id = p_id;
    if not found then raise exception 'Banner % no encontrado', p_id; end if;
    v_banner_id := p_id;
  end if;

  return jsonb_build_object('success', true, 'banner_id', v_banner_id);
end;
$$;

-- ============================================================
-- create_producto_with_lote — incluir imagen_url
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
    receta, requiere_receta, activo, imagen_url
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
    nullif(trim(p_producto_data->>'imagen_url'), '')
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
) to anon, authenticated, service_role;
