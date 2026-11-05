-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Tickets 04-nov-2026 → cola Recibir (borrador). Merge a GitHub NO los crea.
--   1) Cityfarma Iztapalapa S337748 · $1,449.93 · 5 renglones
--   2) Farma Mayoreo V01000002384 · $183.52 · 2 renglones
--   3) Farma MX CAICA1CA111636 · $217.45 · 1 renglón (Detresgel)
--   4) IFC F8 Tienda 132071 · $224.50 · 4 renglones (Mercurio)
-- Sahuayo 432467 ya está en main: omitido (foto repetida).
-- Sin bloques dollar-quote. Sin galería extra. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.
-- Al final: VERIFICACION con los 4 folios en borrador.
-- Luego: tablet Recibir → recargar → aparecen las tarjetas.
-- =============================================================================


-- ========== Cityfarma Iztapalapa S337748 ==========
-- Cityfarma Iztapalapa · folio S337748 · 2026-11-04 · total $1,449.93
-- 2 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Costo = P.U. del ticket. PVP = ceil(costo×1.25 marca / ×1.60 genérico).
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s337748 (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into _fc_cf_s337748 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501349024304', 'FC-281E0F22', 'Budesonida 0.5 mg/2 ml', 'BUDESONIDA 0500MG 2M', 3, 127.12, 204, 'generico', 'Medicamentos',
   'Respiratorio', 'Suspensión', 'AMSA', 'AMSA', 'Caja con 5 ampolletas de 2 ml', 'Budesonida',
   '0.5 mg/2 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/budesonida-amsa-0.5mg-2ml-c5-7501349024304.jpg', null),
  (2, '7501065095947', 'FC-65095947', 'Centrum Silver 50+', 'CENTRUM SILVER 50MAS', 1, 167.48, 210, 'marca', 'Vitaminas',
   null, 'Tabletas', 'Centrum', 'Haleon', 'Caja con 30 tabletas', null,
   null, false, true, 'https://www.farmacapital.mx/catalogo-propia/multivitam-nico-centrum-silver-50-adultos-con-vi-7501065095947.jpg', null),
  (3, '7502009740916', 'FC-50AC2C82', 'Erispan Hypack 8 mg/2 ml', 'ERISPAN HYPACK 8MG B', 1, 24.47, 31, 'marca', 'Medicamentos',
   null, 'Solución inyectable', 'Erispan', 'Maver', 'Caja con 1 ampolleta de 2 ml y jeringa', 'Betametasona',
   '8 mg/2 ml', true, true, 'https://www.farmacapital.mx/catalogo-propia/erispan-hypack-8mg-7502009740916.jpg', null),
  (4, '7501349022249', 'FC-49022249', 'Levetiracetam 1000 mg', 'LEVETIRACETAM 1000MG', 1, 118.18, 190, 'generico', 'Medicamentos',
   'Neurológico', 'Tabletas', 'AMSA', 'AMSA', 'Caja con 30 tabletas', 'Levetiracetam',
   '1000 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/levetiracetam-amsa-1000mg-c30-7501349022249.jpg', null),
  (5, '7501007535494', 'FC-07535494', 'Motrin Infantil', 'MOTRIN INF 2G/100ML', 4, 189.61, 238, 'marca', 'Analgésico',
   'Pediátrico', 'Suspensión', 'Motrin', 'Kenvue', 'Frasco 120 ml', 'Ibuprofeno',
   '2 g/100 ml', false, false, 'https://www.farmacapital.mx/catalogo-propia/motrin-infantil-100mg-5ml-120ml-7501007535494.jpg', null);

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
  'Alta Cityfarma S337748 · 2026-11-04 · listo para pistola',
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
  from _fc_cf_s337748
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
  from _fc_cf_s337748
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
  from _fc_cf_s337748
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S337748',
  '2026-11-04',
  1449.93,
  'borrador',
  'Cityfarma Iztapalapa · orden S337748 · 04-nov-2026 17:29 · Eduardo Nicanor · cliente Luis Angel Palillero · pendiente de pago en papel · cola Recibir, stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'S337748'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 1449.93,
  fecha = '2026-11-04',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Cityfarma Iztapalapa · orden S337748 · 04-nov-2026 17:29 · Eduardo Nicanor · cliente Luis Angel Palillero · pendiente de pago en papel · cola Recibir, stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = 'S337748'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S337748'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s337748 t
join public.recepciones r
  on r.folio = 'S337748'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
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

-- Diagnóstico ticket
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
where r.folio = 'S337748'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
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
from _fc_cf_s337748 t
order by t.linea;

commit;

