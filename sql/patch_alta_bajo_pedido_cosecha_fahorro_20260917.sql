-- ============================================================================
-- FARMA CAPITAL — cosecha Fahorro vitrina bajo pedido 2026-09-17
-- Generado por scripts/alta-bajo-pedido-desde-fichas.js
-- 80 SKU(s). Stock 0. Sin lote ni caducidad.
-- Si el EAN ya existe CON stock: no se marca bajo_pedido.
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
  ('3337875921336', 'FC-75921336', 'La Roche Posay Toleriane Dermallergo Serum 30 ml', 'La Roche-Posay', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1004::numeric, 'https://www.farmacapital.mx/catalogo-propia/la-roche-posay-3337875921336.jpg', 'Fahorro GraphQL · búsqueda «la roche posay» · SKU=EAN 3337875921336 · lista $1004'),
  ('8470003808576', 'FC-03808576', 'Isdin Ureadin Crema Facial 50Ml', 'Isdin', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 564::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-8470003808576.jpg', 'Fahorro GraphQL · búsqueda «isdin» · SKU=EAN 8470003808576 · lista $564'),
  ('8470001776211', 'FC-01776211', 'Heliocare 360° 500 Mg Suplemento Alimenticio 30 Cápsulas', 'Heliocare', '30 cápsulas', 'Cuidado personal', 'Dermatología', 'Cápsula', 911::numeric, 'https://www.farmacapital.mx/catalogo-propia/heliocare-8470001776211.jpg', 'Fahorro GraphQL · búsqueda «heliocare» · SKU=EAN 8470001776211 · lista $911'),
  ('8429979201058', 'FC-79201058', 'Sesderma Serum Acglicolic 30 ml', 'Sesderma', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1250::numeric, 'https://www.farmacapital.mx/catalogo-propia/sesderma-8429979201058.jpg', 'Fahorro GraphQL · búsqueda «sesderma» · SKU=EAN 8429979201058 · lista $1250'),
  ('3337875782357', 'FC-75782357', 'CeraVe Blemish Control Gel 40 ml', 'CeraVe', '40 ml', 'Cuidado personal', 'Dermatología', 'Gel', 537::numeric, 'https://www.farmacapital.mx/catalogo-propia/cerave-3337875782357.jpg', 'Fahorro GraphQL · búsqueda «cerave» · SKU=EAN 3337875782357 · lista $537'),
  ('3701129802076', 'FC-29802076', 'Bioderma Atoderm Intensive Bálsamo 500 ml', 'Bioderma', '500 ml', 'Cuidado personal', 'Dermatología', null, 830::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-3701129802076.jpg', 'Fahorro GraphQL · búsqueda «bioderma» · SKU=EAN 3701129802076 · lista $830'),
  ('3282770396881', 'FC-70396881', 'Avène Leche Solar Adulto 250 ml', 'Avène', '250 ml', 'Cuidado personal', 'Dermatología', null, 753::numeric, 'https://www.farmacapital.mx/catalogo-propia/avene-3282770396881.jpg', 'Fahorro GraphQL · búsqueda «avene» · SKU=EAN 3282770396881 · lista $753'),
  ('3282770389234', 'FC-70389234', 'Ducray Melascreen Contorno de Ojos 15 ml', 'Ducray', '15 ml', 'Cuidado personal', 'Dermatología', null, 948::numeric, 'https://www.farmacapital.mx/catalogo-propia/ducray-3282770389234.jpg', 'Fahorro GraphQL · búsqueda «ducray» · SKU=EAN 3282770389234 · lista $948'),
  ('3661434009204', 'FC-34009204', 'Uriage Agua Micelar Piel Sensible 100Ml', 'Uriage', '100 ml', 'Cuidado personal', 'Dermatología', null, 169::numeric, 'https://www.farmacapital.mx/catalogo-propia/uriage-3661434009204.jpg', 'Fahorro GraphQL · búsqueda «uriage» · SKU=EAN 3661434009204 · lista $169'),
  ('3282770393712', 'FC-70393712', 'A-Derma Epitheliale Ultra Repair Bálsamo 50 g', 'A-Derma', '50 g', 'Cuidado personal', 'Dermatología', null, 372::numeric, 'https://www.farmacapital.mx/catalogo-propia/a-derma-3282770393712.jpg', 'Fahorro GraphQL · búsqueda «a-derma» · SKU=EAN 3282770393712 · lista $372'),
  ('4006000077000', 'FC-00077000', 'Eucerin Epigenetic Serum facial Anti-edad 30 ml', 'Eucerin', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1434::numeric, 'https://www.farmacapital.mx/catalogo-propia/eucerin-4006000077000.jpg', 'Fahorro GraphQL · búsqueda «a-derma» · SKU=EAN 4006000077000 · lista $1434'),
  ('8436574360844', 'FC-74360844', 'Endocare Hydractive Micelar 400 ml', 'Endocare', '400 ml', 'Cuidado personal', 'Dermatología', null, 556::numeric, 'https://www.farmacapital.mx/catalogo-propia/endocare-8436574360844.jpg', 'Fahorro GraphQL · búsqueda «endocare» · SKU=EAN 8436574360844 · lista $556'),
  ('7501089804525', 'FC-89804525', 'Leti At4 Leche Corporal 250 ml', 'Leti', '250 ml', 'Cuidado personal', 'Dermatología', null, 828::numeric, 'https://www.farmacapital.mx/catalogo-propia/leti-7501089804525.jpg', 'Fahorro GraphQL · búsqueda «leti at4» · SKU=EAN 7501089804525 · lista $828'),
  ('3337875908368', 'FC-75908368', 'Vichy Refill Booster M89 50 ml', 'Vichy', '50 ml', 'Cuidado personal', 'Dermatología', null, 749::numeric, 'https://www.farmacapital.mx/catalogo-propia/vichy-3337875908368.jpg', 'Fahorro GraphQL · búsqueda «vichy» · SKU=EAN 3337875908368 · lista $749'),
  ('7897930778634', 'FC-30778634', 'Cetaphil Oil Control Hidratante Facial Matificante Antimanchas 89 ml', 'Cetaphil', '89 ml', 'Cuidado personal', 'Dermatología', null, 613::numeric, 'https://www.farmacapital.mx/catalogo-propia/cetaphil-7897930778634.jpg', 'Fahorro GraphQL · búsqueda «cetaphil» · SKU=EAN 7897930778634 · lista $613'),
  ('3504105032937', 'FC-05032937', 'Mustela Cicastela Crema Reparadora 40 ml', 'Mustela', '40 ml', 'Cuidado personal', 'Dermatología', 'Crema', 244::numeric, 'https://www.farmacapital.mx/catalogo-propia/mustela-3504105032937.jpg', 'Fahorro GraphQL · búsqueda «mustela» · SKU=EAN 3504105032937 · lista $244'),
  ('7503025737386', 'FC-25737386', 'BIRDMAN Minerales 300ml', 'Birdman', '300 ml', 'Suplemento', null, null, 431::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-7503025737386.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503025737386 · lista $431'),
  ('7503057040362', 'FC-57040362', 'Falcon Proteina Chocolate 480 g', 'Falcon', '480 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 600::numeric, 'https://www.farmacapital.mx/catalogo-propia/falcon-7503057040362.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503057040362 · lista $600'),
  ('748927051254', 'FC-27051254', 'Optimum Nutrition Gold Standard Proteína Whey Sabor Chocolate 907 gr', 'Optimum Nutrition', '907 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 1253::numeric, 'https://www.farmacapital.mx/catalogo-propia/optimum-nutrition-748927051254.jpg', 'Fahorro GraphQL · búsqueda «optimum nutrition gold standard» · SKU=EAN 748927051254 · lista $1253'),
  ('073796801212', 'FC-96801212', 'Omron Nebulizador con Compresor Modelo Ne-C801', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 1231::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796801212.jpg', 'Fahorro GraphQL · búsqueda «nebulizador» · SKU=EAN 073796801212 · lista $1231'),
  ('7503012700065', 'FC-12700065', 'Nebulizador Nebucor N-102 portátil silencioso de pistón - fácil de usar', 'Nebucor', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 980::numeric, 'https://www.farmacapital.mx/catalogo-propia/nebucor-7503012700065.jpg', 'Fahorro GraphQL · búsqueda «nebulizador» · SKU=EAN 7503012700065 · lista $980'),
  ('7500399003154', 'FC-99003154', 'HANDY Nebulizador de Pistón', 'Handy', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 1065::numeric, 'https://www.farmacapital.mx/catalogo-propia/handy-7500399003154.jpg', 'Fahorro GraphQL · búsqueda «nebulizador» · SKU=EAN 7500399003154 · lista $1065'),
  ('4015630082988', 'FC-30082988', 'Accu-Chek Active Glucómetro', 'Accu-Chek', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 623::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-4015630082988.jpg', 'Fahorro GraphQL · búsqueda «glucometro» · SKU=EAN 4015630082988 · lista $623'),
  ('3337875892872', 'FC-75892872', 'La Roche-Posay Pure Vitamin C12 Oil Control Serum 30ml', 'La Roche-Posay', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1426::numeric, 'https://www.farmacapital.mx/catalogo-propia/la-roche-posay-3337875892872.jpg', 'Fahorro GraphQL · búsqueda «la roche posay» · SKU=EAN 3337875892872 · lista $1426'),
  ('8470001507983', 'FC-01507983', 'ISDIN Reparador Labial 10 ml', 'Isdin', '10 ml', 'Cuidado personal', 'Dermatología', null, 190::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-8470001507983.jpg', 'Fahorro GraphQL · búsqueda «isdin» · SKU=EAN 8470001507983 · lista $190'),
  ('8436574364460', 'FC-74364460', 'Heliocare 360° Acnimat FPS 50+ 50 ml', 'Heliocare', '50 ml', 'Cuidado personal', 'Dermatología', null, 745::numeric, 'https://www.farmacapital.mx/catalogo-propia/heliocare-8436574364460.jpg', 'Fahorro GraphQL · búsqueda «heliocare» · SKU=EAN 8436574364460 · lista $745'),
  ('8470002259539', 'FC-02259539', 'Sesderma Azelac Loción 100 ml', 'Sesderma', '100 ml', 'Cuidado personal', 'Dermatología', 'Loción', 544::numeric, 'https://www.farmacapital.mx/catalogo-propia/sesderma-8470002259539.jpg', 'Fahorro GraphQL · búsqueda «sesderma» · SKU=EAN 8470002259539 · lista $544'),
  ('3337875795456', 'FC-75795456', 'Cerave SA Limpiador Anti-rugosidades 473ml', 'CeraVe', '473 ml', 'Cuidado personal', 'Dermatología', null, 604::numeric, 'https://www.farmacapital.mx/catalogo-propia/cerave-3337875795456.jpg', 'Fahorro GraphQL · búsqueda «cerave» · SKU=EAN 3337875795456 · lista $604'),
  ('3701129802069', 'FC-29802069', 'Bioderma Atoderm Intensive Bálsamo 200 ml', 'Bioderma', '200 ml', 'Cuidado personal', 'Dermatología', null, 598::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-3701129802069.jpg', 'Fahorro GraphQL · búsqueda «bioderma» · SKU=EAN 3701129802069 · lista $598'),
  ('3282770396317', 'FC-70396317', 'Avène Spray Solar Niños FPS 50+ 200 ml', 'Avène', '200 ml', 'Cuidado personal', 'Dermatología', null, 804::numeric, 'https://www.farmacapital.mx/catalogo-propia/avene-3282770396317.jpg', 'Fahorro GraphQL · búsqueda «avene» · SKU=EAN 3282770396317 · lista $804'),
  ('3282779368612', 'FC-79368612', 'Ducray Keracnyl PP+ 30 ml', 'Ducray', '30 ml', 'Cuidado personal', 'Dermatología', null, 972::numeric, 'https://www.farmacapital.mx/catalogo-propia/ducray-3282779368612.jpg', 'Fahorro GraphQL · búsqueda «ducray» · SKU=EAN 3282779368612 · lista $972'),
  ('3661434005503', 'FC-34005503', 'Uriage Mascarilla De Noche Con Agua Termal 50Ml', 'Uriage', '50 ml', 'Cuidado personal', 'Dermatología', null, 615::numeric, 'https://www.farmacapital.mx/catalogo-propia/uriage-3661434005503.jpg', 'Fahorro GraphQL · búsqueda «uriage» · SKU=EAN 3661434005503 · lista $615'),
  ('3282771057392', 'FC-71057392', 'A-Derma Dermalibour+ Cica-Crema Calmante Reparadora 50 ml', 'A-Derma', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 408::numeric, 'https://www.farmacapital.mx/catalogo-propia/a-derma-3282771057392.jpg', 'Fahorro GraphQL · búsqueda «a-derma» · SKU=EAN 3282771057392 · lista $408'),
  ('4005900436979', 'FC-00436979', 'Eucerine Dermopure Crema Facial de Noche 40 ml', 'Eucerin', '40 ml', 'Cuidado personal', 'Dermatología', 'Crema', 865::numeric, 'https://www.farmacapital.mx/catalogo-propia/eucerin-4005900436979.jpg', 'Fahorro GraphQL · búsqueda «eucerin» · SKU=EAN 4005900436979 · lista $865'),
  ('8470001529688', 'FC-01529688', 'Endocare Tensage Suero 30 ml', 'Endocare', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1116::numeric, 'https://www.farmacapital.mx/catalogo-propia/endocare-8470001529688.jpg', 'Fahorro GraphQL · búsqueda «endocare» · SKU=EAN 8470001529688 · lista $1116'),
  ('7501089804433', 'FC-89804433', 'Leti At4 Intensive 1 Crema 100 ml', 'Leti', '100 ml', 'Cuidado personal', 'Dermatología', 'Crema', 664::numeric, 'https://www.farmacapital.mx/catalogo-propia/leti-7501089804433.jpg', 'Fahorro GraphQL · búsqueda «leti at4» · SKU=EAN 7501089804433 · lista $664'),
  ('3337875920971', 'FC-75920971', 'Vichy Dercos Collagen 17 Acondicionador 200 ml', 'Vichy', '200 ml', 'Cuidado personal', 'Dermatología', null, 694::numeric, 'https://www.farmacapital.mx/catalogo-propia/vichy-3337875920971.jpg', 'Fahorro GraphQL · búsqueda «vichy» · SKU=EAN 3337875920971 · lista $694'),
  ('7640203240242', 'FC-03240242', 'Cetaphil Exfoliante Ultra Suave 178 ml', 'Cetaphil', '178 ml', 'Cuidado personal', 'Dermatología', null, 374::numeric, 'https://www.farmacapital.mx/catalogo-propia/cetaphil-7640203240242.jpg', 'Fahorro GraphQL · búsqueda «cetaphil» · SKU=EAN 7640203240242 · lista $374'),
  ('3504108090743', 'FC-08090743', 'Mustela Jabon Natural Facial y Corporal Piel Normal 100 g', 'Mustela', '100 g', 'Cuidado personal', 'Dermatología', null, 102::numeric, 'https://www.farmacapital.mx/catalogo-propia/mustela-3504108090743.jpg', 'Fahorro GraphQL · búsqueda «mustela» · SKU=EAN 3504108090743 · lista $102'),
  ('7503053835191', 'FC-53835191', 'Birdman Creatina Monohidratada 125 Caps', 'Birdman', '125 cápsulas', 'Suplemento', 'Nutrición deportiva', 'Cápsula', 402::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-7503053835191.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503053835191 · lista $402'),
  ('7503057040539', 'FC-57040539', 'Falcon Performance Vainilla 552 g', 'Falcon', '552 g', 'Suplemento', 'Nutrición deportiva', null, 600::numeric, 'https://www.farmacapital.mx/catalogo-propia/falcon-7503057040539.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503057040539 · lista $600'),
  ('748927068023', 'FC-27068023', 'Optimum Nutrition Gold Standard 100% Plant Protein Vainilla 444 gr', 'Optimum Nutrition', '444 g', 'Suplemento', 'Nutrición deportiva', null, 635::numeric, 'https://www.farmacapital.mx/catalogo-propia/optimum-nutrition-748927068023.jpg', 'Fahorro GraphQL · búsqueda «optimum nutrition gold standard» · SKU=EAN 748927068023 · lista $635'),
  ('073796451011', 'FC-96451011', 'Omron Nebulizador de Compresor Ne-C101', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 1133::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796451011.jpg', 'Fahorro GraphQL · búsqueda «nebulizador» · SKU=EAN 073796451011 · lista $1133'),
  ('7503012700034', 'FC-12700034', 'Baumanómetro Digital de muñeca Nebucor HL-158 - monitor de presión arterial', 'Nebucor', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 625::numeric, 'https://www.farmacapital.mx/catalogo-propia/nebucor-7503012700034.jpg', 'Fahorro GraphQL · búsqueda «omron» · SKU=EAN 7503012700034 · lista $625'),
  ('7500399003215', 'FC-99003215', 'Micronebulizador Adulto Handy', 'Handy', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 199::numeric, 'https://www.farmacapital.mx/catalogo-propia/handy-7500399003215.jpg', 'Fahorro GraphQL · búsqueda «nebulizador» · SKU=EAN 7500399003215 · lista $199'),
  ('4015630066834', 'FC-30066834', 'Accu-Chek Guide Tiras 25', 'Accu-Chek', '25 tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 244::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-4015630066834.jpg', 'Fahorro GraphQL · búsqueda «glucometro» · SKU=EAN 4015630066834 · lista $244'),
  ('3337875725897', 'FC-75725897', 'La Roche Posay Agua Micelar Ultra en Aceite Bifásica 400 ml', 'La Roche-Posay', '400 ml', 'Cuidado personal', 'Dermatología', null, 885::numeric, 'https://www.farmacapital.mx/catalogo-propia/la-roche-posay-3337875725897.jpg', 'Fahorro GraphQL · búsqueda «la roche posay» · SKU=EAN 3337875725897 · lista $885'),
  ('8429420251366', 'FC-20251366', 'Isdin Ureadin Lotion 10 400Ml', 'Isdin', '400 ml', 'Cuidado personal', 'Dermatología', null, 563::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-8429420251366.jpg', 'Fahorro GraphQL · búsqueda «isdin» · SKU=EAN 8429420251366 · lista $563'),
  ('8470001592453', 'FC-01592453', 'Heliocare 360° Advanced Gel FPS 50+ 250 ml', 'Heliocare', '250 ml', 'Cuidado personal', 'Dermatología', 'Gel', 809::numeric, 'https://www.farmacapital.mx/catalogo-propia/heliocare-8470001592453.jpg', 'Fahorro GraphQL · búsqueda «heliocare» · SKU=EAN 8470001592453 · lista $809'),
  ('8470002073241', 'FC-02073241', 'Sesderma Azelac Gel Hidratante 50 ml', 'Sesderma', '50 ml', 'Cuidado personal', 'Dermatología', 'Gel', 905::numeric, 'https://www.farmacapital.mx/catalogo-propia/sesderma-8470002073241.jpg', 'Fahorro GraphQL · búsqueda «sesderma» · SKU=EAN 8470002073241 · lista $905'),
  ('3337875684118', 'FC-75684118', 'Cerave SA Limpiador Anti-rugosidades 236ml', 'CeraVe', '236 ml', 'Cuidado personal', 'Dermatología', null, 464::numeric, 'https://www.farmacapital.mx/catalogo-propia/cerave-3337875684118.jpg', 'Fahorro GraphQL · búsqueda «cerave» · SKU=EAN 3337875684118 · lista $464'),
  ('3401528509551', 'FC-28509551', 'Bioderma Photoderm Aquafluido Pocket 30 ml', 'Bioderma', '30 ml', 'Cuidado personal', 'Dermatología', 'Fluido', 406::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-3401528509551.jpg', 'Fahorro GraphQL · búsqueda «bioderma» · SKU=EAN 3401528509551 · lista $406'),
  ('3282770207774', 'FC-70207774', 'Avène Cleanance Gel Limpiador 400 ml', 'Avène', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 858::numeric, 'https://www.farmacapital.mx/catalogo-propia/avene-3282770207774.jpg', 'Fahorro GraphQL · búsqueda «avene» · SKU=EAN 3282770207774 · lista $858'),
  ('3282770398168', 'FC-70398168', 'Ducray Anaphase Shampoo Anticaída Ocasional 200 ml', 'Ducray', '200 ml', 'Cuidado personal', 'Dermatología', 'Champú', 661::numeric, 'https://www.farmacapital.mx/catalogo-propia/ducray-3282770398168.jpg', 'Fahorro GraphQL · búsqueda «ducray» · SKU=EAN 3282770398168 · lista $661'),
  ('3661434000522', 'FC-34000522', 'Uriage Agua Termal 300 ml', 'Uriage', '300 ml', 'Cuidado personal', 'Dermatología', null, 487::numeric, 'https://www.farmacapital.mx/catalogo-propia/uriage-3661434000522.jpg', 'Fahorro GraphQL · búsqueda «uriage» · SKU=EAN 3661434000522 · lista $487'),
  ('3282770393859', 'FC-70393859', 'A-Derma Exomega Control Aceite de Limpieza 500 ml', 'A-Derma', '500 ml', 'Cuidado personal', 'Dermatología', null, 669::numeric, 'https://www.farmacapital.mx/catalogo-propia/a-derma-3282770393859.jpg', 'Fahorro GraphQL · búsqueda «a-derma» · SKU=EAN 3282770393859 · lista $669'),
  ('4005900436993', 'FC-00436993', 'Eucerin Dermopure Exfoliante 100 ml', 'Eucerin', '100 ml', 'Cuidado personal', 'Dermatología', null, 583::numeric, 'https://www.farmacapital.mx/catalogo-propia/eucerin-4005900436993.jpg', 'Fahorro GraphQL · búsqueda «eucerin» · SKU=EAN 4005900436993 · lista $583'),
  ('8470003310338', 'FC-03310338', 'Cantabria Endocare Crema 30 ml', 'Endocare', '30 ml', 'Cuidado personal', 'Dermatología', 'Crema', 978::numeric, 'https://www.farmacapital.mx/catalogo-propia/endocare-8470003310338.jpg', 'Fahorro GraphQL · búsqueda «endocare» · SKU=EAN 8470003310338 · lista $978'),
  ('8431166181852', 'FC-66181852', 'Leti At4 Multiprotect Loción Corporal Fps50+ 100 Ml', 'Leti', '100 ml', 'Cuidado personal', 'Dermatología', 'Loción', 842::numeric, 'https://www.farmacapital.mx/catalogo-propia/leti-8431166181852.jpg', 'Fahorro GraphQL · búsqueda «leti at4» · SKU=EAN 8431166181852 · lista $842'),
  ('3337875921008', 'FC-75921008', 'Vichy Dercos Collagen 17 Shampoo 200 ml', 'Vichy', '200 ml', 'Cuidado personal', 'Dermatología', 'Champú', 694::numeric, 'https://www.farmacapital.mx/catalogo-propia/vichy-3337875921008.jpg', 'Fahorro GraphQL · búsqueda «vichy» · SKU=EAN 3337875921008 · lista $694'),
  ('7897930778641', 'FC-30778641', 'Cetaphil Oil Control Serum Facial Triple Acción 30 ml', 'Cetaphil', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 451::numeric, 'https://www.farmacapital.mx/catalogo-propia/cetaphil-7897930778641.jpg', 'Fahorro GraphQL · búsqueda «cetaphil» · SKU=EAN 7897930778641 · lista $451'),
  ('3504105025816', 'FC-05025816', 'Crema Mustela para Rozaduras Bebe 50 ml', 'Mustela', '50 ml', 'Cuidado personal', 'Dermatología', 'Crema', 145::numeric, 'https://www.farmacapital.mx/catalogo-propia/mustela-3504105025816.jpg', 'Fahorro GraphQL · búsqueda «mustela» · SKU=EAN 3504105025816 · lista $145'),
  ('7503037273315', 'FC-37273315', 'Birdman Fitmingo Proteína Vegetal Sabor Vainilla 34 gr', 'Birdman', '34 g', 'Suplemento', 'Nutrición deportiva', 'Polvo', 44::numeric, 'https://www.farmacapital.mx/catalogo-propia/birdman-7503037273315.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503037273315 · lista $44'),
  ('7503057040478', 'FC-57040478', 'Falcon Performance Choco Bronze 552 g', 'Falcon', '552 g', 'Suplemento', 'Nutrición deportiva', null, 600::numeric, 'https://www.farmacapital.mx/catalogo-propia/falcon-7503057040478.jpg', 'Fahorro GraphQL · búsqueda «birdman» · SKU=EAN 7503057040478 · lista $600'),
  ('748927068047', 'FC-27068047', 'Optimum Nutrition Gold Standard 100% Plant Protein Chocolate 480 gr', 'Optimum Nutrition', '480 g', 'Suplemento', 'Nutrición deportiva', null, 635::numeric, 'https://www.farmacapital.mx/catalogo-propia/optimum-nutrition-748927068047.jpg', 'Fahorro GraphQL · búsqueda «optimum nutrition gold standard» · SKU=EAN 748927068047 · lista $635'),
  ('073796612429', 'FC-96612429', 'Omron Monitor de Presión Automático', 'Omron', '1 pieza', 'Dispositivo médico', 'Diagnóstico', 'Aparato', 847::numeric, 'https://www.farmacapital.mx/catalogo-propia/omron-073796612429.jpg', 'Fahorro GraphQL · búsqueda «tensiometro» · SKU=EAN 073796612429 · lista $847'),
  ('756058792632', 'FC-58792632', 'Accu-Chek Instant Tiras Reactivas 50+25 piezas', 'Accu-Chek', '50 tiras', 'Dispositivo médico', 'Tiras', 'Tiras', 463::numeric, 'https://www.farmacapital.mx/catalogo-propia/accu-chek-756058792632.jpg', 'Fahorro GraphQL · búsqueda «glucometro» · SKU=EAN 756058792632 · lista $463'),
  ('3337875816847', 'FC-75816847', 'La Roche Posay Cicaplast 100 ml', 'La Roche-Posay', '100 ml', 'Cuidado personal', 'Dermatología', null, 649::numeric, 'https://www.farmacapital.mx/catalogo-propia/la-roche-posay-3337875816847.jpg', 'Fahorro GraphQL · búsqueda «la roche posay» · SKU=EAN 3337875816847 · lista $649'),
  ('8429420251632', 'FC-20251632', 'Isdin Ureadin Shower Gel 400Ml', 'Isdin', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 643::numeric, 'https://www.farmacapital.mx/catalogo-propia/isdin-8429420251632.jpg', 'Fahorro GraphQL · búsqueda «isdin» · SKU=EAN 8429420251632 · lista $643'),
  ('8436574363388', 'FC-74363388', 'Heliocare 360° Mattifying Brush 3 gr', 'Heliocare', '3 g', 'Cuidado personal', 'Dermatología', null, 694::numeric, 'https://www.farmacapital.mx/catalogo-propia/heliocare-8436574363388.jpg', 'Fahorro GraphQL · búsqueda «heliocare» · SKU=EAN 8436574363388 · lista $694'),
  ('8470001613233', 'FC-01613233', 'Sesderma Salises Gel Hidrat 50 ml', 'Sesderma', '50 ml', 'Cuidado personal', 'Dermatología', 'Gel', 1329::numeric, 'https://www.farmacapital.mx/catalogo-propia/sesderma-8470001613233.jpg', 'Fahorro GraphQL · búsqueda «sesderma» · SKU=EAN 8470001613233 · lista $1329'),
  ('3337875904292', 'FC-75904292', 'Cerave Loción Hidratante Intensiva 236 ml', 'CeraVe', '236 ml', 'Cuidado personal', 'Dermatología', 'Loción', 482::numeric, 'https://www.farmacapital.mx/catalogo-propia/cerave-3337875904292.jpg', 'Fahorro GraphQL · búsqueda «cerave» · SKU=EAN 3337875904292 · lista $482'),
  ('3701129805329', 'FC-29805329', 'Bioderma Atoderm Crema Ultra 200 ml', 'Bioderma', '200 ml', 'Cuidado personal', 'Dermatología', 'Crema', 295::numeric, 'https://www.farmacapital.mx/catalogo-propia/bioderma-3701129805329.jpg', 'Fahorro GraphQL · búsqueda «bioderma» · SKU=EAN 3701129805329 · lista $295'),
  ('3282779003131', 'FC-79003131', 'Agua Termal Avène 300 ml', 'Avène', '300 ml', 'Cuidado personal', 'Dermatología', null, 562::numeric, 'https://www.farmacapital.mx/catalogo-propia/avene-3282779003131.jpg', 'Fahorro GraphQL · búsqueda «avene» · SKU=EAN 3282779003131 · lista $562'),
  ('3282770389197', 'FC-70389197', 'Ducray Melascreen Concentrado Despigmentante 30 ml', 'Ducray', '30 ml', 'Cuidado personal', 'Dermatología', null, 1165::numeric, 'https://www.farmacapital.mx/catalogo-propia/ducray-3282770389197.jpg', 'Fahorro GraphQL · búsqueda «ducray» · SKU=EAN 3282770389197 · lista $1165'),
  ('3661434009976', 'FC-34009976', 'Uriage Age Absolu Serum Anti Edad 30Ml', 'Uriage', '30 ml', 'Cuidado personal', 'Dermatología', 'Sérum', 1086::numeric, 'https://www.farmacapital.mx/catalogo-propia/uriage-3661434009976.jpg', 'Fahorro GraphQL · búsqueda «uriage» · SKU=EAN 3661434009976 · lista $1086'),
  ('3282770153002', 'FC-70153002', 'A-Derma Biology AC Gel Espumoso Purificante 400 ml', 'A-Derma', '400 ml', 'Cuidado personal', 'Dermatología', 'Gel', 743::numeric, 'https://www.farmacapital.mx/catalogo-propia/a-derma-3282770153002.jpg', 'Fahorro GraphQL · búsqueda «a-derma» · SKU=EAN 3282770153002 · lista $743'),
  ('4006000028828', 'FC-00028828', 'Eucerin DermoPure Gel Concentrado 150 ml', 'Eucerin', '150 ml', 'Cuidado personal', 'Dermatología', 'Gel', 544::numeric, 'https://www.farmacapital.mx/catalogo-propia/eucerin-4006000028828.jpg', 'Fahorro GraphQL · búsqueda «eucerin» · SKU=EAN 4006000028828 · lista $544'),
  ('8470003468237', 'FC-03468237', 'Endocare Tensage Crema 30 ml', 'Endocare', '30 ml', 'Cuidado personal', 'Dermatología', 'Crema', 1259::numeric, 'https://www.farmacapital.mx/catalogo-propia/endocare-8470003468237.jpg', 'Fahorro GraphQL · búsqueda «endocare» · SKU=EAN 8470003468237 · lista $1259'),
  ('7501089804518', 'FC-89804518', 'Leti At4 Gel de Baño 250 ml', 'Leti', '250 ml', 'Cuidado personal', 'Dermatología', 'Gel', 529::numeric, 'https://www.farmacapital.mx/catalogo-propia/leti-7501089804518.jpg', 'Fahorro GraphQL · búsqueda «leti at4» · SKU=EAN 7501089804518 · lista $529');

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
  '3337875921336',
  '8470003808576',
  '8470001776211',
  '8429979201058',
  '3337875782357',
  '3701129802076',
  '3282770396881',
  '3282770389234',
  '3661434009204',
  '3282770393712',
  '4006000077000',
  '8436574360844',
  '7501089804525',
  '3337875908368',
  '7897930778634',
  '3504105032937',
  '7503025737386',
  '7503057040362',
  '748927051254',
  '073796801212',
  '7503012700065',
  '7500399003154',
  '4015630082988',
  '3337875892872',
  '8470001507983',
  '8436574364460',
  '8470002259539',
  '3337875795456',
  '3701129802069',
  '3282770396317',
  '3282779368612',
  '3661434005503',
  '3282771057392',
  '4005900436979',
  '8470001529688',
  '7501089804433',
  '3337875920971',
  '7640203240242',
  '3504108090743',
  '7503053835191',
  '7503057040539',
  '748927068023',
  '073796451011',
  '7503012700034',
  '7500399003215',
  '4015630066834',
  '3337875725897',
  '8429420251366',
  '8470001592453',
  '8470002073241',
  '3337875684118',
  '3401528509551',
  '3282770207774',
  '3282770398168',
  '3661434000522',
  '3282770393859',
  '4005900436993',
  '8470003310338',
  '8431166181852',
  '3337875921008',
  '7897930778641',
  '3504105025816',
  '7503037273315',
  '7503057040478',
  '748927068047',
  '073796612429',
  '756058792632',
  '3337875816847',
  '8429420251632',
  '8436574363388',
  '8470001613233',
  '3337875904292',
  '3701129805329',
  '3282779003131',
  '3282770389197',
  '3661434009976',
  '3282770153002',
  '4006000028828',
  '8470003468237',
  '7501089804518'
)
order by p.categoria, p.subcategoria nulls first, p.nombre;
