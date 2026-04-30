-- ============================================================
-- FARMAX — P0: RPCs para lecturas tienda web + POS (RLS estricto)
-- ============================================================
-- Ejecutar en Supabase SQL Editor DESPUÉS de:
--   refactor_fase6a_tokens.sql, refactor_fase6b_rpcs_auth.sql
-- (requiere fn_require_empleado, fn_require_cliente, fn_validar_token_*)
--
-- Objetivo: reemplazar .from(pedidos|citas|clientes|lotes|pedido_items|productos)
-- en pedidosTiendaWeb.js, POS.jsx y Tienda.jsx.
-- ============================================================

begin;

-- ── Públicos (anon): solo agregados mínimos para agenda checkout ───────────

create or replace function public.public_listar_horas_ocupadas_citas(p_fecha date)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    jsonb_agg(jsonb_build_object('hora', t.hora) order by t.hora),
    '[]'::jsonb
  )
  from (
    select distinct c.hora
    from public.citas c
    where c.fecha = p_fecha
      and coalesce(c.estado, '') <> 'cancelada'
  ) t;
$$;

comment on function public.public_listar_horas_ocupadas_citas(date) is
  'P0: horas ya ocupadas en una fecha (solo texto hora; sin datos clínicos).';


create or replace function public.public_cita_horario_ocupado(p_fecha date, p_hora text)
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select jsonb_build_object(
    'ocupado',
    exists (
      select 1
      from public.citas c
      where c.fecha = p_fecha
        and c.hora = trim(p_hora)
        and coalesce(c.estado, '') <> 'cancelada'
    )
  );
$$;


create or replace function public.tienda_public_lotes_resumen_checkout(p_producto_ids bigint[])
returns jsonb
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'producto_id', l.producto_id,
        'cantidad_actual', l.cantidad_actual,
        'activo', l.activo
      )
      order by l.producto_id, l.id
    ),
    '[]'::jsonb
  )
  from public.lotes l
  where l.producto_id = any (coalesce(p_producto_ids, array[]::bigint[]))
    and coalesce(l.activo, true) is not false;
$$;


-- ── Cliente autenticado (token sesión tienda) ───────────────────────────────

