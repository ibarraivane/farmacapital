-- Farmalive · ticket 12127 · 2026-09-28 16:24 · Club Iztapalapa 1
-- Total $11,696.80 · 109 artículos / 238 unidades.
-- Costo = P.U. neto (Descto 2–15%). Ticket trunca Suerox a 12 dígitos.
-- Sin lote ni caducidad (MMAA de la caja). No inventar 0000.
-- 63 alta(s) stock 0. 46 ya estaban: solo costo / ficha vacía, no PVP.
-- Nombres de ficha, no del ticket. Fotos en public/catalogo-propia/ (tras deploy).
-- SIN bloques dollar-quote. Idempotente mientras el ticket siga en borrador.
-- Pegar TODO este archivo en Supabase → SQL Editor → Run.

begin;

create temp table _fc_fl_12127 (
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

insert into _fc_fl_12127 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501943444966', 'FC-43444966', 'Suavelastic Jumbo', 'PAÑAL SUAVELASTIC JUMBO C/40 | KIMBERLY CLARK', 1, 249.61, 313, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Suavelastic', 'Kimberly-Clark', 'Paquete 40 pañales talla jumbo', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-jumbo-40-7501943444966.jpg', 'catalogo-propia/kleenbebe-suavelastic-jumbo-40-7501943444966.jpg', null),
  (2, '7501943444928', 'FC-43444928', 'Suavelastic Mediano', 'PAÑAL SUAVELASTIC MED C/40 | KIMBERLY CLARK', 1, 185.81, 233, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Suavelastic', 'Kimberly-Clark', 'Paquete 40 pañales talla mediana', null, null, false, false, null, null, null),
  (3, '7501017372751', 'FC-17372751', 'Absorsec Grande', 'PAÑAL ABSORSEC GDE C/40 | KIMBERLY CLARK', 1, 148.76, 186, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Absorsec', 'Kimberly-Clark', 'Paquete 40 pañales talla grande', null, null, false, false, null, null, null),
  (4, '7501943434622', 'FC-43434622', 'Suavelastic Chico', 'PAÑAL SUAVELASTIC CHICO C/40 | KIMBERLY CLARK', 1, 149.94, 188, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Suavelastic', 'Kimberly-Clark', 'Paquete 40 pañales talla chica', null, null, false, false, null, null, null),
  (5, '7501019031137', 'FC-19031137', 'Saba Amore con alas', 'TOA SANIT SABA AMORE C/ALAS C/8 | SCA', 2, 11.12, 14, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'SCA', 'Paquete 8 toallas', null, null, false, false, null, null, null),
  (6, '056100024798', 'FC-00024798', 'Always nocturna con alas', 'TOA SANIT ALWAYS NOC ALAS C/8 | P&G PERF', 2, 27.24, 35, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Always', 'P&G', 'Paquete 8 toallas', null, null, false, true, null, null, null),
  (7, '7501019050664', 'FC-19050664', 'Saba Buenas Noches con alas', 'TOA SANIT SABA BUENAS NOCHES C/ALAS C/8 | ESSITY', 2, 21.38, 27, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'Essity', 'Paquete 8 toallas', null, null, false, true, null, null, null),
  (8, '7501019036590', 'FC-19036590', 'Saba Buenas Noches Extra', 'TOA SANIT SABA BUENAS NOCHES EXTRA C/12 | ESSITY', 1, 44.39, 56, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'Essity', 'Paquete 12 toallas', null, null, false, true, null, null, null),
  (9, '7501019006623', 'FC-19006623', 'Saba Buenas Noches con alas', 'TOA SANIT SABA BUENAS NOCHES C/ALAS C/8 | SCA', 1, 22.52, 29, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'SCA', 'Paquete 8 toallas', null, null, false, true, null, null, null),
  (10, '7501019006647', 'FC-19006647', 'Saba Ultra Delgada nocturna con alas', 'TOA SANIT SABA U DELGADA NOCT C/A C/10 | SCA', 3, 29.83, 38, 'marca', 'Cuidado personal', 'Higiene femenina', 'Toallas', 'Saba', 'SCA', 'Paquete 10 toallas', null, null, false, true, null, null, null),
  (11, '020800600330', 'FC-00600330', 'Tampax Super', 'TAMPONES TAMPAX SUPER C/10 | P&G PERF', 2, 46.06, 58, 'marca', 'Cuidado personal', 'Higiene femenina', 'Tampones', 'Tampax', 'P&G', 'Caja 10 tampones', null, null, false, true, null, null, null),
  (12, '7506425618200', 'FC-25618200', 'Suavelastic Vitta E toallitas', 'TOA HUM SUAVELAS VITTA E C/80 | KIMBERLY CLARK', 2, 29.20, 37, 'marca', 'Higiene', 'Toallitas', 'Toallitas', 'Suavelastic', 'Kimberly-Clark', 'Paquete 80 toallitas', null, null, false, false, null, null, null),
  (13, '7506425601790', 'FC-25601790', 'Kimbies Durazno Aloe toallitas', 'TOA HUM KIMBIES DURAZNO ALOE C/90 | KIMBERLY CLARK', 2, 14.41, 19, 'marca', 'Higiene', 'Toallitas', 'Toallitas', 'Kimbies', 'Kimberly-Clark', 'Paquete 90 toallitas', null, null, false, false, null, null, null),
  (14, '7501943471337', 'FC-43471337', 'Absorsec toallitas', 'TOA HUM ABSORSEC C/90 | KIMBERLY CLARK', 3, 13.72, 18, 'marca', 'Higiene', 'Toallitas', 'Toallitas', 'Absorsec', 'Kimberly-Clark', 'Paquete 90 toallitas', null, null, false, false, null, null, null),
  (15, '7501943471900', 'FC-43471900', 'Absorsec toallitas', 'TOA HUM ABSORSEC C/120 | KIMBERLY CLARK', 4, 21.07, 27, 'marca', 'Higiene', 'Toallitas', 'Toallitas', 'Absorsec', 'Kimberly-Clark', 'Paquete 120 toallitas', null, null, false, true, null, null, null),
  (16, '7502276040566', 'FC-76040566', 'Lotrimin Uno crema', 'LOTRIMIN-UNO CREMA 20 GR 3PACK | BAYER OTC', 1, 163.20, 204, 'marca', 'Dermatología', 'Antifúngico', 'Crema', 'Lotrimin', 'Bayer', '3 tubos 20 g', 'Terbinafina', '1%', false, false, 'https://www.farmacapital.mx/catalogo-propia/lotrimin-uno-crema-20g-7502276040566.jpg', 'catalogo-propia/lotrimin-uno-crema-20g-7502276040566.jpg', null),
  (17, '7501537163266', 'FC-37163266', 'Tribedoce Compuesto', 'IV TRIBEDOCE COMPUESTO AMP C/3 | BRULUART', 2, 48.58, 61, 'marca', 'Vitaminas', 'Inyectable', 'Ampolleta', 'Tribedoce', 'Bruluart', 'Caja 3 ampolletas', 'Tiamina / piridoxina / cianocobalamina', null, true, true, null, null, null),
  (18, '7501537182960', 'FC-37182960', 'Tribedoce 50000', 'IV TRIBEDOCE 50000 AMP C/5 | BRULUART', 1, 65.82, 83, 'marca', 'Vitaminas', 'Inyectable', 'Ampolleta', 'Tribedoce', 'Bruluart', 'Caja 5 ampolletas', 'Cianocobalamina', '50000 UI', true, true, null, null, null),
  (19, '7501385491146', 'FC-85491146', 'Deflamox Plus suspensión', 'DEFLAMOX PLUS SUSP 75 ML | SANFER', 1, 41.39, 52, 'marca', 'Antibióticos', null, 'Suspensión', 'Deflamox', 'Sanfer', 'Frasco 75 mL', 'Amoxicilina / ácido clavulánico', null, true, true, null, null, null),
  (20, '7501943498815', 'FC-43498815', 'Suavelastic Recién nacido', 'PAÑAL SUAVELASTIC REC NACIDO C/40 | KIMBERLY CLARK', 1, 115.74, 145, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Suavelastic', 'Kimberly-Clark', 'Paquete 40 pañales recién nacido', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-recien-nacido-40-7501943498815.jpg', 'catalogo-propia/kleenbebe-suavelastic-recien-nacido-40-7501943498815.jpg', null),
  (21, '7501943447615', 'FC-43447615', 'Suavelastic Extra Jumbo', 'PAÑAL SUAVELASTIC EXT JUMBO C/40 | KIMBERLY CLARK', 1, 259.90, 325, 'marca', 'Higiene', 'Pañales', 'Pañal', 'Suavelastic', 'Kimberly-Clark', 'Paquete 40 pañales talla extra jumbo', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/kleenbebe-suavelastic-extra-jumbo-40-7501943447615.jpg', 'catalogo-propia/kleenbebe-suavelastic-extra-jumbo-40-7501943447615.jpg', null),
  (22, '7500435162241', 'FC-35162241', 'Head & Shoulders 2 en 1 Suave y Manejable', 'SHAM HEAD & S 2/1 SUAVE MAN 650 ML | PG PERF', 1, 123.03, 154, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 650 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/head-shoulders-2en1-650ml-7500435162241.jpg', 'catalogo-propia/head-shoulders-2en1-650ml-7500435162241.jpg', null),
  (23, '7501590211201', 'FC-90211201', 'Flextrin 25/200/300 mg', 'FLEXTRIN 25/200/300 MG COMP C/30 | CMD', 2, 69.19, 87, 'marca', 'Suplemento', 'Articulaciones', 'Comprimido', 'Flextrin', 'CMD', 'Caja 30 comprimidos', 'Glucosamina / condroitina / MSM', '25/200/300 mg', false, false, null, null, null),
  (24, '7501537103422', 'FC-37103422', 'Tribedoce DX', 'TRIBEDOCE DX AMP C/3 | BRULUART', 3, 49.72, 63, 'marca', 'Vitaminas', 'Inyectable', 'Ampolleta', 'Tribedoce', 'Bruluart', 'Caja 3 ampolletas', 'Vitaminas B / dexametasona', null, true, true, null, null, null),
  (25, '759684431234', 'FC-84431234', 'Jaloma manzanilla toallitas', 'TOA HUM JALOMA MANZANILLA C/80 | LAB JALOMA', 2, 18.48, 24, 'marca', 'Higiene', 'Toallitas', 'Toallitas', 'Jaloma', 'Jaloma', 'Paquete 80 toallitas', null, null, false, false, null, null, null),
  (26, '7501048623006', 'FC-48623006', 'Protec pads faciales redondos', 'PADS FACIAL PROTEC REDONDOS C/100 | DEGASA', 2, 20.18, 26, 'marca', 'Botiquín', 'Material de curación', 'Pads', 'Degasa', 'Degasa', 'Caja 100 pads', null, null, false, true, null, null, null),
  (27, '7506295369363', 'FC-95369363', 'Tampax Pearl Regular', 'TAMPONES TAMPAX PEARL REGULAR C/8 | PG PERF', 2, 45.96, 58, 'marca', 'Cuidado personal', 'Higiene femenina', 'Tampones', 'Tampax', 'P&G', 'Caja 8 tampones', null, null, false, false, null, null, null),
  (28, '7502250340521', 'FC-50340521', 'Vitacilina ungüento', 'VITACILINA UNG 32 GR | KSK', 2, 32.94, 42, 'marca', 'Dermatología', 'Antibiótico tópico', 'Ungüento', 'Vitacilina', 'KSK', 'Tubo 32 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-32g-7502250340521.jpg', 'catalogo-propia/vitacilina-unguento-32g-7502250340521.jpg', null),
  (29, '7501537103545', 'FC-37103545', 'Adinol solución infantil', 'ADINOL SOL INF 120 ML | BRULUART', 2, 20.06, 26, 'marca', 'Analgésico', 'Pediátrico', 'Solución', 'Adinol', 'Bruluart', 'Frasco 120 mL', 'Paracetamol', null, false, false, null, null, null),
  (30, '6758730020570', 'FC-30020570', 'Sukrol Hombre', 'SUKROL HOMBRE TAB C/30 | FARMAMEDICA', 1, 129.36, 162, 'marca', 'Vitaminas', null, 'Tableta', 'Sukrol', 'Farmamédica', 'Caja 30 tabletas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sukrol-hombre-30-tab-6758730020570.jpg', 'catalogo-propia/sukrol-hombre-30-tab-6758730020570.jpg', null),
  (31, '7501836003621', 'FC-36003621', 'Precicol', 'PRECICOL SOL 20 ML NVO | LIFERPAL', 2, 39.62, 50, 'marca', 'Analgésico', 'Cólico', 'Solución', 'Precicol', 'Liferpal', 'Frasco 20 mL', 'Hioscina / paracetamol', null, false, true, null, null, null),
  (32, '7501080912274', 'FC-80912274', 'Sterimar Bebé spray', 'STERIMAR SPRAY BEBE 50 ML | CHURCH & DWIGHTND', 3, 151.30, 190, 'marca', 'Respiratorio', 'Nasal', 'Spray', 'Sterimar', 'Church & Dwight', 'Spray 50 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sterimar-bebe-50ml-7501080912274.jpg', 'catalogo-propia/sterimar-bebe-50ml-7501080912274.jpg', null),
  (33, '7502227425022', 'FC-27425022', 'Algidol 400 mg', 'ALGIDOL 400 MG CAPS C/10 | GELPHARMA', 2, 16.65, 21, 'marca', 'Analgésico', null, 'Cápsula', 'Algidol', 'Gelpharma', 'Caja 10 cápsulas', 'Ibuprofeno', '400 mg', false, false, null, null, null),
  (34, '7501573900115', 'FC-73900115', 'Biomesina Compuesta', 'IV BIOMESINA COMPUESTA TAB C/10 | BIOMEP', 4, 24.84, 40, 'generico', 'Gastro', null, 'Tableta', 'Biomesina', 'BiomeP', 'Caja 10 tabletas', 'Butilhioscina / metamizol', '10 mg / 250 mg', true, true, null, null, null),
  (35, '7502009744129', 'FC-09744129', 'Erispan Compuesto', 'IV ERISPAN COMPUESTO SOL 60 ML | MAVER', 1, 22.51, 37, 'generico', 'Alergia', null, 'Solución', 'Erispan', 'Maver', 'Frasco 60 mL', 'Loratadina / betametasona', null, true, false, null, null, null),
  (36, '7501289511438', 'FC-89511438', 'Pasta Lassar', 'PASTA LASSAR TUBO 60 GR | ANDROMACO', 1, 60.66, 76, 'marca', 'Dermatología', 'Protectores', 'Pasta', 'Pasta Lassar', 'Andrómaco', 'Tubo 60 g', 'Óxido de zinc', null, false, false, null, null, null),
  (37, '7502250342556', 'FC-50342556', 'Vitacilina serum facial retinol', 'VITACILINA SERUM FAC RETINOL 30ML | KSK', 1, 111.88, 140, 'marca', 'Cuidado personal', 'Facial', 'Serum', 'Vitacilina', 'KSK', 'Frasco 30 mL', null, null, false, false, null, null, null),
  (38, '7501258205863', 'FC-58205863', 'Visertral 10 mg', 'IV VISERTRAL 10 MG C/10 | SERRAL', 2, 24.20, 39, 'generico', 'Alergia', null, 'Tableta', 'Visertral', 'Serral', 'Caja 10 tabletas', 'Cetirizina', '10 mg', false, false, null, null, null),
  (39, '7502208894946', 'FC-08894946', 'Puribel 300 mg', 'PURIBEL 300 MG TAB C/20 | BRULUART', 4, 17.16, 22, 'marca', 'Medicamentos', null, 'Tableta', 'Puribel', 'Bruluart', 'Caja 20 tabletas', null, '300 mg', true, false, null, null, null),
  (40, '7501080954212', 'FC-80954212', 'Sterimar Infantil spray', 'STERIMAR SPRAY INFANTIL 50 ML | CHURCH & DWIGHTND', 3, 155.98, 195, 'marca', 'Respiratorio', 'Nasal', 'Spray', 'Sterimar', 'Church & Dwight', 'Spray 50 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sterimar-infantil-50ml-7501080954212.jpg', 'catalogo-propia/sterimar-infantil-50ml-7501080954212.jpg', null),
  (41, '7501573900535', 'FC-73900535', 'Biomesina 10 mg', 'IV BIOMESINA 10 MG TAB C/10 | BIOMEP', 4, 11.92, 20, 'generico', 'Gastro', null, 'Tableta', 'Biomesina', 'BiomeP', 'Caja 10 tabletas', 'Butilhioscina', '10 mg', false, true, null, null, null),
  (42, '7501008494226', 'FC-08494226', 'Aspirina Junior', 'ASPIRINA JUNIOR TAB C/60 | BAYER OTC', 3, 64.32, 81, 'marca', 'Analgésico', null, 'Tableta', 'Aspirina', 'Bayer', 'Caja 60 tabletas', 'Ácido acetilsalicílico', null, false, true, null, null, null),
  (43, '7501573900375', 'FC-73900375', 'Diurmessel 40 mg', 'IV DIURMESSEL 40 MG TAB C/20 | BIOMEP', 4, 8.46, 14, 'generico', 'Cardiovascular', null, 'Tableta', 'Diurmessel', 'BiomeP', 'Caja 20 tabletas', 'Furosemida', '40 mg', true, true, null, null, null),
  (44, '7501070600730', 'FC-70600730', 'Syncol Max', 'SYNCOL MAX TAB C/12 | SANFER', 1, 88.69, 111, 'marca', 'Analgésico', null, 'Tableta', 'Syncol', 'Sanfer', 'Caja 12 tabletas', 'Paracetamol / cafeína / pirilamina', null, false, true, null, null, null),
  (45, '7501125116810', 'FC-25116810', 'Agrifen', 'AGRIFEN TAB C/10 | LAB PISA', 5, 19.11, 24, 'marca', 'Resfriado', null, 'Tableta', 'Agrifen', 'Pisa', 'Caja 10 tabletas', null, null, false, true, null, null, null),
  (46, '7502240450711', 'FC-40450711', 'Punab 100 mg', 'PUNAB 100 MG TAB C/15 | MERMAR', 3, 20.37, 33, 'generico', 'Cardiovascular', null, 'Tableta', 'Punab', 'Wermar', 'Caja 15 tabletas', 'Losartán', '100 mg', true, false, null, null, null),
  (47, '7502211789918', 'FC-11789918', 'Bromuro de pinaverio', 'BROMURO DE PINAVERIO TAB C/14 (LOEFFLER) | LOEFFLER', 4, 18.22, 30, 'generico', 'Gastro', null, 'Tableta', 'Loeffler', 'Loeffler', 'Caja 14 tabletas', 'Bromuro de pinaverio', null, true, false, null, null, null),
  (48, '7501125139543', 'FC-25139543', 'Combesteral', 'IV COMBESTERAL SOL INY C/3 AMP | LAB PISA', 2, 221.71, 355, 'generico', 'Hormonas', 'Inyectable', 'Ampolleta', 'Combesteral', 'Pisa', 'Caja 3 ampolletas', 'Betametasona', null, true, false, null, null, null),
  (49, '7851187543278', 'FC-87543278', 'Ciclox 200 mg', 'CICLOX 200 MG CAPS C/10 | MAVI', 2, 38.81, 63, 'generico', 'Analgésico', null, 'Cápsula', 'Ciclox', 'MAVI', 'Caja 10 cápsulas', 'Celecoxib', '200 mg', true, false, null, null, null),
  (50, '7501070600556', 'FC-70600556', 'Syncol', 'SYNCOL TAB C/24 | SANFER', 2, 94.51, 119, 'marca', 'Analgésico', null, 'Tableta', 'Syncol', 'Sanfer', 'Caja 24 tabletas', 'Paracetamol / cafeína / pirilamina', null, false, true, null, null, null),
  (51, '780083148645', 'FC-83148645', 'Cobedina NS', 'COBEDINA NS TAB C/10 | COLLINS', 3, 10.42, 14, 'marca', 'Alergia', null, 'Tableta', 'Cobedina', 'Collins', 'Caja 10 tabletas', 'Loratadina / betametasona', null, true, false, null, null, null),
  (52, '7502216808430', 'FC-16808430', 'Esomeprazol 40 mg', 'ESOMEPRAZOL 40 MG TAB C/14 (ULTRA) | ULTRA LABORATORIO', 1, 101.20, 162, 'generico', 'Gastro', null, 'Tableta', 'Ultra', 'Ultra', 'Caja 14 tabletas', 'Esomeprazol', '40 mg', true, false, null, null, null),
  (53, '7502250340255', 'FC-50340255', 'Vitacilina Bebé', 'VITACILINA BEBE 110 GR | KSK', 2, 83.17, 104, 'marca', 'Cuidado personal', 'Bebé', 'Crema', 'Vitacilina', 'KSK', 'Tarro 110 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/vitacilina-bebe-110g-7502250340255.jpg', 'catalogo-propia/vitacilina-bebe-110g-7502250340255.jpg', null),
  (54, '7501080911185', 'FC-80911185', 'Sterimar Alergias spray', 'STERIMAR SPRAY ALERGIAS 100 ML | CHURCH & DWIGHTND', 3, 173.40, 217, 'marca', 'Respiratorio', 'Nasal', 'Spray', 'Sterimar', 'Church & Dwight', 'Spray 100 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sterimar-alergias-100ml-7501080911185.jpg', 'catalogo-propia/sterimar-alergias-100ml-7501080911185.jpg', null),
  (55, '7501573900221', 'FC-73900221', 'Vexotil 10 mg', 'IV VEXOTIL 10 MG TAB C/30 | BIOMEP', 4, 7.10, 12, 'generico', 'Cardiovascular', null, 'Tableta', 'Vexotil', 'BiomeP', 'Caja 30 tabletas', 'Enalapril', '10 mg', true, false, null, null, null),
  (56, '7501008491966', 'FC-08491966', 'Aspirina', 'ASPIRINA TAB C/40 | BAYER OTC', 2, 44.64, 56, 'marca', 'Analgésico', null, 'Tableta', 'Aspirina', 'Bayer', 'Caja 40 tabletas', 'Ácido acetilsalicílico', null, false, true, null, null, null),
  (57, '7501080911178', 'FC-80911178', 'Sterimar Cobre spray', 'STERIMAR SPRAY COBRE 100 ML | CHURCH & DWIGHTND', 1, 173.40, 217, 'marca', 'Respiratorio', 'Nasal', 'Spray', 'Sterimar', 'Church & Dwight', 'Spray 100 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sterimar-cobre-100ml-7501080911178.jpg', 'catalogo-propia/sterimar-cobre-100ml-7501080911178.jpg', null),
  (58, '7803510003409', 'FC-10003409', 'Ciruelax Forte', 'CIRUELAX FORTE TAB C/24 | GRISI HNOS', 2, 133.77, 168, 'marca', 'Gastro', 'Laxante', 'Tableta', 'Ciruelax', 'Grisi', 'Caja 24 tabletas', 'Senósidos', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ciruelax-forte-24-tab-7803510003409.jpg', 'catalogo-propia/ciruelax-forte-24-tab-7803510003409.jpg', null),
  (59, '5000174305449', 'FC-74305449', 'Fixodent Original', 'CREMA DENT FIXODENT ORIGINAL 40 ML | PG PERF', 3, 90.33, 113, 'marca', 'Cuidado personal', 'Higiene bucal', 'Crema', 'Fixodent', 'P&G', 'Tubo 40 mL', null, null, false, true, null, null, null),
  (60, '7502250343065', 'FC-50343065', 'Vitacilina ungüento', 'VITACILINA 16 GR 2X1 | KSK', 3, 21.86, 28, 'marca', 'Dermatología', 'Antibiótico tópico', 'Ungüento', 'Vitacilina', 'KSK', 'Tubo 16 g (2x1)', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-16g.jpg', 'catalogo-propia/vitacilina-unguento-16g.jpg', null),
  (61, '7147061009016', 'FC-61009016', 'Sukrol', 'SUKROL TAB C/100 | FARMAMEDICA', 1, 137.28, 172, 'marca', 'Vitaminas', null, 'Tableta', 'Sukrol', 'Farmamédica', 'Caja 100 tabletas', null, null, false, false, null, null, null),
  (62, '7506386100158', 'FC-86100158', 'Benvia jarabe infantil', 'BENVIA JBE INF 120 ML | LOEFFLER', 2, 30.36, 38, 'marca', 'Gastro', 'Pediátrico', 'Jarabe', 'Benvia', 'Loeffler', 'Frasco 120 mL', 'Dimenhidrinato', null, false, true, null, null, null),
  (63, '7500435127363', 'FC-35127363', 'Oral-B Kids Mickey pasta dental', 'CREMA DENT ORAL-B KIDS MICKEY 37 ML | PG PERF', 2, 25.19, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Pasta', 'Oral-B', 'P&G', 'Tubo 37 mL', null, null, false, false, null, null, null),
  (64, '7502250343072', 'FC-50343072', 'Vitacilina ungüento', 'VITACILINA 28 GR 2X1 | KSK', 3, 32.64, 41, 'marca', 'Dermatología', 'Antibiótico tópico', 'Ungüento', 'Vitacilina', 'KSK', 'Tubo 28 g (2x1)', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/vitacilina-unguento-28g.jpg', 'catalogo-propia/vitacilina-unguento-28g.jpg', null),
  (65, '75049638', 'FC-75049638', 'Cloranfenicol ungüento oftálmico', '(RE) CLORANFENICOL UNG OFT 5 GR (EXAKTA) | EXAKTA', 2, 41.62, 67, 'generico', 'Oftalmología', null, 'Ungüento oftálmico', 'Exakta', 'Exakta', 'Tubo 5 g', 'Cloranfenicol', null, true, false, null, null, null),
  (66, '7501109762446', 'FC-09762446', 'Colchiquim 1 mg', 'COLCHIQUIM 1 MG C/20 TAB | QUIMICA Y FARMACIA', 2, 36.08, 58, 'generico', 'Medicamentos', null, 'Tableta', 'Colchiquim', 'Química y Farmacia', 'Caja 20 tabletas', 'Colchicina', '1 mg', true, false, null, null, null),
  (67, '7501385491139', 'FC-85491139', 'Deflamox Plus', 'DEFLAMOX PLUS TAB C/16 | SANFER', 2, 53.94, 68, 'marca', 'Antibióticos', null, 'Tableta', 'Deflamox', 'Sanfer', 'Caja 16 tabletas', 'Amoxicilina / ácido clavulánico', null, true, false, null, null, null),
  (68, '7800005082024', 'FC-05082024', 'Oral-B Essential hilo dental', 'HILO DENTAL ORAL-B ESSENTIAL | PG PERF', 1, 73.51, 92, 'marca', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', 'Oral-B', 'P&G', '1 unidad', null, null, false, false, null, null, null),
  (69, '7501007501031', 'FC-07501031', 'Johnson''s Baby jabón neutro', 'JABON JOHNSONS BABY NEUTRO 75 GR | JOHNSON & JOHNSON', 2, 14.50, 19, 'marca', 'Cuidado personal', 'Bebé', 'Jabón', 'Johnson''s', 'Johnson & Johnson', 'Barra 75 g', null, null, false, false, null, null, null),
  (70, '7502222840349', 'FC-22840349', 'Cloranfenicol gotas oftálmicas', '(RE) CLORANFENICOL OFT GTS 15 ML (ALVARTIS) | ALVARTIS', 3, 21.86, 35, 'generico', 'Oftalmología', null, 'Gotas oftálmicas', 'Alvartis', 'Alvartis', 'Frasco 15 mL', 'Cloranfenicol', null, true, false, null, null, null),
  (71, '7501289511414', 'FC-89511414', 'Pasta Lassar', 'PASTA LASSAR TARRO 60 GR | ANDROMACO', 2, 49.29, 62, 'marca', 'Dermatología', 'Protectores', 'Pasta', 'Pasta Lassar', 'Andrómaco', 'Tarro 60 g', 'Óxido de zinc', null, false, true, null, null, null),
  (72, '7501289511421', 'FC-89511421', 'Pasta Lassar', 'PASTA LASSAR TARRO 30 GR | ANDROMACO', 3, 23.62, 30, 'marca', 'Dermatología', 'Protectores', 'Pasta', 'Pasta Lassar', 'Andrómaco', 'Tarro 30 g', 'Óxido de zinc', null, false, true, null, null, null),
  (73, '7501349028654', 'FC-49028654', 'Hipromelosa oftálmica', 'IV HIPROMELOSA OFT SOL 10 ML | AMSA', 3, 22.51, 37, 'generico', 'Oftalmología', null, 'Solución oftálmica', 'AMSA', 'AMSA', 'Frasco 10 mL', 'Hipromelosa', null, false, false, null, null, null),
  (74, '7503003406785', 'FC-03406785', 'Torunda de algodón Quirmex', 'TORUNDA DE ALGODON QUIRMEX 75 GR | QUIRMEX', 2, 16.65, 21, 'marca', 'Botiquín', 'Material de curación', 'Algodón', 'Quirmex', 'Quirmex', 'Bolsa 75 g', null, null, false, true, null, null, null),
  (75, '78924345', 'FC-78924345', 'Rexona Women Bamboo roll-on', 'DES REXONA ROLL ON BAMBOO 50 ML | UNILEVER', 1, 29.11, 37, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', 'Unilever', 'Envase 50 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/rexona-women-bamboo-roll-on-50-ml-78924345.jpg', 'catalogo-propia/rexona-women-bamboo-roll-on-50-ml-78924345.jpg', null),
  (76, '7891051037878', 'FC-51037878', 'Oral-B Complete enjuague bucal', 'ENJ BUCAL ORAL B COMPLET 250 ML | PG PERF', 2, 47.75, 60, 'marca', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'Oral-B', 'P&G', 'Botella 250 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-complet-250ml.jpg', 'catalogo-propia/oral-b-enjuague-complet-250ml.jpg', null),
  (77, '7501056342258', 'FC-56342258', 'Sedal Restauración Instantánea crema para peinar', 'CRE PEINAR SEDAL RESTAURACION 135 ML | UNILEVER', 3, 16.74, 21, 'marca', 'Cuidado personal', 'Capilar', 'Crema', 'Sedal', 'Unilever', 'Tubo 135 mL', null, null, false, true, null, null, null),
  (78, '7500435179980', 'FC-35179980', 'Oral-B 100% enjuague bucal', 'ENJ BUCAL ORAL B 100% 250 ML | P&G PERF', 2, 53.49, 67, 'marca', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'Oral-B', 'P&G', 'Botella 250 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/oral-b-enjuague-100-250ml.jpg', 'catalogo-propia/oral-b-enjuague-100-250ml.jpg', null),
  (79, '7500435137737', 'FC-35137737', 'Oral-B Kids Princess pasta dental', 'CREMA DENT ORAL-B KIDS PRINCESS 37 ML | PG PERF', 2, 25.19, 32, 'marca', 'Cuidado personal', 'Higiene bucal', 'Pasta', 'Oral-B', 'P&G', 'Tubo 37 mL', null, null, false, false, null, null, null),
  (80, '6502400368802', 'FC-00368802', 'Silka Medic spray', 'SILKA MEDIC SPRAY 150 ML | GENOMMA LAB', 1, 142.49, 179, 'marca', 'Dermatología', 'Antifúngico', 'Spray', 'Silka', 'Genomma Lab', 'Spray 150 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/silka-medic-spray-150ml-6502400368802.jpg', 'catalogo-propia/silka-medic-spray-150ml-6502400368802.jpg', null),
  (81, '7501008491041', 'FC-08491041', 'Lotrimin Power spray', 'LOTRIMIN PWR SPRAY 150 ML | BAYER OTC', 2, 90.30, 113, 'marca', 'Dermatología', 'Antifúngico', 'Spray', 'Lotrimin', 'Bayer', 'Spray 150 mL', 'Tolnaftato', null, false, false, 'https://www.farmacapital.mx/catalogo-propia/lotrimin-power-spray-150ml-7501008491041.jpg', 'catalogo-propia/lotrimin-power-spray-150ml-7501008491041.jpg', null),
  (82, '6758730020716', 'FC-30020716', 'Sukrol Mujer', 'SUKROL MUJER TAB C/30 | FARMAMEDICA', 1, 131.30, 165, 'marca', 'Vitaminas', null, 'Tableta', 'Sukrol', 'Farmamédica', 'Caja 30 tabletas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sukrol-mujer-30-tab-6758730020716.jpg', 'catalogo-propia/sukrol-mujer-30-tab-6758730020716.jpg', null),
  (83, '6502400331318', 'FC-00331318', 'Vanart Hierbas shampoo', 'SHAM VANART HIERBAS 750 ML | GENOMMA LAB', 2, 26.46, 34, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Vanart', 'Genomma Lab', 'Frasco 750 mL', null, null, false, false, null, null, null),
  (84, '6502400331554', 'FC-00331554', 'Vanart Rosa enjuague', 'ENJUAGUE VANART ROSA 750 ML | GENOMMA LAB', 1, 42.53, 54, 'marca', 'Cuidado personal', 'Capilar', 'Enjuague', 'Vanart', 'Genomma Lab', 'Frasco 750 mL', null, null, false, false, null, null, null),
  (85, '7500435169004', 'FC-35169004', 'Herbal Essences Ondas Perfectas mousse', 'MOUSSE HERBAL ESSENCES ONDAS PERF 200 GR | PG PERF', 3, 69.56, 87, 'marca', 'Cuidado personal', 'Capilar', 'Mousse', 'Herbal Essences', 'P&G', 'Envase 200 g', null, null, false, false, null, null, null),
  (86, '7500435162265', 'FC-35162265', 'Head & Shoulders Limpieza Renovadora', 'SHAM HEAD & S LIMP RENOV 650 ML | PG PERF', 1, 123.03, 154, 'marca', 'Cuidado personal', 'Capilar', 'Shampoo', 'Head & Shoulders', 'P&G', 'Frasco 650 mL', null, null, false, false, null, null, null),
  (87, '7500435169035', 'FC-35169035', 'Herbal Essences Rizos mousse', 'MOUSSE HERBAL ESSENCES RIZOS 200 GR | PG PERF', 3, 69.56, 87, 'marca', 'Cuidado personal', 'Capilar', 'Mousse', 'Herbal Essences', 'P&G', 'Envase 200 g', null, null, false, true, null, null, null),
  (88, '7501056342227', 'FC-56342227', 'Sedal Rizos Obedientes crema para peinar', 'CRE PEINAR SEDAL RIZOS OBED 135 ML | UNILEVER', 3, 16.74, 21, 'marca', 'Cuidado personal', 'Capilar', 'Crema', 'Sedal', 'Unilever', 'Tubo 135 mL', null, null, false, true, null, null, null),
  (89, '7506376000277', 'FC-76000277', 'Vitacilina facial humectante', 'CRE VITACILINA FACIAL HUMECTANTE 100 GR | KSK', 2, 73.10, 92, 'marca', 'Cuidado personal', 'Facial', 'Crema', 'Vitacilina', 'KSK', 'Tarro 100 g', null, null, false, true, null, null, null),
  (90, '7506376000260', 'FC-76000260', 'Vitacilina facial aclarado', 'CRE VITACILINA FACIAL ACLARADO 100 GR | KSK', 1, 73.10, 92, 'marca', 'Cuidado personal', 'Facial', 'Crema', 'Vitacilina', 'KSK', 'Tarro 100 g', null, null, false, true, null, null, null),
  (91, '7502250343102', 'FC-50343102', 'Vitacilina facial melatonina', 'CRE VITACILINA FACIAL MELATONINA 100 GR | KSK', 2, 104.63, 131, 'marca', 'Cuidado personal', 'Facial', 'Crema', 'Vitacilina', 'KSK', 'Tarro 100 g', null, null, false, true, null, null, null),
  (92, '78924338', 'FC-78924338', 'Rexona Powder roll-on', 'DES REXONA ROLL ON POWDER 50 ML | UNILEVER', 1, 29.11, 37, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', 'Unilever', 'Envase 50 mL', null, null, false, true, null, null, null),
  (93, '78926523', 'FC-78926523', 'Rexona Active Emotion roll-on', 'DES REXONA ROLL ON ACT EMOTION 50 ML | UNILEVER', 1, 29.11, 37, 'marca', 'Cuidado personal', 'Desodorante', 'Roll-on', 'Rexona', 'Unilever', 'Envase 50 mL', null, null, false, true, null, null, null),
  (94, '7501048640034', 'FC-48640034', 'Vaso recolector Degasa', 'VASO RECOLECTOR DEGASA | DEGASA', 5, 4.37, 6, 'marca', 'Botiquín', 'Material médico', 'Vaso', 'Degasa', 'Degasa', '1 unidad', null, null, false, false, null, null, null),
  (95, '7501059233072', 'FC-59233072', 'Nido Kinder', 'LECHE NIDO KINDER BOLSA 1.44 KG | MARCAS NESTLE', 8, 29.36, 37, 'marca', 'Nutrición', 'Leche en polvo', 'Polvo', 'Nido', 'Nestlé', 'Bolsa 1.44 kg', null, null, false, true, null, null, null),
  (96, '7501059282117', 'FC-59282117', 'Nido Nutri Rindes', 'LECHE NIDO NUTRI RINDES BOLSA 240 GR | MARCAS NESTLE', 4, 29.74, 38, 'marca', 'Nutrición', 'Leche en polvo', 'Polvo', 'Nido', 'Nestlé', 'Bolsa 240 g', null, null, false, true, null, null, null),
  (97, '6502400721541', 'FC-00721541', 'Suerox Vitamins manzana y limón', 'SUEROX VITAMINS MANZANA V-LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (98, '7501033958717', 'FC-33958717', 'Ensure Advance vainilla', 'ENSURE ADVANCE VAINILLA 237 ML | ABBOTT', 1, 50.47, 64, 'marca', 'Suplemento', 'Nutrición clínica', 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-vainilla-237ml-7501033958717.jpg', 'catalogo-propia/ensure-advance-vainilla-237ml-7501033958717.jpg', null),
  (99, '7501033962530', 'FC-33962530', 'Ensure Advance café', 'ENSURE ADVANCE CAFE 237 ML | ABBOTT OTC', 1, 50.47, 64, 'marca', 'Suplemento', 'Nutrición clínica', 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-cafe-237ml-7501033962530.jpg', 'catalogo-propia/ensure-advance-cafe-237ml-7501033962530.jpg', null),
  (100, '7501033960499', 'FC-33960499', 'Ensure Advance fresa', 'ENSURE ADVANCE FRESA 237 ML | ABBOTT', 1, 50.47, 64, 'marca', 'Suplemento', 'Nutrición clínica', 'Líquido', 'Ensure', 'Abbott', 'Frasco 237 mL', null, null, false, true, 'https://www.farmacapital.mx/catalogo-propia/ensure-advance-suplemento-l-quido-237-ml-7501033960499.jpg', 'catalogo-propia/ensure-advance-suplemento-l-quido-237-ml-7501033960499.jpg', null),
  (101, '6502400744481', 'FC-00744481', 'Suerox 8 iones coco piña', 'SUEROX 8IONES COCO PINA 630 ML | GENOMMA LAB', 3, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (102, '6502400323252', 'FC-00323252', 'Suerox 8 iones lima limón', 'SUEROX 8IONES LIMA LIMON 630 ML | GENOMMA LAB', 2, 14.73, 24, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 630 mL', null, null, false, true, null, null, null),
  (103, '6502400801590', 'FC-00801590', 'Suerox Mineral mora azul', 'SUEROX MINERAL MORA AZUL 355 ML | GENOMMA LAB', 2, 15.19, 25, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 355 mL', null, null, false, false, null, null, null),
  (104, '6502400801668', 'FC-00801668', 'Suerox Mineral fresa kiwi', 'SUEROX MINERAL FRESA KIWI 355 ML | GENOMMA LAB', 2, 15.19, 25, 'generico', 'Bebidas', 'Electrolitos', 'Bebida', 'Suerox', 'Genomma Lab', 'Botella 355 mL', null, null, false, false, null, null, null),
  (105, '7501059225350', 'FC-59225350', 'Nido Kinder', 'LECHE NIDO KINDER 800 GR | MARCAS NESTLE', 1, 137.56, 172, 'marca', 'Nutrición', 'Leche en polvo', 'Polvo', 'Nido', 'Nestlé', 'Lata 800 g', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/nido-kinder-800g-7501059225350.jpg', 'catalogo-propia/nido-kinder-800g-7501059225350.jpg', null),
  (106, '7502001166066', 'FC-01166066', 'Barmicil crema', 'BARMICIL CREMA 40 G | LAB QUIMICA SON S', 6, 20.06, 26, 'marca', 'Dermatología', 'Antifúngico', 'Crema', 'Barmicil', 'Química Son''s', 'Tubo 40 g', null, null, false, true, null, null, null),
  (107, '6502400503982', 'FC-00503982', 'Alliviax 550 mg', 'ALLIVIAX 550 MG TAB C/20 | GENOMMA LAB', 1, 0.01, 1, 'marca', 'Analgésico', null, 'Tableta', 'Alliviax', 'Genomma Lab', 'Caja 20 tabletas', 'Naproxeno', '550 mg', false, false, null, null, null),
  (108, '7501058799685', 'FC-58799685', 'Sico Mutual Climax', 'COND SICO MUTUAL CLIMAX C/3 | RB HEALTH', 5, 80.95, 102, 'marca', 'Cuidado personal', 'Preservativos', 'Condón', 'Sico', 'RB Health', 'Caja 3 piezas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sico-mutual-climax-3-7501058799685.jpg', 'catalogo-propia/sico-mutual-climax-3-7501058799685.jpg', null),
  (109, '7501058799685', 'FC-58799685', 'Sico Mutual Climax', 'COND SICO MUTUAL CLIMAX C/3 | RB HEALTH', 1, 0.01, 1, 'marca', 'Cuidado personal', 'Preservativos', 'Condón', 'Sico', 'RB Health', 'Caja 3 piezas', null, null, false, false, 'https://www.farmacapital.mx/catalogo-propia/sico-mutual-climax-3-7501058799685.jpg', 'catalogo-propia/sico-mutual-climax-3-7501058799685.jpg', null);

-- Una fila por EAN (mismo producto con 2 lotes no debe insertar 2 veces el SKU).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'FC-ND-' || right(t.ean, 8)
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Farmalive 12127 · 2026-09-28 · listo para pistola',
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
  from _fc_fl_12127
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

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
  from _fc_fl_12127
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
  from _fc_fl_12127
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Farmalive',
  '12127',
  '2026-09-28',
  11696.80,
  'borrador',
  'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 16:24 · Club de Precios · tarjeta · 109 art / 238 pzas · subtotal $12,642.62 − desc $945.82 = $11,696.80 · precio neto · Suerox EAN canónico · cola Recibir; stock al confirmar pistola + MMAA'
where not exists (
  select 1 from public.recepciones
  where folio = '12127'
    and coalesce(proveedor, '') ilike '%farmalive%'
);

update public.recepciones
set
  total_ticket = 11696.80,
  fecha = '2026-09-28',
  proveedor = 'Farmalive',
  notas = 'Ticket Farmalive 12127 · Club Iztapalapa 1 · 28-sep-2026 16:24 · Club de Precios · tarjeta · 109 art / 238 pzas · subtotal $12,642.62 − desc $945.82 = $11,696.80 · precio neto · Suerox EAN canónico · cola Recibir; stock al confirmar pistola + MMAA',
  updated_at = now()
where folio = '12127'
  and coalesce(proveedor, '') ilike '%farmalive%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '12127'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_12127 t
join public.recepciones r
  on r.folio = '12127'
 and coalesce(r.proveedor, '') ilike '%farmalive%'
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
from _fc_fl_12127 t
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
where r.folio = '12127'
  and coalesce(r.proveedor, '') ilike '%farmalive%'
group by r.id, r.folio, r.proveedor, r.estado, r.total_ticket;

select
  t.linea,
  t.ean,
  t.nombre,
  t.qty,
  t.costo,
  case when public.fc_buscar_producto_escaneo(t.ean) is null then 'PENDIENTE_ALTA' else 'OK' end as match,
  t.ya as marcado_ya
from _fc_fl_12127 t
order by t.linea;

commit;
