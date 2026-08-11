-- ============================================================================
-- Aplicación idempotente de precios (004)
-- PRE-requisitos: 001, 002, 003 ejecutados y vista previa revisada.
-- Solo actualiza productos elegibles. Registra historial.
-- ============================================================================

begin;

-- Heurística inicial: precio manual si difiere >15% del ceil(costo*1.6) Y >15% del calculado
-- Nota: en UPDATE no se puede pasar el alias "p" a LATERAL; usar subquery con p2.
update public.productos p
set manual_price_override = true
from public.productos p2
cross join lateral public.fn_pricing_clasificar_producto(p2) c
where p.id = p2.id
  and coalesce(p.manual_price_override, false) = false
  and coalesce(p.costo, 0) > 0
  and p.precio is not null
  and abs(p.precio - ceil(p.costo * 1.6)) > greatest(2, p.costo * 0.15)
  and abs(
    p.precio - public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo)
  ) > greatest(2, p.costo * 0.15);

-- Calcular campos derivados (sin cambiar precio aún)
update public.productos p
set
  pricing_rule_id = c.rule_id,
  markup_percentage = c.porcentaje_recargo,
  calculated_price = public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo),
  price_needs_review = (
    coalesce(p.price_needs_review, false)
    or c.needs_review
    or coalesce(p.costo, 0) <= 0
  )
from public.productos p2
cross join lateral public.fn_pricing_clasificar_producto(p2) c
where p.id = p2.id;

-- Registrar historial + aplicar precio efectivo
with candidatos as (
  select
    p.id,
    p.precio as precio_anterior,
    p.costo,
    p.pricing_rule_id,
    pr.codigo as rule_codigo,
    p.markup_percentage,
    p.calculated_price as precio_nuevo,
    p.manual_price_override,
    p.price_needs_review
  from public.productos p
  left join public.pricing_rules pr on pr.id = p.pricing_rule_id
  where coalesce(p.costo, 0) > 0
    and coalesce(p.manual_price_override, false) = false
    and coalesce(p.price_needs_review, false) = false
    and p.calculated_price is not null
    and p.calculated_price >= p.costo
    and (p.precio is distinct from p.calculated_price)
),
hist as (
  insert into public.productos_precio_historial (
    producto_id, precio_anterior, precio_nuevo, costo_usado,
    pricing_rule_id, pricing_rule_codigo, markup_percentage, origen, notas
  )
  select
    id, precio_anterior, precio_nuevo, costo,
    pricing_rule_id, rule_codigo, markup_percentage,
    'pricing_engine_v1',
    'apply idempotente 004'
  from candidatos
  returning producto_id, precio_nuevo
)
update public.productos p
set
  precio = h.precio_nuevo,
  price_updated_at = now()
from hist h
where p.id = h.producto_id;

commit;

-- Verificación
select
  count(*) filter (where manual_price_override) as con_precio_manual,
  count(*) filter (where price_needs_review) as pendientes_revision,
  count(*) filter (where calculated_price is not null and not manual_price_override and not price_needs_review) as calculados_ok
from public.productos;

select * from public.productos_precio_historial order by created_at desc limit 20;
