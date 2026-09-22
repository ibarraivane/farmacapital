-- FarmaCapital — 2026-09-21
-- Segundo correo del cliente (p. ej. Hotmail además del Gmail de Google).
-- Los avisos de envío y pago salen a email y a email_alt.
-- Pegar en Supabase → SQL Editor → Run.

begin;

alter table public.clientes
  add column if not exists email_alt text;

comment on column public.clientes.email_alt is
  'Correo adicional para avisos (además de email). No sustituye el de Google/OAuth.';

commit;
