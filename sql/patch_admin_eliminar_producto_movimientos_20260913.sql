-- ============================================================
-- Fix: borrar producto con movimientos_inventario (kardex)
-- ============================================================
-- Síntoma (admin):
--   update or delete on table "productos" violates foreign key constraint
--   "movimientos_inventario_producto_id_fkey" on table "movimientos_inventario"
--
-- Causa: admin_eliminar_producto hacía DELETE duro si no había ventas/compras,
-- pero el producto ya tenía entradas en el kardex (recibir / ajustes).
--
-- Solución: soft-delete (activo=false) si hay ventas, compras O movimientos.
-- Si el DELETE duro falla por cualquier otra FK, también soft-delete.
--
-- Ejecutar en Supabase SQL Editor (una vez).
-- ============================================================

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
  v_tiene_ventas boolean := false;
  v_tiene_compras boolean := false;
  v_tiene_movimientos boolean := false;
  v_motivo text;
begin
  v_actor := public.fn_require_admin(p_session_token);

  select exists(
    select 1 from public.pedido_items where producto_id = p_producto_id
  ) into v_tiene_ventas;

  if to_regclass('public.compra_items') is not null then
    execute
      'select exists(select 1 from public.compra_items where producto_id = $1)'
      into v_tiene_compras
      using p_producto_id;
  end if;

  if to_regclass('public.movimientos_inventario') is not null then
    select exists(
      select 1 from public.movimientos_inventario where producto_id = p_producto_id
    ) into v_tiene_movimientos;
  end if;

  if v_tiene_ventas or v_tiene_compras or v_tiene_movimientos then
    update public.productos set activo = false where id = p_producto_id;
    if not found then
      raise exception 'Producto % no encontrado', p_producto_id;
    end if;

    v_motivo := case
      when v_tiene_ventas and v_tiene_compras and v_tiene_movimientos then 'tiene_ventas_compras_y_movimientos'
      when v_tiene_ventas and v_tiene_movimientos then 'tiene_ventas_y_movimientos'
      when v_tiene_compras and v_tiene_movimientos then 'tiene_compras_y_movimientos'
      when v_tiene_ventas and v_tiene_compras then 'tiene_ventas_y_compras'
      when v_tiene_movimientos then 'tiene_movimientos'
      when v_tiene_ventas then 'tiene_ventas'
      else 'tiene_compras'
    end;

    begin
      insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
      values (
        v_actor,
        (select nombre from public.usuarios where id = v_actor),
        'soft_delete_producto',
        'productos',
        p_producto_id::text,
        jsonb_build_object('motivo', v_motivo)
      );
    exception when others then null;
    end;

    return jsonb_build_object(
      'success', true,
      'soft_deleted', true,
      'motivo', v_motivo
    );
  end if;

  -- Sin historial: desactivar lotes e intentar borrado duro
  if to_regclass('public.lotes') is not null then
    update public.lotes set activo = false where producto_id = p_producto_id;
  end if;

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
