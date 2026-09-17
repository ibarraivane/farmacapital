-- ============================================================================
-- FarmaCapital — 2026-09-17
-- Bajo pedido: sin costo de mayoreo → sin precio de Encargar (CTA Cotizar).
--
-- Error: se cargó la vitrina con lista Fahorro como productos.precio.
-- Regla correcta (docs/BAJO_PEDIDO.md):
--   precio = costo mayorista + ganancia FarmaCapital
--   si no hay costo usable → precio 0 → «Cotizar» (no reserva en tarjeta)
--
-- Este patch NO borra productos ni fotos. Solo quita anclas de competencia.
-- Cuando tengas costo de DermaPharma / Birdman / Nadro / etc., pon:
--   costo = <mayoreo>, precio = costo * 1.25 (marca) o * 1.60 (genérico)
-- ============================================================================

begin;

update public.productos
   set precio = 0
 where coalesce(bajo_pedido, false) = true
   and coalesce(costo, 0) <= 0
   and coalesce(precio, 0) > 0.01;

commit;

select
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) <= 0.01) as cotizar,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) > 0.01) as encargar,
  count(*) filter (where coalesce(bajo_pedido, false)) as total_bajo_pedido
from public.productos;
