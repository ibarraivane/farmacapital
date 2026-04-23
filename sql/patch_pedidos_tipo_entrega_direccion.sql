-- ============================================================
-- FARMAX — Columnas tipo_entrega y direccion en pedidos (tienda web / envío)
-- ============================================================
-- Ejecutar en Supabase SQL si ves errores PostgREST del tipo:
--   "column pedidos.direccion does not exist"
-- El RPC cliente_crear_pedido_online (refactor_fase6b_rpcs_tienda.sql) ya
-- inserta estas columnas; sin ellas el checkout online y el POS (select)
-- fallan con 400.
-- ============================================================

begin;

alter table public.pedidos
  add column if not exists tipo_entrega text;

alter table public.pedidos
  add column if not exists direccion text;

comment on column public.pedidos.tipo_entrega is
  'recoger | envio — alineado a checkout web y POS (ver docs/DELIVERY_MARKETPLACE_PREP.md).';

comment on column public.pedidos.direccion is
  'Dirección de envío cuando tipo_entrega = envio; null en recoger en tienda.';

commit;
