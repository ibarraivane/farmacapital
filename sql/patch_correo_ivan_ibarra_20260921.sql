-- FarmaCapital — 2026-09-21
-- Correo de Ivan Ibarra (pedido #441, tel. 55 3727 5035) para el aviso de envío.
-- Pegar en Supabase → SQL Editor → Run.

begin;

do $$
declare
  v_id bigint;
  v_n int;
begin
  select count(*) into v_n
  from public.clientes
  where right(regexp_replace(coalesce(telefono, ''), '\D', '', 'g'), 10) = '5537275035'
    and lower(nombre) like '%ivan%'
    and lower(nombre) like '%ibarra%';

  if v_n = 0 then
    raise exception 'No encontré a Ivan Ibarra con teléfono 5537275035';
  end if;
  if v_n > 1 then
    raise exception 'Hay % fichas de Ivan Ibarra con ese teléfono; no actualicé ninguna', v_n;
  end if;

  update public.clientes
  set email = 'ibarra.ivan@outlook.com'
  where right(regexp_replace(coalesce(telefono, ''), '\D', '', 'g'), 10) = '5537275035'
    and lower(nombre) like '%ivan%'
    and lower(nombre) like '%ibarra%'
  returning id into v_id;

  update public.pedidos
  set guest_email = 'ibarra.ivan@outlook.com'
  where cliente_id = v_id
    and lower(coalesce(tipo_entrega, '')) = 'envio'
    and lower(coalesce(payment_status, '')) is distinct from 'approved'
    and coalesce(guest_email, '') not like '%@%';

  raise notice 'Correo ibarra.ivan@outlook.com en cliente %', v_id;
end $$;

commit;
