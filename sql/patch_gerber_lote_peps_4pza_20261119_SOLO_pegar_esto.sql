-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Gerber / pouch sin lote PEPS → crea lote con caducidad 2027-05-01.
-- No suma unidades ni cambia precio. Idempotente. Sin $$ / sin producto_imagenes.
--
-- Si filas_insertadas_candidatas sale 0 otra vez: mira el Result del DIAGNOSTICO
-- (primera tabla) y copia sku / stock / marca / presentacion.
-- =============================================================================

begin;

-- 1) DIAGNOSTICO amplio: stock > 0 sin lote con piezas (todo el catálogo chico)
--    + cualquier Gerber/pouch/papilla aunque stock=0
select
  p.id,
  p.sku,
  p.codigo_barras,
  left(p.nombre, 60) as nombre,
  p.marca,
  p.presentacion,
  p.forma_farmaceutica,
  p.stock,
  (
    select coalesce(sum(l.cantidad_actual), 0)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
  ) as sum_lotes,
  (
    select count(*)
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  ) as lotes_con_piezas
from public.productos p
where coalesce(p.activo, true) = true
  and (
    coalesce(p.stock, 0) > 0
    or lower(coalesce(p.marca, '') || ' ' || coalesce(p.nombre, '') || ' ' || coalesce(p.presentacion, ''))
         like '%gerber%'
    or lower(coalesce(p.presentacion, '') || ' ' || coalesce(p.nombre, '')) like '%pouch%'
    or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
    or p.codigo_barras in ('7501058651129', '7506475114073')
    or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
  )
order by
  case when coalesce(p.stock, 0) > 0
            and not exists (
              select 1 from public.lotes l
              where l.producto_id = p.id
                and coalesce(l.activo, true) = true
                and coalesce(l.cantidad_actual, 0) > 0
            ) then 0 else 1 end,
  p.stock desc nulls last,
  p.sku
limit 80;

-- 2) Candidatos: stock > 0, sin lote con piezas, y parece Gerber/pouch/papilla
--    (marca O nombre O presentacion O forma O EAN/SKU conocidos)
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
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  )
  and (
    p.codigo_barras in ('7501058651129', '7506475114073')
    or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
    or lower(coalesce(p.marca, '')) like '%gerber%'
    or lower(coalesce(p.nombre, '')) like '%gerber%'
    or lower(coalesce(p.presentacion, '')) like '%pouch%'
    or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
    or (
      coalesce(p.stock, 0) = 4
      and (
        lower(coalesce(p.nombre, '') || ' ' || coalesce(p.marca, '') || ' ' || coalesce(p.presentacion, ''))
          ~ '(gerber|pouch|papilla|junior)'
      )
    )
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

-- 3) VERIFICACION
select
  t.producto_id,
  t.sku,
  t.codigo_barras,
  left(t.nombre, 60) as nombre,
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
