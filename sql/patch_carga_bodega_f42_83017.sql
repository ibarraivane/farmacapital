-- Bodega F-42 Ejidos del Moral · Caja 2/83017 · 2026-10-02 17:13
-- Ticket térmico. Subtotal $267.20 + impuestos $42.75 = $309.95.
-- Costo = P.U. impreso. EAN Grisi con dígito verificador (037…0 / 810…6).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 4 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_83017 (
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
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_bf42_83017 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '0378360404500', 'FC-36040450', 'Grisi concha nácar crema para manos', 'CRA GRISI CONCHNAC P/MANOS 80 ML', 2, 43.64, 55, 'marca', 'Cuidado personal', null, 'Crema', 'Grisi', 'Grisi', 'Tubo 80 mL', null, null, false, true, null, null, null),
  (2, '8101205017656', 'FC-20501765', 'Grisi aloe vera crema para manos', 'CRA GRISI ALOE VERA P/MANOS 80 ML', 2, 45.15, 57, 'marca', 'Cuidado personal', null, 'Crema', 'Grisi', 'Grisi', 'Tubo 80 mL', null, null, false, true, null, null, null),
  (3, '0378360405354', 'FC-60405354', 'Ricitos de Oro crema corporal lavanda', 'RICITOS DE ORO 100ML CRA CORP LAVANDA', 2, 17.58, 22, 'marca', 'Cuidado personal', 'Bebé', 'Crema', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, false, null, null, null),
  (4, '7501082722116', 'FC-82722116', 'Nuvel crema para manos suaves', 'CRA NUVEL P/MANOS SUAVES 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', null, 'Crema', 'Nuvel', 'Nuvel', 'Tubo 65 mL', null, null, false, false, null, null, null),
  (5, '0378360415940', 'FC-60415940', 'Ricitos de Oro colonia avena y vainilla', 'RICITOS DE ORO 100ML COLONIA AVENA Y VNLLA', 2, 19.90, 25, 'marca', 'Cuidado personal', 'Bebé', 'Colonia', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, false, null, null, null),
  (6, '7501082722123', 'FC-82722123', 'Nuvel crema para manos hidratada', 'CRA NUVEL P/MANOS HIDRATADA 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', null, 'Crema', 'Nuvel', 'Nuvel', 'Tubo 65 mL', null, null, false, false, null, null, null),
  (7, '7501022104248', 'FC-21042481', 'Ricitos de Oro crema corporal', 'CRA RICITOS DE ORO 100ML', 1, 30.43, 39, 'marca', 'Cuidado personal', 'Bebé', 'Crema', 'Ricitos de Oro', 'Grisi', 'Frasco 100 mL', null, null, false, true, null, null, null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
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
  'Alta Bodega F-42 83017 · 2026-10-02 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (ean) *
  from _fc_bf42_83017
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_bf42_83017
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_bf42_83017
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '83017',
  '2026-10-02',
  309.95,
  'borrador',
  'Ticket Bodega F-42 Caja 2/83017 · 02-oct-2026 · tarjeta $309.95 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '83017'
    and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = 309.95,
  fecha = '2026-10-02',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 Caja 2/83017 · 02-oct-2026 · tarjeta $309.95 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '83017'
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '83017'
  and coalesce(r.proveedor, '') ilike '%bodega%'
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
  t.lote,
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
from _fc_bf42_83017 t
join public.recepciones r
  on r.folio = '83017'
 and coalesce(r.proveedor, '') ilike '%bodega%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
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
from _fc_bf42_83017 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
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
where r.folio = '83017'
  and coalesce(r.proveedor, '') ilike '%bodega%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_83017 t
order by t.linea;

commit;
