-- ============================================================================
-- Qué está cargado de verdad: fotos lote 4, Equilibrio, Farma MX.
-- Solo lecturas. Pega el resultado y con eso se cierra la duda.
-- ============================================================================

-- 1) Panorama del catálogo
select
  count(*)                                      as productos,
  count(*) filter (where activo)                as activos,
  count(*) filter (where not activo)            as inactivos,
  count(*) filter (where codigo_barras is not null) as con_ean,
  count(*) filter (where codigo_barras is null) as sin_ean,
  count(*) filter (where sku like 'EQ-%')       as sku_equilibrio,
  count(*) filter (where sku like 'FMX-%')      as sku_farmamx,
  count(*) filter (where sku like 'FC-%')       as sku_fotos
from public.productos;

-- 2) ¿Existen las tablas de cada carga?
select
  to_regclass('public.carga_fotos_lote4')          is not null as lote4_fotos,
  to_regclass('public.ticket_equilibrio_440393')   is not null as ticket_equilibrio,
  to_regclass('public.ticket_farmamx_108588')      is not null as ticket_farmamx;

-- 3) Lote 4 (fotos con EAN): cuántos están, cuántos sin costo
select
  count(*)                              as renglones_lote4,
  count(p.id)                           as en_inventario,
  count(*) filter (where p.activo)      as activos,
  count(*) filter (where not p.activo)  as apagados,
  count(*) filter (where coalesce(p.costo, 0) = 0) as sin_costo
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean;

-- 4) Equilibrio: si la tabla existe, cuántas líneas vs SKUs EQ-
select
  (select count(*) from public.ticket_equilibrio_440393) as lineas_ticket,
  (select count(*) from public.productos where sku like 'EQ-%') as altas_eq,
  (select count(*) from public.productos
    where sku like 'EQ-%' and codigo_barras is null) as eq_sin_ean;

-- 5) Farma MX: si la tabla existe, cuántas líneas vs SKUs FMX-
select
  (select count(*) from public.ticket_farmamx_108588) as lineas_ticket,
  (select count(*) from public.productos where sku like 'FMX-%') as altas_fmx,
  (select count(*) from public.productos
    where sku like 'FMX-%' and codigo_barras is null) as fmx_sin_ean;

-- 6) Los dos productos de las fotos de Gelcavit / Veridex sueltas
select sku, nombre, codigo_barras, costo, precio, activo
from public.productos
where codigo_barras in ('7501130709830', '7501471800210', '7502009747366')
   or nombre ilike '%gelcavit%'
   or nombre ilike '%floroglu%'
   or nombre ilike '%veridex%'
order by nombre;
