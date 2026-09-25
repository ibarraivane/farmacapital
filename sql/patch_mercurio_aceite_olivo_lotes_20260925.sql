-- Mercurio Aceite Olivo (y hermanos): stock en ficha pero POS «Sin lotes».
--
-- Qué pasa:
--   · Inventario muestra stock=3 (productos.stock).
--   · El POS vende por PEPS: suma lotes activos con cantidad > 0.
--   · Si hay filas de lote en 0 / sin lote vendible, IGNORA productos.stock
--     y marca «Sin lotes» / Agregar apagado.
--   · Aceite Olivo FC-5A697CC2 quedó con caducidad NULL
--     (patch_restaurar_caducidades_20260818) y sin lote vendible.
--
-- Aceites Mercurio no traen fecha legible → dueño: cad 01.2030
--   (MMAA → 2030-01-31, fin de mes FEFO).
--
-- También repara TODO Mercurio activo con stock > 0 y sin lote vendible
-- (misma trampa). Al final lista otros marcas con el mismo problema.
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

-- ── Diagnóstico previo ──────────────────────────────────────────────────────
select
  p.sku,
  left(p.nombre, 42) as nombre,
  p.stock as stock_ficha,
  coalesce((
    select sum(l.cantidad_actual)::int
    from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  ), 0) as en_lotes,
  (
    select count(*)::int from public.lotes l
    where l.producto_id = p.id
  ) as filas_lote,
  (
    select string_agg(l.numero_lote || ':' || coalesce(l.cantidad_actual, 0)::text, ', ')
    from public.lotes l
    where l.producto_id = p.id
  ) as detalle_lotes
from public.productos p
where p.activo = true
  and coalesce(p.marca, '') ilike 'mercurio%'
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  )
order by p.nombre;

-- Ficha Olivo
update public.productos set
  nombre = 'Mercurio aceite olivo',
  marca = 'Mercurio',
  presentacion = '50 mL',
  forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Aceite'),
  principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Aceite de olivo'),
  codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '3311000001582'),
  precio = case when coalesce(precio, 0) < 10 then 15 else precio end,
  activo = true
where sku = 'FC-5A697CC2';

-- Candidatos: Mercurio con stock y sin lote vendible
create temporary table _fc_mer_sin_lote (
  producto_id bigint primary key,
  sku text not null,
  stock integer not null,
  costo numeric,
  es_aceite boolean not null default false
) on commit drop;

insert into _fc_mer_sin_lote (producto_id, sku, stock, costo, es_aceite)
select
  p.id,
  p.sku,
  p.stock::integer,
  p.costo,
  (
    coalesce(p.forma_farmaceutica, '') ilike '%aceite%'
    or p.nombre ilike '%aceite%'
    or p.sku in (
      'FC-5A697CC2',  -- olivo
      'FC-69387811',  -- gomenolado
      'FC-931B4809',  -- coco
      'FC-38CAFE6B',  -- romero
      'FC-D4AC123B'   -- almendras
    )
  )
from public.productos p
where p.activo = true
  and coalesce(p.marca, '') ilike 'mercurio%'
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  );

-- 1) Reactivar / rellenar un lote vacío existente (SIN-LOTE, SYNC, etc.)
update public.lotes l
   set
     cantidad_actual = c.stock,
     cantidad_inicial = greatest(coalesce(l.cantidad_inicial, 0), c.stock),
     activo = true,
     fecha_caducidad = case
       when c.es_aceite then coalesce(l.fecha_caducidad, '2030-01-31'::date)
       else coalesce(l.fecha_caducidad, '2030-01-31'::date)
     end,
     costo_unitario = coalesce(l.costo_unitario, c.costo, 0)
  from _fc_mer_sin_lote c
 where l.id = (
   select l2.id
   from public.lotes l2
   where l2.producto_id = c.producto_id
   order by
     case when l2.numero_lote ilike 'SIN-LOTE-%' then 0
          when l2.numero_lote ilike 'SYNC-%' then 1
          else 2 end,
     l2.id desc
   limit 1
 )
 and coalesce(l.cantidad_actual, 0) <= 0;

