-- City Mark 20260905 — nombres de ticket → mostrador.
-- NO sube stock. El 0 es correcto hasta Recibir (pistola + MMAA).
-- Solo pisa el nombre si sigue siendo el código del PDF (snap).
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_cm_nom (
  ean text primary key,
  nombre text not null,
  snap text not null,
  marca text,
  presentacion text,
  categoria text not null,
  subcategoria text,
  forma text,
  imagen text
) on commit drop;

insert into _fc_cm_nom (
  ean, nombre, snap, marca, presentacion, categoria, subcategoria, forma, imagen
) values
  ('7891010245160', 'Neutrogena agua micelar 200 ml', 'NEUTROGENA 200ML AGUA MICELAR C6 SEP26', 'Neutrogena', '200 ml', 'Cuidado personal', 'Facial', 'Solución', 'https://www.farmacapital.mx/catalogo-propia/cm-7891010245160.jpg'),
  ('761318132592', 'Revlon peines Salon Carbon 2 pzas', 'PEINES REVLON SALON CARBON 2PK', 'Revlon', '2 pzas', 'Cuidado personal', 'Cabello', 'Peine', null),
  ('761318128335', 'Revlon cepillo paleta RV2833LA', 'CEP REVLON MOD PALETA RV2833LA', 'Revlon', '1 pza', 'Cuidado personal', 'Cabello', 'Cepillo', null),
  ('761318020639', 'Revlon cepillo acolchado goma RV2063LA', 'CEP REVLON ACOLCHMGO GOMARV2063LA', 'Revlon', '1 pza', 'Cuidado personal', 'Cabello', 'Cepillo', null),
  ('7502221187575', 'Brut Deep Blue 48 h spray 150 ml', 'DESOD BRUT DEEPBLUE 48HR SPY150ML', 'Brut', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506306215511', 'Savile sábila y naranja spray 150 ml', 'DESOD SAVILE SAB-NAC NAT SPY 150ML', 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506306215511.jpg'),
  ('7506306215528', 'Savile bicarbonato y limón spray 150 ml', 'DEO SAVILE B-SOD Y LIM SPY150ML', 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506306209763', 'Savile manzanilla spray 150 ml', 'DESOD SAVILE MANZANILLA SPY 150ML', 'Savile', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('75065102', 'Savile manzanilla stick 45 g', 'DESOD SAVILE MANZANILLA STICK 45G', 'Savile', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', 'https://www.farmacapital.mx/catalogo-propia/cm-75065102.jpg'),
  ('75068639', 'Savile bicarbonato y limón stick 45 g', 'DESOD SAVILE B-SOD Y LIM STICK45G', 'Savile', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  ('75068622', 'Savile bicarbonato y limón roll-on 45 ml', 'DESOD SAVILE B-SOD Y LIM R-ON45ML ABRIL27', 'Savile', '45 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('75064891', 'Savile agua de rosas roll-on 45 ml', 'DESOD SAVILE AGUA/ROSA R-ON 45ML MAR27', 'Savile', '45 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7501082736021', 'Nuvel Aclara woman spray 150 ml', 'DEO NUVEL ACLA WOM SPY150ML', 'Nuvel', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506309864839', 'Gillette Endurance Cool spray 150 ml', 'DESOD GTTE END COOL SPY150ML', 'Gillette', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7501027286000', 'Obao Ocean roll-on 65 g', 'DESOD OBAO OCEAN R-ON 65G', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7506309864822', 'Gillette Endurance Arctic Ice spray 150 ml', 'DESOD GTTE ENDURARTICIC SP 150', 'Gillette', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506309864822.jpg'),
  ('7501027286017', 'Obao Clásico roll-on 65 g', 'DESOD OBAO CLAS R-ON 65G', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7501082731071', 'Nuvel Tropical woman spray 170 ml', 'DESOD NUVEL TROPIC WOM SPY 170 ML', 'Nuvel', '170 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506306251847', 'Axe Black Remix spray 210 ml', 'DESOD AXE BLACK REMIX SPY 210 ML', 'Axe', '210 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7509546029139', 'Speed Stick 24/7 Cool Night stick 85 g', 'DESOD SPEED S 24/7COOL-NIG STIK 85G', 'Speed Stick', '85 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  ('7500435141796', 'Old Spice Mariner Professional spray 150 ml', 'DESOD OLD SPICE MAR PROF SPY 150ML', 'Old Spice', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7500435141796.jpg'),
  ('7509552906158', 'Obao Fresquísima roll-on 65 g', 'DESOD OBAO FRESQUISSIMA R-ON 65G', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7509552844825', 'Obao Naturals Coco roll-on 65 g', 'DESOD OBAO R-NAT COCO R-ON 65G', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7509546071275', 'Lady Speed Stick Powder Fresh spray 60 g', 'DESOD LADYSS POWDER FRESH SPY 60G FEB27', 'Lady Speed Stick', '60 g', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546071275.jpg'),
  ('78924338', 'Rexona Woman Powder roll-on 53 g', 'DESOD REXONA WOM POW R-ON 53G', 'Rexona', '53 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7506306226852', 'Axe Anarchy for Her spray 150 ml', 'DESOD AXE WOM ANARCHY SPY 150ML', 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7500435129367', 'Secret pH Balanced stick gel 45 g', 'DESOD SECRET PH-BALAN STICK GEL 45G', 'Secret', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  ('7506306209862', 'Axe Anarchy Fresh Love for Her spray 150 ml', 'DESOD AXE SPY 150ML 48H ANARCHY FRESH LOVE FOR HER', 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-7506306209862.jpg'),
  ('7791293025919', 'Axe Excite seco spray 152 ml', 'DESOD AXE EXCITE SECO SPY 152ML', 'Axe', '152 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7509546057545', 'Lady Speed Stick Pro 5en1 stick 45 g', 'DESOD LADYSS PRO 5EN1 STICK 45G ABRIL27', 'Lady Speed Stick', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  ('7509546015514', 'Lady Speed Stick Derma Defense Fresh 45 g', 'DESOD LADYSS D-DEF A-FSH 45G', 'Lady Speed Stick', '45 g', 'Cuidado personal', 'Desodorante', 'Stick', null),
  ('7506306209855', 'Axe Anarchy Floral 48 h spray 150 ml', 'DESOD AXE ANARC FLO 48H SPY 150ML', 'Axe', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7509546029153', 'Lady Speed Stick Floral Fresh gel 65 g', 'DESOD LADYSS FLORAL FRESH GEL 65GN', 'Lady Speed Stick', '65 g', 'Cuidado personal', 'Desodorante', 'Gel', null),
  ('78924345', 'Rexona Woman Bamboo roll-on 50 ml', 'DESOD REXONA WOM BAMBOO R-ON 50ML', 'Rexona', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-78924345.jpg'),
  ('7509546060477', 'Lady Speed Stick Powder Fresh roll-on 50 ml', 'DESOD LADYSS POW DER FRES R-ON 50ML', 'Lady Speed Stick', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546060477.jpg'),
  ('7506339349146', 'Old Spice Wolfthorn spray 150 ml', 'DESOD OLD SPICE WOLFTHORN SPY 150ML', 'Old Spice', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7501027250612', 'Obao para ella roll-on 65 g', 'DESOD OBAO P/DEL R-ON 65G', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7501082790481', 'Nuvel toallitas desmaquillantes hidratantes C/25', 'TAS DESMAQ NUVEL HIDRATANTES C25', 'Nuvel', '25 pzas', 'Cuidado personal', 'Facial', 'Toallitas', null),
  ('7502221012303', 'Claris toallitas desmaquillantes aloe C/40', 'TAS HUM CLARIS DESMAQ ALOE C/40', 'Claris', '40 pzas', 'Cuidado personal', 'Facial', 'Toallitas', null),
  ('7509546029825', 'Neutro Balance roll-on 65 ml', 'DESOD NEUTRO B R-ON 65 ML', 'Neutro Balance', '65 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7501022107201', 'Conse shampoo antiolores para perro 500 ml', 'SH PERRO CONSE ANTI OLORES 500ML', 'Conse', '500 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  ('7509546007083', 'Colgate Total 12 Clean Mint 50 ml', 'C D COLGATE TOTAL12 CLEAN MINT 50ML', 'Colgate', '50 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546007083.jpg'),
  ('037836007279', 'Conse Guau Aloe Vera shampoo para perro 400 ml', 'SH PERRO CONSE GUAU ALOE VERA 400ML', 'Conse', '400 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  ('037836084508', 'Grisi Agrade avena shampoo para perro 400 ml', 'SH GRISI PERRO AGRADE AVENA 400ML', 'Grisi', '400 ml', 'Cuidado personal', 'Mascotas', 'Shampoo', null),
  ('759684900204', 'Jaloma agua de rosas tónico facial 250 ml', 'AGUA JALOMA ROSAS TOC FAC 250ML', 'Jaloma', '250 ml', 'Cuidado personal', 'Facial', 'Tónico', 'https://www.farmacapital.mx/catalogo-propia/cm-759684900204.jpg'),
  ('7509546651743', 'Stefano Triumph desodorante 159 ml', 'DESOD STEFANO TRIUMPH 159 ML', 'Stefano', '159 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7501056330378', 'Pond''s Bio-Hydra Dual loción limpiadora 200 ml', 'LOC LIMP PONDS BIO-HYDRA DUAL 200ML', 'Pond''s', '200 ml', 'Cuidado personal', 'Facial', 'Loción', null),
  ('759684900259', 'Jaloma agua de arroz spray 250 ml', 'JALOMA AGUA DE ARROZ 250ML SPRAY C24 PZS', 'Jaloma', '250 ml', 'Cuidado personal', 'Facial', 'Spray', null),
  ('814266022627', 'Honey Keeper Kids lavanda 3en1 414 ml', 'SH HONEYKEEPER KIDS LAVANDA 3EN1 414ML', 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Shampoo', null),
  ('7509546694702', 'Stefano Next Level spray 150 ml', 'DESOD STEFANO NEXT LEVEL SPY150MLN', 'Stefano', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7509546073774', 'Stefano Spaz spray 113 g', 'DESOD STEFANO SPAZ SPY 113G', 'Stefano', '113 g', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7509546078434', 'Stefano Alpine Men spray 113 g', 'DESOD STEFANO ALP MEN SPY 113G', 'Stefano', '113 g', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506267917516', 'Honey Keeper Kids avena crema 414 ml', 'CRA HK KIDS OAT 414ML', 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Crema', null),
  ('7509546655055', 'Caprice Volume Control mousse 200 g', 'MOUSSE CAPRICE VOLUM-CTRL 200 G', 'Caprice', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  ('3600542478359', 'Garnier SkinActive jelly carbón agua micelar 400 ml', 'AGUA MIC GARNIER JELLY CARB 400ML', 'Garnier', '400 ml', 'Cuidado personal', 'Facial', 'Solución', null),
  ('7501035911024', 'Colgate Max Fresh Pepper 125 ml', 'C D COLGATE MFP 125ML', 'Colgate', '125 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  ('7509546068909', 'Colgate Triple Acción extra blanco 50 ml', 'C D COLG TRIPL-ACC EXTBL 50ML', 'Colgate', '50 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546068909.jpg'),
  ('7506425629442', 'Escudo solución antiséptica para manos spray 200 ml', 'ESCUDO SOL ANTISEP P/MAN SPY 200ML ENE27', 'Escudo', '200 ml', 'Cuidado personal', 'Higiene', 'Spray', null),
  ('7702018913954', 'Gillette Clear Wave 3× roll-on 60 g', 'DESOD GTTE 3X CL WAVE R-ON 60G OCT26', 'Gillette', '60 g', 'Cuidado personal', 'Desodorante', 'Roll-on', 'https://www.farmacapital.mx/catalogo-propia/cm-7702018913954.jpg'),
  ('7500435168991', 'Herbal Essences Extra Control mousse 200 g', 'MOUSSE HERBAL ESS EXTR CONT 200G', 'Herbal Essences', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  ('7509546698137', 'Colgate Luminous White Coco Brillante 66 ml', 'C D COLGATE LUMIN W COHIT BRILL 66MLN', 'Colgate', '66 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  ('78926523', 'Rexona Woman Antibacterial Emotional roll-on 50 g', 'DESOD REXONA WOM AEMOT R-ON 50G', 'Rexona', '50 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7509546674018', 'Colgate Luminous White Carbón 66 ml', 'C D COLGATE LUMIN WHIT CARBON 66ML', 'Colgate', '66 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', null),
  ('7509546000350', 'Colgate Triple Acción 150 ml', 'C D COLGATE TRIPLE ACC 150ML FEB27', 'Colgate', '150 ml', 'Cuidado personal', 'Higiene bucal', 'Pasta dental', 'https://www.farmacapital.mx/catalogo-propia/cm-7509546000350.jpg'),
  ('7509546654997', 'Caprice Final Touch mousse 200 g', 'MOUSSE CAPRICE FINAL TOUCH 200 G', 'Caprice', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', null),
  ('814266022610', 'Honey Keeper Kids miel shampoo 414 ml', 'SH HK KIDS HONEY', 'Honey Keeper', '414 ml', 'Cuidado personal', 'Infantil', 'Shampoo', null),
  ('7500435169035', 'Herbal Essences Rizos mousse 200 g', 'MOUSSE HERBAL ESS RIZO 200G', 'Herbal Essences', '200 g', 'Cuidado personal', 'Cabello', 'Mousse', 'https://www.farmacapital.mx/catalogo-propia/cm-7500435169035.jpg'),
  ('7891024028827', 'Colgate Total 12 Clean enjuague 60 ml', 'ENJ BUC COLGATE TOTAL12 CLEAN 60ML', 'Colgate', '60 ml', 'Cuidado personal', 'Higiene bucal', 'Enjuague', null),
  ('3616303440534', 'Adidas Control spray 150 ml', 'ADIDAS 150ML SPY CONTROL', 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('7506267923654', 'Honey Keeper gel manzanilla y miel 200 ml', 'GEL HONEY KEEPER MZNILL MIE 200ML', 'Honey Keeper', '200 ml', 'Cuidado personal', 'Cabello', 'Gel', null),
  ('7896015592837', 'Sensodyne Gentle Care extra suave 3 pzas', 'CEP SENSODYNE GENTLE CARE XTR SUAV 3PZ', 'Sensodyne', '3 pzas', 'Cuidado personal', 'Higiene bucal', 'Cepillo', null),
  ('3616303441173', 'Adidas Dynamic Pulse spray 150 ml', 'ADIDAS 150ML SPY DYNAMIC PULSE', 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-3616303441173.jpg'),
  ('759684900280', 'Jaloma agua de rosas spray 130 ml', 'JALOMA AGUA DE ROSAS 130ML SPRAY', 'Jaloma', '130 ml', 'Cuidado personal', 'Facial', 'Spray', null),
  ('7891024027363', 'Colgate Plax Ice Infinity enjuague 60 ml', 'ENJ BUC PLAX ICE INFINITY 60ML', 'Colgate', '60 ml', 'Cuidado personal', 'Higiene bucal', 'Enjuague', 'https://www.farmacapital.mx/catalogo-propia/cm-7891024027363.jpg'),
  ('3616303842550', 'Adidas Fresh Endurance spray 150 ml', 'ADIDAS 150ML SPY FRESH ENDURANCE', 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('3616303441302', 'Adidas Team Force spray 150 ml', 'ADIDAS 150ML SPY TEAMFORCE', 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', null),
  ('3616303842420', 'Adidas Power Booster spray 150 ml', 'ADIDAS 150ML SPY POWER BOOSTER', 'Adidas', '150 ml', 'Cuidado personal', 'Desodorante', 'Spray', 'https://www.farmacapital.mx/catalogo-propia/cm-3616303842420.jpg'),
  ('7891024183182', 'Colgate hilo dental encerado 25 m', 'HILO DENT COLGATE ENCERA 25M', 'Colgate', '25 m', 'Cuidado personal', 'Higiene bucal', 'Hilo dental', null),
  ('070942302463', 'GUM Go-Betweens microfino C/6', 'CEP DENT GUM GO-BET MICROFINO C/6', 'GUM', '6 pzas', 'Cuidado personal', 'Higiene bucal', 'Cepillo interdental', null),
  ('759684313295', 'Jaloma atomizador Mertodol blanco 60 ml', 'JALOMA ATOMIZADOR 60ML MERTODOL BLANCO', 'Jaloma', '60 ml', 'Botiquín', 'Botiquín', 'Atomizador', null),
  ('75075996', 'Rexona Happy Morning 48 h roll-on 50 ml', 'DESOD REXON HAPPY MOR 48H R-ON 50ML', 'Rexona', '50 ml', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('7509552780956', 'Obao Men Tato Rebel roll-on 65 g', 'DESOD OBAO MEN TATO REBEL R-ON65', 'Obao', '65 g', 'Cuidado personal', 'Desodorante', 'Roll-on', null),
  ('070942303460', 'GUM Trav-Ler interdental 0.8 mm', 'CEP DENT GUM TRAV-LER INTERDENTA 0.8', 'GUM', '1 pza', 'Cuidado personal', 'Higiene bucal', 'Cepillo interdental', null),
  ('7501033204920', 'Speed Stick Xtreme Night crema 30 g', 'DESOD SPEED S XTREM 48H CRA30G S N', 'Speed Stick', '30 g', 'Cuidado personal', 'Desodorante', 'Crema', 'https://www.farmacapital.mx/catalogo-propia/cm-7501033204920.jpg');

update public.productos p
set
  nombre = t.nombre,
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
from _fc_cm_nom t
where p.id = public.fc_buscar_producto_escaneo(t.ean)
  and upper(btrim(p.nombre)) = upper(btrim(t.snap));

select
  count(*) filter (where upper(btrim(p.nombre)) = upper(btrim(t.snap))) as siguen_nombre_ticket,
  count(*) filter (where p.nombre = t.nombre) as ya_mostrador,
  count(*) as lineas
from _fc_cm_nom t
left join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean);

select p.sku, left(p.nombre, 56) as nombre, p.marca, p.proveedor, p.stock
from _fc_cm_nom t
join public.productos p on p.id = public.fc_buscar_producto_escaneo(t.ean)
order by p.nombre;

commit;
