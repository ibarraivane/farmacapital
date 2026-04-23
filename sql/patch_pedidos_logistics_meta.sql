-- ============================================================
-- FARMAX — Columna opcional logistics_meta en pedidos
-- ============================================================
-- Ejecutar manualmente en Supabase cuando quieras persistir:
--   order_channel, fulfillment_type, external_order_id,
--   external_delivery_id, provider, tracking_url, timestamps, etc.
-- sin múltiples ALTERs nuevos.
--
-- No modifica RPCs existentes; el admin puede actualizar vía SQL o
-- futuras migraciones que lean/escriban este jsonb.
-- ============================================================

begin;

alter table public.pedidos
  add column if not exists logistics_meta jsonb not null default '{}'::jsonb;

comment on column public.pedidos.logistics_meta is
  'Metadatos de canal y logística: order_channel, fulfillment_type, external_order_id, external_delivery_id, logistics_provider, tracking_url, courier, timestamps (ver docs/DELIVERY_MARKETPLACE_PREP.md).';

commit;
