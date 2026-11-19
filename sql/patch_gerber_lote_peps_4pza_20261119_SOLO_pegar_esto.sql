-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Gerber pouch: 4 pza. en stock sin lote PEPS → crea el lote con caducidad
-- 2027-05-01 (la fecha que se eligió en Inventario). No suma ni cambia precio.
-- Idempotente. Sin dollar-quote. Sin producto_imagenes.
-- Cubre frutas mixtas (7501058651129) y pouch manzana (7506475114073) si
-- tienen stock > 0 y aún no tienen lote con piezas.
-- =============================================================================

begin;

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
      and lower(coalesce(p.presentacion, '')) like '%pouch%95%'
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

-- VERIFICACION
select
  p.id,
  p.sku,
  p.codigo_barras,
  p.nombre,
  p.stock,
  l.id as lote_id,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad
from public.productos p
left join public.lotes l
  on l.producto_id = p.id
 and coalesce(l.activo, true) = true
 and coalesce(l.cantidad_actual, 0) > 0
where p.codigo_barras in ('7501058651129', '7506475114073')
   or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
order by p.sku, l.id;

select count(*) as candidatos_sin_lote_antes
from tmp_gerber_peps;

commit;
