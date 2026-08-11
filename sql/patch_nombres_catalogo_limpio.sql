-- ============================================================
-- Catálogo limpio: nombre, marca, presentación, descripción
-- 561 productos · NO modifica costo ni precio
-- Fuente: actualizar_catalogo + parser + overrides manuales
-- Ejecutar UNA vez en Supabase después del patch de precios.
-- ============================================================

begin;

-- FC-00003920 | Mercurio Arnica
update public.productos set nombre = 'Mercurio Arnica', marca = 'Mercurio', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Arnica' where sku = 'FC-00003920';

-- FC-00701992 | Nivea Manos 3En1 Ant-Arrugas
update public.productos set nombre = 'Nivea Manos 3En1 Ant-Arrugas', marca = 'Nivea', presentacion = '75 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea Manos 3En1 Ant-Arrugas' where sku = 'FC-00701992';

-- FC-00942760 | Gel facial hidratante hialurónico
update public.productos set nombre = 'Gel facial hidratante hialurónico', marca = 'Nivea', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Gel facial hidratante hialurónico' where sku = 'FC-00942760';

-- FC-00E8A9C7 | Fotosun UV100
update public.productos set nombre = 'Fotosun UV100', marca = 'Fotosun', presentacion = '125 ML', concentracion = 'C/125 ML S0-FP$', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Fotosun UV100' where sku = 'FC-00E8A9C7';

-- FC-01015141 | Lubricante original
update public.productos set nombre = 'Lubricante original', marca = 'Softlub', presentacion = '56.7 G', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lubricante original' where sku = 'FC-01015141';

-- FC-01157296 | Naturella Flujo Mod C/Alas
update public.productos set nombre = 'Naturella Flujo Mod C/Alas', marca = 'Naturella', presentacion = 'C/8', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Naturella Flujo Mod C/Alas' where sku = 'FC-01157296';

-- FC-01165321 | Pantene Acond Rizos Definid
update public.productos set nombre = 'Pantene Acond Rizos Definid', marca = 'Pantene', presentacion = '400 ML', tipo = 'marca', descripcion = 'Pantene Acond Rizos Definid' where sku = 'FC-01165321';

-- FC-01246730 | Vaporub Pom C12 Latas
update public.productos set nombre = 'Vaporub Pom C12 Latas', marca = 'Vaporub', presentacion = '12 G', categoria = 'Producto', tipo = 'marca', descripcion = 'Vaporub Pom C12 Latas' where sku = 'FC-01246730';

-- FC-01303454 | Pantene Ctrcaida A/Pv
update public.productos set nombre = 'Pantene Ctrcaida A/Pv', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pantene Ctrcaida A/Pv' where sku = 'FC-01303454';

-- FC-01405335 | Naturella Noche Con Alas
update public.productos set nombre = 'Naturella Noche Con Alas', marca = 'Naturella', presentacion = 'C/8', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Naturella Noche Con Alas' where sku = 'FC-01405335';

-- FC-01B2F362 | Fasiclor
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '125MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Fasiclor' where sku = 'FC-01B2F362';

-- FC-02012468 | Vaporub Ung
update public.productos set nombre = 'Vaporub Ung', marca = 'Vaporub', presentacion = '50 G', forma_farmaceutica = 'Balsamo', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Vaporub Ung' where sku = 'FC-02012468';

-- FC-02012475 | Vick Ung
update public.productos set nombre = 'Vick Ung', marca = 'Vick', presentacion = '100 G', forma_farmaceutica = 'Ungüento', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Vick Ung' where sku = 'FC-02012475';

-- FC-022543CD | Valclan
update public.productos set nombre = 'Valclan', marca = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Valclan' where sku = 'FC-022543CD';

-- FC-03406501 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '25 CM x 5 M', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-03406501';

-- FC-03406600 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-03406600';

-- FC-04D83B46 | Pralex
update public.productos set nombre = 'Pralex', marca = 'Pralex', presentacion = '28 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Pralex' where sku = 'FC-04D83B46';

-- FC-05965071 | Acroxil-C
update public.productos set nombre = 'Acroxil-C', marca = 'Acroxil-C', presentacion = '12 CAPSULAS', concentracion = '500/8 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Acroxil-C' where sku = 'FC-05965071';

-- FC-06134531 | Afrin Dtc (Rojo) 20
update public.productos set nombre = 'Afrin Dtc (Rojo) 20', marca = 'Afrin', forma_farmaceutica = 'SPRAY', categoria = 'Producto', tipo = 'marca', descripcion = 'Afrin Dtc (Rojo) 20' where sku = 'FC-06134531';

-- FC-06209862 | Axe 48H Anarchy Fresh Love Fo
update public.productos set nombre = 'Axe 48H Anarchy Fresh Love Fo', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe 48H Anarchy Fresh Love Fo' where sku = 'FC-06209862';

-- FC-06213906 | Axe Icechi E-Frio
update public.productos set nombre = 'Axe Icechi E-Frio', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Icechi E-Frio' where sku = 'FC-06213906';

-- FC-06217461 | Rexona Effi Fresh
update public.productos set nombre = 'Rexona Effi Fresh', marca = 'Rexona', presentacion = '200 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Effi Fresh' where sku = 'FC-06217461';

-- FC-06226852 | Axe Wom Anarchy
update public.productos set nombre = 'Axe Wom Anarchy', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Wom Anarchy' where sku = 'FC-06226852';

-- FC-06230507 | Dove Barra Karite Vainill
update public.productos set nombre = 'Dove Barra Karite Vainill', marca = 'Dove', presentacion = '135 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Dove Barra Karite Vainill' where sku = 'FC-06230507';

-- FC-06234062 | Sedal Anti Nudos
update public.productos set nombre = 'Sedal Anti Nudos', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Anti Nudos' where sku = 'FC-06234062';

-- FC-06241206 | Dove Dermac Sk-C 48H
update public.productos set nombre = 'Dove Dermac Sk-C 48H', marca = 'Dove', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Dove Dermac Sk-C 48H' where sku = 'FC-06241206';

-- FC-06244795 | Axe Intense 48H
update public.productos set nombre = 'Axe Intense 48H', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Intense 48H' where sku = 'FC-06244795';

-- FC-06245686 | Axe Men Epic-F 48H
update public.productos set nombre = 'Axe Men Epic-F 48H', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Men Epic-F 48H' where sku = 'FC-06245686';

-- FC-06247327 | Afrin Spray No Drip Extra Humectante Spray Drip Extra
update public.productos set nombre = 'Afrin Spray No Drip Extra Humectante Spray Drip Extra', marca = 'Afrin', tipo = 'marca', descripcion = 'Afrin Spray No Drip Extra Humectante Spray Drip Extra' where sku = 'FC-06247327';

-- FC-06247468 | Ego Fresh C-Cas Fij-Alt
update public.productos set nombre = 'Ego Fresh C-Cas Fij-Alt', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ego Fresh C-Cas Fij-Alt' where sku = 'FC-06247468';

-- FC-06248045 | Dove Spy Invisible Dry C3
update public.productos set nombre = 'Dove Spy Invisible Dry C3', marca = 'Dove', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Dove Spy Invisible Dry C3' where sku = 'FC-06248045';

-- FC-06248052 | Dove Aero Tono Uniforme 3Pack
update public.productos set nombre = 'Dove Aero Tono Uniforme 3Pack', marca = 'Dove', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Dove Aero Tono Uniforme 3Pack' where sku = 'FC-06248052';

-- FC-06249226 | Savile Bio-Sab Creci Res
update public.productos set nombre = 'Savile Bio-Sab Creci Res', marca = 'Savile', presentacion = '700 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Savile Bio-Sab Creci Res' where sku = 'FC-06249226';

-- FC-06249240 | Savile Ker-Sab Fza Repar
update public.productos set nombre = 'Savile Ker-Sab Fza Repar', marca = 'Savile', presentacion = '700 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Savile Ker-Sab Fza Repar' where sku = 'FC-06249240';

-- FC-06249776 | Sedal Ceramidas Inf-Act
update public.productos set nombre = 'Sedal Ceramidas Inf-Act', marca = 'Sedal', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Sedal Ceramidas Inf-Act' where sku = 'FC-06249776';

-- FC-06249783 | Sedal Rizos Def Inf-Act
update public.productos set nombre = 'Sedal Rizos Def Inf-Act', marca = 'Sedal', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Sedal Rizos Def Inf-Act' where sku = 'FC-06249783';

-- FC-06257597 | Rexona 1O0 G Tco Pies Efficient Orig
update public.productos set nombre = 'Rexona 1O0 G Tco Pies Efficient Orig', marca = 'Rexona', tipo = 'marca', descripcion = 'Rexona 1O0 G Tco Pies Efficient Orig' where sku = 'FC-06257597';

-- FC-07457796 | Pantene Brillo Extremo
update public.productos set nombre = 'Pantene Brillo Extremo', marca = 'Pantene', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pantene Brillo Extremo' where sku = 'FC-07457796';

-- FC-07457826 | Pantene Brillo Extremo
update public.productos set nombre = 'Pantene Brillo Extremo', marca = 'Pantene', presentacion = '40 ML', forma_farmaceutica = 'Acondicionador', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pantene Brillo Extremo' where sku = 'FC-07457826';

-- FC-07502441 | Johnson S Baby Antes/Dor
update public.productos set nombre = 'Johnson S Baby Antes/Dor', marca = 'Johnson', presentacion = '75 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Johnson S Baby Antes/Dor' where sku = 'FC-07502441';

-- FC-07521317 | Gotero de cristal
update public.productos set nombre = 'Gotero de cristal', marca = 'Genérico', forma_farmaceutica = 'Gotero', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Gotero de cristal' where sku = 'FC-07521317';

-- FC-07528939 | Lubriderm Thint Psec120 Ml
update public.productos set nombre = 'Lubriderm Thint Psec120 Ml', marca = 'Lubriderm', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Lubriderm Thint Psec120 Ml' where sku = 'FC-07528939';

-- FC-07F04F88 | I.M
update public.productos set nombre = 'I.M', marca = 'Amcef', presentacion = '1 FRASCO AMPULA', concentracion = '500MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'I.M' where sku = 'FC-07F04F88';

-- FC-08344488 | Lactopram
update public.productos set nombre = 'Lactopram', marca = 'Lactopram', presentacion = '430 MG · C/20', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Lactopram' where sku = 'FC-08344488';

-- FC-08344747 | Afrodit
update public.productos set nombre = 'Afrodit', marca = 'Afrodit', presentacion = '400 UI', categoria = 'Producto', tipo = 'marca', descripcion = 'Afrodit' where sku = 'FC-08344747';

-- FC-08426944 | Flanax
update public.productos set nombre = 'Flanax', marca = 'Flanax', presentacion = '40 G', forma_farmaceutica = 'GEL', categoria = 'Otro', tipo = 'marca', descripcion = 'Flanax' where sku = 'FC-08426944';

-- FC-08427330 | Bepanthen
update public.productos set nombre = 'Bepanthen', marca = 'Bepanthen', presentacion = '100 G', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', descripcion = 'Bepanthen' where sku = 'FC-08427330';

-- FC-08443026 | Alka-Seltzer
update public.productos set nombre = 'Alka-Seltzer', marca = 'Alka-Seltzer', presentacion = 'C/100', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Alka-Seltzer' where sku = 'FC-08443026';

-- FC-08485316 | Tabcin Eferv
update public.productos set nombre = 'Tabcin Eferv', marca = 'Tabcin', presentacion = '50 TABLETAS · C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tabcin Eferv' where sku = 'FC-08485316';

-- FC-08491074 | Aspirina
update public.productos set nombre = 'Aspirina', marca = 'Aspirina', presentacion = '80 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aspirina' where sku = 'FC-08491074';

-- FC-08491096 | Cafiaspirina Tar C/100
update public.productos set nombre = 'Cafiaspirina Tar C/100', marca = 'Cafiaspirina', presentacion = 'C/100', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cafiaspirina Tar C/100' where sku = 'FC-08491096';

-- FC-08496701 | Aspirina Eferv
update public.productos set nombre = 'Aspirina Eferv', marca = 'Aspirina', presentacion = 'C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aspirina Eferv' where sku = 'FC-08496701';

-- FC-08498798 | Bepanthen Multiusos Pomada 30 Multiusos Pomada
update public.productos set nombre = 'Bepanthen Multiusos Pomada 30 Multiusos Pomada', marca = 'Bepanthen', tipo = 'marca', descripcion = 'Bepanthen Multiusos Pomada 30 Multiusos Pomada' where sku = 'FC-08498798';

-- FC-08802838 | Nivea B Sofmilk Sec400 Ml
update public.productos set nombre = 'Nivea B Sofmilk Sec400 Ml', marca = 'Nivea', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea B Sofmilk Sec400 Ml' where sku = 'FC-08802838';

-- FC-08820243 | Dermodine Ine M 1 37.60 Ine
update public.productos set nombre = 'Dermodine Ine M 1 37.60 Ine', marca = 'Dermodine', tipo = 'marca', descripcion = 'Dermodine Ine M 1 37.60 Ine' where sku = 'FC-08820243';

-- FC-08837311 | Nivea Pearlb Mspy
update public.productos set nombre = 'Nivea Pearlb Mspy', marca = 'Nivea', presentacion = '150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Nivea Pearlb Mspy' where sku = 'FC-08837311';

-- FC-08895196 | Aspirina
update public.productos set nombre = 'Aspirina', marca = 'Aspirina', presentacion = 'C/10', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aspirina' where sku = 'FC-08895196';

-- FC-08DB70CB | Bicarbonato Velazquez Grande 200G
update public.productos set nombre = 'Bicarbonato Velazquez Grande 200G', marca = 'Bicarbonato', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', descripcion = 'Bicarbonato Velazquez Grande 200G' where sku = 'FC-08DB70CB';

-- FC-09419324 | Sensodyne Original
update public.productos set nombre = 'Sensodyne Original', marca = 'Sensodyne', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Sensodyne Original' where sku = 'FC-09419324';

-- FC-09498091 | Sensodyne Complet + Acc Lim Efec
update public.productos set nombre = 'Sensodyne Complet + Acc Lim Efec', marca = 'Sensodyne', presentacion = '90 G', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Sensodyne Complet + Acc Lim Efec' where sku = 'FC-09498091';

-- FC-0ACC5B6A | Mercurio Oxido De Zinc
update public.productos set nombre = 'Mercurio Oxido De Zinc', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Oxido De Zinc' where sku = 'FC-0ACC5B6A';

-- FC-0BDE9283 | Clophiven 200 Dosis 50 Mcg
update public.productos set nombre = 'Clophiven 200 Dosis 50 Mcg', marca = 'Clophiven', presentacion = '15 G', categoria = 'Producto', tipo = 'marca', descripcion = 'Clophiven 200 Dosis 50 Mcg' where sku = 'FC-0BDE9283';

-- FC-0E0A9E42 | S
update public.productos set nombre = 'S', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '600/42.9MG/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'S' where sku = 'FC-0E0A9E42';

-- FC-10974329 | Listerine Zero Mta Sve
update public.productos set nombre = 'Listerine Zero Mta Sve', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', descripcion = 'Listerine Zero Mta Sve' where sku = 'FC-10974329';

-- FC-11294615 | Amikacina
update public.productos set nombre = 'Amikacina', presentacion = '2 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', descripcion = 'Amikacina' where sku = 'FC-11294615';

-- FC-127F5753 | Mercurio Arnica Tomar 1780823 83156
update public.productos set nombre = 'Mercurio Arnica Tomar 1780823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Arnica Tomar 1780823 83156' where sku = 'FC-127F5753';

-- FC-1321B34F | Hidroxon
update public.productos set nombre = 'Hidroxon', marca = 'Hidroxon', presentacion = '30 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Hidroxon' where sku = 'FC-1321B34F';

-- FC-14119032 | Jabón azufre con miel
update public.productos set nombre = 'Jabón azufre con miel', marca = 'Azufre', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Jabón azufre con miel' where sku = 'FC-14119032';

-- FC-14121782 | Jabón proteína de arroz y concha nácar
update public.productos set nombre = 'Jabón proteína de arroz y concha nácar', marca = 'Genérico', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Jabón proteína de arroz y concha nácar' where sku = 'FC-14121782';

-- FC-14704156 | Senosiain Supos Adto C/10
update public.productos set nombre = 'Senosiain Supos Adto C/10', marca = 'Senosiain', presentacion = 'C/10', forma_farmaceutica = 'SUPOSITORIO', categoria = 'Otro', tipo = 'marca', descripcion = 'Senosiain Supos Adto C/10' where sku = 'FC-14704156';

-- FC-14704163 | Senosiain Supos Ine C/10
update public.productos set nombre = 'Senosiain Supos Ine C/10', marca = 'Senosiain', presentacion = 'C/10', forma_farmaceutica = 'SUPOSITORIO', categoria = 'Otro', tipo = 'marca', descripcion = 'Senosiain Supos Ine C/10' where sku = 'FC-14704163';

