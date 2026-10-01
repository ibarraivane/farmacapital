-- Tickets 30-sep-2026 · TODOS (Baracentro, IFC, Dulcería, Cityfarma, Equilibrio, F-42)
-- Preferible pegar cada patch_carga_*.sql por separado si el editor corta.

-- ===== baracentro_14438 =====
-- Baracentro · folio 14438 · 2026-09-30 17:25 · Central de Abasto F34 B
-- 1 pieza · total $95.00. P.U. = costo.
-- Piezas ticket (suma qty): 1. Total $95.00.
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): ninguno.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bara_14438 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_bara_14438 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501438363321', 'FC-38363321', 'Kuul Fix Me Urban gel fijador', 'KUUL FIX ME URB', 1, 95.00, 119, 'marca', 'Cuidado personal', 'Cabello', 'Gel', 'Kuul', null, 'Pieza', null, null, false, false, null, null, null);

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
  'Alta Baracentro 14438 · 2026-09-30 · listo para pistola',
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
  from _fc_bara_14438
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
  from _fc_bara_14438
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
  from _fc_bara_14438
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Baracentro', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Baracentro')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Baracentro',
  '14438',
  '2026-09-30',
  95.00,
  'borrador',
  'Baracentro 14438 · 30-sep-2026 · Kuul Fix Me Urban · stock al escanear'
where not exists (
  select 1 from public.recepciones
  where folio = '14438'
    and coalesce(proveedor, '') ilike '%Baracentro%'
);

update public.recepciones
set
  total_ticket = 95.00,
  fecha = '2026-09-30',
  proveedor = 'Baracentro',
  notas = 'Baracentro 14438 · 30-sep-2026 · Kuul Fix Me Urban · stock al escanear',
  updated_at = now()
where folio = '14438'
  and coalesce(proveedor, '') ilike '%Baracentro%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '14438'
  and coalesce(r.proveedor, '') ilike '%Baracentro%'
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
from _fc_bara_14438 t
join public.recepciones r
  on r.folio = '14438'
 and coalesce(r.proveedor, '') ilike '%Baracentro%'
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
  from _fc_bara_14438
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
where r.folio = '14438'
  and coalesce(r.proveedor, '') ilike '%Baracentro%'
order by i.id;


