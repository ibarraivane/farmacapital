-- Compra de personal (precio de empleado) + cola de aprobación.
-- Ejecutar en Supabase SQL Editor (o vía migración) antes de desplegar el front.
--
-- Qué hace:
--   1) Tabla nueva `personal_compras`: la cola de aprobación. Cada fila es una
--      cuenta armada por un vendedor para un empleado beneficiario, con el
--      descuento ya calculado por línea (margen - margen mínimo, tope %).
--   2) Columnas nuevas en `pedidos`: `es_compra_personal` y `compra_personal_id`,
--      para poder identificar y excluir estas ventas de reportes/metas sin
--      tocar la tabla `pedidos` en su forma de siempre.
--   3) Parámetros nuevos en `configuracion` (todos ajustables sin tocar código).
--   4) RPCs:
--      - empleado_personal_compra_solicitar   (vendedor, requiere caja abierta)
--      - empleado_personal_compra_listar_propias (vendedor; sin costo/margen)
--      - empleado_personal_compra_cobrar      (vendedor, requiere caja abierta;
--        solo sobre una compra ya 'aprobada')
--      - admin_personal_compra_listar_pendientes (admin/gerente; con costo/margen)
--      - admin_personal_compra_aprobar / _rechazar (admin/gerente)
--   5) Trigger: al cerrar una caja_sesion, cualquier personal_compras de ese
--      turno que siga 'pendiente_aprobacion' o 'aprobada' (nunca cobrada) pasa
--      a 'cancelada_por_cierre_turno'. No se toca el RPC de cierre de caja.
--
-- Decisión de diseño importante: NO se reutiliza create_sale_transaction_v2
-- para el cobro final, porque esa función recalcula su propio precio "oficial"
-- del producto y rechaza el total si no coincide (protección anti-manipulación
-- de precio). Como aquí el precio final SÍ es distinto al de lista (por el
-- descuento), el cobro de una compra de personal se hace con su propia función
-- (empleado_personal_compra_cobrar), que reutiliza la misma lógica de consumo
-- de lotes FEFO (get_lote_fefo / fn_ensure_lote_stock_vendible) pero no toca
-- ni redefine create_sale_transaction_v2. Alcance: solo modo de venta "caja"
-- (no unidad/blister) por ahora.

begin;

-- 1) Columnas nuevas en pedidos --------------------------------------------

alter table public.pedidos
  add column if not exists es_compra_personal boolean not null default false;

alter table public.pedidos
  add column if not exists compra_personal_id bigint null;

comment on column public.pedidos.es_compra_personal is
  'true si este pedido viene de una compra de personal (precio de empleado). '
  'Excluir con "and es_compra_personal = false" en reportes/metas de venta '
  'que no deban incluir este tipo de venta (ver farmacapital-spec-descuento-empleado.md).';

comment on column public.pedidos.compra_personal_id is
  'fk a personal_compras.id cuando es_compra_personal = true.';

-- 2) Tabla de la cola de aprobación -----------------------------------------

create table if not exists public.personal_compras (
  id                      bigint generated always as identity primary key,
  empleado_beneficiario_id bigint not null references public.empleados(id),
  vendedor_id             bigint not null references public.usuarios(id),
  caja_sesion_id          bigint null references public.caja_sesiones(id),
  estado                  text not null default 'pendiente_aprobacion'
                            check (estado in (
                              'pendiente_aprobacion', 'aprobada', 'rechazada',
                              'cobrada', 'cancelada_por_cierre_turno'
                            )),
  items                   jsonb not null,
  total_lista             numeric not null default 0,
  total_descuento         numeric not null default 0,
  total_final             numeric not null default 0,
  excede_tope_mensual     boolean not null default false,
  excede_limite_producto  boolean not null default false,
  motivo_rechazo          text null,
  aprobado_por            bigint null references public.usuarios(id),
  aprobado_at             timestamptz null,
  pedido_id               bigint null references public.pedidos(id),
  creado_at               timestamptz not null default now(),
  actualizado_at          timestamptz not null default now()
);

comment on table public.personal_compras is
  'Cola de aprobación de compras de personal (precio de empleado). '
  'items es un snapshot jsonb por línea: producto_id, nombre, sku, cantidad, '
  'precio_venta, costo, costo_estimado, margen_pct, descuento_pct, '
  'descuento_monto, precio_final. El vendedor nunca ve costo/margen: esos '
  'campos solo se exponen a través de las RPCs admin_*.';

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'fk_pedidos_compra_personal'
  ) then
    alter table public.pedidos
      add constraint fk_pedidos_compra_personal
      foreign key (compra_personal_id) references public.personal_compras(id);
  end if;