-- FC-14980596 | Prudence Mora Cond Mexico 34.10 Mora Cond Mexico
update public.productos set nombre = 'Prudence Mora Cond Mexico 34.10 Mora Cond Mexico', marca = 'Prudence', presentacion = 'C/3', tipo = 'marca', descripcion = 'Prudence Mora Cond Mexico 34.10 Mora Cond Mexico' where sku = 'FC-14980596';

-- FC-14982514 | Prudence
update public.productos set nombre = 'Prudence', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', descripcion = 'Prudence' where sku = 'FC-14982514';

-- FC-14983153 | Prudence Grosella
update public.productos set nombre = 'Prudence Grosella', marca = 'Prudence', presentacion = '75 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Grosella' where sku = 'FC-14983153';

-- FC-14983726 | Prudence Natural Lubricante Natural
update public.productos set nombre = 'Prudence Natural Lubricante Natural', marca = 'Prudence', presentacion = '75 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Natural Lubricante Natural' where sku = 'FC-14983726';

-- FC-14985348 | Prudence Ull Sensitive Cond 'Ull Sensitive
update public.productos set nombre = 'Prudence Ull Sensitive Cond ''Ull Sensitive', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Ull Sensitive Cond ''Ull Sensitive' where sku = 'FC-14985348';

-- FC-14985805 | Prudence Chicle C/E Idkt Cond Chicle
update public.productos set nombre = 'Prudence Chicle C/E Idkt Cond Chicle', marca = 'Prudence', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Chicle C/E Idkt Cond Chicle' where sku = 'FC-14985805';

-- FC-16800803 | Diapro Confort Med
update public.productos set nombre = 'Diapro Confort Med', marca = 'Diapro', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', descripcion = 'Diapro Confort Med' where sku = 'FC-16800803';

-- FC-17360604 | Kotex Ant Flujo Abundante S/A 10Pz
update public.productos set nombre = 'Kotex Ant Flujo Abundante S/A 10Pz', marca = 'Kotex', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Kotex Ant Flujo Abundante S/A 10Pz' where sku = 'FC-17360604';

-- FC-17376CAE | Aspitak-P
update public.productos set nombre = 'Aspitak-P', marca = 'Aspitak-P', presentacion = '30 COMPRIMIDOS', concentracion = '100 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aspitak-P' where sku = 'FC-17376CAE';

-- FC-174824A0 | Vernisen
update public.productos set nombre = 'Vernisen', marca = 'Vernisen', presentacion = '6 TABLETAS', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Vernisen' where sku = 'FC-174824A0';

-- FC-1751468C | Flospet
update public.productos set nombre = 'Flospet', marca = 'Flospet', presentacion = '8 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Flospet' where sku = 'FC-1751468C';

-- FC-1812D26D | Hucius Capsulas
update public.productos set nombre = 'Hucius Capsulas', marca = 'Hucius', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', descripcion = 'Hucius Capsulas' where sku = 'FC-1812D26D';

-- FC-19006371 | Saba Inv Alas
update public.productos set nombre = 'Saba Inv Alas', marca = 'Saba', presentacion = 'C/10', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Saba Inv Alas' where sku = 'FC-19006371';

-- FC-19006623 | Saba Buenas Noches
update public.productos set nombre = 'Saba Buenas Noches', marca = 'Saba', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Saba Buenas Noches' where sku = 'FC-19006623';

-- FC-1AE9D7E6 | Collucort
update public.productos set nombre = 'Collucort', marca = 'Collucort', presentacion = '1 CREMA', concentracion = '1% 60 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', descripcion = 'Collucort' where sku = 'FC-1AE9D7E6';

-- FC-1BF03D35 | Acetonido De Fluocinolona Cma
update public.productos set nombre = 'Acetonido De Fluocinolona Cma', marca = 'Acetonido', categoria = 'Producto', tipo = 'marca', descripcion = 'Acetonido De Fluocinolona Cma' where sku = 'FC-1BF03D35';

-- FC-1CF27DC9 | Dex
update public.productos set nombre = 'Dex', marca = 'Dison', presentacion = '1 FRASCO AMPULA', concentracion = '5/2 MG', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Dex' where sku = 'FC-1CF27DC9';

-- FC-1DA570E3 | Cloxan
update public.productos set nombre = 'Cloxan', marca = 'Cloxan', presentacion = '20 COMPRIMIDOS', concentracion = '30 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cloxan' where sku = 'FC-1DA570E3';

-- FC-1DAD5EF1 | Tusilen Ad 1 Ibe 240/30/50Mg/100
update public.productos set nombre = 'Tusilen Ad 1 Ibe 240/30/50Mg/100', marca = 'Tusilen', presentacion = '118 ML', categoria = 'Producto', tipo = 'marca', descripcion = 'Tusilen Ad 1 Ibe 240/30/50Mg/100' where sku = 'FC-1DAD5EF1';

-- FC-1FBF5206 | Del Viejito Reomatolum
update public.productos set nombre = 'Del Viejito Reomatolum', marca = 'Del Viejito', presentacion = '60 G', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Del Viejito Reomatolum' where sku = 'FC-1FBF5206';

-- FC-1FEA2FB7 | Amikacina
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', descripcion = 'Amikacina' where sku = 'FC-1FEA2FB7';

-- FC-1FFBB505 | Dac
update public.productos set nombre = 'Dac', marca = 'Supratex', presentacion = '1 SOLUCION', concentracion = '300/600 MG 120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', descripcion = 'Dac' where sku = 'FC-1FFBB505';

-- FC-2001A890 | Ad
update public.productos set nombre = 'Ad', marca = 'Ampigrin', presentacion = '3 AMPOLLETA', concentracion = '500/500/100/30MG/3 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Ad' where sku = 'FC-2001A890';

-- FC-2005DD57 | Cefalexina
update public.productos set nombre = 'Cefalexina', presentacion = '20 CAPSULAS', principio_activo = 'CEFALEXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Cefalexina' where sku = 'FC-2005DD57';

-- FC-20500171 | Pert Oliv+Ac Agu P/Pein
update public.productos set nombre = 'Pert Oliv+Ac Agu P/Pein', marca = 'Pert', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Pert Oliv+Ac Agu P/Pein' where sku = 'FC-20500171';

-- FC-20500201 | Pert Plus Ac-Oliva
update public.productos set nombre = 'Pert Plus Ac-Oliva', marca = 'Pert', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pert Plus Ac-Oliva' where sku = 'FC-20500201';

-- FC-20501673 | Hinds Liq Agave Azul
update public.productos set nombre = 'Hinds Liq Agave Azul', marca = 'Hinds', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Hinds Liq Agave Azul' where sku = 'FC-20501673';

-- FC-20501765 | Grisi Aloe Vera P/Manos
update public.productos set nombre = 'Grisi Aloe Vera P/Manos', marca = 'Grisi', presentacion = '80 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Grisi Aloe Vera P/Manos' where sku = 'FC-20501765';

-- FC-21012303 | Claris Desmaq Aloe
update public.productos set nombre = 'Claris Desmaq Aloe', marca = 'Claris', presentacion = 'C/40', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', descripcion = 'Claris Desmaq Aloe' where sku = 'FC-21012303';

-- FC-21042481 | Manzanilla Ml Hnos 31.40 Hnos
update public.productos set nombre = 'Manzanilla Ml Hnos 31.40 Hnos', marca = 'Manzanilla', categoria = 'Producto', tipo = 'marca', descripcion = 'Manzanilla Ml Hnos 31.40 Hnos' where sku = 'FC-21042481';

-- FC-22105207 | Grisi Neutro
update public.productos set nombre = 'Grisi Neutro', marca = 'Grisi', presentacion = '150 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Grisi Neutro' where sku = 'FC-22105207';

-- FC-22111352 | Grisi Corp Diabecare
update public.productos set nombre = 'Grisi Corp Diabecare', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Grisi Corp Diabecare' where sku = 'FC-22111352';

-- FC-22133286 | Grisi Rici Oro Miel
update public.productos set nombre = 'Grisi Rici Oro Miel', marca = 'Grisi', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Grisi Rici Oro Miel' where sku = 'FC-22133286';

-- FC-22150092 | Grisi Leche De Burra
update public.productos set nombre = 'Grisi Leche De Burra', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Grisi Leche De Burra' where sku = 'FC-22150092';

-- FC-22150221 | Ricitos de Oro Neutro
update public.productos set nombre = 'Ricitos de Oro Neutro', marca = 'Ricitos de Oro', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ricitos de Oro Neutro' where sku = 'FC-22150221';

-- FC-22150801 | Grisi Avena
update public.productos set nombre = 'Grisi Avena', marca = 'Grisi', presentacion = '125 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Grisi Avena' where sku = 'FC-22150801';

-- FC-22B18244 | I.M
update public.productos set nombre = 'I.M', marca = 'Cefotaxima', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/4 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'I.M' where sku = 'FC-22B18244';

-- FC-23001331 | Sr I Ting
update public.productos set nombre = 'Sr I Ting', marca = 'Sr', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', descripcion = 'Sr I Ting' where sku = 'FC-23001331';

-- FC-23272151 | Jeringa insulina 0.3 ml
update public.productos set nombre = 'Jeringa insulina 0.3 ml', marca = 'Jayor', presentacion = 'C/100', forma_farmaceutica = 'Jeringa', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Jeringa insulina 0.3 ml' where sku = 'FC-23272151';

-- FC-23273451 | Jeringa insulina 0.5 ml
update public.productos set nombre = 'Jeringa insulina 0.5 ml', marca = 'Jayor', presentacion = 'C/100', forma_farmaceutica = 'Jeringa', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Jeringa insulina 0.5 ml' where sku = 'FC-23273451';

-- FC-24004581 | Ajolotius Pastillas Elderberry Past
update public.productos set nombre = 'Ajolotius Pastillas Elderberry Past', marca = 'Ajolotius', categoria = 'Producto', tipo = 'marca', descripcion = 'Ajolotius Pastillas Elderberry Past' where sku = 'FC-24004581';

-- FC-24227339 | Loxcel adulto
update public.productos set nombre = 'Loxcel adulto', marca = 'Loxcel', presentacion = 'C/1', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Loxcel adulto' where sku = 'FC-24227339';

-- FC-24511629 | Silica Shine uva
update public.productos set nombre = 'Silica Shine uva', marca = 'Silica Shine', presentacion = '120 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Silica Shine uva' where sku = 'FC-24511629';

-- FC-24511636 | Silica Shine Sily 3/1 Naran
update public.productos set nombre = 'Silica Shine Sily 3/1 Naran', marca = 'Silica Shine', presentacion = '12 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Silica Shine Sily 3/1 Naran' where sku = 'FC-24511636';

-- FC-24511711 | Silica Shine Sily 3/1 Mora
update public.productos set nombre = 'Silica Shine Sily 3/1 Mora', marca = 'Silica Shine', presentacion = '120 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Silica Shine Sily 3/1 Mora' where sku = 'FC-24511711';

-- FC-25104268 | Electrolit Fresa
update public.productos set nombre = 'Electrolit Fresa', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Electrolit Fresa' where sku = 'FC-25104268';

-- FC-25104411 | Electrolit Coco
update public.productos set nombre = 'Electrolit Coco', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Electrolit Coco' where sku = 'FC-25104411';

-- FC-25116810 | Agrifen Ab Pis
update public.productos set nombre = 'Agrifen Ab Pis', marca = 'Agrifen', presentacion = 'TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Agrifen Ab Pis' where sku = 'FC-25116810';

-- FC-25149221 | Electrolit Eresa-Kiwi
update public.productos set nombre = 'Electrolit Eresa-Kiwi', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Electrolit Eresa-Kiwi' where sku = 'FC-25149221';

-- FC-25605514 | Escudo Antibact
update public.productos set nombre = 'Escudo Antibact', marca = 'Escudo', presentacion = '110 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Escudo Antibact' where sku = 'FC-25605514';

-- FC-25652716 | Escudo Azul Rey
update public.productos set nombre = 'Escudo Azul Rey', marca = 'Escudo', presentacion = '135 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Escudo Azul Rey' where sku = 'FC-25652716';

-- FC-25E452B6 | Mercurio Arnica Untar 1790823 83156
update public.productos set nombre = 'Mercurio Arnica Untar 1790823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Arnica Untar 1790823 83156' where sku = 'FC-25E452B6';

-- FC-262F2A30 | Irbesartan
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '150 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Irbesartan' where sku = 'FC-262F2A30';

-- FC-26462061 | Ternura Ortodontic Miel C3
update public.productos set nombre = 'Ternura Ortodontic Miel C3', marca = 'Ternura', forma_farmaceutica = 'Chupón', categoria = 'Bebés', tipo = 'marca', descripcion = 'Ternura Ortodontic Miel C3' where sku = 'FC-26462061';

-- FC-26462078 | Chupón con miel
update public.productos set nombre = 'Chupón con miel', marca = 'Ternura', presentacion = '18 PZAS', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Chupón con miel' where sku = 'FC-26462078';

-- FC-26EA40A4 | Ramcinet
update public.productos set nombre = 'Ramcinet', marca = 'Ramcinet', presentacion = '10 TABLETAS', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Ramcinet' where sku = 'FC-26EA40A4';

-- FC-27250612 | Obao P/Del
update public.productos set nombre = 'Obao P/Del', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao P/Del' where sku = 'FC-27250612';

-- FC-27286017 | Obao Clas
update public.productos set nombre = 'Obao Clas', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao Clas' where sku = 'FC-27286017';

-- FC-27512574 | Evenflo Colors
update public.productos set nombre = 'Evenflo Colors', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', descripcion = 'Evenflo Colors' where sku = 'FC-27512574';

-- FC-281E0F22 | Budesonida
update public.productos set nombre = 'Budesonida', marca = 'Budesonida', presentacion = '1 SUSPENSION', concentracion = 'NEB AMP 0.500MG', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Budesonida' where sku = 'FC-281E0F22';

-- FC-28979502 | Ne
update public.productos set nombre = 'Ne', marca = 'Histiacil', presentacion = 'JARABE', concentracion = 'ADTO 150 MI OPELLA JAR ADTO 150 MI OPELLA', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Ne' where sku = 'FC-28979502';

-- FC-28A424E5 | Diziver
update public.productos set nombre = 'Diziver', marca = 'Diziver', presentacion = '20 TABLETAS', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Diziver' where sku = 'FC-28A424E5';

-- FC-29003221 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Vaso recolector', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-29003221';

-- FC-29670370 | Degortzin
update public.productos set nombre = 'Degortzin', marca = 'Degortzin', presentacion = '1 SOLUCION', concentracion = '100 MG/50 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', descripcion = 'Degortzin' where sku = 'FC-29670370';

-- FC-2E5B7248 | Reumatol
update public.productos set nombre = 'Reumatol', marca = 'Del Viejito', presentacion = '60 G', forma_farmaceutica = 'Pomada', categoria = 'Producto', tipo = 'marca', descripcion = 'Reumatol' where sku = 'FC-2E5B7248';

-- FC-2E79C2D8 | Dex
update public.productos set nombre = 'Dex', marca = 'Hierro', presentacion = '3 AMPOLLETA', concentracion = '100 MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Dex' where sku = 'FC-2E79C2D8';

-- FC-2EDC6E3B | Cefagen
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFALEXINA', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefagen' where sku = 'FC-2EDC6E3B';

-- FC-30133021 | Iri
update public.productos set nombre = 'Iri', marca = 'Iri', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Iri' where sku = 'FC-30133021';

-- FC-30622622 | Axe Men Young
update public.productos set nombre = 'Axe Men Young', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Men Young' where sku = 'FC-30622622';

-- FC-31244486 | Lubriderm P/Normal
update public.productos set nombre = 'Lubriderm P/Normal', marca = 'Lubriderm', presentacion = '120 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Lubriderm P/Normal' where sku = 'FC-31244486';

-- FC-31887928 | Listerine Care Zero Mta
update public.productos set nombre = 'Listerine Care Zero Mta', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', descripcion = 'Listerine Care Zero Mta' where sku = 'FC-31887928';

-- FC-31976394 | Listerine Anticari-Al
update public.productos set nombre = 'Listerine Anticari-Al', marca = 'Listerine', presentacion = '250 ML', forma_farmaceutica = 'Enjuague bucal', categoria = 'Higiene', tipo = 'marca', descripcion = 'Listerine Anticari-Al' where sku = 'FC-31976394';

-- FC-33950063 | Basuye Liq Fsa
update public.productos set nombre = 'Basuye Liq Fsa', marca = 'Basuye', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Basuye Liq Fsa' where sku = 'FC-33950063';

-- FC-33950070 | Ensure Liq Vnlla
update public.productos set nombre = 'Ensure Liq Vnlla', marca = 'Ensure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Ensure Liq Vnlla' where sku = 'FC-33950070';

-- FC-33950100 | Lio Chte
update public.productos set nombre = 'Lio Chte', marca = 'Lio', presentacion = '236 ML', categoria = 'Producto', tipo = 'marca', descripcion = 'Lio Chte' where sku = 'FC-33950100';

-- FC-33950209 | Pediasure Liq Vnlla
update public.productos set nombre = 'Pediasure Liq Vnlla', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Pediasure Liq Vnlla' where sku = 'FC-33950209';

