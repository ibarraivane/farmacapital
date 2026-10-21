-- ============================================================================
-- Alta mostrador: Timolol OPKO · Dexal Maver · Dexlansoprazol Avivia
--
-- Fotos de caja (2026-10-21):
--   1) Timolol OPKO 5.0 mg/mL frasco gotero 5 mL — código en caja 75049812
--      (mayoreo Dilopsan / recipe también listan 0000075049812).
--      Dos cajas idénticas; si la pistola lee un dígito distinto, alias abajo.
--   2) Dexal (Ceftibuteno) Maver 400 mg C/5 — EAN 7502009746352
--   3) Dexlansoprazol Avivia 60 mg C/7 LR — EAN 7503049078281
--      (NO es Timolol: mismo prefijo OPKO/Avivia 7503049…, otro SKU)
--
-- Costos ancla mayoreo (DISA): Timolol $31.02 · Dexal $220.70
--   Timolol genérico +60% → PVP $50 · Dexal marca +25% → PVP $276
--   Dexlansoprazol: sin costo de compra; ancla Vitau $114
-- Stock 0 hasta Recibir. Sin inventar lote ni caducidad.
--
-- Fotos: public/catalogo-propia/
--   timolol-opko-5mg-ml-5ml-75049812.jpg
--   dexal-ceftibuteno-400mg-c5-7502009746352.jpg
--   dexlansoprazol-avivia-60mg-c7-7503049078281.jpg
-- ORDEN: 1) merge/deploy  2) pegar TODO este SQL en Supabase → Run.
-- ============================================================================

begin;

-- Match pistola: Timolol Exakta corto ↔ GTIN con ceros (Dilopsan / recipe).
create or replace function public.fc_match_codigo_barras(p_scan text, p_stored text)
returns boolean
language sql
immutable
parallel safe
as $$
  with n as (
    select
      regexp_replace(coalesce(p_scan, ''), '\D', '', 'g') as scan,
      regexp_replace(coalesce(p_stored, ''), '\D', '', 'g') as stored
  )
  select
    case
      when n.scan = '' or n.stored = '' then false
      when n.scan = n.stored then true
      when length(n.scan) >= 12 and length(n.stored) >= 12
        and right(n.scan, 12) = right(n.stored, 12) then true
      when length(n.scan) = 12 and length(n.stored) = 13
        and n.stored = '0' || n.scan then true
      when length(n.stored) = 12 and length(n.scan) = 13
        and n.scan = '0' || n.stored then true
      when length(n.scan) >= 8 and length(n.stored) = length(n.scan) + 1
        and n.stored like n.scan || '_' then true
      when length(n.stored) >= 8 and length(n.scan) = length(n.stored) + 1
        and n.scan like n.stored || '_' then true
      when length(n.scan) = 13 and length(n.stored) = 12
        and n.scan like '6502400%' and n.stored like '650240%'
        and substring(n.scan from 8) = substring(n.stored from 7) then true
      when length(n.stored) = 13 and length(n.scan) = 12
        and n.stored like '6502400%' and n.scan like '650240%'
        and substring(n.stored from 8) = substring(n.scan from 7) then true
      when n.scan in ('7501868900233', '7501868990023')
       and n.stored in ('7501868900233', '7501868990023') then true
      when n.scan in ('747589705123', '714706903205')
       and n.stored in ('747589705123', '714706903205') then true
      when n.scan in ('650240079009', '6502400079009', '6502400070009')
       and n.stored in ('650240079009', '6502400079009', '6502400070009') then true
      when n.scan in ('650240078996', '6502400078996')
       and n.stored in ('650240078996', '6502400078996') then true
      when n.scan in ('7509546695570', '7509546695587')
       and n.stored in ('7509546695570', '7509546695587') then true
      -- Timolol OPKO/Exakta 5 mg/mL 5 mL: caja 75049812 ↔ GTIN 0000075049812
      when n.scan in ('75049812', '0000075049812', '075049812')
       and n.stored in ('75049812', '0000075049812', '075049812') then true
      else false
    end
  from n;
$$;

grant execute on function public.fc_match_codigo_barras(text, text) to anon, authenticated, service_role;

-- ── Timolol OPKO ───────────────────────────────────────────────────────────
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  laboratorio, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Timolol 5 mg/mL',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-75049812'
        and coalesce(p.codigo_barras, '') not in ('75049812', '0000075049812', '075049812')
    ) then 'FC-ND-75049812'
    else 'FC-75049812'
  end,
  '75049812',
  'Medicamentos',
  'Oftalmología',
  'generico',
  'Alta mostrador · OPKO/Exakta Timolol solución oftálmica 5.0 mg/mL frasco gotero 5 mL · EAN caja 75049812 · alias GTIN 0000075049812 · costo DISA $31.02 · PVP $50 (+60%) · receta',
  'OPKO',
  'Frasco gotero con 5 mL',
  'Timolol',
  '5.0 mg/mL',
  'Solución oftálmica',
  'OPKO / Pharmacos Exakta',
  31.02,
  50,
  'https://www.farmacapital.mx/catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg',
  'https://www.farmacapital.mx/catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg',
  0,
  1,
  true,
  true,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('75049812') is null
  and public.fc_buscar_producto_escaneo('0000075049812') is null
  and public.fc_buscar_producto_escaneo('FC-75049812') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('75049812', '0000075049812', '075049812')
       or p.sku in ('FC-75049812', 'FC-ND-75049812')
  );

