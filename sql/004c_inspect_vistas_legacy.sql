-- ============================================================
-- FARMAX — Inspección previa al DROP F4b
-- ============================================================
-- Lista TODAS las vistas que dependen de columnas legacy que
-- vamos a eliminar: pedido_items.lote, pedido_items.caducidad,
-- productos.lote, productos.fecha_caducidad, lotes.proveedor.
--
-- Usa el resultado para decidir si la vista se:
--   (a) reconstruye con JOIN a lotes (ideal)
--   (b) se elimina si ya no aporta valor
-- ============================================================

-- 1) Vistas que referencian alguna columna legacy
select
  n.nspname                   as esquema,
  c.relname                   as vista,
  pg_get_viewdef(c.oid, true) as definicion
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'v'
  and n.nspname = 'public'
  and (
       pg_get_viewdef(c.oid, true) ilike '%pedido_items%lote%'
    or pg_get_viewdef(c.oid, true) ilike '%pedido_items%caducidad%'
    or pg_get_viewdef(c.oid, true) ilike '%productos%lote%'
    or pg_get_viewdef(c.oid, true) ilike '%productos%fecha_caducidad%'
    or pg_get_viewdef(c.oid, true) ilike '%lotes%proveedor%'
  )
order by c.relname;

-- 2) Dependencias directas por columna (más preciso)
select
  dependent_ns.nspname as esquema_dep,
  dependent_view.relname as objeto_dependiente,
  dependent_view.relkind as tipo,       -- 'v'=view, 'm'=matview, 'r'=table
  source_table.relname as tabla_fuente,
  pg_attribute.attname as columna_fuente
from pg_depend
join pg_rewrite         on pg_depend.objid       = pg_rewrite.oid
join pg_class as dependent_view on pg_rewrite.ev_class  = dependent_view.oid
join pg_namespace as dependent_ns on dependent_view.relnamespace = dependent_ns.oid
join pg_class as source_table    on pg_depend.refobjid = source_table.oid
join pg_attribute               on pg_depend.refobjid  = pg_attribute.attrelid
                               and pg_depend.refobjsubid = pg_attribute.attnum
where source_table.relname in ('pedido_items','productos','lotes')
  and pg_attribute.attname in ('lote','caducidad','fecha_caducidad','proveedor')
  and dependent_view.relname <> source_table.relname
order by dependent_view.relname, source_table.relname, pg_attribute.attname;
