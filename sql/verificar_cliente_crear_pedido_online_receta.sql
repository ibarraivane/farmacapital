-- Runbook: ¿qué cliente_crear_pedido_online está viva en Supabase?
--
-- Encargos usan cliente_crear_pedido_bajo_pedido.
-- Anaquel usa cliente_crear_pedido_online: Rx permitido, controlados no,
-- y el total con fc_precio_online_mp (patch_pedido_online_precio_mp_20260916.sql).
--
-- sql/refactor_fase6b_rpcs_tienda.sql RECHAZA receta: no re-ejecutar ese bloque.

select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args,
  pg_get_functiondef(p.oid) like '%requiere receta médica y no puede venderse online%' as es_version_fase6b_que_bloquea_rx,
  pg_get_functiondef(p.oid) like '%requiere_receta: permitido%' as permite_rx,
  pg_get_functiondef(p.oid) like '%fc_precio_online_mp%' as cobra_precio_web_mp
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'cliente_crear_pedido_online';

-- Esperado en todas las firmas:
--   es_version_fase6b_que_bloquea_rx = false
--   permite_rx = true
--   cobra_precio_web_mp = true
-- Si no: correr sql/patch_pedido_online_precio_mp_20260916.sql
-- (incluye Rx + precio web). Si aún bloquea Rx, primero
-- sql/patch_pedido_online_permite_receta_20260915.sql y luego el de precio.
