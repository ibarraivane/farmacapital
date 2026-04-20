-- ============================================================
-- FARMAX — Diagnóstico del trigger fn_sync_productos_stock
-- ============================================================

-- 1) ¿Existe la FUNCIÓN?
select
  proname                            as funcion,
  prosecdef                          as is_security_definer,
  provolatile                        as volatilidad,
  pg_get_function_identity_arguments(oid) as argumentos,
  pg_get_functiondef(oid)            as definicion
from pg_proc
where proname = 'fn_sync_productos_stock';

-- 2) ¿Existe el TRIGGER y sobre qué tabla?
select
  tgname                 as trigger_name,
  tgrelid::regclass      as tabla,
  tgenabled              as habilitado,
  pg_get_triggerdef(oid) as definicion
from pg_trigger
where tgname = 'trg_sync_productos_stock';

-- 3) Prueba directa fuera de sandbox (sin rollback).
--    ESTA PRUEBA MODIFICA DATOS pero los revierte al final manualmente.
--    Usa Paracetamol (id=99) porque ya sabemos que tiene lote.

-- Estado inicial
select
  'inicial'::text        as etapa,
  p.id,
  p.stock                as productos_stock,
  coalesce(
    (select sum(cantidad_actual) from public.lotes
     where producto_id = p.id and coalesce(activo, true) = true),
    0
  )                      as suma_lotes
from public.productos p
where p.id = 99;

-- UPDATE directo al lote de Paracetamol (+3)
update public.lotes
set cantidad_actual = cantidad_actual + 3
where producto_id = 99
  and coalesce(activo, true) = true
  and id = (
    select id from public.lotes
    where producto_id = 99 and coalesce(activo, true) = true
    order by id limit 1
  );

-- Después del UPDATE
select
  'despues_update'::text as etapa,
  p.id,
  p.stock                as productos_stock,
  coalesce(
    (select sum(cantidad_actual) from public.lotes
     where producto_id = p.id and coalesce(activo, true) = true),
    0
  )                      as suma_lotes
from public.productos p
where p.id = 99;

-- Revertir manualmente (−3)
update public.lotes
set cantidad_actual = cantidad_actual - 3
where producto_id = 99
  and coalesce(activo, true) = true
  and id = (
    select id from public.lotes
    where producto_id = 99 and coalesce(activo, true) = true
    order by id limit 1
  );

-- Estado final (debería ser idéntico al inicial)
select
  'final'::text          as etapa,
  p.id,
  p.stock                as productos_stock,
  coalesce(
    (select sum(cantidad_actual) from public.lotes
     where producto_id = p.id and coalesce(activo, true) = true),
    0
  )                      as suma_lotes
from public.productos p
where p.id = 99;
