-- ============================================================
-- FARMAX — Verificación F6d (Auditoría detallada con triggers)
-- ============================================================
-- Tras ejecutar refactor_fase6d_audit_triggers.sql, este script
-- valida que:
--   1. Tabla audit_log_detallado exista con todas las columnas.
--   2. Funciones fn_set_actor_context, fn_audit_trigger,
--      fn_require_admin/empleado/cliente actualizadas.
--   3. Triggers creados en las 32+ tablas críticas.
--   4. Campos sensibles filtrados correctamente (smoke test opcional).
-- ============================================================

-- ============================================================
-- 1. Tabla audit_log_detallado: columnas esperadas
-- ============================================================
with esperadas as (
  select unnest(array[
    'id','tabla','operacion','registro_id',
    'actor_id','actor_tipo','actor_ip',
    'valores_antes','valores_despues','campos_cambiados',
    'created_at'
  ]) as col
)
select
  e.col,
  case when c.column_name is null then '⚠ FALTA' else '✓' end as estado,
  c.data_type
from esperadas e
left join information_schema.columns c
  on c.table_schema='public'
 and c.table_name='audit_log_detallado'
 and c.column_name = e.col
order by e.col;
-- ESPERADO: todas con estado ✓.


-- ============================================================
-- 2. Índices sobre audit_log_detallado
-- ============================================================
select
  indexname,
  case when indexname is null then '⚠' else '✓' end as estado
from pg_indexes
where schemaname='public' and tablename='audit_log_detallado'
order by indexname;
-- ESPERADO: al menos idx_audit_det_tabla_created, idx_audit_det_actor_created,
-- idx_audit_det_registro, idx_audit_det_created + PK.


-- ============================================================
-- 3. Funciones clave existen y tienen search_path fijo
-- ============================================================
with funcs as (
  select unnest(array[
    'fn_set_actor_context',
    'fn_audit_trigger',
    'fn_require_admin',
    'fn_require_empleado',
    'fn_require_cliente'
  ]) as fname
)
select
  f.fname,
  p.prosecdef as security_definer,
  array_to_string(p.proconfig, ', ') as config,
  case
    when p.proname is null then '⚠ FALTA'
    when not p.prosecdef then '⚠ SIN SECURITY DEFINER'
    when not exists (select 1 from unnest(coalesce(p.proconfig,array[]::text[])) c where c like 'search_path=%')
         then '⚠ SIN search_path FIJO'
    else '✓'
  end as estado
from funcs f
left join pg_proc p on p.proname = f.fname
  and p.pronamespace = (select oid from pg_namespace where nspname='public')
order by f.fname;
-- ESPERADO: todas con estado ✓.


-- ============================================================
-- 4. Triggers creados en tablas críticas
-- ============================================================
with esperadas as (
  select unnest(array[
    'pedidos','pedido_items','cortes_caja','movimientos_caja',
    'facturas','devoluciones','devolucion_items','nomina_empleados',
    'productos','lotes','movimientos_inventario',
    'compras','compra_items','stock_reservations','lotes_producto',
    'bitacora_cofepris','bitacora_antibioticos','recetas','alertas_legales',
    'usuarios','clientes','empleados','password_reset_requests',
    'citas','medicos','procedimientos_medicos','consumibles_consulta',
    'configuracion','banners','promociones','promocion_productos',
    'equipamiento_consultorio'
  ]) as tbl
)
select
  e.tbl,
  t.tgname as trigger_name,
  case
    when t.tgname is null and exists(
      select 1 from information_schema.tables where table_schema='public' and table_name=e.tbl
    ) then '⚠ SIN TRIGGER (tabla existe)'
    when t.tgname is null then '– (tabla no existe)'
    else '✓'
  end as estado
from esperadas e
left join pg_trigger t
  on t.tgrelid = ('public.'||e.tbl)::regclass
 and t.tgname = 'trg_audit_'||e.tbl
 and not t.tgisinternal
order by e.tbl;
-- ESPERADO: todas ✓ o – (si la tabla no existe en este entorno).


-- ============================================================
-- 5. Grants defensivos sobre helpers internos
-- ============================================================
-- fn_set_actor_context y fn_audit_trigger NO deben tener execute
-- grant para anon/authenticated (solo se llaman internamente).
select
  p.proname,
  r.rolname,
  'ALERTA: grant indebido' as nota
from pg_proc p
cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
join pg_roles r on r.oid = a.grantee
where p.proname in ('fn_set_actor_context','fn_audit_trigger')
  and p.pronamespace = (select oid from pg_namespace where nspname='public')
  and r.rolname in ('anon','authenticated','public')
  and a.privilege_type = 'EXECUTE';
-- ESPERADO: 0 filas.


-- ============================================================
-- 6. Smoke test: insertar y ver si el trigger audita
-- ============================================================
-- NO ejecutar automáticamente. Copiar y correr manualmente:
--
-- -- 1) simular actor
-- select public.fn_set_actor_context(1, 'admin', '127.0.0.1');
--
-- -- 2) tocar una tabla auditada
-- update public.configuracion set valor = valor where clave = 'precio_consulta';
--
-- -- 3) revisar
-- select tabla, operacion, actor_id, actor_tipo, campos_cambiados, created_at
-- from public.audit_log_detallado
-- order by id desc limit 5;


-- ============================================================
-- 7. Estadísticas finales
-- ============================================================
select
  (select count(*) from pg_trigger where tgname like 'trg_audit_%' and not tgisinternal) as triggers_audit,
  (select count(*) from public.audit_log_detallado) as eventos_registrados;
