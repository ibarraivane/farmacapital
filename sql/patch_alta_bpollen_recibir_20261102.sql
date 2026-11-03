-- ============================================================================
-- FARMACAPITAL — Alta BPOllen 5% y 2.5% (Recibir · sin registrar)
--
-- Pantalla Recibir (Nadro 6091723171): 2 productos sin registrar
--   7502002461306 × 1 · BPOllen gel 5% tubo 60 g · Farmapiel · costo ticket $185.63
--   7502002461290 × 1 · BPOllen gel 2.5% tubo 60 g · Farmapiel · costo ticket $170.78
--
-- SIN bloques dollar-quote (do $$). El SQL Editor de Supabase los corta.
-- Stock 0 hasta escanear + MMAA de la caja. No inventa caducidad.
-- Idempotente. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_bpollen (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  laboratorio text not null,
  presentacion text not null,
  forma text not null,
  principio text not null,
  concentracion text not null,
  categoria text not null,
  subcategoria text not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  imagen text not null
) on commit drop;

insert into _fc_bpollen values
  (
    '7502002461306',
    'FC-02461306',
    'BPOllen gel 5%',
    'BPOllen',
    'Farmapiel',
    'Tubo 60 g',
    'Gel',
    'Peróxido de benzoílo',
    '5%',
    'Dermatología',
    'Acné',
    185.63,
    233,
    'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-5-7502002461306.jpg'
  ),
  (
    '7502002461290',
    'FC-02461290',
    'BPOllen gel 2.5%',
    'BPOllen',
    'Farmapiel',
    'Tubo 60 g',
    'Gel',
    'Peróxido de benzoílo',
    '2.5%',
    'Dermatología',
    'Acné',
    170.78,
    214,
    'https://www.farmacapital.mx/catalogo-propia/bpollen-gel-2.5-7502002461290.jpg'
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
  'Alta Recibir BPOllen · Nadro 6091723171 · listo para pistola',
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
from _fc_bpollen t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  activo = true
from _fc_bpollen t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

-- Enlaza renglones amarillos / pendiente_alta de cualquier ticket vivo.
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false,
  nombre_snapshot = coalesce(
    (select t.nombre from _fc_bpollen t where t.ean = i.codigo_escaneado),
    i.nombre_snapshot
  ),
  costo_estimado = coalesce(
    nullif(i.costo_estimado, 0),
    (select t.costo from _fc_bpollen t where t.ean = i.codigo_escaneado)
  )
where i.codigo_escaneado in ('7502002461306', '7502002461290')
  and coalesce(i.confirmado, false) = false
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null
  and (
    coalesce(i.pendiente_alta, false)
    or i.producto_id is null
    or i.producto_id is distinct from public.fc_buscar_producto_escaneo(i.codigo_escaneado)
  );

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  'catalogo-propia/' || regexp_replace(t.imagen, '^.*/', ''),
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_bpollen t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id
    and (i.url = t.imagen or i.storage_path like '%bpollen%')
);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 40) as nombre,
  p.costo,
  p.precio,
  p.stock,
  case when p.imagen_url is null then 'SIN FOTO' else 'OK' end as foto
from public.productos p
where p.codigo_barras in ('7502002461306', '7502002461290')
   or p.sku in ('FC-02461306', 'FC-02461290')
order by p.codigo_barras;

select
  r.folio,
  r.estado,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 36) as nombre,
  i.cantidad,
  i.pendiente_alta,
  i.producto_id is not null as enlazado,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where i.codigo_escaneado in ('7502002461306', '7502002461290')
order by r.id desc, i.id;
