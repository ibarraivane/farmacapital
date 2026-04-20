-- ============================================================
-- FARMAX — F6b.4: RPCs de la tienda (cliente self-service)
-- ============================================================
-- Operaciones que realiza un cliente autenticado o un guest
-- (sin cuenta) desde la tienda pública.
--
-- Corre DESPUÉS de las 3 anteriores (auth, transacciones, catalogo).
-- Idempotente.
-- ============================================================

begin;

-- ============================================================
-- 1) cliente_actualizar_perfil
-- ============================================================
-- El cliente actualiza sus propios datos. NO permite mover puntos
-- ni cambiar telefono (usado como login) ni password (tiene su
-- propio flujo).
-- ============================================================
create or replace function public.cliente_actualizar_perfil(
  p_session_token uuid,
  p_nombre        text default null,
  p_email         text default null,
  p_calle         text default null,
  p_colonia       text default null,
  p_cp            text default null,
  p_rfc           text default null,
  p_razon_social  text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id bigint;
begin
  v_cli_id := public.fn_require_cliente(p_session_token);

  update public.clientes set
    nombre       = coalesce(nullif(trim(coalesce(p_nombre,'')),''), nombre),
    email        = coalesce(nullif(trim(coalesce(p_email,'')),''), email),
    calle        = coalesce(nullif(trim(coalesce(p_calle,'')),''), calle),
    colonia      = coalesce(nullif(trim(coalesce(p_colonia,'')),''), colonia),
    cp           = coalesce(nullif(trim(coalesce(p_cp,'')),''), cp),
    rfc          = coalesce(nullif(upper(trim(coalesce(p_rfc,''))),''), rfc),
    razon_social = coalesce(nullif(upper(trim(coalesce(p_razon_social,''))),''), razon_social)
  where id = v_cli_id;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 2) cliente_agendar_cita
-- ============================================================
-- Permite a un cliente (logueado o guest) agendar una cita.
-- Valida disponibilidad server-side (no confiable desde el FE).
-- ============================================================
create or replace function public.cliente_agendar_cita(
  p_session_token uuid,       -- token cliente (opcional)
  p_nombre        text,
  p_telefono      text,
  p_fecha         date,
  p_hora          text,
  p_motivo        text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id   bigint;
  v_cita_id  bigint;
  v_ocupada  boolean;
begin
  -- Token opcional: si viene, validamos
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  end if;

  if p_nombre is null or length(trim(p_nombre)) = 0 then
    raise exception 'Nombre requerido';
  end if;
  if p_telefono is null or length(trim(p_telefono)) = 0 then
    raise exception 'Teléfono requerido';
  end if;
  if p_fecha is null then raise exception 'Fecha requerida'; end if;
  if p_hora  is null or length(trim(p_hora)) = 0 then raise exception 'Hora requerida'; end if;

  -- No permitir fecha pasada
  if p_fecha < current_date then
    raise exception 'No se puede agendar en una fecha pasada';
  end if;

  -- Rate limit simple: máximo 3 citas pendientes por teléfono en los próximos 60 días
  if (
    select count(*) from public.citas
    where telefono = trim(p_telefono)
      and fecha between current_date and current_date + interval '60 days'
      and estado not in ('cancelada','no_asistio')
  ) >= 3 then
    raise exception 'Ya tienes 3 citas activas. Cancela alguna antes de agendar otra.';
  end if;

  -- Validar disponibilidad: una cita por (fecha, hora) no cancelada
  select exists (
    select 1 from public.citas
    where fecha = p_fecha and hora = p_hora
      and estado <> 'cancelada'
  ) into v_ocupada;

  if v_ocupada then
    raise exception 'Ese horario ya no está disponible';
  end if;

  insert into public.citas (
    nombre, telefono, fecha, hora, motivo,
    cliente_id, canal, pago_estado, estado
  ) values (
    trim(p_nombre), trim(p_telefono), p_fecha, p_hora, p_motivo,
    v_cli_id, 'web', 'pendiente', 'agendada'
  ) returning id into v_cita_id;

  return jsonb_build_object('success', true, 'cita_id', v_cita_id);
end;
$$;

-- ============================================================
-- 3) cliente_cancelar_cita
-- ============================================================
-- El cliente solo puede cancelar sus propias citas (por telefono
-- o cliente_id si logueado).
-- ============================================================
create or replace function public.cliente_cancelar_cita(
  p_session_token uuid,
  p_cita_id       bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli_id   bigint;
  v_cita     record;
begin
  v_cli_id := public.fn_require_cliente(p_session_token);

  select id, cliente_id, telefono, estado, pago_estado
  into v_cita from public.citas where id = p_cita_id;

  if v_cita.id is null then
    raise exception 'Cita % no encontrada', p_cita_id;
  end if;

  -- Debe pertenecer al cliente
  if v_cita.cliente_id is distinct from v_cli_id
     and v_cita.telefono is distinct from
         (select telefono from public.clientes where id = v_cli_id) then
    raise exception 'No tiene permiso para cancelar esta cita' using errcode = '42501';
  end if;

  if v_cita.pago_estado = 'pagada' then
    raise exception 'No se puede cancelar una cita ya pagada';
  end if;
  if v_cita.estado in ('completada','en_consulta','cancelada') then
    raise exception 'No se puede cancelar una cita en estado: %', v_cita.estado;
  end if;

  update public.citas set estado = 'cancelada' where id = p_cita_id;
  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- 4) cliente_crear_pedido_online
