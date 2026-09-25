-- ============================================================================
-- AUDITORÍA INVENTARIO — duplicados / stock sin lote / doble conteo
-- Solo LECTURA (no modifica). Pegar en Supabase → SQL Editor → Run.
-- Fecha: 2026-09-25
--
-- Cubría los fallos que ya vimos:
--   A) FC-IFC-* sin EAN duplicando ficha vieja (bórax, pomada manzana)
--   B) stock ficha > 0 pero POS «Sin lotes» (aceite olivo)
--   C) caja + sueltas a la vez (Protec 1+99)
--   D) mismo EAN en 2 SKUs activos
-- ============================================================================

-- ── A1. Duplicados YA confirmados (deben quedar inactivos / stock 0) ─────────
select
  'A1_conocidos' as seccion,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.activo,
  p.stock,
  p.stock_unidades,
  p.codigo_barras as ean,
  p.precio,
  case p.sku
    when 'FC-IFC-1400724' then 'debe_inactivo → FC-578F060C'
    when 'FC-IFC-82943' then 'debe_inactivo → FC-MER-MANZANA stock4'
    when 'FC-578F060C' then 'canónico bórax'
    when 'FC-MER-MANZANA' then 'canónico manzana'
    else ''
  end as esperado
from public.productos p
where p.sku in (
  'FC-IFC-1400724', 'FC-578F060C',
  'FC-IFC-82943', 'FC-MER-MANZANA'
)
order by p.sku;

-- ── A2. Todos los FC-IFC / FC-MER activos (candidatos a basura o altas) ──────
select
  'A2_ifc_activos' as seccion,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.stock,
  p.precio,
  p.costo,
  p.presentacion,
  p.marca
from public.productos p
where p.activo = true
  and (p.sku like 'FC-IFC-%' or p.sku like 'FC-MER-%')
order by p.sku;

-- ── A3. FC-IFC sin EAN cuyo nombre se parece a otro activo ───────────────────
-- Heurística simple (sin unaccent): ≥2 tokens de ≥4 letras en común.
-- Revisar a ojo antes de merge. Magnesia calcinada ≠ anisada ≠ tokens_comunes=1.
with ifc as (
  select p.id, p.sku, p.nombre, p.stock, p.precio
  from public.productos p
  where p.activo = true
    and p.sku like 'FC-IFC-%'
    and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
),
canon as (
  select p.id, p.sku, p.nombre, p.codigo_barras as ean, p.stock, p.precio
  from public.productos p
  where p.activo = true
    and p.sku not like 'FC-IFC-%'
),
ifc_tok as (
  select i.*, t.w
  from ifc i
  cross join lateral regexp_split_to_table(
    lower(regexp_replace(coalesce(i.nombre, ''), '[^a-zA-Z0-9áéíóúñüÁÉÍÓÚÑÜ ]', ' ', 'g')),
    '\s+'
  ) as t(w)
  where length(t.w) >= 4
    and t.w not in ('mercurio','paquete','frasco','caja','pomada','polvo','venda','stick')
),
canon_tok as (
  select c.*, t.w
  from canon c
  cross join lateral regexp_split_to_table(
    lower(regexp_replace(coalesce(c.nombre, ''), '[^a-zA-Z0-9áéíóúñüÁÉÍÓÚÑÜ ]', ' ', 'g')),
    '\s+'
  ) as t(w)
  where length(t.w) >= 4
    and t.w not in ('mercurio','paquete','frasco','caja','pomada','polvo','venda','stick')
)
select
  'A3_sospechosos_nombre' as seccion,
  i.sku as sku_ifc,
  left(i.nombre, 40) as nombre_ifc,
  i.stock as stock_ifc,
  c.sku as sku_otro,
  left(c.nombre, 40) as nombre_otro,
  c.ean,
  c.stock as stock_otro,
  count(distinct i.w) as tokens_comunes,
  string_agg(distinct i.w, ', ' order by i.w) as tokens
from ifc_tok i
join canon_tok c on c.w = i.w and c.id <> i.id
group by i.sku, i.nombre, i.stock, c.sku, c.nombre, c.ean, c.stock
having count(distinct i.w) >= 2
order by tokens_comunes desc, i.sku
limit 80;

-- ── A4. Dibar / Venda-stick: IFC vs EAN canónico (mismo producto físico) ────
select
  'A4_vendas_dibar' as seccion,
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.venta_unidad,
  p.stock_unidades,
  case
    when p.sku in ('FC-IFC-83733', 'FC-68950207')
      or p.codigo_barras = '7501868950207' then 'grupo_dibar_c24'
    when p.sku in ('FC-IFC-82912P', 'FC-84500157')
      or p.codigo_barras = '7506484500157' then 'venda_stick_piel'
    when p.sku in ('FC-IFC-82912A', 'FC-84500164')
      or p.codigo_barras = '7506484500164' then 'venda_stick_azul'
    when p.sku in ('FC-IFC-83552', 'FC-84500140')
      or p.codigo_barras = '7506484500140' then 'venda_stick_rojo_o_2pulg'
    else 'otro'
  end as grupo
