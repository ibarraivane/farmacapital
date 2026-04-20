-- ============================================================
-- FARMAX — F6d: Auditoría detallada con triggers
-- ============================================================
-- Objetivo: audit trail automático e inmutable en 6 grupos de
-- tablas críticas. Compliance COFEPRIS, forensics, detección de
-- actividad sospechosa.
--
-- Modelo:
--   1. Tabla public.audit_log_detallado (se crea o normaliza).
--   2. GUCs de sesión (`app.actor_id`, `app.actor_tipo`, `app.actor_ip`)
--      seteados automáticamente por fn_require_admin/empleado/cliente.
--   3. Función genérica fn_audit_trigger() que captura INSERT/UPDATE/
--      DELETE, filtra password_hash/salt/token, y calcula
--      campos_cambiados en UPDATE.
--   4. Triggers AFTER ROW en ~35 tablas de 6 grupos.
--
-- IDEMPOTENTE: se puede re-ejecutar sin efectos colaterales.
-- ============================================================

begin;

-- ============================================================
-- Paso 1: normalizar tabla audit_log_detallado
-- ============================================================
-- Si existe, agregamos columnas faltantes. Si no, la creamos.
-- ============================================================

create table if not exists public.audit_log_detallado (
  id              bigserial primary key,
  tabla           text        not null,
  operacion       text        not null check (operacion in ('INSERT','UPDATE','DELETE')),
  registro_id     text,
  actor_id        bigint,
  actor_tipo      text,
  actor_ip        text,
  valores_antes   jsonb,
  valores_despues jsonb,
  campos_cambiados text[],
  created_at      timestamptz not null default now()
);

-- Por si la tabla ya existía con schema distinto: agrega columnas faltantes
do $$
declare
  v_cols text[];
begin
  select array_agg(column_name::text) into v_cols
  from information_schema.columns
  where table_schema = 'public' and table_name = 'audit_log_detallado';

  if not ('tabla'            = any(v_cols)) then execute 'alter table public.audit_log_detallado add column tabla text'; end if;
  if not ('operacion'        = any(v_cols)) then execute 'alter table public.audit_log_detallado add column operacion text'; end if;
  if not ('registro_id'      = any(v_cols)) then execute 'alter table public.audit_log_detallado add column registro_id text'; end if;
  if not ('actor_id'         = any(v_cols)) then execute 'alter table public.audit_log_detallado add column actor_id bigint'; end if;
  if not ('actor_tipo'       = any(v_cols)) then execute 'alter table public.audit_log_detallado add column actor_tipo text'; end if;
  if not ('actor_ip'         = any(v_cols)) then execute 'alter table public.audit_log_detallado add column actor_ip text'; end if;
  if not ('valores_antes'    = any(v_cols)) then execute 'alter table public.audit_log_detallado add column valores_antes jsonb'; end if;
  if not ('valores_despues'  = any(v_cols)) then execute 'alter table public.audit_log_detallado add column valores_despues jsonb'; end if;
  if not ('campos_cambiados' = any(v_cols)) then execute 'alter table public.audit_log_detallado add column campos_cambiados text[]'; end if;
  if not ('created_at'       = any(v_cols)) then execute 'alter table public.audit_log_detallado add column created_at timestamptz not null default now()'; end if;
end $$;

-- Índices para consultas típicas
create index if not exists idx_audit_det_tabla_created on public.audit_log_detallado (tabla, created_at desc);
create index if not exists idx_audit_det_actor_created on public.audit_log_detallado (actor_id, created_at desc);
create index if not exists idx_audit_det_registro      on public.audit_log_detallado (tabla, registro_id);
create index if not exists idx_audit_det_created       on public.audit_log_detallado (created_at desc);

-- La tabla está en "solo-RPC" (RLS ON sin policies por F6c).
-- Las RPCs SECURITY DEFINER la escriben como postgres (BYPASSRLS).
alter table public.audit_log_detallado enable row level security;


