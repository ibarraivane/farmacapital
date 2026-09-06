-- Catálogo · Nasalub categoría + fotos Solución CS / Bruluaquil
-- ─────────────────────────────────────────────────────────────
-- 1) Nasalub Sol (FC-40015366): spray nasal → Respiratorio.
--    Había quedado en Hidratación por el “alivia la resequedad”
--    de la caja; no es suero/electrolitos. Misma familia que Afrin.
-- 2) Solucion CS PiSA 250 mL (FC-25100116): la portada Rappi
--    (rappi/.../1.webp) muestra la etiqueta al revés. Nueva portada
--    desde Fahorro (EAN 7501125100116), orientación correcta.
--    Categoría Hidratación se mantiene (solución parenteral IV).
-- 3) Bruluaquil (FC-08895042): la portada Rappi trae marca de agua
--    GENDIFAR en el fondo. Nueva foto propia sin marca de agua.
--    Categoría Analgésico ya era correcta.
--
-- Archivos en public/catalogo-propia/ — correr DESPUÉS del deploy
-- de Vercel. Si corres antes, las URLs dan 404.
-- También alinea Solución CS 500 mL (FC-25100123) a Hidratación
-- (estaba en Dispositivo médico).

begin;

-- ── 1) Nasalub → Respiratorio ─────────────────────────────────
update public.productos
set
  categoria = 'Respiratorio',
  subcategoria = coalesce(nullif(trim(subcategoria), ''), 'Solución nasal'),
  forma_farmaceutica = coalesce(nullif(trim(forma_farmaceutica), ''), 'SPRAY')
where sku = 'FC-40015366';

-- ── 2) Solución CS 500 mL → Hidratación (alineado con 250 mL) ─
update public.productos
set categoria = 'Hidratación'
where sku = 'FC-25100123'
  and categoria is distinct from 'Hidratación';

-- ── 3) Solución CS 250 mL · foto portada correcta ────────────
update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/solucion-cs-pisa-250ml.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/solucion-cs-pisa-250ml.jpg'
where sku = 'FC-25100116';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/solucion-cs-pisa-250ml.jpg',
  'catalogo-propia/solucion-cs-pisa-250ml.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.sku = 'FC-25100116'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/solucion-cs-pisa-250ml%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/solucion-cs-pisa-250ml%')
where i.producto_id = (select id from public.productos where sku = 'FC-25100116' limit 1);

-- ── 4) Bruluaquil · foto sin marca de agua ───────────────────
update public.productos
set
  imagen_url = 'https://www.farmacapital.mx/catalogo-propia/bruluaquil-24tab.jpg',
  imagen_mobile_url = 'https://www.farmacapital.mx/catalogo-propia/bruluaquil-24tab.jpg'
where sku = 'FC-08895042';

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  'https://www.farmacapital.mx/catalogo-propia/bruluaquil-24tab.jpg',
  'catalogo-propia/bruluaquil-24tab.jpg',
  coalesce((select max(posicion) from public.producto_imagenes i where i.producto_id = p.id), 0) + 1,
  true,
  'propia'
from public.productos p
where p.sku = 'FC-08895042'
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and i.url like '%catalogo-propia/bruluaquil-24tab%'
  );

update public.producto_imagenes i
set es_principal = (i.url like '%catalogo-propia/bruluaquil-24tab%')
where i.producto_id = (select id from public.productos where sku = 'FC-08895042' limit 1);

commit;

select
  sku,
  left(nombre, 48) as nombre,
  categoria,
  left(coalesce(imagen_url, ''), 78) as foto
from public.productos
where sku in ('FC-40015366', 'FC-25100116', 'FC-25100123', 'FC-08895042')
order by sku;
