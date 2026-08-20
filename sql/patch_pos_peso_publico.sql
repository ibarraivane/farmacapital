-- Cobro de mostrador en pesos enteros (nunca centavos).
-- Pegar en Supabase → SQL Editor ANTES o al mismo tiempo que el deploy del POS.
-- Si el JS ya redondea y esto no está, las ventas con precio .xx van a fallar
-- con "Total mismatch".
--
-- Criterio: peso más cercano. $38.43 → $38. $12.50 → $13.
-- No reescribe el catálogo: la ficha puede seguir con PMP; el ticket cobra entero.
-- No toca tienda web ni pagos de servicio.

create or replace function public.peso_publico(p numeric)
returns numeric
language sql
immutable
parallel safe
as $$
  select case when p is null then 0 else round(p, 0) end;
$$;

grant execute on function public.peso_publico(numeric) to anon, authenticated, service_role;
