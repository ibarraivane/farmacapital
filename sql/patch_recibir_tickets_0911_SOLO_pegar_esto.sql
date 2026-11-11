-- ============================================================================
-- Tickets 09-nov-2026 -> cola Recibir (borrador)
-- Pegar TODO este archivo en Supabase -> SQL Editor -> Run
-- 4 tickets independientes (cada uno con begin/commit).
-- Stock 0 hasta pistola + MMAA. No inventar caducidad 0000.
-- SIN bloques dollar-quote.
-- ============================================================================


-- ========== Equilibrio 451146 ==========
-- Equilibrio 451146 · $283.36 · Nisolver x4 · costo neto. Lote/cad del ticket NO se guarda.
begin;

create temp table _fc_eq_451146 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text
) on commit drop;

insert into _fc_eq_451146 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
(1, '7502009746321', 'FC-09746321', 'Nisolver prednisolona', 'MAV300 NISOLVER 1 SOL 100 ML', 4, 70.84, 114, 'generico', 'Medicamentos', null, 'Solucion', 'Nisolver', 'Maver', 'Frasco 100 ml', 'Prednisolona', '1 mg/ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/nisolver-prednisolona-1mg-ml-100ml-7502009746321.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 09-nov-2026 · 451146 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451146
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451146
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_eq_451146
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '451146',
  '2026-11-09',
  283.36,
  'borrador',
  'Pedido Equilibrio 451146 · Iztapalapa 2 · online 09-nov-2026 16:42 · Nisolver x4 @ $70.84 · $283.36 · cola Recibir; stock al confirmar pistola + MMAA (no pegar lote/cad del ticket)'
where not exists (
  select 1 from public.recepciones
  where folio = '451146' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 283.36,
  fecha = '2026-11-09',
  proveedor = 'Equilibrio',
  notas = 'Pedido Equilibrio 451146 · Iztapalapa 2 · online 09-nov-2026 16:42 · Nisolver x4 @ $70.84 · $283.36 · cola Recibir; stock al confirmar pistola + MMAA (no pegar lote/cad del ticket)',
  updated_at = now()
where folio = '451146'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '451146'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_eq_451146 t
join public.recepciones r
  on r.folio = '451146' and coalesce(r.proveedor, '') ilike '%equilibrio%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '451146'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;

-- ========== Bodega F-48 157665 ==========
-- Bodega F-48 157665 · $1186 · Ensure pistola EAN 237 ml (ticket imprimio 236 ml).
begin;

create temp table _fc_f48_157665 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text
) on commit drop;

insert into _fc_f48_157665 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
(1, '7501033954061', 'FC-33954061', 'Ensure Singles liquido chocolate', 'ENSURE LIQ 236ML CHTE', 8, 42.00, 53, 'marca', 'Suplemento', 'Nutricion', 'Liquido', 'Ensure', 'Abbott', 'Botella 237 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-chocolate-237ml.jpg'),
(2, '7501033954078', 'FC-33954078', 'Ensure Singles liquido fresa', 'ENSURE LIQ 236ML FSA', 8, 42.00, 53, 'marca', 'Suplemento', 'Nutricion', 'Liquido', 'Ensure', 'Abbott', 'Botella 237 ml', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-singles-fresa-237ml.jpg'),
(3, '7501033954085', 'FC-33954085', 'Ensure Singles liquido vainilla', 'ENSURE LIQ 236ML VNLLA', 8, 42.00, 53, 'marca', 'Suplemento', 'Nutricion', 'Liquido', 'Ensure', 'Abbott', 'Botella 237 ml', null, null, false, true, null),
(4, '020800600347', 'FC-00600347', 'Tampax Super Plus', 'TAMPAX 10 SUPER PLUS NARANJA', 4, 44.50, 56, 'marca', 'Cuidado personal', 'Higiene femenina', 'Tampones', 'Tampax', 'P&G', 'Caja con 10', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/tampax-super-plus-10.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 09-nov-2026 · 157665 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f48_157665
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f48_157665
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f48_157665
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-48',
  '157665',
  '2026-11-09',
  1186.00,
  'borrador',
  'Ticket Bodega F-48 / Murillo Pasillo EF · venta 157665 · 09-nov-2026 · Ensure Singles choco/fresa/vainilla x8 c/u + Tampax Super Plus x4 · $1,186 · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '157665' and coalesce(proveedor, '') ilike '%bodega%f-48%'
);

update public.recepciones
set
  total_ticket = 1186.00,
  fecha = '2026-11-09',
  proveedor = 'Bodega F-48',
  notas = 'Ticket Bodega F-48 / Murillo Pasillo EF · venta 157665 · 09-nov-2026 · Ensure Singles choco/fresa/vainilla x8 c/u + Tampax Super Plus x4 · $1,186 · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '157665'
  and coalesce(proveedor, '') ilike '%bodega%f-48%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '157665'
  and coalesce(r.proveedor, '') ilike '%bodega%f-48%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_f48_157665 t
join public.recepciones r
  on r.folio = '157665' and coalesce(r.proveedor, '') ilike '%bodega%f-48%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '157665'
  and coalesce(r.proveedor, '') ilike '%bodega%f-48%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;

-- ========== Bodega F-42 8716 ==========
-- Bodega F-42 / Citymark 8716 · $611.15 · P.U. ya con IVA. Folio leido con encabezado doblado.
begin;

create temp table _fc_f42_8716 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text
) on commit drop;

insert into _fc_f42_8716 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
(1, '070942304542', 'FC-42304542', 'GUM hilo dental + enhebrador', 'HILO DENT GUM + ENHEBRADOR 22.9M', 1, 97.54, 122, 'marca', 'Cuidado personal', 'Bucal', 'Hilo dental', 'GUM', 'Sunstar', '22.9 m con enhebrador', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/gum-hilo-dental-enhebrador-22.9m-070942304542.jpg'),
(2, '7501035911376', 'FC-35911376', 'Colgate Total Clean Mint', 'C D COLGATE TOTAL 150 ML', 3, 53.50, 67, 'marca', 'Cuidado personal', 'Bucal', 'Crema dental', 'Colgate', 'Colgate-Palmolive', 'Tubo 150 ml', null, null, false, true, null),
(3, '070942303194', 'FC-42303194', 'GUM hilo dental con cera menta', 'HILO DENT GUM C/CERAS MTA 129P', 1, 56.61, 71, 'marca', 'Cuidado personal', 'Bucal', 'Hilo dental', 'GUM', 'Sunstar', '129 yardas con cera', null, null, false, true, null),
(4, '7800005082024', 'FC-05082024', 'Oral-B Essential Floss con cera', 'HILO SDA ORAL-B CERA', 2, 69.32, 87, 'marca', 'Cuidado personal', 'Bucal', 'Hilo dental', 'Oral-B', 'P&G', 'Rollo 50 m', null, null, false, true, null),
(5, '7500435129749', 'FC-35129749', 'Oral-B Essential Floss 2 pack', 'HILO DENT ORAL-B ESS FLOSS 2PACK', 1, 70.77, 89, 'marca', 'Cuidado personal', 'Bucal', 'Hilo dental', 'Oral-B', 'P&G', 'Paquete con 2 rollos', null, null, false, true, null),
(6, '7509546653495', 'FC-46653495', 'Colgate Total 12 Clean Mint', 'C D COLGATE TOTAL12 CLEAN MI 65ML', 2, 23.45, 30, 'marca', 'Cuidado personal', 'Bucal', 'Crema dental', 'Colgate', 'Colgate-Palmolive', 'Tubo 65 ml', null, null, false, true, null),
(7, '759684313257', 'FC-84313257', 'Jaloma Mertodol blanco atomizador', 'MERTODOL BCO JALOMA C/ATO 40ML S', 2, 20.11, 26, 'marca', 'Botiquin', 'Antiseptico', 'Solucion', 'Jaloma', 'Jaloma', 'Frasco atomizador 40 ml', 'Cloruro de benzalconio', null, false, true, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 09-nov-2026 · 8716 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f42_8716
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f42_8716
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_f42_8716
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '8716',
  '2026-11-09',
  611.15,
  'borrador',
  'Ticket Citymark / Bodega F-42 Caja 4/8716 · 09-nov-2026 17:07 · GUM · Colgate · Oral-B · Mertodol · tarjeta $611.15 · cola Recibir; stock al confirmar pistola + MMAA (encabezado doblado: confirmar folio si el papel dice otro)'
where not exists (
  select 1 from public.recepciones
  where folio = '8716' and coalesce(proveedor, '') ilike '%bodega%f-42%'
);

update public.recepciones
set
  total_ticket = 611.15,
  fecha = '2026-11-09',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Citymark / Bodega F-42 Caja 4/8716 · 09-nov-2026 17:07 · GUM · Colgate · Oral-B · Mertodol · tarjeta $611.15 · cola Recibir; stock al confirmar pistola + MMAA (encabezado doblado: confirmar folio si el papel dice otro)',
  updated_at = now()
where folio = '8716'
  and coalesce(proveedor, '') ilike '%bodega%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '8716'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_f42_8716 t
join public.recepciones r
  on r.folio = '8716' and coalesce(r.proveedor, '') ilike '%bodega%f-42%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '8716'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;

-- ========== IFC F8 Tienda 132888 ==========
-- IFC F8 132888 · $118 · sin EAN GS1; ligar codigo de caja al SKU.
begin;

create temp table _fc_ifc_132888 (
  linea integer primary key,
  ean text,
  sku text,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2),
  tipo text,
  categoria text,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean,
  es_alta boolean not null default true,
  imagen text
) on commit drop;

insert into _fc_ifc_132888 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, es_alta, imagen
) values
(1, null, 'FC-38CAFE6B', 'Mercurio aceite de romero', 'MERCURIO ACEITE ROMERO C/25 1910923', 10, 8.50, 11, 'marca', 'Cuidado personal', null, 'Aceite', 'Mercurio', 'Mercurio', 'Frasco (pieza de C/25)', 'Aceite de romero', null, false, false, null),
(2, null, 'FC-IFC-83217', 'Jaloma mertiolate blanco', 'JALOMA MERTIOLATE BLANCO 40ML C/25', 2, 16.50, 21, 'marca', 'Botiquin', 'Antiseptico', 'Solucion', 'Jaloma', 'Jaloma', 'Frasco 40 ml (pieza de C/25)', null, null, false, true, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.sku is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(coalesce(t.ean, t.sku), 8)
    when t.sku is not null then t.sku
    else 'FC-' || right(t.ean, 8)
  end,
  t.ean,
  coalesce(t.categoria, 'Medicamentos'),
  t.subcategoria,
  coalesce(t.tipo, 'generico'),
  'Alta ticket 09-nov-2026 · 132888 · listo para pistola',
  case when t.costo >= 1 then t.costo else null end,
  coalesce(
    t.precio,
    case
      when t.costo >= 1 then ceil(t.costo * case when t.tipo = 'marca' then 1.25 else 1.60 end)
      else null
    end
  ),
  0, 1, true, coalesce(t.receta, false),
  t.marca, t.presentacion, t.forma, t.principio_activo, t.concentracion, t.laboratorio,
  t.imagen, t.imagen
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  where es_alta
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and (t.sku is null or public.fc_buscar_producto_escaneo(t.sku) is null)
  and not exists (
    select 1 from public.productos p
    where (t.ean is not null and p.codigo_barras = t.ean)
       or (t.sku is not null and p.sku = t.sku)
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 1 and t.precio is not null then t.precio
    when coalesce(p.precio, 0) <= 1 then ceil(t.costo * case when coalesce(t.tipo,'generico') = 'marca' then 1.25 else 1.60 end)
    else p.precio
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  where costo >= 1
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

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
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean),
  requiere_receta = case when coalesce(t.receta, false) then true else p.requiere_receta end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  case when t.sku is not null then public.fc_buscar_producto_escaneo(t.sku) end
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '132888',
  '2026-11-09',
  118.00,
  'borrador',
  'IFC F8 Tienda · folio 132888 · MENUDEO · 09-nov-2026 16:52 · aceite romero Mercurio x10 + Jaloma mertiolate blanco x2 · $118 · sin EAN GS1 (codigos IFC) · cola Recibir; ligar EAN de caja al escanear'
where not exists (
  select 1 from public.recepciones
  where folio = '132888' and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 118.00,
  fecha = '2026-11-09',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 Tienda · folio 132888 · MENUDEO · 09-nov-2026 16:52 · aceite romero Mercurio x10 + Jaloma mertiolate blanco x2 · $118 · sin EAN GS1 (codigos IFC) · cola Recibir; ligar EAN de caja al escanear',
  updated_at = now()
where folio = '132888'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '132888'
  and coalesce(r.proveedor, '') ilike '%ifc%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id, v.pid, nullif(btrim(t.ean), ''), t.snap, t.qty,
  null, null, t.costo, (v.pid is null), 'pdf', false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid and coalesce(l.activo, true) and coalesce(l.cantidad_actual, 0) > 0
    )
  ),
  null
from _fc_ifc_132888 t
join public.recepciones r
  on r.folio = '132888' and coalesce(r.proveedor, '') ilike '%ifc%' and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), '')) end,
    case when nullif(btrim(t.sku), '') is not null then public.fc_buscar_producto_escaneo(nullif(btrim(t.sku), '')) end
  ) as pid
) v on true
order by t.linea;

select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '132888'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

commit;


-- ========== VERIFICACION FINAL ==========
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  count(*) filter (where i.confirmado is not true) as sin_confirmar
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where (
    (r.folio = '451146' and coalesce(r.proveedor, '') ilike '%equilibrio%')
 or (r.folio = '157665' and coalesce(r.proveedor, '') ilike '%bodega%f-48%')
 or (r.folio = '8716' and coalesce(r.proveedor, '') ilike '%bodega%f-42%')
 or (r.folio = '132888' and coalesce(r.proveedor, '') ilike '%ifc%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;

