-- Raquel no puede cerrar la venta: Postgres responde
-- function public.precio_blister_efectivo(numeric, numeric, integer, integer, text, text, numeric) does not exist
-- El cobro de la caja también arma esa llamada, aunque no vendan blister.
--
-- Pegar SOLO esto en Supabase → SQL Editor → Run.
-- No reemplaza create_sale ni mueve stock. Crea la función que ya se está llamando.

begin;

create or replace function public.blisters_por_caja(p_upc integer, p_ppb integer)
returns integer
language sql
immutable
as $$
  select case
    when coalesce(p_ppb, 0) >= 2
     and coalesce(p_upc, 0) >= 2
     and (p_upc % p_ppb) = 0
     and (p_upc / p_ppb) >= 2
    then p_upc / p_ppb
    else 0
  end;
$$;

create or replace function public.precio_blister_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_ppb integer,
  p_categoria text,
  p_tipo text,
  p_precio_blister_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when public.blisters_por_caja(p_upc, p_ppb) < 2 then 0
    when coalesce(p_precio_blister_guardado, 0) > 0
      then ceil(p_precio_blister_guardado)
    else public.calc_precio_unidad_sugerido(
      p_costo,
      p_precio_caja,
      public.blisters_por_caja(p_upc, p_ppb),
      p_categoria,
      p_tipo
    )
  end;
$$;

grant execute on function public.blisters_por_caja(integer, integer)
  to anon, authenticated, service_role;
grant execute on function public.precio_blister_efectivo(numeric, numeric, integer, integer, text, text, numeric)
  to anon, authenticated, service_role;

commit;
