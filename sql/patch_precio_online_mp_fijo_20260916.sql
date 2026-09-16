-- Reemplazado por sql/patch_precio_online_mp_cubre_todo_20260916.sql
-- (misma fórmula). Corre ese.

create or replace function public.fc_precio_online_mp(p_precio numeric)
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when p_precio is null or p_precio <= 0.01 then null
    else ceil(round((p_precio + 4 * 1.16) / (1 - 0.040484), 2))
  end;
$$;

grant execute on function public.fc_precio_online_mp(numeric) to anon, authenticated;

-- select public.fc_precio_online_mp(10);   -- 16  Skittles
-- select public.fc_precio_online_mp(42);   -- 49  Aspirina
-- select public.fc_precio_online_mp(459);  -- 484 Anthelios
-- select public.fc_precio_online_mp(25);   -- 31  Paracetamol
-- select public.fc_precio_online_mp(0.01); -- null
