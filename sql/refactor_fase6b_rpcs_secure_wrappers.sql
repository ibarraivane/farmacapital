-- ============================================================
-- FARMAX — F6b.5: Wrappers _secure para RPCs existentes + FEFO
-- ============================================================
-- Envuelve RPCs existentes (que aceptan p_user_id) con una capa
-- que valida p_session_token. Así el FE puede migrar paulatinamente
-- a llamar *_secure sin tocar la lógica subyacente.
--
-- También mejora marcar_pedido_listo para que CONSUMA stock de
-- lotes al confirmar un pedido online.
--
-- Corre DESPUÉS de las 4 anteriores de F6b.
-- Idempotente.
-- ============================================================

begin;

-- ============================================================
-- 1) create_sale_transaction_secure
-- ============================================================
-- Venta POS. Requiere rol empleado (admin, gerente, cajero, vendedor…
-- cualquier empleado activo).
-- ============================================================
create or replace function public.create_sale_transaction_secure(
  p_session_token uuid,
  p_metodo_pago   text,
  p_total         numeric,
  p_cart_items    jsonb,
  p_cliente_id    bigint default null,
  p_tipo          text   default 'pos',
  p_tipo_entrega  text   default null,
  p_direccion     text   default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.create_sale_transaction_v2(
    v_user_id, p_metodo_pago, p_total, p_cart_items,
    p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
  );
end;
$$;

-- ============================================================
-- 2) abrir_caja_secure
-- ============================================================
create or replace function public.abrir_caja_secure(
  p_session_token uuid,
  p_producto_id   bigint
)
returns table(stock_nuevo integer, stock_unidades_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.abrir_caja_lote(p_producto_id, v_user_id);
end;
$$;

-- ============================================================
-- 3) restock_via_lote_secure
-- ============================================================
create or replace function public.restock_via_lote_secure(
  p_session_token uuid,
  p_producto_id   bigint,
  p_cantidad      integer,
  p_motivo        text,
  p_lote_id       bigint default null
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.restock_via_lote(p_producto_id, p_cantidad, p_motivo, v_user_id, p_lote_id);
end;
$$;

-- ============================================================
-- 4) adjust_stock_secure
-- ============================================================
-- Requiere admin/gerente (ajusta a un valor absoluto, sensible).
-- ============================================================
create or replace function public.adjust_stock_secure(
  p_session_token uuid,
  p_producto_id   bigint,
  p_nuevo_stock   integer,
  p_motivo        text
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_admin(p_session_token);
  return query
  select * from public.adjust_stock_via_lotes(p_producto_id, p_nuevo_stock, p_motivo, v_user_id);
end;
$$;

-- ============================================================
-- 5) create_producto_secure
-- ============================================================
-- Wrap de create_producto_with_lote. Requiere admin/gerente.
-- ============================================================
create or replace function public.create_producto_secure(
  p_session_token     uuid,
  p_producto_data     jsonb,
  p_cantidad_inicial  integer default 0,
  p_numero_lote       text default null,
  p_fecha_caducidad   date default null,
  p_costo_unitario    numeric default null
)
returns table(producto_id bigint, lote_id bigint)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_admin(p_session_token);
  return query
  select * from public.create_producto_with_lote(
    p_producto_data, p_cantidad_inicial, p_numero_lote,
    p_fecha_caducidad, p_costo_unitario, v_user_id
  );
end;
$$;

-- ============================================================
-- 6) receive_merchandise_secure
-- ============================================================
create or replace function public.receive_merchandise_secure(
  p_session_token    uuid,
  p_producto_id      bigint,
  p_cantidad         integer,
  p_numero_lote      text default null,
  p_fecha_caducidad  date default null,
  p_costo_unitario   numeric default null,
  p_proveedor        text default null
)
returns table(lote_id bigint, stock_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.receive_merchandise_lote(
    p_producto_id, p_cantidad, p_numero_lote, p_fecha_caducidad,
    p_costo_unitario, p_proveedor, v_user_id
  );
end;
$$;

-- ============================================================
-- 7) consume_stock_secure
-- ============================================================
create or replace function public.consume_stock_secure(
  p_session_token uuid,
  p_producto_id   bigint,
  p_cantidad      integer,
  p_motivo        text,
  p_referencia    text default null
)
returns table(stock_nuevo integer)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
  select * from public.consume_stock_via_lotes(
    p_producto_id, p_cantidad, p_motivo, v_user_id, p_referencia
  );
