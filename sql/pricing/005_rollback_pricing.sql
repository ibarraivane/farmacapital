-- ============================================================================
-- ROLLBACK precios desde respaldo (005)
-- Restaura precio, costo NO se toca.
-- ============================================================================

begin;

update public.productos p
set
  precio = b.precio_anterior,
  precio_unidad = b.precio_unidad_ant,
  descuento_pct = b.descuento_pct_ant,
  pricing_rule_id = null,
  markup_percentage = null,
  calculated_price = null,
  manual_price_override = false,
  price_needs_review = false,
  price_updated_at = now()
from public.productos_precio_backup_20260810 b
where b.producto_id = p.id;

insert into public.productos_precio_historial (
  producto_id, precio_anterior, precio_nuevo, costo_usado, origen, notas
)
select
  p.id,
  p.precio,
  b.precio_anterior,
  p.costo,
  'rollback_005',
  'Restaurado desde productos_precio_backup_20260810'
from public.productos p
join public.productos_precio_backup_20260810 b on b.producto_id = p.id
where p.precio is distinct from b.precio_anterior;

commit;

select count(*) as productos_restaurados from public.productos_precio_backup_20260810;
