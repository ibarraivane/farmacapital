-- Precio de venta · denominación mínima 0.5 centavos ($0.005) · 28-sep-2026
--
-- productos.precio era numeric(12,2) y no puede guardar $0.005.
-- En inventario el precio de venta se ajusta a múltiplos de 0.005.
-- El POS sigue cobrando a peso entero (peso_publico). Este parche no toca esa función
-- ni admin_editar_producto: ese RPC ya castea precio a numeric sin escala.
--
-- Pegar en Supabase → SQL Editor → Run. Idempotente.

begin;

do $$
declare
  v_scale integer;
begin
  select c.numeric_scale
    into v_scale
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'productos'
    and c.column_name = 'precio';

  if v_scale is distinct from 3 then
    execute $sql$
      alter table public.productos
        alter column precio type numeric(12,3)
        using precio::numeric(12,3)
    $sql$;
  end if;
end $$;

comment on column public.productos.precio is
  'Precio de venta. Denominación mínima: 0.5 centavos ($0.005 MXN).';

commit;
