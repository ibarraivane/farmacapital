-- Servicio $5 (peso entero) una vez por pedido en línea.
-- Tarjeta web sigue en solo %: Skittles $10 → $11. Total 1 bolsa = $16.
-- Reemplaza el cargo de $4.64. Pegar en Supabase → SQL Editor → Run.

begin;

create or replace function public.fc_cargo_plataforma_online()
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select 5::numeric;
$$;

grant execute on function public.fc_cargo_plataforma_online() to anon, authenticated;

create or replace function public.fc_pedidos_sumar_cargo_plataforma()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_cargo numeric := public.fc_cargo_plataforma_online();
begin
  if tg_op <> 'INSERT' then
    return new;
  end if;
  if lower(trim(coalesce(new.tipo, ''))) is distinct from 'online' then
    return new;
  end if;
  if new.logistics_meta ? 'cargo_plataforma_mxn' then
    return new;
  end if;
  new.total := round(coalesce(new.total, 0) + v_cargo, 0);
  new.logistics_meta := coalesce(new.logistics_meta, '{}'::jsonb) || jsonb_build_object(
    'cargo_plataforma_mxn', v_cargo,
    'cargo_plataforma_concepto', 'Servicio'
  );
  return new;
end;
$$;

select public.fc_precio_online_mp(10) as skittles;   -- 11
select public.fc_cargo_plataforma_online() as servicio; -- 5

commit;
