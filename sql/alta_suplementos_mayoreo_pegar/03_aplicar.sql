-- Paso 3 de 3. Pasa las filas al inventario.
-- Exige las 2231 filas de la tabla temporal. No la borra.

-- Pasa staging a productos + referencia de costo. Idempotente.
-- No toca anaquel con stock. Precio público = 0.
-- No borra _fc_cat_sm_stg: si esto falla, las filas siguen ahí.
begin;

do $$
declare
  n int;
begin
  if to_regclass('public._fc_cat_sm_stg') is null then
    raise exception 'No existe _fc_cat_sm_stg. Primero pega 01_cargar_a.sql y 02_cargar_b.sql.';
  end if;
  select count(*) into n from public._fc_cat_sm_stg;
  if n < 2226 then
    raise exception 'La tabla temporal tiene % filas y deben ser 2231. Falta pegar 01_cargar_a.sql y luego 02_cargar_b.sql.', n;
  end if;
end
$$;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, concentracion, forma_farmaceutica, subcategoria,
  imagen_url, bajo_pedido
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(nullif(t.ean, ''), t.sku), 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  t.tipo,
  'Bajo pedido · suplementosmayoreo' || coalesce(' · ' || nullif(trim(t.sku_externo), ''), ''),
  t.costo,
  0,
  0, 1, true, false,
  t.marca, t.presentacion, t.concentracion, t.forma_farmaceutica, t.subcategoria,
  t.imagen_url, true
from public._fc_cat_sm_stg t
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
       concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
       forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma_farmaceutica),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       descripcion = coalesce(
         nullif(trim(p.descripcion), ''),
         'Bajo pedido · suplementosmayoreo' || coalesce(' · ' || nullif(trim(t.sku_externo), ''), '')
       )
  from public._fc_cat_sm_stg t
 where coalesce(p.stock, 0) = 0
   and (
     (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
     or p.sku = t.sku
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'suplementosmayoreo', 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo suplementosmayoreo.com'
  from public._fc_cat_sm_stg t
  join public.productos p
    on p.sku = t.sku
    or (t.ean is not null and (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean)))
 where t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'suplementosmayoreo'
        and r.fecha = current_date
   );

commit;

select
  count(*) filter (where coalesce(bajo_pedido, false) and descripcion like 'Bajo pedido · suplementosmayoreo%') as filas_sm,
  count(*) filter (where coalesce(bajo_pedido, false) and coalesce(precio, 0) <= 0.01) as ordenar
from public.productos;

