-- Aceite Madrid (Farma Mayoreo 305016) → Aceite de almendras dulces 125 ml
-- El térmico decía «MADRID ACEITE DE» y se dejó el nombre corto a propósito.
-- Fotos de mostrador 19-sep-2026: etiqueta «Aceite de ALMENDRAS DULCES»,
-- Contenido Neto 125 ml, EAN 7506313000513 (botella), lab AMSA / Rebotica Madrid.
-- No toca stock, costo, precio ni caducidad.
--
-- Foto: public/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg
-- ORDEN: 1) merge/deploy de este PR  2) pegar TODO en Supabase → Run.
-- Idempotente. SIN do $$.

begin;

-- Si el alta de #278 no se pegó, créalo ya con la ficha buena.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, laboratorio, presentacion, forma_farmaceutica,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Aceite de almendras dulces Madrid 125 ml',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-313000513'
        and coalesce(p.codigo_barras, '') not in ('7506313000513', '75063130005133')
    ) then 'FC-ND-313000513'
    else 'FC-313000513'
  end,
  '7506313000513',
  'Cuidado personal',
  'Piel',
  'marca',
  'Aceite de almendras dulces. Frasco 125 ml. Uso tópico.',
  'Madrid',
  'AMSA',
  'Frasco 125 ml',
  'Aceite',
  30.90,
  39,
  'https://www.farmacapital.mx/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  'https://www.farmacapital.mx/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  0, 1, true, false
where public.fc_buscar_producto_escaneo('7506313000513') is null
  and public.fc_buscar_producto_escaneo('75063130005133') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7506313000513', '75063130005133')
       or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
       or p.nombre = 'Aceite Madrid'
  );

update public.productos
set
  nombre = 'Aceite de almendras dulces Madrid 125 ml',
  marca = 'Madrid',
  laboratorio = coalesce(nullif(btrim(laboratorio), ''), 'AMSA'),
  presentacion = 'Frasco 125 ml',
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Aceite'),
  categoria = coalesce(nullif(btrim(categoria), ''), 'Cuidado personal'),
  subcategoria = coalesce(nullif(btrim(subcategoria), ''), 'Piel'),
  tipo = 'marca',
  codigo_barras = '7506313000513',
  descripcion = 'Aceite de almendras dulces. Frasco 125 ml. Uso tópico.',
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  activo = true
where codigo_barras in ('7506313000513', '75063130005133')
   or sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
   or nombre = 'Aceite Madrid';

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  'catalogo-propia/madrid-aceite-almendras-dulces-125ml.jpg',
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'propia'
from public.productos p
where (
    p.codigo_barras = '7506313000513'
    or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
  )
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/madrid-aceite-almendras-dulces-125ml%'
  );

update public.producto_imagenes i
set es_principal = false
from public.productos p
where i.producto_id = p.id
  and i.es_principal
  and (
    p.codigo_barras = '7506313000513'
    or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
  )
  and i.url not like '%catalogo-propia/madrid-aceite-almendras-dulces-125ml%';

update public.producto_imagenes i
set es_principal = true
from public.productos p
where i.producto_id = p.id
  and i.es_principal is distinct from true
  and (
    p.codigo_barras = '7506313000513'
    or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
  )
  and i.url like '%catalogo-propia/madrid-aceite-almendras-dulces-125ml%';

-- Recibir 305016: el renglón gris deja de decir «Aceite Madrid»
update public.recepcion_items i
set nombre_snapshot = 'Aceite de almendras dulces Madrid 125 ml'
from public.recepciones r
where r.id = i.recepcion_id
  and r.folio = '305016'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and (
    i.codigo_escaneado in ('7506313000513', '75063130005133')
    or i.producto_id in (
      select p.id from public.productos p
      where p.codigo_barras = '7506313000513'
         or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
    )
    or i.nombre_snapshot = 'Aceite Madrid'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.laboratorio,
  p.presentacion,
  p.forma_farmaceutica,
  p.categoria,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 90) as foto
from public.productos p
where p.codigo_barras = '7506313000513'
   or p.sku in ('FC-313000513', 'FC-ND-313000513', 'FC-13000513')
   or p.nombre ilike '%almendras dulces madrid%';

select
  i.id,
  i.codigo_escaneado as ean,
  i.nombre_snapshot,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  i.fecha_caducidad,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '305016'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
  and (
    i.codigo_escaneado in ('7506313000513', '75063130005133')
    or i.nombre_snapshot ilike '%almendras%'
    or i.nombre_snapshot ilike '%aceite madrid%'
  );
