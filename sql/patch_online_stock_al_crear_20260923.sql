-- ============================================================================
-- Stock online ↔ Recibir: cerrar la desconexión
-- 23-sep-2026. Idempotente. Pegar en Supabase → SQL Editor → Run.
--
-- Qué pasaba:
--   1) Recibir SÍ sube lotes → trigger → productos.stock (agotado se limpia).
--   2) Compra en línea solo CHECABA stock; no lo bajaba hasta que el
--      mostrador daba «Surtir» (marcar_pedido_listo). Mientras tanto el
--      anaquel seguía «disponible» y otra venta podía llevarse las piezas.
--   3) Cancelar/eliminar un pedido «pendiente» online REINTEGRABA stock
--      que nunca se había consumido → inflaba el anaquel.
--
-- Qué hace este patch:
--   A) Al crear pedido online de anaquel: consume FEFO al instante
--      (misma tubería que Recibir / Rappi / POS) y marca stock_consumido_at.
--   B) Al surtir: no vuelve a consumir si ya se comprometió al crear.
--   C) Cancelar/eliminar: solo restockea si hubo consumo real.
--   D) El check de stock ignora lotes caducados (igual que el consume).
--
-- Bajo pedido / encargos: van por otro RPC; este no los toca.
-- ============================================================================

begin;

alter table public.pedidos
  add column if not exists stock_consumido_at timestamptz;

comment on column public.pedidos.stock_consumido_at is
  'Momento en que se bajó stock de lotes por este pedido online. NULL = aún no (legado) o no aplica.';

-- Actor técnico para movimientos sin empleado (checkout del cliente).
create or replace function public.fn_actor_sistema_inventario()
returns bigint
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select u.id
  from public.usuarios u
  where coalesce(u.activo, true)
    and (u.eliminado_at is null)
    and u.rol in ('admin', 'gerente')
  order by case when u.rol = 'admin' then 0 else 1 end, u.id
  limit 1;
$$;

-- Compromete stock FEFO de un pedido online recién creado.
create or replace function public.fn_pedido_online_comprometer_stock(p_pedido_id bigint)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
  v_item   record;
  v_actor  bigint;
  v_n      int := 0;
  v_ref    text;
begin
  select id, tipo, estado, stock_consumido_at
    into v_pedido
  from public.pedidos
  where id = p_pedido_id
  for update;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;
  if coalesce(v_pedido.tipo, '') <> 'online' then
    return 0;
  end if;
  if v_pedido.stock_consumido_at is not null then
    return 0; -- idempotente
  end if;
  if v_pedido.estado = 'cancelado' then
    return 0;
  end if;

  v_actor := public.fn_actor_sistema_inventario();
  if v_actor is null then
    raise exception 'No hay usuario admin/gerente para registrar el movimiento de stock online';
  end if;

  v_ref := 'pedido_online:' || p_pedido_id::text;

  for v_item in
    select id, producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is null or coalesce(v_item.cantidad, 0) <= 0 then
      continue;
    end if;
    -- Si ya trae lote_id (Rappi u otro), el stock ya salió de ese lote.
    if v_item.lote_id is not null then
      continue;
    end if;
    -- Encargos: no viven en anaquel.
    if exists (
      select 1 from public.productos p
      where p.id = v_item.producto_id and coalesce(p.bajo_pedido, false)
    ) then
      continue;
    end if;

    perform public.consume_stock_via_lotes(
      v_item.producto_id,
      v_item.cantidad::integer,
      'Pedido online #' || p_pedido_id,
      v_actor,
      v_ref
    );
    v_n := v_n + 1;
  end loop;

  update public.pedidos
     set stock_consumido_at = now()
   where id = p_pedido_id;

  return v_n;
end;
$$;

-- ¿Debemos reintegrar stock al cancelar/borrar?
create or replace function public.fn_pedido_online_debe_restock(p_pedido_id bigint)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_pedido record;
begin
  select id, tipo, estado, stock_consumido_at
    into v_pedido
  from public.pedidos
  where id = p_pedido_id;

  if v_pedido.id is null then
    return false;
  end if;

  -- Marcado explícito: sí se bajó stock.
  if v_pedido.stock_consumido_at is not null then
    return true;
  end if;

  -- Legado online: solo restockear si ya se surtió (ahí se consumía antes).
  if coalesce(v_pedido.tipo, '') = 'online' then
    return v_pedido.estado in ('listo', 'completado');
  end if;

  -- POS / otros: conservar comportamiento previo (restock si estaba activo).
  return v_pedido.estado in ('pendiente', 'listo', 'completado');