end $$;

alter table public.personal_compras enable row level security;
-- Sin policies para anon/authenticated: igual que el resto de tablas
-- operativas del proyecto, todo el acceso pasa por RPCs security definer.

create index if not exists idx_personal_compras_estado
  on public.personal_compras (estado);
create index if not exists idx_personal_compras_beneficiario_mes
  on public.personal_compras (empleado_beneficiario_id, creado_at);

-- 3) Parámetros configurables -------------------------------------------

insert into public.configuracion (clave, valor, descripcion) values
  ('margen_minimo_empleado', '10',
    'Compra de personal: margen mínimo (%) que el negocio conserva aunque el margen del producto sea mayor.'),
  ('tope_descuento_empleado', '20',
    'Compra de personal: descuento máximo (%) aunque el margen lo permita.'),
  ('tope_unidades_mismo_producto_empleado', '1',
    'Compra de personal: máximo de piezas del mismo producto por transacción.'),
  ('tope_mensual_descuento_empleado', '200',
    'Compra de personal: descuento acumulado máximo (MXN) por empleado beneficiario por mes calendario.')
on conflict (clave) do nothing;

-- 4) RPCs --------------------------------------------------------------

-- Vendedor: arma el carrito, elige beneficiario, el sistema calcula el
-- descuento por línea y manda la cuenta a aprobación. No devuelve costo
-- ni margen: solo el total final y si algo excede los límites configurados.
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

  select nombre into v_nombre_beneficiario
    from public.empleados where id = p_empleado_beneficiario_id;
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

  select id into v_caja_sesion_id from public.caja_sesiones
    where empleado_id = v_user_id and estado = 'abierta'
    order by abierta_at desc limit 1;

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
    -- Misma prioridad que farmacapital-spec-grafica-operacion.md §4.
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

