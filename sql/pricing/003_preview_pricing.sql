-- ============================================================================
-- Vista previa de precios (003) — EJECUTAR DESPUÉS de 001 y 002
-- Revisar resultados antes de 004_apply
-- ============================================================================

begin;

create or replace view public.vw_pricing_preview as
select
  p.id,
  p.sku,
  p.nombre,
  p.categoria,
  p.tipo,
  p.marca,
  p.forma_farmaceutica,
  p.principio_activo,
  p.costo,
  p.precio as precio_actual,
  p.manual_price_override,
  p.price_needs_review as review_previo,
  c.rule_codigo,
  c.rule_id,
  c.porcentaje_recargo,
  c.needs_review as needs_review_clasificacion,
  c.motivo as motivo_regla,
  public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo) as precio_calculado,
  case
    when coalesce(p.costo, 0) <= 0 then p.precio
    when p.manual_price_override then p.precio
    when c.needs_review then p.precio
    else public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo)
  end as precio_efectivo_propuesto,
  case
    when coalesce(p.costo, 0) <= 0 then null
    else round(
      (
        case
          when p.manual_price_override then p.precio
          when c.needs_review then p.precio
          else public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo)
        end - p.costo
      ) / nullif(
        case
          when p.manual_price_override then p.precio
          when c.needs_review then p.precio
          else public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo)
        end, 0
      ) * 100, 2
    )
  end as margen_bruto_pct_sobre_venta,
  case
    when coalesce(p.costo, 0) <= 0 then null
    else round(
      (c.porcentaje_recargo * 100)::numeric, 2
    )
  end as recargo_sobre_costo_pct,
  case
    when coalesce(p.precio, 0) <= 0 then null
    when coalesce(p.costo, 0) <= 0 then null
    else round(
      (
        (
          case
            when p.manual_price_override then p.precio
            when c.needs_review then p.precio
            else public.fn_pricing_calcular_precio(p.costo, c.porcentaje_recargo)
          end - p.precio
        ) / p.precio * 100
      )::numeric, 2
    )
  end as variacion_pct,
  p.tasa_iva,
  p.costo_incluye_iva
from public.productos p
cross join lateral public.fn_pricing_clasificar_producto(p.*) c;

comment on view public.vw_pricing_preview is
  'Vista previa — no modifica datos. Revisar antes de apply.';

commit;

-- Consultas útiles post-creación:
-- select rule_codigo, count(*) from vw_pricing_preview group by 1 order by 2 desc;
-- select * from vw_pricing_preview where variacion_pct > 30 order by variacion_pct desc;
-- select * from vw_pricing_preview where variacion_pct < -5 order by variacion_pct;
-- select * from vw_pricing_preview where needs_review_clasificacion or review_previo;
