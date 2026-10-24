-- ============================================================================
-- FARMACAPITAL — Bodega F-42 folio 84416 · EANs pistola (02-oct-2026)
--
-- El ticket YA está en Recibir (no volver a pegar patch_carga_bodega_f42_84416).
-- Faltaban 2 códigos para poder escanear y cerrar:
--
-- 1) Ítem 46 · Jabón Ricitos de Oro Bio-Pure 90 g
--    Ticket: sin EAN (cortado entre fotos) · SKU FC-F42-JBNGRISIRICITOSO
--    Caja / pistola: UPC-A 037836050725 (0 37836 05072 5)
--    Costo ticket $22.325 · PVP sugerido $28 (marca +25%)
--    Distinto del Neutro 7501022150221 y del shampoo Bio-Pure 250 ml.
--
-- 2) Ítem 31 · Colgate Total Prevención Activa Encías Saludables 250 ml
--    Ticket OCR: 7509546666959 (check digit INVÁLIDO; no usar 6952)
--    Caja / DelSol / Fahorro / Locatel: 7509546666969 (OK)
--    Costo ticket $57.79 · PVP sugerido $73
--
-- Fotos (después del deploy de Vercel):
--   catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg
--   catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg
--
-- ORDEN: 1) merge/deploy  2) pegar TODO este SQL en Supabase → Run.
-- SIN do $$. No inventa stock, lote ni caducidad.
-- ============================================================================

begin;

-- ===========================================================================
-- 1) Ricitos de Oro Bio-Pure jabón 90 g
-- ===========================================================================

-- Si el alta F-42 ya creó el producto sin barras → poner EAN + ficha.
update public.productos p
set
  codigo_barras = '037836050725',
  sku = case
    when p.sku in ('FC-F42-JBNGRISIRICITOSO', 'FC-36050725', 'FC-ND-36050725')
      then case
        when exists (
          select 1 from public.productos x
          where x.sku = 'FC-36050725'
            and x.id <> p.id
            and coalesce(x.codigo_barras, '') <> '037836050725'
        ) then 'FC-ND-36050725'
        else 'FC-36050725'
      end
    else p.sku
  end,
  nombre = 'Ricitos de Oro Bio-Pure',
  marca = 'Ricitos de Oro',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '90 g'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Jabón'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Bebés'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Higiene bebé'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'GRISI'),
  costo = case when coalesce(p.costo, 0) <= 0.01 then 22.325 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 28 else p.precio end,
  activo = true,
  requiere_receta = false,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'F-42 84416 · EAN caja 037836050725 · jabón Bio-Pure 90 g'
  ))
where p.sku = 'FC-F42-JBNGRISIRICITOSO'
   or p.codigo_barras = '037836050725'
   or (
     p.nombre ilike '%ricitos%biopure%90%'
     or p.nombre ilike '%ricitos%bio-pure%90%'
     or p.nombre ilike '%jbn grisi ricitos oro biopure%'
   );

-- Si aún no existe (carga no corrida / borrada): alta idempotente.
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Ricitos de Oro Bio-Pure',
  'FC-36050725',
  '037836050725',
  'Bebés',
  'Higiene bebé',
  'marca',
  'Alta F-42 84416 · Grisi Ricitos de Oro Bio-Pure jabón 90 g · EAN 037836050725',
  'Ricitos de Oro',
  '90 g',
  'Jabón',
  'GRISI',
  22.325,
  28,
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('037836050725') is null
  and public.fc_buscar_producto_escaneo('FC-F42-JBNGRISIRICITOSO') is null
  and public.fc_buscar_producto_escaneo('FC-36050725') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('037836050725', '0037836050725')
       or p.sku in ('FC-36050725', 'FC-F42-JBNGRISIRICITOSO')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  'catalogo-propia/ricitos-de-oro-bio-pure-jabon-90g-037836050725.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '037836050725'
    or p.sku in ('FC-36050725', 'FC-ND-36050725', 'FC-F42-JBNGRISIRICITOSO'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%ricitos-de-oro-bio-pure-jabon-90g-037836050725%'
  );

-- Renglón Recibir F-42 #46
update public.recepcion_items i
set
  codigo_escaneado = '037836050725',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('037836050725'),
    public.fc_buscar_producto_escaneo('FC-36050725'),
    public.fc_buscar_producto_escaneo('FC-F42-JBNGRISIRICITOSO'),
    i.producto_id
  ),
  nombre_snapshot = 'Ricitos de Oro Bio-Pure',
  pendiente_alta = false,
  costo_estimado = coalesce(nullif(i.costo_estimado, 0), 22.325)
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84416'
  and r.estado = 'borrador'
  and (
    coalesce(i.codigo_escaneado, '') in (
      'FC-F42-JBNGRISIRICITOSO', 'FC-36050725', '037836050725'
    )
    or i.nombre_snapshot ilike '%ricitos%biopure%'
    or i.nombre_snapshot ilike '%ricitos%bio%pure%'
    or i.nombre_snapshot ilike '%jbn grisi ricitos%'
    or i.producto_id in (
      select p.id from public.productos p
      where p.sku in ('FC-F42-JBNGRISIRICITOSO', 'FC-36050725', 'FC-ND-36050725')
         or p.codigo_barras = '037836050725'
    )
  );

