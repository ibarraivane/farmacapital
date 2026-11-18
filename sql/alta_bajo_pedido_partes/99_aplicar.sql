-- 29 — pasa staging a productos + referencias. Idempotente.
begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Bajo pedido · ' || t.fuente || coalesce(' · ' || t.sku_externo, ''),
  t.costo,
  0,
  0, 1, true, false,
  t.marca, t.presentacion, t.subcategoria, t.imagen_url, true
from public._fc_cat_bp_stg t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or p.sku = t.sku
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = coalesce(t.costo, p.costo),
       precio = 0,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       codigo_barras = case
         when coalesce(nullif(trim(p.codigo_barras), ''), '') <> '' then p.codigo_barras
         when nullif(t.ean, '') is null then p.codigo_barras
         when exists (
           select 1 from public.productos o
           where o.codigo_barras = t.ean and o.id <> p.id
         ) then p.codigo_barras
         else t.ean
       end
  from public._fc_cat_bp_stg t
 where coalesce(p.stock, 0) = 0
   and (
     (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
     or p.sku = t.sku
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, t.fuente, 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo ' || t.fuente
  from public._fc_cat_bp_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
 where t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = t.fuente
        and r.fecha = current_date
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'promexsa', 'compra', t.techo, t.sku_externo, 'import_csv',
       'techo web Promexsa — no es mayoreo'
  from public._fc_cat_bp_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and p.codigo_barras = t.ean)
 where t.fuente = 'ewafra' and t.techo is not null and t.techo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'promexsa'
        and r.fecha = current_date
   );

drop table if exists public._fc_cat_bp_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) > 0.01) as con_precio,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) <= 0.01) as ordenar
from public.productos;
