-- Fotos lote 2026-09-15. Packshots en public/catalogo-propia/.
-- ORDEN: 1) merge/deploy de Vercel  2) pegar este SQL en Supabase.
-- Galería: inserta es_principal=false y luego rota la principal
-- (evita ux_producto_imagenes_una_principal).
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no pisa una foto distinta; no duplica la misma URL.
--
-- No se usó:
--   URLs de ifarma.com.mx (Cloudflare 403 desde el runner)
--   Droguería Mercurio (~100 px, inutilizable en catálogo)
--   Farmasuper alcohol 250 ml (placeholder)
--   FESA path Magento (casi todo es "Imagen no disponible")
--   Dolver Farmatodo (la caja de la foto dice C/20; el SKU es C/10)
--   Frinver Curitek (caja 6 ml; el SKU es 24 ml)

begin;

create temporary table tmp_foto_lote (
  producto_id bigint not null,
  ean text,
  url text not null,
  posicion int not null,
  es_principal boolean not null,
  origen text not null
) on commit drop;

insert into tmp_foto_lote (producto_id, ean, url, posicion, es_principal, origen) values
  (1758, '7501349020122', 'https://www.farmacapital.mx/catalogo-propia/clonixinato-de-lisina-amsa-5-amp-100-mg-2-ml-7501349020122.jpg', 1, true, 'distribuidor'),
  (1763, '7506022315038', 'https://www.farmacapital.mx/catalogo-propia/navontec-jayor-ondansetron-3-amp-8-mg-4-ml-7506022315038.jpg', 1, true, 'distribuidor'),
  (1764, '7502009742798', 'https://www.farmacapital.mx/catalogo-propia/laritol-ex-maver-loratadina-ambroxol-solucion-30-7502009742798.jpg', 1, true, 'distribuidor'),
  (1765, '7502009747274', 'https://www.farmacapital.mx/catalogo-propia/dolver-maver-ibuprofeno-10-tab-600-mg-7502009747274.jpg', 1, true, 'distribuidor'),
  (1770, '7501258203593', 'https://www.farmacapital.mx/catalogo-propia/lonixer-serral-clonixinato-10-tab-125-mg-7501258203593.jpg', 1, true, 'distribuidor'),
  (1772, '7501122960201', 'https://www.farmacapital.mx/catalogo-propia/arretin-tretinoina-crema-0-05-30-g-7501122960201.jpg', 1, true, 'distribuidor'),
  (1777, '7501299309278', 'https://www.farmacapital.mx/catalogo-propia/tusigen-nf-ambroxol-dextrometorfano-c-20-liomont-7501299309278.jpg', 1, true, 'distribuidor'),
  (1778, '7501349020979', 'https://www.farmacapital.mx/catalogo-propia/ketoprofeno-100-mg-c-15-capsulas-amsa-7501349020979.jpg', 1, true, 'distribuidor'),
  (1786, '7502009744884', 'https://www.farmacapital.mx/catalogo-propia/odivitor-atorvastatina-10-mg-c-20-maver-7502009744884.jpg', 1, true, 'distribuidor'),
  (1788, '7502009747328', 'https://www.farmacapital.mx/catalogo-propia/lapriver-itoprida-50-mg-c-30-maver-7502009747328.jpg', 1, true, 'distribuidor'),
  (1792, '7502216793439', 'https://www.farmacapital.mx/catalogo-propia/sucralfato-1-g-c-40-ultra-7502216793439.jpg', 1, true, 'distribuidor'),
  (1793, '7502216796348', 'https://www.farmacapital.mx/catalogo-propia/felodipino-lp-5-mg-c-20-ultra-7502216796348.jpg', 1, true, 'distribuidor'),
  (1794, '7502216803893', 'https://www.farmacapital.mx/catalogo-propia/ketorolaco-10-mg-c-10-avivia-7502216803893.jpg', 1, true, 'distribuidor'),
  (1811, '7503003738671', 'https://www.farmacapital.mx/catalogo-propia/sepia-itraconazol-33-3-mg-secnidazol-166-6-mg-c-7503003738671.jpg', 1, true, 'distribuidor'),
  (1814, '7501258208550', 'https://www.farmacapital.mx/catalogo-propia/valaciclovir-serral-500-mg-c-10-tabletas-7501258208550.jpg', 1, true, 'distribuidor'),
  (1768, '7501563380415', 'https://www.farmacapital.mx/catalogo-propia/tretinoina-randall-crema-0-05-20-g-7501563380415.jpg', 1, true, 'distribuidor'),
  (1795, '7502226291871', 'https://www.farmacapital.mx/catalogo-propia/hidropharm-clortalidona-50-mg-c-30-alpharma-7502226291871.jpg', 1, true, 'distribuidor'),
  (1757, '7506335701214', 'https://www.farmacapital.mx/catalogo-propia/ht-bloc-accord-ondansetron-1-amp-4-mg-2-ml-7506335701214.jpg', 1, true, 'distribuidor'),
  (1317, '7506475102476', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-durazno-100-g-7506475102476.jpg', 1, true, 'propia'),
  (1319, '7506475102469', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-mango-100-g-7506475102469.jpg', 1, true, 'propia'),
  (1766, '7502009748035', 'https://www.farmacapital.mx/catalogo-propia/tinitrend-maver-tretinoina-crema-0-05-30-g-7502009748035.jpg', 1, true, 'distribuidor'),
  (1766, '7502009748035', 'https://www.farmacapital.mx/catalogo-propia/tinitrend-maver-tretinoina-crema-0-05-30-g-7502009748035-g3.jpg', 2, false, 'distribuidor'),
  (1774, '7501075711035', 'https://www.farmacapital.mx/catalogo-propia/debisor-sublingual-5-mg-c-20-novag-7501075711035.jpg', 1, true, 'distribuidor'),
  (1813, '7502009749469', 'https://www.farmacapital.mx/catalogo-propia/tribenosido-5-lidocaina-2-crema-rectal-30-g-7502009749469.jpg', 1, true, 'distribuidor'),
  (1719, '074451166561', 'https://www.farmacapital.mx/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg', 1, true, 'propia');

-- portada: solo si imagen_url está vacío
update public.productos p
set imagen_url = t.url,
    imagen_mobile_url = t.url
from tmp_foto_lote t
where p.id = t.producto_id
  and t.es_principal
  and (
    t.ean is null
    or p.codigo_barras = t.ean
    or p.codigo_barras = ltrim(t.ean, '0')
    or p.codigo_barras in ('74451166561', '0074451166561')
  )
  and (p.imagen_url is null or btrim(p.imagen_url) = '');

-- galería: insertar como NO principal
insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  t.producto_id,
  t.url,
  'catalogo-propia/' || regexp_replace(t.url, '^.*/', ''),
  coalesce((select max(i.posicion) from public.producto_imagenes i
            where i.producto_id = t.producto_id), 0) + t.posicion,
  false,
  t.origen
from tmp_foto_lote t
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = t.producto_id and i.url = t.url
);

-- rotar principal a la portada de este lote
update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_lote where es_principal)
  and i.es_principal
  and i.url not in (select url from tmp_foto_lote where es_principal);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_lote where es_principal)
  and i.url in (select url from tmp_foto_lote where es_principal)
  and not i.es_principal;

commit;

select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 90) as imagen
from public.productos p
where p.id in (1757,1758,1763,1764,1765,1766,1768,1770,1772,1774,1777,1778,1786,1788,1792,1793,1794,1795,1811,1813,1814,1317,1319,1719)
order by p.id;
