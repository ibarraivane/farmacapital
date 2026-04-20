-- ============================================================
-- FARMAX — F6e: Inmutabilidad de los logs de auditoría
-- ============================================================
-- Objetivo: `audit_log` y `audit_log_detallado` deben ser
-- append-only. Nadie (ni admin, ni service_role, ni usuarios
-- con JWT) puede modificar ni borrar registros.
--
-- Estrategia en 3 capas:
--   1. REVOKE ALL a anon/authenticated/service_role excepto:
--      - audit_log_detallado: nada (solo SELECT vía RPC futura)
--      - audit_log: nada (solo SELECT vía RPC futura)
--   2. Los triggers (fn_audit_trigger) y las RPCs con
--      SECURITY DEFINER corren como postgres y hacen INSERT,
--      así que no les afecta el REVOKE.
--   3. Trigger BEFORE UPDATE/DELETE/TRUNCATE que lanza
--      excepción incluso al dueño (postgres). La única forma
--      de modificar es:
--        set local app.audit_bypass = 'true';
--      en una transacción de mantenimiento (auditable en pgaudit
--      si lo activas en Supabase).
--
-- También crea 2 RPCs de lectura para el dashboard futuro
-- (F-C: "dashboard básico de auditoría"):
--   • admin_listar_audit_log_detallado(filtros, limit, offset)
--   • admin_listar_audit_log(filtros, limit, offset)
--
-- IDEMPOTENTE: se puede re-ejecutar sin efectos colaterales.
-- ============================================================

begin;

-- ============================================================
-- Paso 1: asegurar que las tablas existan (defensivo)
-- ============================================================
-- audit_log_detallado ya fue creada en F6d. audit_log es legacy
-- y la usan varias RPCs; si no existe, la creamos mínima.
-- ============================================================

create table if not exists public.audit_log (
  id              bigserial primary key,
  usuario_id      bigint,
  usuario_nombre  text,
  accion          text,
  tabla           text,
  registro_id     text,
  detalle         text,
  created_at      timestamptz not null default now()
);

-- Índices útiles para el dashboard (idempotentes)
create index if not exists idx_audit_log_tabla_created
  on public.audit_log (tabla, created_at desc);
create index if not exists idx_audit_log_usuario_created
  on public.audit_log (usuario_id, created_at desc);
create index if not exists idx_audit_log_created
  on public.audit_log (created_at desc);


-- ============================================================
-- Paso 2: Capa 1 + 2 — REVOKE total salvo SELECT controlado
-- ============================================================
-- - Ningún rol REST (anon/authenticated) puede hacer nada
--   directo sobre estas tablas.
-- - service_role NO puede insertar/modificar/borrar; solo SELECT
--   (por si necesitas exportarlas para backup). Las RPCs
--   SECURITY DEFINER corren como postgres y siguen pudiendo
--   hacer INSERT.
-- ============================================================

revoke all on public.audit_log_detallado from public;
revoke all on public.audit_log_detallado from anon, authenticated;

revoke all on public.audit_log from public;
revoke all on public.audit_log from anon, authenticated;

-- service_role en Supabase bypassea RLS. Le quitamos escritura
-- pero le dejamos SELECT para backup/análisis externo.
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    execute 'revoke all on public.audit_log_detallado from service_role';
    execute 'grant select on public.audit_log_detallado to service_role';
    execute 'revoke all on public.audit_log from service_role';
    execute 'grant select on public.audit_log to service_role';
  end if;
end $$;


-- ============================================================
-- Paso 3: Capa 3 — Trigger de inmutabilidad
-- ============================================================
-- Rechaza UPDATE/DELETE/TRUNCATE incluso al dueño (postgres),
-- salvo que la sesión haya seteado explícitamente:
--   set local app.audit_bypass = 'true';
-- dentro de una transacción (scope LOCAL, no persiste).
-- ============================================================

create or replace function public.fn_audit_log_immutable()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_bypass text;
begin
  -- GUC puede no estar seteada; el segundo arg "true" evita error
  v_bypass := current_setting('app.audit_bypass', true);

  if v_bypass = 'true' then
    -- bypass autorizado (mantenimiento manual, documentado)
    if tg_op = 'DELETE' then return old; end if;
    return new;
  end if;

  raise exception
    'audit_log es inmutable: operación % bloqueada en %. '
    'Para mantenimiento excepcional use: SET LOCAL app.audit_bypass = ''true'';',
    tg_op, tg_table_name
    using errcode = 'insufficient_privilege';
