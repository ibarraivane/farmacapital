-- ============================================================
-- FARMAX — F6c: Row-Level Security granular (defensa en profundidad)
-- ============================================================
-- Modelo elegido:
--
--   • Arquitectura: sesiones custom via tokens (tabla sesiones /
--     sesiones_cliente). El frontend llama siempre como rol `anon`
--     o `authenticated` (sin claim de JWT de rol personalizado).
--
--   • Escrituras: bloqueadas por F6a(2/4) con REVOKE INSERT/UPDATE/
--     DELETE global. Pasan por RPCs SECURITY DEFINER que bypassean
--     RLS al ejecutar como `postgres` (dueño de las tablas).
--
--   • Lecturas: RLS habilitada en TODAS las tablas con 3 niveles:
--
--     (A) "Público filtrado":
--         productos, banners, promociones, sucursales
--         → policy SELECT USING(activo|activa = true [cuando existe])
--
--     (B) "REST-accessible":
--         pedidos, pedido_items, clientes, usuarios, empleados,
--         citas, lotes, proveedores, configuracion, cortes_caja,
--         facturas, devoluciones, bitacora_cofepris, etc.
--         → policy SELECT USING(true). La protección real está en:
--             - column-level grants (usuarios/clientes/empleados no
--               exponen password_hash)
--             - revoke de INSERT/UPDATE/DELETE (write solo via RPC)
--
--     (C) "Solo RPC":
--         sesiones, sesiones_cliente, password_reset_requests,
--         audit_log, audit_log_detallado, nomina_empleados,
--         bitacora_antibioticos, recetas, movimientos_puntos, etc.
--         → RLS ON, sin policies → DENY ALL para anon/authenticated.
--         Los RPCs SECURITY DEFINER las leen como postgres.
--
-- IDEMPOTENTE: usa create policy if not exists (via DO blocks) y
-- alter table ... enable row level security que es NO-OP si ya está.
-- ============================================================

begin;

-- ============================================================
-- Helper: habilita RLS en una tabla si existe
-- ============================================================
do $$
declare
  r record;
  v_all_tables text[] := array[
    -- (A) públicas filtradas
    'productos','banners','promociones','sucursales',
    -- (B) REST-accessible operativas
    'pedidos','pedido_items','clientes','usuarios','empleados',
    'citas','consumibles_consulta','procedimientos_medicos','medicos',
    'lotes','proveedores','configuracion',
    'cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items',
    'compras','compra_items',
    'alertas_legales','bitacora_cofepris',
    'movimientos_inventario',
    'folios','envios','direcciones_cliente',
    'equipamiento_consultorio','stock_reservations',
    'promocion_productos',
    'perfiles','bitacora_usuarios',
    -- (C) solo-RPC (RLS ON sin policies = DENY)
    'sesiones','sesiones_cliente','password_reset_requests',
    'audit_log','audit_log_detallado','nomina_empleados',
    'bitacora_antibioticos','recetas','movimientos_puntos',
    'lotes_producto'
  ];
  v_tbl text;
begin
  foreach v_tbl in array v_all_tables
  loop
    perform 1 from information_schema.tables
    where table_schema='public' and table_name = v_tbl;
    if found then
      execute format('alter table public.%I enable row level security', v_tbl);
      -- force RLS también para el dueño evita fugas, pero rompería RPCs
      -- SECURITY DEFINER owned by postgres. NO habilitamos FORCE.
    end if;
  end loop;
end $$;


-- ============================================================
-- CATEGORÍA (A): Público filtrado
-- ============================================================
-- Lectura pública sin login, solo registros activos / vigentes.
-- ============================================================

-- productos: ya tiene columna `activo`
drop policy if exists "rls_productos_public_read" on public.productos;
create policy "rls_productos_public_read"
  on public.productos for select
  to anon, authenticated
  using (activo = true);

-- banners: columna `activo`
drop policy if exists "rls_banners_public_read" on public.banners;
create policy "rls_banners_public_read"
  on public.banners for select
  to anon, authenticated
  using (activo = true);

-- promociones: columna `activa`
drop policy if exists "rls_promociones_public_read" on public.promociones;
create policy "rls_promociones_public_read"
  on public.promociones for select
  to anon, authenticated
  using (activa = true);