update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Timolol 5 mg/mL'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'OPKO'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Frasco gotero con 5 mL'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Timolol'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '5.0 mg/mL'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Solución oftálmica'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Oftalmología'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'generico'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'OPKO / Pharmacos Exakta'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '75049812'),
  costo = case when coalesce(p.costo, 0) <= 0.01 then 31.02 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 50 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg'
  ),
  descripcion = case
    when p.descripcion ilike '%75049812%' then p.descripcion
    when coalesce(btrim(p.descripcion), '') = '' then
      'Alta mostrador · OPKO/Exakta Timolol 5.0 mg/mL 5 mL · EAN caja 75049812 · alias GTIN 0000075049812'
    else btrim(p.descripcion) || ' · EAN caja 75049812 · alias GTIN 0000075049812'
  end
where p.codigo_barras in ('75049812', '0000075049812', '075049812')
   or p.sku in ('FC-75049812', 'FC-ND-75049812');

-- ── Dexal (Ceftibuteno) Maver ───────────────────────────────────────────────
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  laboratorio, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Dexal 400 mg',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-09746352'
        and coalesce(p.codigo_barras, '') <> '7502009746352'
    ) then 'FC-ND-09746352'
    else 'FC-09746352'
  end,
  '7502009746352',
  'Medicamentos',
  'Antibióticos',
  'marca',
  'Alta mostrador · Maver Dexal ceftibuteno 400 mg C/5 cápsulas · EAN 7502009746352 · costo DISA $220.70 · PVP $276 (+25%) · receta',
  'Maver',
  'Caja con 5 cápsulas',
  'Ceftibuteno',
  '400 mg',
  'Cápsula',
  'Productos Maver',
  220.70,
  276,
  'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg',
  'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg',
  0,
  1,
  true,
  true,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7502009746352') is null
  and public.fc_buscar_producto_escaneo('FC-09746352') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7502009746352'
       or p.sku in ('FC-09746352', 'FC-ND-09746352')
  );

update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Dexal 400 mg'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Maver'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 5 cápsulas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Ceftibuteno'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '400 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Cápsula'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Antibióticos'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'marca'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Productos Maver'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7502009746352'),
  costo = case when coalesce(p.costo, 0) <= 0.01 then 220.70 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 276 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg'
  )
where p.codigo_barras = '7502009746352'
   or p.sku in ('FC-09746352', 'FC-ND-09746352');

-- ── Dexlansoprazol Avivia 60 mg C/7 ─────────────────────────────────────────
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, principio_activo, concentracion, forma_farmaceutica,
  laboratorio, costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta,
  disponible, visible_tienda
)
select
  'Dexlansoprazol 60 mg',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-49078281'
        and coalesce(p.codigo_barras, '') <> '7503049078281'
    ) then 'FC-ND-49078281'
    else 'FC-49078281'
  end,
  '7503049078281',
  'Medicamentos',
  'Gastroenterología',
  'generico',
  'Alta mostrador · Avivia Dexlansoprazol 60 mg liberación retardada C/7 cápsulas · EAN 7503049078281 · ancla Vitau $114 · sin costo de compra · receta · no confundir con Timolol OPKO 75049812',
  'Avivia',
  'Caja con 7 cápsulas',
  'Dexlansoprazol',
  '60 mg',
  'Cápsula',
  'Avivia Pharma',
  null,
  114,
  'https://www.farmacapital.mx/catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg',
  'https://www.farmacapital.mx/catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg',
  0,
  1,
  true,
  true,
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7503049078281') is null
  and public.fc_buscar_producto_escaneo('FC-49078281') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7503049078281'
       or p.sku in ('FC-49078281', 'FC-ND-49078281')
  );

update public.productos p
set
  nombre = coalesce(nullif(btrim(p.nombre), ''), 'Dexlansoprazol 60 mg'),
  marca = coalesce(nullif(btrim(p.marca), ''), 'Avivia'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 7 cápsulas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Dexlansoprazol'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '60 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Cápsula'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Gastroenterología'),
  tipo = coalesce(nullif(btrim(p.tipo), ''), 'generico'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Avivia Pharma'),
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7503049078281'),
  precio = case when coalesce(p.precio, 0) <= 1 then 114 else p.precio end,
  requiere_receta = true,
  activo = true,
  visible_tienda = true,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  imagen_url = coalesce(
    nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg'
  ),
  imagen_mobile_url = coalesce(
    nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg'
  )
where p.codigo_barras = '7503049078281'
   or p.sku in ('FC-49078281', 'FC-ND-49078281');

-- Galería (idempotente)
insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  u.url,
  u.storage_path,
  0,
  true,
  'propia'
from (
  values
    ('75049812', 'https://www.farmacapital.mx/catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg',
     'catalogo-propia/timolol-opko-5mg-ml-5ml-75049812.jpg'),
    ('7502009746352', 'https://www.farmacapital.mx/catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg',
     'catalogo-propia/dexal-ceftibuteno-400mg-c5-7502009746352.jpg'),
    ('7503049078281', 'https://www.farmacapital.mx/catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg',
     'catalogo-propia/dexlansoprazol-avivia-60mg-c7-7503049078281.jpg')
) as u(ean, url, storage_path)
join public.productos p
  on p.codigo_barras = u.ean
  or (u.ean = '75049812' and p.sku in ('FC-75049812', 'FC-ND-75049812'))
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id
    and i.storage_path = u.storage_path
);

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.principio_activo,
  p.concentracion,
  p.presentacion,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras in ('75049812', '0000075049812', '7502009746352', '7503049078281')
   or p.sku in (
     'FC-75049812', 'FC-ND-75049812',
     'FC-09746352', 'FC-ND-09746352',
     'FC-49078281', 'FC-ND-49078281'
   )
order by p.sku;
