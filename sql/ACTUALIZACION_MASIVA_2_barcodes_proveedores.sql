-- FarmaCapital — ACTUALIZACIÓN MASIVA INVENTARIO
-- Generado: 2026-08-10
-- Fuente: Excel homologado de tickets (627 líneas)
--
-- ORDEN EN SUPABASE SQL EDITOR:
--   1) ACTUALIZACION_MASIVA_1_preparacion_catalogo.sql  ← columnas + funciones + catálogo
--   2) ACTUALIZACION_MASIVA_2_barcodes_proveedores.sql
--
-- Si falló antes: ejecuta primero sql/patch_productos_campos_catalogo.sql
-- y sql/patch_proveedor_tienda_en_lotes.sql por separado.
--
-- Incluye:
--   • Parche RPCs (proveedor tienda en lotes)
--   • Catálogo: nombre, marca, presentación, PA, precios 60%/30%
--   • Códigos de barras del ticket (349 con EAN)
--   • Proveedor del lote = tienda de compra (627 mapeos)


begin;

-- ── actualizar_codigos_barras_tickets.sql ──
-- ============================================================
-- FarmaCapital — Actualizar codigo_barras desde Excel homologado
-- Ejecutar DESPUÉS de carga_inventario_tickets_EJECUTAR_1..4
-- Solo filas con EAN en ticket (Bodega, Surtidor, FarmaLive).
-- Filas con barcode en Excel: 349 | UPDATE únicos: 349
-- ============================================================


