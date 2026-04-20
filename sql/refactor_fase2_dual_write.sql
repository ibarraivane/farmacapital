-- ============================================================
-- FARMAX — Refactor FASE 2: DUAL-WRITE / BACKFILL
-- ============================================================
-- Objetivo: agregar las columnas nuevas y rellenar datos desde
-- las columnas legacy, SIN eliminar nada. Después de F2 tendrás
-- dos fuentes conviviendo (columna vieja + nueva) para que el
-- código se pueda migrar con calma en F3.
--
-- Tareas incluidas:
--   T1 parte 2 — lotes.proveedor_id + backfill desde lotes.proveedor (texto)
--   T4 parte 1 — pedido_items.lote_id + backfill desde pedido_items.lote (texto)
--   T5 parte 1 — view public.v_stock_actual (agregada desde lotes)
--
-- Idempotente y transaccional. Seguro correr varias veces.
--
-- Lo que se deja para FASES posteriores:
--   - F3: actualizar Admin.jsx, Tienda.jsx y RPCs (create_sale_transaction, etc.)
--   - F4: DROP de lotes.proveedor y pedido_items.lote (solo cuando F3 esté verificada)
--   - F5: RLS, triggers, validación de receta, alertas
-- ============================================================

begin;

-- ============================================================
-- T1 parte 2 — Migrar lotes.proveedor (texto) → lotes.proveedor_id
-- ============================================================

-- Agregar columna nullable (no toca nada existente)
alter table public.lotes
  add column if not exists proveedor_id integer references public.proveedores(id);

create index if not exists idx_lotes_proveedor_id on public.lotes (proveedor_id);

-- Poblar catálogo proveedores con los nombres distintos que haya en lotes.proveedor.
-- Case-insensitive y sin duplicados (match por lower(trim(nombre))).
insert into public.proveedores (nombre)
select distinct trim(l.proveedor)
from public.lotes l
where l.proveedor is not null
  and trim(l.proveedor) <> ''
  and not exists (
    select 1
    from public.proveedores p
    where lower(p.nombre) = lower(trim(l.proveedor))
  );

-- Enganchar lotes al proveedor correspondiente
update public.lotes l
set proveedor_id = p.id
from public.proveedores p
where l.proveedor_id is null
  and l.proveedor is not null
  and trim(l.proveedor) <> ''
  and lower(p.nombre) = lower(trim(l.proveedor));

comment on column public.lotes.proveedor    is 'LEGACY: texto libre. Se conserva durante F2/F3 y se drop en F4 cuando el código lea proveedor_id.';
comment on column public.lotes.proveedor_id is 'Canonico: referencia a proveedores(id). Rellenado en F2 desde lotes.proveedor.';


-- ============================================================
-- T4 parte 1 — Migrar pedido_items.lote (texto) → pedido_items.lote_id
-- ============================================================
-- Estrategia de match:
--   (producto_id, numero_lote)
-- y si pedido_items.caducidad está disponible, desempata por fecha_caducidad.
-- Si hay múltiples matches, se toma el lote más antiguo (FIFO).

alter table public.pedido_items
  add column if not exists lote_id integer references public.lotes(id);

create index if not exists idx_pedido_items_lote_id on public.pedido_items (lote_id);

update public.pedido_items pi
set lote_id = sub.lote_id
from (
  select
    pi2.id as pedido_item_id,
    (
      select l.id
      from public.lotes l
      where l.producto_id = pi2.producto_id
        and l.numero_lote = pi2.lote
        and (pi2.caducidad is null or l.fecha_caducidad is null or l.fecha_caducidad = pi2.caducidad)
      order by l.fecha_recepcion asc nulls last, l.id asc
      limit 1
    ) as lote_id
  from public.pedido_items pi2
  where pi2.lote_id is null
    and pi2.lote is not null
    and trim(pi2.lote) <> ''
) sub
where pi.id = sub.pedido_item_id
  and sub.lote_id is not null;

comment on column public.pedido_items.lote     is 'LEGACY: texto libre del lote. Conservada hasta F4.';
comment on column public.pedido_items.caducidad is 'LEGACY: caducidad del item. A futuro se deriva del lote referenciado.';
comment on column public.pedido_items.lote_id  is 'Canonico: referencia a lotes(id). Rellenado en F2.';


-- ============================================================
-- T5 parte 1 — View v_stock_actual (agregada desde lotes)
-- ============================================================
-- No reemplaza todavía a productos.stock. Sirve como fuente alterna
-- para cuando el código empiece a consumirla en F3.

create or replace view public.v_stock_actual as
select
  l.producto_id,
  sum(l.cantidad_actual)::integer as stock_lotes,
  count(*) filter (where coalesce(l.activo, true) = true) as lotes_activos,
  min(l.fecha_caducidad) filter (where coalesce(l.activo, true) = true) as proxima_caducidad
from public.lotes l
where coalesce(l.activo, true) = true
group by l.producto_id;

comment on view public.v_stock_actual is
  'F2: stock agregado desde lotes activos. En F3 el código empezará a preferir esta vista sobre productos.stock.';


commit;

-- ============================================================
-- Verificación post-F2 — pegarme resultado
-- ============================================================
-- Correr AL SEPARADO después del COMMIT:
--
-- -- a) ¿Cuántos proveedores se crearon desde lotes.proveedor?
-- select count(*) from public.proveedores;
--
-- -- b) ¿Cuántos lotes quedaron con proveedor_id vs sin?
-- select
--   count(*) filter (where proveedor_id is not null) as con_proveedor_id,
--   count(*) filter (where proveedor_id is null and proveedor is not null and trim(proveedor) <> '') as texto_sin_match,
--   count(*) filter (where proveedor is null or trim(proveedor) = '') as sin_proveedor_origen,
--   count(*) as total_lotes
-- from public.lotes;
--
-- -- c) ¿Cuántos pedido_items quedaron con lote_id?
-- select
--   count(*) filter (where lote_id is not null) as con_lote_id,
--   count(*) filter (where lote_id is null and lote is not null and trim(lote) <> '') as texto_sin_match,
--   count(*) filter (where lote is null or trim(lote) = '') as sin_lote_origen,
--   count(*) as total_items
-- from public.pedido_items;
--
-- -- d) ¿Stock agregado desde lotes vs productos.stock?
-- select
--   p.id, p.nombre, p.sku,
--   p.stock                as stock_productos,
--   coalesce(v.stock_lotes, 0) as stock_lotes,
--   (p.stock - coalesce(v.stock_lotes, 0)) as diferencia
-- from public.productos p
-- left join public.v_stock_actual v on v.producto_id = p.id
-- order by abs(p.stock - coalesce(v.stock_lotes, 0)) desc
-- limit 20;
-- ============================================================