end;
$$;

revoke all on function public.fn_audit_log_immutable() from public;


-- Version FOR EACH STATEMENT para TRUNCATE (no tiene OLD/NEW)
create or replace function public.fn_audit_log_immutable_stmt()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_bypass text;
begin
  v_bypass := current_setting('app.audit_bypass', true);
  if v_bypass = 'true' then
    return null;
  end if;
  raise exception
    'audit_log es inmutable: TRUNCATE bloqueado en %. '
    'Para mantenimiento excepcional use: SET LOCAL app.audit_bypass = ''true'';',
    tg_table_name
    using errcode = 'insufficient_privilege';
end;
$$;

revoke all on function public.fn_audit_log_immutable_stmt() from public;


-- Aplicar triggers en audit_log_detallado
drop trigger if exists trg_audit_det_immutable_row on public.audit_log_detallado;
create trigger trg_audit_det_immutable_row
  before update or delete on public.audit_log_detallado
  for each row execute function public.fn_audit_log_immutable();

drop trigger if exists trg_audit_det_immutable_trunc on public.audit_log_detallado;
create trigger trg_audit_det_immutable_trunc
  before truncate on public.audit_log_detallado
  for each statement execute function public.fn_audit_log_immutable_stmt();


-- Aplicar triggers en audit_log (legacy)
drop trigger if exists trg_audit_log_immutable_row on public.audit_log;
create trigger trg_audit_log_immutable_row
  before update or delete on public.audit_log
  for each row execute function public.fn_audit_log_immutable();

drop trigger if exists trg_audit_log_immutable_trunc on public.audit_log;
create trigger trg_audit_log_immutable_trunc
  before truncate on public.audit_log
  for each statement execute function public.fn_audit_log_immutable_stmt();


-- ============================================================
-- Paso 4: RPC de lectura para dashboard (admin-only)
-- ============================================================
-- Filtros opcionales (todos pueden ser NULL):
--   p_tabla         → filtra por nombre de tabla exacta
--   p_operacion     → INSERT | UPDATE | DELETE
--   p_actor_id      → filtra por actor
--   p_desde, p_hasta → rango de created_at
--   p_search        → busca substring en valores_antes/despues/campos_cambiados
-- Orden: created_at desc.
-- Paginación: limit/offset.
-- ============================================================

