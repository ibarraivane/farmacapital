-- ============================================================================
-- HOTFIX fotos SVR — URLs oficiales CDN (mx.svr.com / Shopify)
-- 2026-11-01
--
-- Por qué: el patch anterior apuntó a
--   https://www.farmacapital.mx/catalogo-propia/svr-….jpg
-- pero esas JPGs aún NO están en producción (PR #512 sin merge a main).
-- El POS recibe 404 → onError → caja amarilla «SVR».
--
-- Este SQL usa el CDN oficial de SVR (ya responde 200) para que las fotos
-- salgan YA, sin esperar el merge. Pegar TODO en Supabase → Run.
-- ============================================================================

begin;

create temporary table tmp_svr_cdn (
  ean text primary key,
  sku text not null,
  nombre text not null,
  presentacion text not null,
  concentracion text,
  forma text,
  url text not null
) on commit drop;

insert into tmp_svr_cdn
  (ean, sku, nombre, presentacion, concentracion, forma, url)
values
  (
    '3662361002450', 'FC-61002450',
    'SVR Sebiaclear Ampoule Flash',
    '30 ml', null, 'Ampolla',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-Sebiaclear-Ampoule_Flash-1004G16-SVR-Purifiez_et_illuminez_votre_peau_instantanement_avec_cette_ampoule_eclat.jpg'
  ),
  (
    '3662361000364', 'FC-61000364',
    'SVR Sebiaclear Sérum',
    '30 ml', null, 'Sérum',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/SERUM-1.webp'
  ),
  (
    '3662361003402', 'FC-61003402',
    'SVR Sebiaclear Gel Moussant',
    '400 ml', null, 'Gel',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/OLD1.1-Sebiaclear-GelMoussant-1004237-SVR-Purificationefficacepourpeauxatendanceacneique.jpg'
  ),
  (
    '3662361002597', 'FC-61002597',
    'SVR Sun Secure Blur SPF50+',
    '50 ml · sin color', 'SPF50+', 'Crema mousse',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-Sun_Secure-Blur_SPF50_-1029418-SVR-Protection_solaire_avec_effet_floutant.jpg'
  ),
  (
    '3662361003167', 'FC-61003167',
    'SVR Sun Secure Blur Teinté SPF50+',
    '50 ml · con color', 'SPF50+', 'Crema mousse',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-Sun_Secure-Blur_Teinte_SPF50_-1029N17-SVR-Protection_solaire_teintee_avec_effet_floutant.jpg'
  ),
  (
    '3662361001897', 'FC-61001897',
    'SVR Topialyse Gel Lavant',
    '400 ml', null, 'Gel',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-Topialyse-Gel_Lavant-1002757-SVR-Gel_nettoyant_doux_pour_peaux_seches_et_sensibles.jpg'
  ),
  (
    '3662361004300', 'FC-61004300',
    'SVR Hyalu Biotic Rechargeable',
    '50 ml', null, 'Gel',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-Biotic-Hyalu-1031416-SVR-Soinhydratantintensifal_acidehyaluronique_b2e04dd2-ef1b-4b87-983b-af6bbe123f8d.webp'
  ),
  (
    '3662361003792', 'FC-61003792',
    'SVR Physiopure Gelée Moussante',
    '200 ml', null, 'Gelée',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.2-Physiopure-Gelee_Moussante-1026417-SVR-Nettoyant_purete_Anti-pollution.jpg'
  ),
  (
    '3662361000937', 'FC-61000937',
    'SVR Ampoule B3 Hydra',
    '30 ml', null, 'Ampolla',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/OLD1.1-AB3C-AmpouleHydra-101042.jpg'
  ),
  (
    '3662361000401', 'FC-61000401',
    'SVR Ampoule C Anti-Ox',
    '30 ml', null, 'Ampolla',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.1-AB3C-AmpouleAnti-Ox-1010416-SVR-SerumalavitamineCpourunepeaueclatante.png'
  );

update public.productos p
set
  nombre = t.nombre,
  marca = 'SVR',
  laboratorio = coalesce(nullif(btrim(p.laboratorio), ''), 'SVR'),
  presentacion = t.presentacion,
  concentracion = coalesce(t.concentracion, p.concentracion),
  forma_farmaceutica = coalesce(t.forma, p.forma_farmaceutica),
  imagen_url = t.url,
  imagen_mobile_url = t.url,
  activo = true
from tmp_svr_cdn t
where p.codigo_barras = t.ean
   or p.sku = t.sku
   or p.sku = 'FC-ND-' || right(t.ean, 8);

-- Quitar URLs rotas de farmacapital.mx/catalogo-propia/svr-… que aún no existen en prod
delete from public.producto_imagenes i
using public.productos p, tmp_svr_cdn t
where i.producto_id = p.id
  and (p.codigo_barras = t.ean or p.sku = t.sku or p.sku = 'FC-ND-' || right(t.ean, 8))
  and i.url like '%farmacapital.mx/catalogo-propia/svr-%';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.url,
  null,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  false,
  'distribuidor'
from tmp_svr_cdn t
join public.productos p
  on p.codigo_barras = t.ean
  or p.sku = t.sku
  or p.sku = 'FC-ND-' || right(t.ean, 8)
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = p.id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (
  select p.id
  from public.productos p
  join tmp_svr_cdn t
    on p.codigo_barras = t.ean
    or p.sku = t.sku
    or p.sku = 'FC-ND-' || right(t.ean, 8)
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
join tmp_svr_cdn t
  on p.codigo_barras = t.ean
  or p.sku = t.sku
  or p.sku = 'FC-ND-' || right(t.ean, 8)
where i.producto_id = p.id
  and i.url = t.url;

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.presentacion,
  p.stock,
  case
    when p.imagen_url like '%cdn.shopify.com%' then 'cdn_svr_ok'
    when p.imagen_url like '%farmacapital.mx/catalogo-propia%' then 'local_pendiente_merge'
    else 'otro'
  end as foto_estado,
  left(p.imagen_url, 90) as foto
from public.productos p
where p.codigo_barras in (
  '3662361002450','3662361000364','3662361003402','3662361002597','3662361003167',
  '3662361001897','3662361004300','3662361003792','3662361000937','3662361000401'
)
order by p.nombre;
