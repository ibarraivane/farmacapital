-- FARMAX: tracking logistico para pedidos online (pickup/envio)
-- Ejecutar en Supabase SQL Editor.

begin;

alter table public.pedidos
  add column if not exists delivery_provider text,
  add column if not exists delivery_status text,
  add column if not exists delivery_tracking_url text,
  add column if not exists delivery_payload jsonb;

comment on column public.pedidos.delivery_provider is 'Proveedor logistico: uber, rappi, skydropx, manual';
comment on column public.pedidos.delivery_status is 'ready_for_pickup, in_route, delivered, cancelled';
comment on column public.pedidos.delivery_tracking_url is 'URL de seguimiento del envio';
comment on column public.pedidos.delivery_payload is 'Payload crudo de webhooks/logistica';

commit;
