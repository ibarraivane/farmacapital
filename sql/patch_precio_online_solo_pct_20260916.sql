-- La web muestra Skittles $11 (solo 3.49%+IVA). Este SQL alinea el cobro.
-- Si no lo corres, el servidor sigue en $16 por bolsa + Servicio $5.
-- Pegar en Supabase → SQL Editor → Run.

begin;

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

select public.fc_precio_online_mp(10) as skittles;  -- debe ser 11
select public.fc_precio_online_mp(42) as aspirina;  -- debe ser 44
select public.fc_cargo_plataforma_online() as servicio; -- 5

commit;
