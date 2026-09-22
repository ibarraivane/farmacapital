-- FarmaCapital — 2026-09-21
-- Alejandro Escalante: deja el Gmail en email y pone Hotmail en email_alt.
-- Requiere haber corrido patch_clientes_email_alt_20260921.sql antes.
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

  -- No tocar email (Gmail de Google). Solo el segundo correo.
  update public.clientes
  set email_alt = 'a_escalante_barreto@hotmail.com'
  where id = any (v_ids);

  raise notice 'email_alt Hotmail en % ficha(s) de Alejandro Escalante: %', v_n, v_ids;
end $$;

commit;
