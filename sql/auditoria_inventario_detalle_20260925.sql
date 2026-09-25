-- ============================================================================
-- AUDITORÍA parte 2 — detalle de lo que salió en F_resumen
-- Solo LECTURA. Correr después del resumen.
--
-- Resumen 2026-09-25 (producción):
--   ifc_activos=29 · stock_sin_lote=0 · caja_y_sueltas=85
--   ean_multi_sku=2 · borax/manzana IFC ya inactivos ✓
--
-- Triage IFC_SOSPECHA_DUP (mismo día):
--   REAL: FC-IFC-PARCHE-ACNE → FC-07020003 figuras (ticket FIGS)
--         panda FC-07020004 = otra presentación, no merge
--   FALSO: rosa Castilla vs Season Love mascarilla (tokens rosa+castilla)
--   FALSO: parche vs Adaferin/Benzac/Yunneco (tokens para+acné) — stopwords
-- ============================================================================

-- ── 1. Los 2 EAN con más de un SKU activo (arreglar YA) ─────────────────────
select
  'EAN_DUP' as seccion,
  regexp_replace(p.codigo_barras, '\D', '', 'g') as ean,
  p.sku,
  left(p.nombre, 42) as nombre,
  p.stock,
  p.stock_unidades,
  p.precio,
  p.costo,
  p.created_at
from public.productos p
where p.activo = true
  and nullif(btrim(p.codigo_barras), '') is not null
  and regexp_replace(p.codigo_barras, '\D', '', 'g') in (
    select regexp_replace(p2.codigo_barras, '\D', '', 'g')
    from public.productos p2
    where p2.activo = true
      and nullif(btrim(p2.codigo_barras), '') is not null
      and length(regexp_replace(p2.codigo_barras, '\D', '', 'g')) >= 8
    group by regexp_replace(p2.codigo_barras, '\D', '', 'g')
    having count(*) > 1
  )
order by ean, p.sku;

-- ── 2. Caja + sueltas: clasificar sospechosos vs normales ───────────────────
-- Normal: 2 cajas cerradas + 30 sueltas de una abierta.
-- Sospechoso (patrón Protec): casi 1 caja completa en sueltas Y aún stock>=1
--   → probablemente no bajó la caja al abrir (o REINTEGRO fantasma).
select
  'CAJA_SUELTAS' as seccion,
  case
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= p.unidades_por_caja
      then 'CRITICO_sueltas_>=_caja_completa'
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= greatest(p.unidades_por_caja - 5, 1)
      then 'SOSPECHOSO_casi_caja_en_sueltas'
    when exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote ilike 'REINTEGRO%'
    ) and p.stock_unidades > 0
      then 'SOSPECHOSO_reintegro_con_sueltas'
    else 'ok_probable_caja_cerrada_mas_abierta'
  end as clase,
  p.sku,
  left(p.nombre, 40) as nombre,
  p.stock as cajas,
  p.stock_unidades as sueltas,
  p.unidades_por_caja as upc,
  p.precio_unidad,
  (coalesce(p.stock,0) * greatest(coalesce(p.unidades_por_caja,1),1)
    + coalesce(p.stock_unidades,0)) as equiv_piezas
from public.productos p
where p.activo = true
  and p.venta_unidad = true
  and coalesce(p.stock, 0) > 0
  and coalesce(p.stock_unidades, 0) > 0
order by
  case
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= p.unidades_por_caja then 0
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= greatest(p.unidades_por_caja - 5, 1) then 1
    when exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote ilike 'REINTEGRO%'
    ) then 2
    else 3
  end,
  equiv_piezas desc,
  p.sku;

-- Conteos por clase
select
  'CAJA_SUELTAS_COUNT' as seccion,
  case
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= p.unidades_por_caja
      then 'CRITICO'
    when coalesce(p.unidades_por_caja, 0) >= 2
         and p.stock_unidades >= greatest(p.unidades_por_caja - 5, 1)
      then 'SOSPECHOSO'
    when exists (
      select 1 from public.lotes l
      where l.producto_id = p.id
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote ilike 'REINTEGRO%'
    ) and p.stock_unidades > 0
      then 'REINTEGRO'
    else 'OK'
  end as clase,
  count(*) as n
from public.productos p
where p.activo = true
  and p.venta_unidad = true
  and coalesce(p.stock, 0) > 0
  and coalesce(p.stock_unidades, 0) > 0
group by 1, 2
order by 2;

-- ── 3. Los 29 IFC/MER activos (¿altas legítimas o basura?) ──────────────────
select
  'IFC_LISTA' as seccion,
  p.sku,
  left(p.nombre, 48) as nombre,
  coalesce(p.codigo_barras, '') as ean,
  p.stock,
  p.stock_unidades,
  p.precio,
  p.costo,
  p.presentacion,
  p.marca
from public.productos p
where p.activo = true
  and (p.sku like 'FC-IFC-%' or p.sku like 'FC-MER-%')
order by
  case when nullif(btrim(p.codigo_barras), '') is null then 0 else 1 end,
  p.sku;

-- IFC sin EAN + otro activo con tokens fuertes en común (sospecha dup)
with ifc as (
  select p.* from public.productos p
  where p.activo and p.sku like 'FC-IFC-%'
    and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
),
canon as (
  select p.* from public.productos p
  where p.activo and p.sku not like 'FC-IFC-%'
),
ifc_tok as (
  select i.id, i.sku, i.nombre, i.stock, t.w
  from ifc i
  cross join lateral regexp_split_to_table(
    lower(regexp_replace(coalesce(i.nombre,''), '[^a-zA-Z0-9áéíóúñüÁÉÍÓÚÑÜ ]', ' ', 'g')),
    '\s+'
  ) t(w)
  where length(t.w) >= 4
    and t.w not in (
      'mercurio','paquete','frasco','caja','pomada','polvo','venda','stick','colores',
      'para','con','acne','acné','piel','pieles','tratamiento','gel','crema'
    )
),
canon_tok as (
  select c.id, c.sku, c.nombre, c.codigo_barras as ean, c.stock, t.w
  from canon c
  cross join lateral regexp_split_to_table(
    lower(regexp_replace(coalesce(c.nombre,''), '[^a-zA-Z0-9áéíóúñüÁÉÍÓÚÑÜ ]', ' ', 'g')),
    '\s+'
  ) t(w)
  where length(t.w) >= 4
    and t.w not in (
      'mercurio','paquete','frasco','caja','pomada','polvo','venda','stick','colores',
      'para','con','acne','acné','piel','pieles','tratamiento','gel','crema'
    )
)
select
  'IFC_SOSPECHA_DUP' as seccion,
  i.sku as sku_ifc,
  left(max(i.nombre), 40) as nombre_ifc,
  max(i.stock) as stock_ifc,
  c.sku as sku_otro,
  left(max(c.nombre), 40) as nombre_otro,
  max(c.ean) as ean,
  max(c.stock) as stock_otro,
  count(distinct i.w) as tokens,
  string_agg(distinct i.w, ', ' order by i.w) as cuales
from ifc_tok i
join canon_tok c on c.w = i.w and c.id <> i.id
group by i.sku, c.sku
having count(distinct i.w) >= 2
order by tokens desc, i.sku;
