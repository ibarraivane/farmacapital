-- ============================================================
-- FARMAX — F6a (2/4): Revocación de grants masivos (HÍBRIDA)
-- ============================================================
-- Estrategia pragmática acordada con el usuario:
--
--   • Revocar INSERT/UPDATE/DELETE en TODAS las tablas de public
--     (todas las escrituras deben pasar por RPCs SECURITY DEFINER).
--
--   • Revocar SELECT solo en tablas de credenciales/sensibles:
--       - usuarios, clientes, empleados (contienen password_hash, salt)
--       - sesiones, sesiones_cliente
--       - password_reset_requests
--     Para leer estas tablas desde el frontend, usar las RPCs de
--     lectura en refactor_fase6a_rpcs_lectura_credenciales.sql.
--
--   • SELECT directo queda permitido temporalmente en el resto de
--     tablas operativas (pedidos, citas, lotes, etc.). F6c (RLS)
--     filtrará fila por fila según rol del usuario.
--
--   • Lectura pública sin login: productos, banners, promociones,
--     sucursales.
--
-- REQUISITO: correr ANTES refactor_fase6a_rpcs_lectura_credenciales.sql
-- para que el frontend pueda seguir operando.
--
-- IDEMPOTENTE: se puede re-ejecutar sin efectos colaterales.
-- ============================================================

begin;

-- ============================================================
-- Paso 1: revocar TODO write (INSERT/UPDATE/DELETE) en public
-- ============================================================
-- Mantiene SELECT intacto; solo quita escrituras directas.
-- ============================================================
do $$
declare
  r record;
begin
  for r in
    select tablename
    from pg_tables
    where schemaname = 'public'
  loop
    execute format(
      'revoke insert, update, delete on public.%I from anon, authenticated',
      r.tablename
    );
  end loop;

  for r in
    select viewname
    from pg_views
    where schemaname = 'public'
  loop
    -- Views normalmente no se modifican, pero por defensa en profundidad:
    execute format(
      'revoke insert, update, delete on public.%I from anon, authenticated',
      r.viewname
    );
  end loop;
end $$;


-- ============================================================
-- Paso 2: revocar SELECT en tablas de credenciales / sensibles
-- ============================================================
-- Estas tablas contienen password_hash, salt o tokens.
-- Estrategia: column-level grants para permitir JOINs básicos
-- desde PostgREST (ej: pedidos → clientes(nombre, telefono)) sin
-- jamás exponer password_hash, salt, ni tokens.
--
-- El frontend admin sigue usando RPCs para leer el detalle
-- completo (ya migrado en F6a-lectura_credenciales).
-- ============================================================

-- -- USUARIOS ------------------------------------------------
-- Revocar SELECT global y otorgar solo a columnas seguras, por JOIN
-- desde pedidos, audit_log, etc.
revoke select on public.usuarios from anon, authenticated;

do $$
declare
  v_cols  text[] := array['id','nombre','email','rol','activo','created_at','updated_at'];
  v_real  text[];
  v_final text[];
begin
  select array_agg(column_name::text) into v_real
  from information_schema.columns
  where table_schema='public' and table_name='usuarios';

  select array_agg(c) into v_final
  from unnest(v_cols) c
  where c = any(v_real);

  if v_final is not null and array_length(v_final,1) > 0 then
    execute format(
      'grant select (%s) on public.usuarios to anon, authenticated',
      array_to_string(v_final, ', ')
    );
  end if;
end $$;

-- -- CLIENTES ------------------------------------------------
revoke select on public.clientes from anon, authenticated;

do $$
declare
  v_cols  text[] := array[
    'id','nombre','telefono','email','puntos','notas','alergias','antecedentes',
    'direccion','fecha_nacimiento','genero','rfc','razon_social','cp',
    'created_at','updated_at'
  ];
  v_real  text[];
  v_final text[];
