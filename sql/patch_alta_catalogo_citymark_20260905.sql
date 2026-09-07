-- City Mark 20260905 — 71 altas que faltaron + relink Recibir + stock huérfano.
-- Nombres de mostrador (marca + producto), no el código del ticket.
-- Stock 0 en el alta. Piezas al escanear + MMAA. No inventar 0000.
-- NO borra renglones ya escaneados (se conserva MMAA/lote).
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cm20260905 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,3) not null,
  precio numeric(12,2) not null,
  marca text,
  presentacion text,
  categoria text not null,
  subcategoria text,
  forma text,
  imagen text
) on commit drop;

insert into _fc_cm20260905 (
  linea, ean, sku, nombre, snap, qty, costo, precio,
  marca, presentacion, categoria, subcategoria, forma, imagen
) values
  (1, '7891010245160', 'FC-10245160', 'Neutrogena agua micelar 200 ml', 'NEUTROGENA 200ML AGUA MICELAR C6 SEP26', 2, 45.890, 58, 'Neutrogena', '200 ml', 'Cuidado personal', 'Facial', 'Solución', 'https://www.farmacapital.mx/catalogo-propia/cm-7891010245160.jpg'),
  (2, '761318132592', 'FC-18132592', 'Revlon peines Salon Carbon 2 pzas', 'PEINES REVLON SALON CARBON 2PK', 1, 44.950, 57, 'Revlon', '2 pzas', 'Cuidado personal', 'Cabello', 'Peine', null),
  (3, '761318128335', 'FC-18128335', 'Revlon cepillo paleta RV2833LA', 'CEP REVLON MOD PALETA RV2833LA', 1, 45.520, 57, 'Revlon', '1 pza', 'Cuidado personal', 'Cabello', 'Cepillo', null),
  (4, '761318020639', 'FC-18020639', 'Revlon cepillo acolchado goma RV2063LA', 'CEP REVLON ACOLCHMGO GOMARV2063LA', 1, 45.820, 58, 'Revlon', '1 pza', 'Cuidado personal', 'Cabello', 'Cepillo', null),
  (5, '7502221187575', 'FC-21187575', 'Brut Deep Blue 48 h spray 150 ml', 'DESOD BRUT DEEPBLUE 48HR SPY150ML', 2, 45.915, 58, 'Brut', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (6, '7506306215511', 'FC-06215511', 'Savile sábila y naranja spray 150 ml', 'DESOD SAVILE SAB-NAC NAT SPY 150ML', 1, 38.960, 49, 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506306215511.jpg'),
  (7, '7506306215528', 'FC-06215528', 'Savile bicarbonato y limón spray 150 ml', 'DEO SAVILE B-SOD Y LIM SPY150ML', 1, 38.950, 49, 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (8, '7506306209763', 'FC-06209763', 'Savile manzanilla spray 150 ml', 'DESOD SAVILE MANZANILLA SPY 150ML', 1, 38.950, 49, 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (9, '75065102', 'FC-75065102', 'Savile manzanilla stick 45 g', 'DESOD SAVILE MANZANILLA STICK 45G', 1, 38.650, 49, 'Savile', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', 'https://www.farmacapital.mx/catalogo-propia/cm-75065102.jpg'),
  (10, '75068639', 'FC-75068639', 'Savile bicarbonato y limón stick 45 g', 'DESOD SAVILE B-SOD Y LIM STICK45G', 1, 38.650, 49, 'Savile', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  (11, '75068622', 'FC-75068622', 'Savile bicarbonato y limón roll-on 45 ml', 'DESOD SAVILE B-SOD Y LIM R-ON45ML ABRIL27', 1, 24.560, 31, 'Savile', '45 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (12, '75064891', 'FC-75064891', 'Savile agua de rosas roll-on 45 ml', 'DESOD SAVILE AGUA/ROSA R-ON 45ML MAR27', 1, 27.990, 35, 'Savile', '45 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (13, '7501082736021', 'FC-82736021', 'Nuvel Aclara woman spray 150 ml', 'DEO NUVEL ACLA WOM SPY150ML', 2, 35.450, 45, 'Nuvel', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (14, '7506309864839', 'FC-09864839', 'Gillette Endurance Cool spray 150 ml', 'DESOD GTTE END COOL SPY150ML', 1, 55.380, 70, 'Gillette', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (15, '7501027286000', 'FC-27286000', 'Obao Ocean roll-on 65 g', 'DESOD OBAO OCEAN R-ON 65G', 1, 25.830, 33, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (16, '7506309864822', 'FC-09864822', 'Gillette Endurance Arctic Ice spray 150 ml', 'DESOD GTTE ENDURARTICIC SP 150', 1, 55.580, 70, 'Gillette', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506309864822.jpg'),
  (17, '7501027286017', 'FC-27286017', 'Obao Clásico roll-on 65 g', 'DESOD OBAO CLAS R-ON 65G', 1, 29.550, 37, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (18, '7501082731071', 'FC-82731071', 'Nuvel Tropical woman spray 170 ml', 'DESOD NUVEL TROPIC WOM SPY 170 ML', 2, 32.725, 41, 'Nuvel', '170 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (19, '7506306251847', 'FC-06251847', 'Axe Black Remix spray 210 ml', 'DESOD AXE BLACK REMIX SPY 210 ML', 3, 68.730, 86, 'Axe', '210 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (20, '7509546029139', 'FC-46029139', 'Speed Stick 24/7 Cool Night stick 85 g', 'DESOD SPEED S 24/7COOL-NIG STIK 85G', 2, 55.340, 70, 'Speed Stick', '85 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  (21, '7500435141796', 'FC-35141796', 'Old Spice Mariner Professional spray 150 ml', 'DESOD OLD SPICE MAR PROF SPY 150ML', 1, 61.740, 78, 'Old Spice', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7500435141796.jpg'),
  (22, '7509552906158', 'FC-52906158', 'Obao Fresquísima roll-on 65 g', 'DESOD OBAO FRESQUISSIMA R-ON 65G', 1, 26.090, 33, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (23, '7509552844825', 'FC-52844825', 'Obao Naturals Coco roll-on 65 g', 'DESOD OBAO R-NAT COCO R-ON 65G', 1, 24.950, 32, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (24, '7509546071275', 'FC-46071275', 'Lady Speed Stick Powder Fresh spray 60 g', 'DESOD LADYSS POWDER FRESH SPY 60G FEB27', 3, 29.487, 37, 'Lady Speed Stick', '60 g', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546071275.jpg'),
  (25, '78924338', 'FC-78924338', 'Rexona Woman Powder roll-on 53 g', 'DESOD REXONA WOM POW R-ON 53G', 2, 30.120, 38, 'Rexona', '53 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (26, '7506306226852', 'FC-06226852', 'Axe Anarchy for Her spray 150 ml', 'DESOD AXE WOM ANARCHY SPY 150ML', 2, 45.830, 58, 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (27, '7500435129367', 'FC-35129367', 'Secret pH Balanced stick gel 45 g', 'DESOD SECRET PH-BALAN STICK GEL 45G', 1, 60.470, 76, 'Secret', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  (28, '7506306209862', 'FC-06209862', 'Axe Anarchy Fresh Love for Her spray 150 ml', 'DESOD AXE SPY 150ML 48H ANARCHY FRESH LOVE FOR HER', 1, 45.830, 58, 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506306209862.jpg'),
  (29, '7791293025919', 'FC-93025919', 'Axe Excite seco spray 152 ml', 'DESOD AXE EXCITE SECO SPY 152ML', 1, 62.830, 79, 'Axe', '152 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (30, '7509546057545', 'FC-46057545', 'Lady Speed Stick Pro 5en1 stick 45 g', 'DESOD LADYSS PRO 5EN1 STICK 45G ABRIL27', 1, 49.590, 62, 'Lady Speed Stick', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  (31, '7509546015514', 'FC-46015514', 'Lady Speed Stick Derma Defense Fresh 45 g', 'DESOD LADYSS D-DEF A-FSH 45G', 1, 50.780, 64, 'Lady Speed Stick', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  (32, '7506306209855', 'FC-06209855', 'Axe Anarchy Floral 48 h spray 150 ml', 'DESOD AXE ANARC FLO 48H SPY 150ML', 1, 45.830, 58, 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (33, '7509546029153', 'FC-46029153', 'Lady Speed Stick Floral Fresh gel 65 g', 'DESOD LADYSS FLORAL FRESH GEL 65GN', 1, 53.300, 67, 'Lady Speed Stick', '65 g', 'Cuidado personal', 'Desodorante', 'Gel', null),
  (34, '78924345', 'FC-78924345', 'Rexona Woman Bamboo roll-on 50 ml', 'DESOD REXONA WOM BAMBOO R-ON 50ML', 2, 30.125, 38, 'Rexona', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-78924345.jpg'),
  (35, '7509546060477', 'FC-46060477', 'Lady Speed Stick Powder Fresh roll-on 50 ml', 'DESOD LADYSS POW DER FRES R-ON 50ML', 3, 29.163, 37, 'Lady Speed Stick', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546060477.jpg'),
  (36, '7506339349146', 'FC-39349146', 'Old Spice Wolfthorn spray 150 ml', 'DESOD OLD SPICE WOLFTHORN SPY 150ML', 1, 56.990, 72, 'Old Spice', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (37, '7501027250612', 'FC-27250612', 'Obao para ella roll-on 65 g', 'DESOD OBAO P/DEL R-ON 65G', 1, 25.830, 33, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (38, '7501082790481', 'FC-82790481', 'Nuvel toallitas desmaquillantes hidratantes C/25', 'TAS DESMAQ NUVEL HIDRATANTES C25', 1, 25.020, 32, 'Nuvel', '25 pzas', 'Cuidado personal', 'Facial', 'Toallitas', null),
  (39, '7502221012303', 'FC-21012303', 'Claris toallitas desmaquillantes aloe C/40', 'TAS HUM CLARIS DESMAQ ALOE C/40', 1, 18.860, 24, 'Claris', '40 pzas', 'Cuidado personal', 'Facial', 'Toallitas', null),
  (40, '7509546029825', 'FC-46029825', 'Neutro Balance roll-on 65 ml', 'DESOD NEUTRO B R-ON 65 ML', 3, 28.183, 36, 'Neutro Balance', '65 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (41, '7501022107201', 'FC-22107201', 'Conse shampoo antiolores para perro 500 ml', 'SH PERRO CONSE ANTI OLORES 500ML', 1, 72.420, 91, 'Conse', '500 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  (42, '7509546007083', 'FC-46007083', 'Colgate Total 12 Clean Mint 50 ml', 'C D COLGATE TOTAL12 CLEAN MINT 50ML', 1, 19.290, 25, 'Colgate', '50 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546007083.jpg'),
  (43, '037836007279', 'FC-36007279', 'Conse Guau Aloe Vera shampoo para perro 400 ml', 'SH PERRO CONSE GUAU ALOE VERA 400ML', 1, 45.670, 58, 'Conse', '400 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  (44, '037836084508', 'FC-36084508', 'Grisi Agrade avena shampoo para perro 400 ml', 'SH GRISI PERRO AGRADE AVENA 400ML', 1, 74.540, 94, 'Grisi', '400 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  (45, '759684900204', 'FC-84900204', 'Jaloma agua de rosas tónico facial 250 ml', 'AGUA JALOMA ROSAS TOC FAC 250ML', 2, 33.095, 42, 'Jaloma', '250 ml', 'Cuidado personal', 'Facial', 'Tónico', 'https://www.farmacapital.mx/catalogo-propia/cm-759684900204.jpg'),
  (46, '7509546651743', 'FC-46651743', 'Stefano Triumph desodorante 159 ml', 'DESOD STEFANO TRIUMPH 159 ML', 1, 60.490, 76, 'Stefano', '159 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (47, '7501056330378', 'FC-56330378', 'Pond''s Bio-Hydra Dual loción limpiadora 200 ml', 'LOC LIMP PONDS BIO-HYDRA DUAL 200ML', 2, 88.790, 111, 'Pond''s', '200 ml', 'Cuidado personal', 'Facial', 'Loción', null),
  (48, '759684900259', 'FC-84900259', 'Jaloma agua de arroz spray 250 ml', 'JALOMA AGUA DE ARROZ 250ML SPRAY C24 PZS', 1, 37.500, 47, 'Jaloma', '250 ml', 'Cuidado personal', 'Facial', 'Spray', null),
  (49, '814266022627', 'FC-66022627', 'Honey Keeper Kids lavanda 3en1 414 ml', 'SH HONEYKEEPER KIDS LAVANDA 3EN1 414ML', 1, 80.860, 102, 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Shampoo', null),
  (50, '7509546694702', 'FC-46694702', 'Stefano Next Level spray 150 ml', 'DESOD STEFANO NEXT LEVEL SPY150MLN', 1, 60.490, 76, 'Stefano', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (51, '7509546073774', 'FC-46073774', 'Stefano Spaz spray 113 g', 'DESOD STEFANO SPAZ SPY 113G', 1, 60.490, 76, 'Stefano', '113 g', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (52, '7509546078434', 'FC-46078434', 'Stefano Alpine Men spray 113 g', 'DESOD STEFANO ALP MEN SPY 113G', 1, 60.490, 76, 'Stefano', '113 g', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (53, '7506267917516', 'FC-67917516', 'Honey Keeper Kids avena crema 414 ml', 'CRA HK KIDS OAT 414ML', 1, 85.420, 107, 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Crema', null),
  (54, '7509546655055', 'FC-46655055', 'Caprice Volume Control mousse 200 g', 'MOUSSE CAPRICE VOLUM-CTRL 200 G', 1, 50.510, 64, 'Caprice', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  (55, '3600542478359', 'FC-42478359', 'Garnier SkinActive jelly carbón agua micelar 400 ml', 'AGUA MIC GARNIER JELLY CARB 400ML', 1, 115.390, 145, 'Garnier', '400 ml', 'Cuidado personal', 'Facial', 'Solución', null),
  (56, '7501035911024', 'FC-35911024', 'Colgate Max Fresh Pepper 125 ml', 'C D COLGATE MFP 125ML', 2, 49.155, 62, 'Colgate', '125 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  (57, '7509546068909', 'FC-46068909', 'Colgate Triple Acción extra blanco 50 ml', 'C D COLG TRIPL-ACC EXTBL 50ML', 2, 13.525, 17, 'Colgate', '50 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546068909.jpg'),
  (58, '7506425629442', 'FC-25629442', 'Escudo solución antiséptica para manos spray 200 ml', 'ESCUDO SOL ANTISEP P/MAN SPY 200ML ENE27', 2, 43.785, 55, 'Escudo', '200 ml', 'Cuidado personal', 'Higiene', 'Spray', null),
  (59, '7702018913954', 'FC-18913954', 'Gillette Clear Wave 3× roll-on 60 g', 'DESOD GTTE 3X CL WAVE R-ON 60G OCT26', 2, 36.495, 46, 'Gillette', '60 g', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-7702018913954.jpg'),
  (60, '7500435168991', 'FC-35168991', 'Herbal Essences Extra Control mousse 200 g', 'MOUSSE HERBAL ESS EXTR CONT 200G', 1, 67.000, 84, 'Herbal Essences', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  (61, '7509546698137', 'FC-46698137', 'Colgate Luminous White Coco Brillante 66 ml', 'C D COLGATE LUMIN W COHIT BRILL 66MLN', 2, 42.805, 54, 'Colgate', '66 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  (62, '78926523', 'FC-78926523', 'Rexona Woman Antibacterial Emotional roll-on 50 g', 'DESOD REXONA WOM AEMOT R-ON 50G', 1, 30.130, 38, 'Rexona', '50 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (63, '7509546674018', 'FC-46674018', 'Colgate Luminous White Carbón 66 ml', 'C D COLGATE LUMIN WHIT CARBON 66ML', 2, 42.815, 54, 'Colgate', '66 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  (64, '7509546000350', 'FC-46000350', 'Colgate Triple Acción 150 ml', 'C D COLGATE TRIPLE ACC 150ML FEB27', 2, 30.000, 38, 'Colgate', '150 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546000350.jpg'),
  (65, '7509546654997', 'FC-46654997', 'Caprice Final Touch mousse 200 g', 'MOUSSE CAPRICE FINAL TOUCH 200 G', 1, 50.510, 64, 'Caprice', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  (66, '814266022610', 'FC-66022610', 'Honey Keeper Kids miel shampoo 414 ml', 'SH HK KIDS HONEY', 1, 80.860, 102, 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Shampoo', null),
  (67, '7500435169035', 'FC-35169035', 'Herbal Essences Rizos mousse 200 g', 'MOUSSE HERBAL ESS RIZO 200G', 1, 57.900, 73, 'Herbal Essences', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', 'https://www.farmacapital.mx/catalogo-propia/cm-7500435169035.jpg'),
  (68, '7891024028827', 'FC-24028827', 'Colgate Total 12 Clean enjuague 60 ml', 'ENJ BUC COLGATE TOTAL12 CLEAN 60ML', 2, 13.385, 17, 'Colgate', '60 ml', 'Cuidado personal', 'Higiene bucal', 'Enjuague', null),
  (69, '3616303440534', 'FC-03440534', 'Adidas Control spray 150 ml', 'ADIDAS 150ML SPY CONTROL', 2, 39.905, 50, 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (70, '7506267923654', 'FC-67923654', 'Honey Keeper gel manzanilla y miel 200 ml', 'GEL HONEY KEEPER MZNILL MIE 200ML', 1, 41.760, 53, 'Honey Keeper', '200 ml', 'Cuidado personal', 'Cabello', 'Gel', null),
  (71, '7896015592837', 'FC-15592837', 'Sensodyne Gentle Care extra suave 3 pzas', 'CEP SENSODYNE GENTLE CARE XTR SUAV 3PZ', 1, 75.450, 95, 'Sensodyne', '3 pzas', 'Cuidado personal', 'Higiene bucal', 'Cepillo', null),
  (72, '3616303441173', 'FC-03441173', 'Adidas Dynamic Pulse spray 150 ml', 'ADIDAS 150ML SPY DYNAMIC PULSE', 1, 39.900, 50, 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-3616303441173.jpg'),
  (73, '759684900280', 'FC-84900280', 'Jaloma agua de rosas spray 130 ml', 'JALOMA AGUA DE ROSAS 130ML SPRAY', 2, 16.865, 22, 'Jaloma', '130 ml', 'Cuidado personal', 'Facial', 'Spray', null),
  (74, '7891024027363', 'FC-24027363', 'Colgate Plax Ice Infinity enjuague 60 ml', 'ENJ BUC PLAX ICE INFINITY 60ML', 2, 13.040, 17, 'Colgate', '60 ml', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'https://www.farmacapital.mx/catalogo-propia/cm-7891024027363.jpg'),
  (75, '3616303842550', 'FC-03842550', 'Adidas Fresh Endurance spray 150 ml', 'ADIDAS 150ML SPY FRESH ENDURANCE', 1, 39.900, 50, 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (76, '3616303441302', 'FC-03441302', 'Adidas Team Force spray 150 ml', 'ADIDAS 150ML SPY TEAMFORCE', 1, 39.900, 50, 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  (77, '3616303842420', 'FC-03842420', 'Adidas Power Booster spray 150 ml', 'ADIDAS 150ML SPY POWER BOOSTER', 1, 39.900, 50, 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-3616303842420.jpg'),
  (78, '7891024183182', 'FC-24183182', 'Colgate hilo dental encerado 25 m', 'HILO DENT COLGATE ENCERA 25M', 1, 62.660, 79, 'Colgate', '25 m', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', null),
  (79, '070942302463', 'FC-42302463', 'GUM Go-Betweens microfino C/6', 'CEP DENT GUM GO-BET MICROFINO C/6', 1, 82.630, 104, 'GUM', '6 pzas', 'Cuidado personal', 'Higiene bucal', 'Cepillo interdental', null),
  (80, '759684313295', 'FC-84313295', 'Jaloma atomizador Mertodol blanco 60 ml', 'JALOMA ATOMIZADOR 60ML MERTODOL BLANCO', 2, 25.775, 33, 'Jaloma', '60 ml', 'Botiquín', 'Botiquín', 'Atomizador', null),
  (81, '75075996', 'FC-75075996', 'Rexona Happy Morning 48 h roll-on 50 ml', 'DESOD REXON HAPPY MOR 48H R-ON 50ML', 1, 34.790, 44, 'Rexona', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (82, '7509552780956', 'FC-52780956', 'Obao Men Tato Rebel roll-on 65 g', 'DESOD OBAO MEN TATO REBEL R-ON65', 1, 25.830, 33, 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  (83, '070942303460', 'FC-42303460', 'GUM Trav-Ler interdental 0.8 mm', 'CEP DENT GUM TRAV-LER INTERDENTA 0.8', 1, 82.630, 104, 'GUM', '1 pza', 'Cuidado personal', 'Higiene bucal', 'Cepillo interdental', null),
  (84, '7501033204920', 'FC-33204920', 'Speed Stick Xtreme Night crema 30 g', 'DESOD SPEED S XTREM 48H CRA30G S N', 6, 14.383, 18, 'Speed Stick', '30 g', 'Cuidado personal', 'Desodorante', 'Crema', 'https://www.farmacapital.mx/catalogo-propia/cm-7501033204920.jpg');

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-CM-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  'marca',
  'Alta City Mark 20260905 · 2026-09-05 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  false,
  t.marca,
  t.presentacion,
  t.forma,
  t.imagen,
  t.imagen
from _fc_cm20260905 t
where public.fc_buscar_producto_escaneo(t.ean) is null;

update public.productos p
set
  costo = t.costo,
  precio = case when coalesce(p.precio, 0) <= 0 then t.precio else p.precio end
from _fc_cm20260905 t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  nombre = case
    when upper(btrim(p.nombre)) = upper(btrim(t.snap)) then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(t.marca), ''), nullif(trim(p.marca), '')),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  categoria = case
    when coalesce(nullif(trim(p.categoria), ''), 'Otro') in ('Otro', '') then t.categoria
    else p.categoria
  end,
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  proveedor = coalesce(nullif(trim(p.proveedor), ''), 'City Mark')
from _fc_cm20260905 t
where p.id = public.fc_buscar_producto_escaneo(t.ean);

-- Enlaza renglones de este folio. No toca confirmado / MMAA / lote.
update public.recepcion_items i
set
  producto_id = public.fc_buscar_producto_escaneo(i.codigo_escaneado),
  pendiente_alta = false
from public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260905'
  and coalesce(r.proveedor, '') ilike '%city mark%'
  and public.fc_buscar_producto_escaneo(i.codigo_escaneado) is not null
  and (i.pendiente_alta or i.producto_id is null);

select
  count(*) filter (where public.fc_buscar_producto_escaneo(t.ean) is null) as siguen_sin_alta,
  count(*) as lineas_ticket
from _fc_cm20260905 t;

commit;

-- Stock de renglones ya verdes con MMAA y sin lote (si el RPC está).
select
  case
    when exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'recepcion_reparar_stock_huerfanos'
    ) then public.recepcion_reparar_stock_huerfanos(null)
    else jsonb_build_object('skipped', 'falta patch_recepcion_verde_sin_stock_20260903')
  end as reparacion_stock;

select
  r.id as recepcion_id,
  r.estado,
  count(i.*) as renglones,
  count(*) filter (where i.pendiente_alta) as pendiente_alta,
  count(*) filter (where i.confirmado and i.lote_id is not null) as con_stock,
  count(*) filter (where i.confirmado and i.lote_id is null) as verde_sin_lote
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '20260905' and coalesce(r.proveedor, '') ilike '%city mark%'
group by r.id, r.estado
order by r.id desc;

select
  i.codigo_escaneado as ean,
  left(coalesce(p.nombre, i.nombre_snapshot), 52) as nombre,
  i.cantidad,
  i.pendiente_alta,
  i.confirmado,
  i.lote_id is not null as en_anaquel,
  p.stock
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
left join public.productos p on p.id = i.producto_id
where r.folio = '20260905' and coalesce(r.proveedor, '') ilike '%city mark%'
order by i.pendiente_alta desc, i.id;
