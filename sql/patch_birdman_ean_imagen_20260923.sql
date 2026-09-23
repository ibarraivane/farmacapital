-- Códigos de barras y fotos de suplementos Birdman (mayoreo).
-- Cruce exacto por SKU de b2b.birdman.com (variant.barcode + packshot).
-- No cambia el SKU FC-. No pisa un código o una foto que ya existan.
-- No asigna un EAN que ya tenga otro producto.

begin;

create temp table _fc_birdman_ean (
  sku text not null,
  sku_externo text not null,
  ean text,
  imagen_url text
) on commit drop;

insert into _fc_birdman_ean (sku, sku_externo, ean, imagen_url) values
('FC-21752837', 'PRSH20AZUL', '7503025737195', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/SHAKER_ad533ad7-b769-4ffb-9bd8-e60215c1e00a.png?v=1721258396'),
('FC-08530091', 'PRSH20NEGR', null, 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Shaker_NEGRO_sin_sombra.webp?v=1752693738'),
('FC-53534244', 'PRSH20ROSA', null, 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Shaker_ROSA_sin_sombra.webp?v=1752693368'),
('FC-39149283', 'PRTOSRGRIS', '7503037273247', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/ToallaMicrofibra.png?v=1721258396'),
('FC-41351362', 'PRTOSRNEGR', '7503037273230', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/ToallaMicrofibra.png?v=1721258396'),
('FC-59627477', 'PROALM', '7503025737577', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/HarinaAlmendras_Front.png?v=1721258397'),
('FC-50020942', 'LIN500', '7503025737508', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Linaza_Front.png?v=1721258397'),
('FC-32052266', 'SP360', '7503025737560', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Spirulina_Front.png?v=1721258399'),
('FC-53935550', 'BVAL946', '7503025737478', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/birdman-alimento-liquido-bebida-plant-based-almendra-6-pack-946-ml-29670778863703.png?v=1721258396'),
('FC-22161396', 'BVCH946', '7503025737485', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/birdman-alimento-liquido-bebida-plant-based-chocolate-6-pack-946-ml-29670783713367.png?v=1721258397'),
('FC-01408792', 'BVLI946', '7503025737669', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/birdman-alimento-liquido-bebida-plant-based-light-6-pack-946-ml-29670794395735.png?v=1721258397'),
('FC-77665700', 'BVEN946', '7503025737492', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/birdman-alimento-liquido-bebida-plant-based-original-6-pack-946-ml-29670806323287.png?v=1721258397'),
('FC-84453698', 'BCAGFR405', '7503025737584', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BCAAS_FRESA_b135afaf-1189-4528-9278-ace779491df9.png?v=1721258396'),
('FC-28049265', 'BCAGML405', '7503025737591', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BCAAS_FRESA_b135afaf-1189-4528-9278-ace779491df9.png?v=1721258396'),
('FC-41583926', 'CREATINA450', '7503025737355', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/450_CREATINA_1c799b80-8b3c-4e81-8ec5-e5e55603fe69.png?v=1721258396'),
('FC-96950585', 'CREACAP125', '7503053835191', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Creatine_Capsules_125_ES_01_2.png?v=1752256516'),
('FC-03483196', 'CREACAP250', '7503053835214', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Creatine_Capsules_250_ES_01_2.png?v=1752255690'),
('FC-44992467', 'CRDU300', '7503037273940', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/GoldenPeach1.webp?v=1744142221'),
('FC-35707855', 'CRLI300', '7503037273926', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Limon_3aa533c7-70a8-4b1e-ad8c-007f83ccf59b.webp?v=1744140547'),
('FC-84247462', 'CRPL300', '7503037273957', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/pinklemonade1.webp?v=1744141390'),
('FC-86925142', 'CRSA300', '7503037273933', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Watermelon_Splash_1.webp?v=1744127573'),
('FC-39606823', 'CWPL348', '7503057040911', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/PL_Creatine_for_Women_348_01_1.png?v=1776451289'),
('FC-44415196', 'CWNA348', '7503057040928', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/SA_Creatine_for_Women_348_01_2.png?v=1776451679'),
('FC-29281200', 'FPCHC1140', '7503025737317', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_PERFORMANCE_1140_CHOCOLATE_01.png?v=1781031288'),
('FC-65091786', 'FPCHC552', '7503057040478', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_PERFORMANCE_552_CHOCOLATE_01.png?v=1781029791'),
('FC-06433650', 'FPGVC1140', '7503025737324', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_PERFORMANCE_1140_VAINILLA_01.png?v=1781031155'),
('FC-83546244', 'FPGVC552', '7503057040539', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_PERFORMANCE_552_VAINILLA_01.png?v=1781030118'),
('FC-00403428', 'FPCHC190', '7503025737331', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Falcon_Performance_Bag_1900_Chocolate_01.png?v=1781031821'),
('FC-53267306', 'FPGVC190', '7503025737348', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Falcon_Performance_Bag_1900_Chocolate_01.png?v=1781031821'),
('FC-71374695', 'FPCHC10', '7503025737461', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Performance_Choco_Bronze_03_1.png?v=1781046399'),
('FC-96653081', 'FPGVC10', '7503025737454', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Performance_Choco_Bronze_03_1.png?v=1781046399'),
('FC-34437733', 'FCAC480', '7503057040409', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_CHAI_01.png?v=1781249375'),
('FC-57110856', 'FCAC960', '7503057040508', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_960_CHAI_01.png?v=1781247487'),
('FC-10011410', 'FCHC480', '7503057040362', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_CHOCOLATE_01.png?v=1781248548'),
('FC-82046711', 'FCHC960', '7503057040386', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_960_CHOCOLATE_01.png?v=1782521137'),
('FC-53536505', 'FFRC480', '7503057040416', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_FRESA_01.png?v=1781248770'),
('FC-01318124', 'FFRC960', '7503057040515', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_960_FRESA_01.png?v=1782521471'),
('FC-40393268', 'FNAC480', '7503057040423', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_NATURAL_01.png?v=1781249137'),
('FC-29984421', 'FNAC960', '7503057040522', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_960_NATURAL_01.png?v=1781247912'),
('FC-31502844', 'FVAC480', '7503057040355', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_VAINILLA_01.png?v=1782434879'),
('FC-82042925', 'FVAC960', '7503057040379', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_960_VAINILLA_01_1.png?v=1781248067'),
('FC-03985090', 'FPUC480', '7503057040393', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FALCON_480_PUMPKIN_01_1.png?v=1788551864'),
('FC-16339939', 'FCHC1800', '7503025737041', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/FALCON_VAINILLA_1800_LISTING_01_3.jpg?v=1783541893'),
('FC-30796929', 'FVAC1800', '7503025737058', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/FALCON_VAINILLA_1800_LISTING_01_3.jpg?v=1783541893'),
('FC-04614023', 'FCAMP', '7503025737003', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHAI_f7f46966-4037-4327-9bea-1bdea82782f9.png?v=1721258398'),
('FC-59010784', 'FCHMP', '7503025737027', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHAI_f7f46966-4037-4327-9bea-1bdea82782f9.png?v=1721258398'),
('FC-22516107', 'FFRMP', '7503025737683', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHAI_f7f46966-4037-4327-9bea-1bdea82782f9.png?v=1721258398'),
('FC-22844910', 'FNAMP', '7503025737010', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHAI_f7f46966-4037-4327-9bea-1bdea82782f9.png?v=1721258398'),
('FC-11941078', 'FVAMP', '7503025737034', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHAI_f7f46966-4037-4327-9bea-1bdea82782f9.png?v=1721258398'),
('FC-80802444', 'FCAC12', '7503057040812', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Chai_03.png?v=1781250679'),
('FC-83686649', 'FCHC12', '7503057040799', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Chai_03.png?v=1781250679'),
('FC-90048160', 'FFRC12', '7503057040829', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Chai_03.png?v=1781250679'),
('FC-78739107', 'FNAC12', '7503057040850', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Chai_03.png?v=1781250679'),
('FC-38682539', 'FVAC12', '7503057040782', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Falcon_Chai_03.png?v=1781250679'),
('FC-65234248', 'FCH117', '7500326818219', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/1.17KG_CHOCOLATE_33a1a4ad-1732-42a1-ad81-8104b4055b69.png?v=1721258396'),
('FC-75908505', 'FFR117', '7503025737515', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/1.17KG_FRESA_a07dbeec-c956-44eb-a050-8050bd2e1ffd.png?v=1721258396'),
('FC-00526609', 'FPU510', null, 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/510G_PUMPKIN_d7483c66-735b-4ca1-8861-f004f5001748.png?v=1721258396'),
('FC-27361051', 'FIBBC10', '7503037273322', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Fitmingo_Vanilla_03.png?v=1781046622'),
('FC-18543595', 'FIMOC10', '7503037273339', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Fitmingo_Vanilla_03.png?v=1781046622'),
('FC-87504720', 'FIVAC10', '7503037273346', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Multipack_Fitmingo_Vanilla_03.png?v=1781046622'),
('FC-14780513', 'FIBBC1020', '7503037273391', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/FITMINGO_LISTINGS_BLUEBERRY1020_01.jpg?v=1781043593'),
('FC-03210058', 'FIBBC1700', '7503037273452', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Fitmingo_Bag_1700_Blueberry_01_1.png?v=1781045337'),
('FC-88523700', 'FIBBC510', '7503037273360', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FITMINGO_510_BLUEBERRY_01_1.png?v=1781042889'),
('FC-50466353', 'FIMOC1020', '7503037273407', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/FITMINGO_LISTINGS_MOKA_1020_01_2.jpg?v=1784655875'),
('FC-07219482', 'FIMOC1700', '7503037273469', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Fitmingo_Bag_1700_Moka_01.png?v=1781045742'),
('FC-59181380', 'FIMOC510', '7503037273377', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/FITMINGO_LISTINGS_MOKA510_01_1.jpg?v=1781034781'),
('FC-34993090', 'FIVAC1020', '7503037273414', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FITMINGO_1020_VAINILLA_01.png?v=1781044232'),
('FC-46159837', 'FIVAC1700', '7503037273476', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Fitmingo_Bag_1700_Vainilla_01.png?v=1781045742'),
('FC-57892117', 'FIVAC510', '7503037273384', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/BM_FITMINGO_510_VAINILLA_01.png?v=1772696918'),
('FC-77916472', 'PBEMP', '7503025737065', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_BERRYVANILLA_aabdc10c-358f-4b8b-a211-f998ae712c1e.png?v=1721258398'),
('FC-25076842', 'PCHMP', '7503025737072', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_BERRYVANILLA_aabdc10c-358f-4b8b-a211-f998ae712c1e.png?v=1721258398'),
('FC-01616372', 'PBE210', '7500462667726', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/210G_BERRYVAINILLA_9205577e-16e9-42c2-9c8a-b9635a4a582c.png?v=1721258397'),
('FC-04988756', 'PBE900', '7500462667733', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/900G_BERRYVANILLA_0648449b-d7ff-4e31-96d2-3ddcda5fced1.png?v=1721258397'),
('FC-93003613', 'PMA210', '7500462667757', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/210G_MATCHA_91f2bdfd-727f-4430-a78b-1544b658d51e.png?v=1721258397'),
('FC-84598525', 'PMA900', '7500462667740', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/900G_MATCHA_46b4ffc6-3675-4339-8ce9-1c036421c1b3.png?v=1721258396'),
('FC-02498861', 'PECHMP', '7503025737157', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHOCOLATE-1.png?v=1721258398'),
('FC-36570999', 'PECVMP', '7503025737140', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MP_CHOCOLATE-1.png?v=1721258398'),
('FC-63173998', 'PECH882', '7503025737119', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/882G_CHOCOLATE_ec008f61-5225-4090-9bf7-c2497d18c888.png?v=1721258397'),
('FC-43080464', 'PECV882', '7503025737102', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/882G_COCOVANILLA_4b410515-0f19-424c-84b9-e9d9d028a3d6.png?v=1721258397'),
('FC-92571047', 'WSBERB180CAPS', '7503038209290', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_BERB_180CAPS_90p.jpg?v=1737566426'),
('FC-08622819', 'WSBERB90CAPS', '7503038209412', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_BERB_90CAPS_45p.jpg?v=1737566438'),
('FC-35143291', 'WSCITMAG120CAPS', '7503038209061', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_CITMAG_120CAPS_40p.jpg?v=1737566414'),
('FC-27328976', 'WSCITMAG240CAPS', '7503038209078', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_CITMAG_240CAPS_80p.jpg?v=1737566403'),
('FC-44646173', 'WSPROBIO140CAPS', '7503037273988', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_DAIPROBIO_140CAPS_140p.jpg?v=1737566216'),
('FC-10110943', 'WSPROBIO70CAPS', '7503037273964', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_DAIPROBIO_70CAPS_70p.jpg?v=1737566227'),
('FC-21720347', 'WSOMEGAF120CAPS', '7503038209047', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_OMEGAF_120CAPS_60p.jpg?v=1737566262'),
('FC-43700210', 'WSOMEGAF60CAPS', '7503038209030', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_OMEGAF_60CAPS_30p.jpg?v=1737566274'),
('FC-62608613', 'WSGLIMAG120CAPS', '7503038209153', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_GLIMAG_120CAPS_30p.jpg?v=1737566392'),
('FC-05118698', 'WSGLIMAG240CAPS', '7503038209160', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_GLIMAG_240CAPS_60p.jpg?v=1737566381'),
('FC-68156235', 'HBALPL222', '7503038209665', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_HBALANCE_PINKLEMONADE_30PORCIONES.jpg?v=1750116304'),
('FC-98639917', 'HBALPL444', '7503038209672', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_HBALANCE_PINKLEMONADE444.webp?v=1752253045'),
('FC-88147536', 'HBALNA222', '7503053835177', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_HBALANCE_SINSABOR_30PORCIONES.jpg?v=1750115529'),
('FC-44427678', 'HBALNA444', '7503053835184', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_HBALANCE_SINSABOR_30PORCIONES_1_1.png?v=1752254004'),
('FC-59831837', 'MCTOIL270', '7503025737379', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MCT_OIL_BIG_9a5ccbec-e779-4c62-b398-0021a5b16320.png?v=1721258397'),
('FC-27575442', 'MCTOIL420', '7503025737362', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MCT_OIL_BIG_9a5ccbec-e779-4c62-b398-0021a5b16320.png?v=1721258397'),
('FC-84758742', 'BSMCTPOW432', '7503025737423', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MCT_OIL_POWDER_NATURAL.png?v=1721258398'),
('FC-96952979', 'BSMCTPOWVAN432', '7503025737416', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MCT_OIL_POWDER_NATURAL.png?v=1721258398'),
('FC-66779489', 'WSMAGNESIO180CAPS', '7503038209221', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_MAGNESIO_180CAPS_60p.jpg?v=1737566335'),
('FC-83648961', 'WSMAGNESIO90CAPS', '7503038209214', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_MAGNESIO_90CAPS_30p.jpg?v=1737566346'),
('FC-40772944', 'BSMINERALES300', '7503025737386', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/MINERALS_FRONT.png?v=1721258395'),
('FC-98603183', 'WSMCINOS180CAPS', '7503038209115', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_MCINOS_180CAPS_30p.jpg?v=1737566286'),
('FC-73371515', 'WSMCINOS90CAPS', '7503038209108', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_MCINOS_90CAPS_15p.jpg?v=1737566299'),
('FC-72183039', 'INOSMIX123', '7503038209689', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/WS_INOSMIX_123g_FRNT_SCOOP_1_67c66aac-2fa3-4ead-94d8-62de98210ac5.png?v=1756236646'),
('FC-66095859', 'INOSMIX246', '7503038209696', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/WS_G_INOSMIX_246g_FRNT_SCOOP_1.png?v=1756237890'),
('FC-70743533', 'WSINOSITOL180CAPS', '7503038209139', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_INOS_180CAPS_60p.jpg?v=1737566311'),
('FC-39852213', 'WSINOSITOL90CAPS', '7503038209122', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_INOS_90CAPS_30p.jpg?v=1737566323'),
('FC-67118427', 'WSPREMPROBIO120CAPS', '7503038209436', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_PREMPROBIO_120CAPS_120p.jpg?v=1737566193'),
('FC-20144818', 'WSPREMPROBIO60CAPS', '7503038209429', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_PREMPROBIO_60CAPS_60p.jpg?v=1737566204'),
('FC-88487338', 'WSOMEPRE120CAPS', '7503038209016', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_OMEPRE_120CAPS_60p.jpg?v=1737566239'),
('FC-24353857', 'WSOMEPRE60CAPS', '7503037273995', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_OMEPRE_60CAPS_30p.jpg?v=1737566251'),
('FC-56681312', 'WSRESV45CAPS', '7503038209887', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_RESV_45CAPS_45p.jpg?v=1737566182'),
('FC-04158022', 'WSRESV90CAPS', '7503038209450', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_RESV_90CAPS_90p.jpg?v=1737566170'),
('FC-06898799', 'WSTREOMAG180CAPS', '7503038209252', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_TREOMAG_180CAPS_60p.jpg?v=1737566358'),
('FC-65258427', 'WSTREOMAG90CAPS', '7503038209245', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_TREOMAG_90CAPS_30p.jpg?v=1737566371'),
('FC-83116374', 'WSVITDK150', '7503053835481', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/Adobe_Express_-_file_18.png?v=1764705253'),
('FC-01633681', 'WSVITDK300', '7503053835498', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/WSUP-VITAD3K2_Render_300Caps_Front_1.png?v=1764705164'),
('FC-18820668', 'WSVITAD120CAPS', '7503038209184', 'https://cdn.shopify.com/s/files/1/0703/1180/5166/files/01_VITD_120CAPS_120p.jpg?v=1737566159');

with destino as (
  select distinct on (b.sku_externo)
    b.sku_externo, b.ean, b.imagen_url, p.id
  from _fc_birdman_ean b
  join public.productos p
    on p.sku = b.sku
    or p.descripcion = 'Bajo pedido · birdman · ' || b.sku_externo
  order by b.sku_externo, (p.sku = b.sku) desc, p.id
),
ean_libre as (
  select d.id, d.ean
  from destino d
  where d.ean is not null
    and not exists (
      select 1 from public.productos o
      where o.codigo_barras = d.ean
        and o.id <> d.id
    )
)
update public.productos p
   set codigo_barras = e.ean
  from ean_libre e
 where p.id = e.id
   and coalesce(nullif(trim(p.codigo_barras), ''), '') = '';

update public.productos p
   set imagen_url = d.imagen_url
  from destino d
 where p.id = d.id
   and coalesce(d.imagen_url, '') <> ''
   and coalesce(nullif(trim(p.imagen_url), ''), '') = '';

select
  (select count(*) from _fc_birdman_ean where ean is not null) as ean_en_lista,
  (select count(*) from _fc_birdman_ean where coalesce(imagen_url, '') <> '') as fotos_en_lista,
  (select count(*) from public.productos p
     join _fc_birdman_ean b
       on p.sku = b.sku
       or p.descripcion = 'Bajo pedido · birdman · ' || b.sku_externo
    where p.codigo_barras is not null and b.ean is not null and p.codigo_barras = b.ean) as ean_puestos;

commit;