-- FC-33951008 | Pediasure Liq Chte
update public.productos set nombre = 'Pediasure Liq Chte', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Pediasure Liq Chte' where sku = 'FC-33951008';

-- FC-33954245 | Pediasure Liq Fsa
update public.productos set nombre = 'Pediasure Liq Fsa', marca = 'Pediasure', presentacion = '236 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Pediasure Liq Fsa' where sku = 'FC-33954245';

-- FC-33954740 | Pedialyte
update public.productos set nombre = 'Pedialyte', marca = 'Pedialyte', presentacion = '500 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pedialyte' where sku = 'FC-33954740';

-- FC-33956133 | Lucerna Liq
update public.productos set nombre = 'Lucerna Liq', marca = 'Lucerna', presentacion = '237 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Lucerna Liq' where sku = 'FC-33956133';

-- FC-33956140 | Glucerna Sr Liq Fresa
update public.productos set nombre = 'Glucerna Sr Liq Fresa', marca = 'Glucerna', presentacion = '237 ML', forma_farmaceutica = 'Líquido', categoria = 'Suplemento', tipo = 'marca', descripcion = 'Glucerna Sr Liq Fresa' where sku = 'FC-33956140';

-- FC-33956775 | Pedialyte Sr60 Uva
update public.productos set nombre = 'Pedialyte Sr60 Uva', marca = 'Pedialyte', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pedialyte Sr60 Uva' where sku = 'FC-33956775';

-- FC-33961373 | Pedialyte fresa
update public.productos set nombre = 'Pedialyte fresa', marca = 'Pedialyte', presentacion = '500 ML', categoria = 'Otro', tipo = 'marca', descripcion = 'Pedialyte fresa' where sku = 'FC-33961373';

-- FC-34062421 | Tela adhesiva
update public.productos set nombre = 'Tela adhesiva', marca = 'Quirmex', presentacion = '1.25 CM x 1 M', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tela adhesiva' where sku = 'FC-34062421';

-- FC-34063651 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Tela adhesiva', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-34063651';

-- FC-34064021 | Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1
update public.productos set nombre = 'Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1', marca = 'Quirmex', presentacion = 'C/100', forma_farmaceutica = 'Cotonetes', categoria = 'Higiene', tipo = 'marca', descripcion = 'Quirmex Tarro 1 2 12.00 Cotonetes Tarro 1' where sku = 'FC-34064021';

-- FC-34067301 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '5 CM', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-34067301';

-- FC-34067471 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-34067471';

-- FC-34067781 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', presentacion = '30 CM', forma_farmaceutica = 'Venda', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-34067781';

-- FC-34067851 | Quirmex
update public.productos set nombre = 'Quirmex', marca = 'Quirmex', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Quirmex' where sku = 'FC-34067851';

-- FC-347A49C7 | Amikacina
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '100 MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', descripcion = 'Amikacina' where sku = 'FC-347A49C7';

-- FC-35020008 | Herbal Essences Limp Renoy
update public.productos set nombre = 'Herbal Essences Limp Renoy', marca = 'Herbal Essences', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Herbal Essences Limp Renoy' where sku = 'FC-35020008';

-- FC-35020077 | Herbal Essences Alivio Instant
update public.productos set nombre = 'Herbal Essences Alivio Instant', marca = 'Herbal Essences', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Herbal Essences Alivio Instant' where sku = 'FC-35020077';

-- FC-35155847 | Pantene Bambu Ctrl Caida
update public.productos set nombre = 'Pantene Bambu Ctrl Caida', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pantene Bambu Ctrl Caida' where sku = 'FC-35155847';

-- FC-35155922 | Pantene Bambu
update public.productos set nombre = 'Pantene Bambu', marca = 'Pantene', presentacion = '400 ML', forma_farmaceutica = 'Acondicionador', categoria = 'Higiene', tipo = 'marca', descripcion = 'Pantene Bambu' where sku = 'FC-35155922';

-- FC-35168991 | Hask Anti Comezon
update public.productos set nombre = 'Hask Anti Comezon', marca = 'Hask', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Hask Anti Comezon' where sku = 'FC-35168991';

-- FC-35169035 | Herbal Essences Rizo
update public.productos set nombre = 'Herbal Essences Rizo', marca = 'Herbal Essences', presentacion = '200 G', forma_farmaceutica = 'Mousse capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Herbal Essences Rizo' where sku = 'FC-35169035';

-- FC-35231237 | Hask Anti Comezon
update public.productos set nombre = 'Hask Anti Comezon', marca = 'Hask', presentacion = '375 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Hask Anti Comezon' where sku = 'FC-35231237';

-- FC-35231244 | Head & Shoulders Anti Comezon
update public.productos set nombre = 'Head & Shoulders Anti Comezon', marca = 'Head & Shoulders', presentacion = '180 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Head & Shoulders Anti Comezon' where sku = 'FC-35231244';

-- FC-35246309 | Vick Drops Tengibre Pastillas Drops Tengibre
update public.productos set nombre = 'Vick Drops Tengibre Pastillas Drops Tengibre', marca = 'Vick', presentacion = 'C/20', forma_farmaceutica = 'Balsamo', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Vick Drops Tengibre Pastillas Drops Tengibre' where sku = 'FC-35246309';

-- FC-35469151 | Lubriderm Uv Fps15
update public.productos set nombre = 'Lubriderm Uv Fps15', marca = 'Lubriderm', presentacion = '120 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Lubriderm Uv Fps15' where sku = 'FC-35469151';

-- FC-357D4A17 | Ceftazidima
update public.productos set nombre = 'Ceftazidima', marca = 'Ceftazidima', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Ceftazidima' where sku = 'FC-357D4A17';

-- FC-35908130 | Mennen Azul
update public.productos set nombre = 'Mennen Azul', marca = 'Mennen', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Azul' where sku = 'FC-35908130';

-- FC-35908147 | Mennen Rosa
update public.productos set nombre = 'Mennen Rosa', marca = 'Mennen', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Rosa' where sku = 'FC-35908147';

-- FC-35911208 | Palmolive Aquarium
update public.productos set nombre = 'Palmolive Aquarium', marca = 'Palmolive', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', descripcion = 'Palmolive Aquarium' where sku = 'FC-35911208';

-- FC-36032776 | Ricitos de Oro Oro Biopure
update public.productos set nombre = 'Ricitos de Oro Oro Biopure', marca = 'Ricitos de Oro', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ricitos de Oro Oro Biopure' where sku = 'FC-36032776';

-- FC-36033735 | Ricitos de Oro Oro Agua De Coco
update public.productos set nombre = 'Ricitos de Oro Oro Agua De Coco', marca = 'Ricitos de Oro', presentacion = '250 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ricitos de Oro Oro Agua De Coco' where sku = 'FC-36033735';

-- FC-36040450 | Grisi Conchnac P/Manos
update public.productos set nombre = 'Grisi Conchnac P/Manos', marca = 'Grisi', presentacion = '80 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Grisi Conchnac P/Manos' where sku = 'FC-36040450';

-- FC-36041402 | Hinds Hidr-Extr Almendras
update public.productos set nombre = 'Hinds Hidr-Extr Almendras', marca = 'Hinds', presentacion = '500 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Hinds Hidr-Extr Almendras' where sku = 'FC-36041402';

-- FC-3676D5DC | Mercurio Espiritus Tomar 1760823
update public.productos set nombre = 'Mercurio Espiritus Tomar 1760823', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Espiritus Tomar 1760823' where sku = 'FC-3676D5DC';

-- FC-369D1689 | Beneventol
update public.productos set nombre = 'Beneventol', presentacion = '6 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Beneventol' where sku = 'FC-369D1689';

-- FC-38312374 | Moco de Gorila Gel Citr
update public.productos set nombre = 'Moco de Gorila Gel Citr', marca = 'Moco de Gorila', presentacion = '100 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Moco de Gorila Gel Citr' where sku = 'FC-38312374';

-- FC-38891190 | Dove Barra Blanca
update public.productos set nombre = 'Dove Barra Blanca', marca = 'Dove', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Dove Barra Blanca' where sku = 'FC-38891190';

-- FC-38CAFE6B | Mercurio Aceite Romero 1910923
update public.productos set nombre = 'Mercurio Aceite Romero 1910923', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Aceite Romero 1910923' where sku = 'FC-38CAFE6B';

-- FC-39036C88 | Mercurio Glicerina 1230723 83125
update public.productos set nombre = 'Mercurio Glicerina 1230723 83125', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Glicerina 1230723 83125' where sku = 'FC-39036C88';

-- FC-3A4583F3 | Penipot
update public.productos set nombre = 'Penipot', marca = 'Penipot', presentacion = '1 FRASCO AMPULA', concentracion = '400,000 UI', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Penipot' where sku = 'FC-3A4583F3';

-- FC-3B001F9B | Amlodipino
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '30 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Amlodipino' where sku = 'FC-3B001F9B';

-- FC-3CAA7C5C | Cinarizina
update public.productos set nombre = 'Cinarizina', presentacion = '60 TABLETAS', principio_activo = 'CINARIZINA', concentracion = '75 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Cinarizina' where sku = 'FC-3CAA7C5C';

-- FC-3D0ED22B | Zukedib
update public.productos set nombre = 'Zukedib', marca = 'Zukedib', presentacion = '30 TABLETAS', concentracion = '4 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Zukedib' where sku = 'FC-3D0ED22B';

-- FC-3D0F54B7 | Ibupro-Cafe
update public.productos set nombre = 'Ibupro-Cafe', marca = 'Ibupro-Cafe', presentacion = '10 CAPSULAS', concentracion = '400 MG/100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Ibupro-Cafe' where sku = 'FC-3D0F54B7';

-- FC-3E863E37 | Tratidri
update public.productos set nombre = 'Tratidri', marca = 'Tratidri', presentacion = '1 GEL', concentracion = '500/50 MG 60 G', forma_farmaceutica = 'GEL', categoria = 'Otro', tipo = 'marca', descripcion = 'Tratidri' where sku = 'FC-3E863E37';

-- FC-40004643 | Asepxia Exfol
update public.productos set nombre = 'Asepxia Exfol', marca = 'Asepxia', presentacion = '100 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Asepxia Exfol' where sku = 'FC-40004643';

-- FC-40013898 | Teatrical Lanol/Ros
update public.productos set nombre = 'Teatrical Lanol/Ros', marca = 'Teatrical', presentacion = '52 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Teatrical Lanol/Ros' where sku = 'FC-40013898';

-- FC-40025839 | Lomecan V
update public.productos set nombre = 'Lomecan V', marca = 'Lomecan', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lomecan V' where sku = 'FC-40025839';

-- FC-40030338 | Lomecan V Aclar
update public.productos set nombre = 'Lomecan V Aclar', marca = 'Lomecan', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lomecan V Aclar' where sku = 'FC-40030338';

-- FC-40030963 | Teatrical Cel-Ma Nutrit
update public.productos set nombre = 'Teatrical Cel-Ma Nutrit', marca = 'Teatrical', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Teatrical Cel-Ma Nutrit' where sku = 'FC-40030963';

-- FC-40036965 | Asepxia Bicarbon Sod
update public.productos set nombre = 'Asepxia Bicarbon Sod', marca = 'Asepxia', presentacion = '100 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Asepxia Bicarbon Sod' where sku = 'FC-40036965';

-- FC-40171550 | Sensodyne rápido alivio
update public.productos set nombre = 'Sensodyne rápido alivio', marca = 'Sensodyne', presentacion = '100 G', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Sensodyne rápido alivio' where sku = 'FC-40171550';

-- FC-405A75E3 | Ursodesoxicolico
update public.productos set nombre = 'Ursodesoxicolico', marca = 'Acido', presentacion = '50 CAPSULAS', concentracion = '250 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Ursodesoxicolico' where sku = 'FC-405A75E3';

-- FC-40CE757D | Cefalver
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '12 TABLETAS', concentracion = '1 G', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefalver' where sku = 'FC-40CE757D';

-- FC-41339950 | Claritromicina
update public.productos set nombre = 'Claritromicina', presentacion = '10 TABLETAS', principio_activo = 'CLARITROMICINA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Claritromicina' where sku = 'FC-41339950';

-- FC-41500096 | Tiraleche de cristal
update public.productos set nombre = 'Tiraleche de cristal', marca = 'Genérico', presentacion = '1 PZA', forma_farmaceutica = 'Tiraleche', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tiraleche de cristal' where sku = 'FC-41500096';

-- FC-42270027 | Nivea Cuidada Clar-Nat
update public.productos set nombre = 'Nivea Cuidada Clar-Nat', marca = 'Nivea', presentacion = '200 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea Cuidada Clar-Nat' where sku = 'FC-42270027';

-- FC-42326414 | Garnier De Rosas
update public.productos set nombre = 'Garnier De Rosas', marca = 'Garnier', presentacion = '400 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Garnier De Rosas' where sku = 'FC-42326414';

-- FC-42417644 | Nivea Cuidado Int P/Mano
update public.productos set nombre = 'Nivea Cuidado Int P/Mano', marca = 'Nivea', presentacion = '75 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea Cuidado Int P/Mano' where sku = 'FC-42417644';

-- FC-428A228F | Gimalxina
update public.productos set nombre = 'Gimalxina', presentacion = '12 CAPSULAS', principio_activo = 'GIMALXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Gimalxina' where sku = 'FC-428A228F';

-- FC-43427754 | Kotex Nat Flex Noct
update public.productos set nombre = 'Kotex Nat Flex Noct', marca = 'Kotex', presentacion = 'C/5', forma_farmaceutica = 'Toallas sanitarias', categoria = 'Higiene', tipo = 'marca', descripcion = 'Kotex Nat Flex Noct' where sku = 'FC-43427754';

-- FC-43454811 | Toallitas húmedas cuidado puro
update public.productos set nombre = 'Toallitas húmedas cuidado puro', marca = 'Huggies', presentacion = 'C/80', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', descripcion = 'Toallitas húmedas cuidado puro' where sku = 'FC-43454811';

-- FC-43471900 | Toallitas húmedas C/120
update public.productos set nombre = 'Toallitas húmedas C/120', marca = 'Absorsec', presentacion = 'C/120', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', descripcion = 'Toallitas húmedas C/120' where sku = 'FC-43471900';

-- FC-43489004 | Escudo Rosa Prot Y Cuid
update public.productos set nombre = 'Escudo Rosa Prot Y Cuid', marca = 'Escudo', presentacion = '110 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Escudo Rosa Prot Y Cuid' where sku = 'FC-43489004';

-- FC-43489165 | Escudo Blanco Neut
update public.productos set nombre = 'Escudo Blanco Neut', marca = 'Escudo', presentacion = '225 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', descripcion = 'Escudo Blanco Neut' where sku = 'FC-43489165';

-- FC-443C330E | Cefagen
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFALEXINA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefagen' where sku = 'FC-443C330E';

-- FC-447B30F9 | Budesonida
update public.productos set nombre = 'Budesonida', marca = 'Budesonida', presentacion = '5 AMPOLLETA', concentracion = '0.250MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Budesonida' where sku = 'FC-447B30F9';

-- FC-44B6751A | Aquito 500/100/30/4 Mg
update public.productos set nombre = 'Aquito 500/100/30/4 Mg', marca = 'Laur', presentacion = '3 AMPOLLETA', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Aquito 500/100/30/4 Mg' where sku = 'FC-44B6751A';

-- FC-45045281 | Labello Hydro-C
update public.productos set nombre = 'Labello Hydro-C', marca = 'Labello', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', descripcion = 'Labello Hydro-C' where sku = 'FC-45045281';

-- FC-45079011 | Labello
update public.productos set nombre = 'Labello', marca = 'Labello', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', descripcion = 'Labello' where sku = 'FC-45079011';

-- FC-45307181 | Arnica Bde Parche
update public.productos set nombre = 'Arnica Bde Parche', marca = 'Arnica', tipo = 'marca', descripcion = 'Arnica Bde Parche' where sku = 'FC-45307181';

-- FC-45720550 | Quitaesmalte mora azul
update public.productos set nombre = 'Quitaesmalte mora azul', marca = 'Silkhair', presentacion = '100 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Quitaesmalte mora azul' where sku = 'FC-45720550';

-- FC-45720567 | Quitaesmalte coco
update public.productos set nombre = 'Quitaesmalte coco', marca = 'Silkhair', presentacion = '100 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Quitaesmalte coco' where sku = 'FC-45720567';

-- FC-45722547 | Agua micelar bifásica
update public.productos set nombre = 'Agua micelar bifásica', marca = 'Natural-G', presentacion = '120 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Agua micelar bifásica' where sku = 'FC-45722547';

-- FC-46059556 | Palmolive N-Bal Dermol
update public.productos set nombre = 'Palmolive N-Bal Dermol', marca = 'Palmolive', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', descripcion = 'Palmolive N-Bal Dermol' where sku = 'FC-46059556';

-- FC-46072050 | Mennen Miel-Mza Sve
update public.productos set nombre = 'Mennen Miel-Mza Sve', marca = 'Mennen', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Miel-Mza Sve' where sku = 'FC-46072050';

