-- FarmaCapital — precio de tarjeta = solo 3.49% + IVA.
-- El $4 + IVA es por cobro MP (una vez), no por producto.
-- Reemplaza patch_precio_online_mp_fijo_20260916.sql si ya lo corriste.

create or replace function public.fc_precio_online_mp(p_precio numeric)
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when p_precio is null or p_precio <= 0.01 then null
    else ceil(round(p_precio / (1 - 0.040484), 2))
  end;
$$;

grant execute on function public.fc_precio_online_mp(numeric) to anon, authenticated;

-- select public.fc_precio_online_mp(10);   -- 11
-- select public.fc_precio_online_mp(42);   -- 44
-- select public.fc_precio_online_mp(459);  -- 479