-- 77827 Desod Obao R-Nat Coco R-On 65G
update public.productos set codigo_barras = '7509552844825' where sku = 'FC-52844825' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Obao Game 48Hr R-On 65G N
update public.productos set codigo_barras = '7509552933307' where sku = 'FC-52933307' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Obad P/Del R-On 65G
update public.productos set codigo_barras = '7501027250612' where sku = 'FC-27250612' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Obao Clas R-On 65G
update public.productos set codigo_barras = '7501027286017' where sku = 'FC-27286017' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Obao Men Tatto Aqua R-On 65G
update public.productos set codigo_barras = '7509552876406' where sku = 'FC-52876406' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Men Young Spy 150Ml
update public.productos set codigo_barras = '750630622622' where sku = 'FC-30622622' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Icechi E-Frio Spy 150Ml
update public.productos set codigo_barras = '7506306213906' where sku = 'FC-06213906' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona Men Marine Spy 150Ml
update public.productos set codigo_barras = '7791293037806' where sku = 'FC-93037806' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Obao Men Tato Rebel R-On65
update public.productos set codigo_barras = '750955280956' where sku = 'FC-55280956' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Excite Seco Spy 152Ml
update public.productos set codigo_barras = '7791293025919' where sku = 'FC-93025919' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona Men V8 Tun Spy 90G
update public.productos set codigo_barras = '7791293022567' where sku = 'FC-93022567' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Intense 48H Spy 150Ml
update public.productos set codigo_barras = '7506306244795' where sku = 'FC-06244795' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona 48H Happy-M Stick 45G
update public.productos set codigo_barras = '75076009' where sku = 'FC-75076009' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Men Dark Temp Spy150Ml
update public.productos set codigo_barras = '7791293025797' where sku = 'FC-93025797' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona Men Sport Spy 150Ml
update public.productos set codigo_barras = '7791293038223' where sku = 'FC-93038223' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona Bamboo 48H Stick 45G
update public.productos set codigo_barras = '75062897' where sku = 'FC-75062897' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Men Epic-F 48H Spy 150Ml
update public.productos set codigo_barras = '7506306245686' where sku = 'FC-06245686' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Men Gold Temp
update public.productos set codigo_barras = '7791293025865' where sku = 'FC-93025865' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Grisi Neutro 150 G
update public.productos set codigo_barras = '7501022105207' where sku = 'FC-22105207' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Dove Barra Blanca
update public.productos set codigo_barras = '067238891190' where sku = 'FC-38891190' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rexona Pom-Dry48H Stick45G
update public.productos set codigo_barras = '75062927' where sku = 'FC-75062927' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Asepxia Bicarbon Sod 100G
update public.productos set codigo_barras = '650240036965' where sku = 'FC-40036965' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Asexia Exfol 100G
update public.productos set codigo_barras = '650240004643' where sku = 'FC-40004643' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Grisi Avena 125G
update public.productos set codigo_barras = '7501022150801' where sku = 'FC-22150801' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Escudo Antibact 110Gr
update public.productos set codigo_barras = '7506425605514' where sku = 'FC-25605514' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Azufre Jabon C Miel 80
update public.productos set codigo_barras = '7503014119032' where sku = 'FC-14119032' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Dove Barra Karite Vainill 135G
update public.productos set codigo_barras = '7506306230507' where sku = 'FC-06230507' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Grisi Leche De Burra 125G
update public.productos set codigo_barras = '7501022150092' where sku = 'FC-22150092' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Grisi Corp Diabecare 125 G
update public.productos set codigo_barras = '7501022111352' where sku = 'FC-22111352' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Rex Mot-Sen Sport Stick
update public.productos set codigo_barras = '75069223' where sku = 'FC-75069223' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Liq Palmol N-Bal Dermol 221Mln
update public.productos set codigo_barras = '7509546059556' where sku = 'FC-46059556' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Liq Blumen Coconut Para 221Ml
update public.productos set codigo_barras = '7506267905186' where sku = 'FC-67905186' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Palmol N-Bal Dermo Limp 120G
update public.productos set codigo_barras = '7509546683133' where sku = 'FC-46683133' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Dove Dermac Sk-C 48H Spy150Ml
update public.productos set codigo_barras = '7506306241206' where sku = 'FC-06241206' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Escudo Rosa Prot Y Cuid 110G
update public.productos set codigo_barras = '7501943489004' where sku = 'FC-43489004' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Agua Mic Garnier De Rosas 400 Ml
update public.productos set codigo_barras = '3600542326414' where sku = 'FC-42326414' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Agua Mic Vitacilina Ros-Sab 500Mln
update public.productos set codigo_barras = '7506376000284' where sku = 'FC-76000284' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desmaq Bifasico Oil Nuvel 125Ml
update public.productos set codigo_barras = '7501082790504' where sku = 'FC-82790504' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Agua Mice Natural-G Bifasic 120Ml
update public.productos set codigo_barras = '7502245722547' where sku = 'FC-45722547' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Liq Blumen Cherry Bloss 221Ml
update public.productos set codigo_barras = '7506267905131' where sku = 'FC-67905131' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tas Hum Claris Desmaq Aloe C/40
update public.productos set codigo_barras = '7502221012303' where sku = 'FC-21012303' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jabon De Proteina De Arroz Y Concha Nacar 8
update public.productos set codigo_barras = '7505514121782' where sku = 'FC-14121782' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Escudo Azul Rey 135G
update public.productos set codigo_barras = '7506425652716' where sku = 'FC-25652716' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Deo Aero Dove Tono Uniforme 150Ml 3Pack
update public.productos set codigo_barras = '7506306248052' where sku = 'FC-06248052' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Deo Dove Spy Invisible Dry 150Ml C3
update public.productos set codigo_barras = '7506306248045' where sku = 'FC-06248045' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Liq Palmol Aquarium 221Ml
update public.productos set codigo_barras = '7501035911208' where sku = 'FC-35911208' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Nivea Pearlb Mspy150Ml
update public.productos set codigo_barras = '4005808837311' where sku = 'FC-08837311' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo
update public.productos set codigo_barras = '7506306209862' where sku = 'FC-06209862' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Liq Escudo Blanco Neut 225Ml
update public.productos set codigo_barras = '7501943489165' where sku = 'FC-43489165' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jaloma Agua De Rosas 130Ml Spray
update public.productos set codigo_barras = '759684900280' where sku = 'FC-84900280' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Axe Wom Anarchy Spy 150Ml
update public.productos set codigo_barras = '7506306226852' where sku = 'FC-06226852' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Lio Palmol Flor Czo-Rsa 221Ml
update public.productos set codigo_barras = '7509546657035' where sku = 'FC-46657035' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Loc Limp Ponds Bio-Hydra Dual 200Ml
update public.productos set codigo_barras = '7501056330378' where sku = 'FC-56330378' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Deo Mexsana P/Pies Spy 150Ml
update public.productos set codigo_barras = '7502276040436' where sku = 'FC-76040436' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Desod Odolex
update public.productos set codigo_barras = '7501361113000' where sku = 'FC-61113000' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Odolex Naturals 300Gr Talco Desodorante
update public.productos set codigo_barras = '7501361123009' where sku = 'FC-61123009' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tiraleche De Cristal 1 Pza
update public.productos set codigo_barras = '7501441500096' where sku = 'FC-41500096' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Pert Plus Ac-Oliva 400Ml
update public.productos set codigo_barras = '810120500201' where sku = 'FC-20500201' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Ting Polvo 85G
update public.productos set codigo_barras = '7501072300171' where sku = 'FC-72300171' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Ico Desod Rexona Effi Fresh 200G
update public.productos set codigo_barras = '7506306217461' where sku = 'FC-06217461' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Quita Esm Nuvel Humec 125Ml
update public.productos set codigo_barras = '7501082740011' where sku = 'FC-82740011' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Fructis Pei B-Dano Quim 300Ml
update public.productos set codigo_barras = '7509552910971' where sku = 'FC-52910971' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Fructis Pei Oil-R L-Coco 300Ml
update public.productos set codigo_barras = '7509552816297' where sku = 'FC-52816297' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Int Lomecan V 200Ml
update public.productos set codigo_barras = '650240025839' where sku = 'FC-40025839' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Int Lomecan V Aclar 200Ml
update public.productos set codigo_barras = '650240030338' where sku = 'FC-40030338' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silkhair Quita Esmalte Mora Azul 100Ml
update public.productos set codigo_barras = '7502245720550' where sku = 'FC-45720550' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nutribela1O Bio Colageno 300Gn
update public.productos set codigo_barras = '7506192511261' where sku = 'FC-92511261' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nutribela Nutrice Tarro 300G
update public.productos set codigo_barras = '7506192509213' where sku = 'FC-92509213' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Rexona 1O0Gr Tco Pies Efficient Orig
update public.productos set codigo_barras = '7506306257597' where sku = 'FC-06257597' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Caprice Nat Mzna 380 Ml
update public.productos set codigo_barras = '7509546073156' where sku = 'FC-46073156' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Pert Oliv+Ac Agu P/Pein 100 Ml
update public.productos set codigo_barras = '810120500171' where sku = 'FC-20500171' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Ac Pantene Bambu 400Ml
update public.productos set codigo_barras = '7500435155922' where sku = 'FC-35155922' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Acono Pant Brillo Extremo 40Cml
update public.productos set codigo_barras = '7501007457826' where sku = 'FC-07457826' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Rizos Obedie 300Ml
update public.productos set codigo_barras = '7501056340131' where sku = 'FC-56340131' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Acond Pant Rizos Definid 400Ml
update public.productos set codigo_barras = '7501001165321' where sku = 'FC-01165321' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Sedal Rizos Def Inf-Act 180Ml
update public.productos set codigo_barras = '7506306249783' where sku = 'FC-06249783' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Desod Eficc Pies 200 G
update public.productos set codigo_barras = '7501056360429' where sku = 'FC-56360429' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Sos Recon-Estru 300Ml
update public.productos set codigo_barras = '7501056340025' where sku = 'FC-56340025' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Rizos Obedientes 135Ml
update public.productos set codigo_barras = '7501056342227' where sku = 'FC-56342227' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Sedal Ceramidas Inf-Act 180Ml
update public.productos set codigo_barras = '7506306249776' where sku = 'FC-06249776' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Pant Ctrcaida A/Pv 400Ml
update public.productos set codigo_barras = '7501001303454' where sku = 'FC-01303454' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Pant Brillo Extremo
update public.productos set codigo_barras = '7501007457796' where sku = 'FC-07457796' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Pant Bambu Ctrl Caida 400 Ml
update public.productos set codigo_barras = '7500435155847' where sku = 'FC-35155847' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Savile Ker-Sab Fza Repar 700Ml
update public.productos set codigo_barras = '7506306249240' where sku = 'FC-06249240' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Savile Bio-Sab Creci Res 700Ml
update public.productos set codigo_barras = '7506306249226' where sku = 'FC-06249226' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silica Shine Sil 3/1 Uva 120 Mi
update public.productos set codigo_barras = '7502224511629' where sku = 'FC-24511629' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Anti Nudos 300 Ml
update public.productos set codigo_barras = '7506306234062' where sku = 'FC-06234062' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Recons Estructur 135Ml
update public.productos set codigo_barras = '7501056342258' where sku = 'FC-56342258' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Desdo Odolex 150 G
update public.productos set codigo_barras = '7501361111501' where sku = 'FC-61111501' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Odolex Fresh 150G
update public.productos set codigo_barras = '7501361124013' where sku = 'FC-61124013' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Sedal Sos Ceramida 300Ml
update public.productos set codigo_barras = '7501056340124' where sku = 'FC-56340124' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Hbs Limp Renoy 375Ml
update public.productos set codigo_barras = '7500435020008' where sku = 'FC-35020008' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Mousse Herbal Ess Rizo 200G
update public.productos set codigo_barras = '7500435169035' where sku = 'FC-35169035' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Hash Anti Comezon 375Ml
update public.productos set codigo_barras = '7500435168991' where sku = 'FC-35168991' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Hash Anti Comezon 375Ml
update public.productos set codigo_barras = '7500435231237' where sku = 'FC-35231237' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cera Mod Ego Met 25 G
update public.productos set codigo_barras = '7506192504539' where sku = 'FC-92504539' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cera Gel Moco De Gorila Citr 100G
update public.productos set codigo_barras = '7501438312374' where sku = 'FC-38312374' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh H&S Anti Comezon 180 Ml
update public.productos set codigo_barras = '7500435231244' where sku = 'FC-35231244' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Hbs Alivio Instant
update public.productos set codigo_barras = '7500435020077' where sku = 'FC-35020077' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel Ego Magnetic Fij-Alta 200 Ml
update public.productos set codigo_barras = '7506192503558' where sku = 'FC-92503558' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel X-Extreme Titan 250G
update public.productos set codigo_barras = '7501199425580' where sku = 'FC-99425580' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel Moco De Gorila Punk 80 G
update public.productos set codigo_barras = '7501199428024' where sku = 'FC-99428024' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Caprice Sp Biotina Fza 200Ml
update public.productos set codigo_barras = '7509546073040' where sku = 'FC-46073040' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Caprice Sp Acti Ceramida 200Ml
update public.productos set codigo_barras = '7509546073033' where sku = 'FC-46073033' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silica Shine Sily Oleo Argan 120Ml
update public.productos set codigo_barras = '7502254073302' where sku = 'FC-54073302' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silica Shine Sily 3/1 Mora 120Ml
update public.productos set codigo_barras = '7502224511711' where sku = 'FC-24511711' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silica Shine Sily 3/1 Naran 12Cml
update public.productos set codigo_barras = '7502224511636' where sku = 'FC-24511636' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Brill Palmol Lio 115M
update public.productos set codigo_barras = '75001865' where sku = 'FC-75001865' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Mousse Caprice Volum-Cirl 200 G
update public.productos set codigo_barras = '7509546655055' where sku = 'FC-46655055' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel Ego Fresh C-Cas Fij-Alt 200Ml
update public.productos set codigo_barras = '7506306247468' where sku = 'FC-06247468' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel Ego For Men Attraction 200 Ml
update public.productos set codigo_barras = '7506192506601' where sku = 'FC-92506601' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cep Dent Oral-B Indicat35Sve
update public.productos set codigo_barras = '7501086494262' where sku = 'FC-86494262' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cera Ego Firme Matte 25 G
update public.productos set codigo_barras = '7506192506045' where sku = 'FC-92506045' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Acetona Jaloma 60 Ml
update public.productos set codigo_barras = '759684431050' where sku = 'FC-84431050' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Silkhair Quita Esmalte Coco 100 Ml
update public.productos set codigo_barras = '7502245720567' where sku = 'FC-45720567' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Acetona Jaloma 120 Ml
update public.productos set codigo_barras = '759684437151' where sku = 'FC-84437151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec Tocmx2.75M 1 Pza Venda De Yeso C12
update public.productos set codigo_barras = '7501048640775' where sku = 'FC-48640775' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec 15Cmx2.75M 1 Pza Venda De Yeso C12
update public.productos set codigo_barras = '7501048640799' where sku = 'FC-48640799' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec 20Cmx2.75M 1 Pza Venda De Yeso
update public.productos set codigo_barras = '7501046640629' where sku = 'FC-46640629' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec 5Cmx2.75M 1 Pza Venda De Yeso C12 Pz
update public.productos set codigo_barras = '7501048640751' where sku = 'FC-48640751' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Ternura Flor-Balon 18 Pzs Chupon Con Miel
update public.productos set codigo_barras = '7501026462078' where sku = 'FC-26462078' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nivea Sdatarr Giga 400Ml
update public.productos set codigo_barras = '7501054500216' where sku = 'FC-54500216' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Desod Ego Force 24H R-On 45Ml Dic26
update public.productos set codigo_barras = '75064938' where sku = 'FC-75064938' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Hinds Liq Agave Azul 400Ml
update public.productos set codigo_barras = '810120501673' where sku = 'FC-20501673' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nivea B Sofmilk Sec400Ml
update public.productos set codigo_barras = '4005808802838' where sku = 'FC-08802838' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Grisi Conchnac P/Manos 80 Ml
update public.productos set codigo_barras = '037836040450' where sku = 'FC-36040450' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Clarant B3 Nml/Gsa 100G
update public.productos set codigo_barras = '7501056330309' where sku = 'FC-56330309' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nivea Cuidada Clar-Nat 200Ml
update public.productos set codigo_barras = '42270027' where sku = 'FC-42270027' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Gel Niv Fac Ref Hidra Hyalu 200Ml
update public.productos set codigo_barras = '4005900942760' where sku = 'FC-00942760' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Corp Niveamilk 400Ml+Cra100Ml
update public.productos set codigo_barras = '7501054558682' where sku = 'FC-54558682' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Teatrical Cel-Ma Nutrit 400Ml
update public.productos set codigo_barras = '650240030963' where sku = 'FC-40030963' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Chupon Ternura Ortodontic Miel C3
update public.productos set codigo_barras = '7501026462061' where sku = 'FC-26462061' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Lubriderm Uv Fps15 120Ml
update public.productos set codigo_barras = '7702035469151' where sku = 'FC-35469151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Grisi Ricitos Oro Biopure 250Ml
update public.productos set codigo_barras = '037836032776' where sku = 'FC-36032776' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Johnson'S Baby Antes/Dor 75 G
update public.productos set codigo_barras = '7501007502441' where sku = 'FC-07502441' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Palmol N-Bal Corp Baby0% 90G
update public.productos set codigo_barras = '7509546655079' where sku = 'FC-46655079' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Nuvel Protec Pura Para Bebe200G
update public.productos set codigo_barras = '7501082790016' where sku = 'FC-82790016' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Hinds Hidr-Extr Almendras 500Ml
update public.productos set codigo_barras = '037836041402' where sku = 'FC-36041402' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Lubriderm Thint Psec120Ml
update public.productos set codigo_barras = '7501007528939' where sku = 'FC-07528939' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Lubriderm P/Normal 120Ml
update public.productos set codigo_barras = '7702031244486' where sku = 'FC-31244486' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Mennen Zero% Sve 400Ml
update public.productos set codigo_barras = '7509546074504' where sku = 'FC-46074504' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Ricitos Oro Agua De Coco 250Ml
update public.productos set codigo_barras = '037836033735' where sku = 'FC-36033735' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Mennen Lavan-Extrac Aven 200Ml
update public.productos set codigo_barras = '7509546650708' where sku = 'FC-46650708' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Grisi Rici Oro Miel 250Ml
update public.productos set codigo_barras = '7501022133286' where sku = 'FC-22133286' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cep Dent Accion Mayo Alcan Somed
update public.productos set codigo_barras = '7501086472048' where sku = 'FC-86472048' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sensodyne Protec Complet + Acc Lim Efec 90G
update public.productos set codigo_barras = '7896009498091' where sku = 'FC-09498091' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cep Dent Oral-B 3Dw Advant Med2X1
update public.productos set codigo_barras = '7506195129166' where sku = 'FC-95129166' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nivea Cuidado Int P/Mano 75Ml
update public.productos set codigo_barras = '42417644' where sku = 'FC-42417644' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cd Sensodyne Original
update public.productos set codigo_barras = '7896009419324' where sku = 'FC-09419324' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Teatrical Lanol/Ros 52Gr
update public.productos set codigo_barras = '650240013898' where sku = 'FC-40013898' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Corp Niv Soft M P/Seca 100Ml
update public.productos set codigo_barras = '7501054549819' where sku = 'FC-54549819' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tas San Kotex Ant Flujo Abundante S/A 10Pz
update public.productos set codigo_barras = '7501017360604' where sku = 'FC-17360604' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Sh Mennen Miel-Mza Sve 200Ml
update public.productos set codigo_barras = '7509546072050' where sku = 'FC-46072050' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Ricitos D Oro Neutro 90 G
update public.productos set codigo_barras = '7501022150221' where sku = 'FC-22150221' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Grisi Aloe Vera P/Manos 80 Mln
update public.productos set codigo_barras = '810120501765' where sku = 'FC-20501765' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra S Ponds Humectante 100G
update public.productos set codigo_barras = '7501056326142' where sku = 'FC-56326142' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec Tensolastic Plus 10Cmx5M Venda Elast
update public.productos set codigo_barras = '7501048691005' where sku = 'FC-48691005' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Enj Buc List Anticari-Al 250Ml
update public.productos set codigo_barras = '7702031976394' where sku = 'FC-31976394' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tas Sanit Kotex Nat Flex Noct C/5
update public.productos set codigo_barras = '7501943427754' where sku = 'FC-43427754' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Enj Buc List Care Zero Mta 250Ml
update public.productos set codigo_barras = '7702031887928' where sku = 'FC-31887928' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cra Nivea Sda Tarro 100 Ml
update public.productos set codigo_barras = '7501054503095' where sku = 'FC-54503095' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tas Hum Th Bebin Super C/80
update public.productos set codigo_barras = '619585800198' where sku = 'FC-85800198' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Cep Dent Clinic Adulto Med 40 C12
update public.productos set codigo_barras = '7501072629012' where sku = 'FC-72629012' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Enj Buc List Zero Mta Sve 250Ml
update public.productos set codigo_barras = '7891010974329' where sku = 'FC-10974329' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas
update public.productos set codigo_barras = '4005900701992' where sku = 'FC-00701992' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Jbn Mennen Baby Magic Lavan 90 G
update public.productos set codigo_barras = '7509546655727' where sku = 'FC-46655727' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Mennen Azul 200G
update public.productos set codigo_barras = '7501035908130' where sku = 'FC-35908130' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec Tensolastic Plus 15Cmx5M Venda Elast
update public.productos set codigo_barras = '7501048691104' where sku = 'FC-48691104' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tco Mennen Rosa 200G
update public.productos set codigo_barras = '7501035908147' where sku = 'FC-35908147' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Tas Sanit Saba Inv Alas C/10
update public.productos set codigo_barras = '7501019006371' where sku = 'FC-19006371' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Bebin Super 4Opzs Toallitas Humedas
update public.productos set codigo_barras = '619585103015' where sku = 'FC-85103015' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec Tensolastic Plus 5Cmx5M Venda Elasti
update public.productos set codigo_barras = '7501048690800' where sku = 'FC-48690800' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 C D Sensodyne Rapido Alivio 100G
update public.productos set codigo_barras = '7794640171550' where sku = 'FC-40171550' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 77827 Protec Tensolastic Plus 7Cmx5M Venda Elasti
update public.productos set codigo_barras = '7501048690909' where sku = 'FC-48690909' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DIBAR ALCOHOL 125ML ROJO
update public.productos set codigo_barras = '7501868900264' where sku = 'FC-68900264' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DIBAR ALCOHOL ILT ROJO
update public.productos set codigo_barras = '7501868960257' where sku = 'FC-68960257' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 ADIBAR ALCOHOL 250ML. ROJO
update public.productos set codigo_barras = '7501868900226' where sku = 'FC-68900226' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DIBAR ALCOHOL 500ML. ROJO
update public.productos set codigo_barras = '7501868990023' where sku = 'FC-68990023' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 AGUA DESTILADA LA FLOR 1 LT
update public.productos set codigo_barras = '7501677620056' where sku = 'FC-77620056' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 ARNICA MERCURIO
update public.productos set codigo_barras = '3311000003920' where sku = 'FC-00003920' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 CREMA AMARILLA VITACILINA ACLARADORA
update public.productos set codigo_barras = '7506376000260' where sku = 'FC-76000260' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 CREMA ROJA VITACILINA ANTIARRUGAS 100GR
update public.productos set codigo_barras = '7506376000253' where sku = 'FC-76000253' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DIAPRO CONFORT MED C/10
update public.productos set codigo_barras = '7501116800803' where sku = 'FC-16800803' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DABAN ALCOHOL AZUL 125ML.
update public.productos set codigo_barras = '7501186901100' where sku = 'FC-86901100' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 ALCOHOL AZUL 1LT
update public.productos set codigo_barras = '7501868901131' where sku = 'FC-68901131' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 DIBAR ALCOHOL AZUL 250ML
update public.productos set codigo_barras = '7501868901117' where sku = 'FC-68901117' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 ALCOHOL AZUL 500ML
update public.productos set codigo_barras = '7501868901124' where sku = 'FC-68901124' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 BOLO EUROBION TAB C/20
update public.productos set codigo_barras = '7501298223704' where sku = 'FC-98223704' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 LIO 236ML CHTE
update public.productos set codigo_barras = '7501033950100' where sku = 'FC-33950100' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 BASUYE LIQ 236ML FSA
update public.productos set codigo_barras = '7501033950063' where sku = 'FC-33950063' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 ENSURE LIQ 236ML VNLLA
update public.productos set codigo_barras = '7501033950070' where sku = 'FC-33950070' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 LUCERNA LIQ 237ML
update public.productos set codigo_barras = '7501033956133' where sku = 'FC-33956133' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 GLUCERNA SR LIQ 237ML FRESA
update public.productos set codigo_barras = '7501033956140' where sku = 'FC-33956140' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 GOTERO CRISTAL
update public.productos set codigo_barras = '7501507521317' where sku = 'FC-07521317' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 NATURELLA FLUJO MOD C/ALAS C/8
update public.productos set codigo_barras = '7501001157296' where sku = 'FC-01157296' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 NATURELLA NOCHE CON ALAS C/8
update public.productos set codigo_barras = '7501001405335' where sku = 'FC-01405335' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 EDIASURE LIQ 236ML CHTE
update public.productos set codigo_barras = '7501033951008' where sku = 'FC-33951008' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 PEDIASURE LIQ 236ML FSA
update public.productos set codigo_barras = '7501033954245' where sku = 'FC-33954245' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 PEDIASURE LIQ 236ML VNLLA
update public.productos set codigo_barras = '7501033950209' where sku = 'FC-33950209' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 SABA BUENAS NOCHES
update public.productos set codigo_barras = '7501019006623' where sku = 'FC-19006623' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 TB 3 SURT
update public.productos set codigo_barras = '7501065054135' where sku = 'FC-65054135' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 FASELINE PURO 42G
update public.productos set codigo_barras = '7501056323066' where sku = 'FC-56323066' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 VASELINE PURO 85G
update public.productos set codigo_barras = '7501056323059' where sku = 'FC-56323059' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 VAPORUB POM 12G C12 LATAS
update public.productos set codigo_barras = '7501001246730' where sku = 'FC-01246730' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 VICK NAPORUB UNG 100G
update public.productos set codigo_barras = '7590002012475' where sku = 'FC-02012475' and (codigo_barras is null or btrim(codigo_barras) = '');