-- FC-46073033 | Caprice Sp Acti Ceramida
update public.productos set nombre = 'Caprice Sp Acti Ceramida', marca = 'Caprice', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Caprice Sp Acti Ceramida' where sku = 'FC-46073033';

-- FC-46073040 | Caprice Sp Biotina Fza
update public.productos set nombre = 'Caprice Sp Biotina Fza', marca = 'Caprice', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Caprice Sp Biotina Fza' where sku = 'FC-46073040';

-- FC-46073156 | Caprice Nat Mzna
update public.productos set nombre = 'Caprice Nat Mzna', marca = 'Caprice', presentacion = '380 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Caprice Nat Mzna' where sku = 'FC-46073156';

-- FC-46074504 | Mennen Zero% Sve
update public.productos set nombre = 'Mennen Zero% Sve', marca = 'Mennen', presentacion = '400 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Zero% Sve' where sku = 'FC-46074504';

-- FC-46640629 | Venda de yeso 20 cm x 2.75 m
update public.productos set nombre = 'Venda de yeso 20 cm x 2.75 m', marca = 'Protec', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Venda de yeso 20 cm x 2.75 m' where sku = 'FC-46640629';

-- FC-46650708 | Mennen Lavan-Extrac Aven
update public.productos set nombre = 'Mennen Lavan-Extrac Aven', marca = 'Mennen', presentacion = '200 ML', forma_farmaceutica = 'Shampoo', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Lavan-Extrac Aven' where sku = 'FC-46650708';

-- FC-46655055 | Caprice Volum-Cirl
update public.productos set nombre = 'Caprice Volum-Cirl', marca = 'Caprice', presentacion = '200 G', forma_farmaceutica = 'Mousse capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Caprice Volum-Cirl' where sku = 'FC-46655055';

-- FC-46655079 | Palmolive N-Bal Corp Baby0%
update public.productos set nombre = 'Palmolive N-Bal Corp Baby0%', marca = 'Palmolive', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Palmolive N-Bal Corp Baby0%' where sku = 'FC-46655079';

-- FC-46655727 | Mennen Baby Magic Lavan
update public.productos set nombre = 'Mennen Baby Magic Lavan', marca = 'Mennen', presentacion = '90 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mennen Baby Magic Lavan' where sku = 'FC-46655727';

-- FC-46657035 | Lio Flor Czo-Rsa
update public.productos set nombre = 'Lio Flor Czo-Rsa', marca = 'Lio', presentacion = '221 ML', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lio Flor Czo-Rsa' where sku = 'FC-46657035';

-- FC-46683133 | Palmolive N-Bal Dermo Limp
update public.productos set nombre = 'Palmolive N-Bal Dermo Limp', marca = 'Palmolive', presentacion = '120 G', forma_farmaceutica = 'Jabón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Palmolive N-Bal Dermo Limp' where sku = 'FC-46683133';

-- FC-47624171 | Nailex Desenterrador Unas Desenterrador Unas
update public.productos set nombre = 'Nailex Desenterrador Unas Desenterrador Unas', marca = 'Nailex', presentacion = '12 ML', tipo = 'marca', descripcion = 'Nailex Desenterrador Unas Desenterrador Unas' where sku = 'FC-47624171';

-- FC-47640531 | Recuperador una uña amarilla
update public.productos set nombre = 'Recuperador una uña amarilla', marca = 'Pisa', presentacion = '15 ML', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Recuperador una uña amarilla' where sku = 'FC-47640531';

-- FC-47AAF23B | Mercurio Sulfatiazol Polvo 1710824
update public.productos set nombre = 'Mercurio Sulfatiazol Polvo 1710824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Sulfatiazol Polvo 1710824' where sku = 'FC-47AAF23B';

-- FC-48335305 | Degasa 15.00 Agua Oxigenada
update public.productos set nombre = 'Degasa 15.00 Agua Oxigenada', marca = 'Degasa', presentacion = '480 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Degasa 15.00 Agua Oxigenada' where sku = 'FC-48335305';

-- FC-48623006 | Protec Pads Facial Redondos C/100
update public.productos set nombre = 'Protec Pads Facial Redondos C/100', marca = 'Protec', presentacion = 'C/100', forma_farmaceutica = 'Pads', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Protec Pads Facial Redondos C/100' where sku = 'FC-48623006';

-- FC-48640751 | Venda de yeso 5 cm x 2.75 m C/12
update public.productos set nombre = 'Venda de yeso 5 cm x 2.75 m C/12', marca = 'Protec', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Venda de yeso 5 cm x 2.75 m C/12' where sku = 'FC-48640751';

-- FC-48640775 | Venda de yeso 10 cm x 2.75 m C/12
update public.productos set nombre = 'Venda de yeso 10 cm x 2.75 m C/12', marca = 'Protec', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Venda de yeso 10 cm x 2.75 m C/12' where sku = 'FC-48640775';

-- FC-48640799 | Venda de yeso 15 cm x 2.75 m C/12
update public.productos set nombre = 'Venda de yeso 15 cm x 2.75 m C/12', marca = 'Protec', presentacion = '1 PZA', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Venda de yeso 15 cm x 2.75 m C/12' where sku = 'FC-48640799';

-- FC-48690800 | Tensolastic Plus venda elástica 5 cm x 5 m
update public.productos set nombre = 'Tensolastic Plus venda elástica 5 cm x 5 m', marca = 'Protec', presentacion = '5 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tensolastic Plus venda elástica 5 cm x 5 m' where sku = 'FC-48690800';

-- FC-48690909 | Tensolastic Plus venda elástica 7 cm x 5 m
update public.productos set nombre = 'Tensolastic Plus venda elástica 7 cm x 5 m', marca = 'Protec', presentacion = '7 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tensolastic Plus venda elástica 7 cm x 5 m' where sku = 'FC-48690909';

-- FC-48691005 | Tensolastic Plus venda elástica 10 cm x 5 m
update public.productos set nombre = 'Tensolastic Plus venda elástica 10 cm x 5 m', marca = 'Protec', presentacion = '10 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tensolastic Plus venda elástica 10 cm x 5 m' where sku = 'FC-48691005';

-- FC-48691104 | Tensolastic Plus venda elástica 15 cm x 5 m
update public.productos set nombre = 'Tensolastic Plus venda elástica 15 cm x 5 m', marca = 'Protec', presentacion = '15 CM x 5 M', forma_farmaceutica = 'Material de curación', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tensolastic Plus venda elástica 15 cm x 5 m' where sku = 'FC-48691104';

-- FC-48F732CF | Epicin
update public.productos set nombre = 'Epicin', marca = 'Epicin', presentacion = '20 CAPSULAS', principio_activo = 'ERITROMICINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Epicin' where sku = 'FC-48F732CF';

-- FC-492D652F | Cefalver
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefalver' where sku = 'FC-492D652F';

-- FC-49800151 | Prudence Clasico C/3
update public.productos set nombre = 'Prudence Clasico C/3', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Clasico C/3' where sku = 'FC-49800151';

-- FC-49824391 | Prudence 'Ull Retardante C/3
update public.productos set nombre = 'Prudence ''Ull Retardante C/3', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', descripcion = 'Prudence ''Ull Retardante C/3' where sku = 'FC-49824391';

-- FC-49824771 | Prudence Fresa
update public.productos set nombre = 'Prudence Fresa', marca = 'Prudence', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', descripcion = 'Prudence Fresa' where sku = 'FC-49824771';

-- FC-49824911 | Prudence Iva Dki Mexico S Cond Iva Mexico
update public.productos set nombre = 'Prudence Iva Dki Mexico S Cond Iva Mexico', marca = 'Prudence', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Prudence Iva Dki Mexico S Cond Iva Mexico' where sku = 'FC-49824911';

-- FC-49853867 | Softlub Extra Cond Extra
update public.productos set nombre = 'Softlub Extra Cond Extra', marca = 'Softlub', presentacion = 'C/3', forma_farmaceutica = 'Condón', categoria = 'Higiene', tipo = 'marca', descripcion = 'Softlub Extra Cond Extra' where sku = 'FC-49853867';

-- FC-4A0245DA | Amlodipino
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '100 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Amlodipino' where sku = 'FC-4A0245DA';

-- FC-4BD80686 | Beneventol
update public.productos set nombre = 'Beneventol', presentacion = '3 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Beneventol' where sku = 'FC-4BD80686';

-- FC-4C621D07 | Vanmoxol
update public.productos set nombre = 'Vanmoxol', presentacion = '1 SUSPENSION', principio_activo = 'VANMOXOL', concentracion = '250/15MG/5/90 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', descripcion = 'Vanmoxol' where sku = 'FC-4C621D07';

-- FC-4F05124E | Gelcavit-9M Capsulas
update public.productos set nombre = 'Gelcavit-9M Capsulas', marca = 'Gelcavit-9M', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', descripcion = 'Gelcavit-9M Capsulas' where sku = 'FC-4F05124E';

-- FC-4F737E93 | Cloxan
update public.productos set nombre = 'Cloxan', marca = 'Cloxan', presentacion = '1 SOLUCION', concentracion = '300MG/120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', descripcion = 'Cloxan' where sku = 'FC-4F737E93';

-- FC-4FD413D2 | Haspen
update public.productos set nombre = 'Haspen', marca = 'Haspen', presentacion = '3 AMPOLLETA', concentracion = '20 MG/1 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Haspen' where sku = 'FC-4FD413D2';

-- FC-50002301 | Eomelubrina
update public.productos set nombre = 'Eomelubrina', marca = 'Eomelubrina', presentacion = 'C/10', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Eomelubrina' where sku = 'FC-50002301';

-- FC-50003151 | Opella Neomelubrina Jbe I 121.00 Neomelubrina Jbe I
update public.productos set nombre = 'Opella Neomelubrina Jbe I 121.00 Neomelubrina Jbe I', marca = 'Opella', presentacion = '100 ML', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', descripcion = 'Opella Neomelubrina Jbe I 121.00 Neomelubrina Jbe I' where sku = 'FC-50003151';

-- FC-50587FA6 | Mexapin
update public.productos set nombre = 'Mexapin', marca = 'Mexapin', presentacion = '1 SUSPENSION', concentracion = '125MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Mexapin' where sku = 'FC-50587FA6';

-- FC-50882017 | Dermodine Espuma 120 Mi
update public.productos set nombre = 'Dermodine Espuma 120 Mi', marca = 'Dermodine', forma_farmaceutica = 'Espuma', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dermodine Espuma 120 Mi' where sku = 'FC-50882017';

-- FC-50959781 | Centrum C/30
update public.productos set nombre = 'Centrum C/30', marca = 'Centrum', presentacion = 'C/30', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Centrum C/30' where sku = 'FC-50959781';

-- FC-50AC2C82 | Erispan
update public.productos set nombre = 'Erispan', marca = 'Erispan', presentacion = '1 FRASCO AMPULA', concentracion = '8MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Erispan' where sku = 'FC-50AC2C82';

-- FC-50D044FF | Wermy
update public.productos set nombre = 'Wermy', marca = 'Wermy', presentacion = '15 CAPSULAS', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Wermy' where sku = 'FC-50D044FF';

-- FC-51067711 | Nido
update public.productos set nombre = 'Nido', marca = 'Nido', categoria = 'Producto', tipo = 'marca', descripcion = 'Nido' where sku = 'FC-51067711';

-- FC-51078461 | Nan 1 Pro 1
update public.productos set nombre = 'Nan 1 Pro 1', marca = 'Nan', tipo = 'marca', descripcion = 'Nan 1 Pro 1' where sku = 'FC-51078461';

-- FC-51078531 | Nan Nestle Bolsa Nestle Bolsa
update public.productos set nombre = 'Nan Nestle Bolsa Nestle Bolsa', marca = 'Nan', presentacion = '2 G', tipo = 'marca', descripcion = 'Nan Nestle Bolsa Nestle Bolsa' where sku = 'FC-51078531';

-- FC-51444145 | Old Spice
update public.productos set nombre = 'Old Spice', marca = 'Old Spice', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Old Spice' where sku = 'FC-51444145';

-- FC-51448511 | Electrolit Uva
update public.productos set nombre = 'Electrolit Uva', marca = 'Electrolit', presentacion = '525 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Electrolit Uva' where sku = 'FC-51448511';

-- FC-516C2E89 | 12H Jr
update public.productos set nombre = '12H Jr', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '400/57MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = '12H Jr' where sku = 'FC-516C2E89';

-- FC-51747971 | Electrolit Mora Azul
update public.productos set nombre = 'Electrolit Mora Azul', marca = 'Electrolit', presentacion = '625 ML', forma_farmaceutica = 'Suero oral', categoria = 'Higiene', tipo = 'marca', descripcion = 'Electrolit Mora Azul' where sku = 'FC-51747971';

-- FC-52400038 | Ajolotius Menta Eucal S/Azucar Past Menta Eucal
update public.productos set nombre = 'Ajolotius Menta Eucal S/Azucar Past Menta Eucal', marca = 'Ajolotius', tipo = 'marca', descripcion = 'Ajolotius Menta Eucal S/Azucar Past Menta Eucal' where sku = 'FC-52400038';

-- FC-52400212 | Ajolotius Jengibre Tab Nati Jengibre
update public.productos set nombre = 'Ajolotius Jengibre Tab Nati Jengibre', marca = 'Ajolotius', presentacion = 'C/10', tipo = 'marca', descripcion = 'Ajolotius Jengibre Tab Nati Jengibre' where sku = 'FC-52400212';

-- FC-52400267 | Ajolotius
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Ajolotius' where sku = 'FC-52400267';

-- FC-52816297 | Fructis Pei Oil-R L-Coco
update public.productos set nombre = 'Fructis Pei Oil-R L-Coco', marca = 'Fructis', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Fructis Pei Oil-R L-Coco' where sku = 'FC-52816297';

-- FC-52844825 | Obao R-Nat Coco
update public.productos set nombre = 'Obao R-Nat Coco', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao R-Nat Coco' where sku = 'FC-52844825';

-- FC-52876406 | Obao Men Tatto Aqua
update public.productos set nombre = 'Obao Men Tatto Aqua', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao Men Tatto Aqua' where sku = 'FC-52876406';

-- FC-52910971 | Fructis Pei B-Dano Quim
update public.productos set nombre = 'Fructis Pei B-Dano Quim', marca = 'Fructis', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Fructis Pei B-Dano Quim' where sku = 'FC-52910971';

-- FC-52933307 | Obao Game 48Hr N
update public.productos set nombre = 'Obao Game 48Hr N', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao Game 48Hr N' where sku = 'FC-52933307';

-- FC-52D2A43A | Zukedib
update public.productos set nombre = 'Zukedib', marca = 'Zukedib', presentacion = '30 TABLETAS', concentracion = '2 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Zukedib' where sku = 'FC-52D2A43A';

-- FC-53506FA4 | Enalapril
update public.productos set nombre = 'Enalapril', presentacion = '30 TABLETAS', principio_activo = 'ENALAPRIL', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Enalapril' where sku = 'FC-53506FA4';

-- FC-54073302 | Silica Shine Sily Oleo Argan
update public.productos set nombre = 'Silica Shine Sily Oleo Argan', marca = 'Silica Shine', presentacion = '120 ML', forma_farmaceutica = 'Tratamiento capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Silica Shine Sily Oleo Argan' where sku = 'FC-54073302';

-- FC-54500216 | Nivea Sdatarr Giga
update public.productos set nombre = 'Nivea Sdatarr Giga', marca = 'Nivea', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea Sdatarr Giga' where sku = 'FC-54500216';

-- FC-54503095 | Nivea Sda Tarro
update public.productos set nombre = 'Nivea Sda Tarro', marca = 'Nivea', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nivea Sda Tarro' where sku = 'FC-54503095';

-- FC-54504870 | Lásico Pomada I.Abeili.C 56.50 56.50
update public.productos set nombre = 'Lásico Pomada I.Abeili.C 56.50 56.50', marca = 'Lásico', forma_farmaceutica = 'POMADA', categoria = 'Otro', tipo = 'marca', descripcion = 'Lásico Pomada I.Abeili.C 56.50 56.50' where sku = 'FC-54504870';

-- FC-54521161 | Tempra
update public.productos set nombre = 'Tempra', marca = 'Tempra', presentacion = '500 MG · C/10', forma_farmaceutica = 'UNGÜENTO', categoria = 'Otro', tipo = 'marca', descripcion = 'Tempra' where sku = 'FC-54521161';

-- FC-54549819 | Crema corporal piel seca
update public.productos set nombre = 'Crema corporal piel seca', marca = 'Nivea', presentacion = '100 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Crema corporal piel seca' where sku = 'FC-54549819';

-- FC-54558682 | Crema corporal Nivea Milk
update public.productos set nombre = 'Crema corporal Nivea Milk', marca = 'Nivea', presentacion = '400 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Crema corporal Nivea Milk' where sku = 'FC-54558682';

-- FC-55280956 | Obao Men Tato Rebel
update public.productos set nombre = 'Obao Men Tato Rebel', marca = 'Obao', presentacion = 'R-ON 65 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Obao Men Tato Rebel' where sku = 'FC-55280956';

