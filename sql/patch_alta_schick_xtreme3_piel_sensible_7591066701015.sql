-- ============================================================================
-- FARMACAPITAL — Schick Xtreme 3 Piel Sensible 1 máquina
-- EAN empaque (escaneado): 7591066701015 · Edgewell · SKU FC-66701015
--
-- No está en catálogo ni en tickets de compra. Empaque individual
-- «CONT. 1 MÁQUINA DE AFEITAR» (verde lima / Piel Sensible).
-- PVP dueño $23 (ancla Vitau / OpenFarma ~$23).
-- Sin costo de compra: dejar null; ajustar al saber el paquete
-- (ref. Exprezo 12 pzas $179 ≈ $14.92/pza · Ibarra exhib. 12 ≈ $19.71).
-- Stock 0 hasta Recibir. No inventar caducidad ni lote.
--
-- Foto packshot OpenFarma → public/catalogo-propia/
--   schick-xtreme3-piel-sensible-1pza-7591066701015.jpg
-- ORDEN: 1) merge/deploy  2) pegar este SQL en Supabase → Run.
-- SIN bloques $$. Pegar TODO.
-- ============================================================================

begin;

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  marca, presentacion, forma_farmaceutica, laboratorio,
  costo, precio, imagen_url, imagen_mobile_url,
  stock, stock_minimo, activo, requiere_receta
)
select
  'Schick Xtreme 3 Piel Sensible',
  case
    when exists (
      select 1 from public.productos p
      where p.sku = 'FC-66701015'
        and coalesce(p.codigo_barras, '') <> '7591066701015'
    ) then 'FC-ND-66701015'
    else 'FC-66701015'
  end,
  '7591066701015',
  'Higiene',
  'Afeitado',
  'marca',
  'Schick Xtreme 3 Piel Sensible · 3 hojas flexibles · empaque individual 1 máquina · Edgewell · EAN 7591066701015 · PVP $23 · sin costo de compra',
  'Schick',
  '1 máquina',
  'Rastrillo',
  'EDGEWELL',
  null,
  23,
  'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg',
  'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg',
  0,
  2,
  true,
  false
where public.fc_buscar_producto_escaneo('7591066701015') is null
  and public.fc_buscar_producto_escaneo('FC-66701015') is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = '7591066701015'
       or p.sku in ('FC-66701015', 'FC-ND-66701015')
  );

update public.productos p
set
  nombre = 'Schick Xtreme 3 Piel Sensible',
  marca = 'Schick',
  presentacion = coalesce(nullif(btrim(p.presentacion), ''), '1 máquina'),
  forma_farmaceutica = coalesce(nullif(btrim(p.forma_farmaceutica), ''), 'Rastrillo'),
  categoria = coalesce(nullif(btrim(p.categoria), ''), 'Higiene'),
  subcategoria = coalesce(nullif(btrim(p.subcategoria), ''), 'Afeitado'),
  tipo = 'marca',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'EDGEWELL'),
  requiere_receta = false,
  activo = true,
  codigo_barras = '7591066701015',
  precio = case when coalesce(p.precio, 0) <= 1 then 23 else p.precio end,
  imagen_url = coalesce(nullif(btrim(p.imagen_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg'),
  imagen_mobile_url = coalesce(nullif(btrim(p.imagen_mobile_url), ''),
    'https://www.farmacapital.mx/catalogo-propia/schick-xtreme3-piel-sensible-1pza-7591066701015.jpg'),
  descripcion = trim(both ' ·' from concat_ws(
    ' · ',
    nullif(trim(both ' ·' from coalesce(p.descripcion, '')), ''),
    'Schick Xtreme 3 Piel Sensible · EAN 7591066701015 · PVP $23'
  ))
where p.codigo_barras = '7591066701015'
   or p.sku in ('FC-66701015', 'FC-ND-66701015');

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
  p.imagen_url
from public.productos p
where p.codigo_barras = '7591066701015'
   or p.sku in ('FC-66701015', 'FC-ND-66701015')
order by p.id desc
limit 3;
