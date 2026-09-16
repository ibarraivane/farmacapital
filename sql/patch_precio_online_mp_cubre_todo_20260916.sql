-- Precio web = ancla + 3.49% + $4 + IVA (16% sobre la comisión).
-- Skittles $10 → $16. Aspirina $42 → $49. El POS (productos.precio) no cambia.
-- El checkout solo suma esas tarjetas; no se cobra el $4 otra vez.
-- Pegar en Supabase → SQL Editor → Run. Sin esto el servidor sigue cobrando $11.

begin;

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

select public.fc_precio_online_mp(10) as skittles;   -- 16
select public.fc_precio_online_mp(42) as aspirina;   -- 49
select public.fc_precio_online_mp(459) as anthelios; -- 484
select public.fc_precio_online_mp(0.01) as placeholder; -- null

commit;