-- FC-56034041 | Toallitas húmedas antibacterial
update public.productos set nombre = 'Toallitas húmedas antibacterial', marca = 'Escudo', presentacion = 'C/50', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', descripcion = 'Toallitas húmedas antibacterial' where sku = 'FC-56034041';

-- FC-56131681 | Evenflo
update public.productos set nombre = 'Evenflo', marca = 'Evenflo', presentacion = 'C/90', forma_farmaceutica = 'Pañuelos desechables', categoria = 'Higiene', tipo = 'marca', descripcion = 'Evenflo' where sku = 'FC-56131681';

-- FC-56323059 | Vaseline Puro
update public.productos set nombre = 'Vaseline Puro', marca = 'Vaseline', presentacion = '85 G', categoria = 'Producto', tipo = 'marca', descripcion = 'Vaseline Puro' where sku = 'FC-56323059';

-- FC-56323066 | FaseLine Puro
update public.productos set nombre = 'FaseLine Puro', marca = 'FaseLine', presentacion = '42 G', categoria = 'Producto', tipo = 'marca', descripcion = 'FaseLine Puro' where sku = 'FC-56323066';

-- FC-56326142 | Ponds S Humectante
update public.productos set nombre = 'Ponds S Humectante', marca = 'Ponds', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ponds S Humectante' where sku = 'FC-56326142';

-- FC-56330309 | Clariant B3 Nml/Gsa
update public.productos set nombre = 'Clariant B3 Nml/Gsa', marca = 'Clariant', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Clariant B3 Nml/Gsa' where sku = 'FC-56330309';

-- FC-56330378 | Ponds Bio-Hydra Dual
update public.productos set nombre = 'Ponds Bio-Hydra Dual', marca = 'Ponds', presentacion = '200 ML', forma_farmaceutica = 'Loción limpiadora', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ponds Bio-Hydra Dual' where sku = 'FC-56330378';

-- FC-56340025 | Sedal Sos Recon-Estru
update public.productos set nombre = 'Sedal Sos Recon-Estru', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Sos Recon-Estru' where sku = 'FC-56340025';

-- FC-56340124 | Sedal Sos Ceramida
update public.productos set nombre = 'Sedal Sos Ceramida', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Sos Ceramida' where sku = 'FC-56340124';

-- FC-56340131 | Sedal Rizos Obedie
update public.productos set nombre = 'Sedal Rizos Obedie', marca = 'Sedal', presentacion = '300 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Rizos Obedie' where sku = 'FC-56340131';

-- FC-56342227 | Sedal Rizos Obedientes
update public.productos set nombre = 'Sedal Rizos Obedientes', marca = 'Sedal', presentacion = '135 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Rizos Obedientes' where sku = 'FC-56342227';

-- FC-56342258 | Sedal Recons Estructur
update public.productos set nombre = 'Sedal Recons Estructur', marca = 'Sedal', presentacion = '135 ML', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Sedal Recons Estructur' where sku = 'FC-56342258';

-- FC-56360429 | Talco desodorante pies
update public.productos set nombre = 'Talco desodorante pies', marca = 'Genérico', presentacion = '200 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Talco desodorante pies' where sku = 'FC-56360429';

-- FC-578F060C | Mercurio Borax Polvo 140072483490
update public.productos set nombre = 'Mercurio Borax Polvo 140072483490', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Borax Polvo 140072483490' where sku = 'FC-578F060C';

-- FC-57925EF3 | Reglusan
update public.productos set nombre = 'Reglusan', marca = 'Reglusan', presentacion = '50 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Reglusan' where sku = 'FC-57925EF3';

-- FC-58203691 | Hilo dental expanding
update public.productos set nombre = 'Hilo dental expanding', marca = 'Gum', presentacion = '0.9 M', categoria = 'Higiene', tipo = 'marca', descripcion = 'Hilo dental expanding' where sku = 'FC-58203691';

-- FC-58611420 | Nido Nido Nestle Bolsa
update public.productos set nombre = 'Nido Nido Nestle Bolsa', marca = 'Nido', forma_farmaceutica = 'Leche', categoria = 'Abarrotes', tipo = 'marca', descripcion = 'Nido Nido Nestle Bolsa' where sku = 'FC-58611420';

-- FC-58792792 | Tempra
update public.productos set nombre = 'Tempra', marca = 'Tempra', presentacion = 'C/12', categoria = 'Producto', tipo = 'marca', descripcion = 'Tempra' where sku = 'FC-58792792';

-- FC-58793249 | Lubricante sensación calor
update public.productos set nombre = 'Lubricante sensación calor', marca = 'Sico', presentacion = '50 ML', forma_farmaceutica = 'Lubricante', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Lubricante sensación calor' where sku = 'FC-58793249';

-- FC-5885E577 | Pabesorag
update public.productos set nombre = 'Pabesorag', marca = 'Pabesorag', presentacion = '28 TABLETAS', concentracion = '150/12.5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Pabesorag' where sku = 'FC-5885E577';

-- FC-58DB24C4 | Bitenver
update public.productos set nombre = 'Bitenver', marca = 'Bitenver', presentacion = '30 TABLETAS', concentracion = '24 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Bitenver' where sku = 'FC-58DB24C4';

-- FC-59225411 | Nido
update public.productos set nombre = 'Nido', marca = 'Nido', categoria = 'Producto', tipo = 'marca', descripcion = 'Nido' where sku = 'FC-59225411';

-- FC-5A697CC2 | Mercurio Aceite Olivo 1000625 83825
update public.productos set nombre = 'Mercurio Aceite Olivo 1000625 83825', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Aceite Olivo 1000625 83825' where sku = 'FC-5A697CC2';

-- FC-5BC5F234 | Fluconazol
update public.productos set nombre = 'Fluconazol', presentacion = '1 CAPSULAS', principio_activo = 'FLUCONAZOL', concentracion = '150 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Fluconazol' where sku = 'FC-5BC5F234';

-- FC-5C8C9C11 | Gelubrin
update public.productos set nombre = 'Gelubrin', marca = 'Gelubrin', presentacion = '10 CAPSULAS', concentracion = '600 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Gelubrin' where sku = 'FC-5C8C9C11';

-- FC-5D59ED54 | Mercurio Cloruro De Magnesio Cajita
update public.productos set nombre = 'Mercurio Cloruro De Magnesio Cajita', marca = 'Mercurio', presentacion = 'C/10', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Cloruro De Magnesio Cajita' where sku = 'FC-5D59ED54';

-- FC-5D9DFA3D | Norquinol
update public.productos set nombre = 'Norquinol', presentacion = '20 TABLETAS', principio_activo = 'NORQUINOL', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Norquinol' where sku = 'FC-5D9DFA3D';

-- FC-5EF90195 | Mercurio Flor De Arnica 1430724
update public.productos set nombre = 'Mercurio Flor De Arnica 1430724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Flor De Arnica 1430724' where sku = 'FC-5EF90195';

-- FC-5F30F9D4 | Clamoxin
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Clamoxin' where sku = 'FC-5F30F9D4';

-- FC-60009851 | Colgate Triple Acc
update public.productos set nombre = 'Colgate Triple Acc', marca = 'Colgate', presentacion = '75 ML', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Colgate Triple Acc' where sku = 'FC-60009851';

-- FC-60101231 | Tempra ,
update public.productos set nombre = 'Tempra ,', marca = 'Tempra', presentacion = 'C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tempra ,' where sku = 'FC-60101231';

-- FC-60101378 | Lubricante íntimo
update public.productos set nombre = 'Lubricante íntimo', marca = 'Piel con Piel', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lubricante íntimo' where sku = 'FC-60101378';

-- FC-60101521 | Vitacilina
update public.productos set nombre = 'Vitacilina', marca = 'Vitacilina', presentacion = '56.7 G', forma_farmaceutica = 'LUBRICANTE', categoria = 'Producto', tipo = 'marca', descripcion = 'Vitacilina' where sku = 'FC-60101521';

-- FC-60403681 | Desenfriol
update public.productos set nombre = 'Desenfriol', marca = 'Desenfriol', presentacion = 'C/30', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Desenfriol' where sku = 'FC-60403681';

-- FC-60689091 | Colgate Trip Xtra
update public.productos set nombre = 'Colgate Trip Xtra', marca = 'Colgate', presentacion = '50 ML', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', descripcion = 'Colgate Trip Xtra' where sku = 'FC-60689091';

-- FC-6074BB64 | Redalip
update public.productos set nombre = 'Redalip', marca = 'Redalip', presentacion = '30 TABLETAS', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Redalip' where sku = 'FC-6074BB64';

-- FC-60F627D5 | Gentamicina
update public.productos set nombre = 'Gentamicina', presentacion = '5 AMPOLLETA', principio_activo = 'GENTAMICINA', concentracion = '160MG/2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'generico', descripcion = 'Gentamicina' where sku = 'FC-60F627D5';

-- FC-61111501 | Odolex Desdo
update public.productos set nombre = 'Odolex Desdo', marca = 'Odolex', presentacion = '150 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Odolex Desdo' where sku = 'FC-61111501';

-- FC-61113000 | Odolex Desod
update public.productos set nombre = 'Odolex Desod', marca = 'Odolex', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Odolex Desod' where sku = 'FC-61113000';

-- FC-61123009 | Odolex Naturals Talco Desodorante
update public.productos set nombre = 'Odolex Naturals Talco Desodorante', marca = 'Odolex', presentacion = '300 G', tipo = 'marca', descripcion = 'Odolex Naturals Talco Desodorante' where sku = 'FC-61123009';

-- FC-61124013 | Odolex Fresh
update public.productos set nombre = 'Odolex Fresh', marca = 'Odolex', presentacion = '150 G', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Odolex Fresh' where sku = 'FC-61124013';

-- FC-614E4F82 | Perilla N3
update public.productos set nombre = 'Perilla N3', marca = 'Edigar', presentacion = 'PIEZA', categoria = 'Botiquín', tipo = 'generico', descripcion = 'Perilla N3' where sku = 'FC-614E4F82';

-- FC-62034164 | Mercurio Espiritus Untar 1770823
update public.productos set nombre = 'Mercurio Espiritus Untar 1770823', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Espiritus Untar 1770823' where sku = 'FC-62034164';

-- FC-62746605 | Jarabe 250 Ml 1 Nat Ajolotius Bioal Imentos
update public.productos set nombre = 'Jarabe 250 Ml 1 Nat Ajolotius Bioal Imentos', marca = 'Jarabe', presentacion = 'JARABE', concentracion = '250 ML 1 AJOLOTIUS BIOAL IMENTOS', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Jarabe 250 Ml 1 Nat Ajolotius Bioal Imentos' where sku = 'FC-62746605';

-- FC-62746612 | Ajolotius
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', presentacion = 'JARABE', concentracion = 'S/AZUCAR 250 ML. I BIOALIMENTOS NATI', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Ajolotius' where sku = 'FC-62746612';

-- FC-62746643 | Ajolotius Menta Fucal Menta Fucal
update public.productos set nombre = 'Ajolotius Menta Fucal Menta Fucal', marca = 'Ajolotius', presentacion = 'C/10', tipo = 'marca', descripcion = 'Ajolotius Menta Fucal Menta Fucal' where sku = 'FC-62746643';

-- FC-62746698 | Ajolotius
update public.productos set nombre = 'Ajolotius', marca = 'Ajolotius', presentacion = 'JARABE', concentracion = 'REFORZADO 250 ML BIOALIMENTOS NAT: AJOLOTIUS JARABE REFORZADO', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Ajolotius' where sku = 'FC-62746698';

-- FC-63975795 | Gentamicina
update public.productos set nombre = 'Gentamicina', presentacion = '25 COMPRIMIDOS', principio_activo = 'GENTAMICINA', concentracion = '1 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'generico', descripcion = 'Gentamicina' where sku = 'FC-63975795';

-- FC-64EB83AA | Compl
update public.productos set nombre = 'Compl', marca = 'Bencil/Benz', presentacion = '1 FRASCO AMPULA', concentracion = '1,2 U 3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Compl' where sku = 'FC-64EB83AA';

-- FC-65054135 | Tubos surtidos
update public.productos set nombre = 'Tubos surtidos', marca = 'Genérico', forma_farmaceutica = 'Surtido', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Tubos surtidos' where sku = 'FC-65054135';

-- FC-65095718 | Centrum
update public.productos set nombre = 'Centrum', marca = 'Centrum', presentacion = 'C/30', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Centrum' where sku = 'FC-65095718';

-- FC-65095947 | Centrum Tab 1 Tab
update public.productos set nombre = 'Centrum Tab 1 Tab', marca = 'Centrum', presentacion = 'C/30', tipo = 'marca', descripcion = 'Centrum Tab 1 Tab' where sku = 'FC-65095947';

-- FC-6519183A | Clamoxin
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '125/31.25MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Clamoxin' where sku = 'FC-6519183A';

-- FC-66055303 | Meditest Prueba Embarazo
update public.productos set nombre = 'Meditest Prueba Embarazo', marca = 'Meditest', presentacion = 'C/1', categoria = 'Producto', tipo = 'marca', descripcion = 'Meditest Prueba Embarazo' where sku = 'FC-66055303';

-- FC-66534951 | Colgate Total
update public.productos set nombre = 'Colgate Total', marca = 'Colgate', presentacion = '1 tubo', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Colgate Total' where sku = 'FC-66534951';

-- FC-66873531 | Crema dental anticaries
update public.productos set nombre = 'Crema dental anticaries', marca = 'Genérico', forma_farmaceutica = 'Crema dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Crema dental anticaries' where sku = 'FC-66873531';

-- FC-66888171 | Colgate Max Clean
update public.productos set nombre = 'Colgate Max Clean', marca = 'Colgate', presentacion = '120 ML', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', descripcion = 'Colgate Max Clean' where sku = 'FC-66888171';

-- FC-67905131 | Blumen Cherry Bloss
update public.productos set nombre = 'Blumen Cherry Bloss', marca = 'Blumen', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', descripcion = 'Blumen Cherry Bloss' where sku = 'FC-67905131';

-- FC-67905186 | Blumen Coconut Para
update public.productos set nombre = 'Blumen Coconut Para', marca = 'Blumen', presentacion = '221 ML', forma_farmaceutica = 'Jabón líquido', categoria = 'Higiene', tipo = 'marca', descripcion = 'Blumen Coconut Para' where sku = 'FC-67905186';

-- FC-68900127 | Gasa 10 x 10
update public.productos set nombre = 'Gasa 10 x 10', marca = 'Dibar', presentacion = 'PAQ 10', forma_farmaceutica = 'Gasa', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Gasa 10 x 10' where sku = 'FC-68900127';

-- FC-68900134 | Gasa Lox10 C/100
update public.productos set nombre = 'Gasa Lox10 C/100', marca = 'Dibar', presentacion = 'C/100', categoria = 'Producto', tipo = 'marca', descripcion = 'Gasa Lox10 C/100' where sku = 'FC-68900134';

-- FC-68900226 | Dibar Rojo
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '250 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Rojo' where sku = 'FC-68900226';

-- FC-68900264 | Dibar Rojo
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '125 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Rojo' where sku = 'FC-68900264';

-- FC-68901117 | Dibar Azul
update public.productos set nombre = 'Dibar Azul', marca = 'Dibar', presentacion = '250 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Azul' where sku = 'FC-68901117';

-- FC-68901124 | Alcohol etílico
update public.productos set nombre = 'Alcohol etílico', marca = 'Genérico', presentacion = '500 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Alcohol etílico' where sku = 'FC-68901124';

-- FC-68901131 | Alcohol azul
update public.productos set nombre = 'Alcohol azul', marca = 'Genérico', presentacion = '1 L', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Alcohol azul' where sku = 'FC-68901131';

-- FC-68910034 | Dibar Gr Algodon Algodon
update public.productos set nombre = 'Dibar Gr Algodon Algodon', marca = 'Dibar', presentacion = '60 G', categoria = 'Producto', tipo = 'marca', descripcion = 'Dibar Gr Algodon Algodon' where sku = 'FC-68910034';

-- FC-68910041 | Algodón 5 g C/12
update public.productos set nombre = 'Algodón 5 g C/12', marca = 'Dibar', presentacion = '5 G', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Algodón 5 g C/12' where sku = 'FC-68910041';

-- FC-68960257 | Dibar Ilt Rojo
update public.productos set nombre = 'Dibar Ilt Rojo', marca = 'Dibar', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Ilt Rojo' where sku = 'FC-68960257';

-- FC-6898B64F | Bioerter
update public.productos set nombre = 'Bioerter', marca = 'Bioerter', presentacion = '1 SUSPENSION', concentracion = '250 MG/100 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Bioerter' where sku = 'FC-6898B64F';

-- FC-68990023 | Dibar Rojo
update public.productos set nombre = 'Dibar Rojo', marca = 'Dibar', presentacion = '500 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Rojo' where sku = 'FC-68990023';

-- FC-69387811 | Mercurio Aceite Gomenolado 1160623
update public.productos set nombre = 'Mercurio Aceite Gomenolado 1160623', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Aceite Gomenolado 1160623' where sku = 'FC-69387811';

-- FC-697EEAD0 | Kurtosil
update public.productos set nombre = 'Kurtosil', marca = 'Kurtosil', presentacion = '1 CREMA', concentracion = '20/1 MG', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', descripcion = 'Kurtosil' where sku = 'FC-697EEAD0';

