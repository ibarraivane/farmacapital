-- ============================================================================
-- DIAGNÓSTICO DE RENDIMIENTO · SOLO LECTURA · 24-sep-2026
-- Pegar en Supabase → SQL Editor. Corre cada bloque por separado y guarda los
-- resultados. No modifica nada.
-- ============================================================================

-- 1) Tamaño de las tablas que más se escriben
select relname as tabla,
       n_live_tup as filas_aprox,
       pg_size_pretty(pg_total_relation_size(relid)) as tamano_total,
       pg_size_pretty(pg_indexes_size(relid)) as tamano_indices
from pg_stat_user_tables
where relname in ('audit_log_detallado','productos','lotes','pedidos','pedido_items',
                  'movimientos_inventario','sesiones','rappi_sync_queue','producto_imagenes')
order by pg_total_relation_size(relid) desc;

-- 2) Auditoría: filas por tabla y por día (¿cuánto ruido mete productos/lotes?)
select tabla, operacion, count(*) as filas
from public.audit_log_detallado
where created_at > now() - interval '7 days'
group by 1,2 order by 3 desc limit 20;

-- 3) De las auditorías de productos, ¿cuántas cambiaron SOLO stock/updated_at?
select count(*) filter (where campos_cambiados <@ array['stock','updated_at']) as solo_stock,
       count(*) as total
from public.audit_log_detallado
where tabla = 'productos' and operacion = 'UPDATE'
  and created_at > now() - interval '7 days';

-- 4) Índices que deben existir (los del repo se crean en bloques condicionales)
select tablename, indexname, indexdef
from pg_indexes
where schemaname = 'public'
  and tablename in ('productos','lotes','pedido_items','pedidos','sesiones')
order by tablename, indexname;

-- 5) Triggers activos en las tablas calientes
select c.relname as tabla, t.tgname as trigger, t.tgenabled as activo,
       pg_get_triggerdef(t.oid) as definicion
from pg_trigger t join pg_class c on c.oid = t.tgrelid
where not t.tgisinternal
  and c.relname in ('productos','lotes','pedidos','pedido_items','movimientos_inventario')
order by 1,2;

-- 6) Consultas más lentas (requiere pg_stat_statements; en Supabase suele estar activo)
select round(total_exec_time::numeric/1000,1) as seg_totales,
       calls,
       round(mean_exec_time::numeric,1) as ms_promedio,
       round(max_exec_time::numeric,1) as ms_max,
       left(regexp_replace(query, '\s+', ' ', 'g'), 140) as consulta
from pg_stat_statements
order by total_exec_time desc
limit 20;

-- 7) Las que más pesan por ejecución (RPCs del POS)
select calls, round(mean_exec_time::numeric,1) as ms_promedio,
       round(max_exec_time::numeric,1) as ms_max,
       left(regexp_replace(query, '\s+', ' ', 'g'), 140) as consulta
from pg_stat_statements
where query ilike any (array['%empleado_listar_productos_con_lotes_pos%',
                             '%empleado_listar_lotes_inventario%',
                             '%create_sale_transaction%',
                             '%fn_validar_token_empleado%',
                             '%empleado_precios_especiales_caducidad%'])
order by mean_exec_time desc limit 10;

-- 8) Peso del catálogo que baja el POS en cada refresco completo
select count(*) as productos_activos,
       pg_size_pretty(sum(pg_column_size(p.*))::bigint) as tamano_aprox_filas
from public.productos p
where coalesce(p.activo, true);

-- 9) Escrituras muertas / mantenimiento pendiente
select relname, n_dead_tup, n_live_tup, last_autovacuum, last_autoanalyze
from pg_stat_user_tables
where relname in ('productos','lotes','audit_log_detallado','pedidos','pedido_items')
order by n_dead_tup desc;

-- 10) ¿Existe la política de purga/retención de audit_log_detallado?
select count(*) as filas_mas_de_180_dias
from public.audit_log_detallado
where created_at < now() - interval '180 days';
