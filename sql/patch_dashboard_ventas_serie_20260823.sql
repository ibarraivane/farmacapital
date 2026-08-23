-- Dashboard: ventas por día (CDMX) para la gráfica vs meta.
-- 23-ago-2026. Idempotente. Pegar en Supabase SQL Editor.
-- Sin esto la gráfica usa el listado de transacciones (hasta 800 tickets).

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
      'tickets', d.tickets
    ) order by d.dia)
    from (
      select
        ((p.created_at at time zone 'America/Mexico_City')::date) as dia,
        sum(p.total)::numeric as total,
        count(*)::int as tickets
      from public.pedidos p
      where (p.estado)::text = 'completado'
        and ((p.created_at at time zone 'America/Mexico_City')::date) >= p_desde
      group by 1
    ) d
  ), '[]'::jsonb);
end;
$$;

grant execute on function public.empleado_dashboard_ventas_serie(uuid, date) to anon, authenticated;

commit;
