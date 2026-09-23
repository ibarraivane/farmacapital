-- Bloque 2 de 10. Pasa una parte al inventario.
-- Se puede volver a correr.

begin;

do $$
begin
  if exists (select 1 from pg_trigger where tgname = 'trg_producto_enriquecimiento_job') then
    alter table public.productos disable trigger trg_producto_enriquecimiento_job;
  end if;
end $$;

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
where mod(abs(hashtext(t.sku)::bigint), 10) = 1
  and not exists (select 1 from public.productos p where p.sku = t.sku)
  and (
    t.ean is null
    or not exists (select 1 from public.productos p where p.codigo_barras = t.ean)
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
 where mod(abs(hashtext(t.sku)::bigint), 10) = 1
   and coalesce(p.stock, 0) = 0
   and p.sku = t.sku;

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
 where mod(abs(hashtext(t.sku)::bigint), 10) = 1
   and coalesce(p.stock, 0) = 0
   and t.ean is not null
   and p.codigo_barras = t.ean
   and p.sku is distinct from t.sku;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'suplementosmayoreo', 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo suplementosmayoreo.com'
  from public._fc_cat_sm_stg t
  join public.productos p on p.sku = t.sku
 where mod(abs(hashtext(t.sku)::bigint), 10) = 1
   and t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'suplementosmayoreo'
        and r.fecha = current_date
   );

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select p.id, 'suplementosmayoreo', 'compra', t.costo, t.sku_externo, 'import_csv',
       'mayoreo suplementosmayoreo.com'
  from public._fc_cat_sm_stg t
  join public.productos p on p.codigo_barras = t.ean
 where mod(abs(hashtext(t.sku)::bigint), 10) = 1
   and t.ean is not null
   and p.sku is distinct from t.sku
   and t.costo is not null and t.costo > 0
   and not exists (
     select 1 from public.producto_precios_referencia r
      where r.producto_id = p.id and r.fuente = 'suplementosmayoreo'
        and r.fecha = current_date
   );

do $$
begin
  if exists (select 1 from pg_trigger where tgname = 'trg_producto_enriquecimiento_job') then
    alter table public.productos enable trigger trg_producto_enriquecimiento_job;
  end if;
end $$;

commit;

select count(*) as filas_sm
from public.productos
where descripcion like 'Bajo pedido · suplementosmayoreo%';
