-- ============================================================
-- FARMAX — F6b hardening de helpers internos
-- ============================================================
-- Corrige warnings de 008_verificar_fase6b.sql:
--   - fn_generar_salt: pasa a SECURITY DEFINER + search_path fijo
--   - fn_require_*: grants a anon/authenticated (defense-in-depth)
--     Son inocuas si se llaman directo: solo validan y devuelven
--     user_id o lanzan excepción. No modifican estado.
-- ============================================================

begin;

-- 1) fn_generar_salt endurecida
-- pgcrypto vive en el schema "extensions" en Supabase, por eso
-- añadimos extensions al search_path.
create or replace function public.fn_generar_salt()
returns text
language sql
security definer
set search_path = public, extensions, pg_temp
as $$
  select encode(extensions.gen_random_bytes(16), 'hex');
$$;

-- 2) Grants a helpers (ya son SECURITY DEFINER)
grant execute on function public.fn_generar_salt()                 to anon, authenticated;
grant execute on function public.fn_require_admin(uuid)            to anon, authenticated;
grant execute on function public.fn_require_empleado(uuid)         to anon, authenticated;
grant execute on function public.fn_require_cliente(uuid)          to anon, authenticated;

commit;

-- ============================================================
-- Re-corre 008_verificar_fase6b.sql y deben salir todos verdes.
-- ============================================================