-- ===========================================================================
-- 2) Colgate Total Encías Saludables 250 ml
-- ===========================================================================

update public.productos p
set
  codigo_barras = '7509546666969',
  sku = case
    when p.sku in ('FC-46666959', 'FC-46666969', 'FC-ND-46666969')
      then case
        when exists (
          select 1 from public.productos x
          where x.sku = 'FC-46666969'
            and x.id <> p.id
            and coalesce(x.codigo_barras, '') <> '7509546666969'
        ) then 'FC-ND-46666969'
        else 'FC-46666969'
      end
    else p.sku
  end,
  nombre = 'Colgate Total Prevención Activa Encías Saludables',
  marca = 'Colgate',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '250 ml'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Enjuague bucal'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Higiene'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Higiene bucal'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'COLGATE-PALMOLIVE'),
  costo = case when coalesce(p.costo, 0) <= 0.01 then 57.79 else p.costo end,
  precio = case when coalesce(p.precio, 0) <= 1 then 73 else p.precio end,
  activo = true,
  requiere_receta = false,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'F-42 84416 · EAN caja 7509546666969 (ticket OCR 6959 inválido)'
  ))
where p.sku in ('FC-46666959', 'FC-46666969')
   or p.codigo_barras in ('7509546666959', '7509546666969', '7509546666952')
   or p.nombre ilike '%colga%total%enc%sal%250%'
   or p.nombre ilike '%colgate total%enc_as%250%';

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Colgate Total Prevención Activa Encías Saludables',
  'FC-46666969',
  '7509546666969',
  'Higiene',
  'Higiene bucal',
  'marca',
  'Alta F-42 84416 · Colgate Total Prevención Activa Encías Saludables 250 ml · EAN 7509546666969',
  'Colgate',
  '250 ml',
  'Enjuague bucal',
  'COLGATE-PALMOLIVE',
  57.79,
  73,
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  0,
  1,
  true,
  false
where public.fc_buscar_producto_escaneo('7509546666969') is null
  and public.fc_buscar_producto_escaneo('7509546666959') is null
  and public.fc_buscar_producto_escaneo('FC-46666959') is null
  and public.fc_buscar_producto_escaneo('FC-46666969') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras in ('7509546666969', '7509546666959', '7509546666952')
       or p.sku in ('FC-46666969', 'FC-46666959')
  );

insert into public.producto_imagenes (
  producto_id, url, storage_path, posicion, es_principal, origen
)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  'catalogo-propia/colgate-total-encias-prevencion-activa-250ml-7509546666969.jpg',
  0,
  true,
  'propia'
from public.productos p
where (p.codigo_barras = '7509546666969'
    or p.sku in ('FC-46666969', 'FC-ND-46666969', 'FC-46666959'))
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%colgate-total-encias-prevencion-activa-250ml-7509546666969%'
  );

-- Renglón Recibir F-42 #31
update public.recepcion_items i
set
  codigo_escaneado = '7509546666969',
  producto_id = coalesce(
    public.fc_buscar_producto_escaneo('7509546666969'),
    public.fc_buscar_producto_escaneo('FC-46666969'),
    public.fc_buscar_producto_escaneo('FC-46666959'),
    public.fc_buscar_producto_escaneo('7509546666959'),
    i.producto_id
  ),
  nombre_snapshot = 'Colgate Total Prevención Activa Encías Saludables',
  pendiente_alta = false,
  costo_estimado = coalesce(nullif(i.costo_estimado, 0), 57.79)
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84416'
  and r.estado = 'borrador'
  and (
    coalesce(i.codigo_escaneado, '') in (
      '7509546666959', '7509546666952', '7509546666969',
      'FC-46666959', 'FC-46666969'
    )
    or i.nombre_snapshot ilike '%colga%total%enc%'
    or i.nombre_snapshot ilike '%colgate total%enc%'
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 48) as nombre,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 70) as foto,
  i.codigo_escaneado as scan_item,
  i.cantidad,
  i.pendiente_alta
from public.productos p
left join public.recepciones r
  on r.folio = '84416' and r.estado = 'borrador'
left join public.recepcion_items i
  on i.recepcion_id = r.id
 and (
   i.producto_id = p.id
   or i.codigo_escaneado in (
     '037836050725', '7509546666969', '7509546666959',
     'FC-36050725', 'FC-F42-JBNGRISIRICITOSO', 'FC-46666969', 'FC-46666959'
   )
 )
where p.codigo_barras in ('037836050725', '7509546666969', '7509546666959')
   or p.sku in (
     'FC-36050725', 'FC-ND-36050725', 'FC-F42-JBNGRISIRICITOSO',
     'FC-46666969', 'FC-ND-46666969', 'FC-46666959'
   )
order by p.codigo_barras nulls last, p.sku;
