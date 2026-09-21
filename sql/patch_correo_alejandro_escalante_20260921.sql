-- FarmaCapital — 2026-09-21
-- Correo de Alejandro Escalante (hay 2 fichas con ese nombre).
-- Antes: SELECT id, nombre, telefono, email, created_at FROM public.clientes
--   WHERE lower(nombre) like '%alejandro%' AND lower(nombre) like '%escalante%';
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_n int;
  v_ids bigint[];
begin
  select count(*), coalesce(array_agg(id order by id), '{}')
  into v_n, v_ids
  from public.clientes
  where lower(nombre) like '%alejandro%'
    and lower(nombre) like '%escalante%';

  if v_n = 0 then
    raise exception 'No encontré a Alejandro Escalante en clientes';
  end if;

  update public.clientes
  set email = 'a_escalante_barreto@hotmail.com'
  where id = any (v_ids);

  update public.pedidos
  set guest_email = 'a_escalante_barreto@hotmail.com'
  where cliente_id = any (v_ids)
    and lower(coalesce(tipo_entrega, '')) = 'envio'
    and lower(coalesce(payment_status, '')) is distinct from 'approved'
    and coalesce(guest_email, '') not like '%@%';

  raise notice 'Correo a_escalante_barreto@hotmail.com en % ficha(s): %', v_n, v_ids;
end $$;

commit;
