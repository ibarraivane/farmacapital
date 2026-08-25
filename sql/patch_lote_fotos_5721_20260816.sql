-- ============================================================================
-- FARMA CAPITAL — Lote fotos IMG_5721–6042 (16-ago-2026)
--
-- Aunque el producto YA exista, se llena lo vacío:
--   codigo_barras, activo=true, presentacion, principio_activo,
--   forma_farmaceutica, marca, concentracion, unidades_por_caja.
-- No pisa un campo que ya tenga valor. No toca costo, precio ni stock.
--
-- 1) UPDATE de SKU existentes (EQ-/FC- y los que ya tenían EAN).
-- 2) INSERT de cajas que no están (marca nueva u otra presentación).
--
-- No pone EAN en: árnicas (ya tienen otro), Degortzin 4579, eucalipto Madrid,
-- gomenolado (faltó foto de código). No usa fotos duplicadas del lote.
-- Idempotente. No va en transacción.
-- ============================================================================

do $upd$
declare
  r record;
  v_id bigint;
begin
  for r in
    select * from (values
      ('EQ-ALP0300', '7501384504908', 'Caja con 20 tabletas', 'Ácido acetilsalicílico', 'Tableta efervescente', 'Psicofarma', '300 mg', 20),  -- 0048 Ácido acetilsalicílico
      ('EQ-AMS398', '7501349025271', 'Frasco ámpula 1.2 MU', 'Benzatina / procaína / cristalina', 'Suspensión inyectable', 'AMSA', '1 200 000 UI', null),  -- 0032 Bencilpenicilina compuesta
      ('EQ-AMS406', '7501349027312', 'Caja con comprimidos', 'Cinitaprida', 'Comprimido', 'AMSA', '1 mg', null),  -- 0123 Cinitaprida
      ('EQ-HIS075', '7502213042325', 'Caja con 40 cápsulas', 'Nitrofurantoína', 'Cápsula', 'FM', '100 mg', 40),  -- 0078 Terfhicid
      ('EQ-HIS076', '7502213042370', 'Caja con 3 ampolletas', 'Hioscina', 'Solución inyectable', 'Hispanoamericana', '20 mg/1 mL', 3),  -- 0110 FHaspem
      ('EQ-HIS085', '7502213042745', '200 dosis', 'Ipratropio', 'Aerosol', 'Hispanoamericana', '20 µg', 200),  -- 0022 Protaisol
      ('EQ-HIS087', '7502213042752', '200 dosis', 'Beclometasona', 'Aerosol', 'Hispanoamericana', '50 µg', 200),  -- 0090 CloFHiven
      ('EQ-MAI071', '785118752330', 'Frasco 60 mL', 'Claritromicina', 'Suspensión', 'MAVI', '125 mg/5 mL', null),  -- 0104 Krobicin
      ('EQ-MAI141', '785118753887', 'Caja con 8 tabletas', 'Ofloxacino', 'Tableta', 'MAVI', '400 mg', 8),  -- 0113 Flosep
      ('EQ-MAV142', '7502009741500', 'Caja con 15 tabletas', 'Cefalexina / Ambroxol', 'Tableta', 'Maver', '500 mg / 30 mg', 15),  -- 0086 Cefabroxil
      ('EQ-NOV025', '7501075715927', 'Caja con 6 tabletas', 'Albendazol', 'Tableta', 'Novag', '200 mg', 6),  -- 0080 Vermisen
      ('EQ-NOV165', '7501075726251', 'Caja con 5 ampolletas', 'Budesonida', 'Suspensión para nebulizar', 'Novag', '0.125 mg/mL', 5),  -- 0119 Budenova
      ('EQ-NOV179', '7501075727425', 'Caja con 10 tabletas', 'PARACETAMOL', 'Tableta', 'Novag', '500 mg', 10),  -- 0001 Acetif
      ('EQ-PGE052', '7503027446125', 'Caja con 30 cápsulas', 'Calcitriol', 'Cápsula', null, '0.25 µg', 30),  -- 0114 Ercatriv-M
      ('EQ-SON039', '7502001163782', 'Caja con 12 cápsulas', 'Dicloxacilina', 'Cápsula', 'SON''S', '500 mg', 12),  -- 0071 Dicleophen
      ('EQ-SON160', '7502001164833', 'Caja con 1 ampolleta', 'Betametasona', 'Suspensión inyectable', 'SON''S', '5 mg / 2 mg', 1),  -- 0003 Dison's Dex
      ('EQ-SON237', '7502001165328', 'Caja con 20 cápsulas', 'Ampicilina', 'Cápsula', 'SON''S', '500 mg', 20),  -- 0051 Expicin
      ('EQ-SON256', '7502001166592', 'Tubo 40 g', 'Betametasona', 'Crema', 'SON''S', '0.1%', null),  -- 0112 Sonblefam's
      ('EQ-WER038', '7502240450018', 'Caja con 3 tabletas', 'Azitromicina', 'Tableta', 'Wermar', '500 mg', 3),  -- 0049 Charyn
      ('FC-01B2F362', '7502009741067', 'Frasco 50 mL', 'Cefaclor', 'Suspensión', 'Maver', '375 mg/5 mL', null),  -- 0060 Fasiclor
      ('FC-05965071', '7502001169296', 'Frasco 60 mL', 'Amoxicilina / Bromhexina', 'Suspensión', 'SON''S', '250 mg / 8 mg / 5 mL', null),  -- 0056 Acroxil-C
      ('FC-07F04F88', '7501349011007', 'Caja con 1 frasco ámpula', 'Ceftriaxona', 'Solución inyectable', 'AMSA', '500 mg', 1),  -- 0010 Amcef IM
      ('FC-08DB70CB', '7503022640153', 'Frasco 200 g', 'Bicarbonato de sodio', 'Polvo', 'Velázquez', null, null),  -- 0144 Bicarbonato de sodio
      ('FC-0ACC5B6A', '3311000003722', '50 sobres', 'Óxido de zinc', 'Polvo', 'Mercurio', null, 50),  -- 0156 Óxido de zinc
      ('FC-0E0A9E42', null, null, 'Amoxicilina / Ácido clavulánico', 'Suspensión', 'Maver', '200 mg / 28.5 mg / 5 mL', null),  -- 0040 Clamoxín 12 H Pediátrico
      ('FC-11294615', null, 'Caja con 2 ampolletas', 'Amikacina', 'Solución inyectable', 'AMSA', '500 mg/2 mL', 2),  -- 0036 Amikacina
      ('FC-127F5753', null, 'Frasco 50 mL', 'Árnica', 'Solución', 'Mercurio', null, null),  -- 0139 Árnica de tomar
      ('FC-17376CAE', '7502001162976', 'Caja con 30 comprimidos', 'Ácido acetilsalicílico', 'Comprimido liberación retardada', 'SON''S', '100 mg', 30),  -- 0081 Aspitak-P
      ('FC-1DA570E3', null, 'Caja con 20 comprimidos', 'Ambroxol', 'Comprimido', 'Biomep', '30 mg', 20),  -- 0093 Cloxan
      ('FC-1FBF5206', '7503002045008', 'Frasco', 'Reomatolum', 'Linimento', 'Del Viejito', null, null),  -- 0128 Reomatolum
      ('FC-1FEA2FB7', '7501349021440', 'Caja con 1 ampolleta', 'Amikacina', 'Solución inyectable', 'AMSA', '500 mg/2 mL', 1),  -- 0037 Amikacina
      ('FC-1FFBB505', '785118754242', 'Frasco 120 mL', 'Ambroxol / Levodropropizina', 'Solución', 'MAVI', '300 mg / 600 mg / 100 mL', null),  -- 0106 Supratex DAC
      ('FC-2005DD57', '581520933707', 'Caja con 20 cápsulas', 'Cefalexina', 'Cápsula', 'AMSA', '500 mg', 20),  -- 0057 Cefalexina
      ('FC-25E452B6', null, 'Frasco 50 mL', 'Árnica', 'Solución', 'Mercurio', null, null),  -- 0141 Árnica de untar
      ('FC-281E0F22', '7501349024304', 'Ampolleta 2 mL', 'Budesonida', 'Suspensión para nebulizar', 'AMSA', '0.500 mg/2 mL', null),  -- 0016 Budesonida
      ('FC-29670370', '7501825304562', 'Frasco 50 mL', 'Cetirizina', 'Solución', 'Degort''s', '1 mg/mL', null),  -- 0017 Degortzin
      ('FC-2EDC6E3B', null, 'Caja con 10 tabletas', 'Cefuroxima', 'Tableta', 'Maver', '250 mg', 10),  -- 0074 Cefagen
      ('FC-357D4A17', null, 'Caja con 1 frasco ámpula', 'Ceftazidima', 'Solución inyectable', 'AMSA', '1 g', 1),  -- 0006 Ceftazidima
      ('FC-3676D5DC', '3311000001513', 'Frasco 50 mL', 'Espíritus de tomar', 'Solución', 'Mercurio', null, null),  -- 0134 Espíritus de tomar
      ('FC-38CAFE6B', '3311000001537', 'Frasco 50 mL', 'Aceite de romero', 'Aceite', 'Mercurio', null, null),  -- 0138 Aceite de romero
      ('FC-3A4583F3', '7501349012172', 'Frasco ámpula', 'Bencilpenicilina', 'Suspensión inyectable', 'AMSA', '400 000 UI', null),  -- 0045 Penipot
      ('FC-3B001F9B', '7502216804661', 'Caja con 30 tabletas', 'Amlodipino', 'Tableta', 'Avivia', '5 mg', 30),  -- 0029 Amlodipino
      ('FC-3CAA7C5C', '7503004908820', 'Caja con tabletas', 'Cinarizina', 'Tableta', null, '75 mg', null),  -- 0108 Cinarizina
      ('FC-40CE757D', '7502009740480', 'Caja con 20 cápsulas', 'Cefalexina', 'Cápsula', 'Maver', '500 mg', 20),  -- 0079 Cefalver
      ('FC-41339950', '7501349021686', 'Caja con tabletas', 'Claritromicina', 'Tableta', 'AMSA', '500 mg', null),  -- 0031 Claritromicina
      ('FC-428A228F', '780083140663', 'Caja con 12 cápsulas', 'Amoxicilina', 'Cápsula', 'Collins', '500 mg', 12),  -- 0020 Gimalxina
      ('FC-443C330E', '7502009741296', 'Frasco 50 mL', 'Cefuroxima', 'Suspensión', 'Maver', '250 mg/5 mL', null),  -- 0066 Cefagen
      ('FC-447B30F9', null, 'Ampolleta 2 mL', 'Budesonida', 'Suspensión para nebulizar', 'AMSA', '0.250 mg/2 mL', null),  -- 0012 Budesonida
      ('FC-47AAF23B', '3311000003494', 'Frasco', 'Sulfatiazol', 'Polvo', 'Mercurio', null, null),  -- 0158 Sulfatiazol
      ('FC-492D652F', '7502009745614', 'Caja con 12 tabletas', 'Cefalexina', 'Tableta', 'Maver', '1 g', 12),  -- 0085 Cefalver
      ('FC-4BD80686', null, 'Caja con 3 cápsulas', 'Cefixima', 'Cápsula', 'Maver', '400 mg', 3),  -- 0100 Beneventol
      ('FC-4C621D07', '7503001007205', 'Frasco 90 mL', 'Amoxicilina / Ambroxol', 'Suspensión', 'Wandel', '250 mg / 15 mg / 5 mL', null),  -- 0102 Vanmoxol
      ('FC-50587FA6', '7503001007120', 'Frasco 60 mL', 'Ampicilina', 'Suspensión', 'Wandel', '125 mg/5 mL', null),  -- 0063 Mexapin
      ('FC-50AC2C82', null, 'Caja con 1 ampolleta', 'Betametasona', 'Solución inyectable', 'Maver', '8 mg/2 mL', 1),  -- 0116 Erispan
      ('FC-516C2E89', null, 'Frasco 50 mL', 'Amoxicilina / Ácido clavulánico', 'Suspensión', 'Maver', '400 mg / 57 mg / 5 mL', null),  -- 0039 Clamoxín 12 H Junior
      ('FC-578F060C', '3311000003739', '50 sobres', 'Bórax', 'Polvo', 'Mercurio', null, 50),  -- 0155 Bórax polvo
      ('FC-58DB24C4', '7502009747373', 'Caja con 30 tabletas', 'Betahistina', 'Tableta', 'Maver', '24 mg', 30),  -- 0118 Bitenver
      ('FC-5A697CC2', '3311000001582', 'Frasco 50 mL', 'Aceite de olivo', 'Aceite', 'Mercurio', null, null),  -- 0136 Aceite de olivo
      ('FC-5D59ED54', '3311000000776', 'Caja 100 g', 'Cloruro de magnesio', 'Polvo', 'Mercurio', null, null),  -- 0160 Cloruro de magnesio
      ('FC-5D9DFA3D', null, 'Caja con 20 tabletas', 'Norfloxacino', 'Tableta', 'MAVI', '400 mg', 20),  -- 0021 Norquinol
      ('FC-5EF90195', null, 'Bolsa 3 g', 'Flor de árnica', 'Flor', 'Mercurio', null, null),  -- 0146 Flor de árnica
      ('FC-5F30F9D4', null, 'Caja con 10 tabletas', 'Amoxicilina / Ácido clavulánico', 'Tableta', 'Maver', '500 mg / 125 mg', 10),  -- 0033 Clamoxín
      ('FC-6074BB64', '7503000422498', 'Caja con 30 tabletas', 'Bezafibrato', 'Tableta', 'Maver', '200 mg', 30),  -- 0018 Redalip
      ('FC-60F627D5', '7501349026094', 'Caja con 5 ampolletas', 'Gentamicina', 'Solución inyectable', 'AMSA', '160 mg/2 mL', 5),  -- 0076 Gentamicina
      ('FC-62034164', '3311000001605', 'Frasco 50 mL', 'Espíritus de untar', 'Solución', 'Mercurio', null, null),  -- 0135 Espíritus de untar
      ('FC-6519183A', null, null, 'Amoxicilina / Ácido clavulánico', 'Suspensión', 'Maver', '125 mg / 31.25 mg / 5 mL', null),  -- 0083 Clamoxín
      ('FC-69387811', null, 'Frasco 50 mL', 'Aceite gomenolado', 'Aceite', 'Mercurio', null, null),  -- 0137 Aceite gomenolado
      ('FC-697EEAD0', '7502009747656', 'Tubo 15 g', 'Ácido fusídico / Betametasona', 'Crema', 'Maver', '20 mg / 1 mg', null),  -- 0092 Kurtosil
      ('FC-69A3C416', '7503001007694', 'Frasco 120 mL', 'Salbutamol / Ambroxol', 'Solución', null, '2 mg / 7.5 mg / 5 mL', null),  -- 0122 Wexpec
      ('FC-6EAD98A9', '7502009741289', 'Caja con 12 cápsulas', 'Cefalexina / Bromhexina', 'Cápsula', 'Maver', '500 mg / 8.8 mg', 12),  -- 0061 Cepobrom
      ('FC-74A5ABEE', '741339020894', 'Caja con tabletas', 'Ciprofloxacino', 'Tableta', 'AMSA', '250 mg', null),  -- 0054 Ciprofloxacino
      ('FC-7AA38F97', '7503000422719', 'Frasco 90 mL', 'Ampicilina', 'Suspensión', 'Maver', '250 mg/5 mL', null),  -- 0068 Pentiver
      ('FC-7F90064A', null, 'Caja con 1 frasco ámpula', 'Ampicilina', 'Solución inyectable', 'AMSA', '500 mg', 1),  -- 0098 Ampicilina
      ('FC-82F88FED', '7502216792579', 'Caja con 30 tabletas', 'Captopril', 'Tableta', 'Ultra', '25 mg', 30),  -- 0015 Captopril
      ('FC-830BF3FB', '7502001165311', 'Caja con 1 ampolleta', 'Algestona / Estradiol', 'Solución inyectable', 'SON''S', '150 mg / 10 mg', 1),  -- 0034 Diviltac
      ('FC-85BDBD3D', '7502001163775', 'Caja con 12 cápsulas', 'Amoxicilina / Bromhexina', 'Cápsula', 'SON''S', '500 mg / 8 mg', 12),  -- 0023 Acroxil-C
      ('FC-86A95D07', '54321342', 'Caja con 20 tabletas', 'Eritromicina', 'Tableta', 'Alpharma', '500 mg', 20),  -- 0047 Tropharma
      ('FC-885F2723', '7501384541163', 'Caja con 20 tabletas', 'Carbamazepina', 'Tableta', 'Psicofarma', '200 mg', 20),  -- 0014 Carbamazepina
      ('FC-8FB65B79', '7502009749223', 'Frasco 60 mL', 'Claritromicina', 'Suspensión', 'Maver', '250 mg/5 mL', null),  -- 0069 Klarix
      ('FC-930E0B1B', null, 'Frasco 75 mL', 'Amoxicilina', 'Suspensión', 'Wandel', '250 mg/5 mL', null),  -- 0095 Vandix
      ('FC-931B4809', '3311000001476', 'Frasco 50 mL', 'Aceite de coco', 'Aceite', 'Mercurio', null, null),  -- 0130 Aceite de coco
      ('FC-9507CD66', '3311000003388', 'Frasco', 'Haba alcanforada', 'Polvo', 'Mercurio', null, null),  -- 0153 Polvo de haba alcanforada
      ('FC-9538F7D6', null, 'Frasco 75 mL', 'Cefaclor', 'Suspensión', 'Maver', '250 mg/5 mL', null),  -- 0059 Fasiclor
      ('FC-9827438F', '3311000000882', 'Tarro 50 g', 'Veneno de abeja', 'Pomada', 'Mercurio', null, null),  -- 0145 Pomada veneno de abeja
      ('FC-9B93AC4C', null, 'Frasco 50 mL', 'Cefixima', 'Suspensión', 'Maver', '100 mg/5 mL', null),  -- 0011 Beneventol
      ('FC-9F67BB73', null, 'Frasco 60 mL', 'Dicloxacilina', 'Suspensión', 'Wandel', '250 mg/5 mL', null),  -- 0019 Amifarin
      ('FC-A455EE80', '7502009741302', 'Frasco 50 mL', 'Cefuroxima', 'Suspensión', 'Maver', '125 mg/5 mL', null),  -- 0077 Cefagen
      ('FC-A680F97E', '3311000001506', 'Frasco 50 mL', 'Yodo', 'Solución', 'Mercurio', null, null),  -- 0143 Yodo de tomar
      ('FC-A909ABC0', '7502009744877', 'Caja con 10 tabletas', 'Atorvastatina', 'Tableta', 'Maver', '20 mg', 10),  -- 0027 Odivitor
      ('FC-ACA2A2F6', '7301348804309', 'Caja con 20 tabletas', 'Alopurinol', 'Tableta', 'beadvance', '300 mg', 20),  -- 0067 Alopurinol
      ('FC-AE5EEDF7', '7503000422238', 'Caja con 20 tabletas', 'Sulfametoxazol / Trimetoprima', 'Tableta', 'Maver', '400 mg / 80 mg', 20),  -- 0117 Bactiver
      ('FC-AEA8C8DA', '817317520707', 'Caja con 20 tabletas', 'Ácido mefenámico', 'Tableta', 'Novag', '500 mg', 20),  -- 0065 Namifen
      ('FC-B2123139', '7501075717860', 'Caja con 4 tabletas', 'Ácido alendrónico', 'Tableta', 'Novag', '70 mg', 4),  -- 0091 Oxivag
      ('FC-B25094C4', '785118753528', 'Frasco 125 mL', 'ACICLOVIR', 'Suspensión', 'MAVI', '200 mg/5 mL', null),  -- 0002 Lesaclor
      ('FC-B4477A00', null, 'Caja con 16 cápsulas', 'Amoxicilina / Ambroxol', 'Cápsula', 'Maver', '500 mg / 30 mg', 16),  -- 0046 Pentibroxil
      ('FC-B69FCBF4', '785120753530', 'Caja con 35 tabletas', 'Aciclovir', 'Tableta', 'MAVI', '400 mg', 35),  -- 0088 Lesaclor
      ('FC-B72A6420', '7503000422696', 'Frasco 60 mL', 'Ampicilina', 'Suspensión', 'Maver', '500 mg/5 mL', null),  -- 0058 Pentiver
      ('FC-B8D7C997', '3311000003715', '50 sobres', 'Bicarbonato de sodio', 'Polvo', 'Mercurio', null, 50),  -- 0154 Bicarbonato
      ('FC-BE76D409', '7501349012004', 'Caja con 1 frasco ámpula', 'Ceftriaxona', 'Solución inyectable', 'AMSA', '1 g', 1),  -- 0009 Amcef IM
      ('FC-C101D5B1', '7501109763375', 'Caja con 30 tabletas', 'Bisoprolol', 'Tableta', 'iQuifa', '2.5 mg', 30),  -- 0070 Bisoprolol
      ('FC-C4530823', '3311000000936', 'Tarro 50 g', 'Óxido de zinc', 'Pomada', 'Mercurio', null, null),  -- 0148 Pomada de óxido de zinc
      ('FC-C636D8EA', '7506624900519', 'Caja con 1 frasco ámpula', 'Ceftriaxona', 'Solución inyectable', 'beadvance', '1 g', 1),  -- 0007 Ceftriaxona
      ('FC-C6C20517', '7502009748868', 'Caja con 20 tabletas', 'Bumetanida', 'Tableta', 'Maver', '1 mg', 20),  -- 0120 Budimin
      ('FC-C9F4ACCC', '7502216800984', 'Caja con 14 cápsulas', 'Acemetacina', 'Cápsula liberación prolongada', 'Ultra', '90 mg', 14),  -- 0111 Acemetacina
      ('FC-CB5C11ED', '3311000003425', 'Frasco', 'Magnesia anisada', 'Polvo', 'Mercurio', null, null),  -- 0157 Magnesia anisada
      ('FC-CF18C740', '5887400973807', 'Caja con 16 cápsulas', 'Clindamicina', 'Cápsula', 'AMSA', '300 mg', 16),  -- 0052 Clindamicina
      ('FC-D037156B', '3311000003708', 'Frasco', 'Bismuto subnitrato', 'Polvo', 'Mercurio', null, null),  -- 0159 Bismuto subnitrato
      ('FC-D3D28E20', '3311000000493', 'Frasco 50 mL', 'Yodo', 'Solución', 'Mercurio', null, null),  -- 0142 Yodo de untar
      ('FC-D4AC123B', '3311000001209', 'Frasco 50 mL', 'Aceite de almendras', 'Aceite', 'Mercurio', null, null),  -- 0131 Aceite de almendras
      ('FC-D5AC44CA', '7503001007113', 'Caja con 20 cápsulas', 'Dicloxacilina', 'Cápsula', 'Wandel', '500 mg', 20),  -- 0050 Amifarin
      ('FC-D9391288', '7501258210393', 'Frasco 15 mL', 'Azitromicina', 'Suspensión', 'Serral', '200 mg/5 mL', null),  -- 0053 Azitromicina
      ('FC-DB3B2584', '7501537102982', 'Caja con 1 ampolleta 2 mL', 'Betametasona', 'Solución inyectable', 'Bruluart', '8 mg/2 mL', 1),  -- 0004 Celesbitan
      ('FC-DF8ADDAB', '7502009745218', 'Caja con 1 ampolleta', 'Betametasona', 'Solución inyectable', 'Maver', '4 mg/mL', 1),  -- 0115 Erispan
      ('FC-E374F23E', '7502009745126', 'Caja con 10 tabletas', 'Cefuroxima', 'Tableta', 'Maver', '500 mg', 10),  -- 0087 Cefagen
      ('FC-E6112F15', '7502001165533', 'Caja con 20 tabletas', 'Ácido nalidíxico / Fenazopiridina', 'Tableta', 'SON''S', '500 mg / 50 mg', 20),  -- 0073 Nalixone
      ('FC-E69F2E63', null, 'Frasco', 'Aceite de eucalipto', 'Aceite', null, null, null),  -- 0127 Aceite de eucalipto
      ('FC-E6B50AC3', '7502216805361', 'Caja con 10 cápsulas', 'Celecoxib', 'Cápsula', 'Ultra', '200 mg', 10),  -- 0005 Celecoxib
      ('FC-E826D304', '7501349021983', 'Caja con ampolletas 2 mL', 'Lincomicina', 'Solución inyectable', 'AMSA', '600 mg/2 mL', null),  -- 0026 Lincomicina
      ('FC-EFB599B5', '3311000000868', 'Tarro 50 g', 'Pan puerco', 'Pomada', 'Mercurio', null, null),  -- 0147 Pomada de pan puerco
      ('FC-F183C6E9', null, 'Frasco ámpula', 'Bencilpenicilina', 'Suspensión inyectable', 'AMSA', '800 000 UI', null),  -- 0044 Penipot
      ('FC-F22C72BE', null, 'Caja con 10 tabletas', 'Amoxicilina / Ácido clavulánico', 'Tableta', 'Maver', '875 mg / 125 mg', 10),  -- 0038 Clamoxín 12 H
      ('FC-F4E9C71F', null, 'Frasco con polvo', 'Amoxicilina', 'Suspensión', 'AMSA', '500 mg/5 mL', null),  -- 0125 Amoxicilina
      ('FC-F817BC3A', '7502009746093', 'Tubo 20 g', 'Bifonazol', 'Crema', 'Maver', '1%', null),  -- 0025 Sibicos
      ('FC-F82A6E4B', null, 'Caja con tabletas', 'Ampicilina', 'Tableta', 'AMSA', '1 g', null),  -- 0043 Ampicilina
      ('FC-F8691496', '7503000422283', 'Caja con 14 tabletas', 'Sulfametoxazol / Trimetoprima', 'Tableta', 'Maver', '800 mg / 160 mg', 14),  -- 0028 Bactiver F
      ('FC-FBD776D2', '3311000003487', 'Frasco', 'Éter', 'Perlas', 'Mercurio', null, null),  -- 0152 Perlas de éter
      ('FC-FD718DF3', '3311000000967', 'Tarro 50 g', 'Sulfatiazol', 'Pomada', 'Mercurio', null, null),  -- 0151 Pomada de sulfatiazol
      ('FC-FD845E68', '7501349028791', 'Caja con tabletas', 'Aciclovir', 'Tableta', 'AMSA', '400 mg', null),  -- 0094 Aciclovir
      ('FC-FEAECBF1', '3311000001087', 'Tarro 50 g', 'Tepezcohuite', 'Pomada', 'Mercurio', null, null)  -- 0149 Pomada de tepezcohuite
    ) as t(sku, ean, presentacion, pa, forma, marca, conc, upc)
  loop
    v_id := null;
    select id into v_id from public.productos where sku = r.sku limit 1;
    if v_id is null then
      raise notice 'NO EXISTE %', r.sku;
      continue;
    end if;

    if r.ean is not null and exists (
      select 1 from public.productos o
       where o.codigo_barras = r.ean and o.sku <> r.sku
    ) then
      raise notice 'EAN % ya está en otro SKU, no lo pongo en %', r.ean, r.sku;
      r.ean := null;
    end if;

    update public.productos set
      activo              = true,
      codigo_barras       = case
                              when coalesce(codigo_barras,'') = '' and r.ean is not null
                              then r.ean else codigo_barras end,
      presentacion        = coalesce(nullif(presentacion,''), r.presentacion),
      principio_activo    = coalesce(nullif(principio_activo,''), r.pa),
      denominacion_generica = coalesce(nullif(denominacion_generica,''), r.pa),
      forma_farmaceutica  = coalesce(nullif(forma_farmaceutica,''), r.forma),
      marca               = coalesce(nullif(marca,''), r.marca),
      concentracion       = coalesce(nullif(concentracion,''), r.conc),
      unidades_por_caja   = coalesce(unidades_por_caja, r.upc)
    where id = v_id;

    raise notice 'ACTUALIZADO %', r.sku;
  end loop;
