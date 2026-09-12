-- ============================================================
-- Mi Día / RRHH: recargas y pagos de servicio (CFE, Sky…)
-- cuentan en la meta de cada vendedora. 12-sep-2026. Idempotente.
--
-- Todas las filas de pagos_servicio. Monto = total_cobrado.
-- Pegar en el SQL Editor de Supabase.
-- ============================================================

begin;

create or replace function public.empleado_midia_snapshot(
  p_session_token uuid,
  p_empleado_id bigint,
  p_turno_start timestamptz,
  p_turno_end timestamptz,
  p_mes_start timestamptz,
  p_fecha_citas date
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
  return jsonb_build_object(
    'ped_turno', coalesce((
      select jsonb_agg(row_js order by ord)
      from (
        select
          jsonb_build_object(
            'id', p.id,
            'total', p.total,
            'cliente_id', p.cliente_id,
            'created_at', p.created_at,
            'pedido_items', coalesce(pi.js, '[]'::jsonb)
          ) as row_js,
          p.created_at as ord
        from public.pedidos p
        left join lateral (
          select jsonb_agg(
            jsonb_build_object(
              'cantidad', x.cantidad,
              'productos', jsonb_build_object(
                'nombre', pr.nombre,
                'sku', pr.sku,
                'categoria', pr.categoria
              ),
              'lotes', jsonb_build_object(
                'numero_lote', lo.numero_lote
              )
            )
            order by x.id
          ) as js
          from public.pedido_items x
          join public.productos pr on pr.id = x.producto_id
          left join public.lotes lo on lo.id = x.lote_id
          where x.pedido_id = p.id
        ) pi on true
        where p.atendido_por = p_empleado_id
          and (p.estado)::text = 'completado'
          and p.created_at >= p_turno_start
          and p.created_at <= p_turno_end
      ) q
    ), '[]'::jsonb),
    'ped_mes', coalesce((
      select jsonb_agg(jsonb_build_object('id', p.id, 'total', p.total, 'created_at', p.created_at) order by p.created_at)
      from public.pedidos p
      where p.atendido_por = p_empleado_id
        and (p.estado)::text = 'completado'
        and p.created_at >= p_mes_start
    ), '[]'::jsonb),
    -- Pagos de servicio del turno (recargas + recibos) para % de meta y lista.
    'srv_turno', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', ps.id,
          'total_cobrado', ps.total_cobrado,
          'monto_servicio', ps.monto_servicio,
          'categoria', ps.categoria,
          'proveedor', ps.proveedor,
          'folio', ps.folio,
          'created_at', ps.created_at
        )
        order by ps.created_at
      )
      from public.pagos_servicio ps
      where ps.atendido_por = p_empleado_id
        and ps.created_at >= p_turno_start
        and ps.created_at <= p_turno_end
    ), '[]'::jsonb),
    'srv_mes', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', ps.id,
          'total_cobrado', ps.total_cobrado,
          'monto_servicio', ps.monto_servicio,
          'categoria', ps.categoria,
          'proveedor', ps.proveedor,
          'folio', ps.folio,
          'created_at', ps.created_at
        )
        order by ps.created_at
      )
      from public.pagos_servicio ps
      where ps.atendido_por = p_empleado_id
        and ps.created_at >= p_mes_start
    ), '[]'::jsonb),
    'citas_espera', (
      select count(*)::int
      from public.citas c
      where c.fecha = p_fecha_citas
        and (c.estado)::text = 'confirmada'
    )
  );
end;
$$;

grant execute on function public.empleado_midia_snapshot(uuid, bigint, timestamptz, timestamptz, timestamptz, date) to anon, authenticated;

-- Comisiones RRHH: pedidos + todos los pagos de servicio (total = total_cobrado).
create or replace function public.empleado_rrhh_comisiones_pedidos(
  p_session_token uuid,
  p_desde timestamptz
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
    select jsonb_agg(row_js order by ord desc)
    from (
      select
        jsonb_build_object(
          'total', p.total,
          'atendido_por', p.atendido_por,
          'usuarios', jsonb_build_object('nombre', u.nombre),
          'fuente', 'pedido',
          'created_at', p.created_at
        ) as row_js,
        p.created_at as ord
      from public.pedidos p
      left join public.usuarios u on u.id = p.atendido_por
      where (p.estado)::text = 'completado'
        and p.created_at >= p_desde

      union all

      select
        jsonb_build_object(
          'total', ps.total_cobrado,
          'atendido_por', ps.atendido_por,
          'usuarios', jsonb_build_object('nombre', u2.nombre),
          'fuente', 'servicio',
          'created_at', ps.created_at
        ) as row_js,
        ps.created_at as ord
      from public.pagos_servicio ps
      left join public.usuarios u2 on u2.id = ps.atendido_por
      where ps.created_at >= p_desde
    ) q
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_rrhh_comisiones_pedidos(uuid, timestamptz) to anon, authenticated;

commit;
