-- ============================================================================
-- FARMA CAPITAL — Segundo lote vitrina bajo pedido: marcas que recetan dermatólogos
-- 16-sep-2026
--
-- ANTES: sql/patch_bajo_pedido_20260916.sql
--        sql/patch_alta_bajo_pedido_vitrina_20260916.sql (primer lote, 26 SKUs)
-- Pegar TODO en Supabase → SQL Editor → Run. Idempotente.
--
-- 21 SKUs. Ancla = precio de lista Fahorro (SKU = EAN), ceil a peso.
-- Nadro i22 devolvió 429 en esta pasada; no se inventó ficha Nadro.
-- Stock 0. Sin lote ni caducidad.
--
-- Si el EAN ya existe CON stock de anaquel: no se marca bajo_pedido.
-- ============================================================================

begin;

do $$
begin
  if not exists (
    select 1
      from information_schema.columns
     where table_schema = 'public'
       and table_name = 'productos'
       and column_name = 'bajo_pedido'
  ) then
    raise exception 'Primero corre sql/patch_bajo_pedido_20260916.sql (falta productos.bajo_pedido)';
  end if;
end
$$;

create temp table _fc_vitrina_bp_derm (
  ean text primary key,
  sku text not null,
  nombre text not null,
  marca text not null,
  presentacion text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  precio numeric(12,2) not null,
  imagen_url text not null,
  descripcion text not null
) on commit drop;