end
$upd$;


-- 2) Altas: no existían (o es otra presentación con EAN distinto)
do $alta$
declare
  r record;
  v_pid bigint;
  v_review text := '';
begin
  if exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'productos'
       and column_name = 'price_needs_review'
  ) then
    v_review := 'yes';
  end if;

  for r in
    select * from (values
      ('FC-42803524', '7501342803524', 'Ácido acetilsalicílico 100 mg Caja con 30 tabletas beadvance', 'Ácido acetilsalicílico', 'Tableta liberación retardada', 'Caja con 30 tabletas', 'beadvance', '100 mg', 30),
      ('FC-83141226', '780083141226', 'Perudil 150 mg / 10 mg Caja con 1 ampolleta Collins', 'Algestona / Estradiol', 'Solución inyectable', 'Caja con 1 ampolleta', 'Collins', '150 mg / 10 mg', 1),
      ('FC-49020269', '7501349020269', 'Ácido ursodeoxicólico 250 mg Caja con 50 cápsulas AMSA', 'Ácido ursodeoxicólico', 'Cápsula', 'Caja con 50 cápsulas', 'AMSA', '250 mg', 50),
      ('FC-46601138', '7506346601138', 'Merthorab Frasco 20 mL Kohn', 'Cloruro de benzalconio', 'Tintura', 'Frasco 20 mL', 'Kohn', null, null),
      ('FC-02045312', '7503002045312', 'Esencia de clavo Frasco gotero Herbotec', 'Aceite de clavo', 'Esencia', 'Frasco gotero', 'Herbotec', null, null),
      ('FC-00001612', '3311000001612', 'Jarabe de granada Frasco 50 mL Mercurio', 'Jarabe de granada', 'Jarabe', 'Frasco 50 mL', 'Mercurio', null, null),
      ('FC-00001292', '3311000001292', 'Aceite de ricino Frasco 50 mL Mercurio', 'Aceite de ricino', 'Aceite', 'Frasco 50 mL', 'Mercurio', null, null),
      ('FC-49028913', '7501349028913', 'Atorvastatina 40 mg Caja con 10 tabletas AMSA', 'Atorvastatina', 'Tableta', 'Caja con 10 tabletas', 'AMSA', '40 mg', 10),
      ('FC-49021570', '7501349021570', 'Amoxicilina 500 mg Caja con 12 cápsulas AMSA', 'Amoxicilina', 'Cápsula', 'Caja con 12 cápsulas', 'AMSA', '500 mg', 12),
      ('FC-01007250', '7503001007250', 'Valclan 875 mg / 125 mg Caja con 10 tabletas Wandel', 'Amoxicilina / Ácido clavulánico', 'Tableta', 'Caja con 10 tabletas', 'Wandel', '875 mg / 125 mg', 10),
      ('FC-01007199', '7503001007199', 'Valclan 500 mg / 125 mg Caja con 10 tabletas Wandel', 'Amoxicilina / Ácido clavulánico', 'Tableta', 'Caja con 10 tabletas', 'Wandel', '500 mg / 125 mg', 10),
      ('FC-28833707', '019828833707', 'Levofloxacino 500 mg Caja con 7 tabletas beadvance', 'Levofloxacino', 'Tableta', 'Caja con 7 tabletas', 'beadvance', '500 mg', 7),
      ('FC-09741425', '7502009741425', 'Fasiclor 500 mg Caja con 15 cápsulas Maver', 'Cefaclor', 'Cápsula', 'Caja con 15 cápsulas', 'Maver', '500 mg', 15),
      ('FC-52200809', '52200809', 'Cina 750 mg Caja con 7 tabletas Landsteiner', 'Levofloxacino', 'Tableta', 'Caja con 7 tabletas', 'Landsteiner', '750 mg', 7),
      ('FC-49021044', '7501349021044', 'Clindamicina 600 mg/4 mL Caja con 5 ampolletas AMSA', 'Clindamicina', 'Solución inyectable', 'Caja con 5 ampolletas', 'AMSA', '600 mg/4 mL', 5),
      ('FC-09741043', '7502009741043', 'Fasiclor 125 mg/5 mL Frasco 75 mL Maver', 'Cefaclor', 'Suspensión', 'Frasco 75 mL', 'Maver', '125 mg/5 mL', null),
      ('FC-09745140', '7502009745140', 'Clamoxín S 600 mg / 42.9 mg / 5 mL Frasco 50 mL Maver', 'Amoxicilina / Ácido clavulánico', 'Suspensión', 'Frasco 50 mL', 'Maver', '600 mg / 42.9 mg / 5 mL', null),
      ('FC-90973703', '5178190973703', 'Ampicilina 1 g Caja con 1 frasco ámpula AMSA', 'Ampicilina', 'Solución inyectable', 'Caja con 1 frasco ámpula', 'AMSA', '1 g', 1),
      ('FC-83141875', '780083141875', 'Gimalxina 250 mg/5 mL Frasco 75 mL Collins', 'Amoxicilina', 'Suspensión', 'Frasco 75 mL', 'Collins', '250 mg/5 mL', null),
      ('FC-00001049', '3311000001049', 'Pomada de árnica Tarro 50 g Mercurio', 'Árnica', 'Pomada', 'Tarro 50 g', 'Mercurio', null, null)
    ) as t(sku, ean, nombre, pa, forma, pres, marca, conc, upc)
  loop
    v_pid := null;
    select id into v_pid from public.productos
     where sku = r.sku or codigo_barras = r.ean
     limit 1;
    if v_pid is not null then
      -- ya existe: igual llena huecos
      update public.productos set
        activo = true,
        presentacion = coalesce(nullif(presentacion,''), r.pres),
        principio_activo = coalesce(nullif(principio_activo,''), r.pa),
        denominacion_generica = coalesce(nullif(denominacion_generica,''), r.pa),
        forma_farmaceutica = coalesce(nullif(forma_farmaceutica,''), r.forma),
        marca = coalesce(nullif(marca,''), r.marca),
        concentracion = coalesce(nullif(concentracion,''), r.conc),
        unidades_por_caja = coalesce(unidades_por_caja, r.upc),
        codigo_barras = case
          when coalesce(codigo_barras,'') = '' then r.ean else codigo_barras end
      where id = v_pid
        and not exists (
          select 1 from public.productos o
           where o.codigo_barras = r.ean and o.id <> v_pid
        );
      raise notice 'YA EXISTÍA %, huecos llenados', r.sku;
      continue;
    end if;

    if v_review = 'yes' then
      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta,
         presentacion, principio_activo, denominacion_generica,
         forma_farmaceutica, marca, concentracion, unidades_por_caja,
         price_needs_review)
      values
        (r.nombre, r.sku, r.ean, 'Medicamentos', 'marca',
         'Alta lote fotos IMG_5721-6042 2026-08-16 · sin costo · Ibarra corrige',
         0, 0, 0, 1, true, false,
         r.pres, r.pa, r.pa, r.forma, r.marca, r.conc, r.upc, true);
    else
      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta,
         presentacion, principio_activo, denominacion_generica,
         forma_farmaceutica, marca, concentracion, unidades_por_caja)
      values
        (r.nombre, r.sku, r.ean, 'Medicamentos', 'marca',
         'Alta lote fotos IMG_5721-6042 2026-08-16 · sin costo · Ibarra corrige',
         0, 0, 0, 1, true, false,
         r.pres, r.pa, r.pa, r.forma, r.marca, r.conc, r.upc);
    end if;
    raise notice 'CREADO %', r.sku;
  end loop;
