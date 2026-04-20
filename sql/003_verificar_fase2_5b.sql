-- ============================================================
-- FARMAX — Verificación Fase 2.5b (trigger de stock)
-- ============================================================

-- 1) ¿Quedó instalado el trigger?
select
  tgname                as trigger_name,
  tgrelid::regclass     as tabla,
  tgenabled             as habilitado,
  pg_get_triggerdef(oid) as definicion
from pg_trigger
where tgname = 'trg_sync_productos_stock';

-- 2) Prueba viva SEGURA con ROLLBACK — confirma que el trigger funciona
--    sin dejar cambios en la base.
--
-- Ejecutar TODO este bloque como una sola operación
-- (desde "begin;" hasta "rollback;" incluidos).

begin;

  -- Producto de prueba: el primero con stock > 0 y al menos un lote activo
  with t as (
    select p.id
    from public.productos p
    where p.stock > 0
      and exists (
        select 1 from public.lotes l
        where l.producto_id = p.id and coalesce(l.activo, true) = true
      )
    order by p.id
    limit 1
  )
  select
    'antes' as momento,
    p.id,
    p.nombre,
    p.stock as productos_stock,
    (select coalesce(sum(cantidad_actual), 0)
       from public.lotes
      where producto_id = p.id and coalesce(activo, true) = true
    ) as suma_lotes
  from public.productos p
  where p.id = (select id from t);

  -- Cambio: +7 al primer lote activo de ese producto
  update public.lotes
  set cantidad_actual = cantidad_actual + 7
  where id = (
    select l.id
    from public.lotes l
    join public.productos p on p.id = l.producto_id
    where p.stock > 0
      and coalesce(l.activo, true) = true
    order by p.id, l.id
    limit 1
  );

  -- Verificar
  select
    'despues' as momento,
    p.id,
    p.nombre,
    p.stock as productos_stock,
    (select coalesce(sum(cantidad_actual), 0)
       from public.lotes
      where producto_id = p.id and coalesce(activo, true) = true
    ) as suma_lotes
  from public.productos p
  where p.id = (
    select pp.id from public.productos pp
    where pp.stock > 0
      and exists (
        select 1 from public.lotes l2
        where l2.producto_id = pp.id and coalesce(l2.activo, true) = true
      )
    order by pp.id
    limit 1
  );

rollback;

-- Si en el 'despues' ves productos_stock = suma_lotes (ambos con los +7),
-- el trigger funciona. Como es rollback, la base queda igual.
