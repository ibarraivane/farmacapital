-- Google + Nadro/Farmatodo/Chedraui/Fahorro por EAN exacto (14-sep-2026)
-- Pegar DESPUÉS de patch_fotos_google_chedraui_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- Cada pieza se abrió. Foto = frente de la pieza que se vende.
-- Pide deploy de Vercel. No se toca codigo_barras.
--
-- No se usó: Pasta Lassar (Nadro solo costado legal);
-- Enterogermina Fahorro 4 billones ≠ 2 billones C/10;
-- Melox Plus / Evenflo / Loeffler / Xiomara pomada = generica_1;
-- Pantene 7501001303454 ≠ 7501001303464; Gerber 113 g ≠ 100 g;
-- Sico 7501685171113 ≠ 7501685171118; Aderogyl C/5 ≠ C/4 (sí hay C/4 Nadro).

begin;

update public.productos
set nombre = 'Aderogyl solución 3 ml C/4 ampolletas',
    marca = 'Aderogyl',
    presentacion = 'Caja con 4 ampolletas de 3 ml',
    descripcion = 'Aderogyl vitaminas A, C y D caja con 4 ampolletas de 3 ml'
where sku = 'FC-80596011';

update public.productos
set nombre = 'Pharmaton Complete 773 mg C/30',
    marca = 'Pharmaton',
    presentacion = 'Caja con 30 tabletas',
    descripcion = 'Pharmaton Complete ginseng G115 + vitaminas y minerales C/30'
where sku = 'FC-8062229';

update public.productos
set nombre = 'Dolo-Neurobión tabletas C/20',
    marca = 'Dolo-Neurobión',
    presentacion = 'Caja con 20 tabletas',
    descripcion = 'Dolo-Neurobión diclofenaco + complejo B C/20'
where sku = 'FC-98223704';

update public.productos
set nombre = 'Dolo-Neurobión DC 3 jeringas prellenadas 3 ml',
    marca = 'Dolo-Neurobión',
    presentacion = 'Caja con 3 jeringas prellenadas de 3 ml',
    descripcion = 'Dolo-Neurobión DC doble cámara C/3 jeringas 3 ml'
where sku = 'FC-98217659';

update public.productos
set nombre = 'Dolac ketorolaco 10 mg C/10 cápsulas',
    marca = 'Dolac',
    presentacion = 'Caja con 10 cápsulas',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '10 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Ketorolaco'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Cápsulas'),
    descripcion = 'Dolac ketorolaco 10 mg cápsulas C/10 Siegfried Rhein'
where sku = 'FC-30042152';

update public.productos
set nombre = 'Brunadol paracetamol/naproxeno 300/275 mg C/10',
    marca = 'Brunadol',
    presentacion = 'Caja con 10 tabletas',
    concentracion = coalesce(nullif(btrim(concentracion), ''), '300/275 mg'),
    principio_activo = coalesce(nullif(btrim(principio_activo), ''), 'Paracetamol / Naproxeno'),
    forma_farmaceutica = coalesce(nullif(btrim(forma_farmaceutica), ''), 'Tabletas'),
    descripcion = 'Brunadol 300/275 mg C/10 Bruluart'
where sku = 'FC-103521';

update public.productos
set nombre = 'Alli-Triple C/10 tabletas',
    marca = 'Alli-Triple',
    presentacion = 'Caja con 10 tabletas',
    descripcion = 'Alli-Triple diclofenaco + complejo B C/10'
where sku = 'FC-053610';

update public.productos
set nombre = 'Pepto-Bismol suspensión 118 ml',
    marca = 'Pepto-Bismol',
    presentacion = 'Frasco 118 ml',
    descripcion = 'Pepto-Bismol subsalicilato de bismuto suspensión 118 ml'
where sku = 'FC-00753067';

update public.productos
set nombre = 'Alka-Seltzer efervescente C/100',
    marca = 'Alka-Seltzer',
    presentacion = 'Caja con 100 tabletas efervescentes',
    descripcion = 'Alka-Seltzer efervescente C/100'
where sku = 'FC-08443026';

update public.productos
set nombre = 'Alka-Seltzer Boost C/10',
    marca = 'Alka-Seltzer',
    presentacion = 'Caja con 10 tabletas efervescentes',
    descripcion = 'Alka-Seltzer Boost efervescente C/10'
where sku = 'FC-8497593';

update public.productos
set nombre = 'Bronco Rub ungüento 40 g',
    marca = 'Bronco Rub',
    presentacion = 'Tarro 40 g',
    descripcion = 'Bronco Rub ungüento descongestionante 40 g'
where sku = 'FC-50003314';

update public.productos
set nombre = 'Suerox Vitamins Defense Naranja Mango 630 ml',
    marca = 'Suerox',
    presentacion = 'Botella 630 ml',
    descripcion = 'Suerox Vitamins Defense naranja-mango 630 ml'