end
$alta$;


-- Comprobación
select sku, nombre, codigo_barras, activo, presentacion, principio_activo,
       forma_farmaceutica, marca, concentracion, unidades_por_caja, costo, precio, stock
from public.productos
where sku in (
  'EQ-ALP0300','EQ-AMS398','EQ-AMS406','EQ-HIS075','EQ-HIS076','EQ-HIS085',
  'EQ-HIS087','EQ-MAI071','EQ-MAI141','EQ-MAV142','EQ-NOV025','EQ-NOV165',
  'EQ-NOV179','EQ-PGE052','EQ-SON039','EQ-SON160','EQ-SON237','EQ-SON256',
  'EQ-WER038','FC-01B2F362','FC-05965071','FC-07F04F88','FC-08DB70CB','FC-0ACC5B6A',
  'FC-0E0A9E42','FC-11294615','FC-127F5753','FC-17376CAE','FC-1DA570E3','FC-1FBF5206',
  'FC-1FEA2FB7','FC-1FFBB505','FC-2005DD57','FC-25E452B6','FC-281E0F22','FC-29670370',
  'FC-2EDC6E3B','FC-357D4A17','FC-3676D5DC','FC-38CAFE6B','FC-3A4583F3','FC-3B001F9B',
  'FC-3CAA7C5C','FC-40CE757D','FC-41339950','FC-428A228F','FC-443C330E','FC-447B30F9',
  'FC-47AAF23B','FC-492D652F','FC-4BD80686','FC-4C621D07','FC-50587FA6','FC-50AC2C82',
  'FC-516C2E89','FC-578F060C','FC-58DB24C4','FC-5A697CC2','FC-5D59ED54','FC-5D9DFA3D',
  'FC-5EF90195','FC-5F30F9D4','FC-6074BB64','FC-60F627D5','FC-62034164','FC-6519183A',
  'FC-69387811','FC-697EEAD0','FC-69A3C416','FC-6EAD98A9','FC-74A5ABEE','FC-7AA38F97',
  'FC-7F90064A','FC-82F88FED','FC-830BF3FB','FC-85BDBD3D','FC-86A95D07','FC-885F2723',
  'FC-8FB65B79','FC-930E0B1B','FC-931B4809','FC-9507CD66','FC-9538F7D6','FC-9827438F',
  'FC-9B93AC4C','FC-9F67BB73','FC-A455EE80','FC-A680F97E','FC-A909ABC0','FC-ACA2A2F6',
  'FC-AE5EEDF7','FC-AEA8C8DA','FC-B2123139','FC-B25094C4','FC-B4477A00','FC-B69FCBF4',
  'FC-B72A6420','FC-B8D7C997','FC-BE76D409','FC-C101D5B1','FC-C4530823','FC-C636D8EA',
  'FC-C6C20517','FC-C9F4ACCC','FC-CB5C11ED','FC-CF18C740','FC-D037156B','FC-D3D28E20',
  'FC-D4AC123B','FC-D5AC44CA','FC-D9391288','FC-DB3B2584','FC-DF8ADDAB','FC-E374F23E',
  'FC-E6112F15','FC-E69F2E63','FC-E6B50AC3','FC-E826D304','FC-EFB599B5','FC-F183C6E9',
  'FC-F22C72BE','FC-F4E9C71F','FC-F817BC3A','FC-F82A6E4B','FC-F8691496','FC-FBD776D2',
  'FC-FD718DF3','FC-FD845E68','FC-FEAECBF1','FC-42803524','FC-83141226','FC-49020269',
  'FC-46601138','FC-02045312','FC-00001612','FC-00001292','FC-49028913','FC-49021570',
  'FC-01007250','FC-01007199','FC-28833707','FC-09741425','FC-52200809','FC-49021044',
  'FC-09741043','FC-09745140','FC-90973703','FC-83141875','FC-00001049'
)
order by sku;
