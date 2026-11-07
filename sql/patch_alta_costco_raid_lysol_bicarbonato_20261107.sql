-- ============================================================================
-- FARMA CAPITAL — Alta Costco 07-nov-2026 (v2, sin temp table)
--
-- 1) Bicarbonato Just About Foods 6.1 kg
--    Costco #694121 · sin EAN · SKU FC-00694121 · costo 259 → PVP 324
-- 2) Raid Casa y Jardin eucalipto 3 x 430 ml
--    EAN 7503046433663 · SKU FC-04643366 · costo 289 → PVP 362
-- 3) Raid MAX eucalipto 3 x 430 ml
--    EAN 7501032914233 · SKU FC-03291423 · costo 329 → PVP 412
-- 4) Lysol Crisp Linen 3 x 475 g
--    EAN 7501058784278 · SKU FC-05878427 · costo 519 → PVP 649
--
-- Marca +25% (ceil). Stock 0. Caducidad null.
-- NO confundir Lysol lata 7501058752796 (FC-58752796).
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

-- 1) Bicarbonato 6.1 kg (sin EAN)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo
)
select
  'Bicarbonato de sodio Just About Foods',
  'FC-00694121',
  null,
  'Higiene',
  'Limpieza',
  'marca',
  'Alta Costco 2026-11-07 · item 694121 · bolsa 6.1 kg · costo 259 · PVP 324 (+25% marca)',
  259,
  324,
  0,
  1,
  true,
  false,
  'Just About Foods',
  'Bolsa 6.1 kg',
  'Polvo',
  'Bicarbonato de sodio'
where not exists (
  select 1 from public.productos p where p.sku = 'FC-00694121'
);

update public.productos
set
  nombre = 'Bicarbonato de sodio Just About Foods',
  marca = 'Just About Foods',
  presentacion = 'Bolsa 6.1 kg',
  forma_farmaceutica = 'Polvo',
  principio_activo = 'Bicarbonato de sodio',
  categoria = 'Higiene',
  subcategoria = 'Limpieza',
  tipo = 'marca',
  costo = coalesce(costo, 259),
  precio = case when coalesce(precio, 0) <= 0 then 324 else precio end,
  activo = true
where sku = 'FC-00694121';

-- 2) Raid Casa y Jardin 3-pack
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica
)
select
  'Raid Casa y Jardin eucalipto',
  'FC-04643366',
  '7503046433663',
  'Higiene',
  'Insecticida',
  'marca',
  'Alta Costco 2026-11-07 · EAN 7503046433663 · 3 x 430 ml · costo 289 · PVP 362',
  289,
  362,
  0,
  1,
  true,
  false,
  'Raid',
  '3 x 430 ml',
  'Aerosol'
where public.fc_buscar_producto_escaneo('7503046433663') is null
  and not exists (
    select 1 from public.productos p
    where p.sku = 'FC-04643366' or p.codigo_barras = '7503046433663'
  );

update public.productos
set
  codigo_barras = '7503046433663',
  nombre = 'Raid Casa y Jardin eucalipto',
  marca = 'Raid',
  presentacion = '3 x 430 ml',
  forma_farmaceutica = 'Aerosol',
  categoria = 'Higiene',
  subcategoria = 'Insecticida',
  tipo = 'marca',
  costo = coalesce(costo, 289),
  precio = case when coalesce(precio, 0) <= 0 then 362 else precio end,
  activo = true
where sku = 'FC-04643366'
   or codigo_barras = '7503046433663';

-- 3) Raid MAX 3-pack
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica
)
select
  'Raid MAX eucalipto',
  'FC-03291423',
  '7501032914233',
  'Higiene',
  'Insecticida',
  'marca',
  'Alta Costco 2026-11-07 · EAN 7501032914233 · 3 x 430 ml · costo 329 · PVP 412',
  329,
  412,
  0,
  1,
  true,
  false,
  'Raid',
  '3 x 430 ml',
  'Aerosol'
where public.fc_buscar_producto_escaneo('7501032914233') is null
  and not exists (
    select 1 from public.productos p
    where p.sku = 'FC-03291423' or p.codigo_barras = '7501032914233'
  );

update public.productos
set
  codigo_barras = '7501032914233',
  nombre = 'Raid MAX eucalipto',
  marca = 'Raid',
  presentacion = '3 x 430 ml',
  forma_farmaceutica = 'Aerosol',
  categoria = 'Higiene',
  subcategoria = 'Insecticida',
  tipo = 'marca',
  costo = coalesce(costo, 329),
  precio = case when coalesce(precio, 0) <= 0 then 412 else precio end,
  activo = true
where sku = 'FC-03291423'
   or codigo_barras = '7501032914233';

-- 4) Lysol 3-pack (NO es la lata suelta 7501058752796)
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica
)
select
  'Lysol desinfectante antibacterial Crisp Linen',
  'FC-05878427',
  '7501058784278',
  'Higiene',
  'Desinfectante',
  'marca',
  'Alta Costco 2026-11-07 · EAN pack 7501058784278 · 3 x 475 g · no es lata 7501058752796 · costo 519 · PVP 649',
  519,
  649,
  0,
  1,
  true,
  false,
  'Lysol',
  '3 x 475 g',
  'Aerosol'
where public.fc_buscar_producto_escaneo('7501058784278') is null
  and not exists (
    select 1 from public.productos p
    where p.sku = 'FC-05878427' or p.codigo_barras = '7501058784278'
  );

update public.productos
set
  codigo_barras = '7501058784278',
  nombre = 'Lysol desinfectante antibacterial Crisp Linen',
  marca = 'Lysol',
  presentacion = '3 x 475 g',
  forma_farmaceutica = 'Aerosol',
  categoria = 'Higiene',
  subcategoria = 'Desinfectante',
  tipo = 'marca',
  costo = coalesce(costo, 519),
  precio = case when coalesce(precio, 0) <= 0 then 649 else precio end,
  activo = true
where sku = 'FC-05878427'
   or codigo_barras = '7501058784278';

commit;

select
  id,
  sku,
  codigo_barras as ean,
  nombre,
  marca,
  presentacion,
  costo,
  precio,
  stock,
  activo
from public.productos
where sku in (
    'FC-00694121', 'FC-04643366', 'FC-03291423', 'FC-05878427',
    'FC-58752796'
  )
   or codigo_barras in (
    '7503046433663', '7501032914233', '7501058784278', '7501058752796'
  )
order by sku;