-- Vendedor: sus propias compras de personal recientes (sin costo/margen),
-- para que el POS le muestre el estado ("pendiente", "aprobada, ya puedes
-- cobrarla", "rechazada: <motivo>").
create or replace function public.empleado_personal_compra_listar_propias(p_session_token uuid)
returns table(
  id bigint,
  empleado_beneficiario_nombre text,
  estado text,
  total_final numeric,
  motivo_rechazo text,
  creado_at timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
    select pc.id, e.nombre, pc.estado, pc.total_final, pc.motivo_rechazo, pc.creado_at
    from public.personal_compras pc
    join public.empleados e on e.id = pc.empleado_beneficiario_id
    where pc.vendedor_id = v_user_id
      and pc.estado in ('pendiente_aprobacion','aprobada','rechazada')
    order by pc.creado_at desc
    limit 50;
end;
$$;

grant execute on function public.empleado_personal_compra_listar_propias(uuid)
  to anon, authenticated;

-- Admin/gerente: cola completa con costo y margen por línea, para decidir.
create or replace function public.admin_personal_compra_listar_pendientes(p_session_token uuid)
returns table(
  id bigint,
  empleado_beneficiario_id bigint,
  empleado_beneficiario_nombre text,
  vendedor_id bigint,
  vendedor_nombre text,
  estado text,
  items jsonb,
  total_lista numeric,
  total_descuento numeric,
  total_final numeric,
  excede_tope_mensual boolean,
  excede_limite_producto boolean,
  uso_mensual_previo numeric,
  creado_at timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform public.fn_require_admin(p_session_token);
  return query
    select
      pc.id, pc.empleado_beneficiario_id, e.nombre, pc.vendedor_id, u.nombre,
      pc.estado, pc.items, pc.total_lista, pc.total_descuento, pc.total_final,
      pc.excede_tope_mensual, pc.excede_limite_producto,
      coalesce((
        select sum((it->>'descuento_monto')::numeric)
        from public.personal_compras pc2, jsonb_array_elements(pc2.items) it
        where pc2.empleado_beneficiario_id = pc.empleado_beneficiario_id
          and pc2.estado in ('aprobada','cobrada')
          and pc2.id <> pc.id
          and pc2.creado_at >= (date_trunc('month', now() at time zone 'America/Mexico_City') at time zone 'America/Mexico_City')
      ), 0),
      pc.creado_at
    from public.personal_compras pc
    join public.empleados e on e.id = pc.empleado_beneficiario_id
    join public.usuarios u on u.id = pc.vendedor_id
    where pc.estado = 'pendiente_aprobacion'
    order by pc.creado_at asc;
end;
$$;

grant execute on function public.admin_personal_compra_listar_pendientes(uuid)
  to anon, authenticated;

create or replace function public.admin_personal_compra_aprobar(p_session_token uuid, p_id bigint)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_admin_id bigint;
  v_estado text;
begin
  v_admin_id := public.fn_require_admin(p_session_token);
  select estado into v_estado from public.personal_compras where id = p_id for update;
  if v_estado is null then
    raise exception 'Compra de personal no encontrada';
  end if;
  if v_estado <> 'pendiente_aprobacion' then
    raise exception 'Esta compra ya no está pendiente (estado actual: %)', v_estado;
  end if;

  update public.personal_compras
    set estado = 'aprobada', aprobado_por = v_admin_id, aprobado_at = now(), actualizado_at = now()
    where id = p_id;

  insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    select v_admin_id, u.nombre, 'COMPRA_PERSONAL_APROBAR', 'personal_compras', p_id::text, '{}'::jsonb
    from public.usuarios u where u.id = v_admin_id;

  return true;
end;
$$;

grant execute on function public.admin_personal_compra_aprobar(uuid, bigint)
  to anon, authenticated;

create or replace function public.admin_personal_compra_rechazar(
  p_session_token uuid, p_id bigint, p_motivo text default null
)
returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_admin_id bigint;
  v_estado text;
begin
  v_admin_id := public.fn_require_admin(p_session_token);
  select estado into v_estado from public.personal_compras where id = p_id for update;
  if v_estado is null then
    raise exception 'Compra de personal no encontrada';
  end if;
  if v_estado <> 'pendiente_aprobacion' then
    raise exception 'Esta compra ya no está pendiente (estado actual: %)', v_estado;
  end if;

  update public.personal_compras
    set estado = 'rechazada', aprobado_por = v_admin_id, aprobado_at = now(),
        motivo_rechazo = p_motivo, actualizado_at = now()
    where id = p_id;

  insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    select v_admin_id, u.nombre, 'COMPRA_PERSONAL_RECHAZAR', 'personal_compras', p_id::text,
      jsonb_build_object('motivo', p_motivo)
    from public.usuarios u where u.id = v_admin_id;

  return true;
end;
$$;

grant execute on function public.admin_personal_compra_rechazar(uuid, bigint, text)
  to anon, authenticated;

-- Vendedor: cobra una compra de personal ya 'aprobada'. No reutiliza
-- create_sale_transaction_v2 (ver nota al inicio del archivo): crea el
-- pedido y consume lotes FEFO por su cuenta, con el precio_final ya
-- calculado en la solicitud.
create or replace function public.empleado_personal_compra_cobrar(
  p_session_token uuid,
  p_id bigint,
  p_metodo_pago text,
  p_monto_efectivo numeric default null,
  p_monto_tarjeta numeric default null
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_compra record;
  v_pedido_id bigint;
  v_item jsonb;
  v_producto_id bigint;
  v_cantidad integer;
  v_precio_final numeric;
  v_restante integer;
  v_lote_id bigint;
  v_lote_disponible integer;
  v_lote_tomar integer;
  v_metodo text;
  v_notas text;
begin
  v_user_id := public.fn_require_caja_abierta_vendedor(p_session_token);

  select * into v_compra from public.personal_compras where id = p_id for update;
  if v_compra is null then
    raise exception 'Compra de personal no encontrada';
  end if;
  if v_compra.estado <> 'aprobada' then
    raise exception 'Esta compra de personal no está aprobada (estado actual: %)', v_compra.estado;
  end if;

  v_metodo := lower(btrim(coalesce(p_metodo_pago, '')));
  if v_metodo not in ('efectivo','tarjeta','mercadopago','mercadopago_point','spei','mixto') then
    raise exception 'metodo_pago inválido: %', v_metodo;
  end if;

  if v_metodo = 'mixto' then
    if p_monto_efectivo is null or p_monto_tarjeta is null then
      raise exception 'Pago mixto requiere monto_efectivo y monto_tarjeta';
    end if;
    if round(coalesce(p_monto_efectivo,0) + coalesce(p_monto_tarjeta,0), 2) <> round(v_compra.total_final, 2) then
      raise exception 'Mixto: efectivo + tarjeta debe igualar el total (%)', v_compra.total_final;
    end if;
  end if;

  v_notas := 'Compra de personal #' || p_id || ' — beneficiario: ' ||
    coalesce((select nombre from public.empleados where id = v_compra.empleado_beneficiario_id), '—');

  insert into public.pedidos (
    total, estado, tipo, metodo_pago, atendido_por, notas,
    monto_efectivo, monto_tarjeta, es_compra_personal, compra_personal_id
  ) values (
    v_compra.total_final, 'completado', 'tienda_fisica', v_metodo, v_user_id, v_notas,
    coalesce(p_monto_efectivo,0), coalesce(p_monto_tarjeta,0), true, p_id
  ) returning id into v_pedido_id;

  for v_item in select value from jsonb_array_elements(v_compra.items)
  loop
    v_producto_id := (v_item->>'producto_id')::bigint;
    v_cantidad := (v_item->>'cantidad')::integer;
    v_precio_final := (v_item->>'precio_final')::numeric;

    perform public.fn_ensure_lote_stock_vendible(v_producto_id);
    v_restante := v_cantidad;
    while v_restante > 0 loop
      select f.lote_id, f.cantidad_disponible into v_lote_id, v_lote_disponible
        from public.get_lote_fefo(v_producto_id) f;
      if not found or v_lote_id is null then
        raise exception 'Sin lotes disponibles para % (id %); no se pudo completar el cobro',
          (v_item->>'nombre'), v_producto_id;
      end if;
      v_lote_tomar := least(v_restante, coalesce(v_lote_disponible, 0));
      if v_lote_tomar <= 0 then
        raise exception 'Lote FEFO inválido para producto %', v_producto_id;
      end if;

      update public.lotes
        set cantidad_actual = greatest(0, coalesce(cantidad_actual,0) - v_lote_tomar),
            activo = case
              when greatest(0, coalesce(cantidad_actual,0) - v_lote_tomar) <= 0 then false
              else activo
            end
        where id = v_lote_id;

      insert into public.pedido_items (pedido_id, producto_id, cantidad, precio_unitario, lote_id)
        values (v_pedido_id, v_producto_id, v_lote_tomar, v_precio_final, v_lote_id);

      v_restante := v_restante - v_lote_tomar;
    end loop;

    insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id, referencia)
      values (v_producto_id, 'salida', v_cantidad,
        format('Compra de personal #%s pedido #%s', p_id, v_pedido_id), v_user_id, v_pedido_id::text);
  end loop;

  update public.personal_compras
    set estado = 'cobrada', pedido_id = v_pedido_id, actualizado_at = now()
    where id = p_id;

  insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    select v_user_id, u.nombre, 'COMPRA_PERSONAL_COBRAR', 'personal_compras', p_id::text,
      jsonb_build_object('pedido_id', v_pedido_id, 'total', v_compra.total_final)
    from public.usuarios u where u.id = v_user_id;

  return query select v_pedido_id, true;

exception when others then
  raise;
end;
$$;

grant execute on function public.empleado_personal_compra_cobrar(uuid, bigint, text, numeric, numeric)
  to anon, authenticated;

-- 5) Cierre de turno cancela lo que quedó sin cobrar --------------------

create or replace function public.fn_personal_compra_cancelar_al_cerrar_caja()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if NEW.estado = 'cerrada' and coalesce(OLD.estado, '') <> 'cerrada' then
    update public.personal_compras
      set estado = 'cancelada_por_cierre_turno', actualizado_at = now()
      where caja_sesion_id = NEW.id
        and estado in ('pendiente_aprobacion', 'aprobada');
  end if;
  return NEW;
end;
$$;

drop trigger if exists trg_personal_compra_cancelar_al_cerrar_caja on public.caja_sesiones;
create trigger trg_personal_compra_cancelar_al_cerrar_caja
  after update of estado on public.caja_sesiones
  for each row
  execute function public.fn_personal_compra_cancelar_al_cerrar_caja();

-- 6) Selector de beneficiario para el vendedor ---------------------------
-- admin_listar_empleados exige rol admin/gerente (trae salario y datos de
-- nómina). El vendedor solo necesita elegir a quién corresponde la compra.
create or replace function public.empleado_listar_personal_activo(p_session_token uuid)
returns table(id bigint, nombre text)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
begin
  v_user_id := public.fn_require_empleado(p_session_token);
  return query
    select e.id, e.nombre
    from public.empleados e
    where e.estado = true
    order by e.nombre asc;
end;
$$;

grant execute on function public.empleado_listar_personal_activo(uuid)
  to anon, authenticated;

commit;
