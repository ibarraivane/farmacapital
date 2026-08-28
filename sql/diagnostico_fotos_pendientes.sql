-- ============================================================================
-- FARMA CAPITAL — Que falta de los productos cargados por foto
-- Solo lecturas. No modifica nada.
-- ============================================================================
-- Responde: cuales quedaron sin EAN, cuales sin nombre real, cuales sin costo
-- y donde hay EAN duplicado.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) Sin nombre real (se creo desde la foto del codigo de barras solamente)
-- ---------------------------------------------------------------------------
select 'sin nombre real' as problema, sku, nombre, codigo_barras, costo, activo
from public.productos
where nombre ilike 'Producto %'
   or nombre ilike '[REVISAR-EAN]%'
   or nombre ilike '% side panel%'
   or nombre ilike '%(identificar)%'
order by sku;

-- ---------------------------------------------------------------------------
-- 2) Sin codigo de barras (llego la foto principal pero no la del EAN)
-- ---------------------------------------------------------------------------
select 'sin EAN' as problema, sku, nombre, marca, costo, activo
from public.productos
where coalesce(btrim(codigo_barras), '') = ''
  and activo = true
order by nombre;

-- ---------------------------------------------------------------------------
-- 3) Sin costo real (0 o el placeholder 0.01)
-- ---------------------------------------------------------------------------
select 'sin costo' as problema, sku, nombre, codigo_barras, costo, precio,
       l.numero_lote, l.fecha_caducidad
from public.productos p
left join lateral (
  select numero_lote, fecha_caducidad
  from public.lotes where producto_id = p.id order by id limit 1
) l on true
where coalesce(p.costo, 0) <= 0.01
  and p.activo = true
order by p.nombre;

-- ---------------------------------------------------------------------------
-- 4) Sin caducidad registrada
-- ---------------------------------------------------------------------------
select 'sin caducidad' as problema, p.sku, p.nombre, l.numero_lote
from public.productos p
join public.lotes l on l.producto_id = p.id
where l.fecha_caducidad is null
  and p.activo = true
order by p.nombre;

-- ---------------------------------------------------------------------------
-- 5) EAN repetido en mas de un producto (fusion pendiente)
-- ---------------------------------------------------------------------------
select 'EAN duplicado' as problema, codigo_barras,
       count(*) as veces,
       string_agg(sku || ' = ' || nombre, ' | ' order by sku) as productos
from public.productos
where coalesce(btrim(codigo_barras), '') <> ''
group by codigo_barras
having count(*) > 1
order by codigo_barras;

-- ---------------------------------------------------------------------------
-- 6) Resumen
-- ---------------------------------------------------------------------------
select
  count(*) filter (where nombre ilike 'Producto %' or nombre ilike '[REVISAR-EAN]%')            as sin_nombre_real,
  count(*) filter (where coalesce(btrim(codigo_barras), '') = '')                               as sin_ean,
  count(*) filter (where coalesce(costo, 0) <= 0.01)                                            as sin_costo,
  count(*)                                                                                       as total_activos
from public.productos
where activo = true;
