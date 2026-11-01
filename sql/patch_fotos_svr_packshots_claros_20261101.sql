-- ============================================================================
-- FARMA CAPITAL — SVR packshots claros para POS (sin lifestyle)
-- 2026-11-01
--
-- Cambia fotos “con manos / modelo” por packshot de producto solo
-- (fondo blanco, etiqueta legible). Hyalu Biotic: pote + cúpula refill + tapa
-- (SVR no publica la caja de cartón en su web; esto sí muestra la presentación
-- rechargeable que llega a mostrador).
--
-- URLs = CDN oficial SVR (responden YA). Pegar TODO en Supabase → Run.
-- Tras deploy, las mismas piezas viven en public/catalogo-propia/.
-- ============================================================================

begin;

create temporary table tmp_svr_pack_claro (
  ean text primary key,
  sku text not null,
  presentacion text,
  url text not null
) on commit drop;

insert into tmp_svr_pack_claro (ean, sku, presentacion, url) values
  (
    '3662361002450', 'FC-61002450', '30 ml',
    'https://cdn.shopify.com/s/files/1/0720/8343/9854/files/1.7-Sebiaclear-Ampoule_Flash-1004G16-SVR-Purifiez_et_illuminez_votre_peau_instantanement_avec_cette_ampoule_eclat_1b6c739a-1429-40a9-bac1-55a081fc632d.jpg?v=1773914165'
  ),
  (
    '3662361000364', 'FC-61000364', '30 ml',
    'https://cdn.shopify.com/s/files/1/0720/8343/9854/files/1.7-Sebiaclear-Serum-1004A16-SVR-Concentre_purifiant_anti-imperfections_5679adb7-8340-46ac-852f-53f711134318.jpg?v=1733163987'
  ),
  (
    '3662361003402', 'FC-61003402', '400 ml',
    'https://cdn.shopify.com/s/files/1/0256/9021/0376/files/1.7-Sebiaclear-GelMoussant-1004237-SVR-Purificationefficacepourpeauxatendanceacneique.jpg?v=1733158620'
  ),
  (
    '3662361002597', 'FC-61002597', '50 ml · sin color',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.7-Sun_Secure-Blur_SPF50_-1029418-SVR-Protection_solaire_avec_effet_floutant.jpg?v=1775664534'
  ),
  (
    '3662361003167', 'FC-61003167', '50 ml · con color',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.7-Sun_Secure-Blur_Teinte_SPF50_-1029N17-SVR-Protection_solaire_teintee_avec_effet_floutant.jpg?v=1775664666'
  ),
  (
    '3662361001897', 'FC-61001897', '400 ml',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.9-Topialyse-Gel_Lavant-1002737-SVR-Gel_nettoyant_doux_pour_peaux_seches_et_sensibles.jpg?v=1761857615'
  ),
  (
    '3662361004300', 'FC-61004300', '50 ml · pote refillable',
    'https://cdn.shopify.com/s/files/1/0720/8343/9854/files/SVR_retouche-site_ACDA_Hyalu_Biotic_1200x1200_e16746b3-e50a-4bee-9b4f-d145f6c2a7a6.jpg?v=1779784814'
  ),
  (
    '3662361003792', 'FC-61003792', '200 ml',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.8-Physiopure-Gelee_Moussante-1026417-SVR-Nettoyant_purete_Anti-pollution.jpg?v=1761858838'
  ),
  (
    '3662361000937', 'FC-61000937', '30 ml',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.7-A_B3_C-Ampoule_Hydra-1010426-SVR-Ampoule_concentree_en_vitamine_B3_pour_une_hydratation_intense.jpg?v=1727253362'
  ),
  (
    '3662361000401', 'FC-61000401', '30 ml',
    'https://cdn.shopify.com/s/files/1/0710/4738/1213/files/1.7-A_B3_C-Ampoule_Anti-Ox-1010416-SVR-Serum_a_la_vitamine_C_pour_une_peau_eclatante.jpg?v=1761849553'
  );

update public.productos p
set
  imagen_url = t.url,
  imagen_mobile_url = t.url,
  presentacion = coalesce(t.presentacion, p.presentacion)
from tmp_svr_pack_claro t
where p.codigo_barras = t.ean
   or p.sku = t.sku
   or p.sku = 'FC-ND-' || right(t.ean, 8);

-- Nombre Hyalu: dejar claro que es pote refillable (no solo “contenedor”)
update public.productos
set nombre = 'SVR Hyalu Biotic pote refillable'
where codigo_barras = '3662361004300'
   or sku in ('FC-61004300', 'FC-ND-61004300');

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  false,
  'distribuidor'
from tmp_svr_pack_claro t
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
  select p.id from public.productos p
  join tmp_svr_pack_claro t
    on p.codigo_barras = t.ean or p.sku = t.sku or p.sku = 'FC-ND-' || right(t.ean, 8)
);

update public.producto_imagenes i
set es_principal = true
from public.productos p
join tmp_svr_pack_claro t
  on p.codigo_barras = t.ean or p.sku = t.sku or p.sku = 'FC-ND-' || right(t.ean, 8)
where i.producto_id = p.id
  and i.url = t.url;

commit;

select
  p.sku, p.codigo_barras as ean, p.nombre, p.presentacion,
  left(p.imagen_url, 96) as foto
from public.productos p
where p.codigo_barras in (
  '3662361002450','3662361000364','3662361003402','3662361002597','3662361003167',
  '3662361001897','3662361004300','3662361003792','3662361000937','3662361000401'
)
order by p.nombre;
