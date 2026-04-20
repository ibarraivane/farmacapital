-- ============================================================
-- FARMAX — Diagnóstico consolidado del trigger
-- ============================================================
-- Retorna UNA SOLA tabla con todas las pistas: existencia de
-- función, existencia de trigger, y prueba de disparo sobre
-- Paracetamol (id 99). Auto-revierte los cambios al final.
-- ============================================================

-- Temp table para acumular resultados
drop table if exists _diag;
create temp table _diag (
  seccion     text,
  item        text,
  detalle_1   text,
  detalle_2   text
) on commit drop;

-- ---- Seccion A: ¿Existe la función? ----
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'A_funcion',
  proname,
  case when prosecdef then 'SECURITY DEFINER' else 'SECURITY INVOKER' end,
  pg_get_function_identity_arguments(oid)
from pg_proc
where proname = 'fn_sync_productos_stock';

-- Si no existe, dejar un marcador
insert into _diag (seccion, item, detalle_1, detalle_2)
select 'A_funcion', '(no existe)', null, null
where not exists (
  select 1 from pg_proc where proname = 'fn_sync_productos_stock'
);

-- ---- Seccion B: ¿Existe el trigger? ----
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'B_trigger',
  tgname,
  tgrelid::regclass::text,
  case tgenabled
    when 'O' then 'ENABLED (O)'
    when 'D' then 'DISABLED (D)'
    when 'R' then 'REPLICA (R)'
    when 'A' then 'ALWAYS (A)'
    else tgenabled::text
  end
from pg_trigger
where tgname = 'trg_sync_productos_stock';

insert into _diag (seccion, item, detalle_1, detalle_2)
select 'B_trigger', '(no existe)', null, null
where not exists (
  select 1 from pg_trigger where tgname = 'trg_sync_productos_stock'
);

-- ---- Seccion C: Prueba viva sobre Paracetamol (id 99) ----

-- Estado inicial
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'C_prueba', '1_inicial',
  'productos.stock=' || p.stock::text,
  'sum(lotes)=' || coalesce((
    select sum(cantidad_actual)::text from public.lotes
    where producto_id = 99 and coalesce(activo, true) = true
  ), '0')
from public.productos p
where p.id = 99;

-- Aplicar +3 al primer lote activo de Paracetamol
update public.lotes
set cantidad_actual = cantidad_actual + 3
where id = (
  select id from public.lotes
  where producto_id = 99 and coalesce(activo, true) = true
  order by id limit 1
);

-- Estado después del update
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'C_prueba', '2_despues_update',
  'productos.stock=' || p.stock::text,
  'sum(lotes)=' || coalesce((
    select sum(cantidad_actual)::text from public.lotes
    where producto_id = 99 and coalesce(activo, true) = true
  ), '0')
from public.productos p
where p.id = 99;

-- Revertir −3
update public.lotes
set cantidad_actual = cantidad_actual - 3
where id = (
  select id from public.lotes
  where producto_id = 99 and coalesce(activo, true) = true
  order by id limit 1
);

-- Estado final (debe coincidir con inicial)
insert into _diag (seccion, item, detalle_1, detalle_2)
select
  'C_prueba', '3_final',
  'productos.stock=' || p.stock::text,
  'sum(lotes)=' || coalesce((
    select sum(cantidad_actual)::text from public.lotes
    where producto_id = 99 and coalesce(activo, true) = true
  ), '0')
from public.productos p
where p.id = 99;

-- ---- Resultado final ----
select * from _diag order by seccion, item;