where sku = 'FC-00721471';

update public.productos
set nombre = 'Rexona Men Marine spray 150 ml',
    marca = 'Rexona',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Rexona Men Marine antitranspirante spray 150 ml'
where sku = 'FC-93037806';

update public.productos
set nombre = 'Rexona Men Sport spray 150 ml',
    marca = 'Rexona',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Rexona Men Sport antitranspirante spray 150 ml'
where sku = 'FC-93038223';

update public.productos
set nombre = 'Rexona Men V8 spray 90 g',
    marca = 'Rexona',
    presentacion = 'Aerosol 90 g / 150 ml',
    descripcion = 'Rexona Men V8 antitranspirante spray 90 g'
where sku = 'FC-93022567';

update public.productos
set nombre = 'Axe Excite spray 152 ml',
    marca = 'Axe',
    presentacion = 'Aerosol 152 ml',
    descripcion = 'Axe Excite antitranspirante spray 152 ml'
where sku = 'FC-93025919';

update public.productos
set nombre = 'Axe Dark Temptation spray 150 ml',
    marca = 'Axe',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Axe Dark Temptation desodorante spray 150 ml'
where sku = 'FC-93025797';

update public.productos
set nombre = 'Axe Gold Temptation spray 150 ml',
    marca = 'Axe',
    presentacion = 'Aerosol 150 ml',
    descripcion = 'Axe Gold Temptation desodorante spray 150 ml'
where sku = 'FC-93025865';

update public.productos
set nombre = 'Rexona Bamboo stick 45 g',
    marca = 'Rexona',
    presentacion = 'Barra 45 g',
    descripcion = 'Rexona Bamboo & Aloe Vera stick 45 g'
where sku = 'FC-75062897';

update public.productos
set nombre = 'Rexona Powder Dry stick 45 g',
    marca = 'Rexona',
    presentacion = 'Barra 45 g',
    descripcion = 'Rexona Powder Dry stick 45 g'
where sku = 'FC-75062927';

update public.productos
set nombre = 'Rexona Happy Morning stick 45 g',
    marca = 'Rexona',
    presentacion = 'Barra 45 g',
    descripcion = 'Rexona Happy Morning stick 45 g'
where sku = 'FC-75076009';

update public.productos
set nombre = 'Listerine Cuidado Total Zero 250 ml',
    marca = 'Listerine',
    presentacion = 'Botella 250 ml',
    descripcion = 'Listerine Cuidado Total Zero alcohol 250 ml'
where sku = 'FC-31887928';

update public.productos
set nombre = 'Listerine Anticaries Zero 250 ml',
    marca = 'Listerine',
    presentacion = 'Botella 250 ml',
    descripcion = 'Listerine Anticaries Zero alcohol 250 ml'
where sku = 'FC-31976394';

update public.productos
set nombre = 'Listerine Cool Mint Zero 250 ml',
    marca = 'Listerine',
    presentacion = 'Botella 250 ml',
    descripcion = 'Listerine Cool Mint Zero alcohol 250 ml'
where sku = 'FC-10974329';

update public.productos
set nombre = 'Oral-B Complete 4 en 1 250 ml',
    marca = 'Oral-B',
    presentacion = 'Botella 250 ml',
    descripcion = 'Oral-B Complete menta refrescante enjuague 250 ml'
where sku = 'FC-51037878';

update public.productos
set nombre = 'Sensodyne Protección Completa 90 g',
    marca = 'Sensodyne',
    presentacion = 'Tubo 90 g',
    descripcion = 'Sensodyne Protección Completa pasta dental 90 g'
where sku = 'FC-09498091';

update public.productos
set nombre = 'Sensodyne Rápido Alivio 100 g',
    marca = 'Sensodyne',
    presentacion = 'Tubo 100 g',
    descripcion = 'Sensodyne Rápido Alivio pasta dental 100 g'
where sku = 'FC-40171550';

update public.productos
set nombre = 'Nivea Facial 5 en 1 Cuidado Tono Natural 200 ml',
    marca = 'Nivea',
    presentacion = 'Tarro 200 ml',
    descripcion = 'Nivea Facial 5 en 1 Cuidado Tono Natural 200 ml (EAN 42270027; el ticket decía 7 en 1)'
where sku = 'FC-42270027';

update public.productos
set nombre = 'Kleenex Sellapack 15 pañuelos',
    marca = 'Kleenex',
    presentacion = 'Paquetes de 15 pañuelos',
    descripcion = 'Kleenex Sellapack pañuelos faciales 15 hojas (EAN del pack 8×15)'
where sku = 'FC-73629981';

