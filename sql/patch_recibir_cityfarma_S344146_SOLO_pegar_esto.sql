-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Farma City / Cityfarma Iztapalapa S344146 · 25-nov-2026 09:43
-- Subtotal impreso $3,091.24 · Total impreso $0.00 (sin pago)
-- 9 renglones · 25 pzas · total $3,106.11
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Lote solo si viene impreso. Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== Cityfarma Iztapalapa S344146 ==========
-- 4 alta(s) stock 0. 5 ya estaban en catálogo: solo costo (precio solo si estaba en 0).
-- Nombres de ficha, no del ticket. Idempotente mientras el ticket siga en borrador.

begin;

create temp table _fc_cf_s344146 (
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

insert into _fc_cf_s344146 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501537103545', 'FC-37103545', 'Adinol Paracetamol Infantil 3.2 g/100 ml', 'ADINOL PARACETAMOL I', 2, 20.90, 27, 'marca', 'Medicamentos', 'Analgésicos y antipiréticos', 'Solución oral', 'Adinol', 'Bruluart', 'Frasco 120 ml con cuchara dosificadora', 'Paracetamol', '3.2 g/100 ml', true, false, 'https://www.farmacapital.mx/catalogo-propia/adinol-paracetamol-infantil-uva-7501537103545.jpg', null),
  (2, '780083148645', 'FC-83148645', 'Cobedina NS', 'COBEDINA NS C10 TABS', 2, 10.40, 13, 'marca', 'Medicamentos', 'Antialérgicos y corticoides', 'Tabletas', 'Cobedina', 'Collins', 'Caja con 10 tabletas', 'Loratadina / Betametasona', '5 mg / 0.25 mg', true, false, 'https://www.farmacapital.mx/catalogo-propia/cobedina-ns-loratadina-betametasona-780083148645.jpg', null),
  (3, '7501125104268', 'FC-25104268', 'Electrolit Fresa 625 ml', 'ELECTROLIT 625ML FRE', 2, 20.14, 26, 'marca', 'Hidratación', 'Electrolitos', 'Suero oral', 'Electrolit', 'Lab Pisa', 'Botella 625 ml', null, null, false, true, null, null),
  (4, '7501033956140', 'FC-33956140', 'Glucerna fresa 237 ml', 'GLUCERNA 237ML FRESA', 5, 50.56, 64, 'marca', 'Suplemento', 'Suplemento nutricional', 'Líquido', 'Glucerna', 'Abbott', 'Frasco 237 ml', null, null, false, true, null, null),
  (5, '75049805', 'EQ-EXA035', 'Neomicina polimixina gramicidina 15 ml', 'NEOMICINA POLIMIXINA', 2, 37.81, 61, 'generico', 'Medicamentos', null, 'Gotas oftálmicas', 'Exakta', 'Exakta', 'Frasco 15 ml gotas oftálmicas', 'Neomicina / Polimixina B / Gramicidina', null, true, true, null, null),
  (6, '7503028771691', 'FC-28771691', 'Rosuvastatina 20 mg', 'ROSUVASTATINA 20MG C', 4, 35.74, 58, 'generico', 'Medicamentos', 'Cardiovascular', 'Tabletas', 'Suanca', 'Suanca', 'Caja con 10 tabletas', 'Rosuvastatina', '20 mg', true, false, null, null),
  (7, '7501537163266', 'FC-37163266', 'Tribedoce Compuesto', 'TRIBEDOCE COMP C3 AM', 5, 50.11, 63, 'marca', 'Medicamentos', null, 'Ampolleta', 'Tribedoce', 'Bruluart', 'Caja con 3 ampolletas', 'Diclofenaco / complejo B (tiamina, piridoxina, cianocobalamina)', null, true, true, null, null),
  (8, '7500435122726', 'FC-35122726', 'Vicks VapoRub 12 g', 'VAPORUB EXH C 12 LAT', 1, 260.00, 325, 'marca', 'Botiquín', null, 'Ungüento', 'Vicks', 'Procter & Gamble', 'Exhibidor con 12 latas de 12 g', 'Alcanfor / mentol / aceite de eucalipto', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/vicks-vaporub-12g.jpg', null),
  (9, '7501871720590', 'FC-71720590', 'Vartalon Compositum', 'VARTALON COMP C30 SO', 2, 1010.64, 1264, 'marca', 'Medicamentos', null, 'Polvo', 'Vartalon', 'Asofarma', 'Caja con 30 sobres', null, null, false, true, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when not exists (
      select 1 from public.productos p where p.sku = t.sku
    ) then t.sku
    when t.ean is not null and not exists (
      select 1 from public.productos p
      where p.sku = ('FC-ND-' || right(t.ean, 8))
    ) then 'FC-ND-' || right(t.ean, 8)
    when t.ean is not null then
      'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
    else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Cityfarma Iztapalapa S344146 · 2026-11-25 · listo para pistola',
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
  from _fc_cf_s344146
  order by coalesce(ean, sku), linea
) t
where (t.ean is null or not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  ))
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
      and (
        t.ean is null
        or nullif(btrim(p.codigo_barras), '') is null
        or nullif(btrim(p.codigo_barras), '') = t.ean
      )
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = (
      case
        when not exists (
          select 1 from public.productos x where x.sku = t.sku
        ) then t.sku
        when t.ean is not null and not exists (
          select 1 from public.productos x
          where x.sku = ('FC-ND-' || right(t.ean, 8))
        ) then 'FC-ND-' || right(t.ean, 8)
        when t.ean is not null then
          'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.ean, 8)
        else 'FC-T' || lpad(t.linea::text, 2, '0') || '-' || right(t.sku, 8)
      end
    )
  );

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s344146
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
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
  codigo_barras = coalesce(nullif(p.codigo_barras, ''), t.ean)