create or replace function public.cliente_listar_mis_pedidos(
  p_session_token uuid,
  p_limite int default 120
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli bigint;
begin
  v_cli := public.fn_require_cliente(p_session_token);
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'estado', p.estado,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'created_at', p.created_at,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_provider', p.delivery_provider,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object('nombre', pr.nombre)
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.cliente_id = v_cli
      order by p.created_at desc
      limit greatest(1, least(coalesce(p_limite, 120), 500))
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.cliente_listar_mis_citas(
  p_session_token uuid,
  p_limite int default 200
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cli bigint;
begin
  v_cli := public.fn_require_cliente(p_session_token);
  return coalesce((
    select jsonb_agg(to_jsonb(t) order by t.fecha desc, t.hora desc nulls last)
    from (
      select *
      from public.citas
      where cliente_id = v_cli
      order by fecha desc, hora desc nulls last
      limit greatest(1, least(coalesce(p_limite, 200), 500))
    ) t
  ), '[]'::jsonb);
end;
$$;


-- ── Empleado autenticado (panel Farmax) ─────────────────────────────────────

create or replace function public.empleado_contar_pedidos_tienda_web_pendientes(p_session_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_cnt bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::bigint into v_cnt
  from public.pedidos p
  where p.estado = 'pendiente'
    and (
      p.tipo = 'online'
      or (
        p.tipo is null
        and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
      )
    );
  return coalesce(v_cnt, 0);
end;
$$;


create or replace function public.empleado_listar_pedidos_tienda_web_pendientes(
  p_session_token uuid,
  p_limit int default 300
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limit, 300), 500));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'payment_provider', p.payment_provider,
          'payment_status', p.payment_status,
          'payment_id', p.payment_id,
          'paid_at', p.paid_at,
          'delivery_provider', p.delivery_provider,
          'delivery_status', p.delivery_status,
          'delivery_tracking_url', p.delivery_tracking_url,
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'ubicacion_texto', pr.ubicacion_texto
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.estado = 'pendiente'
        and (
          p.tipo = 'online'
          or (
            p.tipo is null
            and lower(trim(coalesce(p.metodo_pago, ''))) = any (array['tarjeta','mercadopago'])
          )
        )
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_pedidos_online_historial(
  p_session_token uuid,
  p_limite int default 40
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_lim int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 40), 200));
  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'id', p.id,
          'total', p.total,
          'created_at', p.created_at,
          'tipo', p.tipo,
          'metodo_pago', p.metodo_pago,
          'estado', p.estado,
          'tipo_entrega', p.tipo_entrega,
          'direccion', p.direccion,
          'clientes', jsonb_build_object(
            'nombre', cl.nombre,
            'telefono', cl.telefono
          ),
          'pedido_items', coalesce(pi.js, '[]'::jsonb)
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.clientes cl on cl.id = p.cliente_id
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'cantidad', i.cantidad,
              'precio_unitario', i.precio_unitario,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'ubicacion_texto', pr.ubicacion_texto
              )
            )
            order by i.id
          ) as js
        from public.pedido_items i
        join public.productos pr on pr.id = i.producto_id
        where i.pedido_id = p.id
      ) pi on true
      where p.tipo = 'online'
        and (p.estado)::text = any (array['listo','completado'])
      order by p.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;


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
        select c.id, c.nombre, c.telefono, c.puntos
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
      select c.id, c.nombre, c.telefono, c.puntos
      from public.clientes c
      where c.nombre ilike '%' || v_q || '%'
      order by c.nombre nulls last
      limit v_lim
    ) r
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_citas_ventana_pos(
  p_session_token uuid,
  p_desde date,
  p_hasta date
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
  return coalesce((
    select jsonb_agg(row_js order by fecha_ord, hora_ord nulls last)
    from (
      select
        jsonb_build_object(
          'id', c.id,
          'nombre', c.nombre,
          'telefono', c.telefono,
          'hora', c.hora,
          'fecha', c.fecha,
          'motivo', c.motivo,
          'estado', c.estado,
          'canal', c.canal,
          'pago_estado', c.pago_estado,
          'pedido_consulta_id', c.pedido_consulta_id,
          'precio_consulta_cobrado', c.precio_consulta_cobrado,
          'ingreso_doctor', c.ingreso_doctor,
          'ingreso_farmacia', c.ingreso_farmacia,
          'consumibles_consulta', coalesce(cc.js, '[]'::jsonb)
        ) as row_js,
        c.fecha as fecha_ord,
        c.hora as hora_ord
      from public.citas c
      left join lateral (
        select
          jsonb_agg(
            jsonb_build_object(
              'id', x.id,
              'cantidad', x.cantidad,
              'precio', x.precio,
              'cobrado', x.cobrado,
              'nombre', x.nombre,
              'producto_id', x.producto_id
            )
            order by x.id
          ) as js
        from public.consumibles_consulta x
        where x.cita_id = c.id
      ) cc on true
      where c.fecha >= p_desde
        and c.fecha <= p_hasta
        and coalesce(c.estado, '') <> 'cancelada'
    ) q
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_listar_productos_con_lotes_pos(p_session_token uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  return coalesce((
    select jsonb_agg((to_jsonb(pr) || jsonb_build_object('lotes', lt.js)) order by pr.nombre nulls last)
    from public.productos pr
    left join lateral (
      select
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'fecha_caducidad', l.fecha_caducidad,
              'cantidad_actual', l.cantidad_actual,
              'activo', l.activo
            )
            order by l.id
          ),
          '[]'::jsonb
        ) as js
      from public.lotes l
      where l.producto_id = pr.id
    ) lt on true
    where coalesce(pr.activo, true) is true
  ), '[]'::jsonb);
end;
$$;


create or replace function public.empleado_obtener_pedido_items_ticket(
  p_session_token uuid,
  p_pedido_id bigint
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
  if p_pedido_id is null then
    return '[]'::jsonb;
  end if;
  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'producto_id', i.producto_id,
        'cantidad', i.cantidad,
        'precio_unitario', i.precio_unitario,
        'lote_id', i.lote_id,
        'productos', jsonb_build_object(
          'nombre', pr.nombre,
          'sku', pr.sku
        ),
        'lotes', jsonb_build_object(
          'numero_lote', lo.numero_lote,
          'fecha_caducidad', lo.fecha_caducidad
        )
      )
      order by i.id
    )
    from public.pedido_items i
    join public.productos pr on pr.id = i.producto_id
    left join public.lotes lo on lo.id = i.lote_id
    where i.pedido_id = p_pedido_id
  ), '[]'::jsonb);
end;
$$;


-- Grants (mismo patrón que F6b: cliente anon + authenticated)

grant execute on function public.public_listar_horas_ocupadas_citas(date) to anon, authenticated;
grant execute on function public.public_cita_horario_ocupado(date, text) to anon, authenticated;
grant execute on function public.tienda_public_lotes_resumen_checkout(bigint[]) to anon, authenticated;

grant execute on function public.cliente_listar_mis_pedidos(uuid, int) to anon, authenticated;
grant execute on function public.cliente_listar_mis_citas(uuid, int) to anon, authenticated;

grant execute on function public.empleado_contar_pedidos_tienda_web_pendientes(uuid) to anon, authenticated;
grant execute on function public.empleado_listar_pedidos_tienda_web_pendientes(uuid, int) to anon, authenticated;
grant execute on function public.empleado_listar_pedidos_online_historial(uuid, int) to anon, authenticated;
grant execute on function public.empleado_buscar_clientes_pos(uuid, text, int) to anon, authenticated;
grant execute on function public.empleado_listar_citas_ventana_pos(uuid, date, date) to anon, authenticated;
grant execute on function public.empleado_listar_productos_con_lotes_pos(uuid) to anon, authenticated;
grant execute on function public.empleado_obtener_pedido_items_ticket(uuid, bigint) to anon, authenticated;

commit;
