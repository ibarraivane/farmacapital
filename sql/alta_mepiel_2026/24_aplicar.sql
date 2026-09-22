-- 24 — pasa staging a productos + referencia mepiel.
-- No pisa anaquel (stock > 0) ni un precio que el dueño ya haya publicado.
-- Si el EAN ya está en Dermaexpress u otro mayoreo, el costo se queda con el más barato.
begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, subcategoria, imagen_url, bajo_pedido,
  concentracion, forma_farmaceutica
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(t.ean, ''),
  t.categoria,
  'marca',
  'Bajo pedido · mepiel'
    || coalesce(' · ' || nullif(t.linea, ''), '')
    || coalesce(' · oferta ' || nullif(t.oferta, ''), ''),
  t.costo,
  0,
  0, 1, true, false,
  t.marca, t.presentacion, t.subcategoria, nullif(t.imagen_url, ''), true,
  nullif(t.concentracion, ''), nullif(t.forma, '')
from public._fc_mepiel_stg t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean or p.sku = t.sku
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       costo = case
         when p.costo is null or p.costo <= 0 then t.costo
         when t.costo < p.costo then t.costo
         else p.costo
       end,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), nullif(t.presentacion, '')),
       concentracion = coalesce(nullif(trim(p.concentracion), ''), nullif(t.concentracion, '')),
       forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), nullif(t.forma, '')),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), nullif(t.imagen_url, '')),
       subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria)
  from public._fc_mepiel_stg t
 where coalesce(p.stock, 0) = 0
   and coalesce(p.precio, 0) <= 0.01
   and (
     p.codigo_barras = t.ean
     or p.id = public.fc_buscar_producto_escaneo(t.ean)
   );

delete from public.producto_precios_referencia r
 using public._fc_mepiel_stg t
 join public.productos p
   on p.codigo_barras = t.ean
   or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where r.producto_id = p.id
   and r.fuente = 'mepiel'
   and r.origen = 'import_xlsx'
   and r.fecha = current_date;

insert into public.producto_precios_referencia
  (producto_id, fuente, tipo, precio, sku_externo, origen, notas)
select distinct on (p.id)
  p.id, 'mepiel', 'compra', t.costo, t.ean, 'import_xlsx',
  'Lista ME Piel 2026 · precio cliente c/IVA'
    || coalesce(' · PVP c/IVA ' || t.techo::text, '')
    || coalesce(' · oferta ' || nullif(t.oferta, ''), '')
  from public._fc_mepiel_stg t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where t.costo is not null and t.costo > 0
 order by p.id, t.costo;

drop table if exists public._fc_mepiel_stg;
commit;

select
  count(*) filter (where coalesce(bajo_pedido, false)) as bajo_pedido,
  count(*) filter (
    where coalesce(bajo_pedido, false)
      and descripcion ilike '%mepiel%'
  ) as alta_mepiel_nueva
from public.productos;
