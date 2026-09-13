-- ============================================================================
-- FARMA CAPITAL — 14 EANs sin catálogo (Recibir mostrador 13-sep-2026)
--
-- Recuadro rojo: productos sin registrar. SKU = FC- + últimos 8 del EAN
-- (skuAltaRecepcion). Stock 0 hasta Recibir. Sin inventar caducidad.
--
-- Fuentes ficha (no código de ticket):
--   St Ives / Unilever · Seda Pure · L'Oréal · Listerine YZA · Just For Men
--   Pert/Grisi · Organogal Silver kit · BIC · Kleenex
--
-- Fotos: public/catalogo-propia/… → después del deploy corre
--   sql/patch_fotos_catalogo_14_mostrador_20260913.sql
-- Pegar TODO en Supabase → SQL Editor → Run.
-- ============================================================================

begin;

create temp table _fc_alta_14 (
  ean text primary key,
  sku text not null,
  nombre text not null,
  precio numeric(12,2) not null,
  categoria text not null,
  marca text not null,
  presentacion text not null,
  forma_farmaceutica text not null,
  subcategoria text not null,
  descripcion text not null
) on commit drop;

insert into _fc_alta_14 values
  (
    '7506306208353',
    'FC-06208353',
    'St. Ives crema corporal Humectación Profunda avena y karité 200 ml',
    48.00,
    'Cuidado personal',
    'St. Ives',
    '200 ml',
    'Crema',
    'Crema corporal',
    'Alta mostrador 2026-09-13 · Unilever St. Ives MX EAN 7506306208353 · PVP ancla ~48 · sin costo de compra'
  ),
  (
    '7502254072831',
    'FC-54072831',
    'Seda Pure Brillo Keratin sílica spray 125 ml',
    89.00,
    'Cuidado personal',
    'Seda Pure',
    '125 ml',
    'Spray',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Seda Pure Brillo Keratin 125 ml EAN 7502254072831 · termo protección + pantenol · PVP ancla Coppel ~89 · sin costo'
  ),
  (
    '7501027233974',
    'FC-27233974',
    'L''Oréal Paris Studio Line Invisi Fix Ultra Fijación gel 180 g',
    97.00,
    'Cuidado personal',
    'L''Oréal Paris',
    '180 g',
    'Gel',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · L''Oréal Studio Line Invisi Fix 180 g EAN 7501027233974 · PVP ancla ~97 · sin costo'
  ),
  (
    '7702035433299',
    'FC-35433299',
    'Listerine Pro-Encías enjuague bucal menta 250 ml',
    99.00,
    'Higiene',
    'Listerine',
    '250 ml',
    'Enjuague',
    'Higiene bucal',
    'Alta mostrador 2026-09-13 · Listerine Pro-Encías 250 ml EAN 7702035433299 · ficha/imagen YZA · PVP ancla ~99 · sin costo'
  ),
  (
    '7502254073715',
    'FC-54073715',
    'Seda Pure tratamiento bifase keratina 250 ml',
    95.00,
    'Cuidado personal',
    'Seda Pure',
    '250 ml',
    'Spray',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Seda Pure bifase keratina 250 ml EAN 7502254073715 · protección térmica · sin costo'
  ),
  (
    '7501080111455',
    'FC-80111455',
    'Just For Men tinte barba y bigote negro',
    165.00,
    'Cuidado personal',
    'Just For Men',
    'Kit gel',
    'Gel',
    'Tinte',
    'Alta mostrador 2026-09-13 · Just For Men barba/bigote negro EAN 7501080111455 · sin amoníaco · sin costo'
  ),
  (
    '7506306208315',
    'FC-06208315',
    'St. Ives crema corporal Piel Renovada colágeno y elastina 200 ml',
    49.00,
    'Cuidado personal',
    'St. Ives',
    '200 ml',
    'Crema',
    'Crema corporal',
    'Alta mostrador 2026-09-13 · Unilever St. Ives MX EAN 7506306208315 · PVP ancla ~49 · sin costo'
  ),
  (
    '7502254073357',
    'FC-54073357',
    'Seda Pure sílica spray uva 300 ml',
    94.00,
    'Cuidado personal',
    'Seda Pure',
    '300 ml',
    'Spray',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Seda Pure sílica uva spray 300 ml EAN 7502254073357 · PVP ancla Farmacias Bazar ~94 · sin costo'
  ),
  (
    '7502254073371',
    'FC-54073371',
    'Seda Pure sílica spray argán 300 ml',
    94.00,
    'Cuidado personal',
    'Seda Pure',
    '300 ml',
    'Spray',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Seda Pure sílica argán spray 300 ml EAN 7502254073371 · sin costo'
  ),
  (
    '810120500164',
    'FC-20500164',
    'Pert crema para peinar kera + aguacate 100 ml',
    55.00,
    'Cuidado personal',
    'Pert',
    '100 ml',
    'Crema',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Grisi/Pert crema peinar keratina y aguacate 100 ml UPC 810120500164 · sin costo'
  ),
  (
    '850040940602',
    'FC-40940602',
    'Grisi Organogal Silver kit shampoo 400 ml + tratamiento canas 130 ml',
    189.00,
    'Cuidado personal',
    'Grisi',
    'Kit 400 ml + 130 ml',
    'Kit',
    'Cuidado del cabello',
    'Alta mostrador 2026-09-13 · Organogal Silver kit shampoo 400 ml + crema 130 ml UPC 850040940602 · matizador canas · sin costo'
  ),
  (
    '070330717541',
    'FC-30717541',
    'BIC Comfort 3 rastrillos desechables 12 pzas',
    120.00,
    'Higiene',
    'BIC',
    '12 pzas',
    'Rastrillo',
    'Afeitado',
    'Alta mostrador 2026-09-13 · BIC Comfort3 piel normal 12 pzas UPC 070330717541 · sin costo'
  ),
  (
    '070330731813',
    'FC-30731813',
    'BIC Soleil 3 Color Collection rastrillos 12 pzas',
    145.00,
    'Higiene',
    'BIC',
    '12 pzas',
    'Rastrillo',
    'Afeitado',
    'Alta mostrador 2026-09-13 · BIC Soleil 3 Color Collection UPC 070330731813 · sin costo'
  ),
  (
    '7501943476271',
    'FC-43476271',
    'Kleenex pañuelos faciales bote 50 pzas',
    45.00,
    'Higiene',
    'Kleenex',
    'Bote 50 pzas',
    'Pañuelos',
    'Pañuelos',
    'Alta mostrador 2026-09-13 · Kleenex bote C/50 EAN 7501943476271 · sin costo'
  );

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku
        and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  'marca',
  t.descripcion,
  null,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma_farmaceutica,
  t.subcategoria
from _fc_alta_14 t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.sku = t.sku
       or p.codigo_barras = t.ean
  );

commit;

select
  p.id,
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.presentacion,
  p.precio,
  p.stock,
  p.categoria,
  p.activo
from public.productos p
where p.codigo_barras in (
  '7506306208353', '7502254072831', '7501027233974', '7702035433299',
  '7502254073715', '7501080111455', '7506306208315', '7502254073357',
  '7502254073371', '810120500164', '850040940602', '070330717541',
  '070330731813', '7501943476271'
)
order by p.codigo_barras;
