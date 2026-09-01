-- Proyecto: ventas acumuladas del POS para recuperación / payback.
-- 01-sep-2026. Idempotente. Pegar en Supabase SQL Editor.
--
-- Antes el bundle armaba ped_todos = jsonb_agg(total) de TODOS los tickets
-- completados. Con volumen eso hincha o tumba el RPC y la pestaña Proyecto
-- quedaba en $0 / "Calculando…" aunque Operación sí tuviera ventas.
--
-- Este parche:
-- 1) RPC liviano con SUM(total) de pedidos completados.
-- 2) Reemplaza ped_todos por un arreglo de un solo elemento {total: SUM}
--    (compat con clientes viejos que hacen reduce) y agrega ventas_acumuladas.

begin;

create or replace function public.empleado_dashboard_ventas_acumuladas(
  p_session_token uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_ventas numeric;
  v_tickets int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);

  select
    coalesce(sum(p.total), 0)::numeric,
    count(*)::int
  into v_ventas, v_tickets
  from public.pedidos p
  where (p.estado)::text = 'completado';

  return jsonb_build_object(
    'ventas_acumuladas', v_ventas,
    'tickets', v_tickets
  );
end;
$$;

grant execute on function public.empleado_dashboard_ventas_acumuladas(uuid) to anon, authenticated;

-- Opcional: vuelve a aplicar sql/patch_dashboard_bundle_farmacapital.sql
-- (o el def del bundle en rpc_p1_lecturas_admin.sql) para que ped_todos
-- deje de ser jsonb_agg de todos los tickets y el bundle traiga ventas_acumuladas.

commit;
