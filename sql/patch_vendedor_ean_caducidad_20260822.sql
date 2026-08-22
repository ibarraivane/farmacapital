-- Vendedores: pueden guardar EAN faltante y corregir caducidad.
-- Precio/costo siguen exigiendo admin (admin_editar_producto).
-- Ejecutar en Supabase → SQL Editor → Run. Idempotente.

begin;

-- Caducidad: mismo cuerpo; el actor puede ser cualquier empleado activo.
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
  v_actor := public.fn_require_empleado(p_session_token);

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

comment on function public.admin_guardar_caducidad_producto(uuid, bigint, date, bigint) is
  'Guarda o quita caducidad de lote. Empleado activo (piso o admin). No inventa MMAA.';

grant execute on function public.admin_guardar_caducidad_producto(uuid, bigint, date, bigint)
  to anon, authenticated;


create or replace function public.empleado_guardar_codigo_barras(
  p_session_token uuid,
  p_producto_id   bigint,
  p_codigo_barras text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_cb    text;
  v_otro  bigint;
  v_n     int;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_producto_id is null then
    return jsonb_build_object('success', false, 'error', 'Producto requerido');
  end if;

  v_cb := regexp_replace(coalesce(p_codigo_barras, ''), '[^0-9]', '', 'g');
  if length(v_cb) < 8 or length(v_cb) > 14 then
    return jsonb_build_object('success', false, 'error', 'Usa 8–14 dígitos (EAN/UPC)');
  end if;

  select p.id into v_otro
  from public.productos p
  where p.id is distinct from p_producto_id
    and regexp_replace(coalesce(p.codigo_barras, ''), '[^0-9]', '', 'g') = v_cb
  limit 1;

  if v_otro is not null then
    return jsonb_build_object(
      'success', false,
      'error', 'Ese código ya está en otro producto',
      'producto_id', v_otro
    );
  end if;

  update public.productos
     set codigo_barras = v_cb
   where id = p_producto_id;

  get diagnostics v_n = row_count;
  if v_n = 0 then
    return jsonb_build_object('success', false, 'error', 'Producto no encontrado');
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'editar_producto',
      'productos',
      p_producto_id::text,
      jsonb_build_object('codigo_barras', v_cb)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'codigo_barras', v_cb);
end;
$$;

comment on function public.empleado_guardar_codigo_barras(uuid, bigint, text) is
  'Piso: agrega o corrige EAN. No toca precio ni costo.';

grant execute on function public.empleado_guardar_codigo_barras(uuid, bigint, text)
  to anon, authenticated;

commit;
