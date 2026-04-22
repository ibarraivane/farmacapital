-- ============================================================
-- FARMAX — Parche: RLS en TODAS las tablas base de public
-- ============================================================
-- Supabase Security Advisor (rls_disabled_in_public) alerta si
-- cualquier tabla en `public` expuesta a la API no tiene RLS.
--
-- Causas típicas:
--   • Tabla nueva creada después de refactor_fase6c_rls_policies.sql
--   • Migración manual / import sin ENABLE ROW LEVEL SECURITY
--
-- Este script solo hace: ALTER TABLE ... ENABLE ROW LEVEL SECURITY
-- en cada tabla ordinaria (relkind 'r') de public que aún no la tenga.
--
-- Comportamiento tras habilitar RLS sin policies:
--   anon / authenticated no ven filas vía PostgREST salvo que exista
--   una policy que lo permita (ver F6c).
--
-- Si alguna pantalla deja de cargar datos, esa tabla necesita una
-- policy SELECT (como en refactor_fase6c_rls_policies.sql) o el FE
-- debe usar solo RPCs.
--
-- Ejecutar en Supabase SQL Editor (idempotente).
-- ============================================================

begin;

-- (Opcional) Ver qué tablas están sin RLS antes de correr el bloque:
-- select c.relname
-- from pg_class c
-- join pg_namespace n on n.oid = c.relnamespace
-- where n.nspname = 'public'
--   and c.relkind = 'r'
--   and not c.relrowsecurity
-- order by 1;

do $$
declare
  r record;
begin
  for r in
    select c.relname
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind = 'r'
      and not c.relrowsecurity
    order by c.relname
  loop
    raise notice 'Habilitando RLS en public.%', r.relname;
    execute format('alter table public.%I enable row level security', r.relname);
  end loop;
end $$;

commit;

-- Tras ejecutar, el advisor debería dejar de marcar "table publicly accessible".
-- Si persiste, revisa vistas/materialized views o esquemas distintos de public.
