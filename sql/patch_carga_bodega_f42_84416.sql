-- Bodega F-42 Ejidos del Moral · Caja 3/84416 · 2026-09-30 16:47
-- 89 renglones / 128 piezas · subtotal $6,010.44 + impuestos $961.66 = $6,972.10.
-- Costo = P.U. impreso (las líneas ya suman al total con IVA).
-- Ítem 46 Grisi Ricitos Biopure: EAN cortado en foto; match por SKU al escanear.
-- Piezas ticket (suma qty): 128. Total $6972.10.
-- 89 alta(s) stock 0. 0 ya estaban: solo costo / ficha vacía, no PVP.
-- Sin EAN (match por SKU): FC-F42-JBNGRISIRICITOSO.
-- Costo = P.U. unitario del ticket (NUNCA el importe del renglón).
-- Caducidad NO del papel: MMAA de la caja. No inventar 0000.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_84416 (
  linea integer primary key,
  ean text,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,3) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_bf42_84416 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7798140259893', 'FC-40259893', 'Shampoo Tio Nacho Ant-Dano Aloe 415Ml', 'SH TIO NACHO ANT-DANO ALOE 415ML', 1, 85.84, 108, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (2, '650240057489', 'FC-40057489', 'Shampoo Tio Nacho A-Cai C-Madre 415Ml', 'SH TIO NACHO A-CAI C-MADRE 415ML', 1, 85.84, 108, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (3, '650240035166', 'FC-40035166', 'Shampoo Tio Nacho Antica En 415Ml', 'SH TIO NACHO ANTICA EN 415ML', 1, 86.83, 109, 'marca', 'Cuidado personal', null, 'Cabello', 'Tío Nacho', null, 'Pieza', null, null, false, false, null, null, null),
  (4, '7500435129367', 'FC-35129367', 'Desodorante Secret Ph-Balan Stick Gel45G', 'DESOD SECRET PH-BALAN STICK GEL45G', 3, 59.11, 74, 'marca', 'Cuidado personal', null, 'Desodorante', 'Secret', null, 'Pieza', null, null, false, false, null, null, null),
  (5, '4005900841483', 'FC-00841483', 'Crema Niv Sun After C/Aloe 200 Ml', 'CRA NIV SUN AFTER C/ALOE 200 ML', 1, 85.97, 108, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (6, '7506306238640', 'FC-06238640', 'Jabón Camay 72', 'JBN CAMAY 72', 3, 15.473, 20, 'marca', 'Cuidado personal', null, 'Pieza', 'Camay', null, 'Pieza', null, null, false, false, null, null, null),
  (7, '7501943489066', 'FC-43489066', 'Jabón Escudo Bco Neutro 110G C/3', 'JBN ESCUDO BCO NEUTRO 110G C/3', 1, 37.50, 47, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (8, '7501943489073', 'FC-43489073', 'Jabón Escudo Azul Natura 110G C/3', 'JBN ESCUDO AZUL NATURA 110G C/3', 1, 37.49, 47, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (9, '4005808944385', 'FC-08944385', 'Bloqueador Nivea Sunkidswimfp50150M', 'BLOQ NIVEA SUNKIDSWIMFP50150M', 1, 235.85, 295, 'marca', 'Cuidado personal', null, 'Protector solar', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (10, '42419860', 'FC-42419860', 'Crema Niv A-Bacte 3En1 P/Manos 75Ml', 'CRA NIV A-BACTE 3EN1 P/MANOS 75ML', 1, 45.92, 58, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (11, '42360537', 'FC-42360537', 'Crema Nivea Aclar Nat P/Mano 75Ml Mar27', 'CRA NIVEA ACLAR NAT P/MANO 75ML MAR27', 2, 52.94, 67, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (12, '4005900645289', 'FC-00645289', 'Gel Nivea Facial Limp Rosas 150Ml', 'GEL NIVEA FACIAL LIMP ROSAS 150ML', 1, 104.46, 131, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (13, '4006000068565', 'FC-00068565', 'Agua micelar Nivea Reparadora 400Ml', 'AGUA MICE NIVEA REPARADORA 400ML', 1, 118.87, 149, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (14, '4006000273839', 'FC-00273839', 'Agua micelar Nivea Luminou Glow 400Mln', 'AGUA MIC NIVEA LUMINOU GLOW 400MLN', 1, 113.85, 143, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (15, '4006000173108', 'FC-00173108', 'Agua micelar Nivea Derma Skin 400Ml N', 'AGUA MICE NIVEA DERMA SKIN 400ML N', 1, 115.06, 144, 'marca', 'Cuidado personal', null, 'Pieza', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (16, '7791293025803', 'FC-93025803', 'Desodorante Axe Men Excite Spy 150Ml', 'DESOD AXE MEN EXCITE SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (17, '42417644', 'FC-42417644', 'Crema Nivea Cuidado Int P/Mano 75Ml', 'CRA NIVEA CUIDADO INT P/MANO 75ML', 1, 48.58, 61, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (18, '7501054514381', 'FC-54514381', 'Crema Nivea Soft Fac-Corp 200Ml', 'CRA NIVEA SOFT FAC-CORP 200ML', 1, 81.61, 103, 'marca', 'Cuidado personal', null, 'Crema', 'Nivea', null, 'Pieza', null, null, false, false, null, null, null),
  (19, '7794640170133', 'FC-40170133', 'Crema dental Sensodyne Repar-Prot 100G', 'C D SENSODYNE REPAR-PROT 100G', 2, 122.765, 154, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Sensodyne', null, 'Pieza', null, null, false, false, null, null, null),
  (20, '7794640171550', 'FC-40171550', 'Crema dental Sensodyne Rapido Alivio 100G', 'C D SENSODYNE RAPIDO ALIVIO 100G', 2, 117.67, 148, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Sensodyne', null, 'Pieza', null, null, false, false, null, null, null),
  (21, '7506306244795', 'FC-06244795', 'Desodorante Axe Intense 48H Spy 150Ml', 'DESOD AXE INTENSE 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (22, '7506306226852', 'FC-06226852', 'Desodorante Axe Nom Anarchy Spy 150Ml', 'DESOD AXE NOM ANARCHY SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (23, '7791293025797', 'FC-93025797', 'Desodorante Axe Men Dark Temp Spy150Ml', 'DESOD AXE MEN DARK TEMP SPY150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (24, '7506306209855', 'FC-06209855', 'Desodorante Axe Anarc Flo 48H Spy 150Ml', 'DESOD AXE ANARC FLO 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', null, 'Desodorante', 'Axe', null, 'Pieza', null, null, false, false, null, null, null),
  (25, '7506339349030', 'FC-39349030', 'Deo Old Spice Sport Spy 150Ml', 'DEO OLD SPICE SPORT SPY 150ML', 3, 57.17, 72, 'marca', 'Cuidado personal', null, 'Desodorante', 'Old Spice', null, 'Pieza', null, null, false, false, null, null, null),
  (26, '7506346604498', 'FC-46604498', 'Botiquin Kohn Primeros Auxilios', 'BOTIQUIN KOHN PRIMEROS AUXILIOS', 1, 98.99, 124, 'marca', 'Botiquín', null, 'Botiquín', 'Kohn', null, 'Pieza', null, null, false, false, null, null, null),
  (27, '070330736580', 'FC-30736580', 'Bic Flex 3 Bl C/2 Oferta 15%', 'BIC FLEX 3 BL C/2 OFERTA 15%', 1, 51.85, 65, 'marca', 'Cuidado personal', null, 'Pieza', 'BIC', null, 'Pieza', null, null, false, false, null, null, null),
  (28, '7702018072408', 'FC-18072408', 'Maq Gtte Venus Simply3 C/4', 'MAQ GTTE VENUS SIMPLY3 C/4', 1, 100.15, 126, 'marca', 'Cuidado personal', null, 'Pieza', 'Gillette', null, 'Pieza', null, null, false, false, null, null, null),
  (29, '037836051401', 'FC-36051401', 'Jabón Cdpr Grisi 450Ml Shower Gel Coco', 'JBN CDPR GRISI 450ML SHOWER GEL COCO', 1, 54.37, 68, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (30, '7891024030813', 'FC-24030813', 'Enjuague bucal Colgate Sens Pro-Aliv 250Ml', 'ENJ BUC COLGATE SENS PRO-ALIV 250ML', 2, 64.775, 81, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Colgate', null, 'Pieza', null, null, false, false, null, null, null),
  (31, '7509546666959', 'FC-46666959', 'Enjuague bucal Colga Total Enc-Sal 250Ml', 'ENJ BUC COLGA TOTAL ENC-SAL 250ML', 2, 57.79, 73, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Colgate', null, 'Pieza', null, null, false, false, null, null, null),
  (32, '7891010258699', 'FC-10258699', 'Shampoo Johnsons Kids 2 En 1 400 Ml N', 'SH JOHNSONS KIDS 2 EN 1 400 ML N', 1, 87.02, 109, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null),
  (33, '7702031293231', 'FC-31293231', 'Shampoo Johnsons Baby Manzanilla 200Ml', 'SH JOHNSONS BABY MANZANILLA 200ML', 1, 60.67, 76, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null),
  (34, '7509546695587', 'FC-46695587', 'Crema Palmol Opt P/Pein Kerat 250Mln', 'CRA PALMOL OPT P/PEIN KERAT 250MLN', 1, 36.67, 46, 'marca', 'Cuidado personal', null, 'Crema', 'Palmolive', null, 'Pieza', null, null, false, false, null, null, null),
  (35, '7509552963366', 'FC-52963366', 'Shampoo Elvive Glycolic Cristal 680 Mln', 'SH ELVIVE GLYCOLIC CRISTAL 680 MLN', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (36, '037836050312', 'FC-36050312', 'Jabón Liq Grisi Lech/Burr 450Ml', 'JBN LIQ GRISI LECH/BURR 450ML', 1, 53.74, 68, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (37, '810120501260', 'FC-20501260', 'Grisi 450Ml Jabón Liq Aloe Vera', 'GRISI 450ML JBN LIQ ALOE VERA', 1, 52.51, 66, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (38, '7501007528427', 'FC-07528427', 'Crema Lubrid Rep/Int Sens 400Ml', 'CRA LUBRID REP/INT SENS 400ML', 1, 96.76, 121, 'marca', 'Cuidado personal', null, 'Crema', 'Lubriderm', null, 'Pieza', null, null, false, false, null, null, null),
  (39, '7501943489165', 'FC-43489165', 'Jabón Liq Escudo Blanco Neut 225Ml', 'JBN LIQ ESCUDO BLANCO NEUT 225ML', 3, 24.507, 31, 'marca', 'Cuidado personal', null, 'Pieza', 'Escudo', null, 'Pieza', null, null, false, false, null, null, null),
  (40, '7506195148679', 'FC-95148679', 'Shampoo H&S 2 En 1 Sve-Man 90Ml', 'SH H&S 2 EN 1 SVE-MAN 90ML', 2, 15.15, 19, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (41, '7506195148686', 'FC-95148686', 'Shampoo H&S Limp Renov 90Ml', 'SH H&S LIMP RENOV 90ML', 2, 15.19, 19, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (42, '7509552816266', 'FC-52816266', 'Shampoo Fructis Oil-R Liso Coco 650Ml', 'SH FRUCTIS OIL-R LISO COCO 650ML', 1, 90.90, 114, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (43, '7501026462092', 'FC-26462092', 'Ternura 18 Pzs Chupon Ortodontico', 'TERNURA 18 PZS CHUPON ORTODONTICO', 2, 78.02, 98, 'marca', 'Bebé', null, 'Accesorio', 'Ternura', null, 'Pieza', null, null, false, false, null, null, null),
  (44, '850040940732', 'FC-40940732', 'Ricitos De Oro 250Ml Aloe Y Calendula', 'RICITOS DE ORO 250ML ALOE Y CALENDULA', 1, 46.64, 59, 'marca', 'Cuidado personal', null, 'Pieza', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (45, '7501022133019', 'FC-22133019', 'Ricitos De Oro 400Ml Shampoo Lavanda + Plastil', 'RICITOS DE ORO 400ML SH LAVANDA + PLASTIL', 1, 64.08, 81, 'marca', 'Cuidado personal', null, 'Cabello', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (46, null, 'FC-F42-JBNGRISIRICITOSO', 'Jabón Grisi Ricitos Oro Biopure 90G', 'JBN GRISI RICITOS ORO BIOPURE 90G', 2, 22.325, 28, 'marca', 'Cuidado personal', null, 'Pieza', 'Grisi', null, 'Pieza', null, null, false, false, null, null, null),
  (47, '7509546654997', 'FC-46654997', 'Mousse Caprice Final Touch 200 G', 'MOUSSE CAPRICE FINAL TOUCH 200 G', 2, 54.44, 69, 'marca', 'Cuidado personal', null, 'Cabello', 'Caprice', null, 'Pieza', null, null, false, false, null, null, null),
  (48, '7506306257610', 'FC-06257610', 'Desodorante Polvo Rexona Eficc Fresh 200 G', 'DESOD PVO REXONA EFICC FRESH 200 G', 1, 66.78, 84, 'marca', 'Cuidado personal', null, 'Cabello', 'Rexona', null, 'Pieza', null, null, false, false, null, null, null),
  (49, '7509546695570', 'FC-46695570', 'Crema Palmo Opt P/Pein Ker Rh 250Mln', 'CRA PALMO OPT P/PEIN KER RH 250MLN', 1, 36.67, 46, 'marca', 'Cuidado personal', null, 'Crema', null, null, 'Pieza', null, null, false, false, null, null, null),
  (50, '7501361121500', 'FC-61121500', 'Odolex Naturals 150Gr Talco Desodorante', 'ODOLEX NATURALS 150GR TALCO DESODORANTE', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Desodorante', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (51, '7501361124013', 'FC-61124013', 'Talco Odolex Fresh 150G', 'TCO ODOLEX FRESH 150G', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Cabello', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (52, '7501048690046', 'FC-48690046', 'Protec 13 Pzs Botiquin Primeros Auxilios', 'PROTEC 13 PZS BOTIQUIN PRIMEROS AUXILIOS', 1, 78.78, 99, 'marca', 'Botiquín', null, 'Botiquín', 'Protect', null, 'Pieza', null, null, false, false, null, null, null),
  (53, '7500435171038', 'FC-35171038', 'Cepillo dental Oral-B 40 Suave 2Pz', 'CEP DENT ORAL-B 40 SUAVE 2PZ', 2, 34.43, 44, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (54, '070942302401', 'FC-42302401', 'Hilo dental Gum Expanding 40 Mts', 'HILO DENT GUM EXPANDING 40 MTS', 2, 64.37, 81, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'GUM', null, 'Pieza', null, null, false, false, null, null, null),
  (55, '7501006711387', 'FC-06711387', 'Cepillo dental Pro D-Out 2X1Med', 'CEP DENT PRO D-OUT 2X1MED', 1, 38.56, 49, 'marca', 'Cuidado personal', null, 'Higiene bucal', null, null, 'Pieza', null, null, false, false, null, null, null),
  (56, '3014260014445', 'FC-60014445', 'Cepillo dental Oral-B Comple Sve 40 2X1', 'CEP DENT ORAL-B COMPLE SVE 40 2X1', 2, 40.54, 51, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (57, '7501086494286', 'FC-86494286', 'Cepillo dental Oral-B Gde 60 Sve', 'CEP DENT ORAL-B GDE 60 SVE', 1, 31.02, 39, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (58, '7501086494262', 'FC-86494262', 'Cepillo dental Oral-B Indicat35Sve', 'CEP DENT ORAL-B INDICAT35SVE', 1, 31.02, 39, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'Oral-B', null, 'Pieza', null, null, false, false, null, null, null),
  (59, '7509546655055', 'FC-46655055', 'Mousse Caprice Volum-Ctrl 200 G', 'MOUSSE CAPRICE VOLUM-CTRL 200 G', 2, 54.44, 69, 'marca', 'Cuidado personal', null, 'Cabello', 'Caprice', null, 'Pieza', null, null, false, false, null, null, null),
  (60, '7501056342258', 'FC-56342258', 'Crema Sedal Recons Estructur 135Ml', 'CRA SEDAL RECONS ESTRUCTUR 135ML', 2, 18.165, 23, 'marca', 'Cuidado personal', null, 'Crema', 'Sedal', null, 'Pieza', null, null, false, false, null, null, null),
  (61, '7501056340100', 'FC-56340100', 'Crema Sedal Anti Sponge 300 Ml', 'CRA SEDAL ANTI SPONGE 300 ML', 2, 50.065, 63, 'marca', 'Cuidado personal', null, 'Crema', 'Sedal', null, 'Pieza', null, null, false, false, null, null, null),
  (62, '7509552992304', 'FC-52992304', 'Acondicionador Elvive Colageno 370Ml', 'ACOND ELVIVE COLAGENO 370ML', 1, 70.63, 89, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (63, '7501943418349', 'FC-43418349', 'Jabón Kbb Max Mznll-Aloe Vera 75G', 'JBN KBB MAX MZNLL-ALOE VERA 75G', 2, 11.675, 15, 'marca', 'Cuidado personal', null, 'Pieza', 'KBB', null, 'Pieza', null, null, false, false, null, null, null),
  (64, '037836033742', 'FC-36033742', 'Shampoo Ricitos De Oro Lech Almen 250Ml', 'SH RICITOS DE ORO LECH ALMEN 250ML', 1, 67.71, 85, 'marca', 'Cuidado personal', null, 'Cabello', 'Ricitos de Oro', null, 'Pieza', null, null, false, false, null, null, null),
  (65, '7500435258425', 'FC-35258425', 'Shampoo H&S 90Ml Romero Anti Caida C24', 'SH H&S 90ML ROMERO ANTI CAIDA C24', 2, 17.05, 22, 'marca', 'Cuidado personal', null, 'Cabello', 'Head & Shoulders', null, 'Pieza', null, null, false, false, null, null, null),
  (66, '7501361111501', 'FC-61111501', 'Talco Desodorante Odolex 150 G', 'TCO DESOD ODOLEX 150 G', 1, 17.77, 23, 'marca', 'Cuidado personal', null, 'Desodorante', 'Odolex', null, 'Pieza', null, null, false, false, null, null, null),
  (67, '7501101311055', 'FC-01311055', 'Super Wet 250Gr Gel Fij Plus Invis', 'SUPER WET 250GR GEL FIJ PLUS INVIS', 2, 13.93, 18, 'marca', 'Cuidado personal', null, 'Pieza', 'Super Wet', null, 'Pieza', null, null, false, false, null, null, null),
  (68, '7501007457796', 'FC-07457796', 'Shampoo Pant Brillo Extremo 400 Ml', 'SH PANT BRILLO EXTREMO 400 ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (69, '7501007457802', 'FC-07457802', 'Sh. Pantene Brillo Extremo 750Ml', 'SH. PANTENE BRILLO EXTREMO 750ML', 1, 109.68, 138, 'marca', 'Cuidado personal', null, 'Pieza', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (70, '7501001165321', 'FC-01165321', 'Acondicionador Pant Rizos Definid 400Ml', 'ACOND PANT RIZOS DEFINID 400ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (71, '7502235820369', 'FC-35820369', 'Hilo dental Gum Expanding 10.9 M', 'HILO DENT GUM EXPANDING 10.9 M', 2, 21.575, 27, 'marca', 'Cuidado personal', null, 'Higiene bucal', 'GUM', null, 'Pieza', null, null, false, false, null, null, null),
  (72, '7506306257603', 'FC-06257603', 'Polvo Desodorante Rexona Effi Ant-Pro 200G', 'PVO DESOD REXONA EFFI ANT-PRO 200G', 1, 64.12, 81, 'marca', 'Cuidado personal', null, 'Desodorante', 'Rexona', null, 'Pieza', null, null, false, false, null, null, null),
  (73, '7702031244509', 'FC-31244509', 'Crema Lubriderm P Normal 400Ml', 'CRA LUBRIDERM P NORMAL 400ML', 1, 96.76, 121, 'marca', 'Cuidado personal', null, 'Crema', 'Lubriderm', null, 'Pieza', null, null, false, false, null, null, null),
  (74, '7509552874983', 'FC-52874983', 'Shampoo Elvive Hidra Hialu Pure 680Ml', 'SH ELVIVE HIDRA HIALU PURE 680ML', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (75, '7503002163023', 'FC-02163023', 'Gel X-Treme Transp 250 G', 'GEL X-TREME TRANSP 250 G', 4, 24.302, 31, 'marca', 'Cuidado personal', null, 'Cabello', 'X-Treme', null, 'Pieza', null, null, false, false, null, null, null),
  (76, '7501007457826', 'FC-07457826', 'Acondicionador Pant Brillo Extremo 400Ml', 'ACOND PANT BRILLO EXTREMO 400ML', 1, 75.70, 95, 'marca', 'Cuidado personal', null, 'Cabello', 'Pantene', null, 'Pieza', null, null, false, false, null, null, null),
  (77, '7502224510042', 'FC-24510042', 'Silica Seda Pure 3N1 Kids 120Ml', 'SILICA SEDA PURE 3N1 KIDS 120ML', 1, 58.56, 74, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (78, '7502245720062', 'FC-45720062', 'Silica Silkhair-F Naranja 120 Ml', 'SILICA SILKHAIR-F NARANJA 120 ML', 2, 33.165, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (79, '7502245720109', 'FC-45720109', 'Silica Silkhair-F Uva 60 Ml', 'SILICA SILKHAIR-F UVA 60 ML', 2, 20.975, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (80, '7502245720086', 'FC-45720086', 'Silica Silkhair-F Coco 120 Ml', 'SILICA SILKHAIR-F COCO 120 ML', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (81, '7502245720079', 'FC-45720079', 'Silkhair Uva 120Ml Silica', 'SILKHAIR UVA 120ML SILICA', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (82, '7502245720116', 'FC-45720116', 'Silkhair Nja 60Ml Silica', 'SILKHAIR NJA 60ML SILICA', 2, 20.975, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (83, '7502224510097', 'FC-24510097', 'Silica Seda Pure 3N1 Papaya 120Ml', 'SILICA SEDA PURE 3N1 PAPAYA 120ML', 1, 58.55, 74, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (84, '7502245720222', 'FC-45720222', 'Silkhair Cereza 60 Ml Silica', 'SILKHAIR CEREZA 60 ML SILICA', 1, 20.97, 27, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (85, '7502245720093', 'FC-45720093', 'Silica Silkhair-F Cerez/Fresa 120Ml', 'SILICA SILKHAIR-F CEREZ/FRESA 120ML', 1, 33.16, 42, 'marca', 'Cuidado personal', null, 'Cabello', 'Sílice', null, 'Pieza', null, null, false, false, null, null, null),
  (86, '7509552908718', 'FC-52908718', 'Shampoo Fructis Borrador Dand 650Ml', 'SH FRUCTIS BORRADOR DAND 650ML', 1, 78.53, 99, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (87, '7509552817393', 'FC-52817393', 'Shampoo Elvive Color-Vive Uv 680 Ml', 'SH ELVIVE COLOR-VIVE UV 680 ML', 1, 110.46, 139, 'marca', 'Cuidado personal', null, 'Cabello', 'Elvive', null, 'Pieza', null, null, false, false, null, null, null),
  (88, '7509552962628', 'FC-52962628', 'Shampoo Fructis Control Grasa 650 Ml N', 'SH FRUCTIS CONTROL GRASA 650 ML N', 1, 84.67, 106, 'marca', 'Cuidado personal', null, 'Cabello', 'Fructis', null, 'Pieza', null, null, false, false, null, null, null),
  (89, '7702031293286', 'FC-31293286', 'Shampoo Johnson''S Baby Cabe Osc 200 Ml', 'SH JOHNSON''S BABY CABE OSC 200 ML', 1, 60.67, 76, 'marca', 'Cuidado personal', null, 'Cabello', 'Johnson''s', null, 'Pieza', null, null, false, false, null, null, null);

insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when nullif(btrim(t.ean), '') is not null and exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  nullif(btrim(t.ean), ''),
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 Ejidos del Moral 84416 · 2026-09-30 · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bf42_84416
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where (
    nullif(btrim(t.ean), '') is null
    or public.fc_buscar_producto_escaneo(t.ean) is null
  )
  and public.fc_buscar_producto_escaneo(t.sku) is null;

update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bf42_84416
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

update public.productos p
set
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(
    nullif(trim(p.codigo_barras), ''),
    nullif(btrim(t.ean), '')
  )
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bf42_84416
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
where p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.proveedores (nombre, activo)
select 'Bodega F-42 Ejidos del Moral', true
where not exists (
  select 1 from public.proveedores
  where lower(btrim(nombre)) = lower('Bodega F-42 Ejidos del Moral')
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42 Ejidos del Moral',
  '84416',
  '2026-09-30',
  6972.10,
  'borrador',
  'Bodega F-42 84416 · 30-sep-2026 · P.U. con IVA · MMAA de la caja'
where not exists (
  select 1 from public.recepciones
  where folio = '84416'
    and coalesce(proveedor, '') ilike '%F-42%'
);

update public.recepciones
set
  total_ticket = 6972.10,
  fecha = '2026-09-30',
  proveedor = 'Bodega F-42 Ejidos del Moral',
  notas = 'Bodega F-42 84416 · 30-sep-2026 · P.U. con IVA · MMAA de la caja',
  updated_at = now()
where folio = '84416'
  and coalesce(proveedor, '') ilike '%F-42%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '84416'
  and coalesce(r.proveedor, '') ilike '%F-42%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  nullif(btrim(t.ean), ''),
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_bf42_84416 t
join public.recepciones r
  on r.folio = '84416'
 and coalesce(r.proveedor, '') ilike '%F-42%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    case when nullif(btrim(t.ean), '') is not null
      then public.fc_buscar_producto_escaneo(t.ean) end,
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  p.id,
  t.imagen,
  t.foto_file,
  coalesce((
    select max(i.posicion) from public.producto_imagenes i
    where i.producto_id = p.id
  ), 0) + 1,
  not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.es_principal
  ),
  'propia'
from (
  select distinct on (coalesce(nullif(btrim(ean), ''), sku)) *
  from _fc_bf42_84416
  order by coalesce(nullif(btrim(ean), ''), sku), linea
) t
join public.productos p on p.id = coalesce(
  case when nullif(btrim(t.ean), '') is not null
    then public.fc_buscar_producto_escaneo(t.ean) end,
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id and i.url = t.imagen
  );

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '84416'
  and coalesce(r.proveedor, '') ilike '%F-42%'
order by i.id;
