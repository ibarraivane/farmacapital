-- ============================================================
-- FARMAX — F6f: Endurecimiento EXECUTE (base vs *_secure)
-- ============================================================
-- - Revoca EXECUTE a public, anon y authenticated sobre RPCs base
--   que aceptan p_user_id (evita suplantación con la anon key).
-- - Revoca EXECUTE a PUBLIC sobre funciones *_secure y reafirma
--   EXECUTE para anon, authenticated y service_role.
--
-- Corre DESPUÉS de refactor_fase6b_rpcs_secure_wrappers.sql (F6b.5).
-- Idempotente: REVOKE/GRANT repetibles.
-- ============================================================

begin;

-- ----------------------------------------------------------------
-- 1) Funciones base: sin cliente (public / anon / authenticated)
-- ----------------------------------------------------------------
-- service_role conserva cualquier GRANT previo si ya existía.

revoke execute on function public.create_sale_transaction(bigint, text, numeric, jsonb)
  from public, anon, authenticated;

revoke execute on function public.create_sale_transaction_v2(
  bigint, text, numeric, jsonb, bigint, text, text, text
) from public, anon, authenticated;

revoke execute on function public.abrir_caja_lote(bigint, bigint)
  from public, anon, authenticated;

revoke execute on function public.adjust_stock_via_lotes(bigint, integer, text, bigint)
  from public, anon, authenticated;

revoke execute on function public.create_producto_with_lote(
  jsonb, integer, text, date, numeric, bigint
) from public, anon, authenticated;

revoke execute on function public.consume_stock_via_lotes(
  bigint, integer, text, bigint, text
) from public, anon, authenticated;

revoke execute on function public.receive_merchandise_lote(
  bigint, integer, text, date, numeric, text, bigint
) from public, anon, authenticated;

-- ----------------------------------------------------------------
-- 2) Wrappers *_secure: sin PUBLIC; cliente + service_role explícitos
-- ----------------------------------------------------------------

revoke execute on function public.create_sale_transaction_secure(
  uuid, text, numeric, jsonb, bigint, text, text, text
) from public;
grant execute on function public.create_sale_transaction_secure(
  uuid, text, numeric, jsonb, bigint, text, text, text
) to anon, authenticated, service_role;

revoke execute on function public.abrir_caja_secure(uuid, bigint)
  from public;
grant execute on function public.abrir_caja_secure(uuid, bigint)
  to anon, authenticated, service_role;

revoke execute on function public.restock_via_lote_secure(
  uuid, bigint, integer, text, bigint
) from public;
grant execute on function public.restock_via_lote_secure(
  uuid, bigint, integer, text, bigint
) to anon, authenticated, service_role;

revoke execute on function public.adjust_stock_secure(
  uuid, bigint, integer, text
) from public;
grant execute on function public.adjust_stock_secure(
  uuid, bigint, integer, text
) to anon, authenticated, service_role;

revoke execute on function public.create_producto_secure(
  uuid, jsonb, integer, text, date, numeric
) from public;
grant execute on function public.create_producto_secure(
  uuid, jsonb, integer, text, date, numeric
) to anon, authenticated, service_role;

revoke execute on function public.receive_merchandise_secure(
  uuid, bigint, integer, text, date, numeric, text
) from public;
grant execute on function public.receive_merchandise_secure(
  uuid, bigint, integer, text, date, numeric, text
) to anon, authenticated, service_role;

revoke execute on function public.consume_stock_secure(
  uuid, bigint, integer, text, text
) from public;
grant execute on function public.consume_stock_secure(
  uuid, bigint, integer, text, text
) to anon, authenticated, service_role;

commit;

-- ============================================================
-- FIN F6f
-- ============================================================
