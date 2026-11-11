-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Tickets 09-nov-2026 → cola Recibir (borrador).
--   1) Bodega F-42 383312 · $611.15 · 7 renglones
--   2) IFC F8 Tienda 132888 · $118.00 · 2 renglones
-- Merge a GitHub NO los crea. Sin bloques dollar-quote. Sin producto_imagenes.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Cada ticket es begin/commit independiente.
-- Al final: VERIFICACION FINAL con los 2 folios en borrador.
-- Luego: tablet Recibir → recargar → aparecen las tarjetas.
-- =============================================================================


-- ========== Bodega F-42 383312 ==========
-- Bodega F-42 · folio 383312 · 2026-11-09 17:07 · total $611.15 · 7 renglones
-- P.U. ya con IVA (suma = total). Folio del CODE128 del pie.
-- 4 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_bf42_383312 (
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
  imagen text
) on commit drop;

insert into _fc_bf42_383312 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '070942304542', 'FC-42304542', 'GUM hilo dental + enhebrador', 'HILO DENT GUM + ENHEBRADOR 22.9M', 1, 97.54, 122, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'GUM', 'Sunstar', '22.9 m con enhebrador', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/gum-hilo-dental-enhebrador-22.9m-070942304542.jpg'),
  (2, '7501035911376', 'FC-35911376', 'Colgate Total Clean Mint', 'C D COLGATE TOTAL 150 ML', 3, 53.50, 67, 'marca', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'Colgate', 'Colgate-Palmolive', 'Tubo 150 ml', null, null, false, false, null),
  (3, '070942303194', 'FC-42303194', 'GUM hilo dental con cera', 'HILO DENT GUM C/CERAS MTA 129P', 1, 56.61, 71, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'GUM', 'Sunstar', '128 m', null, null, false, true, null),
  (4, '7800005082024', 'FC-05082024', 'Oral-B Essential Floss con cera', 'HILO SDA ORAL-B CERA', 2, 69.315, 87, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'Oral-B', 'P&G', '50 m', null, null, false, false, null),
  (5, '7500435129749', 'FC-35129749', 'Oral-B Essential Floss menta', 'HILO DENT ORAL-B ESS FLOSS 2PACK', 1, 70.77, 89, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'Oral-B', 'P&G', '2 × 50 m', null, null, false, false, null),
  (6, '7509546653495', 'FC-66534951', 'Colgate Total 12 Clean Mint', 'C D COLGATE TOTAL12 CLEAN MI 65ML', 2, 23.445, 30, 'marca', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'Colgate', 'Colgate-Palmolive', 'Tubo 65 ml', null, null, false, true, null),
  (7, '759684313257', 'FC-84313257', 'Mertodol blanco con atomizador', 'MERTODOL BCO JALOMA C/ATO 40ML S', 2, 20.105, 26, 'marca', 'Botiquín', 'Antiséptico', 'Solución', 'Jaloma', 'Jaloma', '40 ml con atomizador', 'Cloruro de benzalconio', '0.13%', false, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 383312 · 2026-11-09 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_383312
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_383312
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_bf42_383312
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '383312',
  '2026-11-09',
  611.15,
  'borrador',
  'Bodega F-42 / Citymark · Caja 4 · folio 383312 (CODE128 del pie; encabezado Caja 4/… doblado en la foto) · 09-nov-2026 17:07 · Público en general · TC $611.15 · P.U. ya con IVA · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '383312'
    and coalesce(proveedor, '') ilike '%bodega%f-42%'
);

update public.recepciones
set
  total_ticket = 611.15,
  fecha = '2026-11-09',
  proveedor = 'Bodega F-42',
  notas = 'Bodega F-42 / Citymark · Caja 4 · folio 383312 (CODE128 del pie; encabezado Caja 4/… doblado en la foto) · 09-nov-2026 17:07 · Público en general · TC $611.15 · P.U. ya con IVA · cola Recibir',
  updated_at = now()
where folio = '383312'
  and coalesce(proveedor, '') ilike '%bodega%f-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '383312'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
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
from _fc_bf42_383312 t
join public.recepciones r
  on r.folio = '383312'
 and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
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
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '383312'
  and coalesce(r.proveedor, '') ilike '%bodega%f-42%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_383312 t
order by t.linea;

commit;


-- ========== IFC F8 Tienda 132888 ==========
-- IFC F8 Tienda · folio 132888 · 2026-11-09 16:52 · total $118.00 · 2 renglones
-- Menudeo por pieza. Romero EAN 3311000001537. Mertodol EAN 759684313257.
-- 1 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_ifc_132888 (
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
  imagen text
) on commit drop;

insert into _fc_ifc_132888 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen
) values
  (1, '3311000001537', 'FC-38CAFE6B', 'Aceite de romero Mercurio', 'MERCURIO ACEITE ROMERO C/25 1910923 83187', 10, 8.50, 11, 'marca', 'Cuidado personal', 'Botiquín', 'Aceite', 'Mercurio', 'Mercurio', 'Frasco (pieza de C/25)', null, null, false, true, null),
  (2, '759684313257', 'FC-84313257', 'Mertodol blanco con atomizador', 'JALOMA MERTIOLATE BLANCO 40ML C/25 0179039 83217', 2, 16.50, 21, 'marca', 'Botiquín', 'Antiséptico', 'Solución', 'Jaloma', 'Jaloma', '40 ml con atomizador', 'Cloruro de benzalconio', '0.13%', false, false, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when t.ean is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta IFC F8 Tienda 132888 · 2026-11-09 · listo para pistola',
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
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or public.fc_buscar_producto_escaneo(t.ean) is null)
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
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
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_ifc_132888
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '132888',
  '2026-11-09',
  118.00,
  'borrador',
  'IFC F8 Tienda / Farma Centre · folio 132888 · 09-nov-2026 16:52 · cliente Luis · San Bernabé 317 · MENUDEO · Aceite romero Mercurio 10 pzas + Mertodol Jaloma 2 pzas · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '132888'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 118.00,
  fecha = '2026-11-09',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 Tienda / Farma Centre · folio 132888 · 09-nov-2026 16:52 · cliente Luis · San Bernabé 317 · MENUDEO · Aceite romero Mercurio 10 pzas + Mertodol Jaloma 2 pzas · cola Recibir',
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
  r.id,
  v.pid,
  coalesce(nullif(btrim(t.ean), ''), t.sku),
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
from _fc_ifc_132888 t
join public.recepciones r
  on r.folio = '132888'
 and coalesce(r.proveedor, '') ilike '%ifc%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku)
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
  count(*) filter (where i.confirmado is not true) as sin_confirmar,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '132888'
  and coalesce(r.proveedor, '') ilike '%ifc%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku)
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_ifc_132888 t
order by t.linea;

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
    (r.folio = '383312' and coalesce(r.proveedor, '') ilike '%bodega%f-42%')
 or (r.folio = '132888' and coalesce(r.proveedor, '') ilike '%ifc%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
