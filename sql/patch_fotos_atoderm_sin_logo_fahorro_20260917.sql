-- ============================================================================
-- FarmaCapital — 2026-09-17
-- Quitar el placeholder rosa de Del Ahorro (letra «A») en Atoderm Intensive Baume.
-- La cosecha Fahorro guardó su imagen de «sin foto» en catalogo-propia/.
-- Packshots reales ya van en el deploy; este SQL apunta a nombres nuevos (rompe caché).
-- Correr DESPUÉS de publicar el deploy de Vercel.
-- ============================================================================

begin;

update public.productos p
   set imagen_url = v.imagen_url
  from (
    values
      ('3701129802069', 'https://www.farmacapital.mx/catalogo-propia/bioderma-atoderm-intensive-baume-200ml-3701129802069.jpg'),
      ('3701129802076', 'https://www.farmacapital.mx/catalogo-propia/bioderma-atoderm-intensive-baume-500ml-3701129802076.jpg')
  ) as v(ean, imagen_url)
 where regexp_replace(coalesce(p.codigo_barras, ''), '[^0-9]', '', 'g') = v.ean
    or p.sku in ('FC-29802069', 'FC-29802076');

update public.producto_imagenes pi
   set url = v.imagen_url
  from public.productos p
  join (
    values
      ('3701129802069', 'https://www.farmacapital.mx/catalogo-propia/bioderma-atoderm-intensive-baume-200ml-3701129802069.jpg'),
      ('3701129802076', 'https://www.farmacapital.mx/catalogo-propia/bioderma-atoderm-intensive-baume-500ml-3701129802076.jpg')
  ) as v(ean, imagen_url)
    on (
      regexp_replace(coalesce(p.codigo_barras, ''), '[^0-9]', '', 'g') = v.ean
      or p.sku in ('FC-29802069', 'FC-29802076')
    )
 where pi.producto_id = p.id
   and (
     pi.url ilike '%bioderma-3701129802069%'
     or pi.url ilike '%bioderma-3701129802076%'
     or pi.url ilike '%fahorro.com%'
   );

commit;