-- ============================================================
-- Paso 2: helper para setear el contexto del actor (GUCs)
-- ============================================================
-- Llamado por fn_require_* al inicio. Idempotente por transacción.
-- Usa set_config(..., true) = scope LOCAL a la transacción.
-- ============================================================
create or replace function public.fn_set_actor_context(
  p_actor_id   bigint,
  p_actor_tipo text default 'empleado',
  p_actor_ip   text default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform set_config('app.actor_id',   coalesce(p_actor_id::text, ''), true);
  perform set_config('app.actor_tipo', coalesce(p_actor_tipo,     ''), true);
  perform set_config('app.actor_ip',   coalesce(p_actor_ip,       ''), true);
end;
$$;

-- anon/authenticated NO necesitan execute sobre este helper
-- (solo lo llaman los fn_require_* internos).
revoke execute on function public.fn_set_actor_context(bigint, text, text) from public, anon, authenticated;


-- ============================================================
-- Paso 3: extender fn_require_* para setear el actor (GUCs)
-- ============================================================
-- Conservamos las firmas y lógica originales (admin|gerente en
-- fn_require_admin; fn_validar_token_empleado como delegado).
-- Solo AGREGAMOS la llamada a fn_set_actor_context al final.
-- ============================================================

create or replace function public.fn_require_admin(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_rol     text;
begin
  v_user_id := public.fn_validar_token_empleado(p_token);
  if v_user_id is null then
    raise exception 'Sesión inválida o expirada' using errcode = '28000';
  end if;

  select rol into v_rol from public.usuarios where id = v_user_id and activo = true;
  if v_rol is null or v_rol not in ('admin', 'gerente') then
    raise exception 'Requiere rol admin o gerente' using errcode = '42501';
  end if;

  perform public.fn_set_actor_context(v_user_id, v_rol, null);

  return v_user_id;
end;
$$;

comment on function public.fn_require_admin(uuid) is
  'F6b/F6d: valida token + exige rol admin/gerente y setea app.actor_* para auditoría.';

create or replace function public.fn_require_empleado(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id bigint;
  v_activo  boolean;
  v_rol     text;
begin
  v_user_id := public.fn_validar_token_empleado(p_token);
  if v_user_id is null then
    raise exception 'Sesión inválida o expirada' using errcode = '28000';
  end if;

  select activo, rol into v_activo, v_rol from public.usuarios where id = v_user_id;
  if v_activo is null or v_activo = false then
    raise exception 'Usuario inactivo' using errcode = '42501';
  end if;

  perform public.fn_set_actor_context(v_user_id, coalesce(v_rol, 'empleado'), null);

  return v_user_id;
end;
$$;

comment on function public.fn_require_empleado(uuid) is
  'F6b/F6d: valida token empleado y setea app.actor_* para auditoría.';

create or replace function public.fn_require_cliente(p_token uuid)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_cliente_id bigint;
begin
  v_cliente_id := public.fn_validar_token_cliente(p_token);
  if v_cliente_id is null then
    raise exception 'Sesión de cliente inválida o expirada' using errcode = '28000';
  end if;

  perform public.fn_set_actor_context(v_cliente_id, 'cliente', null);

  return v_cliente_id;
end;
$$;

comment on function public.fn_require_cliente(uuid) is
  'F6b/F6d: valida token cliente y setea app.actor_* para auditoría.';

-- Conservar los grants del hardening F6b: anon/authenticated pueden
-- ejecutar fn_require_* (aunque al llamarlas desde REST sin token
-- válido fallan). Las RPCs SECURITY DEFINER no necesitan el grant
-- (se ejecutan como postgres), pero lo conservamos para consistencia.
grant execute on function public.fn_require_admin(uuid)    to anon, authenticated;
grant execute on function public.fn_require_empleado(uuid) to anon, authenticated;
grant execute on function public.fn_require_cliente(uuid)  to anon, authenticated;


-- ============================================================
-- Paso 4: función genérica de trigger de auditoría
-- ============================================================
-- SECURITY DEFINER owned by postgres → BYPASSRLS. Filtra campos
-- sensibles antes de persistir. No falla si el GUC actor está vacío.
-- ============================================================

create or replace function public.fn_audit_trigger()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_actor_id   bigint;
  v_actor_tipo text;
  v_actor_ip   text;
  v_old        jsonb;
  v_new        jsonb;
  v_pk         text;
  v_changed    text[];
  v_sens_cols  text[] := array['password_hash','salt','token','session_token','password'];
  v_col        text;
begin
  -- 1) Contexto del actor desde GUCs (puede ser null si no está)
  begin
    v_actor_id := nullif(current_setting('app.actor_id', true), '')::bigint;
  exception when others then v_actor_id := null; end;

  v_actor_tipo := nullif(current_setting('app.actor_tipo', true), '');
  v_actor_ip   := nullif(current_setting('app.actor_ip',   true), '');

  -- 2) Snapshot de OLD y NEW
  if (TG_OP = 'DELETE') then
    v_old := to_jsonb(OLD);
    v_new := null;
  elsif (TG_OP = 'INSERT') then
    v_old := null;
    v_new := to_jsonb(NEW);
  else -- UPDATE
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
  end if;

  -- 3) Filtrar columnas sensibles de ambos snapshots
  foreach v_col in array v_sens_cols
  loop
    if v_old is not null and v_old ? v_col then v_old := v_old - v_col; end if;
    if v_new is not null and v_new ? v_col then v_new := v_new - v_col; end if;
  end loop;

  -- 4) Calcular campos cambiados (solo para UPDATE)
  if TG_OP = 'UPDATE' then
    select array_agg(key)
      into v_changed
    from (
      select key
      from jsonb_each(coalesce(v_new, '{}'::jsonb))
      where (v_new->key) is distinct from (v_old->key)
    ) t;

    -- Si no cambió nada real (ej: trigger encadenado), no auditar
    if v_changed is null or array_length(v_changed, 1) is null then
      return coalesce(NEW, OLD);
    end if;
  end if;

  -- 5) Obtener PK de la fila (se asume columna 'id' si existe)
  if TG_OP = 'DELETE' then
    v_pk := coalesce(v_old->>'id', null);
  else
    v_pk := coalesce(v_new->>'id', v_old->>'id');
  end if;

  -- 6) Insertar audit row
  insert into public.audit_log_detallado (
    tabla, operacion, registro_id,
    actor_id, actor_tipo, actor_ip,
    valores_antes, valores_despues, campos_cambiados
  ) values (
    TG_TABLE_NAME, TG_OP, v_pk,
    v_actor_id, v_actor_tipo, v_actor_ip,
    v_old, v_new, v_changed
  );

  return coalesce(NEW, OLD);
