-- ============================================================================
-- FARMA CAPITAL — Alta Costco 07-nov-2026
--
-- 1) Bicarbonato Just About Foods 6.1 kg
--    Costco #694121 · sin EAN legible · SKU FC-00694121 · costo $259 → PVP $324
--
-- 2) Raid Casa y Jardín eucalipto 3×430 ml
--    EAN 7503046433663 · SKU FC-04643366 · costo $289 → PVP $362
--
-- 3) Raid MAX eucalipto 3×430 ml
--    EAN 7501032914233 · SKU FC-03291423 · costo $329 → PVP $412
--
-- 4) Lysol desinfectante Crisp Linen 3×475 g
--    EAN 7501058784278 · SKU FC-05878427 · costo $519 → PVP $649
--
-- Marca → recargo +25% sobre costo (ceil). Stock 0 hasta ajuste en Inventario
-- (1 paquete físico de cada uno). Caducidad null.
--
-- NO confundir:
--   Lysol lata 475 g 7501058752796 (FC-58752796)
--   Lysol 354 g 7501058796882 (FC-58796882)
--   Bicarbonato Velázquez 200 g FC-08DB70CB
--
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_costco_altas (
  ean text,
  sku text primary key,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  forma text not null,
  categoria text not null,
  subcategoria text not null,
  principio text,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  descripcion text not null
) on commit drop;

insert into _fc_costco_altas values
  (
    null,
    'FC-00694121',
    'Bicarbonato de sodio Just About Foods',
    'Just About Foods',
    'Bolsa 6.1 kg',
    'Polvo',
    'Higiene',
    'Limpieza',
    'Bicarbonato de sodio',
    259.00,
    324.00,
    'Alta Costco 2026-11-07 · item 694121 · bolsa 6.1 kg (13.5 lb) grado USP · sin EAN en empaque · costo 259 · PVP 324 (+25% marca)'
  ),
  (
    '7503046433663',
    'FC-04643366',
    'Raid Casa y Jardín eucalipto',
    'Raid',
    '3×430 ml',
    'Aerosol',
    'Higiene',
    'Insecticida',
    null,
    289.00,
    362.00,
    'Alta Costco 2026-11-07 · EAN pack 7503046433663 · RAID C&J EUC 1290ML · 3×430 ml eucalipto base agua · costo 289 · PVP 362 (+25% marca)'
  ),
  (
    '7501032914233',
    'FC-03291423',
    'Raid MAX eucalipto',
    'Raid',
    '3×430 ml',
    'Aerosol',
    'Higiene',
    'Insecticida',
    null,
    329.00,
    412.00,
    'Alta Costco 2026-11-07 · EAN pack 7501032914233 · RAID MAX EUCA 3P 1290 ML · cucarachas/rastreros · costo 329 · PVP 412 (+25% marca)'
  ),
  (
    '7501058784278',
    'FC-05878427',
    'Lysol desinfectante antibacterial Crisp Linen',
    'Lysol',
    '3×475 g',
    'Aerosol',
    'Higiene',
    'Desinfectante',
    null,
    519.00,
    649.00,
    'Alta Costco 2026-11-07 · EAN pack 7501058784278 · LYSOL MX 3PK AER C LIN · no es la lata suelta 7501058752796 · costo 519 · PVP 649 (+25% marca)'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') is distinct from coalesce(t.ean, '')
    ) then 'FC-ND-' || right(t.sku, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  'marca',
  t.descripcion,
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio
from _fc_costco_altas t
where not exists (
  select 1 from public.productos p
  where p.sku = t.sku
     or (t.ean is not null and p.codigo_barras = t.ean)
     or (t.ean is not null and public.fc_buscar_producto_escaneo(t.ean) is not null)
);

-- Si ya existían: rellenar costo/precio vacíos y ficha hueca (no pisa PVP ya puesto).
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio),
  categoria = coalesce(nullif(trim(p.categoria), ''), t.categoria),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  tipo = coalesce(nullif(trim(p.tipo), ''), 'marca'),
  codigo_barras = case
    when t.ean is not null then coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
    else p.codigo_barras
  end,
  costo = coalesce(p.costo, t.costo),
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  descripcion = coalesce(nullif(trim(p.descripcion), ''), t.descripcion),
  activo = true
from _fc_costco_altas t
where p.sku = t.sku
   or (t.ean is not null and p.codigo_barras = t.ean)
   or p.sku = 'FC-ND-' || right(t.sku, 8);

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  p.categoria,
  p.subcategoria,
  p.activo
from public.productos p
where p.sku in (
    'FC-00694121', 'FC-04643366', 'FC-03291423', 'FC-05878427',
    'FC-ND-00694121', 'FC-ND-04643366', 'FC-ND-03291423', 'FC-ND-05878427',
    'FC-58752796', 'FC-58796882', 'FC-08DB70CB'
  )
   or p.codigo_barras in (
    '7503046433663', '7501032914233', '7501058784278',
    '7501058752796', '7501058796882'
  )
order by p.sku;
