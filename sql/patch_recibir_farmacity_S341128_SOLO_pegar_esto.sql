-- =============================================================================
-- PEGAR TODO ESTE ARCHIVO en Supabase → SQL Editor → Run
-- Farma City / Cityfarma Iztapalapa S341128 · $3,312.49 · 18 renglones · 60 pzas
-- Merge a GitHub NO crea la cola. Sin dollar-quote. Sin producto_imagenes.
-- Lote de fabrica si. Caducidad null: MMAA de la caja. No inventar 0000.
-- =============================================================================

rollback;

-- ========== Cityfarma Iztapalapa S341128 ==========
-- Cityfarma Iztapalapa · folio S341128 · 2026-11-23 · total $3,312.49 · 18 renglones
-- 10 alta(s) stock 0. 8 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_cf_s341128 (
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

insert into _fc_cf_s341128 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501008499818', 'FC-08499818', 'Aspirina 500 mg', 'ASPIRINA 500MG C80 T', 2, 75.51, 95, 'marca', 'Medicamentos', null, 'Tabletas', 'Aspirina', 'Bayer', 'Caja con 80 tabletas', 'Acido acetilsalicilico', '500 mg', false, true, null, 'X26SW7'),
  (2, '7502001166066', 'FC-01166066', 'Barmicil', 'BARMICIL 40G SONS BE', 15, 19.82, 25, 'marca', 'Medicamentos', null, 'Crema', 'Barmicil', 'Sons', 'Tubo 40 g', 'Betametasona / Gentamicina / Clotrimazol', null, false, true, null, null),
  (3, '7501008433676', 'FC-08433676', 'Cafiaspirina', 'CAFIASPIRINA 40TAB J', 3, 42.05, 53, 'marca', 'Medicamentos', null, 'Tabletas', 'Cafiaspirina', 'Bayer', 'Caja con 40 tabletas', 'Acido acetilsalicilico / Cafeina', null, false, false, null, null),
  (4, '7501008433553', 'FC-08433553', 'Cafiaspirina Forte', 'CAFIASPIRINA FORTE C', 3, 71.71, 90, 'marca', 'Medicamentos', null, 'Tabletas', 'Cafiaspirina', 'Bayer', 'Caja con 24 tabletas', 'Acido acetilsalicilico / Cafeina', null, false, true, null, null),
  (5, '7502009743627', 'FC-09743627', 'Cefalexina suspension 250 mg/5 ml', 'CEFALEXINA SUSP 250M', 3, 21.46, 35, 'generico', 'Medicamentos', null, 'Suspension', 'Cefalexina', 'Maver', 'Frasco 100 ml', 'Cefalexina', '250 mg/5 ml', true, false, null, '264360'),
  (6, '7502240450018', 'EQ-WER038', 'Charyn 500 mg', 'CHARYN 500MG C 3 TAB', 10, 22.35, 28, 'marca', 'Medicamentos', null, 'Tabletas', 'Charyn', 'Wermar', 'Caja con 3 tabletas', 'Azitromicina', '500 mg', true, true, null, '260460'),
  (7, '7502240450025', 'FC-40450025', 'Charyn 500 mg', 'CHARYN C4TAB 500MG A', 5, 29.89, 38, 'marca', 'Medicamentos', null, 'Tabletas', 'Charyn', 'Wermar', 'Caja con 4 tabletas', 'Azitromicina', '500 mg', true, false, null, '260533'),
  (8, '7501258205221', 'FC-58205221', 'Cyrux 200 mcg', 'CYRUX 200MG C28 TABS', 2, 186.18, 233, 'marca', 'Medicamentos', null, 'Tabletas', 'Cyrux', 'Serral', 'Caja con 28 tabletas', 'Misoprostol', '200 mcg', true, false, null, '260474'),
  (9, '5000174003963', 'FC-74003963', 'Fixodent Fresh', 'FIXODENT FRESH PAST', 2, 89.21, 112, 'marca', 'Cuidado personal', null, 'Adhesivo dental', 'Fixodent', null, 'Pasta 40 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/fixodent-fresh-40g.jpg', '6054028890'),
  (10, '650240070389', 'FC-40070389', 'Genoprazol 20 mg', 'GENOPRAZOL 20MG CAP', 1, 82.84, 104, 'marca', 'Medicamentos', null, 'Capsulas', 'Genoprazol', 'Genomma', '2 pack 14 capsulas', 'Omeprazol', '20 mg', false, false, null, 'G248'),
  (11, '7501871720606', 'FC-71720606', 'Geslutin 100 mg', 'GESLUTIN 100MG C 30', 1, 460.06, 576, 'marca', 'Medicamentos', null, 'Perlas', 'Geslutin', 'Asofarma', 'Caja con 30 perlas', 'Progesterona', '100 mg', true, false, null, '10049'),
  (12, '7501547509016', 'FC-F7A2CACF', 'Indarzona', 'INDARZONA CAP C 30', 2, 56.50, 71, 'marca', 'Medicamentos', null, 'Capsulas', 'Indarzona', 'Streger', 'Caja con 30 capsulas', 'Indometacina / Dexametasona', '25 mg / 0.5 mg', true, true, null, 'SB02DC'),
  (13, '7502001162365', 'FC-01162365', 'Mornin 40 mg', 'MORNIN 40MG C7 CAPS', 5, 12.91, 17, 'marca', 'Medicamentos', null, 'Capsulas', 'Mornin', 'Sons', 'Caja con 7 capsulas', 'Omeprazol', '40 mg', false, true, null, '26061602'),
  (14, '008400007018', 'FC-00007018', 'Neomicina Polimixina Gramicidina', 'NEOMICINA POLIMIXINA', 1, 53.32, 86, 'generico', 'Medicamentos', null, 'Gotas oftalmicas', 'Grin', 'Grin', 'Frasco 15 ml', 'Neomicina / Polimixina B / Gramicidina', null, true, false, null, 'XB01110'),
  (15, '7502009749247', 'FC-09749247', 'Rivaroxaban 20 mg', 'RIVAROXABAN 20MG C28', 2, 151.44, 243, 'generico', 'Medicamentos', null, 'Tabletas', 'Rivaroxaban', 'Maver', 'Caja con 28 tabletas', 'Rivaroxaban', '20 mg', true, false, null, '255115'),
  (16, '650240010712', 'FC-40010712', 'Tukol-D jarabe adulto', 'TUKOL D JBE AD 125', 1, 94.73, 119, 'marca', 'Medicamentos', null, 'Jarabe', 'Tukol-D', 'Genomma', 'Frasco 125 ml', 'Guaifenesina / Dextrometorfano', null, false, true, null, null),
  (17, '3700039500027', 'FC-39500027', 'Utrogestan 100 mg', 'UTROGESTAN 100MG PER', 1, 347.53, 435, 'marca', 'Medicamentos', null, 'Capsulas', 'Utrogestan', 'Besins', 'Caja', 'Progesterona', '100 mg', true, false, null, '262085'),
  (18, '7502223553477', 'FC-23553477', 'Zolufen 20 mg', 'ZOLUFEN 20MG CAP C30', 1, 15.88, 20, 'marca', 'Medicamentos', null, 'Capsulas', 'Zolufen', 'Synthon', 'Frasco con 30 capsulas', 'Omeprazol', '20 mg', false, true, 'https://www.farmacapital.mx/catalogo-propia/zolufen-omeprazol-20mg-30caps-7502223553477.jpg', 'Z26013A');

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
  'Alta Cityfarma Iztapalapa S341128 · 2026-11-23 · listo para pistola',
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
  from _fc_cf_s341128
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
  from _fc_cf_s341128
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
  from _fc_cf_s341128
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
  'S341128',
  '2026-11-23',
  3312.49,
  'borrador',
  'Cityfarma Iztapalapa · orden S341128 · 23-nov-2026 13:28 · cliente Luis Angel Palillero Ventura · prioridad ALTA · surtido sin certificar · 18 renglones · 60 pzas · efectivo $3,312.49 · folio estimado (estampa tapa orden) · lote de fabrica si; caducidad NO · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'S341128'
    and coalesce(proveedor, '') ilike '%cityfarma%'
);

update public.recepciones
set
  total_ticket = 3312.49,
  fecha = '2026-11-23',
  proveedor = 'Cityfarma Iztapalapa',
  notas = 'Cityfarma Iztapalapa · orden S341128 · 23-nov-2026 13:28 · cliente Luis Angel Palillero Ventura · prioridad ALTA · surtido sin certificar · 18 renglones · 60 pzas · efectivo $3,312.49 · folio estimado (estampa tapa orden) · lote de fabrica si; caducidad NO · cola Recibir',
  updated_at = now()
where folio = 'S341128'
  and coalesce(proveedor, '') ilike '%cityfarma%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'S341128'
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
from _fc_cf_s341128 t
join public.recepciones r
  on r.folio = 'S341128'
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
where r.folio = 'S341128'
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
from _fc_cf_s341128 t
order by t.linea;

commit;
