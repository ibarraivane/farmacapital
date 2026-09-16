-- Servicio $5 solo en envío a domicilio.
-- Pick-up / recoger: se aparta el producto y se paga en la terminal BBVA;
-- no se suma Servicio (ahorran cotizar envío).
--
-- Tarjeta web sigue en solo %: Skittles $10 → $11.
--   · pick-up: total $11
--   · domicilio: $11 + Servicio $5 = $16
--
-- Pegar en Supabase → SQL Editor → Run.
-- Si fc_precio_online_mp(10) sigue en 16, corre también
-- sql/patch_precio_online_solo_pct_20260916.sql.

begin;

create or replace function public.fc_cargo_plataforma_online()
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select 5::numeric;
$$;

create or replace function public.fc_cargo_plataforma_online(p_tipo_entrega text)
returns numeric
language sql
immutable
set search_path = public, pg_temp
as $$
  select case
    when lower(trim(coalesce(p_tipo_entrega, ''))) in ('envio', 'cdmx', 'foraneo')
      then 5::numeric
    else 0::numeric
  end;
$$;

grant execute on function public.fc_cargo_plataforma_online() to anon, authenticated;
grant execute on function public.fc_cargo_plataforma_online(text) to anon, authenticated;

create or replace function public.fc_pedidos_sumar_cargo_plataforma()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_entrega text := lower(trim(coalesce(new.tipo_entrega, '')));
  v_cargo numeric;
begin
  if tg_op <> 'INSERT' then
    return new;
  end if;
  if lower(trim(coalesce(new.tipo, ''))) is distinct from 'online' then
    return new;
  end if;
  -- Solo domicilio. Pick-up / recoger no lleva Servicio.
  if v_entrega is distinct from 'envio' then
    return new;
  end if;
  if new.logistics_meta ? 'cargo_plataforma_mxn' then
    return new;
  end if;
  v_cargo := public.fc_cargo_plataforma_online();
  if v_cargo <= 0 then
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

select public.fc_precio_online_mp(10) as skittles;                 -- 11
select public.fc_cargo_plataforma_online() as servicio_monto;     -- 5
select public.fc_cargo_plataforma_online('envio') as domicilio;   -- 5
select public.fc_cargo_plataforma_online('recoger') as pickup;    -- 0

commit;
