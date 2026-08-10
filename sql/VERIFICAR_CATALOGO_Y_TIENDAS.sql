-- Verificación rápida post-carga inventario
-- Ejecutar en Supabase SQL Editor

-- 1) ¿Faltan nombres limpios? (debería tender a 0 después del PASO 1)
select
  count(*) filter (
    where nombre ~* 'descto|lab pisa|\$|\|'
      or nombre like '%Ticket%'
  ) as nombres_sucios,
  count(*) filter (where marca is not null and btrim(marca) <> '') as con_marca,
  count(*) filter (where presentacion is not null and btrim(presentacion) <> '') as con_presentacion,
  count(*) as total_fc
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

-- 2) Muestra de productos que aún están sucios (máx 15)
select sku, left(nombre, 70) as nombre, marca, presentacion
from public.productos
where sku like 'FC-%'
  and (nombre ~* 'descto|lab pisa|\$|\|' or nombre like '%Ticket%')
order by sku
limit 15;

-- 3) Electrolit (ejemplo que debe quedar limpio)
select sku, nombre, marca, presentacion, forma_farmaceutica, precio
from public.productos
where sku in ('FC-51448511', 'FC-25104411', 'FC-25149221', 'FC-25104268', 'FC-51747971')
order by sku;

-- 4) Tiendas en lotes (esperado: ~6 tiendas, 569 lotes con proveedor)
select pr.nombre as tienda, count(*) as lotes
from public.lotes l
join public.proveedores pr on pr.id = l.proveedor_id
where coalesce(l.activo, true)
group by pr.nombre
order by lotes desc;

-- 5) Resumen lotes / barcodes
select
  count(*) filter (where coalesce(l.activo, true)) as lotes_activos,
  count(*) filter (where coalesce(l.activo, true) and l.proveedor_id is not null) as lotes_con_tienda
from public.lotes l;

select
  count(*) filter (where codigo_barras is not null and btrim(codigo_barras) <> '') as con_barcode,
  count(*) as total_fc
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';
