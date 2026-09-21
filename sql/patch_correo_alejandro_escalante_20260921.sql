-- FarmaCapital — 2026-09-21
-- Correo de Alejandro Escalante para avisos de pedido / envío.
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_id bigint;
  v_n int;
begin
  select count(*) into v_n
  from public.clientes
  where lower(nombre) like '%alejandro%'
    and lower(nombre) like '%escalante%';

  if v_n = 0 then
    raise exception 'No encontré a Alejandro Escalante en clientes';
  end if;
  if v_n > 1 then
    raise exception 'Hay % fichas de Alejandro Escalante; no actualicé ninguna', v_n;
  end if;

  update public.clientes
  set email = 'a_escalante_barreto@hotmail.com'
  where lower(nombre) like '%alejandro%'
    and lower(nombre) like '%escalante%'
  returning id into v_id;

  update public.pedidos
  set guest_email = 'a_escalante_barreto@hotmail.com'
  where cliente_id = v_id
    and lower(coalesce(tipo_entrega, '')) = 'envio'
    and lower(coalesce(payment_status, '')) is distinct from 'approved'
    and coalesce(guest_email, '') not like '%@%';

  raise notice 'Correo a_escalante_barreto@hotmail.com en cliente %', v_id;
end $$;

commit;
