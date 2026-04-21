-- ============================================================
-- FARMAX — Parche: fn_hash_* + pgcrypto (Supabase)
-- ============================================================
-- Síntoma al iniciar sesión:
--   function digest(text, unknown) does not exist
--   (a veces POST /rpc/login_empleado aparece como 404 en el navegador)
--
-- Causa: en Supabase, pgcrypto vive en el schema `extensions`. Las
-- funciones SQL sin search_path no resuelven `digest()` y Postgres
-- intenta firmas imposibles (text + unknown).
--
-- Ejecutar una vez en Supabase SQL Editor (idempotente).
-- ============================================================

begin;

create extension if not exists pgcrypto with schema extensions;

create or replace function public.fn_hash_empleado(p_pwd text, p_salt text)
returns text
language sql
immutable
set search_path = public, extensions, pg_temp
as $$
  select encode(
    digest(
      coalesce(nullif(p_salt, ''), 'farmax_2026_salt')
        || p_pwd
        || length(coalesce(nullif(p_salt, ''), 'farmax_2026_salt'))::text,
      'sha256'::text
    ),
    'hex'
  );
$$;

create or replace function public.fn_hash_cliente(p_pwd text)
returns text
language sql
immutable
set search_path = public, extensions, pg_temp
as $$
  select encode(digest(p_pwd, 'sha256'::text), 'hex');
$$;

revoke all on function public.fn_hash_empleado(text, text) from public, anon, authenticated;
revoke all on function public.fn_hash_cliente(text) from public, anon, authenticated;

commit;
