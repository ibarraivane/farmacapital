-- ============================================================================
-- FARMA CAPITAL — Lote fotos ordenadas 2 (IMG ~6044–6271) 16-ago-2026
--
-- SOLO huecos. No crea productos. No pisa un campo que ya tenga valor.
-- No toca costo, precio ni stock.
--
-- codigo_barras / presentacion / PA / forma / marca / concentracion /
-- unidades_por_caja  → solo si están vacíos. activo = true.
--
-- Ticket Equilibrio 440393: Zukedib 4, Amlodipino 100, Elaphterón 100
-- y Ampigrin INF sí están (como FC-). Se les pone el EAN.
--
-- Fuera (líneas del ticket que NUNCA se crearon como SKU — no las invento):
--   AMS328 Ketorolaco 3 amp, AMS253 Dexa 1 FA, MAV295 Erispan Comp,
--   AVT205 Elaphterón 25, MAV318 Cariden 6, OFF008 Dexne nasal,
--   OFF010 Dexne oftálmico, MAV134/167 Doltrix tabs, MAV064 Presistín tab,
--   AVT135 Tusilen ped, BEA313 Dexa 1 mg, AMS362 Diclofenaco iny.
-- Belazix / Bioerter: ya tienen OTRO EAN — no se reemplaza.
-- Ampigrin INF está en FC-DE106642 pero el nombre dice Infamid (error de carga).
-- Idempotente. No va en transacción.
-- ============================================================================

do $upd$
declare
  r record;
  v_id bigint;