update public.productos
set nombre = 'Huggies toallitas húmedas Cuidado Hidratante C/80',
    marca = 'Huggies',
    presentacion = 'Paquete con 80 toallitas',
    descripcion = 'Huggies toallitas húmedas Cuidado Hidratante C/80'
where sku = 'FC-43454743';

update public.productos
set nombre = 'Diapro pañal adulto mediano C/10',
    marca = 'Diapro',
    presentacion = 'Paquete con 10 pañales talla mediana',
    descripcion = 'Diapro pañal adulto mediano C/10'
where sku = 'FC-16800803';

update public.productos
set nombre = 'Curitas Transpiel C/100',
    marca = 'Curitas',
    presentacion = 'Caja con 100 apósitos',
    descripcion = 'Curitas Transpiel resistentes al agua C/100'
where sku = 'FC-03476594';

update public.productos
set nombre = 'Nivea Milk Nutritiva 400 ml + 100 ml',
    marca = 'Nivea',
    presentacion = '400 ml + 100 ml',
    descripcion = 'Nivea Milk Nutritiva crema corporal 400 ml + 100 ml (EAN del combo)'
where sku = 'FC-54558682';

update public.productos
set nombre = 'Xiomara Wax & Shine Classic 60 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 60 g',
    descripcion = 'Xiomara Wax & Shine cera modeladora classic 60 g'
where sku = 'FC-46501100';

update public.productos
set nombre = 'Xiomara Wax & Shine Telaraña 60 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 60 g',
    descripcion = 'Xiomara Wax & Shine cera telaraña 60 g'
where sku = 'FC-46504569';

update public.productos
set nombre = 'Xiomara Elastik Wax telaraña 100 g',
    marca = 'Xiomara',
    presentacion = 'Tarro 100 g',
    descripcion = 'Xiomara Elastik Wax cera telaraña 100 g'
where sku = 'FC-46506198';

update public.productos
set nombre = 'Palmolive brillantina aceite de oliva 115 ml',
    marca = 'Palmolive',
    presentacion = 'Frasco 115 ml',
    descripcion = 'Palmolive brillantina con aceite de oliva 115 ml'
where sku = 'FC-75001865';

update public.productos
set nombre = 'Honey Keeper Kids Oatmeal & Honey loción 414 ml',
    marca = 'Honey Keeper',
    presentacion = 'Frasco 414 ml',
    descripcion = 'The Honeykeeper Kids body lotion avena y miel 414 ml'
where sku = 'FC-67917516';

update public.productos
set nombre = 'GUM hilo dental menta 129 m',
    marca = 'GUM',
    presentacion = 'Estuche 129 m',
    descripcion = 'GUM hilo dental encerado sabor menta 129 m'
where sku = 'FC-42303194';

update public.productos
set nombre = 'Savilé bicarbonato y limón roll-on 45 ml',
    marca = 'Savilé',
    presentacion = 'Roll-on 45 ml',
    descripcion = 'Savilé antitranspirante sábila, bicarbonato y limón roll-on 45 ml'
where sku = 'FC-75068622';

update public.productos
set nombre = 'Colgate Premier Clean cepillo dental',
    marca = 'Colgate',
    presentacion = '1 pieza',
    descripcion = 'Colgate Premier Clean cepillo dental 1 pieza'
where sku = 'FC-007206';

