-- Permite quitar fecha_caducidad de un lote (productos sin caducidad o corrección).
-- Ejecutar en Supabase SQL Editor.

create or replace function public.admin_editar_lote(
  p_session_token uuid,
  p_lote_id       bigint,
  p_fecha_caducidad date default null,
  p_numero_lote   text default null,
  p_quitar_caducidad boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_prev record;
  v_fecha_despues date;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select id, producto_id, numero_lote, fecha_caducidad
  into v_prev
  from public.lotes
  where id = p_lote_id and coalesce(activo, true) = true;

  if not found then
    raise exception 'Lote % no encontrado o inactivo', p_lote_id;
  end if;

  v_fecha_despues := case
    when p_quitar_caducidad then null
    when p_fecha_caducidad is not null then p_fecha_caducidad
    else v_prev.fecha_caducidad
  end;

  update public.lotes
  set
    fecha_caducidad = v_fecha_despues,
    numero_lote = coalesce(nullif(btrim(p_numero_lote), ''), numero_lote)
  where id = p_lote_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_lote',
      'lotes',
      p_lote_id::text,
      jsonb_build_object(
        'producto_id', v_prev.producto_id,
        'fecha_caducidad_antes', v_prev.fecha_caducidad,
        'fecha_caducidad_despues', v_fecha_despues,
        'numero_lote_antes', v_prev.numero_lote,
        'numero_lote_despues', coalesce(nullif(btrim(p_numero_lote), ''), v_prev.numero_lote),
        'quitar_caducidad', p_quitar_caducidad
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'lote_id', p_lote_id);
end;
$$;

grant execute on function public.admin_editar_lote(uuid, bigint, date, text, boolean) to anon, authenticated;


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
      set fecha_caducidad = null
      where id = v_lid;

      return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'quitar');
    end if;

    select l.id, l.fecha_caducidad
    into v_lid, v_prev
    from public.lotes l
    where l.producto_id = p_producto_id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
    order by l.fecha_caducidad nulls first, l.fecha_caducidad asc, l.id asc
    limit 1;

    if v_lid is null then
      select l.id, l.fecha_caducidad
      into v_lid, v_prev
      from public.lotes l
      where l.producto_id = p_producto_id
        and coalesce(l.activo, true) = true
      order by l.id asc
      limit 1;
    end if;

    if v_lid is null then
      raise exception 'No hay lote para quitar la caducidad';
    end if;

    update public.lotes
    set fecha_caducidad = null
    where id = v_lid;

    return jsonb_build_object('success', true, 'lote_id', v_lid, 'accion', 'quitar');
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

  v_numero := coalesce(
    nullif(btrim(v_sku), ''),
    p_producto_id::text
  );

  if coalesce(v_stock, 0) <= 0 then
    v_numero := 'REF-' || v_numero || '-' || to_char(now(), 'YYYYMMDD');

    insert into public.lotes (
      producto_id, numero_lote, cantidad_inicial, cantidad_actual,
      fecha_caducidad, costo_unitario, activo
    ) values (
      p_producto_id, v_numero, 0, 0,
      p_fecha_caducidad, coalesce(v_costo, 0), true
    )
    returning id into v_lid;

    return jsonb_build_object(
      'success', true,
      'lote_id', v_lid,
      'accion', 'crear_referencia',
      'cantidad', 0
    );
  end if;

  v_numero := 'INV-' || v_numero || '-' || to_char(now(), 'YYYYMMDD');

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
