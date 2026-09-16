-- Tarjeta web = solo 3.49% + IVA. Skittles $10 → $11.
-- $4 + IVA = $4.64 una vez por pedido en línea (no es un SKU).
-- Concepto: Pedido en línea FarmaCapital. Se suma al total en el INSERT.
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

create or replace function public.fc_cargo_plataforma_online()
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select 4.64;
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
  new.total := round(coalesce(new.total, 0) + v_cargo, 2);
  new.logistics_meta := coalesce(new.logistics_meta, '{}'::jsonb) || jsonb_build_object(
    'cargo_plataforma_mxn', v_cargo,
    'cargo_plataforma_concepto', 'Pedido en línea FarmaCapital'
  );
  return new;
end;
$$;

drop trigger if exists trg_pedidos_cargo_plataforma on public.pedidos;
create trigger trg_pedidos_cargo_plataforma
before insert on public.pedidos
for each row
execute procedure public.fc_pedidos_sumar_cargo_plataforma();

select public.fc_precio_online_mp(10) as skittles;          -- 11
select public.fc_cargo_plataforma_online() as cargo;        -- 4.64

commit;