-- ===== ifc_126446 =====
-- IFC F8 Tienda · folio 126446 · 2026-09-30 17:02 · CJ 01 · cliente LUIS ANGEL
-- 38 artículos / 12 productos · total $867.00. Costo = P.PUBLICO unitario.
-- Piezas ticket (suma qty): 38. Total $867.00.
-- 9 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): FC-IFC-MYK-IZQ-CH, FC-IFC-MYK-IZQ-GD, FC-IFC-MYK-DER-MD, FC-IFC-MYK-DER-CH, FC-D4AC123B.
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
  costo numeric(12,4) not null,
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
  (1, '6932119800025', 'FC-19800025', 'Cortaúñas Try mediano C/12', 'CORTAUNAS TRY MEDIANO C/12', 1, 75.00, 94, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Try', null, 'Paquete C/12 (no venta individual)', null, null, false, false, null, null, null),
  (2, '6976824588236', 'FC-24588236', 'Cortaúñas Bobo mediano sin cadena C/12', 'CORTAUNAS BOBO (Z608) MEDIANO S/CADENA C/12 PZS', 1, 65.50, 82, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Bobo', null, 'Paquete C/12', null, null, false, false, null, null, null),
  (3, '7501370204577', 'FC-70204577', 'Curtis Lady pinza tijera cejas', 'PINZA DEPILAR LADY GRANDE', 5, 8.00, 10, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', 'Curtis', 'Curtis', '1 pieza · modelo 57LC', null, null, false, true, null, null, null),
  (4, '7501370202023', 'FC-70202023', 'Yoli enchinador de pestañas', 'YOLI ENCHINADOR', 4, 16.00, 20, 'marca', 'Cuidado personal', 'Maquillaje', 'Accesorio', 'Yoli', 'Curtis', '1 pieza · modelo 102CV', null, null, false, false, null, null, null),
  (5, '7501877602203', 'FC-77602203', 'Miyako muñequera tipo guante izquierda neopreno mediana', 'MIYAKO MUNEQUERA T/GUANT IZQUI NEOP MEDI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza mediana izquierda', null, null, false, false, null, null, null),
  (6, null, 'FC-IFC-MYK-IZQ-CH', 'Miyako muñequera tipo guante izquierda neopreno chica', 'MIYAKO MUNEQUERA T/GUANTE IZQUI NEOP CHI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza chica izquierda', null, null, false, false, null, null, null),
  (7, null, 'FC-IFC-MYK-IZQ-GD', 'Miyako muñequera tipo guante izquierda neopreno grande', 'MIYAKO MUNEQUERA T/GUANT IZQUI NEOP GRAN', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza grande izquierda', null, null, false, false, null, null, null),
  (8, null, 'FC-IFC-MYK-DER-MD', 'Miyako muñequera tipo guante derecha neopreno mediana', 'MIYAKO MUNEQUERA T/GUAN DERECH NEOP MEDI', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza mediana derecha', null, null, false, false, null, null, null),
  (9, null, 'FC-IFC-MYK-DER-CH', 'Miyako muñequera tipo guante derecha neopreno chica', 'MIYAKO MUNEQUERA T/GUAN DERECH NEOP CHIC', 1, 77.50, 97, 'marca', 'Botiquín', 'Soportes', 'Muñequera', 'Miyako', null, 'Pieza chica derecha', null, null, false, false, null, null, null),
  (10, '6855265655229', 'FC-65655229', 'Alicata / set manicure económico mango colores', 'ALICATA ECONOMICA MANGO COLORES GDE', 2, 30.00, 38, 'marca', 'Cuidado personal', 'Manicure', 'Accesorio', null, null, 'Pieza / set', null, null, false, false, null, null, null),
  (11, '3311000001292', 'FC-00001292', 'Mercurio aceite de ricino 50 ml', 'MERCURIO ACEITE RICINO C/25', 10, 9.00, 12, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Aceite', 'Mercurio', 'Droguería Mercurio', 'Frasco 50 ml', null, null, false, true, null, null, null),
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


-- ===== dulceria_victoria_T280035422 =====
-- Dulcería La Victoria · nota T280035422 · 2026-09-30 17:25
-- Ticket imprime «DULCERIA LA FAMOSA» (WinCaja); negocio La Victoria F-20.
-- SKITTLES ORIGINAL 24/10PZ ×2 cajas → 48 bolsas · P.U. caja $74.60 → $3.1083/bolsa.
-- Total tarjeta $149.20.
-- Piezas ticket (suma qty): 48. Total $149.20.
-- 0 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): FC-LV-SKITTLES24.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_lv_t280035422 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_lv_t280035422 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, null, 'FC-LV-SKITTLES24', 'Skittles Original bolsa', 'SKITTLES ORIGINAL, 24/10PZ.', 48, 3.1083, 4, 'marca', 'Impulso', 'Dulces', 'Bolsa', 'Skittles', null, 'Bolsa (caja mayoreo 24/10PZ)', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/skittles-original-22g.jpg', 'catalogo-propia/skittles-original-22g.jpg', null);

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
  'Alta Dulcería La Victoria T280035422 · 2026-09-30 · listo para pistola',
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
  from _fc_lv_t280035422
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
  from _fc_lv_t280035422
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
  from _fc_lv_t280035422
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Dulcería La Victoria', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Dulcería La Victoria')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Dulcería La Victoria',
  'T280035422',
  '2026-09-30',
  149.20,
  'borrador',
  'La Famosa/La Victoria T280035422 · Skittles 48 bolsas (2×24 mayoreo) · EAN pendiente de caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'T280035422'
    and coalesce(proveedor, '') ilike '%Victoria%'
);

update public.recepciones
set
  total_ticket = 149.20,
  fecha = '2026-09-30',
  proveedor = 'Dulcería La Victoria',
  notas = 'La Famosa/La Victoria T280035422 · Skittles 48 bolsas (2×24 mayoreo) · EAN pendiente de caja',
  updated_at = now()
where folio = 'T280035422'
  and coalesce(proveedor, '') ilike '%Victoria%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'T280035422'
  and coalesce(r.proveedor, '') ilike '%Victoria%'
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
from _fc_lv_t280035422 t
join public.recepciones r
  on r.folio = 'T280035422'
 and coalesce(r.proveedor, '') ilike '%Victoria%'
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
  from _fc_lv_t280035422
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
where r.folio = 'T280035422'
  and coalesce(r.proveedor, '') ilike '%Victoria%'
order by i.id;


-- ===== cityfarma_s327411 =====
-- Cityfarma · S327411 · 2026-09-30 17:22 · Pasillo E-F 44A
-- 43 piezas / 13 productos · pendiente $4,165.25 (= subtotal + IVA 16%).
-- Costo = P.U. unitario del ticket. Pasta Lassar EAN 7501417006133 (check digit).
-- Piezas ticket (suma qty): 43. Total $4165.25.
-- 0 alta(s) stock 0. 13 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): ninguno.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cf_s327411 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_cf_s327411 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501349014190', 'EQ-AMS147', 'Ácido alendrónico AMSA 10 mg C/30', 'ACIDO ALENDRONICO 70', 5, 23.87, 39, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 30 tabletas', 'Ácido alendrónico', '10 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/alendronico-10-7501349014190.jpg', 'catalogo-propia/alendronico-10-7501349014190.jpg', null),
  (2, '7501300450227', 'FC-00450227', 'Bactrim suspensión 200/40 mg 100 ml', 'BACTRIM SUSP 200/40M', 3, 185.63, 233, 'marca', 'Medicamentos', null, 'Suspensión', 'Bactrim', 'Roche', 'Frasco 100 ml', 'Sulfametoxazol / trimetoprima', '200/40 mg/5 ml', true, true, null, null, null),
  (3, '7501008427330', 'FC-08427330', 'Bepanthen pomada 100 g', 'BEPANTHEN 100GR POM', 2, 131.67, 165, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer', 'Tubo 100 g', 'Dexpantenol', null, false, true, null, null, null),
  (4, '7501008427347', 'FC-08427347', 'Bepanthen pomada 30 g', 'BEPANTHEN 30GR', 3, 64.37, 81, 'marca', 'Dermocosmético', 'Piel', 'Pomada', 'Bepanthen', 'Bayer', 'Tubo 30 g', 'Dexpantenol', null, false, true, null, null, null),
  (5, '7506022331502', 'EQ-JAY263', 'Diflosensi dapagliflozina 10 mg C/28', 'DIFLOSENSI 10MG C28', 4, 298.91, 479, 'generico', 'Medicamentos', null, 'Tableta', 'Diflosensi', null, 'Caja con 28 tabletas', 'Dapagliflozina', '10 mg', true, true, null, null, null),
  (6, '7501390912599', 'FC-90912599', 'Lactiflora Fem probiótico', 'LACTIFLORA FEM PROBI', 1, 362.93, 454, 'marca', 'Vitaminas', null, 'Cápsula', 'Lactiflora', null, 'Caja', null, null, false, true, null, null, null),
  (7, '7501109902866', 'FC-09902866', 'Motrin Infantil suspensión 20 ml', 'MOTRIN INF SUSP 20M', 2, 184.49, 231, 'marca', 'Medicamentos', null, 'Suspensión', 'Motrin', 'Johnson & Johnson', 'Frasco 20 ml', 'Ibuprofeno', null, false, true, null, null, null),
  (8, '7501417006133', 'FC-17006133', 'Pasta de Lassar óxido de zinc 145 g', 'PASTA LASSAR 145G DO', 4, 43.46, 55, 'marca', 'Cuidado personal', 'Piel', 'Pasta', 'Pasta de Lassar', null, 'Tarro 145 g', 'Óxido de zinc', null, false, true, 'https://www.farmacapital.mx/catalogo-propia/pasta-de-lassar-145g.jpg', 'catalogo-propia/pasta-de-lassar-145g.jpg', null),
  (9, '7501314704156', 'FC-14704156', 'Senosiain adulto C/10', 'SENOSIAIN AD C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (10, '7501314704187', 'FC-14704187', 'Senosiain bebé C/10', 'SENOSIAIN BEBE C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (11, '7501314704163', 'FC-14704163', 'Senosiain niño C/10', 'SENOSIAIN NIÑO C 10', 4, 58.74, 74, 'marca', 'Medicamentos', null, 'Supositorio', 'Senosiain', 'Senosiain', 'Caja con 10', null, null, false, true, null, null, null),
  (12, '785118754259', 'FC-18754259', 'Supratex levodropropizina jarabe 120 ml', 'SUPRATEX JBE 120ML L', 2, 41.52, 67, 'generico', 'Medicamentos', null, 'Jarabe', 'Supratex', 'MAVI', 'Frasco 120 ml', 'Levodropropizina', '600 mg/100 ml', false, true, null, null, null),
  (13, '650240052545', 'FC-00525451', 'XL-3 antigripal C/10', 'XL3 C10 ANTIGRIPAL', 5, 28.65, 46, 'generico', 'Medicamentos', null, 'Tableta', 'XL-3', 'Genomma Lab', 'Caja con 10 tabletas', 'Paracetamol + fenilefrina + clorfenamina', null, false, true, null, null, null);

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
  'Alta Cityfarma S327411 · 2026-09-30 · listo para pistola',
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
  from _fc_cf_s327411
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
  from _fc_cf_s327411
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
  from _fc_cf_s327411
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Cityfarma', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Cityfarma')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma',
  'S327411',
  '2026-09-30',
  4165.25,
  'borrador',
  'Cityfarma S327411 · 30-sep-2026 · Luis Angel · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = 'S327411'
    and coalesce(proveedor, '') ilike '%Cityfarma%'
);

update public.recepciones
set
  total_ticket = 4165.25,
  fecha = '2026-09-30',
  proveedor = 'Cityfarma',
  notas = 'Cityfarma S327411 · 30-sep-2026 · Luis Angel · MMAA de la caja',
  updated_at = now()
where folio = 'S327411'
  and coalesce(proveedor, '') ilike '%Cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S327411'
  and coalesce(r.proveedor, '') ilike '%Cityfarma%'
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
from _fc_cf_s327411 t
join public.recepciones r
  on r.folio = 'S327411'
 and coalesce(r.proveedor, '') ilike '%Cityfarma%'
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
  from _fc_cf_s327411
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
where r.folio = 'S327411'
  and coalesce(r.proveedor, '') ilike '%Cityfarma%'
order by i.id;


-- ===== equilibrio_446466 =====
-- Equilibrio Farmacéutico · ticket 446466 · 2026-09-30 16:57 · Iztapalapa 2
-- Cliente 307513 Luis Angel · 71 artículos · total $2,532.66.
-- Costo = P.U. neto post-descuento. Lote de fábrica sí. Caducidad NO.
-- Piezas ticket (suma qty): 71. Total $2532.66.
-- 2 alta(s) stock 0. 12 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): EQ-DEN073.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq_446466 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_eq_446466 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501349012943', 'FC-5BC5F234', 'Fluconazol 150 mg C/1', 'AMS165 FLUCONAZOL 1 CAPS 150 MG', 20, 13.07, 21, 'generico', 'Medicamentos', null, 'Cápsula', 'AMSA', 'AMSA', 'Caja con 1 cápsula', 'Fluconazol', '150 mg', true, true, null, null, 'U25N344'),
  (2, '7506624900809', 'FC-24900809', 'Tusilen adulto jarabe 118 ml', 'AVT195 TUSILEN AD 1 JBE 240/30/50MG/100/118 ML', 3, 25.86, 33, 'marca', 'Medicamentos', null, 'Jarabe', 'Tusilen', 'Avitus / Allen', 'Frasco 118 ml', 'Dextrometorfano / guaifenesina / fenilefrina', '0.300/2.4/0.050 g/100 ml', false, false, null, null, '26195002'),
  (3, null, 'EQ-DEN073', 'Delaphil 20 mg C/4', 'DEN073 DELAPHIL 4 TAB 20 MG', 10, 23.65, 38, 'generico', 'Medicamentos', null, 'Tableta', 'Delaphil', null, 'Caja con 4 tabletas', null, '20 mg', true, true, null, null, '26F009'),
  (4, '780083140922', 'FC-83140922', 'Ampigrin adulto 3 ámpulas', 'COL009 AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML', 2, 81.01, 102, 'marca', 'Medicamentos', null, 'Inyectable', 'Ampigrin', 'Collins', '3 ámpulas', null, '500/500/100/30 mg/3 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/ampigrin-ad-3amp.jpg', 'catalogo-propia/ampigrin-ad-3amp.jpg', '26240138'),
  (5, '7501563380637', 'EQ-RAD100', 'Fenazopiridina 100 mg C/20', 'RAD100 FENAZOPIRIDINA 1 FCO 20 TAB 100 MG', 5, 21.09, 34, 'generico', 'Medicamentos', null, 'Tableta', 'Randall', 'Randall', 'Frasco 20 tabletas', 'Fenazopiridina', '100 mg', false, true, null, null, '30224'),
  (6, '7501258215947', 'FC-58215947', 'Ruquimax hidroxicloroquina 200 mg C/20', 'SER181 RUQUIMOX 20 TAB 200 MG', 2, 166.16, 266, 'generico', 'Medicamentos', null, 'Tableta', 'Ruquimax', 'Serral', 'Caja con 20 tabletas', 'Hidroxicloroquina', '200 mg', true, false, null, null, '260525'),
  (7, '7501075722543', 'EQ-NOV163', 'Pabesorag 150/12.5 mg C/28', 'NOV163 PABESORAG 28 TAB 150/12.5 MG', 6, 60.48, 97, 'generico', 'Medicamentos', null, 'Tableta', 'Pabesorag', 'Novag', 'Caja con 28 tabletas', null, '150/12.5 mg', true, true, null, null, 'B10436'),
  (8, '7502009745140', 'FC-09745140', 'Clamoxin S suspensión 600/42.9 mg 50 ml', 'MAV226 CLAMOXIN S 1 SUSP 600/42.90MG/50 ML', 2, 48.07, 77, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco 50 ml', 'Amoxicilina / ácido clavulánico', '600/42.9 mg/5 ml', true, true, null, null, '256773'),
  (9, '7502009740503', 'FC-09740503', 'Clamoxin 12H JR suspensión 400/57 mg 50 ml', 'MAV014 CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML', 2, 37.17, 60, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco 50 ml', 'Amoxicilina / ácido clavulánico', '400/57 mg/5 ml', true, true, null, null, '260568'),
  (10, '7502009740497', 'FC-09740497', 'Clamoxin 12H PED suspensión 200/28.5 mg', 'MAV013 CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40', 2, 25.99, 42, 'generico', 'Medicamentos', null, 'Suspensión', 'Clamoxin', 'MAVI', 'Frasco', 'Amoxicilina / ácido clavulánico', '200/28.5 mg/5 ml', true, true, null, null, '257267'),
  (11, '780083142308', 'FC-83142308', 'Tempire paracetamol gotas 100 mg/ml 30 ml', 'COL090 TEMPIRE 1 GOT 100MG/30 ML', 3, 20.00, 25, 'marca', 'Medicamentos', null, 'Gotas', 'Tempire', 'Collins', 'Frasco 30 ml', 'Paracetamol', '100 mg/ml', false, true, null, null, '26141514'),
  (12, '7501349020535', 'EQ-AMS424', 'Irbesartán 300 mg C/14 AMSA', 'AMS424 IRBESARTAN 14 TAB 300 MG', 3, 77.88, 125, 'generico', 'Medicamentos', null, 'Tableta', 'AMSA', 'AMSA', 'Caja con 14 tabletas', 'Irbesartán', '300 mg', true, true, null, null, 'U26E329'),
  (13, '7502009740992', 'FC-5F30F9D4', 'Clamoxin amoxicilina/clavulánico 500/125 mg C/10', 'MAV111 CLAMOXIN 10 TAB 500/125 MG', 5, 48.51, 78, 'generico', 'Medicamentos', null, 'Tableta', 'Clamoxin', 'MAVI', 'Caja con 10 tabletas', 'Amoxicilina / ácido clavulánico', '500/125 mg', true, true, null, null, '262924'),
  (14, '7502247373495', 'EQ-LAN057', 'Bacat atorvastatina 20 mg C/30', 'LAN057 BACAT 30 TAB 20 MG', 6, 39.31, 63, 'generico', 'Medicamentos', null, 'Tableta', 'Bacat', null, 'Caja con 30 tabletas', 'Atorvastatina', '20 mg', true, true, 'https://www.farmacapital.mx/catalogo-propia/bacat-atorvastatina-20mg-c30-7502247373495.jpg', 'catalogo-propia/bacat-atorvastatina-20mg-c30-7502247373495.jpg', 'L26G0410A');

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
  'Alta Equilibrio Farmacéutico 446466 · 2026-09-30 · listo para pistola',
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
  from _fc_eq_446466
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
  from _fc_eq_446466
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
  from _fc_eq_446466
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Equilibrio Farmacéutico', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Equilibrio Farmacéutico')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio Farmacéutico',
  '446466',
  '2026-09-30',
  2532.66,
  'borrador',
  'Equilibrio 446466 · 30-sep-2026 · P.U. post-dto · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '446466'
    and coalesce(proveedor, '') ilike '%Equilibrio%'
);