-- 112558 VICK VAPORUB UNG 50G
update public.productos set codigo_barras = '7590002012468' where sku = 'FC-02012468' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolit
update public.productos set codigo_barras = '7502276040610' where sku = 'FC-76040610' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempr
update public.productos set codigo_barras = '7506460101231' where sku = 'FC-60101231' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Na
update public.productos set codigo_barras = '75010587154871' where sku = 'FC-87154871' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft 
update public.productos set codigo_barras = '7506460101521' where sku = 'FC-60101521' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml
update public.productos set codigo_barras = '75010506134531' where sku = 'FC-06134531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen
update public.productos set codigo_barras = '7501008427330' where sku = 'FC-08427330' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 13
update public.productos set codigo_barras = '7501058792792' where sku = 'FC-58792792' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 E
update public.productos set codigo_barras = '75011650002301' where sku = 'FC-50002301' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Desc
update public.productos set codigo_barras = '7501328979502' where sku = 'FC-28979502' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Des
update public.productos set codigo_barras = '75013289794961' where sku = 'FC-89794961' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% 
update public.productos set codigo_barras = '75010379071241' where sku = 'FC-79071241' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas
update public.productos set codigo_barras = '75022347624171' where sku = 'FC-47624171' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 "Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond
update public.productos set codigo_barras = '7501080950139' where sku = 'FC-80950139' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 N
update public.productos set codigo_barras = '75022088947797' where sku = 'FC-88947797' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performanc
update public.productos set codigo_barras = '75010650959781' where sku = 'FC-50959781' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & I
update public.productos set codigo_barras = '7501080953017' where sku = 'FC-80953017' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra
update public.productos set codigo_barras = '75010954521161' where sku = 'FC-54521161' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $
update public.productos set codigo_barras = '75012895201021' where sku = 'FC-95201021' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.7
update public.productos set codigo_barras = '7501008485316' where sku = 'FC-08485316' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pe
update public.productos set codigo_barras = '7501065095947' where sku = 'FC-65095947' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 /10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10
update public.productos set codigo_barras = '7501095451096' where sku = 'FC-95451096' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 San
update public.productos set codigo_barras = '7501079400556' where sku = 'FC-79400556' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubr
update public.productos set codigo_barras = '7501058793249' where sku = 'FC-58793249' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 1
update public.productos set codigo_barras = '7501095467264' where sku = 'FC-95467264' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 
update public.productos set codigo_barras = '75010587932321' where sku = 'FC-87932321' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer
update public.productos set codigo_barras = '7501008443026' where sku = 'FC-08443026' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue
update public.productos set codigo_barras = '75010075354321' where sku = 'FC-75354321' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 
update public.productos set codigo_barras = '7501008491074' where sku = 'FC-08491074' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 (A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% S
update public.productos set codigo_barras = '7501070612368' where sku = 'FC-70612368' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chin
update public.productos set codigo_barras = '7501088508929' where sku = 'FC-88508929' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Ias
update public.productos set codigo_barras = '75010084335531' where sku = 'FC-84335531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Ho
update public.productos set codigo_barras = '75010723001331' where sku = 'FC-23001331' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71
update public.productos set codigo_barras = '75010885592111' where sku = 'FC-85592111' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/5
update public.productos set codigo_barras = '75010084999001' where sku = 'FC-84999001' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada
update public.productos set codigo_barras = '7501008498798' where sku = 'FC-08498798' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% 
update public.productos set codigo_barras = '7501008491096' where sku = 'FC-08491096' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 
update public.productos set codigo_barras = '75011650003151' where sku = 'FC-50003151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 (A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0%
update public.productos set codigo_barras = '7502224227339' where sku = 'FC-24227339' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.2
update public.productos set codigo_barras = '75010898100381' where sku = 'FC-98100381' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos A
update public.productos set codigo_barras = '7501314704156' where sku = 'FC-14704156' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain
update public.productos set codigo_barras = '7501314704163' where sku = 'FC-14704163' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 43
update public.productos set codigo_barras = '7503008344488' where sku = 'FC-08344488' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 / 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Cen
update public.productos set codigo_barras = '7501065095718' where sku = 'FC-65095718' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Soft Lub Lubricante Original 56.7 Soft Lubricante Original
update public.productos set codigo_barras = '75064601015141' where sku = 'FC-01015141' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12
update public.productos set codigo_barras = '7501008496701' where sku = 'FC-08496701' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /1
update public.productos set codigo_barras = '75022088915491' where sku = 'FC-88915491' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui
update public.productos set codigo_barras = '7503008344747' where sku = 'FC-08344747' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E7401
update public.productos set codigo_barras = '7502208895196' where sku = 'FC-08895196' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 
update public.productos set codigo_barras = '7501089810021' where sku = 'FC-89810021' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante 
update public.productos set codigo_barras = '7506460101378' where sku = 'FC-60101378' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desen
update public.productos set codigo_barras = '75022760403681' where sku = 'FC-60403681' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25
update public.productos set codigo_barras = '75022088923551' where sku = 'FC-88923551' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen 
update public.productos set codigo_barras = '7501125116810' where sku = 'FC-25116810' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre
update public.productos set codigo_barras = '7500435246309' where sku = 'FC-35246309' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecupe
update public.productos set codigo_barras = '75022347640531' where sku = 'FC-47640531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab
update public.productos set codigo_barras = '75010084095411' where sku = 'FC-84095411' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Jr. Jbe Ine 60 Mant Chinotes Chinoin Jr. Jbe Mant Chinotes C
update public.productos set codigo_barras = '75010885097661' where sku = 'FC-85097661' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra
update public.productos set codigo_barras = '75010506247327' where sku = 'FC-06247327' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 18
update public.productos set codigo_barras = '75010084973401' where sku = 'FC-84973401' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax 
update public.productos set codigo_barras = '7501008426944' where sku = 'FC-08426944' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg
update public.productos set codigo_barras = '75012982176351' where sku = 'FC-82176351' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Iri Amp 50.000 Mexico Descto: Mexico Iv Bedoyecta Bausch
update public.productos set codigo_barras = '75011230133021' where sku = 'FC-30133021' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 De
update public.productos set codigo_barras = '7501298217659' where sku = 'FC-98217659' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.5
update public.productos set codigo_barras = '75095466888171' where sku = 'FC-66888171' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate
update public.productos set codigo_barras = '75095466873531' where sku = 'FC-66873531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital 
update public.productos set codigo_barras = '75010486708021' where sku = 'FC-86708021' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 
update public.productos set codigo_barras = '7503003406600' where sku = 'FC-03406600' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0%
update public.productos set codigo_barras = '7503003406501' where sku = 'FC-03406501' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 
update public.productos set codigo_barras = '75030034063651' where sku = 'FC-34063651' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhe
update public.productos set codigo_barras = '75030034062421' where sku = 'FC-34062421' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.
update public.productos set codigo_barras = '75095460689091' where sku = 'FC-60689091' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2
update public.productos set codigo_barras = '75010173629981' where sku = 'FC-73629981' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Lee
update public.productos set codigo_barras = '75064256131681' where sku = 'FC-56131681' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.2
update public.productos set codigo_barras = '75095460009851' where sku = 'FC-60009851' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 
update public.productos set codigo_barras = '75060223273451' where sku = 'FC-23273451' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Desc
update public.productos set codigo_barras = '75010275163051' where sku = 'FC-75163051' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0
update public.productos set codigo_barras = '7501027512574' where sku = 'FC-27512574' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* 
update public.productos set codigo_barras = '75010275125811' where sku = 'FC-75125811' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Q
update public.productos set codigo_barras = '75030034067851' where sku = 'FC-34067851' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Fa
update public.productos set codigo_barras = '7501048623006' where sku = 'FC-48623006' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa 
update public.productos set codigo_barras = '75060223272151' where sku = 'FC-23272151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.
update public.productos set codigo_barras = '7501868910041' where sku = 'FC-68910041' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70
update public.productos set codigo_barras = '75018689100101' where sku = 'FC-89100101' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66
update public.productos set codigo_barras = '75030034067301' where sku = 'FC-34067301' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Q
update public.productos set codigo_barras = '75030034067471' where sku = 'FC-34067471' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.
update public.productos set codigo_barras = '75030034067781' where sku = 'FC-34067781' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dib
update public.productos set codigo_barras = '7501868910034' where sku = 'FC-68910034' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Crema Dent Colgate Total Colgate Palmolive $ Colgate Total C
update public.productos set codigo_barras = '75095466534951' where sku = 'FC-66534951' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial P
update public.productos set codigo_barras = '75010483510531' where sku = 'FC-83510531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 1
update public.productos set codigo_barras = '7501868900127' where sku = 'FC-68900127' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 E
update public.productos set codigo_barras = '7501868900134' where sku = 'FC-68900134' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi De
update public.productos set codigo_barras = '7501250882017' where sku = 'FC-50882017' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa
update public.productos set codigo_barras = '75012508820243' where sku = 'FC-08820243' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cre Vitacilina Humectante 100 Gr Vitacilina Humectante
update public.productos set codigo_barras = '7506376000277' where sku = 'FC-76000277' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick 
update public.productos set codigo_barras = '75004351444145' where sku = 'FC-51444145' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxige
update public.productos set codigo_barras = '75010483351691' where sku = 'FC-83351691' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua O
update public.productos set codigo_barras = '75010483351381' where sku = 'FC-83351381' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 
update public.productos set codigo_barras = '7501033956775' where sku = 'FC-33956775' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr6
update public.productos set codigo_barras = '7501033961373' where sku = 'FC-33961373' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenad
update public.productos set codigo_barras = '7501048335305' where sku = 'FC-48335305' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialy
update public.productos set codigo_barras = '7501033954740' where sku = 'FC-33954740' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360
update public.productos set codigo_barras = '7501059225411' where sku = 'FC-59225411' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 3
update public.productos set codigo_barras = '75064751067711' where sku = 'FC-51067711' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Nestum Probioticos Marcas Nestle Avena 270 Nestum Probiotico
update public.productos set codigo_barras = '75010586167151' where sku = 'FC-86167151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rin
update public.productos set codigo_barras = '75010592821171' where sku = 'FC-92821171' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Lec
update public.productos set codigo_barras = '7501058611420' where sku = 'FC-58611420' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1
update public.productos set codigo_barras = '75064751078461' where sku = 'FC-51078461' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Ne
update public.productos set codigo_barras = '75064751078531' where sku = 'FC-51078531' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recole
update public.productos set codigo_barras = '75065529003221' where sku = 'FC-29003221' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.0
update public.productos set codigo_barras = '75011251448511' where sku = 'FC-51448511' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electroli
update public.productos set codigo_barras = '7501125104411' where sku = 'FC-25104411' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit E
update public.productos set codigo_barras = '7501125149221' where sku = 'FC-25149221' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20
update public.productos set codigo_barras = '7501125104268' where sku = 'FC-25104268' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0
update public.productos set codigo_barras = '75011251747971' where sku = 'FC-51747971' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec 
update public.productos set codigo_barras = '7501943471900' where sku = 'FC-43471900' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Qu
update public.productos set codigo_barras = '75030034064021' where sku = 'FC-34064021' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubr
update public.productos set codigo_barras = '7502214983153' where sku = 'FC-14983153' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 
update public.productos set codigo_barras = '7501943454811' where sku = 'FC-43454811' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence 'U
update public.productos set codigo_barras = '75022149824391' where sku = 'FC-49824391' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cond Prudence 'Ull Sensitive C/3 Dkt Cond Prudence 'Ull Sens
update public.productos set codigo_barras = '7502214985348' where sku = 'FC-14985348' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Ple
update public.productos set codigo_barras = '75022149853867' where sku = 'FC-49853867' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mex
update public.productos set codigo_barras = '75022149824911' where sku = 'FC-49824911' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cond Prudence Chicle C/E Idkt Cond Prudence Chicle
update public.productos set codigo_barras = '7502214985805' where sku = 'FC-14985805' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Lubricante Prudence Natural 75 Ml Lubricante Prudence Natura
update public.productos set codigo_barras = '7502214983726' where sku = 'FC-14983726' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond 
update public.productos set codigo_barras = '75022149824771' where sku = 'FC-49824771' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 D
update public.productos set codigo_barras = '75022358203691' where sku = 'FC-58203691' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 
update public.productos set codigo_barras = '7502214982514' where sku = 'FC-14982514' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa P
update public.productos set codigo_barras = '75010545079011' where sku = 'FC-45079011' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Pruden
update public.productos set codigo_barras = '7502214980596' where sku = 'FC-14980596' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Co
update public.productos set codigo_barras = '75022149800151' where sku = 'FC-49800151' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jar
update public.productos set codigo_barras = '7500462746605' where sku = 'FC-62746605' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 5
update public.productos set codigo_barras = '75010545045281' where sku = 'FC-45045281' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 5
update public.productos set codigo_barras = '7501054504870' where sku = 'FC-54504870' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 
update public.productos set codigo_barras = '7506452400212' where sku = 'FC-52400212' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00
update public.productos set codigo_barras = '75064524004581' where sku = 'FC-24004581' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa 
update public.productos set codigo_barras = '75064256034041' where sku = 'FC-56034041' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanill
update public.productos set codigo_barras = '75010221042481' where sku = 'FC-21042481' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 , Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 
update public.productos set codigo_barras = '7506452400267' where sku = 'FC-52400267' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.2
update public.productos set codigo_barras = '7500462746612' where sku = 'FC-62746612' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal
update public.productos set codigo_barras = '7506452400038' where sku = 'FC-52400038' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotiu
update public.productos set codigo_barras = '7500462746698' where sku = 'FC-62746698' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Poroso Arnica Parche Leon Bde Poroso Arnica Parche
update public.productos set codigo_barras = '75010545307181' where sku = 'FC-45307181' and (codigo_barras is null or btrim(codigo_barras) = '');

-- FL-080826 Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fuca
update public.productos set codigo_barras = '7500462746643' where sku = 'FC-62746643' and (codigo_barras is null or btrim(codigo_barras) = '');


-- Verificación pistola POS (debe coincidir con filas con barcode en Excel)
select count(*) as productos_con_barcode
from public.productos
where codigo_barras is not null and btrim(codigo_barras) <> '';

-- ── actualizar_proveedor_lotes_tickets.sql ──
-- FarmaCapital — Proveedor del lote = tienda de compra (ticket)
-- Mapeos únicos: 627 | Tiendas: 6
-- Requiere antes: sql/patch_proveedor_tienda_en_lotes.sql


-- 1) Catálogo de tiendas
select public.fc_resolver_proveedor_tienda('Bodega F-42 Ejidos del Moral'::text);
select public.fc_resolver_proveedor_tienda('El Surtidor de su Farmacia'::text);
select public.fc_resolver_proveedor_tienda('Equilibrio Farmacéutico'::text);
select public.fc_resolver_proveedor_tienda('Farma MX'::text);
select public.fc_resolver_proveedor_tienda('FarmaLive'::text);
select public.fc_resolver_proveedor_tienda('IFC F8 Tienda'::text);

