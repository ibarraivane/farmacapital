-- ============================================================
-- Devoluciones: caja, crédito en tienda, cambio y aprobación
-- 20 ago 2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- 1) El efectivo entregado en una devolución se resta del corte.
-- 2) Crédito en tienda (saldo en pesos, historial de movimientos).
-- 3) Cambio de producto (entra lo devuelto, sale lo nuevo, sólo la diferencia).
-- 4) Arriba de $800 o fuera de política → pendiente, un admin aprueba.
--
-- No hay reverso a tarjeta (MercadoPago). No genera CFDI.
-- ============================================================

begin;

insert into public.configuracion (clave, valor)
select v.clave, v.valor
from (values
  ('umbral_devolucion', '800'),
  ('dias_ventana_devolucion', '7'),
  ('bono_credito_pct', '0')
) as v(clave, valor)
where not exists (
  select 1 from public.configuracion c where c.clave = v.clave
);

alter table public.devoluciones
  add column if not exists tipo text not null default 'reembolso',
  add column if not exists metodo_pago_original text,
  add column if not exists monto_efectivo numeric not null default 0,
  add column if not exists monto_efectivo_ingreso numeric not null default 0,
  add column if not exists monto_tarjeta_ingreso numeric not null default 0,
  add column if not exists monto_credito numeric not null default 0,
  add column if not exists monto_credito_canje numeric not null default 0,
  add column if not exists bono_credito numeric not null default 0,
  add column if not exists requiere_aprobacion boolean not null default false,
  add column if not exists cliente_presente boolean not null default true,
  add column if not exists aprobado_por bigint references public.usuarios(id),
  add column if not exists aprobado_at timestamptz,
  add column if not exists motivo_rechazo text;

alter table public.devolucion_items
  add column if not exists es_entrada boolean not null default false,
  add column if not exists lote_id bigint;

alter table public.clientes
  add column if not exists saldo_credito numeric not null default 0;

alter table public.pedidos
  add column if not exists monto_credito numeric not null default 0;

create table if not exists public.clientes_credito_movimientos (
  id bigint generated always as identity primary key,
  cliente_id bigint not null references public.clientes(id),
  devolucion_id bigint references public.devoluciones(id),
  pedido_id bigint references public.pedidos(id),
  tipo text not null,
  monto numeric not null,
  saldo_resultante numeric not null,
  motivo text,
  creado_por bigint references public.usuarios(id),
  created_at timestamptz not null default now(),
  constraint clientes_credito_movimientos_tipo_chk
    check (tipo in ('otorgado', 'canjeado', 'ajuste', 'expirado'))
);

create index if not exists idx_credito_mov_cliente
  on public.clientes_credito_movimientos (cliente_id, created_at desc);

alter table public.clientes_credito_movimientos enable row level security;
revoke all on table public.clientes_credito_movimientos from anon, authenticated;
grant all on table public.clientes_credito_movimientos to postgres, service_role;

-- Devoluciones en efectivo ya hechas: que el corte de hoy las vea.
update public.devoluciones
   set monto_efectivo = coalesce(total_devuelto, 0)
 where estado = 'aprobada'
   and lower(coalesce(metodo_reembolso, '')) = 'efectivo'
   and coalesce(monto_efectivo, 0) = 0
   and coalesce(monto_credito, 0) = 0;

-- ── helpers ──────────────────────────────────────────────────

create or replace function public.fn_config_num(p_clave text, p_default numeric)
returns numeric
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v text;
begin
  select valor into v from public.configuracion where clave = p_clave limit 1;
  if v is null or btrim(v) = '' then
    return p_default;
  end if;
  begin
    return v::numeric;
  exception when others then
    return p_default;
  end;
end;
$$;

create or replace function public.fn_mover_credito_cliente(
  p_cliente_id bigint,
  p_tipo text,
  p_monto numeric,
  p_devolucion_id bigint,
  p_pedido_id bigint,
  p_motivo text,
  p_actor bigint
)
returns numeric
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_saldo numeric;
  v_nuevo numeric;
  v_monto numeric;
