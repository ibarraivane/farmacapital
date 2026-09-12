-- ============================================================
-- Mi Día: metodo_pago (y datos de servicio) para reimprimir ticket
-- 12-sep-2026. Idempotente. Pegar en Supabase SQL Editor.
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
            'metodo_pago', p.metodo_pago,
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
          'metodo_pago', ps.metodo_pago,
          'comision', ps.comision,
          'referencia', ps.referencia,
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

commit;