from (
  select distinct on (coalesce(ean, sku)) *
  from _fc_cf_s344146
  order by coalesce(ean, sku), linea
) t
where p.id = coalesce(
  case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku),
  (
    select p2.id from public.productos p2
    where t.ean is not null
      and nullif(btrim(p2.codigo_barras), '') = t.ean
    order by p2.id
    limit 1
  ),
  (
    select p2.id from public.productos p2
    where p2.sku = t.sku
    order by p2.id
    limit 1
  )
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Cityfarma Iztapalapa',
  'S344146',
  '2026-11-25',
  3106.11,
  'borrador',
  'Cityfarma Iztapalapa · pedido S344146 · 25-nov-2026 09:43 · cliente Luis Angel Palillero Ventura · vendedor Eduardo Nicanor · 9 renglones · 25 pzas · suma renglones $3,106.11 (subtotal papel $3,091.24) · sin lote impreso · caducidad NO · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'S344146'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 3106.11,
  fecha = '2026-11-25',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Cityfarma Iztapalapa · pedido S344146 · 25-nov-2026 09:43 · cliente Luis Angel Palillero Ventura · vendedor Eduardo Nicanor · 9 renglones · 25 pzas · suma renglones $3,106.11 (subtotal papel $3,091.24) · sin lote impreso · caducidad NO · cola Recibir',
  updated_at = now()
where folio = 'S344146'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S344146'
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
  t.snap,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  false,
  null
from _fc_cf_s344146 t
join public.recepciones r
  on r.folio = 'S344146'
 and coalesce(r.proveedor, '') ilike '%cityfarma%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(nullif(btrim(t.ean), ''))
      else null end,
    public.fc_buscar_producto_escaneo(t.sku),
    (
      select p2.id from public.productos p2
      where nullif(btrim(t.ean), '') is not null
        and nullif(btrim(p2.codigo_barras), '') = nullif(btrim(t.ean), '')
      order by p2.id
      limit 1
    ),
    (
      select p2.id from public.productos p2
      where p2.sku = t.sku
      order by p2.id
      limit 1
    )
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
where r.folio = 'S344146'
  and coalesce(r.proveedor, '') ilike '%cityfarma%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.sku,
  t.nombre,
  t.qty,
  t.costo,
  t.lote,
  case
    when coalesce(
      case when t.ean is not null then public.fc_buscar_producto_escaneo(t.ean) end,
      public.fc_buscar_producto_escaneo(t.sku),
      (
        select p2.id from public.productos p2
        where t.ean is not null
          and nullif(btrim(p2.codigo_barras), '') = t.ean
        order by p2.id
        limit 1
      ),
      (
        select p2.id from public.productos p2
        where p2.sku = t.sku
        order by p2.id
        limit 1
      )
    ) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_cf_s344146 t
order by t.linea;

commit;