end;
$$;

create or replace function public.fn_pedido_online_liberar_stock(
  p_pedido_id bigint,
  p_actor_id bigint,
  p_motivo text default null
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_item record;
  v_n    int := 0;
  v_motivo text;
begin
  if not public.fn_pedido_online_debe_restock(p_pedido_id) then
    return 0;
  end if;

  v_motivo := coalesce(
    p_motivo,
    'Reintegro pedido #' || p_pedido_id
  );

  for v_item in
    select producto_id, cantidad, lote_id
    from public.pedido_items
    where pedido_id = p_pedido_id
  loop
    if v_item.producto_id is null or coalesce(v_item.cantidad, 0) <= 0 then
      continue;
    end if;
    if exists (
      select 1 from public.productos p
      where p.id = v_item.producto_id and coalesce(p.bajo_pedido, false)
    ) then
      continue;
    end if;
    begin
      perform public.restock_via_lote(
        v_item.producto_id,
        v_item.cantidad::integer,
        v_motivo,
        p_actor_id,
        v_item.lote_id
      );
      v_n := v_n + 1;
    exception when others then
      raise notice 'restock falló pedido % producto %: %',
        p_pedido_id, v_item.producto_id, SQLERRM;
    end;
  end loop;

  update public.pedidos
     set stock_consumido_at = null
   where id = p_pedido_id
     and stock_consumido_at is not null;

  return v_n;
end;
$$;

grant execute on function public.fn_actor_sistema_inventario() to anon, authenticated;
grant execute on function public.fn_pedido_online_comprometer_stock(bigint) to anon, authenticated;
grant execute on function public.fn_pedido_online_debe_restock(bigint) to anon, authenticated;
grant execute on function public.fn_pedido_online_liberar_stock(bigint, bigint, text) to anon, authenticated;

-- --------------------------------------------------------------------------
-- Checkout: mismo cuerpo que patch_recargo… + stock FEFO al crear
-- --------------------------------------------------------------------------
create or replace function public.cliente_crear_pedido_online(
  p_session_token          uuid,
  p_cart                   jsonb,
  p_metodo_pago            text,
  p_tipo_entrega           text default 'recoger',
  p_direccion              text default null,
  p_guest_nombre           text default null,
  p_guest_telefono         text default null,
  p_guest_email            text default null,
  p_reservation_session_id text default null,
  p_whatsapp_recibo        boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id       bigint;
  v_pedido_id    bigint;
  v_item         jsonb;
  v_pid          bigint;
  v_qty          numeric;
  v_prod         record;
  v_total        numeric := 0;
  v_puntos_ganados int := 0;
  v_telefono_norm text;
  v_n_items      int := 0;
  v_sum_lotes    integer;
  v_stock_eff    integer;
  v_precio_line  numeric;
  v_precio_cobro numeric;
  v_metodo       text;
  v_es_pickup    boolean;
  v_subtotal     numeric := 0;
  v_recargo      numeric := 0;
  v_factor_recargo numeric := 0.08;
  v_monto_mp     numeric := 0;
  v_items_stock  int := 0;
begin
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    if p_guest_telefono is null or length(trim(p_guest_telefono))=0 then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if p_guest_nombre is null or length(trim(p_guest_nombre))=0 then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;

    v_telefono_norm := trim(p_guest_telefono);

    select id into v_cli_id from public.clientes where telefono = v_telefono_norm limit 1;

    if v_cli_id is null then
      insert into public.clientes (nombre, telefono, email, puntos)
      values (trim(p_guest_nombre), v_telefono_norm,
              nullif(trim(coalesce(p_guest_email,'')),''), 0)
      returning id into v_cli_id;
    end if;
  end if;

  if jsonb_array_length(coalesce(p_cart,'[]'::jsonb)) = 0 then
    raise exception 'Carrito vacío';
  end if;

  if p_tipo_entrega not in ('recoger','envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and (p_direccion is null or length(trim(p_direccion))=0) then
    raise exception 'Dirección requerida para envío';
  end if;

  v_es_pickup := p_tipo_entrega = 'recoger';

  if v_es_pickup then
    v_metodo := 'pendiente_tienda';
  else
    if coalesce(p_metodo_pago, '') not in ('tarjeta','mercadopago','efectivo') then
      raise exception 'Método de pago inválido';
    end if;
    v_metodo := p_metodo_pago;
  end if;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Cantidad inválida para producto %', v_pid;
    end if;

    select id, precio, activo, stock, nombre, controlado, bajo_pedido
    into v_prod from public.productos where id = v_pid for update;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;
    if coalesce(v_prod.controlado, false) then
      raise exception 'El producto "%" es controlado y solo se vende en mostrador',
                      v_prod.nombre;
    end if;

    -- Stock vendible = lotes activos no caducados (misma regla que consume_stock_via_lotes).
    if not coalesce(v_prod.bajo_pedido, false) then
      select coalesce(sum(l.cantidad_actual), 0)::integer
        into v_sum_lotes
        from public.lotes l
        where l.producto_id = v_pid
          and coalesce(l.activo, true)
          and coalesce(l.cantidad_actual, 0) > 0
          and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date);

      v_stock_eff := coalesce(v_sum_lotes, 0);

      if v_stock_eff < v_qty then
        raise exception 'Stock insuficiente para "%": disponible=%, solicitado=%',
                        v_prod.nombre, v_stock_eff, v_qty;
      end if;
    end if;

    begin
      v_precio_line := public.precio_oferta_publico(v_pid);
    exception when undefined_function then
      v_precio_line := coalesce(v_prod.precio, 0);
    end;

    if coalesce(v_precio_line, 0) <= 0.01 then
      raise exception 'Producto "%" aún no tiene precio de venta', v_prod.nombre;
    end if;

    v_subtotal := v_subtotal + (v_precio_line * v_qty);
    if v_es_pickup then
      v_precio_cobro := v_precio_line;
    else
      v_precio_cobro := round(v_precio_line * (1 + v_factor_recargo), 2);
    end if;
    v_monto_mp := v_monto_mp + (v_precio_cobro * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  v_subtotal := round(v_subtotal, 2);
  v_monto_mp := round(v_monto_mp, 2);
  v_recargo := round(v_monto_mp - v_subtotal, 2);
  v_total := case when v_es_pickup then v_subtotal else v_monto_mp end;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  if not v_es_pickup and v_subtotal < 150 then
    raise exception 'El pedido a domicilio tiene un mínimo de $150 en productos (antes de envío). Agrega algo más al carrito o recógelo en farmacia sin mínimo.';
  end if;

  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion,
    metodo_pago, whatsapp_recibo, payment_status, payment_provider,
    subtotal_productos, recargo_procesamiento_pago, monto_cobrado_mercadopago
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion,
    v_metodo, coalesce(p_whatsapp_recibo, false),
    case when v_es_pickup then 'pending_store' else null end,
    null,
    v_subtotal,
    case when v_es_pickup then 0 else v_recargo end,
    case when v_es_pickup then 0 else v_monto_mp end
  ) returning id into v_pedido_id;

  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    begin
      v_precio_line := public.precio_oferta_publico(v_pid);
    exception when undefined_function then
      select coalesce(precio, 0) into v_precio_line from public.productos where id = v_pid;
    end;

    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_pedido_id, v_pid, v_qty, v_precio_line);
  end loop;

  -- Baja el anaquel YA (no esperar a Surtir).
  v_items_stock := public.fn_pedido_online_comprometer_stock(v_pedido_id);

  if not v_es_pickup then
    v_puntos_ganados := floor(v_subtotal / 10);
    if v_puntos_ganados > 0 then
      update public.clientes
         set puntos = coalesce(puntos, 0) + v_puntos_ganados
       where id = v_cli_id;
    end if;
  else
    v_puntos_ganados := 0;
  end if;

  if p_reservation_session_id is not null then
    begin
      perform public.confirm_stock_reservation(p_reservation_session_id, v_pedido_id);
    exception when others then
      raise notice 'confirm_stock_reservation no disponible: %', SQLERRM;
    end;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'cliente_id', v_cli_id,
    'total', v_total,
    'puntos_ganados', v_puntos_ganados,
    'items', v_n_items,
    'items_stock_comprometidos', v_items_stock,
    'whatsapp_recibo', coalesce(p_whatsapp_recibo, false),
    'metodo_pago', v_metodo,
    'payment_status', case when v_es_pickup then 'pending_store' else null end,
    'cobro_en_tienda', v_es_pickup,
    'subtotal_productos', v_subtotal,
    'recargo_procesamiento_pago', case when v_es_pickup then 0 else v_recargo end,
    'monto_cobrado_mercadopago', case when v_es_pickup then 0 else v_monto_mp end
  );
