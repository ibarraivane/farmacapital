-- Sin Servicio $5 al cliente.
-- fc_cargo_plataforma_online() pasa a 0. Los pedidos nuevos online no suman el cargo.
-- Pedidos online aún sin pagar: se quita el $5 del total y de logistics_meta.
-- Pegar en Supabase → SQL Editor → Run.
-- Los pedidos ya pagados (payment_status = approved) no se tocan.

begin;

create or replace function public.fc_cargo_plataforma_online()
returns numeric
language sql
immutable
as $$
  select 0::numeric;
$$;

grant execute on function public.fc_cargo_plataforma_online() to anon, authenticated;

create or replace function public.fc_pedidos_sumar_cargo_plataforma()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
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

  -- Ya no se cobra Servicio: dejar 0 en la meta para que el desglose no invente $5.
  new.logistics_meta := coalesce(new.logistics_meta, '{}'::jsonb) || jsonb_build_object(
    'cargo_plataforma_mxn', 0,
    'cargo_plataforma_concepto', 'Servicio'
  );
  return new;
end;
$$;

-- Quitar el cargo de pedidos online todavía no pagados.
update public.pedidos p
set
  total = round(coalesce(p.total, 0) - coalesce((p.logistics_meta ->> 'cargo_plataforma_mxn')::numeric, 0), 2),
  logistics_meta = coalesce(p.logistics_meta, '{}'::jsonb) || jsonb_build_object(
    'cargo_plataforma_mxn', 0,
    'cargo_plataforma_concepto', 'Servicio'
  )
where p.tipo = 'online'
  and lower(coalesce(p.payment_status, '')) is distinct from 'approved'
  and coalesce((p.logistics_meta ->> 'cargo_plataforma_mxn')::numeric, 0) > 0;

commit;

-- Comprobar: debe dar 0
-- select public.fc_cargo_plataforma_online() as servicio;