begin
  if p_cliente_id is null then
    raise exception 'Cliente requerido para el crédito';
  end if;
  v_monto := round(coalesce(p_monto, 0), 2);
  if v_monto <= 0 then
    raise exception 'Monto de crédito inválido';
  end if;

  select coalesce(saldo_credito, 0) into v_saldo
    from public.clientes
   where id = p_cliente_id
   for update;
  if not found then
    raise exception 'Cliente % no encontrado', p_cliente_id;
  end if;

  if p_tipo = 'canjeado' then
    if v_saldo + 0.001 < v_monto then
      raise exception 'Saldo de crédito insuficiente (% disponible)', v_saldo;
    end if;
    v_nuevo := round(v_saldo - v_monto, 2);
  else
    v_nuevo := round(v_saldo + v_monto, 2);
  end if;

  update public.clientes
     set saldo_credito = v_nuevo
   where id = p_cliente_id;

  insert into public.clientes_credito_movimientos (
    cliente_id, devolucion_id, pedido_id, tipo, monto, saldo_resultante, motivo, creado_por
  ) values (
    p_cliente_id, p_devolucion_id, p_pedido_id, p_tipo, v_monto, v_nuevo, p_motivo, p_actor
  );

  return v_nuevo;
end;
$$;

create or replace function public.fn_descontar_fefo_cantidad(
  p_producto_id bigint,
  p_cantidad integer,
  p_actor bigint,
  p_motivo text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_restante integer;
  v_lote_id bigint;
  v_disp integer;
  v_tomar integer;
begin
  if p_producto_id is null or coalesce(p_cantidad, 0) <= 0 then
    return;
  end if;
  perform public.fn_ensure_lote_stock_vendible(p_producto_id);
  v_restante := p_cantidad;
  while v_restante > 0 loop
    select f.lote_id, f.cantidad_disponible
      into v_lote_id, v_disp
      from public.get_lote_fefo(p_producto_id) f;
    if not found or coalesce(v_disp, 0) <= 0 then
      raise exception 'Sin stock para el producto %', p_producto_id;
    end if;
    v_tomar := least(v_restante, v_disp);
    update public.lotes
       set cantidad_actual = greatest(0, coalesce(cantidad_actual, 0) - v_tomar),
           activo = case
             when greatest(0, coalesce(cantidad_actual, 0) - v_tomar) <= 0 then false
             else activo
           end
     where id = v_lote_id;
    v_restante := v_restante - v_tomar;
  end loop;
  insert into public.movimientos_inventario (producto_id, tipo, cantidad, motivo, usuario_id)
  values (p_producto_id, 'salida', p_cantidad, p_motivo, p_actor);
end;
$$;

create or replace function public.fn_ejecutar_efectos_devolucion(
  p_dev_id bigint,
  p_actor bigint
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dev public.devoluciones%rowtype;
  v_it record;
begin
  select * into v_dev from public.devoluciones where id = p_dev_id for update;
  if not found then
    raise exception 'Devolución % no encontrada', p_dev_id;
  end if;

  for v_it in
    select * from public.devolucion_items where devolucion_id = p_dev_id
  loop
    if coalesce(v_it.es_entrada, false) then
      perform public.fn_descontar_fefo_cantidad(
        v_it.producto_id,
        ceil(coalesce(v_it.cantidad, 0))::int,
        p_actor,
        'Cambio devolución #' || p_dev_id
      );
    else
      if v_it.producto_id is not null and coalesce(v_it.cantidad, 0) > 0 then
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
$$;

create or replace function public.fn_asegurar_cliente_telefono(
  p_telefono text,
  p_nombre text default null
)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_tel text;
  v_id bigint;
begin
  v_tel := regexp_replace(coalesce(p_telefono, ''), '\D', '', 'g');
  if length(v_tel) = 11 and left(v_tel, 1) = '1' then
    v_tel := right(v_tel, 10);
  end if;
  if length(v_tel) = 12 and left(v_tel, 2) = '52' then
    v_tel := right(v_tel, 10);
  end if;
  if length(v_tel) <> 10 then
    raise exception 'Teléfono a 10 dígitos para el crédito';
  end if;
  select id into v_id from public.clientes where telefono = v_tel limit 1;
  if v_id is not null then
    return v_id;
  end if;
  insert into public.clientes (nombre, telefono, puntos, saldo_credito)
  values (coalesce(nullif(btrim(p_nombre), ''), 'Cliente ' || v_tel), v_tel, 0, 0)
  returning id into v_id;
  return v_id;
end;
$$;

-- ── crear_devolucion ─────────────────────────────────────────

drop function if exists public.crear_devolucion(uuid, bigint, text, text, jsonb, text);

create or replace function public.crear_devolucion(
  p_session_token uuid,
  p_pedido_id bigint,
  p_motivo text,
  p_metodo_reembolso text,
  p_items jsonb,
  p_notas text default null,
  p_tipo text default 'reembolso',
  p_items_nuevos jsonb default '[]'::jsonb,
  p_cliente_presente boolean default true,
  p_telefono_credito text default null,
  p_metodo_cobro_diferencia text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_pedido record;
  v_dev_id bigint;
  v_total numeric := 0;
  v_total_nuevo numeric := 0;
  v_diff numeric := 0;
  v_item jsonb;
  v_producto_id bigint;
  v_lote_id bigint;
  v_cantidad numeric;
  v_precio numeric;
  v_precio_db numeric;
  v_tipo text;
  v_metodo text;
  v_cobro_diff text;
  v_monto_ef numeric := 0;
  v_monto_ef_in numeric := 0;
  v_monto_tar_in numeric := 0;
  v_monto_cred numeric := 0;
  v_monto_cred_canje numeric := 0;
  v_bono numeric := 0;
  v_pct numeric;
  v_umbral numeric;
  v_dias numeric;
  v_pendiente boolean := false;
  v_farmacia boolean := false;
  v_edad_dias numeric;
  v_cliente_id bigint;
  v_estado text;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);

  if p_motivo is null or length(trim(p_motivo)) = 0 then
    raise exception 'Motivo requerido';
  end if;
  if jsonb_array_length(coalesce(p_items, '[]'::jsonb)) = 0 then
    raise exception 'Debe incluir al menos un item';
  end if;

  v_tipo := lower(coalesce(nullif(btrim(p_tipo), ''), 'reembolso'));
  if v_tipo not in ('reembolso', 'cambio_producto') then
    raise exception 'Tipo inválido';
  end if;

  v_metodo := lower(coalesce(nullif(btrim(p_metodo_reembolso), ''), 'efectivo'));
  if v_metodo in ('tarjeta', 'puntos') then
    v_metodo := 'efectivo';
  end if;

  select id, cliente_id, metodo_pago, created_at, total
    into v_pedido
    from public.pedidos
   where id = p_pedido_id;
  if v_pedido.id is null then
    raise exception 'Pedido % no encontrado', p_pedido_id;
  end if;

  v_cliente_id := v_pedido.cliente_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_total := v_total +
      ((v_item->>'cantidad')::numeric * (v_item->>'precio_unitario')::numeric);
  end loop;
  v_total := round(coalesce(v_total, 0), 2);

  if v_tipo = 'cambio_producto' then
    for v_item in select * from jsonb_array_elements(coalesce(p_items_nuevos, '[]'::jsonb))
    loop
      v_producto_id := (v_item->>'producto_id')::bigint;
      v_cantidad := (v_item->>'cantidad')::numeric;
      select round(coalesce(precio, 0), 0) into v_precio_db
        from public.productos where id = v_producto_id;
      if not found then
        raise exception 'Producto nuevo % no encontrado', v_producto_id;
      end if;
      v_total_nuevo := v_total_nuevo + (v_cantidad * v_precio_db);
    end loop;
    v_total_nuevo := round(coalesce(v_total_nuevo, 0), 2);
    if v_total_nuevo <= 0 then
      raise exception 'El cambio necesita al menos un producto nuevo';
    end if;
  end if;

  v_diff := round(v_total_nuevo - v_total, 2);
  v_cobro_diff := lower(coalesce(nullif(btrim(p_metodo_cobro_diferencia), ''), 'efectivo'));

  v_pct := public.fn_config_num('bono_credito_pct', 0);

  if v_tipo = 'reembolso' then
    if v_metodo = 'credito' then
      v_bono := round(v_total * greatest(v_pct, 0) / 100.0, 2);
      v_monto_cred := round(v_total + v_bono, 2);
    else
      v_metodo := 'efectivo';
      v_monto_ef := v_total;
    end if;
  else
    if v_diff = 0 then
      v_metodo := 'cambio';
    elsif v_diff < 0 then
      if v_metodo = 'credito' then
        v_bono := round(abs(v_diff) * greatest(v_pct, 0) / 100.0, 2);
        v_monto_cred := round(abs(v_diff) + v_bono, 2);
      else
        v_metodo := 'efectivo';
        v_monto_ef := abs(v_diff);
      end if;
    else
      v_metodo := 'cambio';
      if v_cobro_diff = 'credito' then
        if v_cliente_id is null then
          v_cliente_id := public.fn_asegurar_cliente_telefono(p_telefono_credito, null);
        end if;
        perform 1 from public.clientes
         where id = v_cliente_id
           and coalesce(saldo_credito, 0) + 0.001 >= v_diff;
        if not found then
          raise exception 'El cliente no tiene crédito suficiente para la diferencia';
        end if;
        v_monto_cred_canje := v_diff;
      elsif v_cobro_diff = 'tarjeta' then
        v_monto_tar_in := v_diff;
      else
        v_monto_ef_in := v_diff;
      end if;
    end if;
  end if;

  if v_monto_cred > 0 then
    if v_cliente_id is null then
      v_cliente_id := public.fn_asegurar_cliente_telefono(
        p_telefono_credito,
        null
      );
    end if;
  end if;

  v_umbral := public.fn_config_num('umbral_devolucion', 800);
  v_dias := public.fn_config_num('dias_ventana_devolucion', 7);
  v_farmacia := p_motivo in (
    'Producto en mal estado',
    'Producto incorrecto',
    'Error en la venta',
    'Cobro duplicado'
  );
  v_edad_dias := extract(epoch from (now() - v_pedido.created_at)) / 86400.0;

  if v_total > v_umbral then
    v_pendiente := true;
  elsif coalesce(p_cliente_presente, true) = false
    and not v_farmacia
    and v_edad_dias > v_dias then
    v_pendiente := true;
  end if;

  v_estado := case when v_pendiente then 'pendiente' else 'aprobada' end;

  insert into public.devoluciones (
    pedido_id, cliente_id, motivo, estado, total_devuelto,
    metodo_reembolso, notas, atendido_por,
    tipo, metodo_pago_original, monto_efectivo, monto_efectivo_ingreso,
    monto_tarjeta_ingreso, monto_credito, monto_credito_canje, bono_credito,
    requiere_aprobacion, cliente_presente
  ) values (
    v_pedido.id, v_cliente_id, p_motivo, v_estado, v_total,
    v_metodo, p_notas, v_actor_id,
    v_tipo, v_pedido.metodo_pago, v_monto_ef, v_monto_ef_in,
    v_monto_tar_in, v_monto_cred, v_monto_cred_canje, v_bono,
    v_pendiente, coalesce(p_cliente_presente, true)
  ) returning id into v_dev_id;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_producto_id := (v_item->>'producto_id')::bigint;
    v_lote_id := nullif(v_item->>'lote_id', '')::bigint;
    v_cantidad := (v_item->>'cantidad')::numeric;
    v_precio := (v_item->>'precio_unitario')::numeric;
    insert into public.devolucion_items (
      devolucion_id, producto_id, producto_nombre, cantidad, precio_unitario, es_entrada, lote_id
    ) values (
      v_dev_id, v_producto_id,
      coalesce(v_item->>'producto_nombre', 'Producto'),
      v_cantidad, v_precio, false, v_lote_id
    );
  end loop;

  if v_tipo = 'cambio_producto' then
    for v_item in select * from jsonb_array_elements(coalesce(p_items_nuevos, '[]'::jsonb))
    loop
      v_producto_id := (v_item->>'producto_id')::bigint;
      v_cantidad := (v_item->>'cantidad')::numeric;
      select round(coalesce(precio, 0), 0) into v_precio_db
        from public.productos where id = v_producto_id;
      insert into public.devolucion_items (
        devolucion_id, producto_id, producto_nombre, cantidad, precio_unitario, es_entrada
      ) values (
        v_dev_id, v_producto_id,
        coalesce((select nombre from public.productos where id = v_producto_id), 'Producto'),
        v_cantidad, v_precio_db, true
      );
    end loop;
  end if;

  if not v_pendiente then
    perform public.fn_ejecutar_efectos_devolucion(v_dev_id, v_actor_id);
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id,
      (select nombre from public.usuarios where id = v_actor_id),
      'crear_devolucion', 'devoluciones', v_dev_id::text,
      jsonb_build_object(
        'pedido_id', p_pedido_id, 'total', v_total, 'estado', v_estado,
        'tipo', v_tipo, 'metodo', v_metodo
      )
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success', true,
    'devolucion_id', v_dev_id,
    'total_devuelto', v_total,
    'total_nuevo', v_total_nuevo,
    'diferencia', v_diff,
    'estado', v_estado,
    'requiere_aprobacion', v_pendiente,
    'monto_efectivo', v_monto_ef,
    'monto_credito', v_monto_cred
  );
end;
$$;

grant execute on function public.crear_devolucion(
  uuid, bigint, text, text, jsonb, text, text, jsonb, boolean, text, text
) to anon, authenticated;

-- ── aprobar / rechazar ───────────────────────────────────────

create or replace function public.aprobar_devolucion(
  p_session_token uuid,
  p_devolucion_id bigint
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_dev public.devoluciones%rowtype;
begin
  v_actor := public.fn_require_admin(p_session_token);
  select * into v_dev from public.devoluciones where id = p_devolucion_id for update;
  if not found then
    raise exception 'Devolución % no encontrada', p_devolucion_id;
  end if;
  if v_dev.estado is distinct from 'pendiente' then
    raise exception 'Sólo se aprueban devoluciones pendientes';
  end if;

  perform public.fn_ejecutar_efectos_devolucion(p_devolucion_id, v_actor);

  update public.devoluciones
     set estado = 'aprobada',
         requiere_aprobacion = false,
         aprobado_por = v_actor,
         aprobado_at = now()
   where id = p_devolucion_id;

  return jsonb_build_object('success', true, 'devolucion_id', p_devolucion_id, 'estado', 'aprobada');
end;
$$;

create or replace function public.rechazar_devolucion(
  p_session_token uuid,
  p_devolucion_id bigint,
  p_motivo text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor bigint;
  v_dev public.devoluciones%rowtype;
begin
  v_actor := public.fn_require_admin(p_session_token);
  select * into v_dev from public.devoluciones where id = p_devolucion_id for update;
  if not found then
    raise exception 'Devolución % no encontrada', p_devolucion_id;
  end if;
  if v_dev.estado is distinct from 'pendiente' then
    raise exception 'Sólo se rechazan devoluciones pendientes';
  end if;

  update public.devoluciones
     set estado = 'rechazada',
         motivo_rechazo = nullif(btrim(coalesce(p_motivo, '')), ''),
         aprobado_por = v_actor,
         aprobado_at = now()
   where id = p_devolucion_id;

  return jsonb_build_object('success', true, 'devolucion_id', p_devolucion_id, 'estado', 'rechazada');
end;
$$;

grant execute on function public.aprobar_devolucion(uuid, bigint) to anon, authenticated;
grant execute on function public.rechazar_devolucion(uuid, bigint, text) to anon, authenticated;

-- ── cobro POS con crédito (misma transacción que la venta) ───

create or replace function public.empleado_cobrar_venta_pos(
  p_session_token uuid,
  p_metodo_pago text,
  p_total numeric,
  p_cart_items jsonb,
  p_cliente_id bigint default null,
  p_tipo text default 'pos',
  p_tipo_entrega text default null,
  p_direccion text default null,
  p_monto_credito numeric default 0
)
returns table(pedido_id bigint, success boolean)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_pedido_id bigint;
  v_ok boolean;
  v_cred numeric;
begin
  v_user_id := public.fn_require_caja_abierta_vendedor(p_session_token);
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

  select t.pedido_id, t.success
    into v_pedido_id, v_ok
    from public.create_sale_transaction_v2(
      v_user_id, p_metodo_pago, p_total, p_cart_items,
      p_cliente_id, p_tipo, p_tipo_entrega, p_direccion
    ) t;

  if not coalesce(v_ok, false) or v_pedido_id is null then
    raise exception 'No se pudo crear la venta';
  end if;

  if v_cred > 0 then
    perform public.fn_mover_credito_cliente(
      p_cliente_id, 'canjeado', v_cred, null, v_pedido_id,
      'Canje en venta #' || v_pedido_id, v_user_id
    );
    update public.pedidos
       set monto_credito = v_cred
     where id = v_pedido_id;
  end if;

  return query select v_pedido_id, true;
end;
$$;

grant execute on function public.empleado_cobrar_venta_pos(
  uuid, text, numeric, jsonb, bigint, text, text, text, numeric
) to anon, authenticated;

-- ── búsqueda de productos para el cambio ─────────────────────

create or replace function public.empleado_buscar_productos_venta(
  p_session_token uuid,
  p_busqueda text,
  p_limite int default 12
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_q text;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_q := trim(coalesce(p_busqueda, ''));
  v_lim := greatest(1, least(coalesce(p_limite, 12), 30));
  if length(v_q) < 2 then
    return '[]'::jsonb;
  end if;
  return coalesce((
    select jsonb_agg(to_jsonb(r) order by r.nombre)
    from (
      select
        p.id,
        p.nombre,
        p.sku,
        p.codigo_barras,
        round(coalesce(p.precio, 0), 0) as precio,
        coalesce(p.stock, 0) as stock
      from public.productos p
      where coalesce(p.activo, true) = true
        and (
          p.nombre ilike '%' || v_q || '%'
          or coalesce(p.sku, '') ilike '%' || v_q || '%'
          or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
             like '%' || regexp_replace(v_q, '\D', '', 'g') || '%'
        )
      order by p.nombre
      limit v_lim
    ) r
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_buscar_productos_venta(uuid, text, int)
  to anon, authenticated;

-- ── clientes POS: incluir saldo_credito ──────────────────────

create or replace function public.empleado_buscar_clientes_pos(
  p_session_token uuid,
  p_busqueda text,
  p_limit int default 12
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
  v_q text;
  v_digits text;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limit, 12), 50));
  v_q := trim(coalesce(p_busqueda, ''));
  if length(v_q) < 2 then
    return '[]'::jsonb;
  end if;
  v_digits := regexp_replace(v_q, '\D', '', 'g');

  if length(v_digits) >= 4 then
    return coalesce((
      select jsonb_agg(to_jsonb(r) order by r.nombre nulls last)
      from (
        select c.id, c.nombre, c.telefono, c.puntos,
               coalesce(c.saldo_credito, 0) as saldo_credito
        from public.clientes c
        where c.telefono ilike '%' || v_digits || '%'
           or c.nombre ilike '%' || v_q || '%'
        order by c.nombre nulls last
        limit v_lim
      ) r
    ), '[]'::jsonb);
  end if;

  return coalesce((
    select jsonb_agg(to_jsonb(r) order by r.nombre nulls last)
    from (
      select c.id, c.nombre, c.telefono, c.puntos,
             coalesce(c.saldo_credito, 0) as saldo_credito
      from public.clientes c
      where c.nombre ilike '%' || v_q || '%'
      order by c.nombre nulls last
      limit v_lim
    ) r
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_buscar_clientes_pos(uuid, text, int)
  to anon, authenticated;

create or replace function public.empleado_sumar_devoluciones_rango(
  p_session_token uuid,
  p_created_desde timestamptz,
  p_created_hasta timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return (
    select jsonb_build_object(
      'total_devuelto', coalesce(sum(total_devuelto) filter (where estado = 'aprobada'), 0),
      'monto_efectivo', coalesce(sum(monto_efectivo) filter (where estado = 'aprobada'), 0),
      'monto_credito', coalesce(sum(monto_credito) filter (where estado = 'aprobada'), 0),
      'n', count(*) filter (where estado = 'aprobada')
    )
    from public.devoluciones
    where created_at >= coalesce(p_created_desde, '-infinity'::timestamptz)
      and created_at <= coalesce(p_created_hasta, 'infinity'::timestamptz)
  );
end;
$$;

grant execute on function public.empleado_sumar_devoluciones_rango(uuid, timestamptz, timestamptz)
  to anon, authenticated;

-- ── corte: restar efectivo de devoluciones ───────────────────

create or replace function public.reconcile_shift_cash(
  p_turno text,
  p_fecha date
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_inicio timestamptz;
  v_fin    timestamptz;

  v_ef_pedidos   numeric := 0;
  v_tar_pedidos  numeric := 0;
  v_mp_pedidos   numeric := 0;
  v_spei_pedidos numeric := 0;

  v_ef_serv   numeric := 0;
  v_tar_serv  numeric := 0;

  v_dev_ef numeric := 0;
  v_dev_in numeric := 0;
  v_dev_tar numeric := 0;
  v_dev_cred numeric := 0;
begin
  if p_turno = 'matutino' then
    v_inicio := (p_fecha + time '00:00:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '15:29:59.999') at time zone 'America/Mexico_City';
  else
    v_inicio := (p_fecha + time '15:30:00')     at time zone 'America/Mexico_City';
    v_fin    := (p_fecha + time '23:59:59.999') at time zone 'America/Mexico_City';
  end if;

  select
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'tarjeta'),  0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago in ('mercadopago','mercadopago_point')), 0),
    coalesce(sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'spei'),     0)
  into v_ef_pedidos, v_tar_pedidos, v_mp_pedidos, v_spei_pedidos
  from public.pedidos
  where estado = 'completado'
    and created_at between v_inicio and v_fin;

  select
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'efectivo'), 0),
    coalesce(sum(total_cobrado) filter (where metodo_pago = 'tarjeta'),  0)
  into v_ef_serv, v_tar_serv
  from public.pagos_servicio
  where created_at between v_inicio and v_fin;

  select
    coalesce(sum(monto_efectivo), 0),
    coalesce(sum(monto_efectivo_ingreso), 0),
    coalesce(sum(monto_tarjeta_ingreso), 0),
    coalesce(sum(monto_credito), 0)
  into v_dev_ef, v_dev_in, v_dev_tar, v_dev_cred
  from public.devoluciones
  where estado = 'aprobada'
    and created_at between v_inicio and v_fin;

  return jsonb_build_object(
    'efectivo_sistema',   v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in,
    'tarjeta',            v_tar_pedidos + v_tar_serv + v_dev_tar,
    'mercadopago',        v_mp_pedidos,
    'spei',               v_spei_pedidos,
    'efectivo_pedidos',   v_ef_pedidos,
    'efectivo_servicios', v_ef_serv,
    'efectivo_devoluciones', v_dev_ef,
    'efectivo_cambios_ingreso', v_dev_in,
    'credito_otorgado',   v_dev_cred,
    'tarjeta_pedidos',    v_tar_pedidos,
    'tarjeta_servicios',  v_tar_serv,
    'tarjeta_cambios',    v_dev_tar,
    'rango_inicio',       v_inicio,
    'rango_fin',          v_fin
  );
end;
$$;

grant execute on function public.reconcile_shift_cash(text, date) to anon, authenticated;

create or replace function public.registrar_corte_caja(
  p_session_token      uuid,
  p_turno              text,
  p_efectivo_declarado numeric,
  p_efectivo_sistema   numeric,
  p_tarjeta            numeric,
  p_mercadopago        numeric,
  p_diferencia         numeric,
  p_total_general      numeric,
  p_spei               numeric default 0,
  p_notas              text default null,
  p_fondo_inicial      numeric default 0,
  p_contado_por        text default null,
  p_denominaciones     jsonb default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id bigint;
  v_nombre   text;
  v_corte_id bigint;
  v_ahora    timestamp;
  v_apertura time;
  v_r        jsonb;
  v_sistema  numeric;
  v_tarjeta  numeric;
  v_mp       numeric;
  v_spei     numeric;
  v_fila     public.cortes_caja%rowtype;
  v_sesion   public.caja_sesiones%rowtype;
  v_fondo    numeric;
  v_turno    text;
  v_decl     numeric;
begin
  v_actor_id := public.fn_require_empleado(p_session_token);
  select nombre into v_nombre from public.usuarios where id = v_actor_id;

  v_ahora := now() at time zone 'America/Mexico_City';

  v_decl := public.fn_sumar_denominaciones(p_denominaciones);
  if v_decl is null or v_decl = 0 then
    v_decl := coalesce(p_efectivo_declarado, 0);
  end if;

  select * into v_sesion
  from public.caja_sesiones
  where empleado_id = v_actor_id and estado = 'abierta'
  limit 1;

  if v_sesion.id is not null then
    v_fondo    := v_sesion.fondo_contado;
    v_turno    := v_sesion.turno;
    v_apertura := (v_sesion.abierta_at at time zone 'America/Mexico_City')::time;
  else
    v_fondo    := coalesce(p_fondo_inicial, 0);
    v_turno    := coalesce(nullif(p_turno, ''), 'matutino');
    v_apertura := case when v_turno = 'matutino' then time '08:00' else time '15:00' end;
  end if;

  v_r       := public.reconcile_shift_cash(v_turno, v_ahora::date);
  v_sistema := coalesce((v_r->>'efectivo_sistema')::numeric, 0);
  v_tarjeta := coalesce((v_r->>'tarjeta')::numeric,          0);
  v_mp      := coalesce((v_r->>'mercadopago')::numeric,      0);
  v_spei    := coalesce((v_r->>'spei')::numeric,             0);

  insert into public.cortes_caja (
    turno, empleado_id, fecha, hora_apertura, hora_cierre,
    efectivo_declarado, efectivo_sistema, fondo_inicial,
    total_tarjeta, total_spei, total_mercadopago,
    contado_por, denominaciones, notas
  ) values (
    v_turno, v_actor_id, v_ahora::date, v_apertura, v_ahora::time,
    v_decl, v_sistema, v_fondo,
    v_tarjeta, v_spei, v_mp,
    nullif(btrim(coalesce(p_contado_por, '')), ''), p_denominaciones, p_notas
  ) returning * into v_fila;

  v_corte_id := v_fila.id;

  if v_sesion.id is not null then
    update public.caja_sesiones
       set estado     = 'cerrada',
           cerrada_at = now(),
           corte_id   = v_corte_id
     where id = v_sesion.id;
  end if;

  begin
    insert into public.audit_log (usuario_id, usuario_nombre, accion, tabla, registro_id, detalle)
    values (
      v_actor_id, v_nombre,
      'corte_caja', 'cortes_caja', v_corte_id::text,
      jsonb_build_object('turno', v_turno, 'diferencia', v_fila.diferencia,
                         'total', v_fila.total_general, 'fondo', v_fila.fondo_inicial,
                         'tarjeta', v_tarjeta, 'mercadopago', v_mp,
                         'desglose', v_r)
    );
  exception when others then null;
  end;

  return jsonb_build_object(
    'success',          true,
    'corte_id',         v_corte_id,
    'efectivo_sistema', v_fila.efectivo_sistema,
    'fondo_inicial',    v_fila.fondo_inicial,
    'esperado',         v_fila.fondo_inicial + v_fila.efectivo_sistema,
    'diferencia',       v_fila.diferencia,
    'total_general',    v_fila.total_general,
    'tarjeta',          v_fila.total_tarjeta,
    'mercadopago',      v_fila.total_mercadopago,
    'spei',             v_fila.total_spei,
    'hora_apertura',    v_fila.hora_apertura,
    'hora_cierre',      v_fila.hora_cierre,
    'turno',            v_turno,
    'detalle_metodos',  jsonb_build_object(
      'efectivo_pedidos',         v_r->'efectivo_pedidos',
      'efectivo_servicios',       v_r->'efectivo_servicios',
      'efectivo_devoluciones',    v_r->'efectivo_devoluciones',
      'efectivo_cambios_ingreso', v_r->'efectivo_cambios_ingreso',
      'credito_otorgado',         v_r->'credito_otorgado',
      'tarjeta_pedidos',          v_r->'tarjeta_pedidos',
      'tarjeta_servicios',        v_r->'tarjeta_servicios',
      'tarjeta_cambios',          v_r->'tarjeta_cambios'
    )
  );
end;
$$;

grant execute on function public.registrar_corte_caja(
  uuid, text, numeric, numeric, numeric, numeric, numeric, numeric,
  numeric, text, numeric, text, jsonb
) to anon, authenticated;

-- ── escanear producto → venta reciente ───────────────────────

create or replace function public.empleado_identificar_producto_codigo(
  p_session_token uuid,
  p_codigo text
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_raw text;
  v_digits text;
  v_row jsonb;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_raw := trim(coalesce(p_codigo, ''));
  v_digits := regexp_replace(v_raw, '\D', '', 'g');
  if length(v_raw) < 2 then
    return 'null'::jsonb;
  end if;

  select to_jsonb(r) into v_row
  from (
    select
      p.id, p.nombre, p.sku, p.codigo_barras,
      round(coalesce(p.precio, 0), 0) as precio,
      coalesce(p.stock, 0) as stock
    from public.productos p
    where coalesce(p.activo, true) = true
      and (
        (length(v_digits) >= 8 and (
          regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = v_digits
          or regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g') = '0' || v_digits
          or v_digits = '0' || regexp_replace(coalesce(p.codigo_barras, ''), '\D', '', 'g')
        ))
        or upper(coalesce(p.sku, '')) = upper(v_raw)
      )
    order by p.id
    limit 1
  ) r;

  return coalesce(v_row, 'null'::jsonb);
end;
$$;

grant execute on function public.empleado_identificar_producto_codigo(uuid, text)
  to anon, authenticated;

create or replace function public.empleado_buscar_venta_reciente_por_producto(
  p_session_token uuid,
  p_producto_id bigint,
  p_dias int default 15
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_dias int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  if p_producto_id is null then
    return '[]'::jsonb;
  end if;
  v_dias := greatest(1, least(coalesce(p_dias, 15), 90));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        to_jsonb(p) ||
        jsonb_build_object(
          'clientes', jsonb_build_object(
            'nombre', coalesce(cl.nombre, p.guest_nombre),
            'telefono', coalesce(cl.telefono, p.guest_telefono)
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select jsonb_agg(
          jsonb_build_object(
            'id', i.id,
            'cantidad', i.cantidad,
            'precio_unitario', i.precio_unitario,
            'lote_id', i.lote_id,
            'productos', jsonb_build_object('id', pr.id, 'nombre', pr.nombre, 'stock', pr.stock)
          )
          order by i.id
        ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where (p.estado)::text = 'completado'
        and p.created_at >= now() - (v_dias || ' days')::interval
        and exists (
          select 1 from public.pedido_items x
          where x.pedido_id = p.id and x.producto_id = p_producto_id
        )
      order by p.created_at desc
      limit 12
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_buscar_venta_reciente_por_producto(uuid, bigint, int)
  to anon, authenticated;

notify pgrst, 'reload schema';

commit;
