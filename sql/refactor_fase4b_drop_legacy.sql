-- ============================================================
-- FARMAX — F4b: DROP definitivo de columnas legacy
-- ============================================================
--
-- Corre DESPUES de:
--   1. sql/refactor_fase4a_rpcs_sin_legacy.sql
--   2. Desplegar frontend F4 (ningun modulo lee columnas legacy)
--
-- Columnas que se eliminan:
--   - public.pedido_items.lote        (text)
--   - public.pedido_items.caducidad   (date)
--   - public.productos.lote           (text)
--   - public.productos.fecha_caducidad (date)
--   - public.lotes.proveedor          (text) -- reemplazada por proveedor_id FK
--
-- Vistas afectadas (reconstruidas al final):
--   - public.trazabilidad_ventas
-- ============================================================

begin;

-- ============================================================
-- 0) DROP vistas dependientes (se recrean despues)
-- ============================================================
drop view if exists public.trazabilidad_ventas;

-- ============================================================
-- 1) pedido_items
-- ============================================================
alter table public.pedido_items drop column if exists lote;
alter table public.pedido_items drop column if exists caducidad;

-- ============================================================
-- 2) productos
-- ============================================================
alter table public.productos drop column if exists lote;
alter table public.productos drop column if exists fecha_caducidad;

-- ============================================================
-- 3) lotes
-- ============================================================
alter table public.lotes drop column if exists proveedor;

-- ============================================================
-- 4) Recrear trazabilidad_ventas con JOIN a lotes
-- ============================================================
-- Mantiene nombres de columna (lote, caducidad) para compatibilidad
-- con consumidores externos (BI, reportes, exports).
-- Ahora los datos vienen 100% desde lotes via pedido_items.lote_id.
-- ============================================================
create or replace view public.trazabilidad_ventas as
select
  pi.id                        as pedido_item_id,
  pi.pedido_id,
  p.created_at                 as fecha_venta,
  p.estado                     as estado_pedido,
  p.metodo_pago,
  p.total                      as total_pedido,
  p.tipo                       as tipo_pedido,
  pi.producto_id,
  prod.sku                     as producto_sku,
  prod.nombre                  as producto_nombre,
  prod.categoria               as producto_categoria,
  pi.cantidad,
  pi.precio_unitario,
  pi.lote_id,
  l.numero_lote                as lote,
  l.fecha_caducidad            as caducidad,
  l.costo_unitario             as lote_costo_unitario,
  prov.id                      as proveedor_id,
  prov.nombre                  as proveedor_nombre,
  p.cliente_id,
  c.nombre                     as cliente_nombre,
  c.telefono                   as cliente_telefono,
  p.atendido_por               as empleado_id,
  u.nombre                     as empleado_nombre
from public.pedido_items pi
join public.pedidos      p     on p.id = pi.pedido_id
join public.productos    prod  on prod.id = pi.producto_id
left join public.lotes       l     on l.id = pi.lote_id
left join public.proveedores prov  on prov.id = l.proveedor_id
left join public.clientes    c     on c.id = p.cliente_id
left join public.usuarios    u     on u.id = p.atendido_por;

comment on view public.trazabilidad_ventas is
  'F4: Trazabilidad completa de ventas con datos de lote via pedido_items.lote_id. Reemplaza la version legacy que leia pedido_items.lote y pedido_items.caducidad.';

commit;

-- ============================================================
-- FIN F4b
-- ============================================================
-- Siguiente paso: correr sql/005_verificar_fase4.sql
-- ============================================================