begin
  select array_agg(column_name::text) into v_real
  from information_schema.columns
  where table_schema='public' and table_name='clientes';

  select array_agg(c) into v_final
  from unnest(v_cols) c
  where c = any(v_real);

  if v_final is not null and array_length(v_final,1) > 0 then
    execute format(
      'grant select (%s) on public.clientes to anon, authenticated',
      array_to_string(v_final, ', ')
    );
  end if;
end $$;

-- -- EMPLEADOS ------------------------------------------------
-- Solo columnas de identidad / operativas. Sueldos y cédulas
-- quedan fuera (se consultan via admin_listar_empleados RPC).
revoke select on public.empleados from anon, authenticated;

do $$
declare
  v_cols  text[] := array[
    'id','nombre','puesto','telefono','email','sucursal_id','activo',
    'created_at','updated_at','fecha_ingreso'
  ];
  v_real  text[];
  v_final text[];
begin
  select array_agg(column_name::text) into v_real
  from information_schema.columns
  where table_schema='public' and table_name='empleados';

  select array_agg(c) into v_final
  from unnest(v_cols) c
  where c = any(v_real);

  if v_final is not null and array_length(v_final,1) > 0 then
    execute format(
      'grant select (%s) on public.empleados to anon, authenticated',
      array_to_string(v_final, ', ')
    );
  end if;
end $$;

-- -- SESIONES / RESETS ---------------------------------------
-- Sin grants parciales: tokens y resets NUNCA se leen desde REST.
do $$ begin
  perform 1 from information_schema.tables
  where table_schema='public' and table_name='sesiones';
  if found then
    revoke select on public.sesiones from anon, authenticated;
  end if;
end $$;

do $$ begin
  perform 1 from information_schema.tables
  where table_schema='public' and table_name='sesiones_cliente';
  if found then
    revoke select on public.sesiones_cliente from anon, authenticated;
  end if;
end $$;

do $$ begin
  perform 1 from information_schema.tables
  where table_schema='public' and table_name='password_reset_requests';
  if found then
    revoke select on public.password_reset_requests from anon, authenticated;
  end if;
end $$;


-- ============================================================
-- Paso 3: asegurar que las tablas públicas sigan accesibles
-- ============================================================
-- Estas son las únicas que ven los usuarios NO autenticados.
-- ============================================================
grant select on public.productos   to anon, authenticated;
grant select on public.banners     to anon, authenticated;
grant select on public.promociones to anon, authenticated;

do $$ begin
  perform 1 from information_schema.tables
  where table_schema='public' and table_name='sucursales';
  if found then
    execute 'grant select on public.sucursales to anon, authenticated';
  end if;
end $$;


-- ============================================================
-- Paso 4: schema usage (idempotente)
-- ============================================================
grant usage on schema public to anon, authenticated;


-- ============================================================
-- Paso 5: default privileges para nuevas tablas/secuencias
-- ============================================================
-- Nuevas tablas en public NO heredan grants a anon/authenticated.
-- Hay que otorgar manualmente lo mínimo necesario.
-- ============================================================
alter default privileges in schema public
  revoke insert, update, delete on tables from anon, authenticated;

alter default privileges in schema public
  revoke all on sequences from anon, authenticated;

-- Funciones nuevas tampoco reciben grants masivos; cada RPC debe
-- otorgar execute explícitamente.
alter default privileges in schema public
  revoke execute on functions from anon, authenticated;


commit;

-- ============================================================
-- EFECTOS TRAS EJECUTAR:
--   ✓ Imposible hacer INSERT/UPDATE/DELETE directo desde JS.
--   ✓ Imposible leer password_hash, tokens, resets desde JS.
--   ✓ Admin panel sigue funcionando (SELECT directo temporalmente
--     permitido sobre tablas operativas; F6c agregará RLS).
--   ✓ Tienda pública lee productos/banners/promociones sin login.
--
-- SIGUIENTE PASO: F6c — habilitar RLS y crear policies por rol
-- (admin ve todo, empleado ve su sucursal, cliente solo sus datos).
-- ============================================================