update public.recepciones
set
  total_ticket = 2532.66,
  fecha = '2026-09-30',
  proveedor = 'Equilibrio Farmacéutico',
  notas = 'Equilibrio 446466 · 30-sep-2026 · P.U. post-dto · MMAA de la caja',
  updated_at = now()
where folio = '446466'
  and coalesce(proveedor, '') ilike '%Equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '446466'
  and coalesce(r.proveedor, '') ilike '%Equilibrio%'
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
from _fc_eq_446466 t
join public.recepciones r
  on r.folio = '446466'
 and coalesce(r.proveedor, '') ilike '%Equilibrio%'
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
  from _fc_eq_446466
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
where r.folio = '446466'
  and coalesce(r.proveedor, '') ilike '%Equilibrio%'
order by i.id;


-- ===== bodega_f42_84416 =====
-- Bodega F-42 Ejidos del Moral · Caja 3/84416 · 2026-09-30 16:47
-- 89 renglones / 128 piezas · subtotal $6,010.44 + impuestos $961.66 = $6,972.10.
-- Costo = P.U. impreso (las líneas ya suman al total con IVA).
-- Ítem 46 Grisi Ricitos Biopure: EAN cortado en foto; match por SKU al escanear.
-- Piezas ticket (suma qty): 128. Total $6972.10.
-- 89 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): FC-F42-JBNGRISIRICITOSO.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_84416 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,4) not null,
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