-- 2) Insertar lote nuevo si sigue sin vendible
insert into public.lotes (
  producto_id,
  numero_lote,
  cantidad_inicial,
  cantidad_actual,
  costo_unitario,
  fecha_caducidad,
  activo
)
select
  c.producto_id,
  case
    when c.es_aceite then 'SC-0130-' || c.sku   -- sin caducidad real · MMAA 01.2030
    else 'INV-' || c.sku || '-20260925'
  end,
  c.stock,
  c.stock,
  coalesce(c.costo, 0),
  '2030-01-31'::date,  -- 01.2030
  true
from _fc_mer_sin_lote c
where not exists (
  select 1 from public.lotes l
  where l.producto_id = c.producto_id
    and coalesce(l.activo, true)
    and coalesce(l.cantidad_actual, 0) > 0
);

-- 3) Aceites Mercurio que SÍ tienen lote pero cad NULL → poner 01.2030
update public.lotes l
   set fecha_caducidad = '2030-01-31'::date
  from public.productos p
 where l.producto_id = p.id
   and p.activo = true
   and coalesce(p.marca, '') ilike 'mercurio%'
   and (
     coalesce(p.forma_farmaceutica, '') ilike '%aceite%'
     or p.nombre ilike '%aceite%'
     or p.sku in (
       'FC-5A697CC2', 'FC-69387811', 'FC-931B4809',
       'FC-38CAFE6B', 'FC-D4AC123B'
     )
   )
   and l.fecha_caducidad is null
   and coalesce(l.activo, true)
   and coalesce(l.cantidad_actual, 0) > 0;

-- Resync stock ficha = suma lotes (por si el trigger no corre en bulk)
update public.productos p
   set stock = coalesce((
     select sum(l.cantidad_actual)::integer
     from public.lotes l
     where l.producto_id = p.id
       and coalesce(l.activo, true)
   ), 0)
 where p.id in (select producto_id from _fc_mer_sin_lote)
    or p.sku = 'FC-5A697CC2';

commit;

-- ── Verificación Olivo + aceites ────────────────────────────────────────────
select
  p.sku,
  left(p.nombre, 36) as nombre,
  p.stock as stock_ficha,
  p.presentacion,
  l.numero_lote,
  l.cantidad_actual,
  l.fecha_caducidad,
  l.activo
from public.productos p
left join public.lotes l
  on l.producto_id = p.id and coalesce(l.activo, true)
where p.sku in (
  'FC-5A697CC2', 'FC-69387811', 'FC-931B4809',
  'FC-38CAFE6B', 'FC-D4AC123B'
)
order by p.sku, l.id;

-- Mercurio que aún quedaría sin lote vendible (debe ser 0)
select p.sku, left(p.nombre, 42) as nombre, p.stock
from public.productos p
where p.activo = true
  and coalesce(p.marca, '') ilike 'mercurio%'
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  )
order by p.nombre;

-- Otros (no Mercurio) con la misma trampa — solo reporte, no se tocan
select p.sku, left(p.nombre, 40) as nombre, p.stock, coalesce(p.marca, '') as marca
from public.productos p
where p.activo = true
  and coalesce(p.marca, '') not ilike 'mercurio%'
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  )
order by p.stock desc, p.sku
limit 40;

select count(*) as otros_stock_sin_lote_vendible
from public.productos p
where p.activo = true
  and coalesce(p.marca, '') not ilike 'mercurio%'
  and coalesce(p.stock, 0) > 0
  and not exists (
    select 1 from public.lotes l
    where l.producto_id = p.id
      and coalesce(l.activo, true)
      and coalesce(l.cantidad_actual, 0) > 0
  );
