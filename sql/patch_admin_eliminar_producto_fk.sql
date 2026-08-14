-- Permite eliminar/desactivar productos aunque tengan compras u otras FKs (soft-delete).
-- Ejecutar en Supabase SQL Editor.

create or replace function public.admin_eliminar_producto(
  p_session_token uuid,
  p_producto_id   bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_tiene_ventas boolean;
  v_tiene_compras boolean;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select exists(
    select 1 from public.pedido_items where producto_id = p_producto_id
  ) into v_tiene_ventas;

  select exists(
    select 1 from public.compra_items where producto_id = p_producto_id
  ) into v_tiene_compras;

  if v_tiene_ventas or v_tiene_compras then
    update public.productos set activo = false where id = p_producto_id;
    if not found then
      raise exception 'Producto % no encontrado', p_producto_id;
    end if;
    begin
      insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
      values (
        v_actor,
        (select nombre from public.usuarios where id = v_actor),
        'soft_delete_producto',
        'productos',
        p_producto_id::text,
        jsonb_build_object(
          'motivo',
          case
            when v_tiene_ventas and v_tiene_compras then 'tiene_ventas_y_compras'
            when v_tiene_ventas then 'tiene_ventas'
            else 'tiene_compras'
          end
        )
      );
    exception when others then null;
    end;
    return jsonb_build_object(
      'success', true,
      'soft_deleted', true,
      'motivo',
      case
        when v_tiene_ventas and v_tiene_compras then 'tiene_ventas_y_compras'
        when v_tiene_ventas then 'tiene_ventas'
        else 'tiene_compras'
      end
    );
  end if;

  update public.lotes set activo = false where producto_id = p_producto_id;

  begin
    delete from public.productos where id = p_producto_id;
    if not found then
      raise exception 'Producto % no encontrado', p_producto_id;
    end if;
  exception
    when foreign_key_violation then
      update public.productos set activo = false where id = p_producto_id;
      begin
        insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
        values (
          v_actor,
          (select nombre from public.usuarios where id = v_actor),
          'soft_delete_producto',
          'productos',
          p_producto_id::text,
          jsonb_build_object('motivo', 'referencias_fk')
        );
      exception when others then null;
      end;
      return jsonb_build_object('success', true, 'soft_deleted', true, 'motivo', 'referencias_fk');
  end;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor,
      (select nombre from public.usuarios where id = v_actor),
      'hard_delete_producto',
      'productos',
      p_producto_id::text,
      '{}'::jsonb
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'soft_deleted', false);
end;
$$;

grant execute on function public.admin_eliminar_producto(uuid, bigint) to anon, authenticated;