-- FC-69A3C416 | Wexpec
update public.productos set nombre = 'Wexpec', marca = 'Wexpec', presentacion = '1 SOLUCION', concentracion = '7.5/2MG/5/120 ML', forma_farmaceutica = 'SOLUCION', categoria = 'Otro', tipo = 'marca', descripcion = 'Wexpec' where sku = 'FC-69A3C416';

-- FC-6B2ADEE9 | Protect aerosol 200 dosis
update public.productos set nombre = 'Protect aerosol 200 dosis', marca = 'Protect', presentacion = '12.80 G', tipo = 'marca', descripcion = 'Protect aerosol 200 dosis' where sku = 'FC-6B2ADEE9';

-- FC-6C2878CF | Susp 125 Mg/Ml
update public.productos set nombre = 'Susp 125 Mg/Ml', marca = 'Budenova', presentacion = '5 AMPOLLETA', concentracion = '2 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Susp 125 Mg/Ml' where sku = 'FC-6C2878CF';

-- FC-6EAD98A9 | Cepobrom
update public.productos set nombre = 'Cepobrom', marca = 'Cepobrom', presentacion = '12 CAPSULAS', principio_activo = 'CEFADROXIL', concentracion = '500/0.782 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cepobrom' where sku = 'FC-6EAD98A9';

-- FC-70612368 | Treda
update public.productos set nombre = 'Treda', marca = 'Treda', presentacion = 'C/20', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Treda' where sku = 'FC-70612368';

-- FC-72300171 | Ting polvo decolorante
update public.productos set nombre = 'Ting polvo decolorante', marca = 'Ting', presentacion = '85 G', forma_farmaceutica = 'Polvo', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ting polvo decolorante' where sku = 'FC-72300171';

-- FC-72629012 | Colgate Adulto Med 40 C12
update public.productos set nombre = 'Colgate Adulto Med 40 C12', marca = 'Colgate', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Colgate Adulto Med 40 C12' where sku = 'FC-72629012';

-- FC-72C28BC1 | Knoricin
update public.productos set nombre = 'Knoricin', marca = 'Knoricin', presentacion = '1 SUSPENSION', principio_activo = 'NITROFURANTOINA', concentracion = '125MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Knoricin' where sku = 'FC-72C28BC1';

-- FC-73629981 | Kleenex Panuelos Pack C/8 1
update public.productos set nombre = 'Kleenex Panuelos Pack C/8 1', marca = 'Kleenex', presentacion = 'C/8', forma_farmaceutica = 'Pañuelos desechables', categoria = 'Higiene', tipo = 'marca', descripcion = 'Kleenex Panuelos Pack C/8 1' where sku = 'FC-73629981';

-- FC-74A5ABEE | Ciprofloxacino
update public.productos set nombre = 'Ciprofloxacino', presentacion = '12 TABLETAS', principio_activo = 'CIPROFLOXACINO', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Ciprofloxacino' where sku = 'FC-74A5ABEE';

-- FC-75001865 | Lio 115M
update public.productos set nombre = 'Lio 115M', marca = 'Lio', forma_farmaceutica = 'Brillantine', categoria = 'Higiene', tipo = 'marca', descripcion = 'Lio 115M' where sku = 'FC-75001865';

-- FC-75062897 | Rexona Bamboo 48H
update public.productos set nombre = 'Rexona Bamboo 48H', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Bamboo 48H' where sku = 'FC-75062897';

-- FC-75062927 | Rexona Pom-Dry 48 H
update public.productos set nombre = 'Rexona Pom-Dry 48 H', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Pom-Dry 48 H' where sku = 'FC-75062927';

-- FC-75064938 | Ego Force 24H R-On Dic26
update public.productos set nombre = 'Ego Force 24H R-On Dic26', marca = 'Ego', presentacion = '45 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ego Force 24H R-On Dic26' where sku = 'FC-75064938';

-- FC-75069223 | Rexona Mot-Sen Sport Stick
update public.productos set nombre = 'Rexona Mot-Sen Sport Stick', marca = 'Rexona', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Mot-Sen Sport Stick' where sku = 'FC-75069223';

-- FC-75076009 | Rexona 48H Happy-M
update public.productos set nombre = 'Rexona 48H Happy-M', marca = 'Rexona', presentacion = 'STICK 45 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona 48H Happy-M' where sku = 'FC-75076009';

-- FC-75125811 | Evenflo Colors
update public.productos set nombre = 'Evenflo Colors', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', descripcion = 'Evenflo Colors' where sku = 'FC-75125811';

-- FC-75163051 | Evenflo Ensueno Azul
update public.productos set nombre = 'Evenflo Ensueno Azul', marca = 'Evenflo', forma_farmaceutica = 'Biberón', categoria = 'Bebés', tipo = 'marca', descripcion = 'Evenflo Ensueno Azul' where sku = 'FC-75163051';

-- FC-75354321 | Tylenol
update public.productos set nombre = 'Tylenol', marca = 'Tylenol', presentacion = 'TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tylenol' where sku = 'FC-75354321';

-- FC-759A5EF9 | Wermy
update public.productos set nombre = 'Wermy', marca = 'Wermy', presentacion = '30 CAPSULAS', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Wermy' where sku = 'FC-759A5EF9';

-- FC-76000253 | Vitacilina Roja Antiarrugas
update public.productos set nombre = 'Vitacilina Roja Antiarrugas', marca = 'Vitacilina', presentacion = '100 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Vitacilina Roja Antiarrugas' where sku = 'FC-76000253';

-- FC-76000260 | Vitacilina Amarilla Aclaradora
update public.productos set nombre = 'Vitacilina Amarilla Aclaradora', marca = 'Vitacilina', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Vitacilina Amarilla Aclaradora' where sku = 'FC-76000260';

-- FC-76000277 | Vitacilina Cre Humectante Humectante
update public.productos set nombre = 'Vitacilina Cre Humectante Humectante', marca = 'Vitacilina', presentacion = '100 G', tipo = 'marca', descripcion = 'Vitacilina Cre Humectante Humectante' where sku = 'FC-76000277';

-- FC-76000284 | Vitacilina Ros-Sab
update public.productos set nombre = 'Vitacilina Ros-Sab', marca = 'Vitacilina', presentacion = '500 ML', forma_farmaceutica = 'Agua micelar', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Vitacilina Ros-Sab' where sku = 'FC-76000284';

-- FC-76040436 | Mexsana P/Pies
update public.productos set nombre = 'Mexsana P/Pies', marca = 'Mexsana', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Mexsana P/Pies' where sku = 'FC-76040436';

-- FC-76040610 | Desenfriol ito
update public.productos set nombre = 'Desenfriol ito', marca = 'Desenfriol', presentacion = '2 PACK · C/24', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Desenfriol ito' where sku = 'FC-76040610';

-- FC-77620056 | La Flor Agua Destilada
update public.productos set nombre = 'La Flor Agua Destilada', marca = 'La Flor', presentacion = '1 L', forma_farmaceutica = 'Agua destilada', categoria = 'Botiquín', tipo = 'marca', descripcion = 'La Flor Agua Destilada' where sku = 'FC-77620056';

-- FC-77FE5C83 | S
update public.productos set nombre = 'S', marca = 'Sonblefam', presentacion = '1 CREMA', concentracion = '100 G/40 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', descripcion = 'S' where sku = 'FC-77FE5C83';

-- FC-79071241 | Bisolvon
update public.productos set nombre = 'Bisolvon', marca = 'Bisolvon', presentacion = '120 ML', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Bisolvon' where sku = 'FC-79071241';

-- FC-79400556 | Sanfer Syncol
update public.productos set nombre = 'Sanfer Syncol', marca = 'Sanfer', presentacion = '871210734092301 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Sanfer Syncol' where sku = 'FC-79400556';

-- FC-7AA38F97 | Pentiver
update public.productos set nombre = 'Pentiver', marca = 'Pentiver', presentacion = '1 SUSPENSION', concentracion = '500MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Pentiver' where sku = 'FC-7AA38F97';

-- FC-7AF7ACB5 | Charlyn
update public.productos set nombre = 'Charlyn', marca = 'Charlyn', presentacion = '3 TABLETAS', principio_activo = 'CIPROFLOXACINO', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Charlyn' where sku = 'FC-7AF7ACB5';

-- FC-7D1D9857 | Acetilsalicilico
update public.productos set nombre = 'Acetilsalicilico', marca = 'Acido', presentacion = '30 TABLETAS', concentracion = '100MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Acetilsalicilico' where sku = 'FC-7D1D9857';

-- FC-7F90064A | Ampicilina
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '500MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', descripcion = 'Ampicilina' where sku = 'FC-7F90064A';

-- FC-80950139 | Lásico enzimático
update public.productos set nombre = 'Lásico enzimático', marca = 'Lásico', categoria = 'Producto', tipo = 'marca', descripcion = 'Lásico enzimático' where sku = 'FC-80950139';

-- FC-80953017 | Trojan
update public.productos set nombre = 'Trojan', marca = 'Trojan', presentacion = 'C/3', categoria = 'Producto', tipo = 'marca', descripcion = 'Trojan' where sku = 'FC-80953017';

-- FC-82176351 | Neurobion Sot.O- Dc Ete Jga Sot.O- Prell Health9.20
update public.productos set nombre = 'Neurobion Sot.O- Dc Ete Jga Sot.O- Prell Health9.20', marca = 'Neurobion', presentacion = 'C/1', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', descripcion = 'Neurobion Sot.O- Dc Ete Jga Sot.O- Prell Health9.20' where sku = 'FC-82176351';

-- FC-82740011 | Nuvel Humec
update public.productos set nombre = 'Nuvel Humec', marca = 'Nuvel', presentacion = '125 ML', forma_farmaceutica = 'Quita esmalte', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nuvel Humec' where sku = 'FC-82740011';

-- FC-82790016 | Nuvel Pura Para Bebe200 G
update public.productos set nombre = 'Nuvel Pura Para Bebe200 G', marca = 'Nuvel', forma_farmaceutica = 'Talco', categoria = 'Higiene', tipo = 'marca', descripcion = 'Nuvel Pura Para Bebe200 G' where sku = 'FC-82790016';

-- FC-82790504 | Nuvel Bifasico Oil
update public.productos set nombre = 'Nuvel Bifasico Oil', marca = 'Nuvel', presentacion = '125 ML', forma_farmaceutica = 'Desmaquillante', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nuvel Bifasico Oil' where sku = 'FC-82790504';

-- FC-82F88FED | Captopril
update public.productos set nombre = 'Captopril', presentacion = '30 TABLETAS', principio_activo = 'CAPTOPRIL', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Captopril' where sku = 'FC-82F88FED';

-- FC-830BF3FB | Diviltac
update public.productos set nombre = 'Diviltac', marca = 'Diviltac', presentacion = '1 FRASCO AMPULA', concentracion = '150/10MG/1 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Diviltac' where sku = 'FC-830BF3FB';

-- FC-83351381 | Agua oxigenada
update public.productos set nombre = 'Agua oxigenada', marca = 'Dermocleen', presentacion = '100 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Agua oxigenada' where sku = 'FC-83351381';

-- FC-83351691 | Degasa Agua Oxigenada
update public.productos set nombre = 'Degasa Agua Oxigenada', marca = 'Degasa', presentacion = '230 ML', forma_farmaceutica = 'Agua oxigenada', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Degasa Agua Oxigenada' where sku = 'FC-83351691';

-- FC-83510531 | Protec Antibacterial 22.40 Antibacterial
update public.productos set nombre = 'Protec Antibacterial 22.40 Antibacterial', marca = 'Protec', presentacion = '250 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Protec Antibacterial 22.40 Antibacterial' where sku = 'FC-83510531';

-- FC-84095411 | Saridon
update public.productos set nombre = 'Saridon', marca = 'Saridon', presentacion = '120 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Saridon' where sku = 'FC-84095411';

-- FC-84335531 | Aspirina Forte C/24 Caf Iaspirina
update public.productos set nombre = 'Aspirina Forte C/24 Caf Iaspirina', marca = 'Aspirina', presentacion = 'C/24', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aspirina Forte C/24 Caf Iaspirina' where sku = 'FC-84335531';

-- FC-84431050 | Jaloma
update public.productos set nombre = 'Jaloma', marca = 'Jaloma', presentacion = '60 ML', forma_farmaceutica = 'Acetona', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Jaloma' where sku = 'FC-84431050';

-- FC-84437151 | Jaloma
update public.productos set nombre = 'Jaloma', marca = 'Jaloma', presentacion = '120 ML', forma_farmaceutica = 'Acetona', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Jaloma' where sku = 'FC-84437151';

-- FC-84900280 | Jaloma Spray
update public.productos set nombre = 'Jaloma Spray', marca = 'Jaloma', presentacion = '130 ML', forma_farmaceutica = 'Agua de rosas', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Jaloma Spray' where sku = 'FC-84900280';

-- FC-84973401 | Flanax
update public.productos set nombre = 'Flanax', marca = 'Flanax', presentacion = '00 TABLETAS · C/12', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Flanax' where sku = 'FC-84973401';

-- FC-84999001 | Alka-Seltzer
update public.productos set nombre = 'Alka-Seltzer', marca = 'Alka-Seltzer', presentacion = 'C/50', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Alka-Seltzer' where sku = 'FC-84999001';

-- FC-85097661 | Chinoin Jr. Jbe Ine 60 Mant Jr. Jbe Mant
update public.productos set nombre = 'Chinoin Jr. Jbe Ine 60 Mant Jr. Jbe Mant', marca = 'Chinoin', tipo = 'marca', descripcion = 'Chinoin Jr. Jbe Ine 60 Mant Jr. Jbe Mant' where sku = 'FC-85097661';

-- FC-85103015 | Huggies Super Toallitas Humedas
update public.productos set nombre = 'Huggies Super Toallitas Humedas', marca = 'Huggies', presentacion = '4 PZA', tipo = 'marca', descripcion = 'Huggies Super Toallitas Humedas' where sku = 'FC-85103015';

-- FC-85592111 | Scabisan
update public.productos set nombre = 'Scabisan', marca = 'Scabisan', forma_farmaceutica = 'CREMA', categoria = 'Producto', tipo = 'marca', descripcion = 'Scabisan' where sku = 'FC-85592111';

-- FC-85800198 | Huggies Super
update public.productos set nombre = 'Huggies Super', marca = 'Huggies', presentacion = 'C/80', forma_farmaceutica = 'Toallas húmedas', categoria = 'Higiene', tipo = 'marca', descripcion = 'Huggies Super' where sku = 'FC-85800198';

-- FC-85BDBD3D | Acroxil-C
update public.productos set nombre = 'Acroxil-C', marca = 'Acroxil-C', presentacion = '1 SUSPENSION', concentracion = '250MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Acroxil-C' where sku = 'FC-85BDBD3D';

-- FC-86167151 | Nestum Probioticos Avena 270 Probioticos
update public.productos set nombre = 'Nestum Probioticos Avena 270 Probioticos', marca = 'Nestum', forma_farmaceutica = 'Suplemento', categoria = 'Abarrotes', tipo = 'marca', descripcion = 'Nestum Probioticos Avena 270 Probioticos' where sku = 'FC-86167151';

-- FC-86472048 | Alcanforada Mayo Somed
update public.productos set nombre = 'Alcanforada Mayo Somed', marca = 'Alcanforada', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Alcanforada Mayo Somed' where sku = 'FC-86472048';

-- FC-86494262 | Oral-B Indicat35Sve
update public.productos set nombre = 'Oral-B Indicat35Sve', marca = 'Oral-B', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Oral-B Indicat35Sve' where sku = 'FC-86494262';

-- FC-86708021 | Protec Sigital Termometro 42.10 Sigital Termometro
update public.productos set nombre = 'Protec Sigital Termometro 42.10 Sigital Termometro', marca = 'Protec', categoria = 'Producto', tipo = 'marca', descripcion = 'Protec Sigital Termometro 42.10 Sigital Termometro' where sku = 'FC-86708021';

-- FC-86901100 | Dibar Azul
update public.productos set nombre = 'Dibar Azul', marca = 'Dibar', presentacion = '125 ML', forma_farmaceutica = 'Alcohol', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Dibar Azul' where sku = 'FC-86901100';

-- FC-86A95D07 | Tropharma
update public.productos set nombre = 'Tropharma', marca = 'Tropharma', presentacion = '20 TABLETAS', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tropharma' where sku = 'FC-86A95D07';

-- FC-87154871 | Graneodin
update public.productos set nombre = 'Graneodin', marca = 'Graneodin', presentacion = 'C/16', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Graneodin' where sku = 'FC-87154871';

-- FC-87932321 | Microdacyn Lubricante Ico Cereza 50 Ml 1 Ico Cereza 50
update public.productos set nombre = 'Microdacyn Lubricante Ico Cereza 50 Ml 1 Ico Cereza 50', marca = 'Microdacyn', presentacion = '50 ML', forma_farmaceutica = 'Lubricante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Microdacyn Lubricante Ico Cereza 50 Ml 1 Ico Cereza 50' where sku = 'FC-87932321';

