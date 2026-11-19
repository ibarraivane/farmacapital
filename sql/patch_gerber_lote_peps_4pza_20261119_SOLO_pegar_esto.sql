-- =============================================================================
-- PEGAR TODO en Supabase → SQL Editor → Run
-- Gerber pouch 4 pza. sin lote PEPS → lote caducidad 2027-05-01.
--
-- Si productos.stock ya es > 0 → el lote usa ese stock (no suma).
-- Si el pouch conocido tiene stock 0 pero sin lote → crea lote de 4 pza.
--   (caso: se vio "4" en la ficha sin haber guardado el stock).
-- Idempotente. Sin $$ / sin producto_imagenes.
-- =============================================================================

begin;

-- 1) DIAGNOSTICO (mira ESTE result primero)
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
    where l.producto_id = p.id and coalesce(l.activo, true) = true
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
    lower(coalesce(p.marca, '') || ' ' || coalesce(p.nombre, '')) like '%gerber%'
    or lower(coalesce(p.presentacion, '') || ' ' || coalesce(p.nombre, '')) like '%pouch%'
    or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
    or p.codigo_barras in ('7501058651129', '7506475114073')
    or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
    or (
      coalesce(p.stock, 0) > 0
      and not exists (
        select 1 from public.lotes l
        where l.producto_id = p.id
          and coalesce(l.activo, true) = true
          and coalesce(l.cantidad_actual, 0) > 0
      )
    )
  )
order by
  case
    when coalesce(p.stock, 0) > 0
     and not exists (
       select 1 from public.lotes l
       where l.producto_id = p.id
         and coalesce(l.activo, true) = true
         and coalesce(l.cantidad_actual, 0) > 0
     ) then 0
    else 1
  end,
  p.stock desc nulls last,
  p.sku
limit 100;

-- 2) Candidatos
create temp table tmp_gerber_peps as
select
  p.id as producto_id,
  p.sku,
  p.codigo_barras,
  p.nombre,
  case
    when coalesce(p.stock, 0) > 0 then coalesce(p.stock, 0)
    else 4
  end as stock,
  coalesce(p.costo, 0) as costo,
  'INV-' || coalesce(nullif(btrim(p.sku), ''), p.id::text) || '-20270501' as numero_lote,
  case
    when coalesce(p.stock, 0) > 0 then 'stock_existente'
    else 'alta_4_pza_ficha'
  end as origen
from public.productos p
where coalesce(p.activo, true) = true
  and not exists (
    select 1
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true) = true
      and coalesce(l.cantidad_actual, 0) > 0
  )
  and (
    -- A) Ya tiene stock huérfano y parece Gerber/pouch/papilla
    (
      coalesce(p.stock, 0) > 0
      and (
        p.codigo_barras in ('7501058651129', '7506475114073')
        or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
        or lower(coalesce(p.marca, '')) like '%gerber%'
        or lower(coalesce(p.nombre, '')) like '%gerber%'
        or lower(coalesce(p.presentacion, '')) like '%pouch%'
        or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
      )
    )
    -- B) Pouch Gerber conocido con stock 0: las 4 pzas de la ficha
    or (
      coalesce(p.stock, 0) = 0
      and (
        p.codigo_barras in ('7501058651129', '7506475114073')
        or p.sku in ('FC-58651129', 'FC-75114073', 'FC-ND-75114073')
        or (
          lower(coalesce(p.nombre, '')) like '%gerber%'
          and (
            lower(coalesce(p.presentacion, '')) like '%pouch%'
            or lower(coalesce(p.nombre, '')) like '%pouch%'
            or lower(coalesce(p.forma_farmaceutica, '')) like '%papilla%'
          )
        )
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
  t.origen,
  t.stock as qty_lote,
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