from public.productos p
where p.sku in (
    'FC-IFC-83733', 'FC-68950207',
    'FC-IFC-82912P', 'FC-84500157',
    'FC-IFC-82912A', 'FC-84500164',
    'FC-IFC-83552', 'FC-84500140'
  )
   or p.codigo_barras in (
    '7501868950207', '7506484500157', '7506484500164', '7506484500140'
  )
order by grupo, p.sku;

-- ── B. Stock ficha > 0 sin lote vendible (POS «Sin lotes») ───────────────────
select
  'B_stock_sin_lote' as seccion,
  p.sku,
  left(p.nombre, 42) as nombre,
  coalesce(p.marca, '') as marca,
  p.stock,
  p.precio,
  (
    select count(*)::int from public.lotes l where l.producto_id = p.id
  ) as filas_lote
from public.productos p
where p.activo = true
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  )
order by
  case when coalesce(p.marca,'') ilike 'mercurio%' then 0 else 1 end,
  p.stock desc,
  p.sku
limit 100;

select
  'B_count' as seccion,
  count(*) as productos_stock_sin_lote_vendible
from public.productos p
where p.activo = true
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  );

-- ── C. Doble conteo: cajas cerradas + sueltas a la vez ───────────────────────
select
  'C_caja_y_sueltas' as seccion,
  p.sku,
  left(p.nombre, 42) as nombre,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja,
  p.precio_unidad,
  (coalesce(p.stock,0) * greatest(coalesce(p.unidades_por_caja,1),1)
    + coalesce(p.stock_unidades,0)) as equivalente_piezas
from public.productos p
where p.activo = true
  and p.venta_unidad = true
  and coalesce(p.stock, 0) > 0
  and coalesce(p.stock_unidades, 0) > 0
order by equivalente_piezas desc, p.sku
limit 50;

-- ── D. Mismo EAN en 2+ SKUs activos ─────────────────────────────────────────
select
  'D_ean_duplicado' as seccion,
  regexp_replace(p.codigo_barras, '\D', '', 'g') as ean,
  count(*) as skus,
  string_agg(p.sku || ' (stock=' || coalesce(p.stock,0) || ')', ' | ' order by p.sku) as detalle
from public.productos p
where p.activo = true
  and nullif(btrim(p.codigo_barras), '') is not null
  and length(regexp_replace(p.codigo_barras, '\D', '', 'g')) >= 8
group by regexp_replace(p.codigo_barras, '\D', '', 'g')
having count(*) > 1
order by count(*) desc, ean
limit 40;

-- ── E. Mercurio óxido zinc (presentaciones distintas — NO merge automático) ──
select
  'E_oxido_zinc_revisar' as seccion,
  p.sku,
  left(p.nombre, 42) as nombre,
  p.codigo_barras as ean,
  p.presentacion,
  p.stock,
  p.precio,
  p.activo
from public.productos p
where p.sku in ('FC-C4530823', 'FC-0ACC5B6A')
   or (p.nombre ilike '%oxido%zinc%' and p.marca ilike 'mercurio%')
order by p.sku;

-- ── F. Resumen ejecutivo ────────────────────────────────────────────────────
select 'F_resumen' as seccion, 'ifc_activos' as metric, count(*)::text as valor
from public.productos p
where p.activo and (p.sku like 'FC-IFC-%' or p.sku like 'FC-MER-%')
union all
select 'F_resumen', 'stock_sin_lote', count(*)::text
from public.productos p
where p.activo and coalesce(p.stock,0)>0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id=p.id and coalesce(l.activo,true) and coalesce(l.cantidad_actual,0)>0
  )
union all
select 'F_resumen', 'caja_y_sueltas', count(*)::text
from public.productos p
where p.activo and p.venta_unidad and coalesce(p.stock,0)>0 and coalesce(p.stock_unidades,0)>0
union all
select 'F_resumen', 'ean_multi_sku', count(*)::text
from (
  select 1
  from public.productos p
  where p.activo and nullif(btrim(p.codigo_barras),'') is not null
  group by regexp_replace(p.codigo_barras, '\D', '', 'g')
  having count(*)>1
) x
union all
select 'F_resumen', 'borax_ifc_aun_activo',
  coalesce((select case when activo then 'SI' else 'no' end from public.productos where sku='FC-IFC-1400724'), 'no_existe')
union all
select 'F_resumen', 'manzana_ifc_aun_activo',
  coalesce((select case when activo then 'SI' else 'no' end from public.productos where sku='FC-IFC-82943'), 'no_existe');
