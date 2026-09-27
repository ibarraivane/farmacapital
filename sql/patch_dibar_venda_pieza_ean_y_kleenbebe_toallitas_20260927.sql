-- ============================================================================
-- FARMA CAPITAL — 27-sep-2026
--
-- 1) Dibar venda elástica/deportiva colores
--    Alta mostrador (25-sep) usó EAN del PAQUETE C/24: 7501868950207
--    Foto de hoy (rollo suelto): EAN PIEZA 7501868902527
--    Mismo producto. Este patch enlaza el EAN de pieza en ficha +
--    (POS/Recibir) el par en eanParesConocidos.js.
--    No inventa stock ni cambia PVP pieza $20 / caja $398.
--
-- 2) KleenBebé Absorsec toallitas húmedas (foto mostrador, sin ticket)
--    Grandes 140 · EAN 7506425662388 · clave 96992 · PVP $30
--    Chicas  90 · EAN 7501943471337 · clave 96678 · PVP $22
--    Distinto de Absorsec C/120 (7501943471900 / FC-43471900).
--    Stock 0 hasta Recibir. Sin lote/caducidad inventados.
--
-- SIN do $$. Pegar TODO en Supabase → SQL Editor → Run.
-- Fotos: patch_fotos_kleenbebe_toallitas_20260927.sql tras deploy.
-- ============================================================================

begin;

-- ---------------------------------------------------------------------------
-- Dibar colores: EAN pieza ↔ paquete (solo el SKU de caja ya registrado)
-- ---------------------------------------------------------------------------
update public.productos p
set
  descripcion = case
    when coalesce(p.descripcion, '') ~ '7501868902527' then p.descripcion
    when coalesce(nullif(btrim(p.descripcion), ''), '') = '' then
      'Dibar · venda elástica/deportiva 7.5 cm colores surtido C/24 · media compresión · EAN paquete 7501868950207 · EAN pieza 7501868902527 · venta por pieza $20'
    else
      btrim(p.descripcion) || ' · EAN pieza 7501868902527'
  end,
  codigo_barras = coalesce(nullif(btrim(p.codigo_barras), ''), '7501868950207'),
  venta_unidad = coalesce(p.venta_unidad, true),
  unidades_por_caja = coalesce(p.unidades_por_caja, 24),
  precio_unidad = coalesce(nullif(p.precio_unidad, 0), 20),
  activo = true
where p.codigo_barras = '7501868950207'
   or p.sku in ('FC-IFC-83733', 'FC-68950207');

-- Si alguien dio de alta un renglón solo con el EAN del rollo: pásalo al de caja
-- (si el de caja ya existe) o conviértelo en el canónico con EAN de paquete.
update public.productos pieza
set codigo_barras = null,
    activo = false,
    descripcion = coalesce(nullif(btrim(pieza.descripcion), ''), '')
      || ' · fusionado a EAN paquete 7501868950207 (pieza 7501868902527)'
where pieza.codigo_barras = '7501868902527'
  and exists (
    select 1 from public.productos caja
    where caja.codigo_barras = '7501868950207'
       or caja.sku in ('FC-IFC-83733', 'FC-68950207')
  )
  and pieza.id not in (
    select caja.id from public.productos caja
    where caja.codigo_barras = '7501868950207'
       or caja.sku in ('FC-IFC-83733', 'FC-68950207')
  );

update public.productos p
set
  codigo_barras = '7501868950207',
  descripcion = case
    when coalesce(p.descripcion, '') ~ '7501868902527' then p.descripcion
    when coalesce(nullif(btrim(p.descripcion), ''), '') = '' then
      'Dibar · venda elástica/deportiva colores · EAN paquete 7501868950207 · EAN pieza 7501868902527 · venta por pieza $20'
    else
      btrim(p.descripcion) || ' · EAN pieza 7501868902527'
  end,
  venta_unidad = coalesce(p.venta_unidad, true),
  unidades_por_caja = coalesce(p.unidades_por_caja, 24),
  precio_unidad = coalesce(nullif(p.precio_unidad, 0), 20),
  activo = true
where p.codigo_barras = '7501868902527'
  and not exists (
    select 1 from public.productos caja
    where caja.codigo_barras = '7501868950207'
       or caja.sku in ('FC-IFC-83733', 'FC-68950207')
  );

