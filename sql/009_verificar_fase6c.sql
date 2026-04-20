-- ============================================================
-- FARMAX — Verificación F6c (RLS granular)
-- ============================================================
-- Tras ejecutar refactor_fase6c_rls_policies.sql, este script
-- valida que:
--   1. RLS esté habilitada en todas las tablas esperadas.
--   2. Las tablas públicas (productos/banners/promociones) tengan
--      su policy SELECT con filtro correcto.
--   3. Las tablas operativas tengan policy USING(true) para anon/auth.
--   4. Las tablas "solo-RPC" NO tengan policies.
--   5. Ningún INSERT/UPDATE/DELETE tenga policy para anon/auth
--      (todo pasa por RPC SECURITY DEFINER).
--
-- Uso: ejecutar en el SQL editor de Supabase y revisar cada bloque.
-- Cada query debe devolver 0 filas en "errores".
-- ============================================================

-- ============================================================
-- 1. RLS habilitada en tablas críticas
-- ============================================================
with esperadas as (
  select unnest(array[
    'productos','banners','promociones','sucursales',
    'pedidos','pedido_items','clientes','usuarios','empleados',
    'citas','lotes','proveedores','configuracion',
    'cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items',
    'bitacora_cofepris','alertas_legales',
    'sesiones','sesiones_cliente','password_reset_requests',
    'audit_log','nomina_empleados','recetas'
  ]) as tbl
)
select
  e.tbl,
  coalesce(c.relrowsecurity, false) as rls_enabled,
  case when not coalesce(c.relrowsecurity, false) then '⚠ RLS DESHABILITADA' else '✓' end as estado
from esperadas e
left join pg_class c
  on c.relname = e.tbl
  and c.relnamespace = (select oid from pg_namespace where nspname='public')
where c.oid is not null  -- tabla existe
  and not coalesce(c.relrowsecurity, false);
-- ESPERADO: 0 filas (todas con RLS habilitada).


-- ============================================================
-- 2. Policies de categoría (A) — Público filtrado
-- ============================================================
select
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  p.qual as using_expr
from pg_policies p
where p.schemaname = 'public'
  and p.tablename in ('productos','banners','promociones')
order by p.tablename, p.policyname;
-- ESPERADO: al menos una policy SELECT por tabla, con filtro activo/activa.


-- ============================================================
-- 3. Policies de categoría (B) — REST-accessible operativas
-- ============================================================
-- Todas deben tener policy SELECT con USING(true) para anon/authenticated.
with operativas as (
  select unnest(array[
    'pedidos','pedido_items','clientes','usuarios','empleados',
    'citas','lotes','proveedores','configuracion',
    'cortes_caja','facturas','devoluciones','bitacora_cofepris'
  ]) as tbl
)
select
  o.tbl,
  coalesce(
    (select string_agg(p.policyname, ', ')
     from pg_policies p
     where p.schemaname='public' and p.tablename = o.tbl and p.cmd='SELECT'),
    '⚠ sin policy SELECT'
  ) as policies_select
from operativas o
where exists (
  select 1 from information_schema.tables
  where table_schema='public' and table_name = o.tbl
);
-- ESPERADO: cada tabla con policy "rls_<nombre>_rest_read" u otras equivalentes.
-- Ninguna con '⚠ sin policy'.


-- ============================================================
-- 4. Tablas "solo-RPC" NO deben tener policies
-- ============================================================
-- RLS ON + sin policies = DENY ALL.
with solo_rpc as (
  select unnest(array[
    'sesiones','sesiones_cliente','password_reset_requests',
    'audit_log','audit_log_detallado','nomina_empleados',
    'bitacora_antibioticos','recetas','movimientos_puntos'
  ]) as tbl
)
select
  s.tbl,
  p.policyname,
  p.cmd,
  p.roles,
  '⚠ POLICY INDESEADA' as alerta
from solo_rpc s
join pg_policies p
  on p.schemaname='public' and p.tablename = s.tbl
where exists (
  select 1 from information_schema.tables
  where table_schema='public' and table_name = s.tbl
);
-- ESPERADO: 0 filas.


-- ============================================================
-- 5. Ningún INSERT/UPDATE/DELETE policy para anon/authenticated
-- ============================================================
-- Defensa en profundidad: todas las escrituras deben pasar por RPC.
select
  p.tablename,
  p.policyname,
  p.cmd,
  p.roles,
  '⚠ POLICY DE ESCRITURA DIRECTA' as alerta
from pg_policies p
where p.schemaname = 'public'
  and p.cmd in ('INSERT','UPDATE','DELETE')
  and (
    'anon' = any(p.roles)
    or 'authenticated' = any(p.roles)
    or 'public' = any(p.roles)
  );
-- ESPERADO: 0 filas.


-- ============================================================
-- 6. Smoke test de DENY real (copiar y correr en SQL editor)
-- ============================================================
-- Estos SELECTs deben devolver 0 filas o error de permiso
-- cuando se ejecutan como anon/authenticated:
--
--   -- en SQL editor con `set role anon;`
--   select count(*) from public.sesiones;               -- debe ser 0
--   select count(*) from public.password_reset_requests;-- debe ser 0
--   select count(*) from public.audit_log;              -- debe ser 0
--   select password_hash from public.usuarios limit 1;  -- permission denied
--   select password_hash from public.clientes limit 1;  -- permission denied
--   reset role;
--
-- NO ejecutes este bloque automáticamente; úsalo manualmente si dudas.


-- ============================================================
-- 7. Resumen final
-- ============================================================
select
  count(*) filter (where relrowsecurity) as tablas_con_rls,
  count(*) filter (where not relrowsecurity) as tablas_sin_rls
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r';
-- Resultado esperable: la gran mayoría con RLS ON.
