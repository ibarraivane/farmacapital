-- Fix: Compra de personal → "Mandar a aprobación"
-- Error: column reference "id" is ambiguous
--
-- Causa: empleado_personal_compra_solicitar RETURNS TABLE(id bigint, ...),
-- lo que declara `id` como variable de salida. Un `select id from caja_sesiones`
-- (y `where id =` en empleados) choca con esa variable.
--
-- Pegar en Supabase → SQL Editor. No requiere deploy del frontend.

begin;

create or replace function public.empleado_personal_compra_solicitar(
  p_session_token uuid,
  p_empleado_beneficiario_id bigint,
  p_cart_items jsonb
)
returns table(
  id bigint,
  total_final numeric,
  excede_tope_mensual boolean,
  excede_limite_producto boolean
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_item jsonb;
  v_producto_id bigint;
  v_cantidad integer;
  v_precio numeric;
  v_costo numeric;
  v_costo_estimado boolean;
  v_margen_pct numeric;
  v_margen_minimo numeric;
  v_tope_descuento numeric;
  v_tope_unidades integer;
  v_tope_mensual numeric;
  v_descuento_pct numeric;
  v_descuento_monto numeric;
  v_precio_final numeric;
  v_items jsonb := '[]'::jsonb;
  v_total_lista numeric := 0;
  v_total_descuento numeric := 0;
  v_total_final numeric := 0;
  v_excede_limite_producto boolean := false;
  v_excede_tope_mensual boolean := false;
  v_uso_mensual numeric := 0;
  v_nombre text;
  v_sku text;
  v_id bigint;
  v_caja_sesion_id bigint;
  v_nombre_beneficiario text;
begin
  v_user_id := public.fn_require_caja_abierta_vendedor(p_session_token);

  if p_empleado_beneficiario_id is null then
    raise exception 'Selecciona a qué empleado corresponde la compra';
  end if;

  -- Calificar e.id / cs.id: RETURNS TABLE declara `id` como OUT y Postgres
  -- lo trata como variable local (error "column reference id is ambiguous").
  select e.nombre into v_nombre_beneficiario
    from public.empleados e where e.id = p_empleado_beneficiario_id;
  if v_nombre_beneficiario is null then
    raise exception 'Empleado beneficiario no encontrado';
  end if;

  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array'
     or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'El carrito está vacío';
  end if;

  select coalesce(nullif(valor,'')::numeric, 10) into v_margen_minimo
    from public.configuracion where clave = 'margen_minimo_empleado';
  v_margen_minimo := coalesce(v_margen_minimo, 10);

  select coalesce(nullif(valor,'')::numeric, 20) into v_tope_descuento
    from public.configuracion where clave = 'tope_descuento_empleado';
  v_tope_descuento := coalesce(v_tope_descuento, 20);

  select coalesce(nullif(valor,'')::integer, 1) into v_tope_unidades
    from public.configuracion where clave = 'tope_unidades_mismo_producto_empleado';
  v_tope_unidades := coalesce(v_tope_unidades, 1);

  select coalesce(nullif(valor,'')::numeric, 200) into v_tope_mensual
    from public.configuracion where clave = 'tope_mensual_descuento_empleado';
  v_tope_mensual := coalesce(v_tope_mensual, 200);

  select cs.id into v_caja_sesion_id from public.caja_sesiones cs
    where cs.empleado_id = v_user_id and cs.estado = 'abierta'
    order by cs.abierta_at desc limit 1;

  for v_item in select value from jsonb_array_elements(p_cart_items)
  loop
    v_producto_id := nullif(v_item->>'producto_id','')::bigint;
    v_cantidad := nullif(v_item->>'cantidad','')::integer;
    if v_producto_id is null or v_cantidad is null or v_cantidad <= 0 then
      raise exception 'Renglón de carrito inválido';
    end if;
    if v_cantidad > v_tope_unidades then
      v_excede_limite_producto := true;
    end if;

    select p.nombre, p.sku, coalesce(p.precio,0)
      into v_nombre, v_sku, v_precio
      from public.productos p where p.id = v_producto_id;
    if not found then
      raise exception 'Producto % no existe', v_producto_id;
    end if;

    -- Costo: primero el lote FEFO vigente con costo conocido (el que de
    -- verdad se va a consumir al cobrar); si no hay, cae a productos.costo.
    v_costo := null;
    v_costo_estimado := true;
    select l.costo_unitario into v_costo
      from public.lotes l
      where l.producto_id = v_producto_id
        and coalesce(l.activo,true) = true
        and coalesce(l.cantidad_actual,0) > 0
        and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
        and l.costo_unitario is not null
      order by l.fecha_caducidad asc nulls last, l.id asc
      limit 1;
    if found and v_costo is not null then
      v_costo_estimado := false;
    else
      select coalesce(p.costo,0) into v_costo from public.productos p where p.id = v_producto_id;
    end if;

    if v_precio is null or v_precio <= 0 or v_costo is null or v_costo <= 0 then
      v_margen_pct := 0;
    else
      v_margen_pct := round(greatest(0, (v_precio - v_costo) / v_precio) * 100, 2);
    end if;

    v_descuento_pct := least(greatest(v_margen_pct - v_margen_minimo, 0), v_tope_descuento);
    v_precio_final := round(v_precio - (v_precio * v_descuento_pct / 100), 2);
    v_descuento_monto := round((v_precio - v_precio_final) * v_cantidad, 2);

    v_total_lista := v_total_lista + (v_precio * v_cantidad);
    v_total_descuento := v_total_descuento + v_descuento_monto;
    v_total_final := v_total_final + (v_precio_final * v_cantidad);

    v_items := v_items || jsonb_build_object(
      'producto_id', v_producto_id,
      'nombre', v_nombre,
      'sku', v_sku,
      'cantidad', v_cantidad,
      'precio_venta', v_precio,
      'costo', v_costo,
      'costo_estimado', v_costo_estimado,
      'margen_pct', v_margen_pct,
      'descuento_pct', v_descuento_pct,
      'descuento_monto', v_descuento_monto,
      'precio_final', v_precio_final
    );
  end loop;

  select coalesce(sum((it->>'descuento_monto')::numeric), 0)
    into v_uso_mensual
    from public.personal_compras pc, jsonb_array_elements(pc.items) it
    where pc.empleado_beneficiario_id = p_empleado_beneficiario_id
      and pc.estado in ('aprobada','cobrada')
      and pc.creado_at >= (date_trunc('month', now() at time zone 'America/Mexico_City') at time zone 'America/Mexico_City');

  if (v_uso_mensual + v_total_descuento) > v_tope_mensual then
    v_excede_tope_mensual := true;
  end if;

  insert into public.personal_compras (
    empleado_beneficiario_id, vendedor_id, caja_sesion_id, estado,
    items, total_lista, total_descuento, total_final,
    excede_tope_mensual, excede_limite_producto
  ) values (
    p_empleado_beneficiario_id, v_user_id, v_caja_sesion_id, 'pendiente_aprobacion',
    v_items, round(v_total_lista,2), round(v_total_descuento,2), round(v_total_final,2),
    v_excede_tope_mensual, v_excede_limite_producto
  ) returning personal_compras.id into v_id;

  insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    select v_user_id, u.nombre, 'COMPRA_PERSONAL_SOLICITAR', 'personal_compras', v_id::text,
      jsonb_build_object(
        'empleado_beneficiario_id', p_empleado_beneficiario_id,
        'total_final', v_total_final,
        'excede_tope_mensual', v_excede_tope_mensual,
        'excede_limite_producto', v_excede_limite_producto
      )
    from public.usuarios u where u.id = v_user_id;

  return query select v_id, round(v_total_final,2), v_excede_tope_mensual, v_excede_limite_producto;
end;
$$;

grant execute on function public.empleado_personal_compra_solicitar(uuid, bigint, jsonb)
  to anon, authenticated;

commit;