-- ---------------------------------------------------------------------------
-- KleenBebé Absorsec 140 (grandes) · PVP $30
-- ---------------------------------------------------------------------------
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria,
  disponible, visible_tienda
)
select
  'KleenBebé Absorsec',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-25662388'
        and coalesce(p.codigo_barras, '') <> '7506425662388'
    ) then 'FC-ND-25662388'
    else 'FC-25662388'
  end,
  '7506425662388',
  'Bebés',
  'marca',
  'Alta foto mostrador 2026-09-27 · Kimberly-Clark · Absorsec 140 toallitas · EAN 7506425662388 · clave bolsa 96992 · PVP dueño 30 · sin costo de compra · listo para pistola',
  null,
  30.00,
  0,
  1,
  true,
  false,
  'KleenBebé',
  '140 toallitas',
  'Toallas húmedas',
  'Toallitas',
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7506425662388') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7506425662388'
  );

update public.productos p
set
  nombre = 'KleenBebé Absorsec',
  marca = coalesce(nullif(btrim(p.marca), ''), 'KleenBebé'),
  presentacion = '140 toallitas',
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Toallas húmedas'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Bebés'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Toallitas'),
  tipo = 'marca',
  precio = 30.00,
  activo = true,
  requiere_receta = false,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  visible_tienda = true,
  descripcion = coalesce(
    nullif(btrim(p.descripcion), ''),
    'Alta foto mostrador 2026-09-27 · Absorsec 140 · EAN 7506425662388 · clave 96992 · PVP 30'
  )
where p.codigo_barras = '7506425662388'
   or p.sku in ('FC-25662388', 'FC-ND-25662388');

-- ---------------------------------------------------------------------------
-- KleenBebé Absorsec 90 (chicas) · PVP $22
-- ---------------------------------------------------------------------------
insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria,
  disponible, visible_tienda
)
select
  'KleenBebé Absorsec',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-43471337'
        and coalesce(p.codigo_barras, '') <> '7501943471337'
    ) then 'FC-ND-43471337'
    else 'FC-43471337'
  end,
  '7501943471337',
  'Bebés',
  'marca',
  'Alta foto mostrador 2026-09-27 · Kimberly-Clark · Absorsec 90 toallitas · EAN 7501943471337 · clave bolsa 96678 · PVP dueño 22 · sin costo de compra · listo para pistola',
  null,
  22.00,
  0,
  1,
  true,
  false,
  'KleenBebé',
  '90 toallitas',
  'Toallas húmedas',
  'Toallitas',
  'inmediato',
  true
where public.fc_buscar_producto_escaneo('7501943471337') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7501943471337'
  );

update public.productos p
set
  nombre = 'KleenBebé Absorsec',
  marca = coalesce(nullif(btrim(p.marca), ''), 'KleenBebé'),
  presentacion = '90 toallitas',
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Toallas húmedas'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Bebés'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Toallitas'),
  tipo = 'marca',
  precio = 22.00,
  activo = true,
  requiere_receta = false,
  disponible = coalesce(nullif(btrim(p.disponible), ''), 'inmediato'),
  visible_tienda = true,
  descripcion = coalesce(
    nullif(btrim(p.descripcion), ''),
    'Alta foto mostrador 2026-09-27 · Absorsec 90 · EAN 7501943471337 · clave 96678 · PVP 22'
  )
where p.codigo_barras = '7501943471337'
   or p.sku in ('FC-43471337', 'FC-ND-43471337');

commit;

-- Diagnóstico
select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 40) as nombre,
  p.presentacion,
  p.precio,
  p.precio_unidad,
  p.venta_unidad,
  p.stock,
  case
    when p.descripcion ~ '7501868902527' then 'pieza_enlazada'
    when p.codigo_barras in ('7506425662388', '7501943471337') then 'toallita_ok'
    else 'revisar'
  end as estado
from public.productos p
where p.codigo_barras in (
    '7501868950207', '7501868902527',
    '7506425662388', '7501943471337',
    '7501943471900'
  )
   or p.sku in (
    'FC-IFC-83733', 'FC-68950207',
    'FC-25662388', 'FC-ND-25662388',
    'FC-43471337', 'FC-ND-43471337',
    'FC-43471900'
  )
order by p.presentacion, p.sku;