end;
$$;

-- ============================================================
-- 8) marcar_pedido_listo (MEJORADA)
-- ============================================================
-- Cuando un empleado marca un pedido online como listo, AHORA
-- se consume el stock de los lotes (FEFO) y se libera la reserva.
-- Reemplaza la versión mínima creada en F6b.2.
-- ============================================================
create or replace function public.marcar_pedido_listo(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_pedido   record;
  v_item     record;
  v_consumidos int := 0;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  select id, estado, tipo, cliente_id into v_pedido
  from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;
  if v_pedido.estado = 'listo' then
    return jsonb_build_object('success', true, 'ya_listo', true);
  end if;
  if v_pedido.estado in ('cancelado','completado') then
    raise exception 'No se puede marcar listo un pedido en estado: %', v_pedido.estado;
  end if;

  -- Consumir stock de cada item via FEFO
  for v_item in
    select id, producto_id, cantidad, lote_id
    from public.pedido_items where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
      -- Si el item ya tiene lote_id asignado, se respetó desde la venta original.
      -- Si NO (pedidos online), consumimos FEFO.
      if v_item.lote_id is null then
        begin
          perform public.consume_stock_via_lotes(
            v_item.producto_id,
            v_item.cantidad::integer,
            'Pedido listo #' || p_pedido_id,
            v_actor_id,
            'pedido_listo:' || p_pedido_id::text
          );
          v_consumidos := v_consumidos + 1;
        exception when others then
          raise exception 'Error al consumir stock de producto %: %', v_item.producto_id, SQLERRM;
        end;
      end if;
    end if;
  end loop;

  -- Liberar reserva si existe
  begin
    perform public.release_stock_reservation(p_pedido_id);
  exception when others then null;
  end;

  update public.pedidos
     set estado = 'listo', atendido_por = v_actor_id
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'marcar_pedido_listo', 'pedidos', p_pedido_id::text,
      jsonb_build_object('items_consumidos', v_consumidos)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_consumidos', v_consumidos);
end;
$$;

-- ============================================================
-- Grants
-- ============================================================
grant execute on function public.create_sale_transaction_secure(uuid, text, numeric, jsonb, bigint, text, text, text) to anon, authenticated;
grant execute on function public.abrir_caja_secure(uuid, bigint)                                   to anon, authenticated;
grant execute on function public.restock_via_lote_secure(uuid, bigint, integer, text, bigint)      to anon, authenticated;
grant execute on function public.adjust_stock_secure(uuid, bigint, integer, text)                  to anon, authenticated;
grant execute on function public.create_producto_secure(uuid, jsonb, integer, text, date, numeric) to anon, authenticated;
grant execute on function public.receive_merchandise_secure(uuid, bigint, integer, text, date, numeric, text) to anon, authenticated;
grant execute on function public.consume_stock_secure(uuid, bigint, integer, text, text)          to anon, authenticated;
grant execute on function public.marcar_pedido_listo(uuid, bigint)                                to anon, authenticated;

commit;

-- ============================================================
-- FIN F6b.5 — backend terminado
-- ============================================================
-- Total RPCs seguras creadas en F6b:
--   F6b.1 auth:          11 (login/logout empleado y cliente + admin_*)
--   F6b.2 transacciones: 10
--   F6b.3 catálogo:      18
--   F6b.4 tienda:         5
--   F6b.5 wrappers:       8
--   TOTAL:               52 RPCs
-- ============================================================
-- Siguiente: verificación (008_verificar_fase6b.sql) y luego
-- migración del FRONTEND para llamar estas RPCs.
-- ============================================================
