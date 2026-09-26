-- ============================================================================
-- Agotados vs Inventario: resync + criterio unificado
-- 23-sep-2026. Idempotente. Pegar en Supabase → SQL Editor → Run.
--
-- Qué pasaba:
--   Recibir escribe lotes (PEPS). El trigger debería dejar
--   productos.stock = sum(lotes.cantidad_actual). Si el trigger faltó o
--   hubo writes directos, Catálogo/Reabasto/tienda veían AGOTADO
--   (columna en 0) aunque Lotes PEPS ya tuviera piezas — o al revés.
--
-- Qué hace:
--   A) Reinstala fn_sync_productos_stock + trigger (por si se perdió).
--   B) Resync masivo: productos.stock ← suma de lotes activos.
--   C) Badge / dashboard cuentan con GREATEST(columna, suma lotes)
--      por si vuelve a desfasarse un rato.
--
-- Después: refrescar Inventario. El contador «Agotados» debe bajar
-- para SKUs que sí tienen piezas en lotes.
-- ============================================================================

begin;

-- ── A) Trigger de sync (misma lógica que refactor_fase2_5b) ────────────────
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
  'Mantiene productos.stock = sum(lotes.cantidad_actual). Campo derivado; lotes son fuente de verdad.';

drop trigger if exists trg_sync_productos_stock on public.lotes;

create trigger trg_sync_productos_stock
after insert or update or delete on public.lotes
for each row
execute function public.fn_sync_productos_stock();

-- ── B) Resync masivo ───────────────────────────────────────────────────────
update public.productos p
set stock = coalesce((
  select sum(l.cantidad_actual)
  from public.lotes l
  where l.producto_id = p.id
    and coalesce(l.activo, true) = true
), 0);

-- ── C) Stock efectivo (columna ∪ lotes) para alertas ────────────────────────
create or replace function public.fn_stock_anaquel(p_producto_id bigint)
returns integer
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select greatest(
    coalesce((select p.stock from public.productos p where p.id = p_producto_id), 0),
    coalesce((
      select sum(l.cantidad_actual)::int
      from public.lotes l
      where l.producto_id = p_producto_id
        and coalesce(l.activo, true)
    ), 0)
  )::int;
$$;

comment on function public.fn_stock_anaquel(bigint) is
  'GREATEST(productos.stock, sum lotes activos). Evita falsos agotados si hay desfase.';

revoke all on function public.fn_stock_anaquel(bigint) from public;
grant execute on function public.fn_stock_anaquel(bigint) to anon, authenticated;

-- Badge del menú Inventario
create or replace function public.empleado_contar_productos_bajo_stock(p_session_token uuid)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_dummy bigint;
  v_n int;
begin
  v_dummy := public.fn_require_empleado(p_session_token);
  select count(*)::int into v_n
  from public.productos p
  where coalesce(p.activo, false)
    and not coalesce(p.bajo_pedido, false)
    and public.fn_stock_anaquel(p.id) <= coalesce(p.stock_minimo, 0);
  return coalesce(v_n, 0);
end;
$$;

revoke all on function public.empleado_contar_productos_bajo_stock(uuid) from public;
grant execute on function public.empleado_contar_productos_bajo_stock(uuid) to anon, authenticated;

commit;

-- ============================================================================
-- Diagnóstico (correr aparte; solo lectura)
-- ============================================================================
--
-- -- 1) Falsos agotados: columna 0 pero lotes con piezas (lo que veías en Inventario)
-- select p.id, p.sku, left(p.nombre, 48) as nombre,
--        coalesce(p.stock, 0) as stock_columna,
--        coalesce((
--          select sum(l.cantidad_actual)::int from public.lotes l
--          where l.producto_id = p.id and coalesce(l.activo, true)
--        ), 0) as suma_lotes
-- from public.productos p
-- where coalesce(p.activo, true)
--   and not coalesce(p.bajo_pedido, false)
--   and coalesce(p.stock, 0) <= 0
--   and coalesce((
--     select sum(l.cantidad_actual) from public.lotes l
--     where l.producto_id = p.id and coalesce(l.activo, true)
--   ), 0) > 0
-- order by suma_lotes desc
-- limit 80;
--
-- -- 2) Cuántos agotados reales quedan (columna y lotes en 0)
-- select count(*) as agotados_reales
-- from public.productos p
-- where coalesce(p.activo, true)
--   and not coalesce(p.bajo_pedido, false)
--   and public.fn_stock_anaquel(p.id) = 0;
--
-- -- 3) ¿Trigger instalado?
-- select tgname, tgenabled from pg_trigger where tgname = 'trg_sync_productos_stock';
