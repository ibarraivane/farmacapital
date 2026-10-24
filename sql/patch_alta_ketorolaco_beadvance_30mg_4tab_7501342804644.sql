-- ============================================================================
-- FARMA CAPITAL — Alta foto mostrador: Ketorolaco beadvance 30 mg C/4
--
-- EAN: 7501342804644
-- Caja: beadvance Ketorolaco tableta 30 mg · sublingual · Caja con 4 tabletas
-- Reg. No. 299M2005 SSA IV
-- Fabricante: Laboratorios PiSA, S.A. de C.V.
-- Distribuido por: Antibióticos de México, S.A. de C.V.
-- Clave Levic/FarmaSmart: BEA433 (referencia; SKU FarmaCapital FC-42804644)
--
-- Por qué no estaba: nunca se dio de alta. El parecido en catálogo es
-- EQ-AMS160 (Ketorolaco AMSA sublingual 30 mg C/6, EAN 7501349023369) —
-- otra marca y otra presentación.
--
-- Sin costo de compra (foto de caja, no ticket). PVP ancla FarmaSmart $13.50
-- → $14. Stock 0 hasta Recibir. No inventar lote ni caducidad.
--
-- INSERT ONLY. SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Foto: public/catalogo-propia/ketorolaco-beadvance-30mg-4tab-sublingual.jpg
--   → tras deploy: sql/patch_fotos_ketorolaco_beadvance_30mg_4tab_20261004.sql
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, laboratorio, presentacion, principio_activo, concentracion,
  forma_farmaceutica, costo, precio, stock, stock_minimo, activo, requiere_receta
)
select
  'Ketorolaco sublingual 30 mg',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-42804644'
        and coalesce(p.codigo_barras, '') <> '7501342804644'
    ) then 'FC-ND-42804644'
    else 'FC-42804644'
  end,
  '7501342804644',
  'Medicamentos',
  'Dolor',
  'generico',
  'Alta foto mostrador 2026-10-04 · beadvance Ketorolaco 30 mg C/4 sublingual · EAN 7501342804644 · Reg. 299M2005 SSA IV · clave BEA433 · PVP ancla FarmaSmart 13.50 → 14 · sin costo de compra · stock 0 hasta Recibir',
  'beadvance',
  'Laboratorios PiSA',
  'Caja con 4 tabletas',
  'Ketorolaco trometamina',
  '30 mg',
  'Tableta sublingual',
  null,
  14,
  0,
  1,
  true,
  true
where public.fc_buscar_producto_escaneo('7501342804644') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501342804644'
       or p.sku in ('FC-42804644', 'FC-ND-42804644', 'EQ-BEA433')
  );

-- Si ya existía por EAN/SKU: completar ficha hueca sin pisar costo/PVP buenos.
update public.productos p
set
  nombre = 'Ketorolaco sublingual 30 mg',
  marca = coalesce(nullif(btrim(p.marca), ''), 'beadvance'),
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'Laboratorios PiSA'),
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), 'Caja con 4 tabletas'),
  principio_activo = coalesce(nullif(btrim(p.principio_activo), ''), 'Ketorolaco trometamina'),
  concentracion = coalesce(nullif(btrim(p.concentracion), ''), '30 mg'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Tableta sublingual'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Medicamentos'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Dolor'),
  tipo = 'generico',
  codigo_barras = '7501342804644',
  precio = case when coalesce(p.precio, 0) <= 0 then 14 else p.precio end,
  activo = true,
  requiere_receta = true,
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'Alta foto mostrador 2026-10-04 · BEA433 · Reg. 299M2005 SSA IV'
  ))
where p.codigo_barras = '7501342804644'
   or p.sku in ('FC-42804644', 'FC-ND-42804644', 'EQ-BEA433');

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.principio_activo,
  p.concentracion,
  p.forma_farmaceutica,
  p.categoria,
  p.subcategoria,
  p.tipo,
  p.costo,
  p.precio,
  p.stock,
  p.requiere_receta,
  p.activo,
  left(coalesce(p.imagen_url, ''), 88) as foto
from public.productos p
where p.codigo_barras = '7501342804644'
   or p.sku in ('FC-42804644', 'FC-ND-42804644', 'EQ-BEA433');