-- promocion_productos: depende de promociones; lectura libre
-- (es una tabla M-a-M sin datos sensibles)
drop policy if exists "rls_promocion_productos_public_read" on public.promocion_productos;
create policy "rls_promocion_productos_public_read"
  on public.promocion_productos for select
  to anon, authenticated
  using (true);

-- sucursales: lectura libre si la tabla existe
do $$ begin
  perform 1 from information_schema.tables
  where table_schema='public' and table_name='sucursales';
  if found then
    drop policy if exists "rls_sucursales_public_read" on public.sucursales;
    create policy "rls_sucursales_public_read"
      on public.sucursales for select
      to anon, authenticated
      using (true);
  end if;
end $$;


-- ============================================================
-- CATEGORÍA (B): REST-accessible operativas
-- ============================================================
-- Policy USING(true) para SELECT. La protección real está en:
--   • Column-level grants (password_hash/salt nunca expuestos)
--   • Revoke de INSERT/UPDATE/DELETE (escritura solo via RPC)
-- ============================================================

do $$
declare
  v_operativas text[] := array[
    'pedidos','pedido_items','clientes','usuarios','empleados',
    'citas','consumibles_consulta','procedimientos_medicos','medicos',
    'lotes','proveedores','configuracion',
    'cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items',
    'compras','compra_items',
    'alertas_legales','bitacora_cofepris',
    'movimientos_inventario',
    'folios','envios','direcciones_cliente',
    'equipamiento_consultorio','stock_reservations',
    'perfiles','bitacora_usuarios',
    'lotes_producto'
  ];
  v_tbl text;
begin
  foreach v_tbl in array v_operativas
  loop
    perform 1 from information_schema.tables
    where table_schema='public' and table_name = v_tbl;
    if not found then continue; end if;

    execute format(
      'drop policy if exists %I on public.%I',
      'rls_'||v_tbl||'_rest_read',
      v_tbl
    );
    execute format(
      'create policy %I on public.%I for select to anon, authenticated using (true)',
      'rls_'||v_tbl||'_rest_read',
      v_tbl
    );
  end loop;
end $$;


-- ============================================================
-- CATEGORÍA (C): Solo-RPC (RLS ON sin policies = DENY ALL)
-- ============================================================
-- Estas tablas NO tienen ninguna policy para anon/authenticated.
-- Cualquier SELECT directo desde REST devolverá 0 filas (RLS deniega).
-- Los RPCs SECURITY DEFINER las acceden como postgres (bypass RLS).
--
-- Explícitamente dejamos sin policy:
--   sesiones, sesiones_cliente, password_reset_requests,
--   audit_log, audit_log_detallado, nomina_empleados,
--   bitacora_antibioticos, recetas, movimientos_puntos
--
-- Por defensa en profundidad, dropeamos cualquier policy previa.
-- ============================================================
do $$
declare
  v_solo_rpc text[] := array[
    'sesiones','sesiones_cliente','password_reset_requests',
    'audit_log','audit_log_detallado','nomina_empleados',
    'bitacora_antibioticos','recetas','movimientos_puntos'
  ];
  v_tbl text;
  v_pol record;
begin
  foreach v_tbl in array v_solo_rpc
  loop
    perform 1 from information_schema.tables
    where table_schema='public' and table_name = v_tbl;
    if not found then continue; end if;

    -- Drop cualquier policy existente para garantizar DENY
    for v_pol in
      select policyname from pg_policies
      where schemaname='public' and tablename = v_tbl
    loop
      execute format('drop policy if exists %I on public.%I', v_pol.policyname, v_tbl);
    end loop;
  end loop;
end $$;


commit;

-- ============================================================
-- FIN F6c
-- ============================================================
-- EFECTOS:
--   ✓ RLS habilitada en todas las tablas relevantes.
--   ✓ Tienda pública ve solo productos/banners/promociones activos.
--   ✓ Admin panel sigue leyendo operativas (policy USING true).
--   ✓ Credenciales (password_hash/salt) bloqueadas por column grants.
--   ✓ Sesiones, resets, audit, nómina, recetas: DENY ALL directo.
--     Solo accesibles via RPCs SECURITY DEFINER.
--   ✓ RPCs SECURITY DEFINER siguen funcionando (bypass RLS como owner).
--
-- SIGUIENTE: F6d — triggers de auditoría detallada.
-- ============================================================
