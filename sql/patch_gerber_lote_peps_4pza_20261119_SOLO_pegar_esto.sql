-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Gerber pouch: 4 pza. en stock sin lote PEPS → crea el lote con caducidad
-- 2027-05-01. No suma unidades ni cambia precio.
-- Idempotente. Sin dollar-quote. Sin producto_imagenes.
-- =============================================================================

begin;

-- 1) DIAGNOSTICO: qué Gerber hay con stock y sin lote con piezas
select
  p.id,
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.stock,
  (
    select count(*)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  ) as lotes_con_piezas
from public.productos p
where coalesce(p.activo, true) = true
  and coalesce(p.stock, 0) > 0
  and (
    lower(coalesce(p.marca, '')) like '%gerber%'
    or lower(coalesce(p.nombre, '')) like '%gerber%'
    or p.codigo_barras in ('7501058651129', '7506475114073')
    or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
  )
order by p.stock desc, p.sku;

create temp table tmp_gerber_peps as
select
  p.id as producto_id,
  p.sku,
  p.codigo_barras,
  p.nombre,
  coalesce(p.stock, 0) as stock,
  coalesce(p.costo, 0) as costo,
  'INV-' || coalesce(nullif(btrim(p.sku), ''), p.id::text) || '-20270501' as numero_lote
from public.productos p
where coalesce(p.activo, true) = true
  and coalesce(p.stock, 0) > 0
  and (
    p.codigo_barras in ('7501058651129', '7506475114073')
    or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
    or (
      lower(coalesce(p.marca, '')) like '%gerber%'
      and (
        lower(coalesce(p.presentacion, '')) like '%pouch%'
        or lower(coalesce(p.presentacion, '')) like '%95%'
        or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
        or lower(coalesce(p.nombre, '')) like '%pouch%'
        or coalesce(p.stock, 0) = 4
      )
    )
  )
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  );

insert into public.lotes (
  producto_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  fecha_caducidad,
  costo_unitario,
  activo
)
select
  t.producto_id,
  t.numero_lote,
  t.stock,
  t.stock,
  date '2027-05-01',
  t.costo,
  true
from tmp_gerber_peps t
where not exists (
  select 1
  from public.lotes l
  where l.producto_id = t.producto_id
    and l.numero_lote = t.numero_lote
);

-- 2) VERIFICACION: lote creado
select
  t.producto_id,
  t.sku,
  t.codigo_barras,
  t.nombre,
  t.stock as stock_antes,
  l.id as lote_id,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  p.stock as stock_despues
from tmp_gerber_peps t
join public.productos p on p.id = t.producto_id
left join public.lotes l
  on l.producto_id = t.producto_id
 and l.numero_lote = t.numero_lote;

select count(*) as filas_insertadas_candidatas from tmp_gerber_peps;

commit;
