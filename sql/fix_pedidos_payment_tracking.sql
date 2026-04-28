-- FARMAX: trazabilidad de pagos online (Mercado Pago / pasarela externa)
-- Idempotente. No altera flujos existentes de estado de pedido.

begin;

alter table if exists public.pedidos
  add column if not exists payment_provider text,
  add column if not exists payment_status text,
  add column if not exists payment_id text,
  add column if not exists paid_at timestamptz,
  add column if not exists payment_payload jsonb;

create index if not exists idx_pedidos_payment_id on public.pedidos(payment_id);
create index if not exists idx_pedidos_payment_status on public.pedidos(payment_status);

commit;