begin
  for r in
    select * from (values
      ('EQ-ACC066', '7506335700019', 'Caja con 30 tabletas', 'Finasterida', 'Tableta', 'Accord', '5 mg', 30),  -- 0034 Steryx
      ('EQ-ALP0633', '7502226295954', 'Caja con 10 tabletas', 'Dexketoprofeno', 'Tableta', 'Alpharma', '25 mg', 10),  -- 0056 Dexketoprofeno
      ('EQ-AMS209', '7501349028654', 'Frasco 10 mL', 'Hipromelosa', 'Gotas oftálmicas', 'AMSA', '0.5%', null),  -- 0076 Hipromelosa
      ('EQ-AMS274', '7501349024540', null, 'Ezetimiba / Simvastatina', 'Tableta', 'AMSA', '10 mg / 20 mg', null),  -- 0092 Ezetimiba / Simvastatina
      ('EQ-AMS428', '7501349028326', 'Caja con 30 tabletas', 'Cisaprida', 'Tableta', 'AMSA', '5 mg', 30),  -- 0045 Cisaprida
      ('EQ-AMS460', '7501349027787', null, 'Etoricoxib', 'Comprimido', 'AMSA', '90 mg', null),  -- 0042 Etoricoxib
      ('EQ-AMS472', '7501349024922', 'Caja con 14 tabletas', 'Citalopram', 'Tableta', 'AMSA', '20 mg', 14),  -- 0018 Citalopram
      ('EQ-AMS497', '7501349022249', null, 'Levetiracetam', 'Tableta', 'AMSA', '1000 mg', null),  -- 0036 Levetiracetam
      ('EQ-AVT203', '7502209858183', 'Caja con 28 tabletas', 'Clopidogrel', 'Tableta', 'Avitus', '75 mg', 28),  -- 0070 Cidorix
      ('EQ-BEA342', '7501342803418', 'Caja con 20 tabletas', 'Dexametasona', 'Tableta', 'beadvance', '0.5 mg', 20),  -- 0031 Dexametasona
      ('EQ-BEA379', '7501342803814', 'Caja con 20 tabletas', 'Espironolactona', 'Tableta', 'beadvance', '25 mg', 20),  -- 0080 Espironolactona
      ('EQ-BIO100', '7501573904151', 'Caja con 10 tabletas', 'Fexofenadina', 'Tableta', 'Biomep', '120 mg', 10),  -- 0079 Biostafex
      ('EQ-BIO212', '7501573909958', 'Caja con 30 tabletas', 'Colchicina', 'Tableta', 'Biomep', '1 mg', 30),  -- 0027 Colchicina
      ('EQ-BRU016', '7501537102586', 'Caja con 3 ampolletas', 'Dexametasona', 'Solución inyectable', 'Bruluart', '8 mg/2 mL', 3),  -- 0068 Brulin
      ('EQ-BRU053', '7501537102845', 'Caja con 20 tabletas', 'Diclofenaco', 'Tableta liberación prolongada', 'Bruluart', '100 mg', 20),  -- 0106 Nediclon
      ('EQ-COL073', '780083140021', 'Frasco 20 mL', 'Lidocaína / Neomicina', 'Gotas', 'Collins', null, null),  -- 0019 Otilin
      ('EQ-COL120', '780083142537', 'Tubo 60 g', 'Hidrocortisona', 'Crema', 'Collins', '1%', null),  -- 0102 Collicort
      ('EQ-COL226', '780083148805', 'Caja con 10 tabletas', 'Ibuprofeno', 'Tableta', 'Collins', '800 mg', 10),  -- 0089 Dolprofen
      ('EQ-DEG011', '7501825300175', null, null, 'Solución', 'Degort''s', null, null),  -- 0074 Convifer con hierro
      ('EQ-EXA042', '75053086', 'Frasco 5 mL', 'Cromoglicato de sodio', 'Gotas oftálmicas', 'OPKO', '40 mg/mL', null),  -- 0053 Cromoglicato de sodio
      ('EQ-IFA001', '7501249606778', 'Caja con 1 comprimido', 'Levonorgestrel', 'Comprimido', 'ifa', '1.5 mg', 1),  -- 0014 Postday
      ('EQ-JAY263', '7506022331502', 'Caja con 28 tabletas', 'Dapagliflozina', 'Tableta', null, '10 mg', 28),  -- 0069 Diflosensi
      ('EQ-LOE058', '500487172707', 'Frasco 50 tabletas', 'Fenitoína', 'Tableta', 'Loeffler', '100 mg', 50),  -- 0028 Feniffler-T
      ('EQ-MAI055', '785118752415', 'Tubo 30 g', 'Clindamicina', 'Gel', 'MAVI', '1%', null),  -- 0088 Dalatina
      ('EQ-MAI078', '785118752477', 'Caja con 20 tabletas', 'Fenazopiridina', 'Tableta', 'MAVI', '100 mg', 20),  -- 0041 Urezol
      ('EQ-MAI099', '785120754681', 'Caja con 30 tabletas', 'Hidroxizina', 'Tableta', 'MAVI', '10 mg', 30),  -- 0020 Hidroxin
      ('EQ-MAI152', '785118752941', 'Tubo 30 g + 6 aplicadores', 'Clindamicina / Ketoconazol', 'Crema vaginal', 'MAVI', '2% / 8%', null),  -- 0005 Mavifem
      ('EQ-MAV043', '7502009740244', 'Caja con 10 tabletas', 'Ketorolaco', 'Tableta', 'Maver', '10 mg', 10),  -- 0004 Lorotec
      ('EQ-MAV065', '7502009740299', 'Frasco 60 mL', 'Cisaprida', 'Suspensión', 'Maver', '1 mg/mL', null),  -- 0048 Presistín
      ('EQ-MAV140', '7502009741326', 'Caja con 3+3 ampolletas', 'Clonixinato / Hioscina', 'Solución inyectable', 'Maver', '100 mg / 20 mg', 3),  -- 0032 Doltrix
      ('EQ-MAV236', '7502009745478', 'Caja con 14 tabletas', 'Duloxetina', 'Tableta liberación retardada', 'Maver', '60 mg', 14),  -- 0081 Ideliver Pro
      ('EQ-MAV311', '7502009746499', 'Caja con 7', 'Etoricoxib', 'Comprimido', 'Maver', '120 mg', null),  -- 0066 Exicort
      ('EQ-MAV320', '7502009746734', 'Caja con 10 tabletas', 'Deflazacort', 'Tableta', 'Maver', '30 mg', 10),  -- 0062 Cariden
      ('EQ-MAV322', '7502009746932', 'Tubo 60 g', 'Indometacina / Betametasona', 'Gel', 'Maver', null, null),  -- 0067 Traditor
      ('EQ-MAV358', '7502009746178', 'Caja con 30 comprimidos', 'Leflunomida', 'Comprimido', 'Maver', '20 mg', 30),  -- 0039 Avattor
      ('EQ-MAV376', '7502009748929', 'Tubo 100 g', null, 'Gel corporal', 'Maver', null, null),  -- 0001 Flausiver
      ('EQ-MAV415', '7502009749292', 'Caja con 28 tabletas', 'Esomeprazol', 'Tableta liberación retardada', 'Maver', '40 mg', 28),  -- 0100 Esomeprazol
      ('EQ-NOV032', '7501075717150', 'Caja con 10 tabletas', 'Ketoconazol', 'Tableta', 'Novag', '200 mg', 10),  -- 0010 Lizovag
      ('EQ-NOV154', null, 'Caja con 20 tabletas', 'Levocetirizina', 'Tableta', 'Novag', '5 mg', 20),  -- 0047 Belazix
      ('EQ-OFF009', '7502004401508', 'Frasco 10 mL', 'Dexametasona / Neomicina / Lidocaína', 'Gotas óticas', 'Offenbach', null, null),  -- 0058 Dexne Ótico
      ('EQ-PGE059', '7503027446408', 'Caja con 30 cápsulas', 'Colecalciferol', 'Cápsula', null, '4000 UI', 30),  -- 0015 Lorefic-D
      ('EQ-QUM043', '7502223112346', 'Caja con 10 tabletas', 'Desloratadina', 'Tableta', 'Quimpharma', '5 mg', 10),  -- 0024 Histapharm
      ('EQ-QUM070', '7502223111400', 'Frasco 200 mL', 'Dropropizina / Bromhexina', 'Jarabe', 'Quimpharma', null, null),  -- 0101 Drosequim adulto
      ('EQ-RAD081', '7501563380163', 'Caja con 50 tabletas', 'Fumarato ferroso', 'Tableta', 'Pisa', '200 mg', 50),  -- 0083 Fumarato ferroso
      ('EQ-RAD082', '7501563380286', 'Caja con 30 cápsulas', 'Indometacina', 'Cápsula', null, '25 mg', 30),  -- 0022 Indometacina
      ('EQ-RAD092', '7501563380408', 'Frasco 120 mL', 'Dextrometorfano', 'Jarabe', 'Randall', '15 mg/5 mL', null),  -- 0073 Dextrometorfano
      ('EQ-RAD096', '7501563380439', 'Tubo 12', 'Calcio', 'Comprimido efervescente', 'Raam', '500 mg', null),  -- 0029 Calcio efervescente
      ('EQ-RAD100', '7501563380637', 'Frasco 20 tabletas', 'Fenazopiridina', 'Tableta', 'Randall', '100 mg', 20),  -- 0052 Fenazopiridina
      ('EQ-SER001', '7501258200288', 'Caja con 30 tabletas', 'Ketotifeno', 'Tableta', 'Serral', '1 mg', 30),  -- 0044 Asmaral-K
      ('EQ-SER025', '7501258203586', 'Caja con 10 tabletas', 'Clonixinato de lisina', 'Tableta', 'Serral', '250 mg', 10),  -- 0090 Lonixer
      ('EQ-SOF041', '7502274791163', 'Caja con 60 tabletas', 'Levetiracetam', 'Tableta', 'Solfrán', '500 mg', 60),  -- 0035 Vixgoplisol
      ('EQ-SON024', '7502001161511', 'Tubo 40 g', 'Clioquinol / Fluocinolona', 'Crema', 'SON''S', null, null),  -- 0057 Bentix
      ('EQ-SON193', '7502001162600', 'Frasco 10 mL', 'Hidrocortisona / Cloranfenicol / Benzocaína', 'Gotas óticas', 'SON''S', null, null),  -- 0033 Poral Ótico
      ('EQ-SON204', '7502001162693', 'Frasco 10 mL', 'Ciprofloxacino / Hidrocortisona / Lidocaína', 'Suspensión ótica', 'SON''S', null, null),  -- 0109 Phendex
      ('EQ-SON214', '7502001164338', 'Frasco 5 mL', 'Ciprofloxacino / Dexametasona', 'Gotas', 'SON''S', null, null),  -- 0060 Ciprofloxacino / Dexametasona
      ('EQ-SON264', '7502001166981', 'Caja con 3 frascos ámpula', null, 'Solución inyectable', 'SON''S', null, 3),  -- 0086 Laur adulto
      ('EQ-TEM009', '7501249600813', 'Caja con 100 tabletas', 'Levotiroxina', 'Tableta', 'Tempus', '100 mcg', 100),  -- 0007 Levotiroxina
      ('EQ-ULT103', '7502216802919', 'Caja con 20 tabletas', 'Diclofenaco', 'Tableta liberación prolongada', 'Ultra', '100 mg', 20),  -- 0087 Diclofenaco
      ('EQ-ULT230', '7502216806474', 'Caja con 1 tableta', 'Levonorgestrel', 'Tableta', 'Ultra', '1.5 mg', 1),  -- 0037 Levonorgestrel
      ('EQ-VIC030', '656599040226', 'Caja con 10 tabletas', 'Diclofenaco / Paracetamol', 'Tableta', 'Victory', '50 mg / 500 mg', 10),  -- 0078 Tofel
      ('EQ-WER046', '7502240450827', 'Caja con 15 tabletas', 'Diosmina', 'Tableta', 'Wermar', '600 mg', 15),  -- 0061 Mevedim
      ('FC-04D83B46', '785120755442', 'Caja con 28 tabletas', 'Escitalopram', 'Tableta', 'MAVI', '10 mg', 28),  -- 0021 Pralex
      ('FC-1BF03D35', '7503004908721', 'Tubo 40 g', 'Fluocinolona', 'Crema', 'Alpharma', '0.01%', null),  -- 0013 Fluocinolona
      ('FC-1DAD5EF1', '7502209810365', 'Frasco 118 mL', 'Dextrometorfano / Guaifenesina / Fenilefrina', 'Jarabe', 'Avitus', null, null),  -- 0103 Tusilen
      ('FC-2001A890', '780083140922', 'Caja con 3 frascos ámpula', 'Ampicilina', 'Solución inyectable', 'Collins', '500 mg', 3),  -- 0114 Ampigrin adulto
      ('FC-262F2A30', null, null, 'Irbesartán', 'Tableta', 'AMSA', '150 mg', null),  -- 0111 Irbesartán
      ('FC-28A424E5', null, 'Caja con 20 tabletas', 'Hidroclorotiazida', 'Tableta', 'Maver', '25 mg', 20),  -- 0071 Diziver
      ('FC-2E79C2D8', '7501349020412', null, 'Hierro dextrán', 'Solución inyectable', 'AMSA', '100 mg/2 mL', null),  -- 0105 Hierro dextrán
      ('FC-4F737E93', '7501573902706', 'Frasco 120 mL', 'Ambroxol', 'Solución', 'Biomep', '15 mg/5 mL', null),  -- 0107 Cloxan
      ('FC-50D044FF', '7502240450780', 'Caja con 30 cápsulas', 'Gabapentina', 'Cápsula', 'Wermar', '300 mg', 30),  -- 0049 Wermy
      ('FC-57925EF3', null, 'Caja con 50 tabletas', 'Glibenclamida', 'Tableta', 'Novag', '5 mg', 50),  -- 0113 Reglusan
      ('FC-5885E577', '7501075722543', 'Caja con 28 tabletas', 'Irbesartán / Hidroclorotiazida', 'Tableta', 'Novag', '150 mg / 12.5 mg', 28),  -- 0017 Pabesorag
      ('FC-5BC5F234', null, 'Caja con 1 cápsula', 'Fluconazol', 'Cápsula', 'AMSA', '150 mg', 1),  -- 0038 Fluconazol
      ('FC-5C8C9C11', null, 'Caja con 10 cápsulas', 'Ibuprofeno', 'Cápsula', null, '600 mg', 10),  -- 0097 Gelubrin
      ('FC-6898B64F', null, 'Frasco 100 mL', 'Eritromicina', 'Suspensión', null, '250 mg/5 mL', null),  -- 0108 Bioerter
      ('FC-759A5EF9', '7502240450773', 'Caja con 15 cápsulas', 'Gabapentina', 'Cápsula', 'Wermar', '300 mg', 15),  -- 0051 Wermy
      ('FC-9A37D44A', null, 'Caja con 14 cápsulas', 'Lansoprazol', 'Cápsula', 'Wermar', '30 mg', 14),  -- 0072 Amdory
      ('FC-A23F290E', null, 'Caja con 15 cápsulas', 'Itraconazol', 'Cápsula', 'Avitus', '100 mg', 15),  -- 0055 Zitriasol
      ('FC-A2B284E0', '75058661', 'Frasco 10 mL', 'Hialuronato de sodio', 'Gotas', 'OPKO', '4 mg/mL', null),  -- 0023 Hialuronato de sodio
      ('FC-BE76D409', null, 'Caja con 1 frasco ámpula', 'Ceftriaxona', 'Solución inyectable', 'AMSA', '1 g', 1),  -- 0094 Amcef IM
      ('FC-E535DE28', null, 'Caja con 20 tabletas', 'Furosemida', 'Tableta', 'Biomep', '40 mg', 20),  -- 0096 Diurmessel
      ('FC-EADF1484', '6348812732387', 'Caja con 20 tabletas', 'Diosmina / Hesperidina', 'Tableta', 'beadvance', '450 mg / 50 mg', 20),  -- 0112 Diosmina / Hesperidina
      ('FC-F7A2CACF', '7501547509016', 'Caja con 30 cápsulas', 'Indometacina / Dexametasona', 'Cápsula', null, '25 mg / 0.5 mg', 30),  -- 0098 Indarzona
      ('FC-F7DB080D', null, 'Caja con 28 tabletas', 'Fluoxetina', 'Tableta', 'Biomep', '20 mg', 28),  -- 0085 Ovisen
      ('FC-FD92D114', '7501573900290', 'Caja con 14 tabletas', 'Fluoxetina', 'Tableta', 'Biomep', '20 mg', 14),  -- 0084 Ovisen
      -- Ticket Equilibrio 440393: mismos productos, cargados como FC- sin EAN
      ('FC-3D0ED22B', '7502211784036', 'Caja con 30 tabletas', 'Glimepirida', 'Tableta', 'Loeffler', '4 mg', 30),  -- LOE071 Zukedib 4 mg
      ('FC-4A0245DA', '7502216804814', 'Frasco con 100 tabletas', 'Amlodipino', 'Tableta', 'Avivia', '5 mg', 100),  -- AVI027 Amlodipino 100
      ('FC-9ABFB996', '7502209858251', 'Caja con 28 tabletas', 'Lamotrigina', 'Tableta dispersable', 'Avitus', '100 mg', 28),  -- AVT204 Elaphterón 100
      ('FC-DE106642', '780083140939', 'Caja con 3 frascos ámpula', 'Ampicilina', 'Solución inyectable', 'Collins', '250 mg', 3)  -- COL008 Ampigrin INF (el nombre en BD dice Infamid: error, no lo cambio)
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



-- Altas omitidas a propósito: no crear SKU sin avisar.




select sku, nombre, codigo_barras, activo, presentacion, principio_activo,
       forma_farmaceutica, marca, concentracion, unidades_por_caja, costo, precio, stock
from public.productos
where sku in (
  'EQ-ACC066','EQ-ALP0633','EQ-AMS209','EQ-AMS274','EQ-AMS428','EQ-AMS460',
  'EQ-AMS472','EQ-AMS497','EQ-AVT203','EQ-BEA342','EQ-BEA379','EQ-BIO100',
  'EQ-BIO212','EQ-BRU016','EQ-BRU053','EQ-COL073','EQ-COL120','EQ-COL226',
  'EQ-DEG011','EQ-EXA042','EQ-IFA001','EQ-JAY263','EQ-LOE058','EQ-MAI055',
  'EQ-MAI078','EQ-MAI099','EQ-MAI152','EQ-MAV043','EQ-MAV065','EQ-MAV140',
  'EQ-MAV236','EQ-MAV311','EQ-MAV320','EQ-MAV322','EQ-MAV358','EQ-MAV376',
  'EQ-MAV415','EQ-NOV032','EQ-NOV154','EQ-OFF009','EQ-PGE059','EQ-QUM043',
  'EQ-QUM070','EQ-RAD081','EQ-RAD082','EQ-RAD092','EQ-RAD096','EQ-RAD100',
  'EQ-SER001','EQ-SER025','EQ-SOF041','EQ-SON024','EQ-SON193','EQ-SON204',
  'EQ-SON214','EQ-SON264','EQ-TEM009','EQ-ULT103','EQ-ULT230','EQ-VIC030',
  'EQ-WER046','FC-04D83B46','FC-1BF03D35','FC-1DAD5EF1','FC-2001A890','FC-262F2A30',
  'FC-28A424E5','FC-2E79C2D8','FC-4F737E93','FC-50D044FF',
  'FC-57925EF3','FC-5885E577','FC-5BC5F234','FC-5C8C9C11','FC-6898B64F','FC-759A5EF9',
  'FC-9A37D44A','FC-A23F290E','FC-A2B284E0','FC-BE76D409','FC-E535DE28',
  'FC-EADF1484','FC-F7A2CACF','FC-F7DB080D','FC-FD92D114',
  'FC-3D0ED22B','FC-4A0245DA','FC-9ABFB996','FC-DE106642'
)
order by sku;