end;
$$;

grant execute on function public.cliente_crear_pedido_online(
  uuid, jsonb, text, text, text, text, text, text, text, boolean
) to anon, authenticated;

comment on function public.cliente_crear_pedido_online(uuid, jsonb, text, text, text, text, text, text, text, boolean) is
  'Checkout online: compromete stock FEFO al crear; pickup sin recargo; envío +8%; mínimo $150 subtotal.';

-- --------------------------------------------------------------------------
-- Surtir: no doble-consume si ya se bajó al crear
-- --------------------------------------------------------------------------
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
  v_actor_id     bigint;
  v_atendido_id  bigint;
  v_pedido       record;
  v_item         record;
  v_consumidos   int := 0;
  v_nuevo_estado text;
  v_es_pickup    boolean;
  v_ya_consumido boolean;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  v_atendido_id := public.fn_atendido_por_venta(v_actor_id);

  select id, estado, tipo, tipo_entrega, cliente_id, metodo_pago, payment_status, stock_consumido_at
    into v_pedido
  from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  if coalesce(v_pedido.tipo, '') = 'online'
     and not public.fn_pedido_online_pago_confirmado(v_pedido.metodo_pago, v_pedido.payment_status, v_pedido.tipo) then
    raise exception 'Pago no confirmado. Espera la aprobación de Mercado Pago antes de surtir.';
  end if;

  if v_pedido.estado in ('listo', 'completado') then
    update public.pedidos
       set atendido_por = coalesce(atendido_por, v_atendido_id),
           atendido_at = coalesce(atendido_at, now()),
           estado = case
             when coalesce(tipo_entrega, '') = 'recoger' and estado = 'listo' then 'completado'
             else estado
           end,
           delivery_provider = case
             when coalesce(tipo_entrega, '') = 'recoger' then coalesce(delivery_provider, 'pickup')
             else delivery_provider
           end,
           delivery_status = case
             when coalesce(tipo_entrega, '') = 'recoger' then coalesce(delivery_status, 'ready_for_pickup')
             else delivery_status
           end
     where id = p_pedido_id
       and (
         atendido_por is null
         or atendido_at is null
         or (coalesce(tipo_entrega, '') = 'recoger' and estado = 'listo')
       );
    return jsonb_build_object('success', true, 'ya_listo', true);
  end if;

  if v_pedido.estado = 'cancelado' then
    raise exception 'No se puede marcar listo un pedido en estado: %', v_pedido.estado;
  end if;

  v_ya_consumido := v_pedido.stock_consumido_at is not null;

  if not v_ya_consumido then
    -- Pedidos legados (creados antes de este patch): consumir al surtir.
    for v_item in
      select id, producto_id, cantidad, lote_id
      from public.pedido_items where pedido_id = p_pedido_id
    loop
      if v_item.producto_id is not null and coalesce(v_item.cantidad, 0) > 0 then
        if v_item.lote_id is null then
          begin
            perform public.consume_stock_via_lotes(
              v_item.producto_id,
              v_item.cantidad::integer,
              'Pedido listo #' || p_pedido_id,
              v_atendido_id,
              'pedido_listo:' || p_pedido_id::text
            );
            v_consumidos := v_consumidos + 1;
          exception when others then
            raise exception 'Error al consumir stock de producto %: %', v_item.producto_id, SQLERRM;
          end;
        end if;
      end if;
    end loop;

    if v_consumidos > 0 then
      update public.pedidos
         set stock_consumido_at = coalesce(stock_consumido_at, now())
       where id = p_pedido_id;
    end if;
  end if;

  begin
    perform public.release_stock_reservation(p_pedido_id);
  exception when others then null;
  end;

  v_es_pickup := coalesce(v_pedido.tipo_entrega, '') = 'recoger';
  v_nuevo_estado := case when v_es_pickup then 'completado' else 'listo' end;

  update public.pedidos
     set estado = v_nuevo_estado,
         atendido_por = v_atendido_id,
         atendido_at = now(),
         delivery_provider = case when v_es_pickup then 'pickup' else delivery_provider end,
         delivery_status = case when v_es_pickup then 'ready_for_pickup' else delivery_status end
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'marcar_pedido_listo', 'pedidos', p_pedido_id::text,
      jsonb_build_object(
        'items_consumidos', v_consumidos,
        'stock_ya_comprometido', v_ya_consumido,
        'tipo_entrega', v_pedido.tipo_entrega,
        'estado', v_nuevo_estado,
        'atendido_por', v_atendido_id
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'estado', v_nuevo_estado,
    'items_consumidos', v_consumidos,
    'stock_ya_comprometido', v_ya_consumido
  );