-- FC-88508929 | Anara
update public.productos set nombre = 'Anara', marca = 'Anara', presentacion = 'C/20', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Anara' where sku = 'FC-88508929';

-- FC-885F2723 | Carbamazepina
update public.productos set nombre = 'Carbamazepina', presentacion = '20 TABLETAS', principio_activo = 'CARBAMAZEPINA', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Carbamazepina' where sku = 'FC-885F2723';

-- FC-88915491 | Tarmin 2 Mg /12
update public.productos set nombre = 'Tarmin 2 Mg /12', marca = 'Tarmin', presentacion = '12 TABLETAS', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tarmin 2 Mg /12' where sku = 'FC-88915491';

-- FC-88923551 | Cilocid Iv
update public.productos set nombre = 'Cilocid Iv', marca = 'Cilocid', presentacion = 'C/20', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cilocid Iv' where sku = 'FC-88923551';

-- FC-88947797 | Tribedoce
update public.productos set nombre = 'Tribedoce', marca = 'Tribedoce', presentacion = 'C/30', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Tribedoce' where sku = 'FC-88947797';

-- FC-89100101 | Algodón 200 g
update public.productos set nombre = 'Algodón 200 g', marca = 'Dibak', presentacion = '200 G', forma_farmaceutica = 'Algodón', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Algodón 200 g' where sku = 'FC-89100101';

-- FC-89794961 | Ne
update public.productos set nombre = 'Ne', marca = 'Histiacil', presentacion = 'JARABE', concentracion = 'INE 150 ML OPELLA 1 G 123.28 JAR INE 150 ML OPELLA G 123.28', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Ne' where sku = 'FC-89794961';

-- FC-89810021 | Armstrong Herklin Ne Sham 60 Ml
update public.productos set nombre = 'Armstrong Herklin Ne Sham 60 Ml', marca = 'Armstrong', presentacion = '60 ML', forma_farmaceutica = 'SHAMPOO', categoria = 'Producto', tipo = 'marca', descripcion = 'Armstrong Herklin Ne Sham 60 Ml' where sku = 'FC-89810021';

-- FC-89F00320 | Mercurio Arnica 2550123
update public.productos set nombre = 'Mercurio Arnica 2550123', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Arnica 2550123' where sku = 'FC-89F00320';

-- FC-8FB65B79 | Klarix
update public.productos set nombre = 'Klarix', marca = 'Klarix', presentacion = '1 SUSPENSION', principio_activo = 'CLARITROMICINA', concentracion = '250MG/5 ML 60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Klarix' where sku = 'FC-8FB65B79';

-- FC-92503558 | Ego Magnetic Fij-Alta
update public.productos set nombre = 'Ego Magnetic Fij-Alta', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ego Magnetic Fij-Alta' where sku = 'FC-92503558';

-- FC-92504539 | Ego Mod Met
update public.productos set nombre = 'Ego Mod Met', marca = 'Ego', presentacion = '25 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ego Mod Met' where sku = 'FC-92504539';

-- FC-92506045 | Ego Firme Matte
update public.productos set nombre = 'Ego Firme Matte', marca = 'Ego', presentacion = '25 G', forma_farmaceutica = 'Cera capilar', categoria = 'Higiene', tipo = 'marca', descripcion = 'Ego Firme Matte' where sku = 'FC-92506045';

-- FC-92506601 | Ego For Men Attraction
update public.productos set nombre = 'Ego For Men Attraction', marca = 'Ego', presentacion = '200 ML', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Ego For Men Attraction' where sku = 'FC-92506601';

-- FC-92509213 | Nutribela Nutrice Tarro
update public.productos set nombre = 'Nutribela Nutrice Tarro', marca = 'Nutribela', presentacion = '300 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nutribela Nutrice Tarro' where sku = 'FC-92509213';

-- FC-92511261 | Nutribela Bio Colageno
update public.productos set nombre = 'Nutribela Bio Colageno', marca = 'Nutribela', presentacion = '300 G', forma_farmaceutica = 'Crema', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Nutribela Bio Colageno' where sku = 'FC-92511261';

-- FC-926099D3 | Mertiolate Kohn Rojo 012023 82912
update public.productos set nombre = 'Mertiolate Kohn Rojo 012023 82912', marca = 'Mertiolate', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mertiolate Kohn Rojo 012023 82912' where sku = 'FC-926099D3';

-- FC-92821171 | Nido Nido Nestle Bolsa Nestle
update public.productos set nombre = 'Nido Nido Nestle Bolsa Nestle', marca = 'Nido', presentacion = '240 G', forma_farmaceutica = 'Leche', categoria = 'Abarrotes', tipo = 'marca', descripcion = 'Nido Nido Nestle Bolsa Nestle' where sku = 'FC-92821171';

-- FC-93022567 | Rexona Men V8 Tun Spy
update public.productos set nombre = 'Rexona Men V8 Tun Spy', marca = 'Rexona', presentacion = '90 G', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Men V8 Tun Spy' where sku = 'FC-93022567';

-- FC-93025797 | Axe Men Dark Temp
update public.productos set nombre = 'Axe Men Dark Temp', marca = 'Axe', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Men Dark Temp' where sku = 'FC-93025797';

-- FC-93025865 | Axe Men Gold Temp
update public.productos set nombre = 'Axe Men Gold Temp', marca = 'Axe', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Men Gold Temp' where sku = 'FC-93025865';

-- FC-93025919 | Axe Excite Seco
update public.productos set nombre = 'Axe Excite Seco', marca = 'Axe', presentacion = 'SPRAY 152 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Axe Excite Seco' where sku = 'FC-93025919';

-- FC-93037806 | Rexona Men Marine
update public.productos set nombre = 'Rexona Men Marine', marca = 'Rexona', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Men Marine' where sku = 'FC-93037806';

-- FC-93038223 | Rexona Men Sport
update public.productos set nombre = 'Rexona Men Sport', marca = 'Rexona', presentacion = 'SPRAY 150 ML', forma_farmaceutica = 'Desodorante', categoria = 'Higiene', tipo = 'marca', descripcion = 'Rexona Men Sport' where sku = 'FC-93038223';

-- FC-930E0B1B | Vandil
update public.productos set nombre = 'Vandil', marca = 'Vandil', presentacion = '1 SUSPENSION', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Vandil' where sku = 'FC-930E0B1B';

-- FC-931B4809 | Mercurio Aceite Coco 800523 83064
update public.productos set nombre = 'Mercurio Aceite Coco 800523 83064', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Aceite Coco 800523 83064' where sku = 'FC-931B4809';

-- FC-9507CD66 | Mercurio Haba Alcanforada 1510724
update public.productos set nombre = 'Mercurio Haba Alcanforada 1510724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Haba Alcanforada 1510724' where sku = 'FC-9507CD66';

-- FC-95129166 | Oral-B 3Dw Advant Med2X1
update public.productos set nombre = 'Oral-B 3Dw Advant Med2X1', marca = 'Oral-B', forma_farmaceutica = 'Cepillo dental', categoria = 'Higiene', tipo = 'marca', descripcion = 'Oral-B 3Dw Advant Med2X1' where sku = 'FC-95129166';

-- FC-95201021 | Hipoglos Turo
update public.productos set nombre = 'Hipoglos Turo', marca = 'Hipoglos', presentacion = '45 G', categoria = 'Producto', tipo = 'marca', descripcion = 'Hipoglos Turo' where sku = 'FC-95201021';

-- FC-9538F7D6 | Fasiclor
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Fasiclor' where sku = 'FC-9538F7D6';

-- FC-95451096 | Sal de uvas
update public.productos set nombre = 'Sal de uvas', marca = 'Sal de Uvas', presentacion = 'C/10', categoria = 'Otro', tipo = 'generico', descripcion = 'Sal de uvas' where sku = 'FC-95451096';

-- FC-95467264 | Sal de Uvas Ixh C/50
update public.productos set nombre = 'Sal de Uvas Ixh C/50', marca = 'Sal de Uvas', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Sal de Uvas Ixh C/50' where sku = 'FC-95467264';

-- FC-95779436 | Acetilsalicilico Ef
update public.productos set nombre = 'Acetilsalicilico Ef', marca = 'Acido', presentacion = '20 TABLETAS', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Acetilsalicilico Ef' where sku = 'FC-95779436';

-- FC-974EE5FD | Gimalxina
update public.productos set nombre = 'Gimalxina', presentacion = '1 SUSPENSION', principio_activo = 'GIMALXINA', concentracion = '250MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', descripcion = 'Gimalxina' where sku = 'FC-974EE5FD';

-- FC-97BEFA1A | Amlodipino
update public.productos set nombre = 'Amlodipino', marca = 'Amlodipino', presentacion = '100 TABLETAS', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Amlodipino' where sku = 'FC-97BEFA1A';

-- FC-98100381 | Shampoo Herklin
update public.productos set nombre = 'Shampoo Herklin', marca = 'Herklin', presentacion = '20 ML', categoria = 'Higiene', tipo = 'marca', descripcion = 'Shampoo Herklin' where sku = 'FC-98100381';

-- FC-98217659 | Dolo-Neurobión
update public.productos set nombre = 'Dolo-Neurobión', marca = 'Neurobion', presentacion = 'C/3 · 3 ML', forma_farmaceutica = 'Inyectable', categoria = 'Otro', tipo = 'marca', descripcion = 'Dolo-Neurobión' where sku = 'FC-98217659';

-- FC-98223704 | Eurobion Bolo Tab
update public.productos set nombre = 'Eurobion Bolo Tab', marca = 'Eurobion', presentacion = 'C/20', forma_farmaceutica = 'Tabletas', categoria = 'Otro', tipo = 'marca', descripcion = 'Eurobion Bolo Tab' where sku = 'FC-98223704';

-- FC-9827438F | Mercurio Veneno De Abeja
update public.productos set nombre = 'Mercurio Veneno De Abeja', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Veneno De Abeja' where sku = 'FC-9827438F';

-- FC-99425580 | X-Treme Titan
update public.productos set nombre = 'X-Treme Titan', marca = 'X-Treme', presentacion = '250 G', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'X-Treme Titan' where sku = 'FC-99425580';

-- FC-99428024 | Moco de Gorila Punk
update public.productos set nombre = 'Moco de Gorila Punk', marca = 'Moco de Gorila', presentacion = '80 G', forma_farmaceutica = 'Gel', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Moco de Gorila Punk' where sku = 'FC-99428024';

-- FC-9A1C64E7 | Perilla Edigar N O Caja
update public.productos set nombre = 'Perilla Edigar N O Caja', marca = 'Perilla', categoria = 'Producto', tipo = 'marca', descripcion = 'Perilla Edigar N O Caja' where sku = 'FC-9A1C64E7';

-- FC-9A37D44A | Amdoryl
update public.productos set nombre = 'Amdoryl', marca = 'Amdoryl', presentacion = '14 CAPSULAS', concentracion = '30 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Amdoryl' where sku = 'FC-9A37D44A';

-- FC-9A4E4C31 | Clindamicina
update public.productos set nombre = 'Clindamicina', presentacion = 'FRASCO AMPULA', principio_activo = 'CLINDAMICINA', concentracion = '600MG/4 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', descripcion = 'Clindamicina' where sku = 'FC-9A4E4C31';

-- FC-9ABFB996 | Elaphteron
update public.productos set nombre = 'Elaphteron', marca = 'Elaphteron', presentacion = '20 TABLETAS', concentracion = '100 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Elaphteron' where sku = 'FC-9ABFB996';

-- FC-9B93AC4C | Beneventol
update public.productos set nombre = 'Beneventol', presentacion = '1 SUSPENSION', principio_activo = 'BENEVENTOL', concentracion = '100MG/5 ML/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', descripcion = 'Beneventol' where sku = 'FC-9B93AC4C';

-- FC-9F67BB73 | Amifarin
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '1 SUSPENSION', concentracion = '250MG 60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Amifarin' where sku = 'FC-9F67BB73';

-- FC-A0D320D1 | Amoxicilina
update public.productos set nombre = 'Amoxicilina', presentacion = '12 CAPSULAS', principio_activo = 'AMOXICILINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Amoxicilina' where sku = 'FC-A0D320D1';

-- FC-A23F290E | Zitriasol
update public.productos set nombre = 'Zitriasol', presentacion = '15 CAPSULAS', principio_activo = 'ZITRIASOL', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Zitriasol' where sku = 'FC-A23F290E';

-- FC-A2B284E0 | Hialuronato De Sodio 4Mg
update public.productos set nombre = 'Hialuronato De Sodio 4Mg', marca = 'Hialuronato', presentacion = '10 ML', categoria = 'Producto', tipo = 'marca', descripcion = 'Hialuronato De Sodio 4Mg' where sku = 'FC-A2B284E0';

-- FC-A455EE80 | Cefagen
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFALEXINA', concentracion = '250MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefagen' where sku = 'FC-A455EE80';

-- FC-A680F97E | Mercurio Yodo Tomar 1800823 83156
update public.productos set nombre = 'Mercurio Yodo Tomar 1800823 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Yodo Tomar 1800823 83156' where sku = 'FC-A680F97E';

-- FC-A871D831 | Perilla N6
update public.productos set nombre = 'Perilla N6', marca = 'Edigar', presentacion = 'PIEZA', categoria = 'Botiquín', tipo = 'generico', descripcion = 'Perilla N6' where sku = 'FC-A871D831';

-- FC-A909ABC0 | Odivitor
update public.productos set nombre = 'Odivitor', marca = 'Odivitor', presentacion = '10 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Odivitor' where sku = 'FC-A909ABC0';

-- FC-AA7B0686 | Drosquim Ad 1 Ibe 300/160
update public.productos set nombre = 'Drosquim Ad 1 Ibe 300/160', marca = 'Drosquim', presentacion = '200 ML', categoria = 'Producto', tipo = 'marca', descripcion = 'Drosquim Ad 1 Ibe 300/160' where sku = 'FC-AA7B0686';

-- FC-AA905BF7 | Perludil
update public.productos set nombre = 'Perludil', marca = 'Perludil', presentacion = '1 FRASCO AMPULA', concentracion = '150/10 MG', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Perludil' where sku = 'FC-AA905BF7';

-- FC-ACA2A2F6 | Alopurinol
update public.productos set nombre = 'Alopurinol', presentacion = '20 TABLETAS', principio_activo = 'ALOPURINOL', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Alopurinol' where sku = 'FC-ACA2A2F6';

-- FC-AE5EEDF7 | Bactiver
update public.productos set nombre = 'Bactiver', marca = 'Bactiver', presentacion = '20 TABLETAS', concentracion = '400/80 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Bactiver' where sku = 'FC-AE5EEDF7';

-- FC-AEA8C8DA | Namifen
update public.productos set nombre = 'Namifen', marca = 'Namifen', presentacion = '20 TABLETAS', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Namifen' where sku = 'FC-AEA8C8DA';

-- FC-B18E386A | Cefaroxil
update public.productos set nombre = 'Cefaroxil', marca = 'Cefaroxil', presentacion = '15 TABLETAS', concentracion = '500/30 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefaroxil' where sku = 'FC-B18E386A';

-- FC-B2123139 | Oxivag
update public.productos set nombre = 'Oxivag', marca = 'Oxivag', presentacion = '4 TABLETAS', concentracion = '70 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Oxivag' where sku = 'FC-B2123139';

-- FC-B25094C4 | Lesaclor
update public.productos set nombre = 'Lesaclor', marca = 'Lesaclor', presentacion = '1 SUSPENSION', concentracion = '200MG/5/125 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Lesaclor' where sku = 'FC-B25094C4';

-- FC-B25B4654 | Cina
update public.productos set nombre = 'Cina', marca = 'Cina', presentacion = '7 TABLETAS', concentracion = '750 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Cina' where sku = 'FC-B25B4654';

-- FC-B3B8F9BB | Desrotan
update public.productos set nombre = 'Desrotan', marca = 'Desrotan', presentacion = '10 TABLETAS', concentracion = '180 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Desrotan' where sku = 'FC-B3B8F9BB';

-- FC-B4477A00 | Pentibroxil
update public.productos set nombre = 'Pentibroxil', marca = 'Pentibroxil', presentacion = '16 CAPSULAS', concentracion = '500/30 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Pentibroxil' where sku = 'FC-B4477A00';

-- FC-B69FCBF4 | Lesaclor
update public.productos set nombre = 'Lesaclor', marca = 'Lesaclor', presentacion = '35 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Lesaclor' where sku = 'FC-B69FCBF4';

-- FC-B72A6420 | Pentiver
update public.productos set nombre = 'Pentiver', marca = 'Pentiver', presentacion = '1 SUSPENSION', concentracion = '250MG/5/90 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Pentiver' where sku = 'FC-B72A6420';

-- FC-B8D7C997 | Bicarbonato Sobres
update public.productos set nombre = 'Bicarbonato Sobres', marca = 'Bicarbonato', presentacion = 'C/50', forma_farmaceutica = 'Producto natural', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Bicarbonato Sobres' where sku = 'FC-B8D7C997';

