-- ============================================================================
-- Ideliver Pro duloxetina 30 mg C/7 · Maver · EAN 7502009745485
--
-- Distinto de Ideliver Pro 60 mg C/14 (EQ-MAV236 · 7502009745478).
-- 4 cajas físicas · costo y PVP = 0 (los pone el dueño después).
-- Stock 0 hasta Recibir: escanear pistola + MMAA de la caja. No inventar 0000.
--
-- Foto: public/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg
--       packshot Farmatodo (tras deploy → farmacapital.mx/catalogo-propia/…).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  'Ideliver Pro duloxetina 30 mg',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-09745485'
        and coalesce(p.codigo_barras, '') <> '7502009745485'
    ) then 'FC-ND-09745485'
    else 'FC-09745485'
  end,
  '7502009745485',
  'Medicamentos',
  'Antidepresivo',
  'marca',
  'Alta Ideliver Pro 30 mg C/7 · Maver · 4 cajas · costo/PVP pendiente · listo para pistola',
  0,
  0,
  0,
  1,
  true,
  true,
  'Ideliver Pro',
  'Caja con 7 tabletas de liberación retardada',
  'Tableta',
  'Duloxetina',
  '30 mg',
  'Maver',
  'https://www.farmacapital.mx/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg',
  'https://www.farmacapital.mx/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg'
where public.fc_buscar_producto_escaneo('7502009745485') is null
  and public.fc_buscar_producto_escaneo('FC-09745485') is null;

-- Si ya existía: ficha vacía / foto. No pisa costo/PVP que ya haya puesto el dueño.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then 'Ideliver Pro duloxetina 30 mg'
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), 'Ideliver Pro'),
  presentacion = coalesce(
    nullif(trim(p.presentacion), ''),
    'Caja con 7 tabletas de liberación retardada'
  ),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), 'Duloxetina'),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), '30 mg'),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), 'Maver'),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), 'Tableta'),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), 'Antidepresivo'),
  categoria = coalesce(nullif(trim(p.categoria), ''), 'Medicamentos'),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  requiere_receta = true,
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), '7502009745485'),
  imagen_url = coalesce(
    nullif(trim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg'
  )
where p.id = coalesce(
  public.fc_buscar_producto_escaneo('7502009745485'),
  public.fc_buscar_producto_escaneo('FC-09745485')
);

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg',
  'catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg',
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from public.productos p
where p.id = coalesce(
  public.fc_buscar_producto_escaneo('7502009745485'),
  public.fc_buscar_producto_escaneo('FC-09745485')
)
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (
        i.url like '%ideliver-pro-duloxetina-30mg-c7-7502009745485%'
        or i.storage_path = 'catalogo-propia/ideliver-pro-duloxetina-30mg-c7-7502009745485.jpg'
      )
  );

-- Cola Recibir: 4 cajas. Stock al confirmar pistola + MMAA. Costo null (pendiente).
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Mostrador',
  'IDELIVER-30-4',
  '2026-10-03',
  0,
  'borrador',
  'Ideliver Pro duloxetina 30 mg C/7 · 4 cajas · costo/PVP pendiente · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'IDELIVER-30-4'
    and coalesce(proveedor, '') ilike '%mostrador%'
);

update public.recepciones
set
  total_ticket = 0,
  fecha = '2026-10-03',
  proveedor = 'Mostrador',
  notas = 'Ideliver Pro duloxetina 30 mg C/7 · 4 cajas · costo/PVP pendiente · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = 'IDELIVER-30-4'
  and coalesce(proveedor, '') ilike '%mostrador%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'IDELIVER-30-4'
  and coalesce(r.proveedor, '') ilike '%mostrador%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  public.fc_buscar_producto_escaneo('7502009745485'),
  '7502009745485',
  'Ideliver Pro duloxetina 30 mg',
  4,
  null,
  null,
  null,
  (public.fc_buscar_producto_escaneo('7502009745485') is null),
  'pdf',
  false,
  (
    public.fc_buscar_producto_escaneo('7502009745485') is not null
    and exists (
      select 1 from public.lotes l
      where l.producto_id = public.fc_buscar_producto_escaneo('7502009745485')
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from public.recepciones r
where r.folio = 'IDELIVER-30-4'
  and coalesce(r.proveedor, '') ilike '%mostrador%'
  and r.estado = 'borrador';

-- Diagnóstico
select
  p.id,
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.costo,
  p.precio,
  p.stock,
  p.marca,
  p.presentacion
from public.productos p
where p.id = coalesce(
  public.fc_buscar_producto_escaneo('7502009745485'),
  public.fc_buscar_producto_escaneo('FC-09745485')
);

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
where r.folio = 'IDELIVER-30-4'
  and coalesce(r.proveedor, '') ilike '%mostrador%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;
