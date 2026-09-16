-- Runbook: ¿qué cliente_crear_pedido_online está viva en Supabase?
--
-- En el repo hay varios CREATE OR REPLACE de la misma firma. La que DEBE
-- estar aplicada es sql/patch_pedido_online_permite_receta_20260915.sql:
-- medicamentos con receta SÍ se venden en línea; controlados NO.
--
-- sql/refactor_fase6b_rpcs_tienda.sql es MÁS VIEJA y RECHAZA requiere_receta.
-- Si alguien la re-ejecuta, el checkout de recetas se rompe. No tocar
-- cliente_crear_pedido_online en el flujo de bajo pedido
-- (ese usa cliente_crear_pedido_bajo_pedido).
--
-- En Supabase → SQL Editor:

select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args,
  pg_get_functiondef(p.oid) like '%requiere receta médica y no puede venderse online%' as es_version_fase6b_que_bloquea_rx,
  pg_get_functiondef(p.oid) like '%requiere_receta: permitido%' as es_version_20260915_que_permite_rx,
  pg_get_functiondef(p.oid) like '%controlado%' as menciona_controlado
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'cliente_crear_pedido_online';

-- Esperado: es_version_fase6b_que_bloquea_rx = false
--           es_version_20260915_que_permite_rx = true
-- Si la primera sale true: volver a correr
--   sql/patch_pedido_online_permite_receta_20260915.sql
