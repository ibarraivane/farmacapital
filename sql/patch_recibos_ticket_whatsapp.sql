-- FarmaCapital — Token público para ticket digital (/r/{token}) + WhatsApp
-- Ejecutar en Supabase SQL Editor.

begin;

alter table public.pedidos
  add column if not exists recibo_token uuid;

alter table public.pedidos
  add column if not exists recibo_generado_at timestamptz;

create unique index if not exists pedidos_recibo_token_uidx
  on public.pedidos (recibo_token)
  where recibo_token is not null;

comment on column public.pedidos.recibo_token is
  'Token opaco para URL pública del ticket: https://farmacapital.mx/r/{recibo_token}';

comment on column public.pedidos.recibo_generado_at is
  'Primera vez que se generó el enlace público del ticket (WhatsApp o manual).';

commit;
