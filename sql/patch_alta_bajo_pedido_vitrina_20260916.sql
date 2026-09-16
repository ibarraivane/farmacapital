-- ============================================================================
-- FARMA CAPITAL — Primer lote vitrina bajo pedido (/conseguir)
-- 16-sep-2026
--
-- ANTES: sql/patch_bajo_pedido_20260916.sql (columna + RPCs).
-- Pegar TODO en Supabase → SQL Editor → Run.
--
-- 26 SKUs. Ancla = precio público Nadro (ceil a peso) o precio oficial SVR MX.
-- Sin costo de compra. Stock 0. Sin lote ni caducidad.
--
-- Si el EAN ya existe CON stock de anaquel: no se marca bajo_pedido.
-- Si existe SIN stock: se marca y se completa foto/marca si faltan.
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

create temp table _fc_vitrina_bp (
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

insert into _fc_vitrina_bp values
  ('3337872411991', 'FC-72411991', 'La Roche-Posay Effaclar Gel Limpiador Facial 400 ml', 'La Roche-Posay', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 538::numeric, 'https://nadro.vtexassets.com/arquivos/ids/164747/3337872411991_01.jpg', 'Nadro i22 · GEL EFFACLAR LIMP FACI 400ML · precio público $537.16'),
  ('3337875722827', 'FC-75722827', 'La Roche-Posay Effaclar Ultra Sérum Anti-Imperfecciones 30 ml', 'La Roche-Posay', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 706::numeric, 'https://nadro.vtexassets.com/arquivos/ids/206739/3337875722827_01.jpg', 'Nadro i22 · SERUM EFFACLAR ULTRA A-IMPE 30ML · precio público $705.25'),
  ('3337875863377', 'FC-75863377', 'La Roche-Posay Effaclar Duo+ M Anti-Imperfecciones 40 ml', 'La Roche-Posay', '40 ml', 'Cuidado personal', 'Dermatología', 'Crema', 605::numeric, 'https://www.farmacapital.mx/catalogo-propia/effaclar-duo-mas-40ml.jpg', 'Nadro i22 · CRA EFFACLAR DUO ANTI-IMPERF 40ML · foto Fahorro (Nadro traía genérica) · precio público $604.40'),
  ('3337875708289', 'FC-75708289', 'La Roche-Posay Effaclar Gel Micro-Exfoliante 400 ml', 'La Roche-Posay', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 591::numeric, 'https://nadro.vtexassets.com/arquivos/ids/174846/3337875708289_01.jpg', 'Nadro i22 · GEL EFFACLAR MICRO-EXFOL 400 ML · precio público $590.95'),
  ('8429420285644', 'FC-20285644', 'Isdin Fotoprotector Fusion Water Color Light 50 ml', 'Isdin', '50 ml', 'Cuidado personal', 'Dermatología', 'Fluido', 701::numeric, 'https://nadro.vtexassets.com/arquivos/ids/198699/8429420285644_01.jpg', 'Nadro i22 · Fusion Water Color Light · precio público $700.86'),
  ('8429420227590', 'FC-20227590', 'Isdin Acniben Facial Cleanser Gel 400 ml', 'Isdin', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 548::numeric, 'https://nadro.vtexassets.com/arquivos/ids/232554/8429420227590_01.jpg', 'Nadro i22 · Acniben Facial Cleanser Gel · precio público $547.40'),
  ('8470003245920', 'FC-03245920', 'Isdin Acniben Gel-Crema Brillos y Granos 40 ml', 'Isdin', '40 ml', 'Cuidado personal', 'Dermatología', 'Gel-crema', 662::numeric, 'https://nadro.vtexassets.com/arquivos/ids/216029/8470003245920_01.jpg', 'Nadro i22 · ISDIN GEL-CRA ACNIBE BRI-GRA 40ML · precio público $661.21'),
  ('3337875597197', 'FC-75597197', 'CeraVe Gel Limpiador Espumoso 236 ml', 'CeraVe', '236 ml', 'Cuidado personal', 'Dermatología', 'Gel', 309::numeric, 'https://nadro.vtexassets.com/arquivos/ids/167940/3337875597197_01.jpg', 'Nadro i22 · GEL LIMP CERAVE ESPUMOSO 236ML · precio público $308.67'),
  ('3337875923866', 'FC-75923866', 'CeraVe Limpiador Control Imperfecciones 473 ml', 'CeraVe', '473 ml', 'Cuidado personal', 'Dermatología', 'Gel', 422::numeric, 'https://nadro.vtexassets.com/arquivos/ids/230593/3337875923866_01.jpg', 'Nadro i22 · Limpiador Control Imperfecciones 473 ml · precio público $421.14'),
  ('4006000183572', 'FC-00183572', 'Eucerin Dermopure Clinical Gel Limpiador Purificante 400 ml', 'Eucerin', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 455::numeric, 'https://nadro.vtexassets.com/arquivos/ids/231023/4006000183572_01.jpg', 'Nadro i22 · Dermopure Clinical gel 400 ml · precio público $454.44'),
  ('3282770139204', 'FC-70139204', 'Avène Cleanance Gel Facial Sin Jabón 200 ml', 'Avène', '200 ml', 'Cuidado personal', 'Dermatología', 'Gel', 569::numeric, 'https://nadro.vtexassets.com/arquivos/ids/199024/3282770139204_01.jpg', 'Nadro i22 · AVENE CLEANAN GEL FAC S · ficha: Gel Facial Sin Jabón 200 ml · precio público $568.10'),
  ('3662361003402', 'FC-61003402', 'SVR Sebiaclear Gel Moussant 400 ml', 'SVR', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 913::numeric, 'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-gel-moussant-400ml.jpg', 'No está en Nadro. Ficha oficial mx.svr.com + EAN Puntopiel MX 3662361003402 · ancla $913 tienda SVR México'),
  ('3662361000364', 'FC-61000364', 'SVR Sebiaclear Sérum 30 ml', 'SVR', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1073::numeric, 'https://www.farmacapital.mx/catalogo-propia/svr-sebiaclear-serum-30ml.jpg', 'No está en Nadro. Ficha oficial mx.svr.com + EAN Halo Skin / WeCare 3662361000364 · ancla $1,072.50 tienda SVR México'),
  ('3664798064704', 'FC-98064704', 'Pharmaton Complete Kids Jarabe 100 ml', 'Pharmaton', '100 ml', 'Vitaminas', null, 'Jarabe', 312::numeric, 'https://nadro.vtexassets.com/arquivos/ids/218372/3664798064704_01.jpg', 'Nadro i22 · PHARMATON COMPLETE KIDS JBE 100MLN · precio público $311.60'),
  ('3664798027525', 'FC-98027525', 'Pharmaton Woman 50+ 750 mg 30 cápsulas', 'Pharmaton', '30 cápsulas', 'Vitaminas', null, 'Cápsula', 345::numeric, 'https://nadro.vtexassets.com/arquivos/ids/200308/3664798027525_01.jpg', 'Nadro i22 · PHARMATON WOM50+ 750MG S ALI 30CAPS · precio público $344.90'),
  ('7501008499177', 'FC-08499177', 'Elevit 2-Omegas 28 cápsulas', 'Elevit', '28 cápsulas', 'Vitaminas', null, 'Cápsula', 529::numeric, 'https://nadro.vtexassets.com/arquivos/ids/210119/7501008499177_01.jpg', 'Nadro i22 · ELEVIT 2-OMEGAS SUP ALIM 28CAPS · precio público $528.30'),
  ('7501008499580', 'FC-08499580', 'Elevit 3-Luteína 30 cápsulas', 'Elevit', '30 cápsulas', 'Vitaminas', null, 'Cápsula', 549::numeric, 'https://nadro.vtexassets.com/arquivos/ids/210147/7501008499580_01.jpg', 'Nadro i22 · ELEVIT 3-LUTEINA SUP ALIM 30 CAPS · precio público $548.81'),
  ('7501065004000', 'FC-65004000', 'Centrum Gender+50 Mujeres 60 tabletas', 'Centrum', '60 tabletas', 'Vitaminas', null, 'Tableta', 540::numeric, 'https://nadro.vtexassets.com/arquivos/ids/206660/7501065004000_01.jpg', 'Nadro i22 · CENTRUM GENDER+50 MUJER 60 TAB · precio público $539.76'),
  ('7501008409527', 'FC-08409527', 'Redoxon Ácido Ascórbico 1 g naranja 10 tabletas efervescentes', 'Redoxon', '10 tabletas', 'Vitaminas', null, 'Tableta efervescente', 160::numeric, 'https://nadro.vtexassets.com/arquivos/ids/210029/7501008409527_01.jpg', 'Nadro i22 · Redoxon 1 g naranja 10 tabletas · precio público $160.00'),
  ('7503006545177', 'FC-06545177', 'Solanum Omega 3 Salmón Salvaje Alaska 60 cápsulas', 'Solanum', '60 cápsulas', 'Suplemento', null, 'Cápsula', 235::numeric, 'https://nadro.vtexassets.com/arquivos/ids/200492/7503006545177_01.jpg', 'Nadro i22 · OMEGA 3 SALMON SALVAJE ALASK 60CAPS · precio público $234.21'),
  ('7503006073106', 'FC-06073106', 'Essential Omega 3 Forte 1000 mg 40 cápsulas', 'Essential', '40 cápsulas', 'Suplemento', null, 'Cápsula', 283::numeric, 'https://nadro.vtexassets.com/arquivos/ids/214889/7503006073106_01.jpg', 'Nadro i22 · OMEGA 3 FOR 1000MG S ALIM 40 CAPS · precio público $283.00'),
  ('7506241700813', 'FC-41700813', 'Essential Biotina 500 mg 30 cápsulas', 'Essential', '30 cápsulas', 'Suplemento', null, 'Cápsula', 203::numeric, 'https://nadro.vtexassets.com/arquivos/ids/215089/7506241700813_01.jpg', 'Nadro i22 · BIOTINA 500MG SUP ALIM 30 CAPS · precio público $203.00'),
  ('7501062910175', 'FC-62910175', 'Prowinner Proteína 90% chocolate 400 g', 'Prowinner', '400 g', 'Suplemento', 'Proteína', 'Polvo', 488::numeric, 'https://nadro.vtexassets.com/arquivos/ids/200567/7501062910175_01.jpg', 'Nadro i22 · PROTEINA 90% PROW S ALIM CHTE 400G · precio público $488.00'),
  ('7501062914531', 'FC-62914531', 'Pronat Proteína Vegetal vainilla 12 sobres de 30 g', 'Pronat', '12 × 30 g', 'Suplemento', 'Proteína', 'Polvo', 442::numeric, 'https://nadro.vtexassets.com/arquivos/ids/199238/7501062914531_01.jpg', 'Nadro i22 · Proteína Vegetal Pronat 12 sobres · precio público $442.00'),
  ('7501033956126', 'FC-33956126', 'Glucerna SR Vainilla 237 ml', 'Glucerna', '237 ml', 'Suplemento', null, 'Líquido', 65::numeric, 'https://nadro.vtexassets.com/arquivos/ids/159036/7501033956126_01.jpg', 'Nadro i22 · GLUCERNA SR VAINI 237 ML · precio público $64.87'),
  ('7501033956140', 'FC-33956140', 'Glucerna SR Fresa 237 ml', 'Glucerna', '237 ml', 'Suplemento', null, 'Líquido', 65::numeric, 'https://nadro.vtexassets.com/arquivos/ids/155757/7501033956140_01.jpg', 'Nadro i22 · GLUCERNA SR FSA 237 ML · precio público $64.87');

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
from _fc_vitrina_bp t
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
  from _fc_vitrina_bp t
 where (p.codigo_barras = t.ean or p.id = public.fc_buscar_producto_escaneo(t.ean))
   and coalesce(p.stock, 0) = 0;

insert into public.producto_imagenes (producto_id, url, posicion, es_principal, origen)
select p.id, t.imagen_url, 1, true, 'distribuidor'
  from _fc_vitrina_bp t
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
  p.categoria,
  p.subcategoria,
  p.precio,
  p.stock,
  p.bajo_pedido,
  left(p.imagen_url, 80) as imagen
from public.productos p
where p.codigo_barras in (
  '3337872411991',
  '3337875722827',
  '3337875863377',
  '3337875708289',
  '8429420285644',
  '8429420227590',
  '8470003245920',
  '3337875597197',
  '3337875923866',
  '4006000183572',
  '3282770139204',
  '3662361003402',
  '3662361000364',
  '3664798064704',
  '3664798027525',
  '7501008499177',
  '7501008499580',
  '7501065004000',
  '7501008409527',
  '7503006545177',
  '7503006073106',
  '7506241700813',
  '7501062910175',
  '7501062914531',
  '7501033956126',
  '7501033956140'
)
order by p.categoria, p.subcategoria nulls first, p.nombre;
