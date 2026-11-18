-- =============================================================================
-- Servicios de salud en el POS (inyección, presión, oximetría, glucosa)
-- 2026-10-08 · FarmaCapital
--
-- Qué hace:
--   1. Nuevo tipo de producto `servicio`: se vende en el POS, NO tiene stock ni lotes.
--   2. Helper fn_venta_pos_con_servicios: separa servicios de productos del carrito.
--      - Sin servicios en el carrito → llama a create_sale_transaction_v2 tal cual
--        (cero cambio de comportamiento para la venta de todos los días).
--      - Con servicios → los productos pasan por v2 (FEFO, validación de precio),
--        y los servicios se agregan al MISMO pedido con precio validado en servidor.
--   3. create_sale_transaction_secure y empleado_cobrar_venta_pos llaman al helper
--      en vez de a v2. create_sale_transaction_v2 NO se toca.
--   4. Costo del servicio queda con origen 'servicio' (no 'sin_costo'), para que
--      la gráfica de ganancia sí lo cuente.
--   5. Devoluciones: un servicio devuelto regresa dinero/crédito pero NO crea stock.
--   6. El contador de "bajo stock" ignora servicios.
--   7. Catálogo inicial (precios [CONFIGURABLE], revisar antes de correr).
--
-- Seguro de correr más de una vez (idempotente).
-- =============================================================================

begin;

-- Si algo está bloqueando las tablas (una venta en curso), falla rápido en vez de congelar el POS.
set local lock_timeout = '5s';

-- ---------------------------------------------------------------------------
-- 1. Origen de costo 'servicio'
-- ---------------------------------------------------------------------------
alter table public.pedido_item_consumos
  drop constraint if exists pedido_item_consumos_costo_origen_check;
alter table public.pedido_item_consumos
  add constraint pedido_item_consumos_costo_origen_check
  check (costo_origen = any (array[
    'lote','lote_estimado','caja_abierta','estimado_por_fecha',
    'catalogo_actual','sin_costo','servicio'
  ]));

