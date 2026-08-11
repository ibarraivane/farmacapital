-- Guarda caducidad por producto: encuentra el lote en servidor (sin depender del JOIN en cliente).
-- Si hay lote activo → actualiza fecha. Si no hay lote pero hay stock → crea lote sin sumar unidades.

create or replace function public.admin_guardar_caducidad_producto(
  p_session_token   uuid,
  p_producto_id     bigint,
  p_fecha_caducidad date,
  p_lote_id         bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_lid bigint;
  v_stock integer;
  v_costo numeric;
  v_sku text;
  v_numero text;
  v_prev date;
begin
  v_actor := public.fn_require_admin(p_session_token);

  if p_fecha_caducidad is null then
    raise exception 'Fecha de caducidad requerida';
  end if;

  if p_lote_id is not null then
    select l.id, l.fecha_caducidad
    into v_lid, v_prev
    from public.lotes l
    where l.id = p_lote_id
      and l.producto_id = p_producto_id
      and coalesce(l.activo, true) = true;

    if not found then
      raise exception 'Lote % no encontrado para este producto', p_lote_id;
    end if;

    update public.lotes
    set fecha_caducidad = p_fecha_caducidad
    where id = v_lid;

    return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'editar');
  end if;

  select l.id, l.fecha_caducidad
  into v_lid, v_prev
  from public.lotes l
  where l.producto_id = p_producto_id
    and coalesce(l.activo, true) = true
    and coalesce(l.cantidad_actual, 0) > 0
  order by l.fecha_caducidad nulls first, l.fecha_caducidad asc, l.id asc
  limit 1;

  if v_lid is not null then
    if v_prev is not distinct from p_fecha_caducidad then
      return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'sin_cambio');
    end if;

    update public.lotes
    set fecha_caducidad = p_fecha_caducidad
    where id = v_lid;

    return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'editar');
  end if;

  select l.id, l.fecha_caducidad
  into v_lid, v_prev
  from public.lotes l
  where l.producto_id = p_producto_id
    and coalesce(l.activo, true) = true
  order by l.id asc
  limit 1;

  if v_lid is not null then
    update public.lotes
    set fecha_caducidad = p_fecha_caducidad
    where id = v_lid;

    return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'editar_lote_inactivo');
  end if;

  select p.stock, p.costo, p.sku
  into v_stock, v_costo, v_sku
  from public.productos p
  where p.id = p_producto_id
  for update;

  if not found then
    raise exception 'Producto % no existe', p_producto_id;
  end if;

  if coalesce(v_stock, 0) <= 0 then
    raise exception 'Sin lote ni stock — usá Recibir mercancía';
  end if;

  v_numero := 'INV-' || coalesce(nullif(btrim(v_sku), ''), p_producto_id::text) || '-' || to_char(now(), 'YYYYMMDD');

  insert into public.lotes (
    producto_id, numero_lote, cantidad_inicial, cantidad_actual,
    fecha_caducidad, costo_unitario, activo
  ) values (
    p_producto_id, v_numero, v_stock, v_stock,
    p_fecha_caducidad, coalesce(v_costo, 0), true
  )
  returning id into v_lid;

  return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'crear', 'cantidad', v_stock);
end;
$$;

grant execute on function public.admin_guardar_caducidad_producto(uuid, bigint, date, bigint) to anon, authenticated;
