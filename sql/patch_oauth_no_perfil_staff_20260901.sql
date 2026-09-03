-- ============================================================
-- FARMAX — Google OAuth de clientes no debe crear empleado
-- ============================================================
-- Causa del error en tienda: "Database error saving new user"
--
-- auth.handle_new_auth_user (legado) insertaba en public.perfiles
-- (id uuid, rol, nombre) cada vez que Auth creaba un usuario.
--
-- Eso rompe el login con Google de un cliente:
--   1) No trae rol de empleado → el trigger lo metía como 'vendedor'
--   2) public.perfiles ya no es (id, rol, nombre); el personal se
--      crea en public.usuarios + perfiles.usuario_id (bigint)
--   3) El INSERT falla → Auth revierte → no hay cuenta
--
-- El personal se da de alta con admin_crear_usuario.
-- Los clientes de la tienda, con service_login_cliente_oauth.
-- Este trigger no debe escribir nada.
--
-- Ejecutar en SQL Editor de Supabase (idempotente).
-- ============================================================

begin;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- No-op a propósito. Un INSERT en auth.users (Google / Apple /
  -- Facebook de la tienda) no crea personal ni toca perfiles.
  return NEW;
end;
$$;

comment on function public.handle_new_auth_user() is
  'Legado: ya no copia auth.users a perfiles. Los clientes van a public.clientes; el personal a public.usuarios.';

commit;
