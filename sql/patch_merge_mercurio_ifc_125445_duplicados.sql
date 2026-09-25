-- Mercurio IFC 125445: duplicados sin EAN → ficha canónica.
--
-- Auditoría del ticket (6 Mercurio):
--
--   DUPLICADOS (merge):
--   · FC-IFC-1400724 → FC-578F060C  Mercurio bórax polvo
--       EAN 3311000003739 (lote 5721). Ya en patch_merge_mercurio_borax_ifc_1400724.sql
--       (este archivo lo re-aplica idempotente).
--   · FC-IFC-82943   → FC-MER-MANZANA  Mercurio pomada manzana
--       Alta previa IFC 122576 (Mayfar MER-010, foto). Mismo $9.50 / pieza.
--
--   NO son duplicados (altas nuevas, sin match en catálogo):
--   · FC-IFC-1570818  magnesia calcinada C/50  ≠≠ FC-CB5C11ED magnesia anisada)
--   · FC-IFC-1490724  rosa de Castilla C/50
--   · FC-IFC-1330723  almidón cajita C/10
--   · FC-IFC-1660824  anís estrella C/25
--
--   Óxido de zinc FC-C4530823 (C/50) vs FC-0ACC5B6A (pomada) son presentaciones
--   distintas a propósito — no se tocan.
--
-- Candados: pobre activo y sin EAN (o sin EAN usable); bueno activo.
-- No suma stock si el bueno ya tiene piezas. Idempotente.
-- Supabase → SQL Editor → Run.

begin;

-- ── Vista previa: pares + altas nuevas del ticket ───────────────────────────
select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.costo,
  p.precio,
  p.presentacion,
  case
    when p.sku in ('FC-IFC-1400724', 'FC-578F060C') then 'dup_borax'
    when p.sku in ('FC-IFC-82943', 'FC-MER-MANZANA') then 'dup_manzana'
    when p.sku like 'FC-IFC-%' then 'alta_nueva_ticket'
    else 'otro'
  end as rol
from public.productos p
where p.sku in (
  'FC-578F060C', 'FC-IFC-1400724',
  'FC-MER-MANZANA', 'FC-IFC-82943',
  'FC-IFC-1570818', 'FC-IFC-1490724',
  'FC-IFC-1330723', 'FC-IFC-1660824'
)
order by rol, p.sku;

create temporary table _fc_mer_dup (
  sku_pobre text primary key,
  sku_bueno text not null,
  ean_bueno text,           -- null si el bueno tampoco tiene EAN
  nombre_bueno text not null,
  presentacion text,
  forma text,
  principio text,
  costo_piso numeric,
  precio_piso numeric
) on commit drop;

insert into _fc_mer_dup (
  sku_pobre, sku_bueno, ean_bueno, nombre_bueno,
  presentacion, forma, principio, costo_piso, precio_piso
) values
  (
    'FC-IFC-1400724', 'FC-578F060C', '3311000003739',
    'Mercurio bórax polvo', 'C/50', 'Polvo', 'Bórax', 53, 85
  ),
  (
    'FC-IFC-82943', 'FC-MER-MANZANA', null,
    'Mercurio pomada manzana', '50 g', 'Pomada', null, 9.50, 16
  );

-- Estado de cada par
select
  d.sku_pobre,
  p.nombre as pobre_nombre,
  p.activo as pobre_activo,
  p.stock as pobre_stock,
  p.codigo_barras as pobre_ean,
  d.sku_bueno,
  b.nombre as bueno_nombre,
  b.activo as bueno_activo,
  b.stock as bueno_stock,
  b.codigo_barras as bueno_ean,
  case
    when p.id is null then 'pobre_ya_no_existe'
    when p.activo is not true then 'pobre_ya_inactivo'
    when b.id is null then 'bueno_no_existe'
    when b.activo is not true then 'bueno_inactivo'
    when d.ean_bueno is not null
         and regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
             <> regexp_replace(d.ean_bueno, '\D', '', 'g')
         and nullif(btrim(b.codigo_barras), '') is not null
      then 'ean_del_bueno_no_cuadra'
    else 'listo_para_desactivar'
  end as estado
from _fc_mer_dup d
left join public.productos p on p.sku = d.sku_pobre
left join public.productos b on b.sku = d.sku_bueno
order by d.sku_pobre;

