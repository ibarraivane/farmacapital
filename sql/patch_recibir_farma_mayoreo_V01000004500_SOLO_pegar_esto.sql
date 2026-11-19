-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 · $1,625.91 · 7 renglones
-- Standalone: este ticket pudo no entrar si solo se reintentó Cityfarma+Surtidor.
-- Caducidad null (MMAA de caja). Sin dollar-quote. Sin producto_imagenes.
-- Idempotente en borrador.
-- =============================================================================

rollback;

-- ========== Farma Mayoreo V01000004500 ==========
-- Farma Mayoreo · folio V01000004500 · 2026-11-17 · total $1,625.91
-- P.U. con IVA. Suma renglones = total.
-- 6 alta(s) stock 0. 1 ya estaban: solo costo / ficha vacia, no PVP.
-- Nombres de ficha, no del ticket. SIN dollar-quote. Idempotente en borrador.
-- Caducidad null: MMAA de la caja. No inventar 0000.

begin;

create temp table _fc_fm_4500 (
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

insert into _fc_fm_4500 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, lote
) values
  (1, '7501088575396', 'FC-88575396', 'Troferit 3 mg/mL jarabe 120 mL', 'TROFERIT 3MG/ML CON FRASCO 120ML', 1, 144.97, 182, 'marca', 'Medicamentos', null, 'Jarabe', 'Troferit', null, 'Frasco 120 mL', 'Levodropropizina', '3 mg/mL', true, false, null, 'BFG058'),
  (2, '7501037907117', 'FC-7907117', 'Bisolvon solucion adulto 120 mL', 'BISOLVON SOLUCION ADULTO FRASCO CON 120 ML', 2, 146.98, 184, 'marca', 'Medicamentos', null, 'Solucion', 'Bisolvon', 'Sanofi', 'Frasco 120 mL', 'Bromhexina', '160 mg/100 mL', false, true, null, '23980029'),
  (3, '7501159580182', 'FC-59580182', 'Sinuberase probioticos 4 billones', 'SINUBERASE PROBIOTICOS CAJA CON 10 AMPOLLETAS', 3, 217.98, 273, 'marca', 'Gastro', null, 'Ampolletas', 'Sinuberase', null, 'Caja con 10 ampolletas', 'Bacillus clausii', '4 billones UFC', false, false, null, 'B1175'),
  (4, '7501089810526', 'FC-89810526', 'Picosend amoniaco 3.5%', 'PICOSEND AMONIACO SOLUCION 3.5% TUBO CON 11 ML', 2, 73.98, 93, 'marca', 'Botiquin', null, 'Solucion', 'Picosend', null, 'Tubo 11 mL', null, '3.5%', false, false, null, null),
  (5, '7501089810625', 'FC-89810625', 'Picosend Protect repelente 120 mL', 'PICOSEND PROTECT REPELENTE 120ML', 2, 81.98, 103, 'marca', 'Botiquin', null, 'Repelente', 'Picosend', null, 'Frasco 120 mL', null, null, false, false, null, null),
  (6, '75012571', 'FC-75012571', 'Picosend Protect travel 50 mL', 'REPEL PICOSEND PROTECT TRAVE 50 ML', 3, 38.98, 49, 'marca', 'Botiquin', null, 'Repelente', 'Picosend', null, 'Frasco 50 mL', null, null, false, false, null, null),
  (7, '7501299368145', 'FC-99368145', 'Sensibit D NF', 'SENSIBIT D NF 2X1', 2, 52.09, 66, 'marca', 'Medicamentos', 'Respiratorio', 'Jarabe', 'Sensibit', null, '2x1', null, null, false, false, null, '010484');

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
  'Alta Farma Mayoreo V01000004500 · 2026-11-17 · listo para pistola',
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
  from _fc_fm_4500
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
  from _fc_fm_4500
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
  from _fc_fm_4500
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
  'Farma Mayoreo',
  'V01000004500',
  '2026-11-17',
  1625.91,
  'borrador',
  'Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 11:31 · TC BBVA $1,625.91 · P.U. ya traen IVA (suma renglones = total) · lote de fabrica; caducidad NO · cola Recibir'
where not exists (
  select 1 from public.recepciones
  where folio = 'V01000004500'
    and coalesce(proveedor, '') ilike '%farma mayoreo%'
);

update public.recepciones
set
  total_ticket = 1625.91,
  fecha = '2026-11-17',
  proveedor = 'Farma Mayoreo',
  notas = 'Farma Mayoreo · ID Venta V01000004500 · 17-nov-2026 11:31 · TC BBVA $1,625.91 · P.U. ya traen IVA (suma renglones = total) · lote de fabrica; caducidad NO · cola Recibir',
  updated_at = now()
where folio = 'V01000004500'
  and coalesce(proveedor, '') ilike '%farma mayoreo%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = 'V01000004500'
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
from _fc_fm_4500 t
join public.recepciones r
  on r.folio = 'V01000004500'
 and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
where r.folio = 'V01000004500'
  and coalesce(r.proveedor, '') ilike '%farma mayoreo%'
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
from _fc_fm_4500 t
order by t.linea;

commit;