insert into _fc_vitrina_bp_derm values
  ('3337875816809', 'FC-75816809', 'La Roche-Posay Cicaplast Baume B5+ 40 ml', 'La Roche-Posay', '40 ml', 'Cuidado personal', 'Dermatología', 'Bálsamo', 426::numeric, 'https://www.farmacapital.mx/catalogo-propia/cicaplast-baume-b5-plus-40ml.jpg', 'Fahorro SKU=EAN 3337875816809 · Cicaplast Baume B5+ 40 ml · precio lista $426'),
  ('3337875696548', 'FC-75696548', 'La Roche-Posay Lipikar Baume AP+M 400 ml', 'La Roche-Posay', '400 ml', 'Cuidado personal', 'Dermatología', 'Bálsamo', 834::numeric, 'https://www.farmacapital.mx/catalogo-propia/lipikar-baume-apm-400ml.jpg', 'Fahorro SKU=EAN 3337875696548 · Lipikar Baume AP+M 400 ml · precio lista $834'),
  ('3337875583626', 'FC-75583626', 'La Roche-Posay Hyalu B5 Suero Anti-Edad Hidratante 30 ml', 'La Roche-Posay', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 851::numeric, 'https://www.farmacapital.mx/catalogo-propia/hyalu-b5-serum-30ml.jpg', 'Fahorro SKU=EAN 3337875583626 · Hyalu B5 suero 30 ml · precio mostrado $851'),
  ('3337875543248', 'FC-75543248', 'Vichy Minéral 89 Suero Hidratante Facial 50 ml', 'Vichy', '50 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 946::numeric, 'https://www.farmacapital.mx/catalogo-propia/vichy-mineral-89-50ml.jpg', 'Fahorro SKU=EAN 3337875543248 · Mineral 89 50 ml · precio lista $946'),
  ('3337871330286', 'FC-71330286', 'Vichy Dercos Shampoo Anti-Caspa Grasa 200 ml', 'Vichy', '200 ml', 'Cuidado personal', 'Dermatología', 'Champú', 708::numeric, 'https://www.farmacapital.mx/catalogo-propia/vichy-dercos-anticaspa-200ml.jpg', 'Fahorro SKU=EAN 3337871330286 · Dercos anti-caspa grasa 200 ml · precio lista $708'),
  ('3499320012850', 'FC-20012850', 'Cetaphil Loción Limpiadora Piel Sensible 473 ml', 'Cetaphil', '473 ml', 'Cuidado personal', 'Dermatología', 'Loción', 598::numeric, 'https://www.farmacapital.mx/catalogo-propia/cetaphil-locion-limpiadora-473ml.jpg', 'Fahorro SKU=EAN 3499320012850 · Loción limpiadora 473 ml · precio lista $598'),
  ('3499320015530', 'FC-20015530', 'Cetaphil Limpiador Facial Diario para Piel Grasa 473 ml', 'Cetaphil', '473 ml', 'Cuidado personal', 'Dermatología', 'Gel', 630::numeric, 'https://www.farmacapital.mx/catalogo-propia/cetaphil-limpiador-grasa-473ml.jpg', 'Fahorro SKU=EAN 3499320015530 · Limpiador facial piel grasa 473 ml · precio lista $630'),
  ('8470001724137', 'FC-01724137', 'Heliocare 360 Gel Oil-Free FPS 50+ 50 ml', 'Heliocare', '50 ml', 'Cuidado personal', 'Dermatología', 'Gel', 788::numeric, 'https://www.farmacapital.mx/catalogo-propia/heliocare-360-gel-oil-free-50ml.jpg', 'Fahorro SKU=EAN 8470001724137 · Heliocare 360 Gel Oil Free 50 ml · precio lista $788'),
  ('3701129812075', 'FC-29812075', 'Bioderma Sensibio H2O Agua Micelar 100 ml', 'Bioderma', '100 ml', 'Cuidado personal', 'Dermatología', 'Agua micelar', 248::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-sensibio-h2o-100ml.jpg', 'Fahorro SKU=EAN 3701129812075 · Sensibio H2O 100 ml · precio lista $248'),
  ('3401399277092', 'FC-99277092', 'Bioderma Sébium Gel Moussant 500 ml', 'Bioderma', '500 ml', 'Cuidado personal', 'Dermatología', 'Gel', 829::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-sebium-gel-500ml.jpg', 'Fahorro SKU=EAN 3401399277092 · Sébium Gel Moussant 500 ml · precio lista $829'),
  ('3337875597388', 'FC-75597388', 'CeraVe Crema Hidratante Rostro y Cuerpo 454 g', 'CeraVe', '454 g', 'Cuidado personal', 'Dermatología', 'Crema', 575::numeric, 'https://www.farmacapital.mx/catalogo-propia/cerave-crema-hidratante-454g.jpg', 'Fahorro SKU=EAN 3337875597388 · Crema hidratante 454 g · precio lista $575'),
  ('3282776385421', 'FC-76385421', 'Avène Cicalfate+ Crema Reparadora 100 ml', 'Avène', '100 ml', 'Cuidado personal', 'Dermatología', 'Crema', 644::numeric, 'https://www.farmacapital.mx/catalogo-propia/avene-cicalfate-plus-100ml.jpg', 'Fahorro SKU=EAN 3282776385421 · Cicalfate+ 100 ml · precio lista $644'),
  ('3282776382109', 'FC-76382109', 'Ducray Kelual DS Champú Tratante 100 ml', 'Ducray', '100 ml', 'Cuidado personal', 'Dermatología', 'Champú', 584::numeric, 'https://www.farmacapital.mx/catalogo-propia/ducray-kelual-ds-shampoo-100ml.jpg', 'Fahorro SKU=EAN 3282776382109 · Kelual DS shampoo 100 ml · precio lista $584'),
  ('8470002094857', 'FC-02094857', 'Endocare Hyaluboost Age Barrier Sérum 30 ml', 'Endocare', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1084::numeric, 'https://www.farmacapital.mx/catalogo-propia/endocare-hyaluboost-30ml.jpg', 'Fahorro SKU=EAN 8470002094857 · Hyaluboost Age Barrier Serum 30 ml · precio habitual $1,084'),
  ('3661434004735', 'FC-34004735', 'Uriage Bariéderm Cica Crema Reparadora 40 ml', 'Uriage', '40 ml', 'Cuidado personal', 'Dermatología', 'Crema', 319::numeric, 'https://www.farmacapital.mx/catalogo-propia/uriage-bariederm-cica-40ml.jpg', 'Fahorro SKU=EAN 3661434004735 · Bariéderm Cica crema 40 ml · precio lista $319'),
  ('3282770073577', 'FC-70073577', 'A-Derma Exomega Control Crema Emoliente 400 ml', 'A-Derma', '400 ml', 'Cuidado personal', 'Dermatología', 'Crema', 801::numeric, 'https://www.farmacapital.mx/catalogo-propia/aderma-exomega-control-400ml.jpg', 'Fahorro SKU=EAN 3282770073577 · Exomega Control 400 ml · precio lista $801'),
  ('8470001541871', 'FC-01541871', 'Isdin Ureadin Ultra 20 Crema 100 ml', 'Isdin', '100 ml', 'Cuidado personal', 'Dermatología', 'Crema', 450::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-ureadin-ultra-20-100ml.jpg', 'Fahorro SKU=EAN 8470001541871 · Ureadin Ultra 20 100 ml · precio lista $450'),
  ('4005800164361', 'FC-00164361', 'Eucerin UreaRepair Loción Corporal 10% 400 ml', 'Eucerin', '400 ml', 'Cuidado personal', 'Dermatología', 'Loción', 682::numeric, 'https://www.farmacapital.mx/catalogo-propia/eucerin-urea-repair-10-400ml.jpg', 'Fahorro SKU=EAN 4005800164361 · Urea Repair loción 10% 400 ml · precio lista $682'),
  ('8431166181418', 'FC-66181418', 'Leti AT4 Multiprotect Facial FPS 50+ 50 ml', 'Leti', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 632::numeric, 'https://www.farmacapital.mx/catalogo-propia/leti-at4-multiprotect-50ml.jpg', 'Fahorro SKU=EAN 8431166181418 · AT4 Multiprotect facial FPS 50+ 50 ml · precio lista $632'),
  ('8429979444448', 'FC-79444448', 'Sesderma C-VIT Crema Facial Hidratante 50 ml', 'Sesderma', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 1235::numeric, 'https://www.farmacapital.mx/catalogo-propia/sesderma-c-vit-50ml.jpg', 'Fahorro SKU=EAN 8429979444448 · C-VIT crema 50 ml · precio habitual $1,235'),
  ('3504105025878', 'FC-05025878', 'Mustela Crema para Rozaduras Bebé 100 ml', 'Mustela', '100 ml', 'Cuidado personal', 'Dermatología', 'Crema', 202::numeric, 'https://www.farmacapital.mx/catalogo-propia/mustela-rozaduras-100ml.jpg', 'Fahorro SKU=EAN 3504105025878 · Crema rozaduras 100 ml · precio lista $202');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, subcategoria, imagen_url,
  bajo_pedido
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
  t.forma,
  t.subcategoria,
  t.imagen_url,
  true
from _fc_vitrina_bp_derm t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where p.codigo_barras = t.ean
  );

update public.productos p
   set bajo_pedido = true,
       activo = true,
       marca = coalesce(nullif(trim(p.marca), ''), t.marca),
       presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
       imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen_url),
       precio = case when coalesce(p.precio, 0) <= 0.01 then t.precio else p.precio end
  from _fc_vitrina_bp_derm t
 where (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean))
   and coalesce(p.stock, 0) = 0;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id, t.imagen_url, 1, true, 'distribuidor'
  from _fc_vitrina_bp_derm t
  join public.productos p
    on p.codigo_barras = t.ean
    or p.id = public.fc_buscar_producto_escaneo(t.ean)
 where coalesce(p.bajo_pedido, false) = true
   and not exists (
     select 1 from public.producto_imagenes i
      where i.producto_id = p.id
        and i.url = t.imagen_url
   );

commit;

select
  p.sku,
  p.codigo_barras as ean,
  p.nombre,
  p.marca,
  p.precio,
  p.stock,
  p.bajo_pedido
from public.productos p
where p.codigo_barras in (
  '3337875816809',
  '3337875696548',
  '3337875583626',
  '3337875543248',
  '3337871330286',
  '3499320012850',
  '3499320015530',
  '8470001724137',
  '3701129812075',
  '3401399277092',
  '3337875597388',
  '3282776385421',
  '3282776382109',
  '8470002094857',
  '3661434004735',
  '3282770073577',
  '8470001541871',
  '4005800164361',
  '8431166181418',
  '8429979444448',
  '3504105025878'
)
order by p.marca, p.nombre;