-- ---------------------------------------------------------------------------
-- 2. Helper de venta POS con servicios
-- ---------------------------------------------------------------------------
create or replace function public.fn_venta_pos_con_servicios(
  p_user_id bigint,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb,
  p_cliente_id bigint default null,
  p_tipo text default 'pos',
  p_tipo_entrega text default null,
  p_direccion text default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $function$
declare
  v_item jsonb;
  v_pid bigint;
  v_qty integer;
  v_modo text;
  v_tipo text;
  v_prod jsonb := '[]'::jsonb;
  v_serv jsonb := '[]'::jsonb;
  v_serv_total numeric := 0;
  v_precio numeric;
  v_costo numeric;
  v_activo boolean;
  v_nombre text;
  v_pedido_id bigint;
  v_ok boolean;
  v_item_id bigint;
  v_flag_prev text;
begin
  if p_cart_items is null or jsonb_typeof(p_cart_items) <> 'array'
     or jsonb_array_length(p_cart_items) = 0 then
    raise exception 'cart_items debe ser un arreglo no vacio';
  end if;

  -- Separar servicios de productos
  for v_item in select value from jsonb_array_elements(p_cart_items)
  loop
    v_pid := nullif(coalesce(
      v_item->>'producto_id', v_item->>'product_id', v_item->>'id'
    ), '')::bigint;
    v_tipo := null;
    if v_pid is not null then
      select p.tipo into v_tipo from public.productos p where p.id = v_pid;
    end if;
    if coalesce(v_tipo, '') = 'servicio' then
      v_serv := v_serv || jsonb_build_array(v_item);
    else
      v_prod := v_prod || jsonb_build_array(v_item);
    end if;
  end loop;

  -- Camino normal: sin servicios, exactamente igual que antes
  if jsonb_array_length(v_serv) = 0 then
    return query
    select * from public.create_sale_transaction_v2(
      p_user_id, p_metodo_pago, p_total, p_cart_items,
      p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
    );
    return;
  end if;

  if coalesce(p_tipo, '') <> 'pos' then
    raise exception 'Los servicios de salud solo se cobran en mostrador (POS)';
  end if;
  if p_user_id is null then raise exception 'user_id es requerido'; end if;
  if p_metodo_pago is null or btrim(p_metodo_pago) = '' then
    raise exception 'metodo_pago es requerido';
  end if;
  if p_total is null or p_total < 0 then raise exception 'total invalido'; end if;

  -- Validar servicios y calcular su total con el precio del servidor
  for v_item in select value from jsonb_array_elements(v_serv)
  loop
    v_pid := nullif(coalesce(
      v_item->>'producto_id', v_item->>'product_id', v_item->>'id'
    ), '')::bigint;
    v_qty := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;
    v_modo := lower(coalesce(v_item->>'modo_venta', 'caja'));

    select public.peso_publico(coalesce(p.precio, 0)), coalesce(p.activo, true), p.nombre
      into v_precio, v_activo, v_nombre
      from public.productos p
     where p.id = v_pid;

    if v_qty is null or v_qty <= 0 then
      raise exception 'cantidad invalida para servicio %', v_nombre;
    end if;
    if v_modo <> 'caja' then
      raise exception 'El servicio % no se vende por unidad ni por blister', v_nombre;
    end if;
    if not v_activo then
      raise exception 'El servicio % está desactivado', v_nombre;
    end if;
    if coalesce(v_precio, 0) <= 0 then
      raise exception 'El servicio % no tiene precio', v_nombre;
    end if;

    v_serv_total := v_serv_total + v_precio * v_qty;
  end loop;

  -- Productos: por v2 (FEFO + validación de precio). Servicios: aparte.
  if jsonb_array_length(v_prod) > 0 then
    select t.pedido_id, t.success
      into v_pedido_id, v_ok
      from public.create_sale_transaction_v2(
        p_user_id, p_metodo_pago, round(p_total - v_serv_total, 2), v_prod,
        p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
      ) t;
    if not coalesce(v_ok, false) or v_pedido_id is null then
      raise exception 'No se pudo crear la venta';
    end if;
  else
    if round(p_total, 2) <> round(v_serv_total, 2) then
      raise exception 'Total mismatch detected (esperado %, recibido %)',
        round(v_serv_total, 2), round(p_total, 2);
    end if;
    insert into public.pedidos (
      cliente_id, total, estado, tipo, tipo_entrega, metodo_pago, atendido_por, notas
    ) values (
      p_cliente_id, round(p_total, 2), 'completado', 'tienda_fisica',
      p_tipo_entrega, p_metodo_pago, p_user_id, null
    ) returning id into v_pedido_id;
  end if;

  -- Renglones de servicio: sin lote, sin stock, sin movimiento de inventario.
  -- El costo lo congelamos aquí con origen 'servicio' (el trigger se salta).
  v_flag_prev := coalesce(current_setting('app.fc_consumo_manual', true), '');
  perform set_config('app.fc_consumo_manual', '1', true);

  for v_item in select value from jsonb_array_elements(v_serv)
  loop
    v_pid := nullif(coalesce(
      v_item->>'producto_id', v_item->>'product_id', v_item->>'id'
    ), '')::bigint;
    v_qty := nullif(coalesce(v_item->>'cantidad', v_item->>'qty'), '')::integer;

    select public.peso_publico(coalesce(p.precio, 0)), greatest(coalesce(p.costo, 0), 0)
      into v_precio, v_costo
      from public.productos p
     where p.id = v_pid;

    insert into public.pedido_items (
      pedido_id, producto_id, cantidad, precio_unitario, lote_id
    ) values (
      v_pedido_id, v_pid, v_qty, v_precio, null
    ) returning id into v_item_id;

    insert into public.pedido_item_consumos (
      pedido_item_id, lote_id, modo, cantidad, costo_unitario, costo_origen
    ) values (
      v_item_id, null, 'caja', v_qty, v_costo, 'servicio'
    );
  end loop;

  perform set_config('app.fc_consumo_manual', v_flag_prev, true);

  update public.pedidos set total = round(p_total, 2) where id = v_pedido_id;

  return query select v_pedido_id, true;
end;
$function$;

revoke all on function public.fn_venta_pos_con_servicios(bigint, text, numeric, jsonb, bigint, text, text, text) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. Los dos puntos de entrada del POS llaman al helper
--    (idénticos a los actuales salvo la llamada a v2)
-- ---------------------------------------------------------------------------
create or replace function public.create_sale_transaction_secure(
  p_session_token uuid, p_metodo_pago text, p_total numeric, p_cart_items jsonb,
  p_cliente_id bigint default null, p_tipo text default 'pos',
  p_tipo_entrega text default null, p_direccion text default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $function$
declare
  v_actor bigint;
  v_atendido bigint;
begin
  v_actor := public.fn_require_caja_abierta_vendedor(p_session_token);
  v_atendido := public.fn_atendido_por_venta(v_actor);
  return query
  select * from public.fn_venta_pos_con_servicios(
    v_atendido, p_metodo_pago, p_total, p_cart_items,
    p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
  );
end;
$function$;

create or replace function public.empleado_cobrar_venta_pos(
  p_session_token uuid, p_metodo_pago text, p_total numeric, p_cart_items jsonb,
  p_cliente_id bigint default null, p_tipo text default 'pos',
  p_tipo_entrega text default null, p_direccion text default null,
  p_monto_credito numeric default 0, p_monto_efectivo numeric default null,
  p_monto_tarjeta numeric default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $function$
declare
  v_actor bigint;
  v_atendido bigint;
  v_pedido_id bigint;
  v_ok boolean;
  v_cred numeric;
  v_metodo text;
  v_ef numeric;
  v_tar numeric;
  v_a_cobrar numeric;
begin
  v_actor := public.fn_require_caja_abierta_vendedor(p_session_token);
  v_atendido := public.fn_atendido_por_venta(v_actor);
  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo = '' then
    raise exception 'metodo_pago es requerido';
  end if;

  v_cred := round(coalesce(p_monto_credito, 0), 2);
  if v_cred < 0 then
    raise exception 'Crédito inválido';
  end if;
  if v_cred > 0 and p_cliente_id is null then
    raise exception 'Identifica al cliente para usar su crédito';
  end if;
  if v_cred > round(coalesce(p_total, 0), 2) then
    raise exception 'El crédito no puede ser mayor al total';
  end if;

  v_a_cobrar := round(coalesce(p_total, 0) - v_cred, 2);
  v_ef := case when p_monto_efectivo is null then null else round(p_monto_efectivo, 2) end;
  v_tar := case when p_monto_tarjeta is null then null else round(p_monto_tarjeta, 2) end;

  if v_metodo = 'mixto' then
    if v_ef is null or v_tar is null then
      raise exception 'Pago mixto requiere monto_efectivo y monto_tarjeta';
    end if;
    if v_ef <= 0 or v_tar <= 0 then
      raise exception 'En mixto, efectivo y tarjeta deben ser mayores a cero';
    end if;
    if round(v_ef + v_tar, 2) <> v_a_cobrar then
      raise exception 'Mixto: efectivo (%) + tarjeta (%) debe igualar lo por cobrar (%)',
        v_ef, v_tar, v_a_cobrar;
    end if;
  elsif v_ef is not null or v_tar is not null then
    v_ef := null;
    v_tar := null;
  end if;

  select t.pedido_id, t.success
    into v_pedido_id, v_ok
    from public.fn_venta_pos_con_servicios(
      v_atendido, v_metodo, p_total, p_cart_items,
      p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
    ) t;

  if not coalesce(v_ok, false) or v_pedido_id is null then
    raise exception 'No se pudo crear la venta';
  end if;

  if v_cred > 0 then
    perform public.fn_mover_credito_cliente(
      p_cliente_id, 'canjeado', v_cred, null, v_pedido_id,
      'Canje en venta #' || v_pedido_id, v_atendido
    );
  end if;

  if v_cred > 0 or v_metodo = 'mixto' then
    update public.pedidos
       set monto_credito = v_cred,
           monto_efectivo = coalesce(v_ef, 0),
           monto_tarjeta = coalesce(v_tar, 0)
     where id = v_pedido_id;
  end if;

  return query select v_pedido_id, true;
end;
$function$;

-- ---------------------------------------------------------------------------
-- 4. Devoluciones: un servicio no regresa a inventario
-- ---------------------------------------------------------------------------
create or replace function public.fn_ejecutar_efectos_devolucion(p_dev_id bigint, p_actor bigint)
returns void
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $function$
declare
  v_dev public.devoluciones%rowtype;
  v_it record;
  v_es_servicio boolean;
begin
  select * into v_dev from public.devoluciones where id = p_dev_id for update;
  if not found then
    raise exception 'Devolución % no encontrada', p_dev_id;
  end if;

  for v_it in
    select * from public.devolucion_items where devolucion_id = p_dev_id
  loop
    v_es_servicio := exists (
      select 1 from public.productos p
       where p.id = v_it.producto_id and p.tipo = 'servicio'
    );

    if coalesce(v_it.es_entrada, false) then
      if v_es_servicio then
        raise exception 'Un servicio no se puede entregar como cambio';
      end if;
      perform public.fn_descontar_fefo_cantidad(
        v_it.producto_id,
        ceil(coalesce(v_it.cantidad, 0))::int,
        p_actor,
        'Cambio devolución #' || p_dev_id
      );
    else
      -- Servicio devuelto: se regresa el dinero/crédito, pero no hay nada que reintegrar al stock.
      if v_it.producto_id is not null and coalesce(v_it.cantidad, 0) > 0
         and not v_es_servicio then
        perform public.restock_via_lote(
          v_it.producto_id,
          ceil(v_it.cantidad)::int,
          'Devolución #' || p_dev_id || ' - ' || coalesce(v_dev.motivo, ''),
          p_actor,
          v_it.lote_id
        );
      end if;
    end if;
  end loop;

  if coalesce(v_dev.monto_credito, 0) > 0 then
    if v_dev.cliente_id is null then
      raise exception 'Crédito requiere un cliente con teléfono';
    end if;
    perform public.fn_mover_credito_cliente(
      v_dev.cliente_id,
      'otorgado',
      v_dev.monto_credito,
      p_dev_id,
      v_dev.pedido_id,
      'Devolución #' || p_dev_id,
      p_actor
    );
  end if;

  if coalesce(v_dev.monto_credito_canje, 0) > 0 then
    if v_dev.cliente_id is null then
      raise exception 'Crédito requiere un cliente con teléfono';
    end if;
    perform public.fn_mover_credito_cliente(
      v_dev.cliente_id,
      'canjeado',
      v_dev.monto_credito_canje,
      p_dev_id,
      v_dev.pedido_id,
      'Diferencia cambio #' || p_dev_id,
      p_actor
    );
  end if;
end;
$function$;

-- ---------------------------------------------------------------------------
-- 5. "Bajo stock" ignora servicios
-- ---------------------------------------------------------------------------
create or replace function public.empleado_contar_productos_bajo_stock(p_session_token uuid)
returns integer
language plpgsql
security definer
set search_path to 'public', 'pg_temp'
as $function$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.productos p
  where coalesce(p.activo, false)
    and not coalesce(p.bajo_pedido, false)
    and coalesce(p.tipo, '') <> 'servicio'
    and public.fn_stock_anaquel(p.id) <= coalesce(p.stock_minimo, 0);
  return coalesce(v_n, 0);
end;
$function$;

-- ---------------------------------------------------------------------------
-- 6. Catálogo inicial  ── Precios confirmados 2026-10-09:
--    inyección $30, presión $20, oximetría $20 (mitad quien aplica, mitad farmacia).
--    Si la fila ya existe, el precio lo corrige patch_servicios_salud_precio_inyeccion_20261009.sql.
--    costo = 0: sin insumo propio (la jeringa / el medicamento se venden aparte).
--    Glucosa capilar entra DESACTIVADA (gasta tira + lanceta: definir costo primero).
-- ---------------------------------------------------------------------------
insert into public.productos (
  sku, nombre, categoria, subcategoria, tipo, precio, costo,
  stock, stock_minimo, activo, visible_tienda, requiere_receta,
  venta_unidad, bajo_pedido, controlado, descripcion
)
select s.sku, s.nombre, 'Servicios de salud', null, 'servicio', s.precio, s.costo,
       0, 0, s.activo, false, false,
       false, false, false, s.descripcion
from (values
  ('SERV-INY-IM',   'Aplicación de inyección intramuscular', 30::numeric, 0::numeric, true,
   'Aplicación de medicamento inyectable intramuscular. El medicamento y la jeringa se cobran aparte.'),
  ('SERV-PRESION',  'Toma de presión arterial',              20::numeric, 0::numeric, true,
   'Medición de presión arterial con baumanómetro digital.'),
  ('SERV-OXIMETRIA','Medición de oxigenación (oximetría)',   20::numeric, 0::numeric, true,
   'Medición de saturación de oxígeno y pulso con oxímetro de dedo.'),
  ('SERV-GLUCOSA',  'Medición de glucosa capilar',           40::numeric, 0::numeric, false,
   'Medición de glucosa en sangre capilar con glucómetro. Incluye tira y lanceta.')
) as s(sku, nombre, precio, costo, activo, descripcion)
where not exists (select 1 from public.productos p where p.sku = s.sku);

-- No mandar servicios al pipeline de enriquecimiento de fichas web
delete from public.enriquecimiento_jobs
 where estado = 'pendiente'
   and producto_id in (
     select id from public.productos
      where sku in ('SERV-INY-IM','SERV-PRESION','SERV-OXIMETRIA','SERV-GLUCOSA')
   );

commit;