-- ============================================================
-- Crea un pedido online tipo='online' estado='pendiente'.
-- NO consume lotes todavía (eso lo hace el empleado al marcar
-- listo). Sí reserva stock mediante el sistema existente.
--
-- Acepta:
--   - Cliente logueado (p_session_token) o guest (datos en p_datos)
--   - p_cart: [{producto_id, cantidad}]
--   - p_reservation_session_id: id de reserva previa (reserve_stock_for_checkout)
-- ============================================================
create or replace function public.cliente_crear_pedido_online(
  p_session_token        uuid,         -- token cliente (opcional, null = guest)
  p_cart                 jsonb,        -- [{producto_id, cantidad}]
  p_metodo_pago          text,
  p_tipo_entrega         text default 'recoger',
  p_direccion            text default null,
  p_guest_nombre         text default null,
  p_guest_telefono       text default null,
  p_guest_email          text default null,
  p_reservation_session_id text default null
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
begin
  -- 1) Identificar cliente
  if p_session_token is not null then
    v_cli_id := public.fn_validar_token_cliente(p_session_token);
    if v_cli_id is null then
      raise exception 'Sesión cliente inválida' using errcode = '28000';
    end if;
  else
    -- Guest checkout: requerimos nombre + teléfono
    if p_guest_telefono is null or length(trim(p_guest_telefono))=0 then
      raise exception 'Teléfono requerido para checkout sin cuenta';
    end if;
    if p_guest_nombre is null or length(trim(p_guest_nombre))=0 then
      raise exception 'Nombre requerido para checkout sin cuenta';
    end if;

    v_telefono_norm := trim(p_guest_telefono);

    -- Buscar cliente existente por teléfono
    select id into v_cli_id from public.clientes where telefono = v_telefono_norm limit 1;

    if v_cli_id is null then
      insert into public.clientes (nombre, telefono, email, puntos)
      values (trim(p_guest_nombre), v_telefono_norm,
              nullif(trim(coalesce(p_guest_email,'')),''), 0)
      returning id into v_cli_id;
    end if;
  end if;

  -- 2) Validar cart
  if jsonb_array_length(coalesce(p_cart,'[]'::jsonb)) = 0 then
    raise exception 'Carrito vacío';
  end if;

  if p_metodo_pago not in ('tarjeta','mercadopago','efectivo') then
    raise exception 'Método de pago inválido';
  end if;
  if p_tipo_entrega not in ('recoger','envio') then
    raise exception 'Tipo de entrega inválido';
  end if;
  if p_tipo_entrega = 'envio' and (p_direccion is null or length(trim(p_direccion))=0) then
    raise exception 'Dirección requerida para envío';
  end if;

  -- 3) Calcular total SERVER-SIDE desde productos.precio
  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    if v_qty is null or v_qty <= 0 then
      raise exception 'Cantidad inválida para producto %', v_pid;
    end if;

    select id, precio, activo, stock, nombre, requiere_receta
    into v_prod from public.productos where id = v_pid;

    if v_prod.id is null then
      raise exception 'Producto % no existe', v_pid;
    end if;
    if not coalesce(v_prod.activo, false) then
      raise exception 'Producto "%" no está disponible', v_prod.nombre;
    end if;
    if coalesce(v_prod.stock, 0) < v_qty then
      raise exception 'Stock insuficiente para "%": disponible=%, solicitado=%',
                      v_prod.nombre, v_prod.stock, v_qty;
    end if;
    if coalesce(v_prod.requiere_receta, false) then
      raise exception 'El producto "%" requiere receta médica y no puede venderse online',
                      v_prod.nombre;
    end if;

    v_total := v_total + (v_prod.precio * v_qty);
    v_n_items := v_n_items + 1;
  end loop;

  if v_total <= 0 then
    raise exception 'Total inválido';
  end if;

  -- 4) Crear pedido
  insert into public.pedidos (
    cliente_id, total, estado, tipo, tipo_entrega, direccion, metodo_pago
  ) values (
    v_cli_id, v_total, 'pendiente', 'online', p_tipo_entrega, p_direccion, p_metodo_pago
  ) returning id into v_pedido_id;

  -- 5) Insertar items (sin lote_id aún: se asigna al marcar listo)
  for v_item in select * from jsonb_array_elements(p_cart)
  loop
    v_pid := (v_item->>'producto_id')::bigint;
    v_qty := (v_item->>'cantidad')::numeric;
    select precio into v_prod from public.productos where id = v_pid;

    insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario)
    values (v_pedido_id, v_pid, v_qty, v_prod.precio);
  end loop;

  -- 6) Otorgar puntos (1 por cada $10)
  v_puntos_ganados := floor(v_total / 10);
  if v_puntos_ganados > 0 then
    update public.clientes
       set puntos = coalesce(puntos, 0) + v_puntos_ganados
     where id = v_cli_id;
  end if;

  -- 7) Marcar reserva como confirmada (si existe y la función existe)
  if p_reservation_session_id is not null then
    begin
      perform public.confirm_stock_reservation(p_reservation_session_id, v_pedido_id);
    exception when others then
      -- Si no existe esa función, sólo log; la reserva expirará sola
      raise notice 'confirm_stock_reservation no disponible: %', SQLERRM;
    end;
  end if;

  return jsonb_build_object(
    'success', true,
    'pedido_id', v_pedido_id,
    'cliente_id', v_cli_id,
    'total', v_total,
    'puntos_ganados', v_puntos_ganados,
    'items', v_n_items
  );
end;
$$;

-- ============================================================
-- 5) cliente_cancelar_pedido_online
-- ============================================================
-- El cliente solo puede cancelar sus pedidos online en estado
-- 'pendiente'.
-- ============================================================
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

  update public.pedidos set estado = 'cancelado' where id = p_pedido_id;

  -- Liberar reserva de stock si aplica
  begin
    perform public.release_stock_reservation(p_pedido_id);
  exception when others then null;
  end;

  return jsonb_build_object('success', true);
end;
$$;

-- ============================================================
-- Grants
-- ============================================================
grant execute on function public.cliente_actualizar_perfil(uuid, text, text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.cliente_agendar_cita(uuid, text, text, date, text, text) to anon, authenticated;
grant execute on function public.cliente_cancelar_cita(uuid, bigint) to anon, authenticated;
grant execute on function public.cliente_crear_pedido_online(uuid, jsonb, text, text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.cliente_cancelar_pedido_online(uuid, bigint) to anon, authenticated;

commit;

-- ============================================================
-- FIN F6b.4
-- ============================================================
-- Siguiente: refactor_fase6b_rpcs_compat.sql
--   (extiende RPCs existentes para aceptar p_session_token)
-- ============================================================
