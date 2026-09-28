-- Precio por pieza suelta: $0.50 es la mínima denominación.
-- $1.50 se queda en $1.50. Antes, precio_unidad_efectivo hacía ceil
-- y peso_publico lo llevaba al peso entero ($1.50 → $2).
--
-- Pegar en Supabase → SQL Editor. No reescribe el catálogo.
-- La caja sigue su cobro (precio_caja_cobro_pos). Este peso_publico
-- solo mueve unidad, blister y el PVP de caja cuando no hay precio especial.

create or replace function public.peso_publico(p numeric)
returns numeric
language sql
immutable
parallel safe
as $$
  select case
    when p is null or p <= 0 then 0
    else round(p * 2) / 2
  end;
$$;

grant execute on function public.peso_publico(numeric) to anon, authenticated, service_role;

create or replace function public.precio_unidad_efectivo(
  p_costo numeric,
  p_precio_caja numeric,
  p_upc integer,
  p_categoria text,
  p_tipo text,
  p_precio_unidad_guardado numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when coalesce(p_precio_unidad_guardado, 0) > 0
      then round(p_precio_unidad_guardado * 2) / 2
    else public.calc_precio_unidad_sugerido(
      p_costo, p_precio_caja, p_upc, p_categoria, p_tipo
    )
  end;
$$;

grant execute on function public.precio_unidad_efectivo(numeric, numeric, integer, text, text, numeric)
  to anon, authenticated, service_role;
