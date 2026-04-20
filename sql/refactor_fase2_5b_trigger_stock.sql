-- ============================================================
-- FARMAX — Refactor FASE 2.5b: TRIGGER de sincronización
-- ============================================================
-- Objetivo: cada cambio en lotes (INSERT/UPDATE/DELETE) recalcula
-- automáticamente productos.stock = sum(lotes.cantidad_actual).
--
-- Después de esto, productos.stock es un CAMPO DERIVADO / CACHÉ.
-- Deja de ser la "fuente de verdad" (eso pasa a ser lotes).
-- Ningún otro código debería hacer UPDATE directo a productos.stock.
--
-- El trigger maneja:
--   - INSERT: recalcula para new.producto_id
--   - DELETE: recalcula para old.producto_id
--   - UPDATE (normal): recalcula para new.producto_id
--   - UPDATE con cambio de producto_id: recalcula AMBOS productos
--
-- SECURITY DEFINER para que funcione sin importar qué rol dispare
-- la modificación (anon key, service role, autenticado, etc.).
--
-- Idempotente: se puede correr varias veces.
-- ============================================================

begin;

-- -----------------------------------------------
-- Función de recálculo
-- -----------------------------------------------
create or replace function public.fn_sync_productos_stock()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_old_producto integer := null;
  v_new_producto integer := null;
begin
  if tg_op in ('INSERT', 'UPDATE') then
    v_new_producto := new.producto_id;
  end if;
  if tg_op in ('UPDATE', 'DELETE') then
    v_old_producto := old.producto_id;
  end if;

  -- Recalcular el producto "nuevo" (o el único en INSERT/UPDATE)
  if v_new_producto is not null then
    update public.productos
    set stock = coalesce((
      select sum(l.cantidad_actual)
      from public.lotes l
      where l.producto_id = v_new_producto
        and coalesce(l.activo, true) = true
    ), 0)
    where id = v_new_producto;
  end if;

  -- Si el UPDATE movió el lote entre productos, recalcular también el viejo
  if v_old_producto is not null
     and v_old_producto is distinct from v_new_producto then
    update public.productos
    set stock = coalesce((
      select sum(l.cantidad_actual)
      from public.lotes l
      where l.producto_id = v_old_producto
        and coalesce(l.activo, true) = true
    ), 0)
    where id = v_old_producto;
  end if;

  return coalesce(new, old);
end;
$$;

comment on function public.fn_sync_productos_stock() is
  'F2.5b: mantiene productos.stock = sum(lotes.cantidad_actual) sobre cambios en lotes. Productos.stock ya NO es fuente de verdad, es campo derivado.';

-- -----------------------------------------------
-- Trigger (drop + create para re-instalación limpia)
-- -----------------------------------------------
drop trigger if exists trg_sync_productos_stock on public.lotes;

create trigger trg_sync_productos_stock
after insert or update or delete on public.lotes
for each row
execute function public.fn_sync_productos_stock();

commit;

-- ============================================================
-- Verificación (correr por separado y pegar resultados)
-- ============================================================
--
-- -- 1) ¿El trigger quedó instalado?
-- select tgname, tgrelid::regclass as tabla, tgtype, tgenabled
-- from pg_trigger
-- where tgname = 'trg_sync_productos_stock';
--
-- -- 2) Prueba en sandbox (transacción con rollback): cambiar un lote
-- -- y verificar que productos.stock se ajustó.
-- begin;
--   -- Toma el primer producto con stock > 0
--   with target as (
--     select p.id as producto_id, p.stock as stock_antes
--     from public.productos p
--     where p.stock > 0
--     order by p.id
--     limit 1
--   )
--   select * from target;
--
--   -- Incrementa cantidad_actual en 7 en todos los lotes activos de ese producto
--   update public.lotes
--   set cantidad_actual = cantidad_actual + 7
--   where producto_id = (select id from public.productos where stock > 0 order by id limit 1)
--     and coalesce(activo, true) = true;
--
--   -- Verifica que productos.stock se incrementó en 7 (o múltiplo si hay varios lotes)
--   select p.id, p.stock as stock_despues
--   from public.productos p
--   where p.id = (select id from public.productos where stock > 0 order by id limit 1);
-- rollback;
-- ============================================================
