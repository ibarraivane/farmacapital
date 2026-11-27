-- ============================================================================
-- FARMACAPITAL — Alta Prot-age 30 sobres (Armstrong)
--
-- EAN 7501089805058 · SKU FC-9805058
-- Suplemento alimenticio polvo 2.6 g × 30 sobres
-- Marca Prot-age · laboratorio Armstrong
-- Costo $579 · PVP $550 (precio pedido; bajo costo)
-- Stock 0 hasta Recibir / Inventario. Caducidad null.
--
-- Ficha: prot-age.com.mx / PLM / Fahorro SKU = EAN
-- Foto: catalogo-propia/prot-age-30-sobres-7501089805058.jpg
--
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_prot_age (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  laboratorio text not null,
  presentacion text not null,
  forma text not null,
  principio text not null,
  concentracion text,
  categoria text not null,
  subcategoria text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen text not null
) on commit drop;

insert into _fc_prot_age values
  (
    '7501089805058',
    'FC-9805058',
    'Prot-age',
    'Prot-age',
    'Armstrong',
    'Caja con 30 sobres de 2.6 g',
    'Polvo',
    'Myo-inositol, isoflavonas de soya, polifenoles de cacao',
    '2.6 g',
    'Suplemento',
    'Menopausia / inositol',
    579.00,
    550.00,
    'https://www.farmacapital.mx/catalogo-propia/prot-age-30-sobres-7501089805058.jpg'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  'marca',
  'Alta Prot-age · EAN 7501089805058 · Armstrong · costo 579 · PVP 550',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.laboratorio,
  t.presentacion,
  t.forma,
  t.principio,
  t.concentracion,
  t.imagen,
  t.imagen
from _fc_prot_age t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  nombre = t.nombre,
  marca = t.marca,
  laboratorio = t.laboratorio,
  presentacion = t.presentacion,
  forma_farmaceutica = t.forma,
  principio_activo = t.principio,
  concentracion = t.concentracion,
  categoria = t.categoria,
  subcategoria = t.subcategoria,
  tipo = 'marca',
  codigo_barras = t.ean,
  costo = t.costo,
  precio = t.precio,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  activo = true,
  stock_minimo = greatest(coalesce(p.stock_minimo, 0), 1),
  requiere_receta = false
from _fc_prot_age t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false,
  nombre_snapshot = coalesce(
    (select t.nombre from _fc_prot_age t where t.ean = i.codigo_escaneado),
    i.nombre_snapshot
  ),
  costo_estimado = coalesce(
    nullif(i.costo_estimado, 0),
    (select t.costo from _fc_prot_age t where t.ean = i.codigo_escaneado)
  )
where i.codigo_escaneado = '7501089805058'
  and coalesce(i.confirmado, false) = false
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null
  and (
    coalesce(i.pendiente_alta, false)
    or i.producto_id is null
    or i.producto_id is distinct from public.fc_buscar_producto_escaneo(i.codigo_escaneado)
  );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.laboratorio,
  p.presentacion,
  p.costo,
  p.precio,
  round((p.precio - p.costo) / nullif(p.precio, 0) * 100, 1) as margen_pct,
  p.stock,
  case when p.imagen_url is null then 'SIN FOTO' else 'OK' end as foto
from public.productos p
where p.codigo_barras = '7501089805058'
   or p.sku in ('FC-9805058', 'FC-ND-9805058');
