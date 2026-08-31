-- FARMAX — Costo de envío Uber Direct (opcional, aditivo)
-- El checkout cobra el fee al comprador. El API /api/logistics/uber-direct
-- actualiza pedidos.total y logistics_meta aunque esta columna no exista.
-- Ejecutar en Supabase SQL Editor tras backup.

begin;

alter table public.pedidos
  add column if not exists costo_envio numeric;

comment on column public.pedidos.costo_envio is
  'Costo de envío cobrado al cliente (Uber Direct), en MXN. Independiente de la suma de pedido_items.';

alter table public.pedidos
  add column if not exists logistics_meta jsonb not null default '{}'::jsonb;

commit;