insert into _fc_bf42_84416 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7798140259893', 'FC-40259893', 'Shampoo Tio Nacho Ant-Dano Aloe 415Ml', 'SH TIO NACHO ANT-DANO ALOE 415ML', 1, 85.84, 108, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (2, '650240057489', 'FC-40057489', 'Shampoo Tio Nacho A-Cai C-Madre 415Ml', 'SH TIO NACHO A-CAI C-MADRE 415ML', 1, 85.84, 108, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (3, '650240035166', 'FC-40035166', 'Shampoo Tio Nacho Antica En 415Ml', 'SH TIO NACHO ANTICA EN 415ML', 1, 86.83, 109, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (4, '7500435129367', 'FC-35129367', 'Desodorante Secret Ph-Balan Stick Gel45G', 'DESOD SECRET PH-BALAN STICK GEL45G', 3, 59.11, 74, 'marca', 'Cuidado personal', null, 'Desodorante', 'Secret', null, 'Pieza', null, null, false, false, null, null, null),
  (5, '4005900841483', 'FC-00841483', 'Crema Niv Sun After C/Aloe 200 Ml', 'CRA NIV SUN AFTER C/ALOE 200 ML', 1, 85.97, 108, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (6, '7506306238640', 'FC-06238640', 'Jabón Camay 72', 'JBN CAMAY 72', 3, 15.473, 20, 'marca', 'Cuidado personal', null, 'Pieza', 'Camay', null, 'Pieza', null, null, false, false, null, null, null),
  (7, '7501943489066', 'FC-43489066', 'Jabón Escudo Bco Neutro 110G C/3', 'JBN ESCUDO BCO NEUTRO 110G C/3', 1, 37.50, 47, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (8, '7501943489073', 'FC-43489073', 'Jabón Escudo Azul Natura 110G C/3', 'JBN ESCUDO AZUL NATURA 110G C/3', 1, 37.49, 47, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (9, '4005808944385', 'FC-08944385', 'Bloqueador Nivea Sunkidswimfp50150M', 'BLOQ NIVEA SUNKIDSWIMFP50150M', 1, 235.85, 295, 'marca', 'Cuidado personal', null, 'Protector solar', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (10, '42419860', 'FC-42419860', 'Crema Niv A-Bacte 3En1 P/Manos 75Ml', 'CRA NIV A-BACTE 3EN1 P/MANOS 75ML', 1, 45.92, 58, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (11, '42360537', 'FC-42360537', 'Crema Nivea Aclar Nat P/Mano 75Ml Mar27', 'CRA NIVEA ACLAR NAT P/MANO 75ML MAR27', 2, 52.94, 67, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (12, '4005900645289', 'FC-00645289', 'Gel Nivea Facial Limp Rosas 150Ml', 'GEL NIVEA FACIAL LIMP ROSAS 150ML', 1, 104.46, 131, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (13, '4006000068565', 'FC-00068565', 'Agua micelar Nivea Reparadora 400Ml', 'AGUA MICE NIVEA REPARADORA 400ML', 1, 118.87, 149, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (14, '4006000273839', 'FC-00273839', 'Agua micelar Nivea Luminou Glow 400Mln', 'AGUA MIC NIVEA LUMINOU GLOW 400MLN', 1, 113.85, 143, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (15, '4006000173108', 'FC-00173108', 'Agua micelar Nivea Derma Skin 400Ml N', 'AGUA MICE NIVEA DERMA SKIN 400ML N', 1, 115.06, 144, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (16, '7791293025803', 'FC-93025803', 'Desodorante Axe Men Excite Spy 150Ml', 'DESOD AXE MEN EXCITE SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (17, '42417644', 'FC-42417644', 'Crema Nivea Cuidado Int P/Mano 75Ml', 'CRA NIVEA CUIDADO INT P/MANO 75ML', 1, 48.58, 61, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (18, '7501054514381', 'FC-54514381', 'Crema Nivea Soft Fac-Corp 200Ml', 'CRA NIVEA SOFT FAC-CORP 200ML', 1, 81.61, 103, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (19, '7794640170133', 'FC-40170133', 'Crema dental Sensodyne Repar-Prot 100G', 'C D SENSODYNE REPAR-PROT 100G', 2, 122.765, 154, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Sensodyne', null, 'Pieza', null, null, false, false, null, null, null),
  (20, '7794640171550', 'FC-40171550', 'Crema dental Sensodyne Rapido Alivio 100G', 'C D SENSODYNE RAPIDO ALIVIO 100G', 2, 117.67, 148, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Sensodyne', null, 'Pieza', null, null, false, false, null, null, null),
  (21, '7506306244795', 'FC-06244795', 'Desodorante Axe Intense 48H Spy 150Ml', 'DESOD AXE INTENSE 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (22, '7506306226852', 'FC-06226852', 'Desodorante Axe Nom Anarchy Spy 150Ml', 'DESOD AXE NOM ANARCHY SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (23, '7791293025797', 'FC-93025797', 'Desodorante Axe Men Dark Temp Spy150Ml', 'DESOD AXE MEN DARK TEMP SPY150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (24, '7506306209855', 'FC-06209855', 'Desodorante Axe Anarc Flo 48H Spy 150Ml', 'DESOD AXE ANARC FLO 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (25, '7506339349030', 'FC-39349030', 'Deo Old Spice Sport Spy 150Ml', 'DEO OLD SPICE SPORT SPY 150ML', 3, 57.17, 72, 'marca', 'Cuidado personal', null, 'Desodorante', 'Old Spice', null, 'Pieza', null, null, false, false, null, null, null),
  (26, '7506346604498', 'FC-46604498', 'Botiquin Kohn Primeros Auxilios', 'BOTIQUIN KOHN PRIMEROS AUXILIOS', 1, 98.99, 124, 'marca', 'Botiquín', null, 'Botiquín', 'Kohn', null, 'Pieza', null, null, false, false, null, null, null),
  (27, '070330736580', 'FC-30736580', 'Bic Flex 3 Bl C/2 Oferta 15%', 'BIC FLEX 3 BL C/2 OFERTA 15%', 1, 51.85, 65, 'marca', 'Cuidado personal', null, 'Pieza', 'BIC', null, 'Pieza', null, null, false, false, null, null, null),
  (28, '7702018072408', 'FC-18072408', 'Maq Gtte Venus Simply3 C/4', 'MAQ GTTE VENUS SIMPLY3 C/4', 1, 100.15, 126, 'marca', 'Cuidado personal', null, 'Pieza', 'Gillette', null, 'Pieza', null, null, false, false, null, null, null),
  (29, '037836051401', 'FC-36051401', 'Jabón Cdpr Grisi 450Ml Shower Gel Coco', 'JBN CDPR GRISI 450ML SHOWER GEL COCO', 1, 54.37, 68, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (30, '7891024030813', 'FC-24030813', 'Enjuague bucal Colgate Sens Pro-Aliv 250Ml', 'ENJ BUC COLGATE SENS PRO-ALIV 250ML', 2, 64.775, 81, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Colgate', null, 'Pieza', null, null, false, false, null, null, null),
  (31, '7509546666959', 'FC-46666959', 'Enjuague bucal Colga Total Enc-Sal 250Ml', 'ENJ BUC COLGA TOTAL ENC-SAL 250ML', 2, 57.79, 73, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Colgate', null, 'Pieza', null, null, false, false, null, null, null),
  (32, '7891010258689', 'FC-10258689', 'Johnson's Baby shampoo fragancia prolongada 400 ml', 'SH JOHNSONS BABY FRAGANCIA PROLONGADA 400ML', 1, 87.02, 109, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null),
  (33, '7702031293231', 'FC-31293231', 'Shampoo Johnsons Baby Manzanilla 200Ml', 'SH JOHNSONS BABY MANZANILLA 200ML', 1, 60.67, 76, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null),
  (34, '7509546695587', 'FC-46695587', 'Crema Palmol Opt P/Pein Kerat 250Mln', 'CRA PALMOL OPT P/PEIN KERAT 250MLN', 1, 36.67, 46, 'marca', 'Cuidado personal', null, 'Crema', 'Palmolive', null, 'Pieza', null, null, false, false, null, null, null),
  (35, '7509552963366', 'FC-52963366', 'Shampoo Elvive Glycolic Cristal 680 Mln', 'SH ELVIVE GLYCOLIC CRISTAL 680 MLN', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (36, '037836050312', 'FC-36050312', 'Jabón Liq Grisi Lech/Burr 450Ml', 'JBN LIQ GRISI LECH/BURR 450ML', 1, 53.74, 68, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (37, '810120501260', 'FC-20501260', 'Grisi 450Ml Jabón Liq Aloe Vera', 'GRISI 450ML JBN LIQ ALOE VERA', 1, 52.51, 66, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (38, '7501007528427', 'FC-07528427', 'Crema Lubrid Rep/Int Sens 400Ml', 'CRA LUBRID REP/INT SENS 400ML', 1, 96.76, 121, 'marca', 'Cuidado personal', null, 'Crema', 'Lubriderm', null, 'Pieza', null, null, false, false, null, null, null),
  (39, '7501943489165', 'FC-43489165', 'Jabón Liq Escudo Blanco Neut 225Ml', 'JBN LIQ ESCUDO BLANCO NEUT 225ML', 3, 24.507, 31, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (40, '7506195148679', 'FC-95148679', 'Shampoo H&S 2 En 1 Sve-Man 90Ml', 'SH H&S 2 EN 1 SVE-MAN 90ML', 2, 15.15, 19, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (41, '7506195148686', 'FC-95148686', 'Shampoo H&S Limp Renov 90Ml', 'SH H&S LIMP RENOV 90ML', 2, 15.19, 19, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (42, '7509552816266', 'FC-52816266', 'Shampoo Fructis Oil-R Liso Coco 650Ml', 'SH FRUCTIS OIL-R LISO COCO 650ML', 1, 90.90, 114, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (43, '7501026462092', 'FC-26462092', 'Ternura 18 Pzs Chupon Ortodontico', 'TERNURA 18 PZS CHUPON ORTODONTICO', 2, 78.02, 98, 'marca', 'Bebé', null, 'Accesorio', 'Ternura', null, 'Pieza', null, null, false, false, null, null, null),
  (44, '850040940732', 'FC-40940732', 'Ricitos De Oro 250Ml Aloe Y Calendula', 'RICITOS DE ORO 250ML ALOE Y CALENDULA', 1, 46.64, 59, 'marca', 'Cuidado personal', null, 'Pieza', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (45, '7501022133019', 'FC-22133019', 'Ricitos De Oro 400Ml Shampoo Lavanda + Plastil', 'RICITOS DE ORO 400ML SH LAVANDA + PLASTIL', 1, 64.08, 81, 'marca', 'Cuidado personal', null, 'Cabello', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (46, null, 'FC-F42-JBNGRISIRICITOSO', 'Jabón Grisi Ricitos Oro Biopure 90G', 'JBN GRISI RICITOS ORO BIOPURE 90G', 2, 22.325, 28, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (47, '7509546654997', 'FC-46654997', 'Mousse Caprice Final Touch 200 G', 'MOUSSE CAPRICE FINAL TOUCH 200 G', 2, 54.44, 69, 'marca', 'Cuidado personal', null, 'Cabello', 'Caprice', null, 'Pieza', null, null, false, false, null, null, null),
  (48, '7506306257610', 'FC-06257610', 'Desodorante Polvo Rexona Eficc Fresh 200 G', 'DESOD PVO REXONA EFICC FRESH 200 G', 1, 66.78, 84, 'marca', 'Cuidado personal', null, 'Cabello', 'Rexona', null, 'Pieza', null, null, false, false, null, null, null),
  (49, '7509546695570', 'FC-46695570', 'Crema Palmo Opt P/Pein Ker Rh 250Mln', 'CRA PALMO OPT P/PEIN KER RH 250MLN', 1, 36.67, 46, 'marca', 'Cuidado personal', null, 'Crema', null, null, 'Pieza', null, null, false, false, null, null, null),
  (50, '7501361121500', 'FC-61121500', 'Odolex Naturals 150Gr Talco Desodorante', 'ODOLEX NATURALS 150GR TALCO DESODORANTE', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Desodorante', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (51, '7501361124013', 'FC-61124013', 'Talco Odolex Fresh 150G', 'TCO ODOLEX FRESH 150G', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Cabello', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (52, '7501048690046', 'FC-48690046', 'Protec 13 Pzs Botiquin Primeros Auxilios', 'PROTEC 13 PZS BOTIQUIN PRIMEROS AUXILIOS', 1, 78.78, 99, 'marca', 'Botiquín', null, 'Botiquín', 'Protect', null, 'Pieza', null, null, false, false, null, null, null),
  (53, '7500435171038', 'FC-35171038', 'Cepillo dental Oral-B 40 Suave 2Pz', 'CEP DENT ORAL-B 40 SUAVE 2PZ', 2, 34.43, 44, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (54, '070942302401', 'FC-42302401', 'Hilo dental Gum Expanding 40 Mts', 'HILO DENT GUM EXPANDING 40 MTS', 2, 64.37, 81, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'GUM', null, 'Pieza', null, null, false, false, null, null, null),
  (55, '7501006711387', 'FC-06711387', 'Cepillo dental Pro D-Out 2X1Med', 'CEP DENT PRO D-OUT 2X1MED', 1, 38.56, 49, 'marca', 'Cuidado personal', null, 'Higiene bucal', null, null, 'Pieza', null, null, false, false, null, null, null),
  (56, '3014260014445', 'FC-60014445', 'Cepillo dental Oral-B Comple Sve 40 2X1', 'CEP DENT ORAL-B COMPLE SVE 40 2X1', 2, 40.54, 51, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (57, '7501086494286', 'FC-86494286', 'Cepillo dental Oral-B Gde 60 Sve', 'CEP DENT ORAL-B GDE 60 SVE', 1, 31.02, 39, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (58, '7501086494262', 'FC-86494262', 'Cepillo dental Oral-B Indicat35Sve', 'CEP DENT ORAL-B INDICAT35SVE', 1, 31.02, 39, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (59, '7509546655055', 'FC-46655055', 'Mousse Caprice Volum-Ctrl 200 G', 'MOUSSE CAPRICE VOLUM-CTRL 200 G', 2, 54.44, 69, 'marca', 'Cuidado personal', null, 'Cabello', 'Caprice', null, 'Pieza', null, null, false, false, null, null, null),
  (60, '7501056342258', 'FC-56342258', 'Crema Sedal Recons Estructur 135Ml', 'CRA SEDAL RECONS ESTRUCTUR 135ML', 2, 18.165, 23, 'marca', 'Cuidado personal', null, 'Crema', 'Sedal', null, 'Pieza', null, null, false, false, null, null, null),
  (61, '7501056340100', 'FC-56340100', 'Crema Sedal Anti Sponge 300 Ml', 'CRA SEDAL ANTI SPONGE 300 ML', 2, 50.065, 63, 'marca', 'Cuidado personal', null, 'Crema', 'Sedal', null, 'Pieza', null, null, false, false, null, null, null),
  (62, '7509552992304', 'FC-52992304', 'Acondicionador Elvive Colageno 370Ml', 'ACOND ELVIVE COLAGENO 370ML', 1, 70.63, 89, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (63, '7501943418349', 'FC-43418349', 'Jabón Kbb Max Mznll-Aloe Vera 75G', 'JBN KBB MAX MZNLL-ALOE VERA 75G', 2, 11.675, 15, 'marca', 'Cuidado personal', null, 'Pieza', 'KBB', null, 'Pieza', null, null, false, false, null, null, null),
  (64, '037836033742', 'FC-36033742', 'Shampoo Ricitos De Oro Lech Almen 250Ml', 'SH RICITOS DE ORO LECH ALMEN 250ML', 1, 67.71, 85, 'marca', 'Cuidado personal', null, 'Cabello', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (65, '7500435258425', 'FC-35258425', 'Shampoo H&S 90Ml Romero Anti Caida C24', 'SH H&S 90ML ROMERO ANTI CAIDA C24', 2, 17.05, 22, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (66, '7501361111501', 'FC-61111501', 'Talco Desodorante Odolex 150 G', 'TCO DESOD ODOLEX 150 G', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Desodorante', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (67, '7501101311055', 'FC-01311055', 'Super Wet 250Gr Gel Fij Plus Invis', 'SUPER WET 250GR GEL FIJ PLUS INVIS', 2, 13.93, 18, 'marca', 'Cuidado personal', null, 'Pieza', 'Super Wet', null, 'Pieza', null, null, false, false, null, null, null),
  (68, '7501007457796', 'FC-07457796', 'Shampoo Pant Brillo Extremo 400 Ml', 'SH PANT BRILLO EXTREMO 400 ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (69, '7501007457802', 'FC-07457802', 'Sh. Pantene Brillo Extremo 750Ml', 'SH. PANTENE BRILLO EXTREMO 750ML', 1, 109.68, 138, 'marca', 'Cuidado personal', null, 'Pieza', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (70, '7501001165321', 'FC-01165321', 'Acondicionador Pant Rizos Definid 400Ml', 'ACOND PANT RIZOS DEFINID 400ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (71, '7502235820369', 'FC-35820369', 'Hilo dental Gum Expanding 10.9 M', 'HILO DENT GUM EXPANDING 10.9 M', 2, 21.575, 27, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'GUM', null, 'Pieza', null, null, false, false, null, null, null),
  (72, '7506306257603', 'FC-06257603', 'Polvo Desodorante Rexona Effi Ant-Pro 200G', 'PVO DESOD REXONA EFFI ANT-PRO 200G', 1, 64.12, 81, 'marca', 'Cuidado personal', null, 'Desodorante', 'Rexona', null, 'Pieza', null, null, false, false, null, null, null),
  (73, '7702031244509', 'FC-31244509', 'Crema Lubriderm P Normal 400Ml', 'CRA LUBRIDERM P NORMAL 400ML', 1, 96.76, 121, 'marca', 'Cuidado personal', null, 'Crema', 'Lubriderm', null, 'Pieza', null, null, false, false, null, null, null),
  (74, '7509552874983', 'FC-52874983', 'Shampoo Elvive Hidra Hialu Pure 680Ml', 'SH ELVIVE HIDRA HIALU PURE 680ML', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (75, '7503002163023', 'FC-02163023', 'Gel X-Treme Transp 250 G', 'GEL X-TREME TRANSP 250 G', 4, 24.302, 31, 'marca', 'Cuidado personal', null, 'Cabello', 'X-Treme', null, 'Pieza', null, null, false, false, null, null, null),
  (76, '7501007457826', 'FC-07457826', 'Acondicionador Pant Brillo Extremo 400Ml', 'ACOND PANT BRILLO EXTREMO 400ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (77, '7502224510042', 'FC-24510042', 'Silica Seda Pure 3N1 Kids 120Ml', 'SILICA SEDA PURE 3N1 KIDS 120ML', 1, 58.56, 74, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (78, '7502245720062', 'FC-45720062', 'Silica Silkhair-F Naranja 120 Ml', 'SILICA SILKHAIR-F NARANJA 120 ML', 2, 33.165, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (79, '7502245720109', 'FC-45720109', 'Silica Silkhair-F Uva 60 Ml', 'SILICA SILKHAIR-F UVA 60 ML', 2, 20.975, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (80, '7502245720086', 'FC-45720086', 'Silica Silkhair-F Coco 120 Ml', 'SILICA SILKHAIR-F COCO 120 ML', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (81, '7502245720079', 'FC-45720079', 'Silkhair Uva 120Ml Silica', 'SILKHAIR UVA 120ML SILICA', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (82, '7502245720116', 'FC-45720116', 'Silkhair Nja 60Ml Silica', 'SILKHAIR NJA 60ML SILICA', 2, 20.975, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (83, '7502224510097', 'FC-24510097', 'Silica Seda Pure 3N1 Papaya 120Ml', 'SILICA SEDA PURE 3N1 PAPAYA 120ML', 1, 58.55, 74, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (84, '7502245720222', 'FC-45720222', 'Silkhair Cereza 60 Ml Silica', 'SILKHAIR CEREZA 60 ML SILICA', 1, 20.97, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (85, '7502245720093', 'FC-45720093', 'Silica Silkhair-F Cerez/Fresa 120Ml', 'SILICA SILKHAIR-F CEREZ/FRESA 120ML', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (86, '7509552908718', 'FC-52908718', 'Shampoo Fructis Borrador Dand 650Ml', 'SH FRUCTIS BORRADOR DAND 650ML', 1, 78.53, 99, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (87, '7509552817393', 'FC-52817393', 'Shampoo Elvive Color-Vive Uv 680 Ml', 'SH ELVIVE COLOR-VIVE UV 680 ML', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (88, '7509552962628', 'FC-52962628', 'Shampoo Fructis Control Grasa 650 Ml N', 'SH FRUCTIS CONTROL GRASA 650 ML N', 1, 84.67, 106, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (89, '7702031293286', 'FC-31293286', 'Shampoo Johnson''S Baby Cabe Osc 200 Ml', 'SH JOHNSON''S BABY CABE OSC 200 ML', 1, 60.67, 76, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null);

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
  'Alta Bodega F-42 Ejidos del Moral 84416 · 2026-09-30 · listo para pistola',
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
  from _fc_bf42_84416
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
  from _fc_bf42_84416
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
  from _fc_bf42_84416
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Bodega F-42 Ejidos del Moral', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Bodega F-42 Ejidos del Moral')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42 Ejidos del Moral',
  '84416',
  '2026-09-30',
  6972.10,
  'borrador',
  'Bodega F-42 84416 · 30-sep-2026 · P.U. con IVA · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '84416'
    and coalesce(proveedor, '') ilike '%F-42%'
);

update public.recepciones
set
  total_ticket = 6972.10,
  fecha = '2026-09-30',
  proveedor = 'Bodega F-42 Ejidos del Moral',
  notas = 'Bodega F-42 84416 · 30-sep-2026 · P.U. con IVA · MMAA de la caja',
  updated_at = now()
where folio = '84416'
  and coalesce(proveedor, '') ilike '%F-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84416'
  and coalesce(r.proveedor, '') ilike '%F-42%'
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
from _fc_bf42_84416 t
join public.recepciones r
  on r.folio = '84416'
 and coalesce(r.proveedor, '') ilike '%F-42%'
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
  from _fc_bf42_84416
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
where r.folio = '84416'
  and coalesce(r.proveedor, '') ilike '%F-42%'
order by i.id;