end;
$$;

grant execute on function public.marcar_pedido_listo(uuid, bigint) to anon, authenticated;

-- --------------------------------------------------------------------------
-- Cancelar / eliminar: restock solo si hubo consumo
-- --------------------------------------------------------------------------
create or replace function public.admin_cancelar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_estado_prev text;
  v_cnt      int := 0;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  select estado into v_estado_prev from public.pedidos where id = p_pedido_id;
  if v_estado_prev is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;
  if v_estado_prev = 'cancelado' then
    return jsonb_build_object('success', true, 'ya_cancelado', true);
  end if;

  v_cnt := public.fn_pedido_online_liberar_stock(
    p_pedido_id,
    v_actor_id,
    'Cancelación pedido #' || p_pedido_id || coalesce(' - ' || p_motivo, '')
  );

  update public.pedidos
     set estado = 'cancelado',
         notas  = case when p_motivo is null then notas
                       else coalesce(notas || E'\n', '') || 'Cancelación: ' || p_motivo end
   where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'cancelar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object('estado_previo', v_estado_prev, 'items_restaurados', v_cnt, 'motivo', p_motivo)
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

grant execute on function public.admin_cancelar_pedido(uuid, bigint, text) to anon, authenticated;

create or replace function public.cliente_cancelar_pedido_online(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id bigint;
  v_pedido record;
  v_actor  bigint;
  v_cnt    int := 0;
begin
  v_cli_id := public.fn_require_cliente(p_session_token);

  select id, cliente_id, estado, tipo
  into v_pedido from public.pedidos where id = p_pedido_id;

  if v_pedido.id is null then
    raise exception 'Pedido no encontrado';
  end if;
  if v_pedido.cliente_id is distinct from v_cli_id then
    raise exception 'No tiene permiso sobre este pedido' using errcode = '42501';
  end if;
  if v_pedido.estado <> 'pendiente' then
    raise exception 'Solo se pueden cancelar pedidos en estado pendiente';
  end if;
  if v_pedido.tipo <> 'online' then
    raise exception 'Solo pedidos online pueden cancelarse desde la tienda';
  end if;

  v_actor := coalesce(public.fn_actor_sistema_inventario(), v_cli_id);
  v_cnt := public.fn_pedido_online_liberar_stock(
    p_pedido_id,
    v_actor,
    'Cancelación cliente pedido online #' || p_pedido_id
  );

  update public.pedidos set estado = 'cancelado' where id = p_pedido_id;

  begin
    perform public.release_stock_reservation(p_pedido_id);
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

grant execute on function public.cliente_cancelar_pedido_online(uuid, bigint) to anon, authenticated;

create or replace function public.admin_eliminar_pedido(
  p_session_token uuid,
  p_pedido_id     bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id    bigint;
  v_cnt         int := 0;
  v_pedido_snap jsonb;
  v_items_snap  jsonb;
begin
  v_actor_id := public.fn_require_admin(p_session_token);

  if not exists (select 1 from public.pedidos where id = p_pedido_id) then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  select to_jsonb(p.*) into v_pedido_snap
  from public.pedidos p
  where p.id = p_pedido_id;

  select coalesce(jsonb_agg(to_jsonb(i.*) order by i.id), '[]'::jsonb)
    into v_items_snap
  from public.pedido_items i
  where i.pedido_id = p_pedido_id;

  v_cnt := public.fn_pedido_online_liberar_stock(
    p_pedido_id,
    v_actor_id,
    'Reintegro por eliminación de pedido #' || p_pedido_id
  );

  delete from public.pedido_items where pedido_id = p_pedido_id;
  delete from public.pedidos where id = p_pedido_id;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'eliminar_pedido', 'pedidos', p_pedido_id::text,
      jsonb_build_object(
        'items_restaurados', v_cnt,
        'pedido', v_pedido_snap,
        'items', v_items_snap
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object('success', true, 'items_restaurados', v_cnt);
end;
$$;

grant execute on function public.admin_eliminar_pedido(uuid, bigint) to anon, authenticated;

commit;

-- Diagnóstico rápido (opcional, no cambia datos):
-- select p.id, p.nombre, p.stock,
--        (select coalesce(sum(l.cantidad_actual),0) from lotes l
--          where l.producto_id=p.id and coalesce(l.activo,true)
--            and coalesce(l.cantidad_actual,0)>0
--            and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)) as lotes_vivos
-- from productos p
-- where coalesce(p.activo,true)
-- order by abs(p.stock - (
--   select coalesce(sum(l.cantidad_actual),0) from lotes l
--   where l.producto_id=p.id and coalesce(l.activo,true))) desc
-- limit 30;
