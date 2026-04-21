-- ============================================================
-- FARMAX — Parche: EXECUTE en RPCs de login (PostgREST)
-- ============================================================
-- Síntoma: login admin o tienda falla con 403 / "permission denied"
-- al llamar login_empleado o login_cliente.
--
-- Idempotente. Ejecutar en Supabase SQL Editor si hace falta.
-- ============================================================

begin;

grant execute on function public.login_empleado(text, text, text, text) to anon, authenticated;
grant execute on function public.login_cliente(text, text, text, text) to anon, authenticated;
grant execute on function public.registrar_cliente(text, text, text, text, text, text) to anon, authenticated;
grant execute on function public.logout_empleado(uuid) to anon, authenticated;
grant execute on function public.logout_cliente(uuid) to anon, authenticated;

commit;