-- 2) Mapeo SKU + lote → tienda
create temp table _fc_proveedor_lote (
  sku text not null,
  numero_lote text not null,
  tienda text not null,
  primary key (sku, numero_lote)
) on commit drop;

insert into _fc_proveedor_lote (sku, numero_lote, tienda) values
  ('FC-F967863B', '5M297', 'Equilibrio Farmacéutico'),
  ('FC-C721E8D7', 'U26M041', 'Equilibrio Farmacéutico'),
  ('FC-B25B4654', 'U26D009', 'Equilibrio Farmacéutico'),
  ('FC-ACA2A2F6', 'AB25002', 'Equilibrio Farmacéutico'),
  ('FC-174824A0', '790055', 'Equilibrio Farmacéutico'),
  ('FC-D5AC44CA', 'C6227', 'Equilibrio Farmacéutico'),
  ('FC-9A4E4C31', 'E25N206', 'Equilibrio Farmacéutico'),
  ('FC-40CE757D', '256934', 'Equilibrio Farmacéutico'),
  ('FC-B18E386A', '255417', 'Equilibrio Farmacéutico'),
  ('FC-1DA570E3', 'SB2642', 'Equilibrio Farmacéutico'),
  ('FC-A455EE80', '256533', 'Equilibrio Farmacéutico'),
  ('FC-E374F23E', '255233', 'Equilibrio Farmacéutico'),
  ('FC-8FB65B79', '263020', 'Equilibrio Farmacéutico'),
  ('FC-2EDC6E3B', '254942', 'Equilibrio Farmacéutico'),
  ('FC-C101D5B1', '26E039', 'Equilibrio Farmacéutico'),
  ('FC-7AF7ACB5', '251303', 'Equilibrio Farmacéutico'),
  ('FC-CF18C740', 'U26E412', 'Equilibrio Farmacéutico'),
  ('FC-E4EFC4C2', '255646', 'Equilibrio Farmacéutico'),
  ('FC-6EAD98A9', '260152', 'Equilibrio Farmacéutico'),
  ('FC-CF719C07', 'E2605191', 'Equilibrio Farmacéutico'),
  ('FC-60F627D5', 'B25N402', 'Equilibrio Farmacéutico'),
  ('FC-48F732CF', 'E2603101', 'Equilibrio Farmacéutico'),
  ('FC-72C28BC1', '5F0981', 'Equilibrio Farmacéutico'),
  ('FC-443C330E', '256911', 'Equilibrio Farmacéutico'),
  ('FC-492D652F', '261277', 'Equilibrio Farmacéutico'),
  ('FC-86A95D07', '2512921', 'Equilibrio Farmacéutico'),
  ('FC-697EEAD0', '264239', 'Equilibrio Farmacéutico'),
  ('FC-830BF3FB', 'H26020022', 'Equilibrio Farmacéutico'),
  ('FC-F3E734A0', '252890', 'Equilibrio Farmacéutico'),
  ('FC-74A5ABEE', 'U26V028', 'Equilibrio Farmacéutico'),
  ('FC-AEA8C8DA', '440096', 'Equilibrio Farmacéutico'),
  ('FC-2005DD57', '26A067', 'Equilibrio Farmacéutico'),
  ('FC-B4477A00', '262066', 'Equilibrio Farmacéutico'),
  ('FC-85BDBD3D', 'E2512603', 'Equilibrio Farmacéutico'),
  ('FC-7AA38F97', '256072', 'Equilibrio Farmacéutico'),
  ('FC-9538F7D6', '251778', 'Equilibrio Farmacéutico'),
  ('FC-01B2F362', '255772', 'Equilibrio Farmacéutico'),
  ('FC-50587FA6', 'S5721', 'Equilibrio Farmacéutico'),
  ('FC-B72A6420', '257070', 'Equilibrio Farmacéutico'),
  ('FC-D9391288', '251985', 'Equilibrio Farmacéutico'),
  ('FC-41339950', 'U26E021', 'Equilibrio Farmacéutico'),
  ('FC-E6112F15', '2630655', 'Equilibrio Farmacéutico'),
  ('FC-F183C6E9', '126A003', 'Equilibrio Farmacéutico'),
  ('FC-A0D320D1', 'C0925787', 'Equilibrio Farmacéutico'),
  ('FC-95779436', '0380626', 'Equilibrio Farmacéutico'),
  ('FC-4C621D07', 'S5406', 'Equilibrio Farmacéutico'),
  ('FC-022543CD', 'T6079', 'Equilibrio Farmacéutico'),
  ('FC-64EB83AA', '125T007', 'Equilibrio Farmacéutico'),
  ('FC-D210172A', '126H505', 'Equilibrio Farmacéutico'),
  ('FC-7F90064A', '125S506', 'Equilibrio Farmacéutico'),
  ('FC-F82A6E4B', 'Q0126016', 'Equilibrio Farmacéutico'),
  ('FC-5F30F9D4', '261979', 'Equilibrio Farmacéutico'),
  ('FC-7D1D9857', '6AM103C', 'Equilibrio Farmacéutico'),
  ('FC-516C2E89', '257270', 'Equilibrio Farmacéutico'),
  ('FC-05965071', 'B2602071', 'Equilibrio Farmacéutico'),
  ('FC-930E0B1B', 'S6252', 'Equilibrio Farmacéutico'),
  ('FC-405A75E3', 'U26F085', 'Equilibrio Farmacéutico'),
  ('FC-D06E54FE', 'T6315', 'Equilibrio Farmacéutico'),
  ('FC-3A4583F3', '125U014', 'Equilibrio Farmacéutico'),
  ('FC-F22C72BE', '263412', 'Equilibrio Farmacéutico'),
  ('FC-F48FF7EF', '260027', 'Equilibrio Farmacéutico'),
  ('FC-4BD80686', '256213', 'Equilibrio Farmacéutico'),
  ('FC-974EE5FD', '26240167', 'Equilibrio Farmacéutico'),
  ('FC-0E0A9E42', '256303', 'Equilibrio Farmacéutico'),
  ('FC-6519183A', '260677', 'Equilibrio Farmacéutico'),
  ('FC-DDFBABDF', '257267', 'Equilibrio Farmacéutico'),
  ('FC-C9F4ACCC', 'CNF2656', 'Equilibrio Farmacéutico'),
  ('FC-17376CAE', '26051262', 'Equilibrio Farmacéutico'),
  ('FC-369D1689', '255831', 'Equilibrio Farmacéutico'),
  ('FC-B69FCBF4', 'S19964', 'Equilibrio Farmacéutico'),
  ('FC-F4E9C71F', 'Q626334', 'Equilibrio Farmacéutico'),
  ('FC-428A228F', '26240134', 'Equilibrio Farmacéutico'),
  ('FC-FD845E68', 'U26F020', 'Equilibrio Farmacéutico'),
  ('FC-B2123139', '650086', 'Equilibrio Farmacéutico'),
  ('FC-11294615', '26F511', 'Equilibrio Farmacéutico'),
  ('FC-1FEA2FB7', '25T514', 'Equilibrio Farmacéutico'),
  ('FC-AA905BF7', 'S2341670', 'Equilibrio Farmacéutico'),
  ('FC-AE5EEDF7', '261013', 'Equilibrio Farmacéutico'),
  ('FC-F8691496', '261127', 'Equilibrio Farmacéutico'),
  ('FC-6074BB64', '251660', 'Equilibrio Farmacéutico'),
  ('FC-E826D304', 'B25D203', 'Equilibrio Farmacéutico'),
  ('FC-4F737E93', 'LE2626', 'Equilibrio Farmacéutico'),
  ('FC-DB3B2584', '26C2109', 'Equilibrio Farmacéutico'),
  ('FC-22B18244', 'J25T017', 'Equilibrio Farmacéutico'),
  ('FC-4A0245DA', '5LM125B', 'Equilibrio Farmacéutico'),
  ('FC-29670370', '444AA', 'Equilibrio Farmacéutico'),
  ('FC-69A3C416', 'LB2633', 'Equilibrio Farmacéutico'),
  ('FC-F817BC3A', '262040', 'Equilibrio Farmacéutico'),
  ('FC-447B30F9', 'C26F206', 'Equilibrio Farmacéutico'),
  ('FC-1CF27DC9', '26040978', 'Equilibrio Farmacéutico'),
  ('FC-3CAA7C5C', '2605279', 'Equilibrio Farmacéutico'),
  ('FC-E6B50AC3', '6EM120A', 'Equilibrio Farmacéutico'),
  ('FC-6B2ADEE9', 'C635', 'Equilibrio Farmacéutico'),
  ('FC-DB4A39AE', '29911', 'Equilibrio Farmacéutico'),
  ('FC-FA3D96E6', 'U0265', 'Equilibrio Farmacéutico'),
  ('FC-63975795', 'U26M335', 'Equilibrio Farmacéutico'),
  ('FC-C6C20517', '257237', 'Equilibrio Farmacéutico'),
  ('FC-58DB24C4', '261052', 'Equilibrio Farmacéutico'),
  ('FC-1FFBB505', 'SK2102', 'Equilibrio Farmacéutico'),
  ('FC-A909ABC0', '251614', 'Equilibrio Farmacéutico'),
  ('FC-82F88FED', '6AN062A', 'Equilibrio Farmacéutico'),
  ('FC-6C2878CF', '25XY004', 'Equilibrio Farmacéutico'),
  ('FC-3B001F9B', '5EM451B', 'Equilibrio Farmacéutico'),
  ('FC-B25094C4', 'SK2106', 'Equilibrio Farmacéutico'),
  ('FC-26EA40A4', 'RRC179', 'Equilibrio Farmacéutico'),
  ('FC-885F2723', '7220526', 'Equilibrio Farmacéutico'),
  ('FC-DF8ADDAB', '256110', 'Equilibrio Farmacéutico'),
  ('FC-50AC2C82', '256664', 'Equilibrio Farmacéutico'),
  ('FC-281E0F22', 'C26E206', 'Equilibrio Farmacéutico'),
  ('FC-9F67BB73', 'S6117', 'Equilibrio Farmacéutico'),
  ('FC-4FD413D2', '6S032', 'Equilibrio Farmacéutico'),
  ('FC-0BDE9283', 'CLOPHIVEN', 'Equilibrio Farmacéutico'),
  ('FC-97BEFA1A', '5MM301A', 'Equilibrio Farmacéutico'),
  ('FC-DEAF33B0', '262631', 'Equilibrio Farmacéutico'),
  ('FC-77FE5C83', '26061504', 'Equilibrio Farmacéutico'),
  ('FC-C636D8EA', 'J25G109', 'Equilibrio Farmacéutico'),
  ('FC-44B6751A', 'B26031S', 'Equilibrio Farmacéutico'),
  ('FC-9B93AC4C', '256866', 'Equilibrio Farmacéutico'),
  ('FC-2001A890', '26240110', 'Equilibrio Farmacéutico'),
  ('FC-DE106642', '26240043', 'Equilibrio Farmacéutico'),
  ('FC-BE76D409', 'J25N044', 'Equilibrio Farmacéutico'),
  ('FC-07F04F88', 'J25D063', 'Equilibrio Farmacéutico'),
  ('FC-357D4A17', 'J25D018', 'Equilibrio Farmacéutico'),
  ('FC-5D9DFA3D', 'SK2094', 'Equilibrio Farmacéutico'),
  ('FC-E9C38DC4', 'U26F042', 'Equilibrio Farmacéutico'),
  ('FC-347A49C7', '25T515', 'Equilibrio Farmacéutico'),
  ('FC-E4BE37BE', 'U26E117', 'Equilibrio Farmacéutico'),
  ('FC-1751468C', '5J1920', 'Equilibrio Farmacéutico'),
  ('FC-6898B64F', '0226330', 'Equilibrio Farmacéutico'),
  ('FC-CD261CD5', '26140712', 'Equilibrio Farmacéutico'),
  ('FC-5C8C9C11', 'U0397', 'Equilibrio Farmacéutico'),
  ('FC-A23F290E', 'SD26112', 'Equilibrio Farmacéutico'),
  ('FC-5885E577', '610426', 'Equilibrio Farmacéutico'),
  ('FC-3D0F54B7', 'M26052', 'Equilibrio Farmacéutico'),
  ('FC-F7A2CACF', 'SB01DC', 'Equilibrio Farmacéutico'),
  ('FC-50D044FF', '260373', 'Equilibrio Farmacéutico'),
  ('FC-E535DE28', 'SB2664', 'Equilibrio Farmacéutico'),
  ('FC-1321B34F', 'SK2109', 'Equilibrio Farmacéutico'),
  ('FC-1AE9D7E6', '26340160', 'Equilibrio Farmacéutico'),
  ('FC-3E863E37', '261001', 'Equilibrio Farmacéutico'),
  ('FC-9ABFB996', 'B26050', 'Equilibrio Farmacéutico'),
  ('FC-9A37D44A', '260066', 'Equilibrio Farmacéutico'),
  ('FC-1BF03D35', '2601201', 'Equilibrio Farmacéutico'),
  ('FC-5BC5F234', 'U25N344', 'Equilibrio Farmacéutico'),
  ('FC-A2B284E0', '26161P', 'Equilibrio Farmacéutico'),
  ('FC-2E79C2D8', 'B25T405', 'Equilibrio Farmacéutico'),
  ('FC-28A424E5', '261313', 'Equilibrio Farmacéutico'),
  ('FC-52D2A43A', 'R25126048', 'Equilibrio Farmacéutico'),
  ('FC-3D0ED22B', 'R2506781', 'Equilibrio Farmacéutico'),
  ('FC-04D83B46', '6D064G', 'Equilibrio Farmacéutico'),
  ('FC-D11D586A', 'L2K501', 'Equilibrio Farmacéutico'),
  ('FC-53506FA4', '6N50A', 'Equilibrio Farmacéutico'),
  ('FC-F7DB080D', 'SC2617', 'Equilibrio Farmacéutico'),
  ('FC-FD92D114', 'SC2622', 'Equilibrio Farmacéutico'),
  ('FC-57925EF3', '710026', 'Equilibrio Farmacéutico'),
  ('FC-AA7B0686', '26DP32', 'Equilibrio Farmacéutico'),
  ('FC-B3B8F9BB', 'RD065', 'Equilibrio Farmacéutico'),
  ('FC-EADF1484', 'C50366', 'Equilibrio Farmacéutico'),
  ('FC-262F2A30', 'U25U621', 'Equilibrio Farmacéutico'),
  ('FC-1DAD5EF1', '2513407', 'Equilibrio Farmacéutico'),
  ('FC-BDB2E087', 'U26E239', 'Equilibrio Farmacéutico'),
  ('FC-759A5EF9', '260486', 'Equilibrio Farmacéutico'),
  ('FC-52844825', 'TK-77827-1', 'Bodega F-42 Ejidos del Moral'),
  ('FC-52933307', 'TK-77827-2', 'Bodega F-42 Ejidos del Moral'),
  ('FC-27250612', 'TK-77827-3', 'Bodega F-42 Ejidos del Moral'),
  ('FC-27286017', 'TK-77827-4', 'Bodega F-42 Ejidos del Moral'),
  ('FC-52876406', 'TK-77827-5', 'Bodega F-42 Ejidos del Moral'),
  ('FC-30622622', 'TK-77827-6', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06213906', 'TK-77827-7', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93037806', 'TK-77827-8', 'Bodega F-42 Ejidos del Moral'),
  ('FC-55280956', 'TK-77827-9', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93025919', 'TK-77827-10', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93022567', 'TK-77827-11', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06244795', 'TK-77827-12', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75076009', 'TK-77827-13', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93025797', 'TK-77827-14', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93038223', 'TK-77827-15', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75062897', 'TK-77827-16', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06245686', 'TK-77827-17', 'Bodega F-42 Ejidos del Moral'),
  ('FC-93025865', 'TK-77827-18', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22105207', 'TK-77827-19', 'Bodega F-42 Ejidos del Moral'),
  ('FC-38891190', 'TK-77827-20', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75062927', 'TK-77827-21', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40036965', 'TK-77827-22', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40004643', 'TK-77827-23', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22150801', 'TK-77827-24', 'Bodega F-42 Ejidos del Moral'),
  ('FC-25605514', 'TK-77827-25', 'Bodega F-42 Ejidos del Moral'),
  ('FC-14119032', 'TK-77827-26', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06230507', 'TK-77827-28', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22150092', 'TK-77827-29', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22111352', 'TK-77827-30', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75069223', 'TK-77827-31', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46059556', 'TK-77827-32', 'Bodega F-42 Ejidos del Moral'),
  ('FC-67905186', 'TK-77827-33', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46683133', 'TK-77827-34', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06241206', 'TK-77827-35', 'Bodega F-42 Ejidos del Moral'),
  ('FC-43489004', 'TK-77827-36', 'Bodega F-42 Ejidos del Moral'),
  ('FC-42326414', 'TK-77827-37', 'Bodega F-42 Ejidos del Moral'),
  ('FC-76000284', 'TK-77827-38', 'Bodega F-42 Ejidos del Moral'),
  ('FC-82790504', 'TK-77827-39', 'Bodega F-42 Ejidos del Moral'),
  ('FC-45722547', 'TK-77827-40', 'Bodega F-42 Ejidos del Moral'),
  ('FC-67905131', 'TK-77827-41', 'Bodega F-42 Ejidos del Moral'),
  ('FC-21012303', 'TK-77827-42', 'Bodega F-42 Ejidos del Moral'),
  ('FC-14121782', 'TK-77827-43', 'Bodega F-42 Ejidos del Moral'),
  ('FC-25652716', 'TK-77827-44', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06248052', 'TK-77827-45', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06248045', 'TK-77827-46', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35911208', 'TK-77827-47', 'Bodega F-42 Ejidos del Moral'),
  ('FC-08837311', 'TK-77827-48', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06209862', 'TK-77827-49', 'Bodega F-42 Ejidos del Moral'),
  ('FC-43489165', 'TK-77827-50', 'Bodega F-42 Ejidos del Moral'),
  ('FC-84900280', 'TK-77827-51', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06226852', 'TK-77827-52', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46657035', 'TK-77827-53', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56330378', 'TK-77827-54', 'Bodega F-42 Ejidos del Moral'),
  ('FC-76040436', 'TK-77827-55', 'Bodega F-42 Ejidos del Moral'),
  ('FC-61113000', 'TK-77827-56', 'Bodega F-42 Ejidos del Moral'),
  ('FC-61123009', 'TK-77827-57', 'Bodega F-42 Ejidos del Moral'),
  ('FC-41500096', 'TK-77827-58', 'Bodega F-42 Ejidos del Moral'),
  ('FC-20500201', 'TK-77827-59', 'Bodega F-42 Ejidos del Moral'),
  ('FC-72300171', 'TK-77827-60', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06217461', 'TK-77827-61', 'Bodega F-42 Ejidos del Moral'),
  ('FC-82740011', 'TK-77827-62', 'Bodega F-42 Ejidos del Moral'),
  ('FC-52910971', 'TK-77827-63', 'Bodega F-42 Ejidos del Moral'),
  ('FC-52816297', 'TK-77827-64', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40025839', 'TK-77827-66', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40030338', 'TK-77827-68', 'Bodega F-42 Ejidos del Moral'),
  ('FC-45720550', 'TK-77827-69', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92511261', 'TK-77827-70', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92509213', 'TK-77827-71', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06257597', 'TK-77827-73', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46073156', 'TK-77827-74', 'Bodega F-42 Ejidos del Moral'),
  ('FC-20500171', 'TK-77827-75', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35155922', 'TK-77827-76', 'Bodega F-42 Ejidos del Moral'),
  ('FC-07457826', 'TK-77827-78', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56340131', 'TK-77827-79', 'Bodega F-42 Ejidos del Moral'),
  ('FC-01165321', 'TK-77827-80', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06249783', 'TK-77827-81', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56360429', 'TK-77827-82', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56340025', 'TK-77827-83', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56342227', 'TK-77827-84', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06249776', 'TK-77827-85', 'Bodega F-42 Ejidos del Moral'),
  ('FC-01303454', 'TK-77827-86', 'Bodega F-42 Ejidos del Moral'),
  ('FC-07457796', 'TK-77827-87', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35155847', 'TK-77827-89', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06249240', 'TK-77827-90', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06249226', 'TK-77827-91', 'Bodega F-42 Ejidos del Moral'),
  ('FC-24511629', 'TK-77827-92', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06234062', 'TK-77827-93', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56342258', 'TK-77827-94', 'Bodega F-42 Ejidos del Moral'),
  ('FC-61111501', 'TK-77827-95', 'Bodega F-42 Ejidos del Moral'),
  ('FC-61124013', 'TK-77827-96', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56340124', 'TK-77827-97', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35020008', 'TK-77827-98', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35169035', 'TK-77827-99', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35168991', 'TK-77827-100', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35231237', 'TK-77827-101', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92504539', 'TK-77827-102', 'Bodega F-42 Ejidos del Moral'),
  ('FC-38312374', 'TK-77827-103', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35231244', 'TK-77827-104', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35020077', 'TK-77827-105', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92503558', 'TK-77827-106', 'Bodega F-42 Ejidos del Moral'),
  ('FC-99425580', 'TK-77827-107', 'Bodega F-42 Ejidos del Moral'),
  ('FC-99428024', 'TK-77827-108', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46073040', 'TK-77827-109', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46073033', 'TK-77827-110', 'Bodega F-42 Ejidos del Moral'),
  ('FC-54073302', 'TK-77827-111', 'Bodega F-42 Ejidos del Moral'),
  ('FC-24511711', 'TK-77827-112', 'Bodega F-42 Ejidos del Moral'),
  ('FC-24511636', 'TK-77827-113', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75001865', 'TK-77827-114', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46655055', 'TK-77827-115', 'Bodega F-42 Ejidos del Moral'),
  ('FC-06247468', 'TK-77827-116', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92506601', 'TK-77827-117', 'Bodega F-42 Ejidos del Moral'),
  ('FC-86494262', 'TK-77827-118', 'Bodega F-42 Ejidos del Moral'),
  ('FC-92506045', 'TK-77827-119', 'Bodega F-42 Ejidos del Moral'),
  ('FC-84431050', 'TK-77827-120', 'Bodega F-42 Ejidos del Moral'),
  ('FC-45720567', 'TK-77827-121', 'Bodega F-42 Ejidos del Moral'),
  ('FC-84437151', 'TK-77827-122', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48640775', 'TK-77827-123', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48640799', 'TK-77827-124', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46640629', 'TK-77827-125', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48640751', 'TK-77827-126', 'Bodega F-42 Ejidos del Moral'),
  ('FC-26462078', 'TK-77827-127', 'Bodega F-42 Ejidos del Moral'),
  ('FC-54500216', 'TK-77827-128', 'Bodega F-42 Ejidos del Moral'),
  ('FC-75064938', 'TK-77827-129', 'Bodega F-42 Ejidos del Moral'),
  ('FC-20501673', 'TK-77827-130', 'Bodega F-42 Ejidos del Moral'),
  ('FC-08802838', 'TK-77827-131', 'Bodega F-42 Ejidos del Moral'),
  ('FC-36040450', 'TK-77827-133', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56330309', 'TK-77827-134', 'Bodega F-42 Ejidos del Moral'),
  ('FC-42270027', 'TK-77827-135', 'Bodega F-42 Ejidos del Moral'),
  ('FC-00942760', 'TK-77827-136', 'Bodega F-42 Ejidos del Moral'),
  ('FC-54558682', 'TK-77827-137', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40030963', 'TK-77827-138', 'Bodega F-42 Ejidos del Moral'),
  ('FC-26462061', 'TK-77827-139', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35469151', 'TK-77827-140', 'Bodega F-42 Ejidos del Moral'),
  ('FC-36032776', 'TK-77827-141', 'Bodega F-42 Ejidos del Moral'),
  ('FC-07502441', 'TK-77827-142', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46655079', 'TK-77827-143', 'Bodega F-42 Ejidos del Moral'),
  ('FC-82790016', 'TK-77827-144', 'Bodega F-42 Ejidos del Moral'),
  ('FC-36041402', 'TK-77827-145', 'Bodega F-42 Ejidos del Moral'),
  ('FC-07528939', 'TK-77827-146', 'Bodega F-42 Ejidos del Moral'),
  ('FC-31244486', 'TK-77827-147', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46074504', 'TK-77827-149', 'Bodega F-42 Ejidos del Moral'),
  ('FC-36033735', 'TK-77827-150', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46650708', 'TK-77827-151', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22133286', 'TK-77827-152', 'Bodega F-42 Ejidos del Moral'),
  ('FC-86472048', 'TK-77827-153', 'Bodega F-42 Ejidos del Moral'),
  ('FC-09498091', 'TK-77827-154', 'Bodega F-42 Ejidos del Moral'),
  ('FC-95129166', 'TK-77827-155', 'Bodega F-42 Ejidos del Moral'),
  ('FC-42417644', 'TK-77827-156', 'Bodega F-42 Ejidos del Moral'),
  ('FC-09419324', 'TK-77827-157', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40013898', 'TK-77827-158', 'Bodega F-42 Ejidos del Moral'),
  ('FC-54549819', 'TK-77827-159', 'Bodega F-42 Ejidos del Moral'),
  ('FC-17360604', 'TK-77827-160', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46072050', 'TK-77827-161', 'Bodega F-42 Ejidos del Moral'),
  ('FC-22150221', 'TK-77827-162', 'Bodega F-42 Ejidos del Moral'),
  ('FC-20501765', 'TK-77827-163', 'Bodega F-42 Ejidos del Moral'),
  ('FC-56326142', 'TK-77827-164', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48691005', 'TK-77827-165', 'Bodega F-42 Ejidos del Moral'),
  ('FC-31976394', 'TK-77827-166', 'Bodega F-42 Ejidos del Moral'),
  ('FC-43427754', 'TK-77827-167', 'Bodega F-42 Ejidos del Moral'),
  ('FC-31887928', 'TK-77827-169', 'Bodega F-42 Ejidos del Moral'),
  ('FC-54503095', 'TK-77827-170', 'Bodega F-42 Ejidos del Moral'),
  ('FC-85800198', 'TK-77827-171', 'Bodega F-42 Ejidos del Moral'),
  ('FC-72629012', 'TK-77827-172', 'Bodega F-42 Ejidos del Moral'),
  ('FC-10974329', 'TK-77827-173', 'Bodega F-42 Ejidos del Moral'),
  ('FC-00701992', 'TK-77827-174', 'Bodega F-42 Ejidos del Moral'),
  ('FC-46655727', 'TK-77827-175', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35908130', 'TK-77827-177', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48691104', 'TK-77827-178', 'Bodega F-42 Ejidos del Moral'),
  ('FC-35908147', 'TK-77827-179', 'Bodega F-42 Ejidos del Moral'),
  ('FC-19006371', 'TK-77827-180', 'Bodega F-42 Ejidos del Moral'),
  ('FC-85103015', 'TK-77827-181', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48690800', 'TK-77827-182', 'Bodega F-42 Ejidos del Moral'),
  ('FC-40171550', 'TK-77827-183', 'Bodega F-42 Ejidos del Moral'),
  ('FC-48690909', 'TK-77827-184', 'Bodega F-42 Ejidos del Moral'),
  ('FC-68900264', 'TK-112558-1', 'El Surtidor de su Farmacia'),
  ('FC-68960257', 'TK-112558-2', 'El Surtidor de su Farmacia'),
  ('FC-68900226', 'TK-112558-3', 'El Surtidor de su Farmacia'),
  ('FC-68990023', 'TK-112558-4', 'El Surtidor de su Farmacia'),
  ('FC-77620056', 'TK-112558-5', 'El Surtidor de su Farmacia'),
  ('FC-00003920', 'TK-112558-6', 'El Surtidor de su Farmacia'),
  ('FC-76000260', 'TK-112558-7', 'El Surtidor de su Farmacia'),
  ('FC-76000253', 'TK-112558-8', 'El Surtidor de su Farmacia'),
  ('FC-16800803', 'TK-112558-9', 'El Surtidor de su Farmacia'),
  ('FC-86901100', 'TK-112558-10', 'El Surtidor de su Farmacia'),
  ('FC-68901131', 'TK-112558-11', 'El Surtidor de su Farmacia'),
  ('FC-68901117', 'TK-112558-12', 'El Surtidor de su Farmacia'),
  ('FC-68901124', 'TK-112558-13', 'El Surtidor de su Farmacia'),
  ('FC-98223704', 'TK-112558-14', 'El Surtidor de su Farmacia'),
  ('FC-33950100', 'TK-112558-15', 'El Surtidor de su Farmacia'),
  ('FC-33950063', 'TK-112558-16', 'El Surtidor de su Farmacia'),
  ('FC-33950070', 'TK-112558-17', 'El Surtidor de su Farmacia'),
  ('FC-33956133', 'TK-112558-18', 'El Surtidor de su Farmacia'),
  ('FC-33956140', 'TK-112558-19', 'El Surtidor de su Farmacia'),
  ('FC-07521317', 'TK-112558-20', 'El Surtidor de su Farmacia'),
  ('FC-01157296', 'TK-112558-21', 'El Surtidor de su Farmacia'),
  ('FC-01405335', 'TK-112558-22', 'El Surtidor de su Farmacia'),
  ('FC-33951008', 'TK-112558-23', 'El Surtidor de su Farmacia'),
  ('FC-33954245', 'TK-112558-24', 'El Surtidor de su Farmacia'),
  ('FC-33950209', 'TK-112558-25', 'El Surtidor de su Farmacia'),
  ('FC-19006623', 'TK-112558-26', 'El Surtidor de su Farmacia'),
  ('FC-65054135', 'TK-112558-27', 'El Surtidor de su Farmacia'),
  ('FC-56323066', 'TK-112558-28', 'El Surtidor de su Farmacia'),
  ('FC-56323059', 'TK-112558-29', 'El Surtidor de su Farmacia'),
  ('FC-01246730', 'TK-112558-30', 'El Surtidor de su Farmacia'),
  ('FC-02012475', 'TK-112558-31', 'El Surtidor de su Farmacia'),
  ('FC-02012468', 'TK-112558-32', 'El Surtidor de su Farmacia'),
  ('FC-1FBF5206', 'TK-IFC1-080826-1', 'IFC F8 Tienda'),
  ('FC-2E5B7248', 'TK-IFC1-080826-2', 'IFC F8 Tienda'),
  ('FC-D12CA0FA', 'TK-IFC1-080826-3', 'IFC F8 Tienda'),
  ('FC-62034164', 'TK-IFC1-080826-4', 'IFC F8 Tienda'),
  ('FC-3676D5DC', 'TK-IFC1-080826-5', 'IFC F8 Tienda'),
  ('FC-5A697CC2', 'TK-IFC1-080826-6', 'IFC F8 Tienda'),
  ('FC-39036C88', 'TK-IFC1-080826-7', 'IFC F8 Tienda'),
  ('FC-DFF99C3F', 'TK-IFC1-080826-8', 'IFC F8 Tienda'),
  ('FC-931B4809', 'TK-IFC1-080826-9', 'IFC F8 Tienda'),
  ('FC-D4AC123B', 'TK-IFC1-080826-10', 'IFC F8 Tienda'),
  ('FC-38CAFE6B', 'TK-IFC1-080826-11', 'IFC F8 Tienda'),
  ('FC-926099D3', 'TK-IFC1-080826-12', 'IFC F8 Tienda'),
  ('FC-E69F2E63', 'TK-IFC1-080826-13', 'IFC F8 Tienda'),
  ('FC-25E452B6', 'TK-IFC1-080826-14', 'IFC F8 Tienda'),
  ('FC-127F5753', 'TK-IFC1-080826-15', 'IFC F8 Tienda'),
  ('FC-D3D28E20', 'TK-IFC1-080826-16', 'IFC F8 Tienda'),
  ('FC-69387811', 'TK-IFC1-080826-17', 'IFC F8 Tienda'),
  ('FC-A680F97E', 'TK-IFC1-080826-18', 'IFC F8 Tienda'),
  ('FC-C4530823', 'TK-IFC2-080826-1', 'IFC F8 Tienda'),
  ('FC-D037156B', 'TK-IFC2-080826-2', 'IFC F8 Tienda'),
  ('FC-B8D7C997', 'TK-IFC2-080826-3', 'IFC F8 Tienda'),
  ('FC-CB5C11ED', 'TK-IFC2-080826-4', 'IFC F8 Tienda'),
  ('FC-A871D831', 'TK-IFC2-080826-5', 'IFC F8 Tienda'),
  ('FC-578F060C', 'TK-IFC2-080826-6', 'IFC F8 Tienda'),
  ('FC-FBD776D2', 'TK-IFC2-080826-7', 'IFC F8 Tienda'),
  ('FC-5EF90195', 'TK-IFC2-080826-8', 'IFC F8 Tienda'),
  ('FC-9A1C64E7', 'TK-IFC2-080826-9', 'IFC F8 Tienda'),
  ('FC-47AAF23B', 'TK-IFC2-080826-10', 'IFC F8 Tienda'),
  ('FC-FFC25DD1', 'TK-IFC2-080826-11', 'IFC F8 Tienda'),
  ('FC-614E4F82', 'TK-IFC2-080826-12', 'IFC F8 Tienda'),
  ('FC-C22EBFE6', 'TK-IFC2-080826-13', 'IFC F8 Tienda'),
  ('FC-BCF59548', 'TK-IFC2-080826-14', 'IFC F8 Tienda'),
  ('FC-9507CD66', 'TK-IFC2-080826-15', 'IFC F8 Tienda'),
  ('FC-FEAECBF1', 'TK-IFC2-080826-16', 'IFC F8 Tienda'),
  ('FC-9827438F', 'TK-IFC2-080826-17', 'IFC F8 Tienda'),
  ('FC-EFB599B5', 'TK-IFC2-080826-18', 'IFC F8 Tienda'),
  ('FC-08DB70CB', 'TK-IFC2-080826-19', 'IFC F8 Tienda'),
  ('FC-89F00320', 'TK-IFC2-080826-20', 'IFC F8 Tienda'),
  ('FC-FD718DF3', 'TK-IFC2-080826-21', 'IFC F8 Tienda'),
  ('FC-0ACC5B6A', 'TK-IFC2-080826-22', 'IFC F8 Tienda'),
  ('FC-5D59ED54', 'TK-IFC2-080826-23', 'IFC F8 Tienda'),
  ('FC-E5BA49B2', '7033325D', 'Farma MX'),
  ('FC-895EA161', '251101-2', 'Farma MX'),
  ('FC-33B15A58', '251101-3', 'Farma MX'),
  ('FC-66055303', 'TK-FMX-080826-4', 'Farma MX'),
  ('FC-DF92D3CF', 'RIJ25078', 'Farma MX'),
  ('FC-757DEC8A', 'S26094', 'Farma MX'),
  ('FC-108AB6B6', '262440', 'Farma MX'),
  ('FC-22ECC02C', '0038U', 'Farma MX'),
  ('FC-23B68FA1', 'U0377', 'Farma MX'),
  ('FC-87621652', '262526', 'Farma MX'),
  ('FC-2E70DB7E', '25540582', 'Farma MX'),
  ('FC-A166D66F', '26E0001', 'Farma MX'),
  ('FC-7B88B47E', '262415', 'Farma MX'),
  ('FC-F349C6DD', '256971', 'Farma MX'),
  ('FC-D751525D', '255714', 'Farma MX'),
  ('FC-4F05124E', '26C658', 'Farma MX'),
  ('FC-85632ABD', '26E40105', 'Farma MX'),
  ('FC-0906E3E1', '26A50040', 'Farma MX'),
  ('FC-4C3B3B9C', '25J662', 'Farma MX'),
  ('FC-1812D26D', '26E00193', 'Farma MX'),
  ('FC-EC96A027', '264672', 'Farma MX'),
  ('FC-3B7A358D', '28D007', 'Farma MX'),
  ('FC-16C9352F', '26C694', 'Farma MX'),
  ('FC-70F50FD7', '261SP0301', 'Farma MX'),
  ('FC-D33D7A48', '26F30810', 'Farma MX'),
  ('FC-00E8A9C7', 'TK-FMX-080826-26', 'Farma MX'),
  ('FC-D4342B8E', '260021', 'Farma MX'),
  ('FC-CF0AF2F6', '260915', 'Farma MX'),
  ('FC-5CA1622C', '26Y01966', 'Farma MX'),
  ('FC-D0A49FC8', '25402039', 'Farma MX'),
  ('FC-EB5DCEBE', '202602', 'Farma MX'),
  ('FC-DA34D88D', 'R2601829', 'Farma MX'),
  ('FC-BE2ACF63', '26A01381', 'Farma MX'),
  ('FC-D259E551', 'SP020325', 'Farma MX'),
  ('FC-2782A4D6', '25N50408', 'Farma MX'),
  ('FC-E3CFD0A7', '260205', 'Farma MX'),
  ('FC-39E059E2', '604203', 'Farma MX'),
  ('FC-DF39BB27', '26A01563', 'Farma MX'),
  ('FC-79C61297', '0925961', 'Farma MX'),
  ('FC-EC93AE62', '0164389', 'Farma MX'),
  ('FC-223B5D76', '26141117', 'Farma MX'),
  ('FC-86606791', '25J664', 'Farma MX'),
  ('FC-6D9926C2', 'TK-FMX-080826-43', 'Farma MX'),
  ('FC-2E7C6CD6', '26540074', 'Farma MX'),
  ('FC-D3FB53E9', '26140731', 'Farma MX'),
  ('FC-E3C83D59', '26740135', 'Farma MX'),
  ('FC-99F357DC', '0165578', 'Farma MX'),
  ('FC-23CE9602', '0161683', 'Farma MX'),
  ('FC-CAABC42B', '26AM34', 'Farma MX'),
  ('FC-E94C79BA', 'TK-FMX-080826-50', 'Farma MX'),
  ('FC-D75138BB', '12026092', 'Farma MX'),
  ('FC-6E084251', '5LM122A', 'Farma MX'),
  ('FC-30F56906', '06026056', 'Farma MX'),
  ('FC-046D8251', '0526059', 'Farma MX'),
  ('FC-D69881BF', 'B80046', 'Farma MX'),
  ('FC-C3B611F3', '60705', 'Farma MX'),
  ('FC-98518364', '2504863004', 'Farma MX'),
  ('FC-F89008C6', '3189826E', 'Farma MX'),
  ('FC-355851E7', '3211825F', 'Farma MX'),
  ('FC-C8B741F6', '251102-2', 'Farma MX'),
  ('FC-3B0C76C8', '251102-1', 'Farma MX'),
  ('FC-BE0A0E46', '3189325E', 'Farma MX'),
  ('FC-ED3B0AD4', 'V26Y020', 'Farma MX'),
  ('FC-83941A95', '2506885808', 'Farma MX'),
  ('FC-E9FA700D', '2601973605', 'Farma MX'),
  ('FC-BE977010', '2506885602', 'Farma MX'),
  ('FC-35A0F20F', 'P26F301', 'Farma MX'),
  ('FC-AE88EDDC', '221205-1', 'Farma MX'),
  ('FC-EE6593B4', '2512962201', 'Farma MX'),
  ('FC-93322783', '2504864301', 'Farma MX'),
  ('FC-20C90A6D', '1A12505', 'Farma MX'),
  ('FC-7607DDA7', '2503853712', 'Farma MX'),
  ('FC-8C9A304D', '2506885503', 'Farma MX'),
  ('FC-BA60704A', '2504864004', 'Farma MX'),
  ('FC-8EF34E83', '2411816005', 'Farma MX'),
  ('FC-76040610', 'TK-FL-080826-1', 'FarmaLive'),
  ('FC-60101231', 'TK-FL-080826-2', 'FarmaLive'),
  ('FC-87154871', 'TK-FL-080826-3', 'FarmaLive'),
  ('FC-60101521', 'TK-FL-080826-4', 'FarmaLive'),
  ('FC-06134531', 'TK-FL-080826-5', 'FarmaLive'),
  ('FC-08427330', 'TK-FL-080826-6', 'FarmaLive'),
  ('FC-58792792', 'TK-FL-080826-7', 'FarmaLive'),
  ('FC-50002301', 'TK-FL-080826-8', 'FarmaLive'),
  ('FC-28979502', 'TK-FL-080826-9', 'FarmaLive'),
  ('FC-89794961', 'TK-FL-080826-10', 'FarmaLive'),
  ('FC-79071241', 'TK-FL-080826-11', 'FarmaLive'),
  ('FC-47624171', 'TK-FL-080826-12', 'FarmaLive'),
  ('FC-80950139', 'TK-FL-080826-13', 'FarmaLive'),
  ('FC-88947797', 'TK-FL-080826-14', 'FarmaLive'),
  ('FC-50959781', 'TK-FL-080826-15', 'FarmaLive'),
  ('FC-80953017', 'TK-FL-080826-16', 'FarmaLive'),
  ('FC-54521161', 'TK-FL-080826-17', 'FarmaLive'),
  ('FC-95201021', 'TK-FL-080826-18', 'FarmaLive'),
  ('FC-08485316', 'TK-FL-080826-19', 'FarmaLive'),
  ('FC-65095947', 'TK-FL-080826-20', 'FarmaLive'),
  ('FC-95451096', 'TK-FL-080826-21', 'FarmaLive'),
  ('FC-79400556', 'TK-FL-080826-22', 'FarmaLive'),
  ('FC-58793249', 'TK-FL-080826-23', 'FarmaLive'),
  ('FC-95467264', 'TK-FL-080826-24', 'FarmaLive'),
  ('FC-87932321', 'TK-FL-080826-25', 'FarmaLive'),
  ('FC-08443026', 'TK-FL-080826-26', 'FarmaLive'),
  ('FC-75354321', 'TK-FL-080826-27', 'FarmaLive'),
  ('FC-08491074', 'TK-FL-080826-28', 'FarmaLive'),
  ('FC-70612368', 'TK-FL-080826-29', 'FarmaLive'),
  ('FC-88508929', 'TK-FL-080826-30', 'FarmaLive'),
  ('FC-84335531', 'TK-FL-080826-31', 'FarmaLive'),
  ('FC-23001331', 'TK-FL-080826-32', 'FarmaLive'),
  ('FC-85592111', 'TK-FL-080826-33', 'FarmaLive'),
  ('FC-84999001', 'TK-FL-080826-34', 'FarmaLive'),
  ('FC-08498798', 'TK-FL-080826-35', 'FarmaLive'),
  ('FC-08491096', 'TK-FL-080826-36', 'FarmaLive'),
  ('FC-50003151', 'TK-FL-080826-37', 'FarmaLive'),
  ('FC-24227339', 'TK-FL-080826-38', 'FarmaLive'),
  ('FC-98100381', 'TK-FL-080826-39', 'FarmaLive'),
  ('FC-14704156', 'TK-FL-080826-40', 'FarmaLive'),
  ('FC-14704163', 'TK-FL-080826-41', 'FarmaLive'),
  ('FC-08344488', 'TK-FL-080826-42', 'FarmaLive'),
  ('FC-65095718', 'TK-FL-080826-43', 'FarmaLive'),
  ('FC-01015141', 'TK-FL-080826-44', 'FarmaLive'),
  ('FC-08496701', 'TK-FL-080826-45', 'FarmaLive'),
  ('FC-88915491', 'TK-FL-080826-46', 'FarmaLive'),
  ('FC-08344747', 'TK-FL-080826-47', 'FarmaLive'),
  ('FC-08895196', 'TK-FL-080826-48', 'FarmaLive'),
  ('FC-89810021', 'TK-FL-080826-49', 'FarmaLive'),
  ('FC-60101378', 'TK-FL-080826-50', 'FarmaLive'),
  ('FC-60403681', 'TK-FL-080826-51', 'FarmaLive'),
  ('FC-88923551', 'TK-FL-080826-52', 'FarmaLive'),
  ('FC-25116810', 'TK-FL-080826-53', 'FarmaLive'),
  ('FC-35246309', 'TK-FL-080826-54', 'FarmaLive'),
  ('FC-47640531', 'TK-FL-080826-55', 'FarmaLive'),
  ('FC-84095411', 'TK-FL-080826-56', 'FarmaLive'),
  ('FC-85097661', 'TK-FL-080826-57', 'FarmaLive'),
  ('FC-06247327', 'TK-FL-080826-58', 'FarmaLive'),
  ('FC-84973401', 'TK-FL-080826-59', 'FarmaLive'),
  ('FC-08426944', 'TK-FL-080826-60', 'FarmaLive'),
  ('FC-82176351', 'TK-FL-080826-61', 'FarmaLive'),
  ('FC-30133021', 'TK-FL-080826-62', 'FarmaLive'),
  ('FC-98217659', 'TK-FL-080826-63', 'FarmaLive'),
  ('FC-66888171', 'TK-FL-080826-64', 'FarmaLive'),
  ('FC-66873531', 'TK-FL-080826-65', 'FarmaLive'),
  ('FC-86708021', 'TK-FL-080826-66', 'FarmaLive'),
  ('FC-03406600', 'TK-FL-080826-67', 'FarmaLive'),
  ('FC-03406501', 'TK-FL-080826-68', 'FarmaLive'),
  ('FC-34063651', 'TK-FL-080826-69', 'FarmaLive'),
  ('FC-34062421', 'TK-FL-080826-70', 'FarmaLive'),
  ('FC-60689091', 'TK-FL-080826-71', 'FarmaLive'),
  ('FC-73629981', 'TK-FL-080826-72', 'FarmaLive'),
  ('FC-56131681', 'TK-FL-080826-73', 'FarmaLive'),
  ('FC-60009851', 'TK-FL-080826-74', 'FarmaLive'),
  ('FC-23273451', 'TK-FL-080826-75', 'FarmaLive'),
  ('FC-75163051', 'TK-FL-080826-76', 'FarmaLive'),
  ('FC-27512574', 'TK-FL-080826-77', 'FarmaLive'),
  ('FC-75125811', 'TK-FL-080826-78', 'FarmaLive'),
  ('FC-34067851', 'TK-FL-080826-79', 'FarmaLive'),
  ('FC-48623006', 'TK-FL-080826-80', 'FarmaLive'),
  ('FC-23272151', 'TK-FL-080826-81', 'FarmaLive'),
  ('FC-68910041', 'TK-FL-080826-82', 'FarmaLive'),
  ('FC-89100101', 'TK-FL-080826-83', 'FarmaLive'),
  ('FC-34067301', 'TK-FL-080826-84', 'FarmaLive'),
  ('FC-34067471', 'TK-FL-080826-85', 'FarmaLive'),
  ('FC-34067781', 'TK-FL-080826-86', 'FarmaLive'),
  ('FC-68910034', 'TK-FL-080826-87', 'FarmaLive'),
  ('FC-66534951', 'TK-FL-080826-88', 'FarmaLive'),
  ('FC-83510531', 'TK-FL-080826-89', 'FarmaLive'),
  ('FC-68900127', 'TK-FL-080826-90', 'FarmaLive'),
  ('FC-68900134', 'TK-FL-080826-91', 'FarmaLive'),
  ('FC-50882017', 'TK-FL-080826-92', 'FarmaLive'),
  ('FC-08820243', 'TK-FL-080826-93', 'FarmaLive'),
  ('FC-76000277', 'TK-FL-080826-94', 'FarmaLive'),
  ('FC-51444145', 'TK-FL-080826-95', 'FarmaLive'),
  ('FC-83351691', 'TK-FL-080826-96', 'FarmaLive'),
  ('FC-83351381', 'TK-FL-080826-97', 'FarmaLive'),
  ('FC-33956775', 'TK-FL-080826-98', 'FarmaLive'),
  ('FC-33961373', 'TK-FL-080826-99', 'FarmaLive'),
  ('FC-48335305', 'TK-FL-080826-100', 'FarmaLive'),
  ('FC-33954740', 'TK-FL-080826-101', 'FarmaLive'),
  ('FC-59225411', 'TK-FL-080826-102', 'FarmaLive'),
  ('FC-51067711', 'TK-FL-080826-103', 'FarmaLive'),
  ('FC-86167151', 'TK-FL-080826-104', 'FarmaLive'),
  ('FC-92821171', 'TK-FL-080826-105', 'FarmaLive'),
  ('FC-58611420', 'TK-FL-080826-106', 'FarmaLive'),
  ('FC-51078461', 'TK-FL-080826-107', 'FarmaLive'),
  ('FC-51078531', 'TK-FL-080826-108', 'FarmaLive'),
  ('FC-29003221', 'TK-FL-080826-109', 'FarmaLive'),
  ('FC-51448511', 'TK-FL-080826-110', 'FarmaLive'),
  ('FC-25104411', 'TK-FL-080826-111', 'FarmaLive'),
  ('FC-25149221', 'TK-FL-080826-112', 'FarmaLive'),
  ('FC-25104268', 'TK-FL-080826-113', 'FarmaLive'),
  ('FC-51747971', 'TK-FL-080826-114', 'FarmaLive'),
  ('FC-43471900', 'TK-FL-080826-115', 'FarmaLive'),
  ('FC-34064021', 'TK-FL-080826-116', 'FarmaLive'),
  ('FC-14983153', 'TK-FL-080826-117', 'FarmaLive'),
  ('FC-43454811', 'TK-FL-080826-118', 'FarmaLive'),
  ('FC-49824391', 'TK-FL-080826-119', 'FarmaLive'),
  ('FC-14985348', 'TK-FL-080826-120', 'FarmaLive'),
  ('FC-49853867', 'TK-FL-080826-121', 'FarmaLive'),
  ('FC-49824911', 'TK-FL-080826-122', 'FarmaLive'),
  ('FC-14985805', 'TK-FL-080826-123', 'FarmaLive'),
  ('FC-14983726', 'TK-FL-080826-124', 'FarmaLive'),
  ('FC-49824771', 'TK-FL-080826-125', 'FarmaLive'),
  ('FC-58203691', 'TK-FL-080826-126', 'FarmaLive'),
  ('FC-14982514', 'TK-FL-080826-127', 'FarmaLive'),
  ('FC-45079011', 'TK-FL-080826-128', 'FarmaLive'),
  ('FC-14980596', 'TK-FL-080826-129', 'FarmaLive'),
  ('FC-49800151', 'TK-FL-080826-130', 'FarmaLive'),
  ('FC-62746605', 'TK-FL-080826-131', 'FarmaLive'),
  ('FC-45045281', 'TK-FL-080826-132', 'FarmaLive'),
  ('FC-54504870', 'TK-FL-080826-133', 'FarmaLive'),
  ('FC-52400212', 'TK-FL-080826-134', 'FarmaLive'),
  ('FC-24004581', 'TK-FL-080826-135', 'FarmaLive'),
  ('FC-56034041', 'TK-FL-080826-136', 'FarmaLive'),
  ('FC-21042481', 'TK-FL-080826-137', 'FarmaLive'),
  ('FC-52400267', 'TK-FL-080826-138', 'FarmaLive'),
  ('FC-62746612', 'TK-FL-080826-139', 'FarmaLive'),
  ('FC-52400038', 'TK-FL-080826-140', 'FarmaLive'),
  ('FC-62746698', 'TK-FL-080826-141', 'FarmaLive'),
  ('FC-45307181', 'TK-FL-080826-142', 'FarmaLive'),
  ('FC-62746643', 'TK-FL-080826-143', 'FarmaLive');

-- 3) Actualización masiva
update public.lotes l
set proveedor_id = public.fc_resolver_proveedor_tienda(m.tienda)
from public.productos p
join _fc_proveedor_lote m on m.sku = p.sku
where l.producto_id = p.id
  and l.numero_lote = m.numero_lote
  and coalesce(l.activo, true);

-- 4) Verificación
select
  count(*) as lotes_activos,
  count(*) filter (where l.proveedor_id is not null) as con_tienda,
  count(*) filter (where l.proveedor_id is null) as sin_tienda
from public.lotes l
where coalesce(l.activo, true);

select pv.nombre as tienda, count(*) as lotes
from public.lotes l
join public.proveedores pv on pv.id = l.proveedor_id
where coalesce(l.activo, true)
group by pv.nombre
order by lotes desc;

commit;

-- ═══════════════════════════════════════════════════════════
-- VERIFICACIÓN FINAL
-- ═══════════════════════════════════════════════════════════

select count(*) as productos_fc
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select sum(cantidad_actual) as piezas_en_lotes from public.lotes where coalesce(activo, true);

select
  count(*) filter (where codigo_barras is not null and btrim(codigo_barras) <> '') as con_barcode,
  count(*) filter (where marca is not null and btrim(marca) <> '') as con_marca,
  count(*) filter (where presentacion is not null and btrim(presentacion) <> '') as con_presentacion
from public.productos
where sku like 'FC-%' and sku not like 'FC100%';

select
  count(*) as lotes_activos,
  count(*) filter (where proveedor_id is not null) as lotes_con_tienda
from public.lotes
where coalesce(activo, true);