-- FC-BCF59548 | Perilla N1
update public.productos set nombre = 'Perilla N1', marca = 'Edigar', presentacion = 'PIEZA', categoria = 'Botiquín', tipo = 'generico', descripcion = 'Perilla N1' where sku = 'FC-BCF59548';

-- FC-BDB2E087 | Irbesartan
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Irbesartan' where sku = 'FC-BDB2E087';

-- FC-BE0A0E46 | Sumitex Intravenoso- Pu X 25 Mm C/1 Azul
update public.productos set nombre = 'Sumitex Intravenoso- Pu X 25 Mm C/1 Azul', marca = 'Sumitex', presentacion = '22 G', forma_farmaceutica = 'Catéter', categoria = 'Botiquín', tipo = 'marca', descripcion = 'Sumitex Intravenoso- Pu X 25 Mm C/1 Azul' where sku = 'FC-BE0A0E46';

-- FC-BE2ACF63 | Valnait Capsulas
update public.productos set nombre = 'Valnait Capsulas', marca = 'Valnait', presentacion = 'C/30', categoria = 'Producto', tipo = 'marca', descripcion = 'Valnait Capsulas' where sku = 'FC-BE2ACF63';

-- FC-BE76D409 | I.M
update public.productos set nombre = 'I.M', marca = 'Amcef', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3.5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'I.M' where sku = 'FC-BE76D409';

-- FC-C101D5B1 | Bisoprolol
update public.productos set nombre = 'Bisoprolol', presentacion = '30 TABLETAS', principio_activo = 'BISOPROLOL', concentracion = '2.5 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Bisoprolol' where sku = 'FC-C101D5B1';

-- FC-C22EBFE6 | Perilla N2
update public.productos set nombre = 'Perilla N2', marca = 'Edigar', presentacion = 'PIEZA', categoria = 'Botiquín', tipo = 'generico', descripcion = 'Perilla N2' where sku = 'FC-C22EBFE6';

-- FC-C4530823 | Mercurio Oxido De Zinc 1620824 83521
update public.productos set nombre = 'Mercurio Oxido De Zinc 1620824 83521', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Oxido De Zinc 1620824 83521' where sku = 'FC-C4530823';

-- FC-C636D8EA | I.M
update public.productos set nombre = 'I.M', marca = 'Ceftriaxona', presentacion = '1 FRASCO AMPULA', concentracion = '1 G/3.5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'I.M' where sku = 'FC-C636D8EA';

-- FC-C6C20517 | Budimin
update public.productos set nombre = 'Budimin', marca = 'Budimin', presentacion = '20 TABLETAS', concentracion = '1 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Budimin' where sku = 'FC-C6C20517';

-- FC-C721E8D7 | Levofloxacino
update public.productos set nombre = 'Levofloxacino', presentacion = '7 TABLETAS', principio_activo = 'LEVOFLOXACINO', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Levofloxacino' where sku = 'FC-C721E8D7';

-- FC-C8B741F6 | Fc 01711/2030
update public.productos set nombre = 'Fc 01711/2030', marca = 'Fc', categoria = 'Producto', tipo = 'marca', descripcion = 'Fc 01711/2030' where sku = 'FC-C8B741F6';

-- FC-C9F4ACCC | Acemetacina
update public.productos set nombre = 'Acemetacina', presentacion = '14 CAPSULAS', principio_activo = 'ACEMETACINA', concentracion = '90 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Acemetacina' where sku = 'FC-C9F4ACCC';

-- FC-CB5C11ED | Mercurio Magnesia Anisada 1560824
update public.productos set nombre = 'Mercurio Magnesia Anisada 1560824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Magnesia Anisada 1560824' where sku = 'FC-CB5C11ED';

-- FC-CD261CD5 | Doliprofen
update public.productos set nombre = 'Doliprofen', marca = 'Doliprofen', presentacion = '10 TABLETAS', concentracion = '800 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Doliprofen' where sku = 'FC-CD261CD5';

-- FC-CF18C740 | Clindamicina
update public.productos set nombre = 'Clindamicina', presentacion = '16 CAPSULAS', principio_activo = 'CLINDAMICINA', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Clindamicina' where sku = 'FC-CF18C740';

-- FC-CF719C07 | Diclofen
update public.productos set nombre = 'Diclofen', marca = 'Diclofen', presentacion = '12 CAPSULAS', principio_activo = 'DICLOFENACO', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Diclofen' where sku = 'FC-CF719C07';

-- FC-D037156B | Mercurio Bismuto Subnitrato 1390724
update public.productos set nombre = 'Mercurio Bismuto Subnitrato 1390724', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Bismuto Subnitrato 1390724' where sku = 'FC-D037156B';

-- FC-D06E54FE | Valclan
update public.productos set nombre = 'Valclan', marca = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Valclan' where sku = 'FC-D06E54FE';

-- FC-D11D586A | Valgab 3 Ibe /6Ml
update public.productos set nombre = 'Valgab 3 Ibe /6Ml', marca = 'Valgab', presentacion = '50 MG', categoria = 'Producto', tipo = 'marca', descripcion = 'Valgab 3 Ibe /6Ml' where sku = 'FC-D11D586A';

-- FC-D210172A | Ampicilina
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '1 G/5 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'generico', descripcion = 'Ampicilina' where sku = 'FC-D210172A';

-- FC-D3D28E20 | Mercurio Yodo Untar 1810623 83156
update public.productos set nombre = 'Mercurio Yodo Untar 1810623 83156', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Yodo Untar 1810623 83156' where sku = 'FC-D3D28E20';

-- FC-D4AC123B | Mercurio Aceite Almendras 790523
update public.productos set nombre = 'Mercurio Aceite Almendras 790523', marca = 'Mercurio', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Aceite Almendras 790523' where sku = 'FC-D4AC123B';

-- FC-D5AC44CA | Amifarin
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Amifarin' where sku = 'FC-D5AC44CA';

-- FC-D751525D | Animalin
update public.productos set nombre = 'Animalin', marca = 'Animalin', presentacion = 'GOTAS', concentracion = 'C/30 ML', forma_farmaceutica = 'GOTAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Animalin' where sku = 'FC-D751525D';

-- FC-D9391288 | Azitromicina
update public.productos set nombre = 'Azitromicina', presentacion = '1 SUSPENSION', principio_activo = 'AZITROMICINA', concentracion = '200MG/5/15 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', descripcion = 'Azitromicina' where sku = 'FC-D9391288';

-- FC-DA34D88D | Erbitrax
update public.productos set nombre = 'Erbitrax', marca = 'Erbitrax', presentacion = 'C/7', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Erbitrax' where sku = 'FC-DA34D88D';

-- FC-DB3B2584 | Celesbitan
update public.productos set nombre = 'Celesbitan', marca = 'Celesbitan', presentacion = '1 FRASCO AMPULA', concentracion = 'C/BER 6MG/2 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Celesbitan' where sku = 'FC-DB3B2584';

-- FC-DB4A39AE | Efe
update public.productos set nombre = 'Efe', marca = 'Calcio', presentacion = '12 COMPRIMIDOS', concentracion = '500 MG', forma_farmaceutica = 'COMPRIMIDOS', categoria = 'Otro', tipo = 'marca', descripcion = 'Efe' where sku = 'FC-DB4A39AE';

-- FC-DDFBABDF | 12H Ped
update public.productos set nombre = '12H Ped', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '200/28.5MG/40 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = '12H Ped' where sku = 'FC-DDFBABDF';

-- FC-DE106642 | Inf
update public.productos set nombre = 'Inf', marca = 'Ampigrin', presentacion = '3 AMPOLLETA', concentracion = '250/200/100/30MG/3 ML', forma_farmaceutica = 'AMPOLLETA', categoria = 'Otro', tipo = 'marca', descripcion = 'Inf' where sku = 'FC-DE106642';

-- FC-DEAF33B0 | Bactiver
update public.productos set nombre = 'Bactiver', marca = 'Bactiver', presentacion = '1 SUSPENSION', concentracion = '40/200/5/120 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Bactiver' where sku = 'FC-DEAF33B0';

-- FC-DF39BB27 | Alevarin Capsulas
update public.productos set nombre = 'Alevarin Capsulas', marca = 'Alevarin', presentacion = 'C/45', categoria = 'Producto', tipo = 'marca', descripcion = 'Alevarin Capsulas' where sku = 'FC-DF39BB27';

-- FC-DF8ADDAB | Erispan
update public.productos set nombre = 'Erispan', marca = 'Erispan', presentacion = '1 FRASCO AMPULA', concentracion = '4MG/3 ML', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Erispan' where sku = 'FC-DF8ADDAB';

-- FC-DFF99C3F | Mercurio
update public.productos set nombre = 'Mercurio', marca = 'Mercurio', presentacion = 'JARABE', concentracion = 'DE GRANADA. C/25 1750823', forma_farmaceutica = 'JARABE', categoria = 'Otro', tipo = 'marca', descripcion = 'Mercurio' where sku = 'FC-DFF99C3F';

-- FC-E374F23E | Cefagen
update public.productos set nombre = 'Cefagen', marca = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFALEXINA', concentracion = '125MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Cefagen' where sku = 'FC-E374F23E';

-- FC-E4BE37BE | Atorvastatina
update public.productos set nombre = 'Atorvastatina', presentacion = '10 TABLETAS', principio_activo = 'ATORVASTATINA', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Atorvastatina' where sku = 'FC-E4BE37BE';

-- FC-E4EFC4C2 | Fasiclor
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '15 CAPSULAS', principio_activo = 'CEFACLOR', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Fasiclor' where sku = 'FC-E4EFC4C2';

-- FC-E535DE28 | Diurmessel
update public.productos set nombre = 'Diurmessel', marca = 'Diurmessel', presentacion = '20 TABLETAS', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Diurmessel' where sku = 'FC-E535DE28';

-- FC-E6112F15 | Nalixone
update public.productos set nombre = 'Nalixone', presentacion = '20 TABLETAS', principio_activo = 'NALIXONE', concentracion = '500/50 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Nalixone' where sku = 'FC-E6112F15';

-- FC-E69F2E63 | Madrid Aceite Eucalipto 2712017 83401
update public.productos set nombre = 'Madrid Aceite Eucalipto 2712017 83401', marca = 'Madrid', presentacion = 'C/25', categoria = 'Producto', tipo = 'marca', descripcion = 'Madrid Aceite Eucalipto 2712017 83401' where sku = 'FC-E69F2E63';

-- FC-E6B50AC3 | Celecoxib
update public.productos set nombre = 'Celecoxib', marca = 'Celecoxib', presentacion = '10 CAPSULAS', concentracion = '200MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Celecoxib' where sku = 'FC-E6B50AC3';

-- FC-E826D304 | Lincomicina /2Ml 6 Ampolletas
update public.productos set nombre = 'Lincomicina /2Ml 6 Ampolletas', marca = 'Lincomicina', presentacion = '600 MG', categoria = 'Producto', tipo = 'marca', descripcion = 'Lincomicina /2Ml 6 Ampolletas' where sku = 'FC-E826D304';

-- FC-E9C38DC4 | Ciprofloxacino G.I
update public.productos set nombre = 'Ciprofloxacino G.I', presentacion = '14 TABLETAS', principio_activo = 'CIPROFLOXACINO G.I', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Ciprofloxacino G.I' where sku = 'FC-E9C38DC4';

-- FC-EADF1484 | Diosmina Hesperidina
update public.productos set nombre = 'Diosmina Hesperidina', presentacion = '20 TABLETAS', principio_activo = 'DIOSMINA HESPERIDINA', concentracion = '450/50 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Diosmina Hesperidina' where sku = 'FC-EADF1484';

-- FC-EFB599B5 | Mercurio Pan Puerco 25401233
update public.productos set nombre = 'Mercurio Pan Puerco 25401233', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Pan Puerco 25401233' where sku = 'FC-EFB599B5';

-- FC-F183C6E9 | Penipot
update public.productos set nombre = 'Penipot', marca = 'Penipot', presentacion = '1 FRASCO AMPULA', concentracion = '800,000 UI', forma_farmaceutica = 'FRASCO AMPULA', categoria = 'Otro', tipo = 'marca', descripcion = 'Penipot' where sku = 'FC-F183C6E9';

-- FC-F22C72BE | 12H
update public.productos set nombre = '12H', marca = 'Clamoxin', presentacion = '10 TABLETAS', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = '12H' where sku = 'FC-F22C72BE';

-- FC-F3E734A0 | Fasiclor
update public.productos set nombre = 'Fasiclor', marca = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'CEFACLOR', concentracion = '375MG/5/50 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Fasiclor' where sku = 'FC-F3E734A0';

-- FC-F48FF7EF | Clamoxin
update public.productos set nombre = 'Clamoxin', marca = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA/AC. CLAVULANICO', concentracion = '250/62.5MG/5/60 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'marca', descripcion = 'Clamoxin' where sku = 'FC-F48FF7EF';

-- FC-F4E9C71F | Amoxicilina
update public.productos set nombre = 'Amoxicilina', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA', concentracion = '500MG/5/75 ML', forma_farmaceutica = 'SUSPENSION', categoria = 'Otro', tipo = 'generico', descripcion = 'Amoxicilina' where sku = 'FC-F4E9C71F';

-- FC-F7A2CACF | Indarzona
update public.productos set nombre = 'Indarzona', marca = 'Indarzona', presentacion = '30 CAPSULAS', concentracion = '25/0.5 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Indarzona' where sku = 'FC-F7A2CACF';

-- FC-F7DB080D | Ovisen
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '28 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Ovisen' where sku = 'FC-F7DB080D';

-- FC-F817BC3A | Sibicos
update public.productos set nombre = 'Sibicos', marca = 'Sibicos', presentacion = '1 CREMA', concentracion = '1/100/20 G', forma_farmaceutica = 'CREMA', categoria = 'Otro', tipo = 'marca', descripcion = 'Sibicos' where sku = 'FC-F817BC3A';

-- FC-F82A6E4B | Ampicilina
update public.productos set nombre = 'Ampicilina', presentacion = '10 TABLETAS', principio_activo = 'AMPICILINA', concentracion = '1 G', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'generico', descripcion = 'Ampicilina' where sku = 'FC-F82A6E4B';

-- FC-F8691496 | F
update public.productos set nombre = 'F', marca = 'Bactiver', presentacion = '16 TABLETAS', concentracion = '160/800 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'F' where sku = 'FC-F8691496';

-- FC-F967863B | Terficho
update public.productos set nombre = 'Terficho', marca = 'Terficho', presentacion = '40 CAPSULAS', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Terficho' where sku = 'FC-F967863B';

-- FC-FA3D96E6 | N Calcitriol
update public.productos set nombre = 'N Calcitriol', marca = 'Becatrim', presentacion = '30 CAPSULAS', concentracion = '0.25 MCG', forma_farmaceutica = 'CAPSULAS', categoria = 'Otro', tipo = 'marca', descripcion = 'N Calcitriol' where sku = 'FC-FA3D96E6';

-- FC-FBD776D2 | Mercurio Perlas De Eter 1630824
update public.productos set nombre = 'Mercurio Perlas De Eter 1630824', marca = 'Mercurio', presentacion = 'C/50', categoria = 'Producto', tipo = 'marca', descripcion = 'Mercurio Perlas De Eter 1630824' where sku = 'FC-FBD776D2';

-- FC-FD718DF3 | Mercurio Sulfatiazol 2600223
update public.productos set nombre = 'Mercurio Sulfatiazol 2600223', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Sulfatiazol 2600223' where sku = 'FC-FD718DF3';

-- FC-FD845E68 | Aciclovir
update public.productos set nombre = 'Aciclovir', marca = 'Aciclovir', presentacion = '35 TABLETAS', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Aciclovir' where sku = 'FC-FD845E68';

-- FC-FD92D114 | Ovisen
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '14 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS', categoria = 'Otro', tipo = 'marca', descripcion = 'Ovisen' where sku = 'FC-FD92D114';

-- FC-FEAECBF1 | Mercurio Tepezcohuite
update public.productos set nombre = 'Mercurio Tepezcohuite', marca = 'Mercurio', presentacion = 'C/25', forma_farmaceutica = 'Pomada', categoria = 'Cuidado personal', tipo = 'marca', descripcion = 'Mercurio Tepezcohuite' where sku = 'FC-FEAECBF1';

-- FC-FFC25DD1 | Perilla N4
update public.productos set nombre = 'Perilla N4', marca = 'Edigar', presentacion = 'PIEZA', categoria = 'Botiquín', tipo = 'generico', descripcion = 'Perilla N4' where sku = 'FC-FFC25DD1';

commit;

-- Verificación: nombres OCR que aún parezcan ticket
select sku, left(nombre, 72) as nombre
from public.productos
where sku like 'FC-%'
  and (
    nombre ~* 'descto|\\$|\\(a\\)|\\|\\s*lab'
    or length(nombre) > 90
  )
order by sku
limit 30;

-- Muestra Tensolastic + casos del screenshot
select sku, nombre, presentacion, marca
from public.productos
where sku in (
  'FC-48690909','FC-48690800','FC-48691005','FC-48691104',
  'FC-24227339','FC-80950139','FC-70612368','FC-65095718','FC-95451096'
)
order by sku;
