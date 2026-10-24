-- Bodega F-42 Ejidos del Moral · Caja 4/28130 · 2026-10-24 12:39
-- Ticket térmico. Subtotal $4,553.92 + impuestos $728.58 = $5,282.50.
-- Costo = P.U. impreso (ya con IVA; suma de renglones = total tarjeta).
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 58 alta(s) stock 0. 15 ya estaban (snapshot ago-2026): solo costo / ficha vacía, no PVP.
-- Nombres de mostrador, no del ticket. Fotos: TODO packshot (sin placeholder competencia).
-- Códigos cortos Rexona (8 dígitos) tal cual en ticket Walmart; pistola puede traer EAN completo.
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_bf42_28130 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
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

insert into _fc_bf42_28130 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7506078972292', 'FC-78972292', 'Obao Piel Delicada spray 150 ml', 'DESOD OBAO PIEL DEL SPY 150ML', 1, 43.41, 55, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Obao', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (2, '7509552909814', 'FC-52909814', 'Obao Rosa Tentación 48h spray 150 ml', 'DESOD OBAO RSA TEN 48H SPY 150ML', 1, 43.41, 55, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Obao', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (3, '7506306226722', 'FC-06226722', 'Axe Men Young spray 150 ml', 'DESOD AXE MEN YOUNG SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, true, null, null, null),
  (4, '7509552844795', 'FC-52844795', 'Obao Ritual Natural Coco spray 150 ml', 'DESOD OBAO R-NAT COCO SPY 150ML', 1, 42.41, 54, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Obao', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (5, '7506306226739', 'FC-06226739', 'Axe Men Conviction spray 150 ml', 'DESOD AXE MEN CONVICT SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, true, null, null, null),
  (6, '7506306213081', 'FC-06213081', 'Axe Music Fresh 48h spray 150 ml', 'DESOD AXE MUSIC FRES 48H SPY150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (7, '75062804', 'FC-75062804', 'Rexona Antibacterial + Aclarante roll-on 50 ml', 'DESOD REXONA ANTIB+ACLA R-ON 50ML', 1, 33.74, 43, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', null, 'Roll-on 50 ml', null, null, false, false, null, null, null),
  (8, '7506306245686', 'FC-06245686', 'Axe Men Epic Fresh 48h spray 150 ml', 'DESOD AXE MEN EPIC-F 48H SPY 150ML', 2, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, true, null, null, null),
  (9, '7501868920163', 'FC-68920163', 'Dibar gel antibacterial 500 ml', 'DIBAR GEL 500ML ANTIBAC', 2, 35.24, 45, 'marca', 'Cuidado personal', 'Antibacterial', 'Gel', 'Dibar', null, 'Frasco 500 ml', null, null, false, false, null, null, null),
  (10, '75085513', 'FC-75085513', 'Rexona Men Invisible Balm Milk & Peonia barra 41 g', 'DESOD REXONA 41G BARRA MEN INVIS BALM MLCTN &PEONIA', 2, 55.68, 70, 'marca', 'Cuidado personal', 'Desodorante', 'Barra', 'Rexona', null, 'Barra 41 g', null, null, false, false, null, null, null),
  (11, '7506306244795', 'FC-06244795', 'Axe Intense 48h spray 150 ml', 'DESOD AXE INTENSE 48H SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, true, null, null, null),
  (12, '75081669', 'FC-75081669', 'Rexona Powder Dry roll-on 50 ml', 'DEO ROLL ON REXONA POW 50ML', 1, 30.13, 38, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', null, 'Roll-on 50 ml', null, null, false, false, null, null, null),
  (13, '7506376000284', 'FC-76000284', 'Vitacilina agua micelar rosa-sábila 500 ml', 'AGUA MIC VITACILINA ROS-SAB 500MLN', 1, 81.47, 102, 'marca', 'Cuidado personal', 'Limpieza facial', 'Líquido', 'Vitacilina', null, 'Frasco 500 ml', null, null, false, true, null, null, null),
  (14, '7506078928565', 'FC-78928565', 'L''Oréal desmaquillante bifásico 200 ml', 'DESMAQ L''OREAL 200ML BIFASICO', 1, 118.13, 148, 'marca', 'Cuidado personal', 'Desmaquillante', 'Líquido', 'L''Oréal', null, 'Frasco 200 ml', null, null, false, false, null, null, null),
  (15, '75075996', 'FC-75075996', 'Rexona Happy Morning 48h roll-on 50 ml', 'DESOD REXON HAPPY MOR 48H R-ON 50ML', 1, 34.79, 44, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', null, 'Roll-on 50 ml', null, null, false, false, null, null, null),
  (16, '78924345', 'FC-78924345', 'Rexona Women Bamboo roll-on 50 ml', 'DESOD REXONA WOM BAMBOO R-ON 50ML', 1, 30.13, 38, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', null, 'Roll-on 50 ml', null, null, false, false, null, null, null),
  (17, '7502254073821', 'FC-54073821', 'Glesol Fresh desinfectante antibacterial 443 ml', 'DESINFEC ANTIB GLESOL FRESH 443ML', 2, 68.19, 86, 'marca', 'Cuidado personal', 'Desinfectante', 'Líquido', 'Glesol', null, 'Frasco 443 ml', null, null, false, false, null, null, null),
  (18, '759684154140', 'FC-84154140', 'Jaloma gel antibacterial 120 ml', 'JALOMA 120ML GEL ANTIBACTERIAL', 3, 18.18, 23, 'marca', 'Cuidado personal', 'Antibacterial', 'Gel', 'Jaloma', null, 'Frasco 120 ml', null, null, false, false, null, null, null),
  (19, '037836051555', 'FC-36051555', 'Grisi jabón líquido para manos neutro 480 ml', 'JBN LIQ GRISI P MANO NEUTRO 480 ML', 1, 45.98, 58, 'marca', 'Cuidado personal', 'Higiene de manos', 'Líquido', 'Grisi', null, 'Frasco 480 ml', null, null, false, false, null, null, null),
  (20, '7501022151198', 'FC-22151198', 'Grisi jabón líquido para manos fresia 480 ml', 'JBN LIQ GRISI P-MANO FRESIA 480ML', 1, 45.98, 58, 'marca', 'Cuidado personal', 'Higiene de manos', 'Líquido', 'Grisi', null, 'Frasco 480 ml', null, null, false, false, null, null, null),
  (21, '7501082731064', 'FC-82731064', 'Nuvel Soft Woman spray 170 ml', 'DESOD NUVEL SOFTY WOM SPY 170 ML', 2, 32.73, 41, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', null, 'Spray 170 ml', null, null, false, false, null, null, null),
  (22, '7501082731071', 'FC-82731071', 'Nuvel Tropic Woman spray 170 ml', 'DESOD NUVEL TROPIC WOM SPY 170 ML', 2, 32.73, 41, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', null, 'Spray 170 ml', null, null, false, false, null, null, null),
  (23, '7500435107389', 'FC-35107389', 'Old Spice Bearglove spray 150 ml', 'DESOD OLD SPICE BEAR GLOV SPY 150ML', 2, 59.45, 75, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Old Spice', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (24, '7500435257008', 'FC-35257008', 'Old Spice Paradise spray 150 ml', 'DESOD OLD SPICE 150ML SPY PARADISE', 2, 59.48, 75, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Old Spice', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (25, '7506309839141', 'FC-09839141', 'Old Spice Wolfthorn Anti spray 150 ml', 'DESOD OLD SPICE WOLF ANTI SPY 150ML', 2, 56.23, 71, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Old Spice', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (26, '7506339349146', 'FC-39349146', 'Old Spice Wolfthorn spray 150 ml', 'DESOD OLD SPICE WOLFTHORN SPY 150ML', 2, 59.84, 75, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Old Spice', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (27, '7501082731057', 'FC-82731057', 'Nuvel Fusion Men spray 160 ml', 'DESOD NUVEL FUSION MEN SPY 160ML', 1, 32.72, 41, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', null, 'Spray 160 ml', null, null, false, false, null, null, null),
  (28, '75085537', 'FC-75085537', 'Rexona Men Invisible Balm Mint Fresh barra 41 g', 'DESOD REXONA 41G BARRA MEN INVIS BALM MINT FRESH', 2, 55.68, 70, 'marca', 'Cuidado personal', 'Desodorante', 'Barra', 'Rexona', null, 'Barra 41 g', null, null, false, false, null, null, null),
  (29, '75085520', 'FC-75085520', 'Rexona Men Invisible Balm Ocean Fresh barra 41 g', 'DESOD REXONA 41G BARRA MEN INVIS BALM OCEAN FRESH', 2, 55.68, 70, 'marca', 'Cuidado personal', 'Desodorante', 'Barra', 'Rexona', null, 'Barra 41 g', null, null, false, false, null, null, null),
  (30, '7501082731040', 'FC-82731040', 'Nuvel Devotion Men spray 170 ml', 'DEO NUVEL SPY 170ML MEN DEVOTION', 1, 32.72, 41, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', null, 'Spray 170 ml', null, null, false, false, null, null, null),
  (31, '7501082736021', 'FC-82736021', 'Nuvel Aclarante Woman spray 150 ml', 'DEO NUVEL ACLA WOM SPY150ML', 2, 35.45, 45, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Nuvel', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (32, '7791293036052', 'FC-93036052', 'Rexona Women Flores Blancas spray 150 ml', 'DESOD REXONA WOM FLORESB SPY150ML', 2, 54.68, 69, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Rexona', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (33, '7501054504535', 'FC-54504535', 'Nivea Body Milk Extra Seca 400 ml', 'CRA NIVEA B MILK EXTSCA 400 ML', 2, 84.50, 106, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Nivea', null, 'Frasco 400 ml', null, null, false, true, null, null, null),
  (34, '4005900581341', 'FC-00581341', 'Nivea Milk Nutritiva piel extra seca 625 ml', 'CRM NIVEA MILK NUTRITIVA PIEL EXTRA SECA 625ML', 2, 113.64, 143, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Nivea', null, 'Frasco 625 ml', null, null, false, false, null, null, null),
  (35, '7506306202832', 'FC-06202832', 'Axe Collision spray 150 ml', 'DESOD AXE COLLISION SPY150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (36, '4005808802836', 'FC-08802836', 'Nivea Soft Milk seca 400 ml', 'CRA NIVEA B SOFMILK SEC400ML', 2, 84.50, 106, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Nivea', null, 'Frasco 400 ml', null, null, false, false, null, null, null),
  (37, '7501082790504', 'FC-82790504', 'Nuvel desmaquillante bifásico oil 125 ml', 'DESMAQ BIFASICO OIL NUVEL 125ML', 3, 27.75, 35, 'marca', 'Cuidado personal', 'Desmaquillante', 'Líquido', 'Nuvel', null, 'Frasco 125 ml', null, null, false, true, null, null, null),
  (38, '810120501673', 'FC-20501673', 'Hinds Agave Azul crema líquida 400 ml', 'CRA HINDS LIQ AGAVE AZUL 400ML', 1, 42.25, 53, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 400 ml', null, null, false, false, null, null, null),
  (39, '037836041273', 'FC-36041273', 'Hinds Rosa crema corporal 400 ml', 'HINDS ROSA 400ML CREMA CORPORAL', 1, 49.97, 63, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 400 ml', null, null, false, false, null, null, null),
  (40, '037836041259', 'FC-36041259', 'Hinds Rosa crema líquida 90 ml', 'CRA HINDS LIQ RSA RCA 90ML', 2, 18.74, 24, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 90 ml', null, null, false, true, null, null, null),
  (41, '7791293036045', 'FC-93036045', 'Rexona Women Pomelo / Toronja spray 150 ml', 'DESOD REXONA WOM POM/TOR SPY150ML', 1, 54.55, 69, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Rexona', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (42, '7501082790474', 'FC-82790474', 'Nuvel desmaquillante oil-free piel mixta 235 ml', 'DESMAQ NUVEL OIL-FREE P/MIX 235ML', 1, 43.65, 55, 'marca', 'Cuidado personal', 'Desmaquillante', 'Líquido', 'Nuvel', null, 'Frasco 235 ml', null, null, false, false, null, null, null),
  (43, '759684154232', 'FC-84154232', 'Jaloma gel antibacterial 60 ml', 'JALOMA 60ML GEL ANTIBACTERIAL', 3, 13.01, 17, 'marca', 'Cuidado personal', 'Antibacterial', 'Gel', 'Jaloma', null, 'Frasco 60 ml', null, null, false, false, null, null, null),
  (44, '7501022140543', 'FC-22140543', 'Ricitos de Oro Lavanda kit C/4', 'KIT RICITOS DE ORO LAVANDA C/4PZ', 1, 106.64, 134, 'marca', 'Cuidado personal', 'Cuidado infantil', null, 'Ricitos de Oro', null, 'Kit 4 piezas', null, null, false, false, null, null, null),
  (45, '037836041426', 'FC-36041426', 'Hinds Hidratación Extrema con avena 400 ml', 'CRA HINDS HIDR-EXT C/AVENA 400 ML', 1, 49.97, 63, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 400 ml', null, null, false, false, null, null, null),
  (46, '7791293032412', 'FC-93032412', 'Rexona Women Sexy Bouquet spray 150 ml', 'DESOD REXONA WOM SEXY-BOU SPY 150ML', 1, 54.68, 69, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Rexona', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (47, '037836041341', 'FC-36041341', 'Hinds Natural crema líquida piel reseca 90 ml', 'CRA HINDS LIQ P/RCA 90ML', 2, 18.74, 24, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 90 ml', null, null, false, true, null, null, null),
  (48, '037836041365', 'FC-36041365', 'Hinds Natural crema líquida piel reseca 400 ml', 'CRA HINDS LIQ NAT RCA 400ML', 1, 49.97, 63, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Hinds', null, 'Frasco 400 ml', null, null, false, false, null, null, null),
  (49, '7506306216907', 'FC-06216907', 'Rexona Efficient pies talco dúo 200 g', 'TCO DESOD EFFICIENT PIES 200G DUO', 1, 120.00, 150, 'marca', 'Cuidado personal', 'Cuidado de pies', 'Talco', 'Rexona', null, 'Dúo 200 g', null, null, false, false, null, null, null),
  (50, '7501022188507', 'FC-22188507', 'Ricitos de Oro Lavanda y Leche shampoo 400 ml + crema 100 ml', 'SH RICITOS DE ORO DE LAV Y LECH 400ML C/ CR A CORP 100ML', 1, 77.52, 97, 'marca', 'Cuidado personal', 'Cuidado infantil', 'Shampoo', 'Ricitos de Oro', null, 'Shampoo 400 ml + crema 100 ml', null, null, false, false, null, null, null),
  (51, '7501082790450', 'FC-82790450', 'Nuvel gel limpiador facial 235 ml', 'GEL NUVEL LIMPIADOR FAC 235ML', 1, 42.36, 53, 'marca', 'Cuidado personal', 'Limpieza facial', 'Gel', 'Nuvel', null, 'Frasco 235 ml', null, null, false, false, null, null, null),
  (52, '7791293025810', 'FC-93025810', 'Axe Men Fusion spray 150 ml', 'DESOD AXE MEN FUSION SPY 150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (53, '7501082790498', 'FC-82790498', 'Nuvel desmaquillante bifásico rostro/ojos 235 ml', 'DESMAQ NUVEL BIFAS ROST/OJO 235ML', 1, 43.65, 55, 'marca', 'Cuidado personal', 'Desmaquillante', 'Líquido', 'Nuvel', null, 'Frasco 235 ml', null, null, false, false, null, null, null),
  (54, '7791293025797', 'FC-93025797', 'Axe Men Dark Temptation spray 150 ml', 'DESOD AXE MEN DARK TEMP SPY150ML', 1, 45.83, 58, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Axe', null, 'Spray 150 ml', null, null, false, true, null, null, null),
  (55, '7509546052632', 'FC-46052632', 'Colgate Total Advanced Clean 75 ml', 'CEP DENT COLGATE TA+C D T ACC 75ML OCT26', 3, 23.90, 30, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Colgate', null, 'Tubo 75 ml', null, null, false, false, null, null, null),
  (56, '037836040368', 'FC-36040368', 'Ricitos de Oro agua de colonia spray 100 ml', 'AGUA COL RICITOS ORO SPY 100 ML', 2, 39.07, 49, 'marca', 'Cuidado personal', 'Cuidado infantil', 'Spray', 'Ricitos de Oro', null, 'Spray 100 ml', null, null, false, false, null, null, null),
  (57, '7501082722123', 'FC-82722123', 'Nuvel crema para manos hidratada 65 ml', 'CRA NUVEL P/MANOS HIDRATADA 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', 'Cuidado de manos', 'Crema', 'Nuvel', null, 'Tubo 65 ml', null, null, false, false, null, null, null),
  (58, '7798140258490', 'FC-40258490', 'Tío Nacho Ultra Hidratación Coco shampoo 415 ml', 'SH TIO NACHO ULT-HIDRA COCO 415ML', 1, 85.84, 108, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Shampoo', 'Tío Nacho', null, 'Frasco 415 ml', null, null, false, false, null, null, null),
  (59, '7506295388487', 'FC-95388487', 'Oral-B 3D White Brilliance Fresh pasta 53 ml', 'C D ORAL-B 3DW BRILLIAN FRES 53ML', 3, 24.61, 31, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Oral-B', null, 'Tubo 53 ml', null, null, false, false, null, null, null),
  (60, '7791293032429', 'FC-93032429', 'Rexona Women Happy Morning spray 150 ml', 'DESOD REXONA WOM HAPPY-MO SPY 150ML', 1, 54.68, 69, 'marca', 'Cuidado personal', 'Desodorante', 'Spray', 'Rexona', null, 'Spray 150 ml', null, null, false, false, null, null, null),
  (61, '7896009498091', 'FC-09498091', 'Sensodyne Protección Completa limpieza efectiva 90 g', 'SENSODYNE PROTEC COMPLET + ACC LIM EFEC 90G HALEON', 1, 72.62, 91, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Sensodyne', null, 'Tubo 90 g', null, null, false, true, null, null, null),
  (62, '7896009419324', 'FC-09419324', 'Sensodyne Original pasta dental 90 g', 'CD SENSODYNE ORIGINAL 90G', 1, 72.62, 91, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Sensodyne', null, 'Tubo 90 g', null, null, false, true, null, null, null),
  (63, '7509546687353', 'FC-46687353', 'Colgate Máxima Protección Anticaries Calci-Protect 90 ml', 'C D COLGATE MFP CALCI-PROT 90ML', 1, 33.34, 42, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Colgate', null, 'Tubo 90 ml', null, null, false, true, null, null, null),
  (64, '7509546054032', 'FC-46054032', 'Colgate Luminous White pasta dental', 'C D COLGATE LUMINOUS WHITE22', 3, 17.54, 22, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema dental', 'Colgate', null, 'Tubo', null, null, false, false, null, null, null),
  (65, '7506306257597', 'FC-06257597', 'Rexona Efficient Original talco para pies 100 g', 'REXONA 100GR TCO PIES EFFICIENT ORIG', 2, 40.24, 51, 'marca', 'Cuidado personal', 'Cuidado de pies', 'Talco', 'Rexona', null, 'Talco 100 g', null, null, false, true, null, null, null),
  (66, '7501027280657', 'FC-27280657', 'Kids 2 en 1 Smoothie Manzana shampoo 265 ml', 'SH KIDS 2EN1 SMOOTHIE MANJA265ML', 1, 77.23, 97, 'marca', 'Cuidado personal', 'Cuidado infantil', 'Shampoo', 'Kids', null, 'Frasco 265 ml', null, null, false, false, null, null, null),
  (67, '7506078941755', 'FC-78941755', 'L''Oréal Kids 3 en 1 Explosión Frambuesa shampoo 265 ml', 'SH KIDS 3EN1 EXPLOSION FRAMBU 265ML', 1, 77.00, 97, 'marca', 'Cuidado personal', 'Cuidado infantil', 'Shampoo', 'L''Oréal Kids', null, 'Frasco 265 ml', null, null, false, false, null, null, null),
  (68, '7506306257580', 'FC-06257580', 'Rexona Efficient polvo desodorante pies 50 g', 'PVO DESOD REXONA EFICC PIES 50 G', 2, 29.68, 38, 'marca', 'Cuidado personal', 'Cuidado de pies', 'Polvo', 'Rexona', null, 'Polvo 50 g', null, null, false, false, null, null, null),
  (69, '7501082722116', 'FC-82722116', 'Nuvel crema para manos suaves 65 ml', 'CRA NUVEL P/MANOS SUAVES 65ML', 1, 13.49, 17, 'marca', 'Cuidado personal', 'Cuidado de manos', 'Crema', 'Nuvel', null, 'Tubo 65 ml', null, null, false, false, null, null, null),
  (70, '7501846506198', 'FC-46506198', 'Xiomara Elastik cera 100 g', 'CERA ELASTIK 100GM XIOMARA', 2, 78.14, 98, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Cera', 'Xiomara', null, 'Tarro 100 g', null, null, false, false, null, null, null),
  (71, '7509552874952', 'FC-52874952', 'Elvive Hidra Hialurónico Pure shampoo 370 ml', 'SH ELVIVE HIDRA HIALU PURE 370ML', 1, 71.44, 90, 'marca', 'Cuidado personal', 'Cuidado capilar', 'Shampoo', 'Elvive', null, 'Frasco 370 ml', null, null, false, false, null, null, null),
  (72, '7501054558682', 'FC-54558682', 'Nivea Milk crema corporal 400 ml + 100 ml', 'CRA CORP NIVEAMILK 400ML+CRA100ML', 1, 85.87, 108, 'marca', 'Cuidado personal', 'Cuidado corporal', 'Crema', 'Nivea', null, '400 ml + 100 ml', null, null, false, true, null, null, null),
  (73, '7509552525427', 'FC-52525427', 'Obao Frescura Suave / Piel Delicada roll-on 65 g 3-pack', 'DESOD OBAO 65G ROLL ON FRESC SUAVE-PIEL DEL IC 3PACK', 1, 58.95, 74, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Obao', null, '3 roll-on 65 g', null, null, false, false, null, null, null);

-- Si ya hay ficha inactiva con el mismo EAN, reactivar (fc_buscar solo ve activos).
update public.productos p
set
  activo = true,
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma)
from (
  select distinct on (ean) *
  from _fc_bf42_28130
  order by ean, linea
) t
where coalesce(p.activo, true) = false
  and nullif(btrim(p.codigo_barras), '') = t.ean;

-- Una fila por EAN (mismo producto no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  -- SKU siempre único por ticket/línea (evita productos_sku_key con FC-xxxxxxxx del catálogo).
  'FC-B28130-' || lpad(t.linea::text, 3, '0'),
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Bodega F-42 28130 · 2026-10-24 · listo para pistola',
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
  select distinct on (ean) *
  from _fc_bf42_28130
  order by ean, linea
) t
-- Solo por EAN (activos vía fc_buscar; cualquier fila con el mismo código).
where public.fc_buscar_producto_escaneo(t.ean) is null
  and not exists (
    select 1 from public.productos p
    where nullif(btrim(p.codigo_barras), '') = t.ean
  )
  and not exists (
    select 1 from public.productos p
    where p.sku = ('FC-B28130-' || lpad(t.linea::text, 3, '0'))
  );

-- Ya existían: costo. PVP solo si estaba en 0.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end
from (
  select distinct on (ean) *
  from _fc_bf42_28130
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
  and (
    p.costo is distinct from t.costo
    or coalesce(p.precio, 0) <= 0
  );

-- Ficha vacía / foto si falta. No pisa una foto que ya esté.
update public.productos p
set
  nombre = case
    when length(trim(coalesce(p.nombre, ''))) < 8 then t.nombre
    else p.nombre
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_bf42_28130
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Bodega F-42',
  '28130',
  '2026-10-24',
  5282.50,
  'borrador',
  'Ticket Bodega F-42 Caja 4/28130 · 24-oct-2026 · foto térmica · tarjeta $5,282.50 · cola Recibir; stock al confirmar pistola'
where not exists (
  select 1 from public.recepciones
  where folio = '28130'
    and coalesce(proveedor, '') ilike '%bodega%'
);

update public.recepciones
set
  total_ticket = 5282.50,
  fecha = '2026-10-24',
  proveedor = 'Bodega F-42',
  notas = 'Ticket Bodega F-42 Caja 4/28130 · 24-oct-2026 · foto térmica · tarjeta $5,282.50 · cola Recibir; stock al confirmar pistola',
  updated_at = now()
where folio = '28130'
  and coalesce(proveedor, '') ilike '%bodega%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '28130'
  and coalesce(r.proveedor, '') ilike '%bodega%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
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
    )
  ),
  null
from _fc_bf42_28130 t
join public.recepciones r
  on r.folio = '28130'
 and coalesce(r.proveedor, '') ilike '%bodega%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
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
    where i.producto_id = p.id and coalesce(i.es_principal, false)
  ),
  'propia'
from _fc_bf42_28130 t
join public.productos p on p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
)
where t.imagen is not null
  and not exists (
    select 1 from public.producto_imagenes i
    where i.producto_id = p.id
      and (i.url = t.imagen or i.storage_path = t.foto_file)
  );

-- Diagnóstico
select
  r.folio,
  r.proveedor,
  r.estado,
  r.total_ticket,
  count(i.*) as renglones,
  sum(i.cantidad) as piezas,
  bool_or(i.pendiente_alta) as tiene_pendiente_alta
from public.recepciones r
left join public.recepcion_items i on i.recepcion_id = r.id
where r.folio = '28130'
  and coalesce(r.proveedor, '') ilike '%bodega%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_bf42_28130 t
order by t.linea;

commit;