-- ========== Farma Mayoreo V01000002384 ==========
-- Farma Mayoreo · folio V01000002384 · 2026-11-04 · total $183.52
-- 2 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Costo = P.U. del ticket. PVP = ceil(costo×1.25 marca / ×1.60 genérico).
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_fm_v01000002384 (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into _fc_fm_v01000002384 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501082731323', 'FC-08273132', 'Nuvel Beauty antitranspirante', 'DESODORANTE NUVEL ANTITRANSPIRANTE BEAUTY ROLL-ON 55 ML', 4, 11.96, 15, 'marca', 'Cuidado personal',
   'Desodorante', 'Roll-on', 'Nuvel', 'Nuvel', 'Envase 55 ml', null,
   null, false, false, 'https://www.farmacapital.mx/catalogo-propia/nuvel-beauty-rollon-55ml-7501082731323.jpg', null),
  (2, '7501082730258', 'FC-08273025', 'Nuvel Aclarado Ideal antitranspirante', 'DESODORANTE NUVEL ANTITRANSPIRANTE ACLARADO IDEAL ROLL-ON 50 ML', 8, 16.96, 22, 'marca', 'Cuidado personal',
   'Desodorante', 'Roll-on', 'Nuvel', 'Nuvel', 'Envase 50 ml', null,
   null, false, false, 'https://www.farmacapital.mx/catalogo-propia/nuvel-aclarado-ideal-rollon-50ml-7501082730258.jpg', null);

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
  'Alta Farma Mayoreo V01000002384 · 2026-11-04 · listo para pistola',
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
  from _fc_fm_v01000002384
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
  from _fc_fm_v01000002384
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
  from _fc_fm_v01000002384
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma Mayoreo',
  'V01000002384',
  '2026-11-04',
  183.52,
  'borrador',
  'Farma Mayoreo · ID Venta V01000002384 · 04-nov-2026 16:35 · Central Abastos Bodega 30B Pasillo F · débito BBVA · P.U. con IVA · cola Recibir, stock al confirmar pistola y MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = 'V01000002384'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 183.52,
  fecha = '2026-11-04',
  proveedor = 'Farma Mayoreo',
  notas = 'Farma Mayoreo · ID Venta V01000002384 · 04-nov-2026 16:35 · Central Abastos Bodega 30B Pasillo F · débito BBVA · P.U. con IVA · cola Recibir, stock al confirmar pistola y MMAA',
  updated_at = now()
where folio = 'V01000002384'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'V01000002384'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm_v01000002384 t
join public.recepciones r
  on r.folio = 'V01000002384'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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

-- Diagnóstico ticket
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
where r.folio = 'V01000002384'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm_v01000002384 t
order by t.linea;

commit;

-- ========== Farma MX CAICA1CA111636 ==========
-- Farma MX · folio CAICA1CA111636 · 2026-11-04 · total $217.45
-- 1 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Costo = P.U. del ticket. PVP = ceil(costo×1.25 marca / ×1.60 genérico).
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_mx_ca111636 (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into _fc_mx_ca111636 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7502227427811', 'FC-27427811', 'Detresgel 5000 UI', 'DETRESGEL CAPSULAS 5,000 UI C/30', 5, 43.49, 55, 'marca', 'Vitaminas',
   null, 'Cápsulas blandas', 'Detresgel', 'Gelpharma', 'Frasco con 30 cápsulas', 'Colecalciferol',
   '5000 UI', false, false, 'https://www.farmacapital.mx/catalogo-propia/detresgel-5000ui-c30-7502227427811.jpg', '260779');

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
  'Alta Farma MX CAICA1CA111636 · 2026-11-04 · listo para pistola',
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
  from _fc_mx_ca111636
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
  from _fc_mx_ca111636
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
  from _fc_mx_ca111636
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farma MX',
  'CAICA1CA111636',
  '2026-11-04',
  217.45,
  'borrador',
  'Farma MX / Reinvex Integra · nota CAICA1CA111636 · 04-nov-2026 · Central Abastos F-34A · cliente Yolanda Ventura Medina · lote 260779 en papel · caducidad MMAA de la caja · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'CAICA1CA111636'
    and coalesce(proveedor, '') ilike '%farma mx%'
);

update public.recepciones
set
  total_ticket = 217.45,
  fecha = '2026-11-04',
  proveedor = 'Farma MX',
  notas = 'Farma MX / Reinvex Integra · nota CAICA1CA111636 · 04-nov-2026 · Central Abastos F-34A · cliente Yolanda Ventura Medina · lote 260779 en papel · caducidad MMAA de la caja · cola Recibir',
  updated_at = now()