create temporary table tmp_foto_ean (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_ean (sku, url, origen)
values
  ('FC-80596011', 'https://www.farmacapital.mx/catalogo-propia/aderogyl-c4-ampolletas.jpg', 'propia'),
  ('FC-8062229', 'https://www.farmacapital.mx/catalogo-propia/pharmaton-complete-c30.jpg', 'propia'),
  ('FC-98223704', 'https://www.farmacapital.mx/catalogo-propia/dolo-neurobion-20-tab.jpg', 'propia'),
  ('FC-98217659', 'https://www.farmacapital.mx/catalogo-propia/dolo-neurobion-dc-c3.jpg', 'propia'),
  ('FC-30042152', 'https://www.farmacapital.mx/catalogo-propia/dolac-ketorolaco-10mg-c10.jpg', 'propia'),
  ('FC-103521', 'https://www.farmacapital.mx/catalogo-propia/brunadol-300-275-c10.jpg', 'propia'),
  ('FC-053610', 'https://www.farmacapital.mx/catalogo-propia/alli-triple-c10.jpg', 'propia'),
  ('FC-00753067', 'https://www.farmacapital.mx/catalogo-propia/pepto-bismol-118ml.jpg', 'propia'),
  ('FC-08443026', 'https://www.farmacapital.mx/catalogo-propia/alka-seltzer-c100.jpg', 'propia'),
  ('FC-8497593', 'https://www.farmacapital.mx/catalogo-propia/alka-seltzer-boost-c10.jpg', 'propia'),
  ('FC-50003314', 'https://www.farmacapital.mx/catalogo-propia/bronco-rub-40g.jpg', 'propia'),
  ('FC-00721471', 'https://www.farmacapital.mx/catalogo-propia/suerox-vitamins-naranja-mango-630ml.jpg', 'propia'),
  ('FC-93037806', 'https://www.farmacapital.mx/catalogo-propia/rexona-men-marine-spray-150ml.jpg', 'propia'),
  ('FC-93038223', 'https://www.farmacapital.mx/catalogo-propia/rexona-men-sport-spray-150ml.jpg', 'propia'),
  ('FC-93022567', 'https://www.farmacapital.mx/catalogo-propia/rexona-men-v8-spray-90g.jpg', 'propia'),
  ('FC-93025919', 'https://www.farmacapital.mx/catalogo-propia/axe-excite-spray-152ml.jpg', 'propia'),
  ('FC-93025797', 'https://www.farmacapital.mx/catalogo-propia/axe-dark-temptation-spray-150ml.jpg', 'propia'),
  ('FC-93025865', 'https://www.farmacapital.mx/catalogo-propia/axe-gold-temptation-spray-150ml.jpg', 'propia'),
  ('FC-75062897', 'https://www.farmacapital.mx/catalogo-propia/rexona-bamboo-stick-45g.jpg', 'propia'),
  ('FC-75062927', 'https://www.farmacapital.mx/catalogo-propia/rexona-powder-dry-stick-45g.jpg', 'propia'),
  ('FC-75076009', 'https://www.farmacapital.mx/catalogo-propia/rexona-happy-morning-stick-45g.jpg', 'propia'),
  ('FC-31887928', 'https://www.farmacapital.mx/catalogo-propia/listerine-cuidado-total-250ml.jpg', 'propia'),
  ('FC-31976394', 'https://www.farmacapital.mx/catalogo-propia/listerine-anticaries-250ml.jpg', 'propia'),
  ('FC-10974329', 'https://www.farmacapital.mx/catalogo-propia/listerine-cool-mint-250ml.jpg', 'propia'),
  ('FC-51037878', 'https://www.farmacapital.mx/catalogo-propia/oralb-complete-250ml.jpg', 'propia'),
  ('FC-09498091', 'https://www.farmacapital.mx/catalogo-propia/sensodyne-proteccion-completa-90g.jpg', 'propia'),
  ('FC-40171550', 'https://www.farmacapital.mx/catalogo-propia/sensodyne-rapido-alivio-100g.jpg', 'propia'),
  ('FC-42270027', 'https://www.farmacapital.mx/catalogo-propia/nivea-facial-5en1-tono-natural-200ml.jpg', 'propia'),
  ('FC-73629981', 'https://www.farmacapital.mx/catalogo-propia/kleenex-sellapack-15.jpg', 'propia'),
  ('FC-43454743', 'https://www.farmacapital.mx/catalogo-propia/huggies-toallitas-80.jpg', 'propia'),
  ('FC-16800803', 'https://www.farmacapital.mx/catalogo-propia/diapro-mediano-c10.jpg', 'propia'),
  ('FC-03476594', 'https://www.farmacapital.mx/catalogo-propia/curitas-transpiel-100.jpg', 'propia'),
  ('FC-54558682', 'https://www.farmacapital.mx/catalogo-propia/nivea-milk-400ml-100ml.jpg', 'propia'),
  ('FC-46501100', 'https://www.farmacapital.mx/catalogo-propia/xiomara-cera-wax-shine-classic-60g.jpg', 'propia'),
  ('FC-46504569', 'https://www.farmacapital.mx/catalogo-propia/xiomara-cera-telarana-60g.jpg', 'propia'),
  ('FC-46506198', 'https://www.farmacapital.mx/catalogo-propia/xiomara-elastik-telarana-100g.jpg', 'propia'),
  ('FC-75001865', 'https://www.farmacapital.mx/catalogo-propia/palmolive-brillantina-115ml.jpg', 'propia'),
  ('FC-67917516', 'https://www.farmacapital.mx/catalogo-propia/honeykeeper-kids-oat-honey-414ml.jpg', 'propia'),
  ('FC-42303194', 'https://www.farmacapital.mx/catalogo-propia/gum-hilo-dental-129m.jpg', 'propia'),
  ('FC-75068622', 'https://www.farmacapital.mx/catalogo-propia/savile-bicarbonato-limon-rollon-45ml.jpg', 'propia'),
  ('FC-007206', 'https://www.farmacapital.mx/catalogo-propia/colgate-premier-clean.jpg', 'propia');

create temporary table tmp_foto_ean_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_ean_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_ean m on p.sku = m.sku
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_ean_match m
where p.id = m.producto_id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_ean_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_ean_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_ean_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_ean_match)
  and i.url in (select url from tmp_foto_ean_match)
  and not i.es_principal;

commit;
