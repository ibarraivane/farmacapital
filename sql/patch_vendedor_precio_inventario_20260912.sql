-- Piso: la vendedora puede corregir el precio de venta en Inventario.
-- No toca costo ni margen. Marca manual_price_override como el admin.
-- Ejecutar en Supabase → SQL Editor → Run. Idempotente.

begin;

create or replace function public.empleado_guardar_precio(
  p_session_token uuid,
  p_producto_id   bigint,
  p_precio        numeric
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_prev  numeric;
  v_n     int;
begin
  v_actor := public.fn_require_empleado(p_session_token);

  if p_producto_id is null then
    return jsonb_build_object('success', false, 'error', 'Producto requerido');
  end if;

  if p_precio is null or p_precio < 0 then
    return jsonb_build_object('success', false, 'error', 'Precio inválido');
  end if;

  select precio into v_prev
  from public.productos
  where id = p_producto_id;

  if not found then
    return jsonb_build_object('success', false, 'error', 'Producto no encontrado');
  end if;

  if v_prev is not distinct from p_precio then
    return jsonb_build_object('success', true, 'precio', p_precio, 'sin_cambio', true);
  end if;

  update public.productos
     set precio = p_precio,
         manual_price_override = true
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
      jsonb_build_object(
        'precio', p_precio,
        'precio_anterior', v_prev,
        'origen', 'empleado_guardar_precio'
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'precio', p_precio);
end;
$$;

comment on function public.empleado_guardar_precio(uuid, bigint, numeric) is
  'Piso: corrige PVP en Inventario. No toca costo. Marca override manual.';

grant execute on function public.empleado_guardar_precio(uuid, bigint, numeric)
  to anon, authenticated;

commit;