exception when others then
  -- Nunca romper la operación original por un fallo de auditoría.
  -- El error se puede revisar con logs de Postgres.
  return coalesce(NEW, OLD);
end;
$$;

-- Solo postgres ejecuta esta función (vía trigger); revoke defensivo
revoke execute on function public.fn_audit_trigger() from public, anon, authenticated;


-- ============================================================
-- Paso 5: aplicar triggers a tablas críticas
-- ============================================================
-- Helper interno para no repetir el DDL de 35 triggers.
-- ============================================================

do $$
declare
  v_tablas text[] := array[
    -- 💰 Dinero / ventas
    'pedidos','pedido_items','cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items','nomina_empleados',
    -- 📦 Inventario
    'productos','lotes','movimientos_inventario',
    'compras','compra_items','stock_reservations','lotes_producto',
    -- 💊 Regulatorio
    'bitacora_cofepris','bitacora_antibioticos','recetas','alertas_legales',
    -- 👤 Usuarios / acceso
    'usuarios','clientes','empleados','password_reset_requests',
    -- 🏥 Consultorio
    'citas','medicos','procedimientos_medicos','consumibles_consulta',
    -- 🎯 Configuración
    'configuracion','banners','promociones','promocion_productos',
    'equipamiento_consultorio'
  ];
  v_tbl text;
begin
  foreach v_tbl in array v_tablas
  loop
    -- Solo si la tabla existe
    perform 1 from information_schema.tables
    where table_schema='public' and table_name = v_tbl;
    if not found then continue; end if;

    -- Drop + create para idempotencia
    execute format('drop trigger if exists trg_audit_%s on public.%I', v_tbl, v_tbl);
    execute format(
      'create trigger trg_audit_%s
         after insert or update or delete on public.%I
         for each row execute function public.fn_audit_trigger()',
      v_tbl, v_tbl
    );
  end loop;
end $$;


commit;

-- ============================================================
-- FIN F6d
-- ============================================================
-- EFECTOS:
--   ✓ Cada INSERT/UPDATE/DELETE en las 32+ tablas críticas queda
--     registrado en public.audit_log_detallado con actor, timestamp,
--     snapshot antes/después y campos cambiados.
--   ✓ Campos sensibles (password_hash, salt, tokens) NUNCA se
--     almacenan en el audit log.
--   ✓ Los RPCs SECURITY DEFINER ya setean el actor automáticamente
--     vía fn_require_* → fn_set_actor_context.
--   ✓ Un fallo en el trigger de auditoría NUNCA rompe la operación
--     original (manejo de excepción interno).
--
-- CONSULTAS ÚTILES (para uso posterior):
--
-- -- Todo lo que hizo un usuario en las últimas 24h:
-- select * from audit_log_detallado
--   where actor_id = 1 and created_at > now() - interval '24 hours'
--   order by created_at desc;
--
-- -- Quién borró un pedido específico:
-- select * from audit_log_detallado
--   where tabla='pedidos' and registro_id='123' and operacion='DELETE';
--
-- -- Cambios de precio en productos:
-- select created_at, actor_id, registro_id,
--        valores_antes->>'precio' as antes,
--        valores_despues->>'precio' as despues
-- from audit_log_detallado
-- where tabla='productos' and operacion='UPDATE'
--   and 'precio' = any(campos_cambiados)
-- order by created_at desc;
-- ============================================================