create or replace function public.admin_listar_audit_log_detallado(
  p_session_token uuid,
  p_tabla         text default null,
  p_operacion     text default null,
  p_actor_id      bigint default null,
  p_desde         timestamptz default null,
  p_hasta         timestamptz default null,
  p_search        text default null,
  p_limit         int default 100,
  p_offset        int default 0
)
returns table (
  id               bigint,
  tabla            text,
  operacion        text,
  registro_id      text,
  actor_id         bigint,
  actor_tipo       text,
  actor_ip         text,
  valores_antes    jsonb,
  valores_despues  jsonb,
  campos_cambiados text[],
  created_at       timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_limit  int := least(greatest(coalesce(p_limit, 100), 1), 1000);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  perform public.fn_require_admin(p_session_token);

  return query
  select a.id, a.tabla, a.operacion, a.registro_id, a.actor_id,
         a.actor_tipo, a.actor_ip, a.valores_antes, a.valores_despues,
         a.campos_cambiados, a.created_at
  from public.audit_log_detallado a
  where (p_tabla     is null or a.tabla = p_tabla)
    and (p_operacion is null or a.operacion = upper(p_operacion))
    and (p_actor_id  is null or a.actor_id = p_actor_id)
    and (p_desde     is null or a.created_at >= p_desde)
    and (p_hasta     is null or a.created_at <= p_hasta)
    and (p_search    is null or p_search = ''
         or a.valores_antes::text   ilike '%' || p_search || '%'
         or a.valores_despues::text ilike '%' || p_search || '%'
         or array_to_string(a.campos_cambiados, ',') ilike '%' || p_search || '%')
  order by a.created_at desc, a.id desc
  limit v_limit offset v_offset;
end;
$$;

grant execute on function public.admin_listar_audit_log_detallado(
  uuid, text, text, bigint, timestamptz, timestamptz, text, int, int
) to anon, authenticated;


-- RPC de conteo (para paginación en UI)
create or replace function public.admin_contar_audit_log_detallado(
  p_session_token uuid,
  p_tabla         text default null,
  p_operacion     text default null,
  p_actor_id      bigint default null,
  p_desde         timestamptz default null,
  p_hasta         timestamptz default null,
  p_search        text default null
)
returns bigint
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_total bigint;
begin
  perform public.fn_require_admin(p_session_token);

  select count(*) into v_total
  from public.audit_log_detallado a
  where (p_tabla     is null or a.tabla = p_tabla)
    and (p_operacion is null or a.operacion = upper(p_operacion))
    and (p_actor_id  is null or a.actor_id = p_actor_id)
    and (p_desde     is null or a.created_at >= p_desde)
    and (p_hasta     is null or a.created_at <= p_hasta)
    and (p_search    is null or p_search = ''
         or a.valores_antes::text   ilike '%' || p_search || '%'
         or a.valores_despues::text ilike '%' || p_search || '%'
         or array_to_string(a.campos_cambiados, ',') ilike '%' || p_search || '%');

  return v_total;
end;
$$;

grant execute on function public.admin_contar_audit_log_detallado(
  uuid, text, text, bigint, timestamptz, timestamptz, text
) to anon, authenticated;


-- RPC legacy (audit_log textual)
create or replace function public.admin_listar_audit_log(
  p_session_token uuid,
  p_tabla         text default null,
  p_accion        text default null,
  p_usuario_id    bigint default null,
  p_desde         timestamptz default null,
  p_hasta         timestamptz default null,
  p_search        text default null,
  p_limit         int default 100,
  p_offset        int default 0
)
returns table (
  id             bigint,
  usuario_id     bigint,
  usuario_nombre text,
  accion         text,
  tabla          text,
  registro_id    text,
  detalle        text,
  created_at     timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_limit  int := least(greatest(coalesce(p_limit, 100), 1), 1000);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  perform public.fn_require_admin(p_session_token);

  return query
  select a.id, a.usuario_id, a.usuario_nombre, a.accion, a.tabla,
         a.registro_id, a.detalle, a.created_at
  from public.audit_log a
  where (p_tabla      is null or a.tabla = p_tabla)
    and (p_accion     is null or a.accion ilike p_accion)
    and (p_usuario_id is null or a.usuario_id = p_usuario_id)
    and (p_desde      is null or a.created_at >= p_desde)
    and (p_hasta      is null or a.created_at <= p_hasta)
    and (p_search     is null or p_search = ''
         or a.detalle ilike '%' || p_search || '%'
         or a.usuario_nombre ilike '%' || p_search || '%')
  order by a.created_at desc, a.id desc
  limit v_limit offset v_offset;
end;
$$;

grant execute on function public.admin_listar_audit_log(
  uuid, text, text, bigint, timestamptz, timestamptz, text, int, int
) to anon, authenticated;


commit;

-- ============================================================
-- Verificación rápida (correr por separado):
-- ============================================================
-- 1) Verificar grants revocados:
--    select grantee, privilege_type
--    from information_schema.role_table_grants
--    where table_schema = 'public'
--      and table_name in ('audit_log','audit_log_detallado')
--    order by table_name, grantee;
--
-- 2) Verificar triggers instalados:
--    select trigger_name, event_manipulation, event_object_table
--    from information_schema.triggers
--    where event_object_schema = 'public'
--      and event_object_table in ('audit_log','audit_log_detallado')
--      and trigger_name like '%immutable%'
--    order by event_object_table, trigger_name;
--
-- 3) Probar inmutabilidad (debe fallar):
--    update public.audit_log_detallado set tabla = 'hack' where id = 1;
--    delete from public.audit_log_detallado where id = 1;
--
-- 4) Probar bypass documentado (debe funcionar):
--    begin;
--      set local app.audit_bypass = 'true';
--      -- operación de mantenimiento...
--    commit;
-- ============================================================
