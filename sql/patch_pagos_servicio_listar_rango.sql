-- Listar recargas / pagos de servicio por rango (Dashboard → Transacciones).
-- Idempotente. El POS ya registra en pagos_servicio; este RPC los lee por fechas.

create or replace function public.empleado_listar_pagos_servicio_rango(
  p_session_token uuid,
  p_desde         timestamptz default null,
  p_hasta         timestamptz default null,
  p_limite        integer default 300
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_lim int;
begin
  perform public.fn_require_empleado(p_session_token);
  v_lim := greatest(1, least(coalesce(p_limite, 300), 800));

  return coalesce((
    select jsonb_agg(row_js order by ord desc)
    from (
      select jsonb_build_object(
        'id', ps.id,
        'folio', ps.folio,
        'proveedor', ps.proveedor,
        'categoria', ps.categoria,
        'referencia', ps.referencia,
        'monto_servicio', ps.monto_servicio,
        'comision', ps.comision,
        'total_cobrado', ps.total_cobrado,
        'metodo_pago', ps.metodo_pago,
        'liquidado_point', ps.liquidado_point,
        'notas', ps.notas,
        'created_at', ps.created_at,
        'atendido_por', ps.atendido_por,
        'atendido_por_nombre', u.nombre
      ) as row_js,
      ps.created_at as ord
      from public.pagos_servicio ps
      left join public.usuarios u on u.id = ps.atendido_por
      where (p_desde is null or ps.created_at >= p_desde)
        and (p_hasta is null or ps.created_at <= p_hasta)
      order by ps.created_at desc
      limit v_lim
    ) s
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_listar_pagos_servicio_rango(uuid, timestamptz, timestamptz, integer)
  to anon, authenticated;