where folio = 'CAICA1CA111636'
  and coalesce(proveedor, '') ilike '%farma mx%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'CAICA1CA111636'
  and coalesce(r.proveedor, '') ilike '%farma mx%'
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
from _fc_mx_ca111636 t
join public.recepciones r
  on r.folio = 'CAICA1CA111636'
 and coalesce(r.proveedor, '') ilike '%farma mx%'
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

-- Diagnóstico ticket
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
where r.folio = 'CAICA1CA111636'
  and coalesce(r.proveedor, '') ilike '%farma mx%'
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
from _fc_mx_ca111636 t
order by t.linea;

commit;

-- ========== IFC F8 Tienda 132071 ==========
-- IFC F8 Tienda · folio 132071 · 2026-11-04 · total $224.50
-- 1 alta(s) stock 0. 3 ya estaban: solo costo / ficha vacía, no PVP.
-- Costo = P.U. del ticket. PVP = ceil(costo×1.25 marca / ×1.60 genérico).
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_ifc_132071 (
  linea integer primary key,
  ean text,
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
  lote text
) on commit drop;

insert into _fc_ifc_132071 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, null, 'FC-IFC-82972', 'Glicerina Mercurio', 'MERCURIO GLICERINA 250ML. 3010223 82972', 2, 41.00, 52, 'marca', 'Cuidado personal',
   null, 'Solución', 'Mercurio', 'Mercurio', 'Frasco 250 ml', 'Glicerina',
   null, false, false, null, null),
  (2, '3311000001209', 'FC-D4AC123B', 'Aceite de almendras Mercurio', 'MERCURIO ACEITE ALMENDRAS C/25 790527 84525', 5, 8.50, 11, 'marca', 'Cuidado personal',
   null, 'Aceite', 'Mercurio', 'Mercurio', 'Frasco (pieza de C/25)', 'Aceite de almendras',
   null, false, true, null, null),
  (3, '3311000001292', 'FC-00001292', 'Aceite de ricino Mercurio', 'MERCURIO ACEITE RICINO C/25 1120627 84556', 5, 9.50, 12, 'marca', 'Cuidado personal',
   null, 'Aceite', 'Mercurio', 'Mercurio', 'Frasco (pieza de C/25)', 'Aceite de ricino',
   null, false, true, null, null),
  (4, null, 'FC-MER-MANZANA', 'Pomada Manzana Mercurio', 'MERCURIO POMADA MANZANA C/25 2530127 84404', 5, 10.50, 14, 'marca', 'Cuidado personal',
   null, 'Pomada', 'Mercurio', 'Mercurio', 'Pomo (pieza de C/25)', null,
   null, false, true, 'https://www.farmacapital.mx/catalogo-propia/mercurio-pomada-manzana-50g.jpg', null);

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
  'Alta IFC F8 132071 · 2026-11-04 · listo para pistola',
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
  from _fc_ifc_132071
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
  from _fc_ifc_132071
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
  from _fc_ifc_132071
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'IFC F8 Tienda',
  '132071',
  '2026-11-04',
  224.50,
  'borrador',
  'IFC F8 Tienda / Farma Centre · folio 132071 · 04-nov-2026 16:40 · cliente Luis · Mercurio glicerina 250 ml + aceites/pomada por pieza · sin EAN GS1 en glicerina/pomada: ligar código de caja al escanear · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = '132071'
    and coalesce(proveedor, '') ilike '%ifc%'
);

update public.recepciones
set
  total_ticket = 224.50,
  fecha = '2026-11-04',
  proveedor = 'IFC F8 Tienda',
  notas = 'IFC F8 Tienda / Farma Centre · folio 132071 · 04-nov-2026 16:40 · cliente Luis · Mercurio glicerina 250 ml + aceites/pomada por pieza · sin EAN GS1 en glicerina/pomada: ligar código de caja al escanear · cola Recibir',
  updated_at = now()
where folio = '132071'
  and coalesce(proveedor, '') ilike '%ifc%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '132071'
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
from _fc_ifc_132071 t
join public.recepciones r
  on r.folio = '132071'
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

-- Diagnóstico ticket
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
where r.folio = '132071'
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
from _fc_ifc_132071 t
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
    (r.folio = 'S337748' and coalesce(r.proveedor, '') ilike '%cityfarma%')
 or (r.folio = 'V01000002384' and coalesce(r.proveedor, '') ilike '%farma mayoreo%')
 or (r.folio = 'CAICA1CA111636' and coalesce(r.proveedor, '') ilike '%farma mx%')
 or (r.folio = '132071' and coalesce(r.proveedor, '') ilike '%ifc%')
)
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket
order by r.folio;
