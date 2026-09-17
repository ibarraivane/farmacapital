-- Pick-up en farmacia: no sumar Servicio $5 al total.
-- El cargo sigue aplicando a pedidos online con envío (tipo_entrega = envio).
-- Pegar en Supabase → SQL Editor → Run.

begin;

create or replace function public.fc_pedidos_sumar_cargo_plataforma()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
declare
  v_cargo numeric := public.fc_cargo_plataforma_online();
  v_entrega text := lower(trim(coalesce(new.tipo_entrega, '')));
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

  -- Recoger en tienda: sin cargo (UI «Gratis · Mismo día»).
  if v_entrega in ('recoger', 'pickup', 'pickup_store', 'web_pickup') then
    new.logistics_meta := coalesce(new.logistics_meta, '{}'::jsonb) || jsonb_build_object(
      'cargo_plataforma_mxn', 0,
      'cargo_plataforma_concepto', 'Servicio'
    );
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

commit;
