-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase - SQL Editor - Run
-- Levic A 9012600253 · 02-nov-2026 · $649.90 · 1 renglón / 2 pzas
-- Merge a GitHub NO crea la tarjeta. Este Run si.
-- Sin temp tables. Sin dollar-quote. Idempotente en borrador.
-- Al final: VERIFICACION con folio 9012600253 en borrador.
-- Luego: tablet Recibir - recargar.
-- =============================================================================
-- Clave MAV381 = Gladiatron (Maver) 1500/1200 mg C/30. EAN 7502009749018.
-- Costo $324.95 · PVP marca +25% = $407. Lote 264793. Caducidad null (MMAA caja).

-- 1) Alta producto (solo si no existe)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, laboratorio, presentacion, forma_farmaceutica,
  principio_activo, concentracion, imagen_url, imagen_mobile_url
)
select
  'Gladiatron 1500/1200 mg',
  'FC-09749018',
  '7502009749018',
  'Medicamentos',
  'marca',
  'Alta Levic 9012600253 · MAV381 · listo para pistola',
  324.95,
  407,
  0,
  1,
  true,
  false,
  'Gladiatron',
  'Maver',
  'Caja con 30 sobres',
  'Polvo',
  'Glucosamina / condroitina',
  '1500/1200 mg',
  'https://www.farmacapital.mx/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg',
  'https://www.farmacapital.mx/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg'
where not exists (
  select 1 from public.productos
  where codigo_barras = '7502009749018' or sku = 'FC-09749018'
)
and public.fc_buscar_producto_escaneo('7502009749018') is null;

-- 2) Completar ficha / costo si ya existia
update public.productos
set
  codigo_barras = '7502009749018',
  costo = 324.95,
  precio = case when coalesce(precio, 0) <= 0 then 407 else precio end,
  nombre = case
    when length(trim(coalesce(nombre, ''))) < 8 then 'Gladiatron 1500/1200 mg'
    else nombre
  end,
  marca = coalesce(nullif(trim(marca), ''), 'Gladiatron'),
  laboratorio = coalesce(nullif(trim(laboratorio), ''), 'Maver'),
  presentacion = coalesce(nullif(trim(presentacion), ''), 'Caja con 30 sobres'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'Polvo'),
  principio_activo = coalesce(nullif(trim(principio_activo), ''), 'Glucosamina / condroitina'),
  concentracion = coalesce(nullif(trim(concentracion), ''), '1500/1200 mg'),
  imagen_url = coalesce(
    nullif(trim(imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(trim(imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/gladiatron-1500-1200-c30-7502009749018.jpg'
  ),
  activo = true,
  tipo = coalesce(nullif(trim(tipo), ''), 'marca')
where sku = 'FC-09749018'
   or codigo_barras = '7502009749018'
   or id = public.fc_buscar_producto_escaneo('7502009749018');

-- 3) Reabrir a borrador solo si no hay stock ya recibido
update public.recepciones
set estado = 'borrador', updated_at = now()
where folio = '9012600253'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado is distinct from 'borrador'
  and not exists (
    select 1 from public.recepcion_items i
    where i.recepcion_id = recepciones.id
      and i.lote_id is not null
  );

-- 4) Cabecera recepcion
insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Levic',
  '9012600253',
  '2026-11-02',
  649.90,
  'borrador',
  'Factura Levic A 9012600253 · CFDI B7385380-DAD5-497D-AAEE-05AA746339DA · Gladiatron MAV381 · $649.90 · cola Recibir; stock al confirmar pistola · lote de fabrica; MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '9012600253' and coalesce(proveedor, '') ilike '%levic%'
);

update public.recepciones
set
  total_ticket = 649.90,
  fecha = '2026-11-02',
  proveedor = 'Levic',
  notas = 'Factura Levic A 9012600253 · CFDI B7385380-DAD5-497D-AAEE-05AA746339DA · Gladiatron MAV381 · $649.90 · cola Recibir; stock al confirmar pistola · lote de fabrica; MMAA de la caja',
  updated_at = now()
where folio = '9012600253'
  and coalesce(proveedor, '') ilike '%levic%'
  and estado = 'borrador';

-- 5) Renglones (solo en borrador)
delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  coalesce(
    public.fc_buscar_producto_escaneo('7502009749018'),
    public.fc_buscar_producto_escaneo('FC-09749018')
  ),
  '7502009749018',
  'Gladiatron 1500/1200 mg',
  2,
  null,
  '264793',
  324.95,
  (
    coalesce(
      public.fc_buscar_producto_escaneo('7502009749018'),
      public.fc_buscar_producto_escaneo('FC-09749018')
    ) is null
  ),
  'pdf',
  false,
  (
    coalesce(
      public.fc_buscar_producto_escaneo('7502009749018'),
      public.fc_buscar_producto_escaneo('FC-09749018')
    ) is not null
    and exists (
      select 1 from public.lotes l
      where l.producto_id = coalesce(
          public.fc_buscar_producto_escaneo('7502009749018'),
          public.fc_buscar_producto_escaneo('FC-09749018')
        )
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from '264793'
    )
  ),
  null
from public.recepciones r
where r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
  and r.estado = 'borrador';

-- VERIFICACION
select
  r.proveedor,
  r.folio,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  coalesce(sum(i.cantidad), 0) as piezas,
  count(*) filter (where not coalesce(i.confirmado, false)) as sin_confirmar,
  bool_or(coalesce(i.pendiente_alta, false)) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
group by r.id, r.proveedor, r.folio, r.estado, r.total_ticket;

select
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote as lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'OK' end as estado,
  p.sku,
  p.precio
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '9012600253'
  and coalesce(r.proveedor, '') ilike '%levic%'
order by i.id;
