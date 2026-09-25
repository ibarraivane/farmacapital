-- Mercurio bórax polvo C/50: unificar duplicado IFC sin EAN → ficha con barcode.
--
-- Qué pasó (24-sep-2026, ticket IFC 125445):
--   · Ya existía FC-578F060C con EAN 3311000003739 (foto lote 5721 / pistola).
--   · Un ticket IFC anterior (118216) ya lo matcheó por nombre a FC-578F060C.
--   · La carga del 125445 llegó SIN EAN (código interno 1400724) y el generador
--     inventó FC-IFC-1400724 en vez de reusar FC-578F060C → dos fichas en Catálogo.
--
-- Qué hace este patch:
--   1) Relinka recepcion_items del pobre → bueno y pone el EAN real.
--   2) Activa venta suelta (C/50 sobres) en el SKU bueno: precio_unidad $7
--      (regla calcPrecioUnidad: max(porCosto≈2, porUtil=+5→7, penalty caja≈2)).
--   3) Desactiva FC-IFC-1400724 (stock 0, lotes apagados).
--      Pasa stock SOLO si el bueno tiene 0 y el pobre > 0 (no doble conteo).
--
-- Idempotente. Supabase → SQL Editor → Run.

begin;

-- ── Vista previa ────────────────────────────────────────────────────────────
select
  p.sku,
  p.nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  coalesce(p.stock_unidades, 0) as stock_unidades,
  p.costo,
  p.precio,
  p.venta_unidad,
  p.precio_unidad,
  p.unidades_por_caja,
  p.presentacion,
  p.principio_activo
from public.productos p
where p.sku in ('FC-578F060C', 'FC-IFC-1400724')
order by p.sku;

-- ── Canonical: ficha limpia + venta suelta ──────────────────────────────────
update public.productos
   set
     nombre = 'Mercurio bórax polvo',
     marca = 'Mercurio',
     presentacion = 'C/50',
     principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Bórax'),
     forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Polvo'),
     codigo_barras = coalesce(nullif(btrim(codigo_barras), ''), '3311000003739'),
     costo = case when coalesce(costo, 0) <= 0 then 53 else costo end,
     precio = case
       when coalesce(precio, 0) <= 0 then 85
       when precio < 60 then 85
       else precio
     end,
     venta_unidad = true,
     unidades_por_caja = 50,
     precio_unidad = 7,
     activo = true
 where sku = 'FC-578F060C'
   and (
     codigo_barras is null
     or btrim(codigo_barras) = ''
     or regexp_replace(codigo_barras, '\D', '', 'g') = '3311000003739'
   );

-- ── Relink recepción IFC 125445 (y cualquier otra que apunte al pobre) ───────
update public.recepcion_items i
   set
     producto_id = b.id,
     codigo_escaneado = coalesce(
       nullif(btrim(i.codigo_escaneado), ''),
       nullif(btrim(b.codigo_barras), ''),
       '3311000003739'
     ),
     pendiente_alta = false,
     nombre_snapshot = coalesce(nullif(btrim(i.nombre_snapshot), ''), b.nombre)
  from public.productos p
  join public.productos b on b.sku = 'FC-578F060C'
 where i.producto_id = p.id
   and p.sku = 'FC-IFC-1400724'
   and b.activo = true;

-- Renglón 125445 por snapshot (si producto_id quedó null / otro).
update public.recepcion_items i
   set
     producto_id = b.id,
     codigo_escaneado = coalesce(
       nullif(btrim(i.codigo_escaneado), ''),
       '3311000003739'
     ),
     pendiente_alta = false
  from public.recepciones r
  join public.productos b on b.sku = 'FC-578F060C'
 where i.recepcion_id = r.id
   and r.folio = '125445'
   and coalesce(r.proveedor, '') ilike '%ifc%'
   and i.producto_id is distinct from b.id
   and (
     i.nombre_snapshot ilike '%borax%'
     or i.nombre_snapshot ilike '%bórax%'
   );

-- ── Pasar stock solo si el bueno está en 0 (evita doble conteo del mismo lote) ─
update public.productos b
   set stock = coalesce(b.stock, 0) + coalesce(p.stock, 0)
  from public.productos p
 where p.sku = 'FC-IFC-1400724'
   and b.sku = 'FC-578F060C'
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and b.activo = true
   and coalesce(b.stock, 0) = 0
   and coalesce(p.stock, 0) > 0;

-- Apagar lotes del pobre (mismo lote no se suma dos veces si bueno ya tenía stock).
update public.lotes l
   set activo = false
  from public.productos p
 where l.producto_id = p.id
   and p.sku = 'FC-IFC-1400724'
   and coalesce(l.activo, true);

-- Desactivar ficha pobre.
update public.productos p
   set activo = false,
       stock = 0,
       stock_unidades = 0
 where p.sku = 'FC-IFC-1400724'
   and p.activo = true
   and (p.codigo_barras is null or btrim(p.codigo_barras) = '')
   and exists (
     select 1 from public.productos b
     where b.sku = 'FC-578F060C'
       and b.activo = true
       and regexp_replace(coalesce(b.codigo_barras, ''), '\D', '', 'g') = '3311000003739'
   );

commit;

-- ── Verificación ────────────────────────────────────────────────────────────
select
  p.sku,
  p.nombre,
  p.codigo_barras as ean,
  p.activo,
  p.stock,
  p.costo,
  p.precio,
  p.venta_unidad,
  p.precio_unidad,
  p.unidades_por_caja,
  p.presentacion,
  p.principio_activo
from public.productos p
where p.sku in ('FC-578F060C', 'FC-IFC-1400724')
order by p.sku;

select
  r.folio,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 48) as snap,
  p.sku,
  i.cantidad,
  i.pendiente_alta,
  i.confirmado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '125445'
  and coalesce(r.proveedor, '') ilike '%ifc%'
  and (
    i.nombre_snapshot ilike '%borax%'
    or i.nombre_snapshot ilike '%bórax%'
    or p.sku in ('FC-578F060C', 'FC-IFC-1400724')
  );