-- ── Canonical: ficha limpia ─────────────────────────────────────────────────
update public.productos b
   set
     nombre = d.nombre_bueno,
     marca = 'Mercurio',
     presentacion = coalesce(nullif(btrim(b.presentacion), ''), d.presentacion),
     forma_farmaceutica = coalesce(nullif(btrim(b.forma_farmaceutica), ''), d.forma),
     principio_activo = case
       when d.principio is null then b.principio_activo
       else coalesce(nullif(btrim(b.principio_activo), ''), d.principio)
     end,
     codigo_barras = case
       when d.ean_bueno is null then b.codigo_barras
       else coalesce(nullif(btrim(b.codigo_barras), ''), d.ean_bueno)
     end,
     costo = case
       when coalesce(b.costo, 0) <= 0 then d.costo_piso
       else b.costo
     end,
     precio = case
       when coalesce(b.precio, 0) <= 0 then d.precio_piso
       else b.precio
     end,
     activo = true,
     -- bórax: venta suelta C/50
     venta_unidad = case when d.sku_bueno = 'FC-578F060C' then true else b.venta_unidad end,
     unidades_por_caja = case
       when d.sku_bueno = 'FC-578F060C' then 50
       else b.unidades_por_caja
     end,
     precio_unidad = case
       when d.sku_bueno = 'FC-578F060C'
         then case when coalesce(b.precio_unidad, 0) <= 0 then 7 else b.precio_unidad end
       else b.precio_unidad
     end,
     -- manzana: hereda foto del bueno si el pobre tenía URL y el bueno no
     imagen_url = coalesce(
       nullif(btrim(b.imagen_url), ''),
       (
         select nullif(btrim(p.imagen_url), '')
         from public.productos p
         where p.sku = d.sku_pobre
         limit 1
       )
     )
  from _fc_mer_dup d
 where b.sku = d.sku_bueno
   and b.activo is not false;

-- ── Relink recepción (cualquier folio) pobre → bueno ────────────────────────
update public.recepcion_items i
   set
     producto_id = b.id,
     codigo_escaneado = coalesce(
       nullif(btrim(i.codigo_escaneado), ''),
       nullif(btrim(b.codigo_barras), ''),
       d.ean_bueno
     ),
     pendiente_alta = false,
     nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''), b.nombre)
  from public.productos p
  join _fc_mer_dup d on d.sku_pobre = p.sku
  join public.productos b on b.sku = d.sku_bueno
 where i.producto_id = p.id
   and b.activo = true
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '');

-- Relink por snapshot en IFC 125445 (si producto_id quedó raro)
update public.recepcion_items i
   set
     producto_id = b.id,
     codigo_escaneado = coalesce(
       nullif(btrim(i.codigo_escaneado), ''),
       nullif(btrim(b.codigo_barras), ''),
       d.ean_bueno
     ),
     pendiente_alta = false
  from public.recepciones r
  join _fc_mer_dup d on true
  join public.productos b on b.sku = d.sku_bueno
 where i.recepcion_id = r.id
   and r.folio = '125445'
   and coalesce(r.proveedor, '') ilike '%ifc%'
   and i.producto_id is distinct from b.id
   and (
     (d.sku_pobre = 'FC-IFC-1400724'
       and (i.nombre_snapshot ilike '%borax%' or i.nombre_snapshot ilike '%bórax%'))
     or (d.sku_pobre = 'FC-IFC-82943'
       and i.nombre_snapshot ilike '%manzana%')
   );

-- ── Pasar stock solo si bueno en 0 ──────────────────────────────────────────
update public.productos b
   set stock = coalesce(b.stock, 0) + coalesce(p.stock, 0)
  from _fc_mer_dup d
  join public.productos p on p.sku = d.sku_pobre
 where b.sku = d.sku_bueno
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and b.activo = true
   and coalesce(b.stock, 0) = 0
   and coalesce(p.stock, 0) > 0;

-- Apagar lotes del pobre
update public.lotes l
   set activo = false
  from public.productos p
  join _fc_mer_dup d on d.sku_pobre = p.sku
 where l.producto_id = p.id
   and coalesce(l.activo, true)
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '');

-- Desactivar pobres
update public.productos p
   set activo = false,
       stock = 0,
       stock_unidades = 0
  from _fc_mer_dup d
  join public.productos b on b.sku = d.sku_bueno
 where p.sku = d.sku_pobre
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and b.activo = true
   and (
     d.ean_bueno is null
     or regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g')
        = regexp_replace(d.ean_bueno, '\D', '', 'g')
     or nullif(btrim(b.codigo_barras), '') is null
   );

commit;

-- ── Verificación ────────────────────────────────────────────────────────────
select
  p.sku,
  left(p.nombre, 48) as nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.costo,
  p.precio,
  p.venta_unidad,
  p.precio_unidad,
  p.presentacion
from public.productos p
where p.sku in (
  'FC-578F060C', 'FC-IFC-1400724',
  'FC-MER-MANZANA', 'FC-IFC-82943',
  'FC-IFC-1570818', 'FC-IFC-1490724',
  'FC-IFC-1330723', 'FC-IFC-1660824'
)
order by p.sku;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  p.sku,
  i.cantidad,
  i.pendiente_alta
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '125445'
  and coalesce(r.proveedor, '') ilike '%ifc%'
  and (
    i.nombre_snapshot ilike '%borax%'
    or i.nombre_snapshot ilike '%bórax%'
    or i.nombre_snapshot ilike '%manzana%'
    or p.sku in ('FC-578F060C', 'FC-IFC-1400724', 'FC-MER-MANZANA', 'FC-IFC-82943')
  )
order by i.id;
