-- ============================================================
-- DIAGNÓSTICO URGENTE — firma de registrar_corte_caja
-- Sólo lee. Pegar en Supabase → SQL Editor → Run.
--
-- El error de la tablet:
--   Could not find the function public.registrar_corte_caja(
--     p_confirmar, p_contado_por, …)
-- significa que PostgREST no ve una función con p_confirmar.
--
-- Firma correcta (desde 24-ago-2026, cadena continua): 14 args,
-- el último es p_confirmar boolean.
--
-- Causa típica de romperla: re-pegar
--   sql/patch_corte_electronicos_servidor.sql
-- Ese archivo BORRA cualquier overload que no tenga exactamente
-- 13 argumentos y recrea la firma vieja SIN p_confirmar.
-- ============================================================

-- 1) ¿Qué firmas están vivas?
select
  p.oid::regprocedure as firma,
  p.pronargs as num_args,
  pg_get_function_identity_arguments(p.oid) as argumentos
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname = 'registrar_corte_caja'
order by p.pronargs;

-- Esperado: UNA fila, num_args = 14, y "p_confirmar boolean" al final.
-- Si num_args = 13 o 0 filas → la tablet no puede guardar cortes.

-- 2) ¿Siguen los helpers de cadena continua?
select p.proname
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'fn_ventana_corte',
    'reconcile_cash_rango',
    'fn_sumar_denominaciones',
    'fn_corte_previo_at',
    'anular_corte_caja'
  )
order by 1;

-- Si falta alguno → hay que reaplicar TODO
-- sql/patch_caja_cadena_continua_20260824.sql (no un parche parcial).
