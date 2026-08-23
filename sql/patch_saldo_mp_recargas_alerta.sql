-- Saldo de recargas como inventario. MP no avisa cuando se acaba:
-- FarmaCapital descuenta cada recarga y el admin define el mínimo.
-- Ejecutar en Supabase SQL Editor. Idempotente.

begin;

insert into public.configuracion (clave, valor)
values
  ('saldo_mp_recargas', ''),
  ('saldo_mp_recargas_minimo', '500')
on conflict (clave) do nothing;

create or replace function public.fn_descontar_saldo_mp_recargas()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.configuracion
  set valor = trim(to_char(
    greatest(0, round(valor::numeric - coalesce(NEW.monto_servicio, 0), 2)),
    'FM9999999990.00'
  ))
  where clave = 'saldo_mp_recargas'
    and valor ~ '^[0-9]+(\.[0-9]+)?$';
  return NEW;
end;
$$;

drop trigger if exists trg_descontar_saldo_mp_recargas on public.pagos_servicio;
create trigger trg_descontar_saldo_mp_recargas
after insert on public.pagos_servicio
for each row
execute function public.fn_descontar_saldo_mp_recargas();

create or replace function public.admin_set_saldo_recargas(
  p_session_token uuid,
  p_saldo         numeric,
  p_minimo        numeric default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_saldo numeric;
  v_min numeric;
begin
  perform public.fn_require_admin(p_session_token);
  v_saldo := round(coalesce(p_saldo, 0)::numeric, 2);
  if v_saldo < 0 then
    raise exception 'Saldo inválido';
  end if;

  insert into public.configuracion (clave, valor)
  values ('saldo_mp_recargas', trim(to_char(v_saldo, 'FM9999999990.00')))
  on conflict (clave) do update set valor = excluded.valor;

  if p_minimo is not null then
    v_min := round(p_minimo::numeric, 2);
    if v_min < 0 then
      raise exception 'Mínimo inválido';
    end if;
    insert into public.configuracion (clave, valor)
    values ('saldo_mp_recargas_minimo', trim(to_char(v_min, 'FM9999999990.00')))
    on conflict (clave) do update set valor = excluded.valor;
  end if;

  return jsonb_build_object('success', true, 'saldo', v_saldo);
end;
$$;

grant execute on function public.admin_set_saldo_recargas(uuid, numeric, numeric)
  to anon, authenticated;

commit;
