-- Tienda Accu-Chek México · 17-sep-2026 · Roche DC.
-- Ticket: 4 × Softclix 25 ($75.40) + 2 × Softclix 100 ($162.40) = $626.40.
-- Envío gratis. IVA 0% en el comprobante. Folio no venía en la captura.
-- Costo = lista oficial Roche. PVP dueño: $85 las de 25, $180 las de 100.
-- Recargo ~12.7% / ~10.8% (abajo del +25% marca; a la par de Similares $86 las 25).
-- Ficha: tienda.accu-chek.com.mx (EAN 4015630018277 / 4015630018284).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- Stock 0 hasta escanear en Recibir.
-- Fotos en public/catalogo-propia/ (visibles tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_accuchek_20260917 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  receta boolean not null,
  imagen text,
  foto_file text
) on commit drop;

insert into _fc_accuchek_20260917 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, receta,
  imagen, foto_file
) values
  (
    1,
    '4015630018277',
    'FC-30018277',
    'Accu-Chek Softclix lancetas 25 piezas',
    '25 Lancetas Accu-Chek Softclix',
    4,
    75.40,
    85,
    'marca',
    'Diabetes',
    'Lancetas',
    'Lanceta',
    'Accu-Chek',
    'Roche Diabetes Care',
    'Caja con 25 lancetas',
    false,
    'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-25-4015630018277.jpg',
    'catalogo-propia/accu-chek-softclix-25-4015630018277.jpg'
  ),
  (
    2,
    '4015630018284',
    'FC-30018284',
    'Accu-Chek Softclix lancetas 100 piezas',
    '100 Lancetas Accu-Chek Softclix',
    2,
    162.40,
    180,
    'marca',
    'Diabetes',
    'Lancetas',
    'Lanceta',
    'Accu-Chek',
    'Roche Diabetes Care',
    'Caja con 100 lancetas',
    false,
    'https://www.farmacapital.mx/catalogo-propia/accu-chek-softclix-100-4015630018284.jpg',
    'catalogo-propia/accu-chek-softclix-100-4015630018284.jpg'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, laboratorio,
  imagen_url, imagen_mobile_url
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
  t.tipo,
  'Lanceta Accu-Chek Softclix con corte de 3 caras. Superficie lisa y pulida. Alta Tienda Accu-Chek 20260917 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.laboratorio,
  t.imagen,
  t.imagen
from _fc_accuchek_20260917 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

-- Dueño fijó costo de esta compra y PVP de mostrador. Pisa ambos.
update public.productos p
set
  costo = t.costo,
  precio = t.precio,
  activo = true,
  tipo = coalesce(nullif(trim(p.tipo), ''), t.tipo),
  categoria = case
    when coalesce(nullif(trim(p.categoria), ''), '') in ('', 'Otro') then t.categoria
    else p.categoria
  end,
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8
      or p.nombre ~* 'BLOQ|LGEN|FRABEL'
      then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from _fc_accuchek_20260917 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Tienda Accu-Chek',
  '20260917',
  '2026-09-17',
  626.40,
  'borrador',
  'Tienda oficial Accu-Chek · 17-sep-2026 · 4×25 ($75.40) + 2×100 ($162.40) = $626.40 · envío gratis · cola Recibir; stock al confirmar pistola · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '20260917'
    and coalesce(proveedor, '') ilike '%accu-chek%'
);

update public.recepciones
set
  total_ticket = 626.40,
  fecha = '2026-09-17',
  proveedor = 'Tienda Accu-Chek',
  notas = 'Tienda oficial Accu-Chek · 17-sep-2026 · 4×25 ($75.40) + 2×100 ($162.40) = $626.40 · envío gratis · cola Recibir; stock al confirmar pistola · MMAA de la caja',
  updated_at = now()
where folio = '20260917'
  and coalesce(proveedor, '') ilike '%accu-chek%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
  t.qty,
  null,
  null,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_accuchek_20260917 t
join public.recepciones r
  on r.folio = '20260917'
 and coalesce(r.proveedor, '') ilike '%accu-chek%'
 and r.estado = 'borrador'
left join lateral (
  select public.fc_buscar_producto_escaneo(t.ean) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_accuchek_20260917 t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '20260917'
  and coalesce(r.proveedor, '') ilike '%accu-chek%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.precio,
  p.sku as sku_vivo,
  p.stock,
  case when p.id is null then 'PENDIENTE_ALTA' else 'OK' end as match
from _fc_accuchek_20260917 t
left join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
order by t.linea;

-- Por si ya había Softclix sin este EAN (no se toca; solo aviso).
select
  sku,
  codigo_barras as ean,
  left(nombre, 56) as nombre,
  costo,
  precio,
  stock
from public.productos
where nombre ilike '%softclix%'
   or codigo_barras in ('4015630018277', '4015630018284')
order by presentacion, sku;

commit;
