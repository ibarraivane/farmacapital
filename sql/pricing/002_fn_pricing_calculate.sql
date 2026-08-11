-- ============================================================================
-- FARMA CAPITAL — Funciones de cálculo de precio (002)
-- Recargo sobre costo + utilidad mínima + redondeo ceil entero
-- ============================================================================

begin;

create or replace function public.fn_pricing_utilidad_minima(p_costo numeric)
returns numeric
language sql
immutable
as $$
  select case
    when coalesce(p_costo, 0) <= 0 then null
    when p_costo < 20 then 5
    when p_costo < 50 then 8
    else 0
  end;
$$;

create or replace function public.fn_pricing_calcular_precio(
  p_costo numeric,
  p_porcentaje_recargo numeric
)
returns numeric
language sql
immutable
as $$
  select case
    when coalesce(p_costo, 0) <= 0 then null
    else ceil(
      greatest(
        p_costo * (1 + coalesce(p_porcentaje_recargo, 0)),
        p_costo + coalesce(public.fn_pricing_utilidad_minima(p_costo), 0)
      )
    )
  end;
$$;

comment on function public.fn_pricing_calcular_precio(numeric, numeric) is
  'precio = CEIL(MAX(costo*(1+recargo), costo+utilidad_minima)). Nunca menor a costo.';

-- Clasificador conservador: categoría/tipo primero; nombre solo como apoyo.
create or replace function public.fn_pricing_clasificar_producto(p public.productos)
returns table (
  rule_codigo text,
  rule_id bigint,
  porcentaje_recargo numeric,
  needs_review boolean,
  motivo text
)
language plpgsql
stable
as $$
declare
  v_cat text := lower(coalesce(p.categoria, ''));
  v_tipo text := lower(coalesce(p.tipo, ''));
  v_nombre text := lower(coalesce(p.nombre, ''));
  v_forma text := lower(coalesce(p.forma_farmaceutica, ''));
  v_costo numeric := coalesce(p.costo, 0);
  v_pa text := coalesce(btrim(p.principio_activo), '');
  v_rule record;
begin
  -- Costo inválido → no clasificar para auto-apply
  if v_costo <= 0 then
    return query select 'sin_costo'::text, null::bigint, null::numeric, true, 'costo null/cero/negativo'::text;
    return;
  end if;

  -- Costo sospechosamente bajo (parseo ticket)
  if v_costo < 2 then
    return query select 'sin_clasificar'::text,
      (select id from public.pricing_rules where codigo = 'sin_clasificar'),
      0.35::numeric, true, 'costo < $2 — revisar ticket'::text;
    return;
  end if;

  -- Bebidas / sueros / electrolitos
  if v_cat in ('hidratación','bebidas')
     or v_nombre ~ '(electrolit|pedialyte|suero oral|oralit|suerox|agua destilada|agua purificada)' then
    select * into v_rule from public.pricing_rules where codigo = 'bebidas_sueros' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'bebidas/sueros'::text;
    return;
  end if;

  if v_cat in ('bebés','bebes') or v_nombre ~ '(pañal|pampers|huggies|nan |enfamil|gerber|bebe|bebé)' then
    select * into v_rule from public.pricing_rules where codigo = 'bebe' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'bebe'::text;
    return;
  end if;

  if v_cat in ('abarrotes','minisuper') or v_nombre ~ '(dulce|chocolate|botana|papas|galleta|chicle)' then
    select * into v_rule from public.pricing_rules where codigo = 'impulso' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'impulso'::text;
    return;
  end if;

  if v_cat in ('suplemento','vitaminas') or v_nombre ~ '(vitamina|suplemento|omega|colageno|colágeno)' then
    select * into v_rule from public.pricing_rules where codigo = 'vitaminas' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'vitaminas'::text;
    return;
  end if;

  if v_cat in ('botiquín','botiquin')
     or v_nombre ~ '(venda|gasa|jeringa|algodon|algodón|alcohol|agua oxigenada|cinta|apósito|aposito|guante|curita|torunda|tela adhesiva|cateter|catéter)' then
    select * into v_rule from public.pricing_rules where codigo = 'material_curacion' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'material curacion'::text;
    return;
  end if;

  if v_cat in ('higiene','cuidado personal') then
    select * into v_rule from public.pricing_rules where codigo = 'higiene' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'higiene'::text;
    return;
  end if;

  -- Dispositivos médicos
  if v_nombre ~ '(tensiometro|tensiómetro|glucometro|glucómetro|nebulizador|termometro|termómetro|oximetro|oxímetro|baston|bastón|andadera)' then
    if v_costo >= 300 then
      select * into v_rule from public.pricing_rules where codigo = 'disp_med_alto' and activo limit 1;
    else
      select * into v_rule from public.pricing_rules where codigo = 'disp_med_bajo' and activo limit 1;
    end if;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'dispositivo medico'::text;
    return;
  end if;

  -- Medicamentos: requiere señales de medicamento, NO solo principio en nombre
  if v_tipo in ('generico','genérico')
     and v_pa <> ''
     and v_forma ~ '(tableta|capsula|cápsula|jarabe|suspension|suspensión|solucion|solución|inyect|comprim|gragea|supositorio)' then
    select * into v_rule from public.pricing_rules where codigo = 'med_generico' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'generico con PA'::text;
    return;
  end if;

  if v_tipo = 'marca' and coalesce(p.requiere_receta, false) then
    select * into v_rule from public.pricing_rules where codigo = 'med_patente' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'marca con receta'::text;
    return;
  end if;

  if v_tipo = 'marca'
     and not coalesce(p.requiere_receta, false)
     and v_forma ~ '(tableta|capsula|cápsula|jarabe|suspension|suspensión|solucion|solución|inyect|comprim|gragea|spray nasal|gotas)' then
    select * into v_rule from public.pricing_rules where codigo = 'med_otc_marca' and activo limit 1;
    return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, false, 'otc marca'::text;
    return;
  end if;

  -- Ambiguo / sin clasificar
  select * into v_rule from public.pricing_rules where codigo = 'sin_clasificar' and activo limit 1;
  return query select v_rule.codigo, v_rule.id, v_rule.porcentaje_recargo, true,
    'categoria/tipo ambiguo — revision manual'::text;
end;
$$;

commit;
