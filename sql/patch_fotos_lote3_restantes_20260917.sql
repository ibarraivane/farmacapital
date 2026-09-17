-- Fotos lote 3 (2026-09-17): pendientes de siguen_sin_imagen_v2 +
-- candidatos lote 2 que sí bajaron limpios.
-- Packshots en public/catalogo-propia/. ORDEN: 1) merge/deploy  2) este SQL.
-- origen SOLO admite rappi | distribuidor | propia | gs1 | otro.
-- Idempotente: no duplica la misma URL.
-- Portada: vacío O ya apuntaba a otro catalogo-propia de este lote.

begin;

create temporary table tmp_foto_lote3 (
  producto_id bigint not null,
  ean text,
  url text not null,
  posicion int not null,
  es_principal boolean not null,
  origen text not null
) on commit drop;

insert into tmp_foto_lote3 (producto_id, ean, url, posicion, es_principal, origen) values
  (243, '7501001303454', 'https://www.farmacapital.mx/catalogo-propia/pantene-pro-v-control-caida-shampoo-400-ml-7501001303454.jpg', 1, true, 'distribuidor'),
  (339, '7501868900226', 'https://www.farmacapital.mx/catalogo-propia/alcohol-etilico-dibar-96-250-ml-7501868900226.jpg', 1, true, 'distribuidor'),
  (1270, '7501846504859', 'https://www.farmacapital.mx/catalogo-propia/xiomara-pomada-black-cera-black-60-g-7501846504859.jpg', 1, true, 'distribuidor'),
  (1633, '759684313295', 'https://www.farmacapital.mx/catalogo-propia/jaloma-mertodol-blanco-atomizador-759684313295.jpg', 1, true, 'distribuidor'),
  (1760, '7502209850231', 'https://www.farmacapital.mx/catalogo-propia/zagapsol-amlodipino-5-mg-c-10-7502209850231.jpg', 1, true, 'distribuidor'),
  (1762, '6358975544000', 'https://www.farmacapital.mx/catalogo-propia/clorofil-jahvs-solucion-500-ml-6358975544000.jpg', 1, true, 'distribuidor'),
  (1801, '7506494600311', 'https://www.farmacapital.mx/catalogo-propia/cloropiramina-schoen-25-mg-7506494600311.jpg', 1, true, 'distribuidor'),
  (1720, '7501370204584', 'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-mini-58lc-7501370204584.jpg', 1, true, 'distribuidor'),
  (1721, '7501370204577', 'https://www.farmacapital.mx/catalogo-propia/pinza-lady-curtis-maxi-57lc-7501370204577.jpg', 1, true, 'distribuidor'),
  (1315, '7506475102520', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-res-verduras-y-arroz-7506475102520.jpg', 1, true, 'distribuidor'),
  (1316, '7506475102537', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-pollo-verduras-y-arroz-7506475102537.jpg', 1, true, 'distribuidor'),
  (1317, '7506475102476', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-durazno-7506475102476.jpg', 1, true, 'distribuidor'),
  (1319, '7506475102469', 'https://www.farmacapital.mx/catalogo-propia/gerber-etapa-2-mango-7506475102469.jpg', 1, true, 'distribuidor'),
  (1771, '7506281106019', 'https://www.farmacapital.mx/catalogo-propia/ferro-4-30grag-7506281106019.jpg', 1, true, 'propia'),
  (1719, '074451166561', 'https://www.farmacapital.mx/catalogo-propia/baby-einstein-neptunes-busy-bubbles-16656.jpg', 1, true, 'propia');

-- portada
update public.productos p
set imagen_url = t.url,
    imagen_mobile_url = t.url
from tmp_foto_lote3 t
where p.id = t.producto_id
  and t.es_principal
  and (
    t.ean is null
    or p.codigo_barras = t.ean
    or p.codigo_barras = ltrim(t.ean, '0')
    or (p.id = 243 and p.codigo_barras in ('7501001303454', '7501001303464'))
    or (p.id = 1719 and p.codigo_barras in ('74451166561', '0074451166561', '074451166561'))
  )
  and (
    p.imagen_url is null
    or btrim(p.imagen_url) = ''
    or p.imagen_url not like '%' || regexp_replace(t.url, '^.*/', '') || '%'
  );

-- nombre de mostrador: EAN 7501846504859 es Cera Black, no 'Pomada B'
update public.productos
set nombre = 'Xiomara Pomada Black / Cera Black 60 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 60 g'
where id = 1270
  and codigo_barras = '7501846504859';

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
from tmp_foto_lote3 t
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = t.producto_id and i.url = t.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_lote3 where es_principal)
  and i.es_principal
  and i.url not in (select url from tmp_foto_lote3 where es_principal);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_lote3 where es_principal)
  and i.url in (select url from tmp_foto_lote3 where es_principal)
  and not i.es_principal;

commit;

select p.id, p.sku, p.codigo_barras, p.nombre, left(coalesce(p.imagen_url, ''), 90) as imagen
from public.productos p
where p.id in (243, 339, 1270, 1633, 1760, 1762, 1801, 1720, 1721, 1315, 1316, 1317, 1319, 1771, 1719)
order by p.id;
