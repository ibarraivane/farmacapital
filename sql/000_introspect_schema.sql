-- ============================================================
-- FARMAX — Introspección del esquema Supabase
-- ============================================================
-- Correr en el SQL Editor de Supabase y pegar TODOS los resultados
-- (cada query devuelve una tabla). Esto alimenta las siguientes fases
-- del refactor para que trabajen con el esquema REAL, no con supuestos.
--
-- No modifica nada. Solo lectura.
-- ============================================================

-- 1) Tablas públicas y conteo aproximado de filas
select
  c.relname               as tabla,
  c.reltuples::bigint     as filas_aprox
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r'
order by c.relname;

-- 2) Columnas por tabla (tipo, nullable, default)
select
  table_name,
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'public'
order by table_name, ordinal_position;

-- 3) Primary keys y unique constraints
select
  tc.table_name,
  tc.constraint_type,
  tc.constraint_name,
  string_agg(kcu.column_name, ', ' order by kcu.ordinal_position) as columnas
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  using (constraint_schema, constraint_name, table_schema, table_name)
where tc.table_schema = 'public'
  and tc.constraint_type in ('PRIMARY KEY', 'UNIQUE')
group by tc.table_name, tc.constraint_type, tc.constraint_name
order by tc.table_name, tc.constraint_type;

-- 4) Foreign keys
select
  tc.table_name                    as tabla,
  kcu.column_name                  as columna,
  ccu.table_name                   as referencia_tabla,
  ccu.column_name                  as referencia_columna,
  rc.update_rule,
  rc.delete_rule
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  using (constraint_schema, constraint_name, table_schema, table_name)
join information_schema.referential_constraints rc
  on rc.constraint_name = tc.constraint_name
 and rc.constraint_schema = tc.constraint_schema
join information_schema.constraint_column_usage ccu
  on ccu.constraint_name = tc.constraint_name
 and ccu.constraint_schema = tc.constraint_schema
where tc.table_schema = 'public'
  and tc.constraint_type = 'FOREIGN KEY'
order by tc.table_name, kcu.column_name;

-- 5) Índices
select
  tablename,
  indexname,
  indexdef
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;

-- 6) RLS (row-level security) habilitado por tabla
select
  schemaname,
  tablename,
  rowsecurity as rls_activado
from pg_tables
where schemaname = 'public'
order by tablename;

-- 7) Políticas RLS existentes
select
  schemaname,
  tablename,
  policyname,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
order by tablename, policyname;

-- 8) Triggers definidos
select
  event_object_table  as tabla,
  trigger_name,
  event_manipulation  as evento,
  action_timing       as timing,
  action_statement
from information_schema.triggers
where trigger_schema = 'public'
order by event_object_table, trigger_name;

-- 9) Funciones / RPCs definidas por el usuario
select
  p.proname             as funcion,
  pg_get_function_arguments(p.oid) as argumentos,
  pg_get_function_result(p.oid)    as retorna,
  l.lanname             as lenguaje
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_language l  on l.oid = p.prolang
where n.nspname = 'public'
  and p.prokind  = 'f'
order by p.proname;

-- 10) Vistas existentes
select table_name, view_definition
from information_schema.views
where table_schema = 'public'
order by table_name;
