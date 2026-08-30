-- Dashboard: ventas por día civil CDMX, netas (tickets − devoluciones del mismo día).
-- 30-ago-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Sin esto la gráfica / KPIs usan solo pedidos.total (bruto) y, si falta el RPC
-- anterior, el listado de transacciones (tope 800 tickets) recorta el mes.

begin;

create or replace function public.empleado_dashboard_ventas_serie(
  p_session_token uuid,
  p_desde date
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
  if p_desde is null then
    raise exception 'p_desde requerido';
  end if;

  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'dia', d.dia,
      'total', d.total,
      'tickets', d.tickets,
      'devoluciones', d.devoluciones
    ) order by d.dia)
    from (
      select
        coalesce(v.dia, dv.dia) as dia,
        coalesce(v.total, 0)::numeric as total,
        coalesce(v.tickets, 0)::int as tickets,
        coalesce(dv.devoluciones, 0)::numeric as devoluciones
      from (
        select
          ((p.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(p.total)::numeric as total,
          count(*)::int as tickets
        from public.pedidos p
        where (p.estado)::text = 'completado'
          and ((p.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) v
      full outer join (
        select
          ((d.created_at at time zone 'America/Mexico_City')::date) as dia,
          sum(d.total_devuelto)::numeric as devoluciones
        from public.devoluciones d
        where (d.estado)::text = 'aprobada'
          and ((d.created_at at time zone 'America/Mexico_City')::date) >= p_desde
        group by 1
      ) dv on dv.dia = v.dia
    ) d
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_dashboard_ventas_serie(uuid, date) to anon, authenticated;

commit;
