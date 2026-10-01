-- IFC F8 Tienda · folio 126446 · 2026-09-30 17:02 · CJ 01 · cliente LUIS ANGEL
-- 38 artículos / 12 productos · total $867.00. Costo = P.PUBLICO unitario.
-- Piezas ticket (suma qty): 38. Total $867.00.
-- 10 alta(s) stock 0. 2 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): FC-IFC-CORTA-TRY12, FC-IFC-CORTA-BOBO12, FC-IFC-PINZA-LADY, FC-IFC-YOLI-ENCH, FC-IFC-MYK-IZQ-CH, FC-IFC-MYK-IZQ-GD, FC-IFC-MYK-DER-MD, FC-IFC-MYK-DER-CH, FC-IFC-ALICATA-GDE, FC-IFC-MER-RICINO, FC-D4AC123B.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_ifc_126446 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,3) not null,
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

insert into _fc_ifc_126446 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, null, 'FC-IFC-CORTA-TRY12', 'Cortaúñas Try mediano C/12', 'CORTAUNAS TRY MEDIANO C/12', 1, 75.00, 94, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Try', null, 'Paquete C/12', null, null, false, false, null, null, null),
  (2, null, 'FC-IFC-CORTA-BOBO12', 'Cortaúñas Bobo mediano sin cadena C/12', 'CORTAUNAS BOBO (Z608) MEDIANO S/CADENA C/12 PZS', 1, 65.50, 82, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Bobo', null, 'Paquete C/12', null, null, false, false, null, null, null),
  (3, null, 'FC-IFC-PINZA-LADY', 'Pinza depilar Lady grande', 'PINZA DEPILAR LADY GRANDE', 5, 8.00, 10, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Lady', null, 'Pieza', null, null, false, false, null, null, null),
  (4, null, 'FC-IFC-YOLI-ENCH', 'Yoli enchinador de pestañas', 'YOLI ENCHINADOR', 4, 16.00, 20, 'marca', 'Cuidado personal', 'Maquillaje', 'Accesorio', 'Yoli', null, 'Pieza', null, null, false, false, null, null, null),
  (5, '7501877602203', 'FC-77602203', 'Miyako muñequera tipo guante izquierda neopreno mediana', 'MIYAKO MUNEQUERA T/GUANT IZQUI NEOP MEDI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza mediana izquierda', null, null, false, false, null, null, null),
  (6, null, 'FC-IFC-MYK-IZQ-CH', 'Miyako muñequera tipo guante izquierda neopreno chica', 'MIYAKO MUNEQUERA T/GUANTE IZQUI NEOP CHI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza chica izquierda', null, null, false, false, null, null, null),
  (7, null, 'FC-IFC-MYK-IZQ-GD', 'Miyako muñequera tipo guante izquierda neopreno grande', 'MIYAKO MUNEQUERA T/GUANT IZQUI NEOP GRAN', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza grande izquierda', null, null, false, false, null, null, null),
  (8, null, 'FC-IFC-MYK-DER-MD', 'Miyako muñequera tipo guante derecha neopreno mediana', 'MIYAKO MUNEQUERA T/GUAN DERECH NEOP MEDI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza mediana derecha', null, null, false, false, null, null, null),
  (9, null, 'FC-IFC-MYK-DER-CH', 'Miyako muñequera tipo guante derecha neopreno chica', 'MIYAKO MUNEQUERA T/GUAN DERECH NEOP CHIC', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza chica derecha', null, null, false, false, null, null, null),
  (10, null, 'FC-IFC-ALICATA-GDE', 'Alicata económica mango colores grande', 'ALICATA ECONOMICA MANGO COLORES GDE', 2, 30.00, 38, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', null, null, 'Pieza', null, null, false, false, null, null, null),
  (11, null, 'FC-IFC-MER-RICINO', 'Mercurio aceite de ricino', 'MERCURIO ACEITE RICINO C/25', 10, 9.00, 12, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Aceite', 'Mercurio', null, 'Frasco (caja C/25)', null, null, false, true, null, null, null),
  (12, null, 'FC-D4AC123B', 'Mercurio aceite de almendras', 'MERCURIO ACEITE ALMENDRAS C/25', 10, 8.50, 11, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Aceite', 'Mercurio', null, 'Frasco (caja C/25)', null, null, false, true, null, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta IFC F8 Tienda 126446 · 2026-09-30 · listo para pistola',
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
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_ifc_126446
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_ifc_126446
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_ifc_126446
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'IFC F8 Tienda', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('IFC F8 Tienda')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '126446',
  '2026-09-30',
  867.00,
  'borrador',
  'IFC F8 126446 · 30-sep-2026 · mayoreo+menudeo · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '126446'
    and coalesce(proveedor, '') ilike '%IFC%'
);

update public.recepciones
set
  total_ticket = 867.00,
  fecha = '2026-09-30',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 126446 · 30-sep-2026 · mayoreo+menudeo · MMAA de la caja',
  updated_at = now()
where folio = '126446'
  and coalesce(proveedor, '') ilike '%IFC%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '126446'
  and coalesce(r.proveedor, '') ilike '%IFC%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
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
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_ifc_126446 t
join public.recepciones r
  on r.folio = '126446'
 and coalesce(r.proveedor, '') ilike '%IFC%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
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
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_ifc_126446
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '126446'
  and coalesce(r.proveedor, '') ilike '%IFC%'
order by i.id;
