-- Actualiza marca, presentación, principio activo y nombre limpio
-- Filas: 597
-- Ejecutar UNA vez en Supabase SQL Editor

begin;

-- 440393 L1 | TERFICHO 40 CAPS 100 MG
update public.productos set nombre = 'Terficho', marca = 'Terficho', presentacion = '40 CAPSULAS', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-F967863B';

-- 440393 L2 | LEVOFLOXACINO 7 TAB 500 MG
update public.productos set nombre = 'Levofloxacino', presentacion = '7 TABLETAS', principio_activo = 'LEVOFLOXACINO', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-C721E8D7';

-- 440393 L3 | CINA 7 TAB 750 MG
update public.productos set nombre = 'Cina', presentacion = '7 TABLETAS', principio_activo = 'CINA', concentracion = '750 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-B25B4654';

-- 440393 L4 | ALOPURINOL 20 TAB 300 MG
update public.productos set nombre = 'Alopurinol', presentacion = '20 TABLETAS', principio_activo = 'ALOPURINOL', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-ACA2A2F6';

-- 440393 L5 | VERNISEN 6 TAB 200 MG
update public.productos set nombre = 'Vernisen', marca = 'Vernisen', presentacion = '6 TABLETAS', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-174824A0';

-- 440393 L6 | AMIFARIN 20 CAPS 500 MG
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-D5AC44CA';

-- 440393 L7 | CLINDAMICINA FA 600MG/4ML
update public.productos set nombre = 'Clindamicina', presentacion = 'FRASCO AMPULA', principio_activo = 'CLINDAMICINA', concentracion = '600MG/4ML', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-9A4E4C31';

-- 440393 L8 | CEFALVER 12 TAB 1 G
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '12 TABLETAS', concentracion = '1 G', forma_farmaceutica = 'TABLETAS' where sku = 'FC-40CE757D';

-- 440393 L9 | CEFAROXIL 15 TAB 500/30 MG
update public.productos set nombre = 'Cefaroxil', marca = 'Cefaroxil', presentacion = '15 TABLETAS', concentracion = '500/30 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-B18E386A';

-- 440393 L10 | CLOXAN 20 COMP 30 MG
update public.productos set nombre = 'Cloxan', marca = 'Cloxan', presentacion = '20 COMPRIMIDOS', concentracion = '30 MG', forma_farmaceutica = 'COMPRIMIDOS' where sku = 'FC-1DA570E3';

-- 440393 L11 | CEFAGEN 1 SUSP 250MG/5/50 ML
update public.productos set nombre = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFAGEN', concentracion = '250MG/5/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-A455EE80';

-- 440393 L12 | CEFAGEN 1 SUSP 125MG/5/50 ML
update public.productos set nombre = 'Cefagen', presentacion = '1 SUSPENSION', principio_activo = 'CEFAGEN', concentracion = '125MG/5/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-E374F23E';

-- 440393 L13 | KLARIX 1 SUSP 250MG/5ML 60 ML
update public.productos set nombre = 'Klarix', presentacion = '1 SUSPENSION', principio_activo = 'KLARIX', concentracion = '250MG/5ML 60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-8FB65B79';

-- 440393 L14 | CEFAGEN 10 TAB 250 MG
update public.productos set nombre = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFAGEN', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-2EDC6E3B';

-- 440393 L15 | BISOPROLOL 30 TAB 2.5 MG
update public.productos set nombre = 'Bisoprolol', presentacion = '30 TABLETAS', principio_activo = 'BISOPROLOL', concentracion = '2.5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-C101D5B1';

-- 440393 L16 | CHARLYN 3 TAB 500 MG
update public.productos set nombre = 'Charlyn', presentacion = '3 TABLETAS', principio_activo = 'CHARLYN', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-7AF7ACB5';

-- 440393 L17 | CLINDAMICINA 16 CAP 300 MG
update public.productos set nombre = 'Clindamicina', presentacion = '16 CAPSULAS', principio_activo = 'CLINDAMICINA', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-CF18C740';

-- 440393 L18 | FASICLOR 15 CAPS 500 MG
update public.productos set nombre = 'Fasiclor', presentacion = '15 CAPSULAS', principio_activo = 'FASICLOR', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-E4EFC4C2';

-- 440393 L19 | CEPOBROM 12 CAPS 500/0.782 MG
update public.productos set nombre = 'Cepobrom', presentacion = '12 CAPSULAS', principio_activo = 'CEPOBROM', concentracion = '500/0.782 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-6EAD98A9';

-- 440393 L20 | DICLOFEN 12 CAPS 500 MG
update public.productos set nombre = 'Diclofen', presentacion = '12 CAPSULAS', principio_activo = 'DICLOFEN', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-CF719C07';

-- 440393 L21 | GENTAMICINA 5 AMP 160MG/2ML
update public.productos set nombre = 'Gentamicina', presentacion = '5 AMPOLLETA', principio_activo = 'GENTAMICINA', concentracion = '160MG/2ML', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-60F627D5';

-- 440393 L22 | EPICIN 20 CAPS 500 MG
update public.productos set nombre = 'Epicin', presentacion = '20 CAPSULAS', principio_activo = 'EPICIN', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-48F732CF';

-- 440393 L23 | KNORICIN 1 SUSP 125MG/5/60 ML
update public.productos set nombre = 'Knoricin', presentacion = '1 SUSPENSION', principio_activo = 'KNORICIN', concentracion = '125MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-72C28BC1';

-- 440393 L24 | CEFAGEN 10 TAB 500 MG
update public.productos set nombre = 'Cefagen', presentacion = '10 TABLETAS', principio_activo = 'CEFAGEN', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-443C330E';

-- 440393 L25 | CEFALVER 20 CAPS 500 MG
update public.productos set nombre = 'Cefalver', marca = 'Cefalver', presentacion = '20 CAPSULAS', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-492D652F';

-- 440393 L26 | TROPHARMA 20 TAB 500 MG
update public.productos set nombre = 'Tropharma', presentacion = '20 TABLETAS', principio_activo = 'TROPHARMA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-86A95D07';

-- 440393 L27 | KURTOSIL 1 CMA 20/1 MG
update public.productos set nombre = 'Kurtosil 1 Cma 20/1 Mg' where sku = 'FC-697EEAD0';

-- 440393 L28 | DIVILTAC 1 FA 150/10MG/1 ML
update public.productos set nombre = 'Diviltac', presentacion = '1 FRASCO AMPULA', principio_activo = 'DIVILTAC', concentracion = '150/10MG/1', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-830BF3FB';

-- 440393 L29 | FASICLOR 1 SUSP 375MG/5/50 ML
update public.productos set nombre = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'FASICLOR', concentracion = '375MG/5/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-F3E734A0';

-- 440393 L30 | CIPROFLOXACINO 12 TAB 250 MG
update public.productos set nombre = 'Ciprofloxacino', presentacion = '12 TABLETAS', principio_activo = 'CIPROFLOXACINO', concentracion = '250 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-74A5ABEE';

-- 440393 L31 | NAMIFEN 20 TAB 500 MG
update public.productos set nombre = 'Namifen', presentacion = '20 TABLETAS', principio_activo = 'NAMIFEN', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-AEA8C8DA';

-- 440393 L32 | CEFALEXINA 20 CAPS 500 MG
update public.productos set nombre = 'Cefalexina', presentacion = '20 CAPSULAS', principio_activo = 'CEFALEXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-2005DD57';

-- 440393 L33 | PENTIBROXIL 16 CAPS 500/30 MG
update public.productos set nombre = 'Pentibroxil', presentacion = '16 CAPSULAS', principio_activo = 'PENTIBROXIL', concentracion = '500/30 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-B4477A00';

-- 440393 L34 | ACROXIL-C 1 SUSP 250MG/5/60 ML
update public.productos set nombre = 'Acroxil-C', presentacion = '1 SUSPENSION', principio_activo = 'ACROXIL-C', concentracion = '250MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-85BDBD3D';

-- 440393 L35 | PENTIVER 1 SUSP 500MG/5/60 ML
update public.productos set nombre = 'Pentiver', presentacion = '1 SUSPENSION', principio_activo = 'PENTIVER', concentracion = '500MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-7AA38F97';

-- 440393 L36 | FASICLOR 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'FASICLOR', concentracion = '250MG/5/75', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-9538F7D6';

-- 440393 L37 | FASICLOR 1 SUSP 125MG/5/75 ML
update public.productos set nombre = 'Fasiclor', presentacion = '1 SUSPENSION', principio_activo = 'FASICLOR', concentracion = '125MG/5/75', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-01B2F362';

-- 440393 L38 | MEXAPIN 1 SUSP 125MG/5/60 ML
update public.productos set nombre = 'Mexapin', presentacion = '1 SUSPENSION', principio_activo = 'MEXAPIN', concentracion = '125MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-50587FA6';

-- 440393 L39 | PENTIVER 1 SUSP 250MG/5/90 ML
update public.productos set nombre = 'Pentiver', presentacion = '1 SUSPENSION', principio_activo = 'PENTIVER', concentracion = '250MG/5/90', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-B72A6420';

-- 440393 L40 | AZITROMICINA 1 SUSP 200MG/5/15 ML
update public.productos set nombre = 'Azitromicina', presentacion = '1 SUSPENSION', principio_activo = 'AZITROMICINA', concentracion = '200MG/5/15', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-D9391288';

-- 440393 L41 | CLARITROMICINA 10 TAB 500 MG
update public.productos set nombre = 'Claritromicina', presentacion = '10 TABLETAS', principio_activo = 'CLARITROMICINA', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-41339950';

-- 440393 L42 | NALIXONE 20 TAB 500/50 MG
update public.productos set nombre = 'Nalixone', presentacion = '20 TABLETAS', principio_activo = 'NALIXONE', concentracion = '500/50 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-E6112F15';

-- 440393 L43 | PENIPOT 1 FA 800,000 UI
update public.productos set nombre = 'Penipot', presentacion = '1 FRASCO AMPULA', principio_activo = 'PENIPOT', concentracion = '800,000 UI', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-F183C6E9';

-- 440393 L44 | AMOXICILINA 12 CAPS 500 MG
update public.productos set nombre = 'Amoxicilina', presentacion = '12 CAPSULAS', principio_activo = 'AMOXICILINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-A0D320D1';

-- 440393 L45 | ACIDO ACETILSALICILICO EF 20 TAB 300 MG
update public.productos set nombre = 'Acido Acetilsalicilico Ef', presentacion = '20 TABLETAS', principio_activo = 'ACIDO ACETILSALICILICO EF', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-95779436';

-- 440393 L46 | VANMOXOL 1 SUSP 250/15MG/5/90 ML
update public.productos set nombre = 'Vanmoxol', presentacion = '1 SUSPENSION', principio_activo = 'VANMOXOL', concentracion = '250/15MG/5/90', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-4C621D07';

-- 440393 L47 | VALCLAN 10 TAB 500/125 MG
update public.productos set nombre = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'VALCLAN', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-022543CD';

-- 440393 L48 | BENCIL/BENZ COMPL 1 FA 1,2 U 3 ML
update public.productos set nombre = 'Bencil/Benz Compl', presentacion = '1 FRASCO AMPULA', principio_activo = 'BENCIL/BENZ COMPL', concentracion = '1,2 U 3', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-64EB83AA';

-- 440393 L49 | AMPICILINA 1 FA 1G/5 ML
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '1G/5', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-D210172A';

-- 440393 L50 | AMPICILINA 1 FA 500MG/2 ML
update public.productos set nombre = 'Ampicilina', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMPICILINA', concentracion = '500MG/2', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-7F90064A';

-- 440393 L51 | AMPICILINA 10 TAB 1 G
update public.productos set nombre = 'Ampicilina', presentacion = '10 TABLETAS', principio_activo = 'AMPICILINA', concentracion = '1 G', forma_farmaceutica = 'TABLETAS' where sku = 'FC-F82A6E4B';

-- 440393 L52 | CLAMOXIN 10 TAB 500/125 MG
update public.productos set nombre = 'Clamoxin', presentacion = '10 TABLETAS', principio_activo = 'CLAMOXIN', concentracion = '500/125 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-5F30F9D4';

-- 440393 L53 | ACIDO ACETILSALICILICO 30 TAB 100MG
update public.productos set nombre = 'Acido Acetilsalicilico', presentacion = '30 TABLETAS', principio_activo = 'ACIDO ACETILSALICILICO', concentracion = '100MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-7D1D9857';

-- 440393 L54 | CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50 ML
update public.productos set nombre = 'Clamoxin 12H Jr', presentacion = '1 SUSPENSION', principio_activo = 'CLAMOXIN 12H JR', concentracion = '400/57MG/5/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-516C2E89';

-- 440393 L55 | ACROXIL-C 12 CAPS 500/8 MG
update public.productos set nombre = 'Acroxil-C', presentacion = '12 CAPSULAS', principio_activo = 'ACROXIL-C', concentracion = '500/8 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-05965071';

-- 440393 L56 | VANDIL 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Vandil', presentacion = '1 SUSPENSION', principio_activo = 'VANDIL', concentracion = '250MG/5/75', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-930E0B1B';

-- 440393 L57 | ACIDO URSODESOXICOLICO 50 CAP 250 MG
update public.productos set nombre = 'Acido Ursodesoxicolico', presentacion = '50 CAPSULAS', principio_activo = 'ACIDO URSODESOXICOLICO', concentracion = '250 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-405A75E3';

-- 440393 L58 | VALCLAN 10 TAB 875/125 MG
update public.productos set nombre = 'Valclan', presentacion = '10 TABLETAS', principio_activo = 'VALCLAN', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-D06E54FE';

-- 440393 L59 | PENIPOT 1 FA 400,000 UI
update public.productos set nombre = 'Penipot', presentacion = '1 FRASCO AMPULA', principio_activo = 'PENIPOT', concentracion = '400,000 UI', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-3A4583F3';

-- 440393 L60 | CLAMOXIN 12H 10 TAB 875/125 MG
update public.productos set nombre = 'Clamoxin 12H', presentacion = '10 TABLETAS', principio_activo = 'CLAMOXIN 12H', concentracion = '875/125 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-F22C72BE';

-- 440393 L61 | CLAMOXIN 1 SUSP 250/62.5MG/5/60 ML
update public.productos set nombre = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'CLAMOXIN', concentracion = '250/62.5MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-F48FF7EF';

-- 440393 L62 | BENEVENTOL 3 CAPS 400 MG
update public.productos set nombre = 'Beneventol', presentacion = '3 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-4BD80686';

-- 440393 L63 | GIMALXINA 1 SUSP 250MG/5/75 ML
update public.productos set nombre = 'Gimalxina', presentacion = '1 SUSPENSION', principio_activo = 'GIMALXINA', concentracion = '250MG/5/75', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-974EE5FD';

-- 440393 L64 | CLAMOXIN S 1 SUSP 600/42.9MG/50 ML
update public.productos set nombre = 'Clamoxin S', presentacion = '1 SUSPENSION', principio_activo = 'CLAMOXIN S', concentracion = '600/42.9MG/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-0E0A9E42';

-- 440393 L65 | CLAMOXIN 1 SUSP 125/31.25MG/5/60 ML
update public.productos set nombre = 'Clamoxin', presentacion = '1 SUSPENSION', principio_activo = 'CLAMOXIN', concentracion = '125/31.25MG/5/60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-6519183A';

-- 440393 L66 | CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40 ML
update public.productos set nombre = 'Clamoxin 12H Ped', presentacion = '1 SUSPENSION', principio_activo = 'CLAMOXIN 12H PED', concentracion = '200/28.5MG/40', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-DDFBABDF';

-- 440393 L67 | ACEMETACINA 14 CAPS 90 MG
update public.productos set nombre = 'Acemetacina', presentacion = '14 CAPSULAS', principio_activo = 'ACEMETACINA', concentracion = '90 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-C9F4ACCC';

-- 440393 L68 | ASPITAK-P 30 COMP 100 MG
update public.productos set nombre = 'Aspitak-P', presentacion = '30 COMPRIMIDOS', principio_activo = 'ASPITAK-P', concentracion = '100 MG', forma_farmaceutica = 'COMPRIMIDOS' where sku = 'FC-17376CAE';

-- 440393 L69 | BENEVENTOL 6 CAPS 400 MG
update public.productos set nombre = 'Beneventol', presentacion = '6 CAPSULAS', principio_activo = 'BENEVENTOL', concentracion = '400 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-369D1689';

-- 440393 L70 | LESACLOR (MACLOV) 35 TAB 400 MG
update public.productos set nombre = 'Lesaclor (Maclov)', presentacion = '35 TABLETAS', principio_activo = 'LESACLOR (MACLOV)', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-B69FCBF4';

-- 440393 L71 | AMOXICILINA 1 SUSP 500MG/5/75 ML
update public.productos set nombre = 'Amoxicilina', presentacion = '1 SUSPENSION', principio_activo = 'AMOXICILINA', concentracion = '500MG/5/75', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-F4E9C71F';

-- 440393 L72 | GIMALXINA 12 CAPS 500 MG
update public.productos set nombre = 'Gimalxina', presentacion = '12 CAPSULAS', principio_activo = 'GIMALXINA', concentracion = '500 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-428A228F';

-- 440393 L73 | ACICLOVIR 35 TAB 400 MG
update public.productos set nombre = 'Aciclovir', presentacion = '35 TABLETAS', principio_activo = 'ACICLOVIR', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-FD845E68';

-- 440393 L74 | OXIVAG 4 TAB 70 MG
update public.productos set nombre = 'Oxivag', presentacion = '4 TABLETAS', principio_activo = 'OXIVAG', concentracion = '70 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-B2123139';

-- 440393 L75 | AMIKACINA 2 AMP 500MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '2 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-11294615';

-- 440393 L76 | AMIKACINA 1 AMP 500MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '500MG/2', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-1FEA2FB7';

-- 440393 L77 | PERLUDIL 1 FA 150/10 MG
update public.productos set nombre = 'Perludil', marca = 'Perludil', presentacion = '1 FRASCO AMPULA', concentracion = '150/10 MG', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-AA905BF7';

-- 440393 L78 | BACTIVER 20 TAB 400/80 MG
update public.productos set nombre = 'Bactiver', presentacion = '20 TABLETAS', principio_activo = 'BACTIVER', concentracion = '400/80 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-AE5EEDF7';

-- 440393 L79 | BACTIVER F 16 TAB 160/800 MG
update public.productos set nombre = 'Bactiver F', presentacion = '16 TABLETAS', principio_activo = 'BACTIVER F', concentracion = '160/800 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-F8691496';

-- 440393 L80 | REDALIP 30 TAB 200 MG
update public.productos set nombre = 'Redalip', presentacion = '30 TABLETAS', principio_activo = 'REDALIP', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-6074BB64';

-- 440393 L81 | LINCOMICINA 600MG/2ML 6 AMPOLLETAS
update public.productos set nombre = 'Lincomicina 600Mg/ 6 Ampolletas', presentacion = '2 ML' where sku = 'FC-E826D304';

-- 440393 L82 | CLOXAN 1 SOL 300MG/120ML
update public.productos set nombre = 'Cloxan 1', marca = 'Cloxan', presentacion = 'SOL', concentracion = '300MG/120ML', forma_farmaceutica = 'SOL' where sku = 'FC-4F737E93';

-- 440393 L83 | CELESBITAN 1 FA C/BER 6MG/2 ML
update public.productos set nombre = 'Celesbitan', presentacion = '1 FRASCO AMPULA', principio_activo = 'CELESBITAN', concentracion = 'C/BER 6MG/2', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-DB3B2584';

-- 440393 L84 | CEFOTAXIMA I.M. 1 FA 1G/4 ML
update public.productos set nombre = 'Cefotaxima I.M', presentacion = '1 FRASCO AMPULA', principio_activo = 'CEFOTAXIMA I.M', concentracion = '1G/4', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-22B18244';

-- 440393 L85 | AMLODIPINO 100 TAB 5 MG
update public.productos set nombre = 'Amlodipino', presentacion = '100 TABLETAS', principio_activo = 'AMLODIPINO', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-4A0245DA';

-- 440393 L86 | DEGORTZIN 1 SOL 100 MG/50 ML
update public.productos set nombre = 'Degortzin 1', marca = 'Degortzin', presentacion = 'SOL', concentracion = '100 MG/50', forma_farmaceutica = 'SOL' where sku = 'FC-29670370';

-- 440393 L87 | WEXPEC 1 SOL 7.5/2MG/5/120 ML
update public.productos set nombre = 'Wexpec 1', marca = 'Wexpec', presentacion = 'SOL', concentracion = '7.5/2MG/5/120', forma_farmaceutica = 'SOL' where sku = 'FC-69A3C416';

-- 440393 L88 | SIBICOS 1 CMA 1/100/20 G
update public.productos set nombre = 'Sibicos 1 Cma 1/100/', presentacion = '20 G' where sku = 'FC-F817BC3A';

-- 440393 L89 | BUDESONIDA 5 AMP 0.250MG/2ML
update public.productos set nombre = 'Budesonida', presentacion = '5 AMPOLLETA', principio_activo = 'BUDESONIDA', concentracion = '0.250MG/2ML', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-447B30F9';

-- 440393 L90 | DISON DEX 1 FA 5/2 MG
update public.productos set nombre = 'Dison Dex', presentacion = '1 FRASCO AMPULA', principio_activo = 'DISON DEX', concentracion = '5/2 MG', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-1CF27DC9';

-- 440393 L91 | CINARIZINA 60 TAB 75 MG
update public.productos set nombre = 'Cinarizina', presentacion = '60 TABLETAS', principio_activo = 'CINARIZINA', concentracion = '75 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-3CAA7C5C';

-- 440393 L92 | CELECOXIB 10 CAPS 200MG
update public.productos set nombre = 'Celecoxib', presentacion = '10 CAPSULAS', principio_activo = 'CELECOXIB', concentracion = '200MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-E6B50AC3';

-- 440393 L93 | PRCTAISOL 1 SUSP/AER 200 DOSIS 12.80 G
update public.productos set nombre = 'Prctaisol 1 Susp/Aer 200 Dosis', presentacion = '12.80 G' where sku = 'FC-6B2ADEE9';

-- 440393 L94 | CALCIO EFE 12 COMP 500 MG
update public.productos set nombre = 'Calcio Efe', presentacion = '12 COMPRIMIDOS', principio_activo = 'CALCIO EFE', concentracion = '500 MG', forma_farmaceutica = 'COMPRIMIDOS' where sku = 'FC-DB4A39AE';

-- 440393 L95 | BECATRIM N CALCITRIOL 30 CAPS 0.25 MCG
update public.productos set nombre = 'Becatrim N Calcitriol', presentacion = '30 CAPSULAS', principio_activo = 'BECATRIM N CALCITRIOL', concentracion = '0.25 MCG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-FA3D96E6';

-- 440393 L96 | GENTAMICINA 25 COMP 1 MG
update public.productos set nombre = 'Gentamicina', presentacion = '25 COMPRIMIDOS', principio_activo = 'GENTAMICINA', concentracion = '1 MG', forma_farmaceutica = 'COMPRIMIDOS' where sku = 'FC-63975795';

-- 440393 L97 | BUDIMIN 20 TAB 1 MG
update public.productos set nombre = 'Budimin', presentacion = '20 TABLETAS', principio_activo = 'BUDIMIN', concentracion = '1 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-C6C20517';

-- 440393 L98 | BITENVER 30 TAB 24 MG
update public.productos set nombre = 'Bitenver', presentacion = '30 TABLETAS', principio_activo = 'BITENVER', concentracion = '24 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-58DB24C4';

-- 440393 L99 | SUPRATEX DAC 1 SOL 300/600 MG 120 ML
update public.productos set nombre = 'Supratex Dac 1', marca = 'Supratex', presentacion = 'SOL', concentracion = '300/600 MG 120', forma_farmaceutica = 'SOL' where sku = 'FC-1FFBB505';

-- 440393 L100 | ODIVITOR 10 TAB 20 MG
update public.productos set nombre = 'Odivitor', presentacion = '10 TABLETAS', principio_activo = 'ODIVITOR', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-A909ABC0';

-- 440393 L101 | CAPTOPRIL 30 TAB 25 MG
update public.productos set nombre = 'Captopril', presentacion = '30 TABLETAS', principio_activo = 'CAPTOPRIL', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-82F88FED';

-- 440393 L102 | BUDENOVA SUSP 125 MG/ML 5 AMP 2ML
update public.productos set nombre = 'Budenova Susp 125 Mg/', presentacion = '5 AMPOLLETA', principio_activo = 'BUDENOVA SUSP 125 MG/', concentracion = '2ML', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-6C2878CF';

-- 440393 L103 | AMLODIPINO 30 TAB 5 MG
update public.productos set nombre = 'Amlodipino', presentacion = '30 TABLETAS', principio_activo = 'AMLODIPINO', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-3B001F9B';

-- 440393 L104 | LESACLOR 1 SUSP 200MG/5/125 ML
update public.productos set nombre = 'Lesaclor', presentacion = '1 SUSPENSION', principio_activo = 'LESACLOR', concentracion = '200MG/5/125', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-B25094C4';

-- 440393 L105 | RAMCINET 10 TAB 10 MG
update public.productos set nombre = 'Ramcinet', presentacion = '10 TABLETAS', principio_activo = 'RAMCINET', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-26EA40A4';

-- 440393 L106 | CARBAMAZEPINA 20 TAB 200 MG
update public.productos set nombre = 'Carbamazepina', presentacion = '20 TABLETAS', principio_activo = 'CARBAMAZEPINA', concentracion = '200 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-885F2723';

-- 440393 L107 | ERISPAN 1 FA 4MG/3 ML
update public.productos set nombre = 'Erispan', presentacion = '1 FRASCO AMPULA', principio_activo = 'ERISPAN', concentracion = '4MG/3', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-DF8ADDAB';

-- 440393 L108 | ERISPAN 1 FA 8MG/2 ML
update public.productos set nombre = 'Erispan', presentacion = '1 FRASCO AMPULA', principio_activo = 'ERISPAN', concentracion = '8MG/2', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-50AC2C82';

-- 440393 L109 | BUDESONIDA 1 SUSP NEB AMP 0.500MG
update public.productos set nombre = 'Budesonida', presentacion = '1 SUSPENSION', principio_activo = 'BUDESONIDA', concentracion = 'NEB AMP 0.500MG', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-281E0F22';

-- 440393 L110 | AMIFARIN 1 SUSP 250MG 60 ML
update public.productos set nombre = 'Amifarin', marca = 'Amifarin', presentacion = '1 SUSPENSION', concentracion = '250MG 60', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-9F67BB73';

-- 440393 L111 | HASPEN 3 AMP 20 MG/1 ML
update public.productos set nombre = 'Haspen', presentacion = '3 AMPOLLETA', principio_activo = 'HASPEN', concentracion = '20 MG/1', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-4FD413D2';

-- 440393 L112 | CLOPHIVEN 200 DOSIS 50 MCG/15 G
update public.productos set nombre = 'Clophiven 200 Dosis 50 Mcg/', presentacion = '15 G' where sku = 'FC-0BDE9283';

-- 440393 L113 | AMLODIPINO 100 TAB 5 MG
update public.productos set nombre = 'Amlodipino', presentacion = '100 TABLETAS', principio_activo = 'AMLODIPINO', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-97BEFA1A';

-- 440393 L114 | BACTIVER 1 SUSP 40/200/5/120 ML
update public.productos set nombre = 'Bactiver', presentacion = '1 SUSPENSION', principio_activo = 'BACTIVER', concentracion = '40/200/5/120', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-DEAF33B0';

-- 440393 L115 | SONBLEFAM S 1 CMA 100 G/40 G
update public.productos set nombre = 'Sonblefam S 1 Cma /40 G', presentacion = '100 G' where sku = 'FC-77FE5C83';

-- 440393 L116 | CEFTRIAXONA I.M. 1 FA 1G/3.5 ML
update public.productos set nombre = 'Ceftriaxona I.M', presentacion = '1 FRASCO AMPULA', principio_activo = 'CEFTRIAXONA I.M', concentracion = '1G/3.5', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-C636D8EA';

-- 440393 L117 | LAUR AQUITO 500/100/30/4 MG 3 AMP
update public.productos set nombre = 'Laur Aquito 500/100/30/4 Mg', presentacion = '3 AMPOLLETA', principio_activo = 'LAUR AQUITO 500/100/30/4 MG', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-44B6751A';

-- 440393 L118 | BENEVENTOL 1 SUSP 100MG/5ML/50 ML
update public.productos set nombre = 'Beneventol', presentacion = '1 SUSPENSION', principio_activo = 'BENEVENTOL', concentracion = '100MG/5ML/50', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-9B93AC4C';

-- 440393 L119 | AMPIGRIN AD 3 AMP 500/500/100/30MG/3 ML
update public.productos set nombre = 'Ampigrin Ad', presentacion = '3 AMPOLLETA', principio_activo = 'AMPIGRIN AD', concentracion = '500/500/100/30MG/3', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-2001A890';

-- 440393 L120 | AMPIGRIN INF 3 AMP 250/200/100/30MG/3 ML
update public.productos set nombre = 'Ampigrin Inf', presentacion = '3 AMPOLLETA', principio_activo = 'AMPIGRIN INF', concentracion = '250/200/100/30MG/3', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-DE106642';

-- 440393 L121 | AMCEF I.M. 1 FA 1G/3.5 ML
update public.productos set nombre = 'Amcef I.M', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMCEF I.M', concentracion = '1G/3.5', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-BE76D409';

-- 440393 L122 | AMCEF I.M. 1 FA 500MG/2 ML
update public.productos set nombre = 'Amcef I.M', presentacion = '1 FRASCO AMPULA', principio_activo = 'AMCEF I.M', concentracion = '500MG/2', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-07F04F88';

-- 440393 L123 | CEFTAZIDIMA 1 FA 1G/3 ML
update public.productos set nombre = 'Ceftazidima', presentacion = '1 FRASCO AMPULA', principio_activo = 'CEFTAZIDIMA', concentracion = '1G/3', forma_farmaceutica = 'FRASCO AMPULA' where sku = 'FC-357D4A17';

-- 440393 L124 | NORQUINOL 20 TAB 400 MG
update public.productos set nombre = 'Norquinol', presentacion = '20 TABLETAS', principio_activo = 'NORQUINOL', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-5D9DFA3D';

-- 440393 L125 | CIPROFLOXACINO G.I. 14 TAB 500 MG
update public.productos set nombre = 'Ciprofloxacino G.I', presentacion = '14 TABLETAS', principio_activo = 'CIPROFLOXACINO G.I', concentracion = '500 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-E9C38DC4';

-- 440393 L126 | AMIKACINA 1 AMP 100 MG/2 ML
update public.productos set nombre = 'Amikacina', presentacion = '1 AMPOLLETA', principio_activo = 'AMIKACINA', concentracion = '100 MG/2', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-347A49C7';

-- 440393 L127 | ATORVASTATINA 10 TAB 40 MG
update public.productos set nombre = 'Atorvastatina', presentacion = '10 TABLETAS', principio_activo = 'ATORVASTATINA', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-E4BE37BE';

-- 440393 L128 | FLOSPET 8 TAB 400 MG
update public.productos set nombre = 'Flospet', presentacion = '8 TABLETAS', principio_activo = 'FLOSPET', concentracion = '400 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-1751468C';

-- 440393 L129 | BIOERTER 1 SUSP 250 MG/100 ML
update public.productos set nombre = 'Bioerter', presentacion = '1 SUSPENSION', principio_activo = 'BIOERTER', concentracion = '250 MG/100', forma_farmaceutica = 'SUSPENSION' where sku = 'FC-6898B64F';

-- 440393 L130 | DOLIPROFEN 10 TAB 800 MG
update public.productos set nombre = 'Doliprofen', presentacion = '10 TABLETAS', principio_activo = 'DOLIPROFEN', concentracion = '800 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-CD261CD5';

-- 440393 L131 | GELUBRIN 10 CAPS 600 MG
update public.productos set nombre = 'Gelubrin', presentacion = '10 CAPSULAS', principio_activo = 'GELUBRIN', concentracion = '600 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-5C8C9C11';

-- 440393 L132 | ZITRIASOL 15 CAP 100 MG
update public.productos set nombre = 'Zitriasol', presentacion = '15 CAPSULAS', principio_activo = 'ZITRIASOL', concentracion = '100 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-A23F290E';

-- 440393 L133 | PABESORAG 28 TAB 150/12.5 MG
update public.productos set nombre = 'Pabesorag', presentacion = '28 TABLETAS', principio_activo = 'PABESORAG', concentracion = '150/12.5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-5885E577';

-- 440393 L134 | IBUPRO-CAFE 10 CAPS 400 MG/100 MG
update public.productos set nombre = 'Ibupro-Cafe', presentacion = '10 CAPSULAS', principio_activo = 'IBUPRO-CAFE', concentracion = '400 MG/100 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-3D0F54B7';

-- 440393 L135 | INDARZONA 30 CAPS 25/0.5 MG
update public.productos set nombre = 'Indarzona', presentacion = '30 CAPSULAS', principio_activo = 'INDARZONA', concentracion = '25/0.5 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-F7A2CACF';

-- 440393 L136 | WERMY 15 CAPS 300 MG
update public.productos set nombre = 'Wermy', presentacion = '15 CAPSULAS', principio_activo = 'WERMY', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-50D044FF';

-- 440393 L137 | DIURMESSEL 20 TAB 40 MG
update public.productos set nombre = 'Diurmessel', presentacion = '20 TABLETAS', principio_activo = 'DIURMESSEL', concentracion = '40 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-E535DE28';

-- 440393 L138 | HIDROXON 30 TAB 10 MG
update public.productos set nombre = 'Hidroxon', presentacion = '30 TABLETAS', principio_activo = 'HIDROXON', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-1321B34F';

-- 440393 L139 | COLLUCORT 1 CMA 1% 60 G
update public.productos set nombre = 'Collucort 1 Cma 1%', presentacion = '60 G' where sku = 'FC-1AE9D7E6';

-- 440393 L140 | TRATIDRI 1 GEL 500/50 MG 60 G
update public.productos set nombre = 'Tratidri', presentacion = '1 GEL', principio_activo = 'TRATIDRI', concentracion = '500/50 MG 60 G', forma_farmaceutica = 'GEL' where sku = 'FC-3E863E37';

-- 440393 L141 | ELAPHTERON 20 TAB 100 MG
update public.productos set nombre = 'Elaphteron', presentacion = '20 TABLETAS', principio_activo = 'ELAPHTERON', concentracion = '100 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-9ABFB996';

-- 440393 L142 | AMDORYL 14 CAPS 30 MG
update public.productos set nombre = 'Amdoryl', presentacion = '14 CAPSULAS', principio_activo = 'AMDORYL', concentracion = '30 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-9A37D44A';

-- 440393 L143 | ACETONIDO DE FLUOCINOLONA CMA
update public.productos set nombre = 'Tonido De Fluocinolona Cma', marca = 'Ace' where sku = 'FC-1BF03D35';

-- 440393 L144 | FLUCONAZOL 1 CAPS 150 MG
update public.productos set nombre = 'Fluconazol', presentacion = '1 CAPSULAS', principio_activo = 'FLUCONAZOL', concentracion = '150 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-5BC5F234';

-- 440393 L145 | HIALURONATO DE SODIO 4MG 10 ML
update public.productos set nombre = 'Hialuronato De Sodio 4Mg 10' where sku = 'FC-A2B284E0';

-- 440393 L146 | HIERRO DEX 3 AMP 100 MG/2 ML
update public.productos set nombre = 'Hierro Dex', presentacion = '3 AMPOLLETA', principio_activo = 'HIERRO DEX', concentracion = '100 MG/2', forma_farmaceutica = 'AMPOLLETA' where sku = 'FC-2E79C2D8';

-- 440393 L147 | DIZIVER 20 TAB 25 MG
update public.productos set nombre = 'Diziver', presentacion = '20 TABLETAS', principio_activo = 'DIZIVER', concentracion = '25 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-28A424E5';

-- 440393 L148 | ZUKEDIB 30 TAB 2 MG
update public.productos set nombre = 'Zukedib', presentacion = '30 TABLETAS', principio_activo = 'ZUKEDIB', concentracion = '2 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-52D2A43A';

-- 440393 L149 | ZUKEDIB 30 TAB 4 MG
update public.productos set nombre = 'Zukedib', presentacion = '30 TABLETAS', principio_activo = 'ZUKEDIB', concentracion = '4 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-3D0ED22B';

-- 440393 L150 | PRALEX 28 TAB 10 MG
update public.productos set nombre = 'Pralex', presentacion = '28 TABLETAS', principio_activo = 'PRALEX', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-04D83B46';

-- 440393 L151 | VALGAB 3 IBE 50MG/6ML
update public.productos set nombre = 'Valgab 3 Ibe 50Mg/', presentacion = '6 ML' where sku = 'FC-D11D586A';

-- 440393 L152 | ENALAPRIL 30 TAB 10 MG
update public.productos set nombre = 'Enalapril', presentacion = '30 TABLETAS', principio_activo = 'ENALAPRIL', concentracion = '10 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-53506FA4';

-- 440393 L153 | OVISEN 28 TAB 20 MG
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '28 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-F7DB080D';

-- 440393 L154 | OVISEN 14 TAB 20 MG
update public.productos set nombre = 'Ovisen', marca = 'Ovisen', presentacion = '14 TABLETAS', concentracion = '20 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-FD92D114';

-- 440393 L155 | REGLUSAN 50 TAB 5 MG
update public.productos set nombre = 'Reglusan', presentacion = '50 TABLETAS', principio_activo = 'REGLUSAN', concentracion = '5 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-57925EF3';

-- 440393 L156 | DROSQUIM AD 1 IBE 300/160/200 ML
update public.productos set nombre = 'Drosquim Ad 1 Ibe 300/160/200' where sku = 'FC-AA7B0686';

-- 440393 L157 | DESROTAN 10 TAB 180 MG
update public.productos set nombre = 'Desrotan', presentacion = '10 TABLETAS', principio_activo = 'DESROTAN', concentracion = '180 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-B3B8F9BB';

-- 440393 L158 | DIOSMINA HESPERIDINA 20 TAB 450/50 MG
update public.productos set nombre = 'Diosmina Hesperidina', presentacion = '20 TABLETAS', principio_activo = 'DIOSMINA HESPERIDINA', concentracion = '450/50 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-EADF1484';

-- 440393 L159 | IRBESARTAN 14 TAB 150 MG
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '150 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-262F2A30';

-- 440393 L160 | TUSILEN AD 1 IBE 240/30/50MG/100/118 ML
update public.productos set nombre = 'Tusilen Ad 1 Ibe 240/30/50Mg/100/118' where sku = 'FC-1DAD5EF1';

-- 440393 L161 | IRBESARTAN 14 TAB 300 MG
update public.productos set nombre = 'Irbesartan', presentacion = '14 TABLETAS', principio_activo = 'IRBESARTAN', concentracion = '300 MG', forma_farmaceutica = 'TABLETAS' where sku = 'FC-BDB2E087';

-- 440393 L162 | WERMY 30 CAPS 300 MG
update public.productos set nombre = 'Wermy', presentacion = '30 CAPSULAS', principio_activo = 'WERMY', concentracion = '300 MG', forma_farmaceutica = 'CAPSULAS' where sku = 'FC-759A5EF9';

-- 77827 L1 | Desod Obao R-Nat Coco R-On 65G
update public.productos set nombre = 'R-Nat Coco R-On', marca = 'Obao', presentacion = '65 G' where sku = 'FC-52844825';

-- 77827 L2 | Desod Obao Game 48Hr R-On 65G N
update public.productos set nombre = 'Game 48Hr R-On N', marca = 'Obao', presentacion = '65 G' where sku = 'FC-52933307';

-- 77827 L3 | Desod Obad P/Del R-On 65G
update public.productos set nombre = 'P/Del R-On', marca = 'Obad', presentacion = '65 G' where sku = 'FC-27250612';

-- 77827 L4 | Desod Obao Clas R-On 65G
update public.productos set nombre = 'Clas R-On', marca = 'Obao', presentacion = '65 G' where sku = 'FC-27286017';

-- 77827 L5 | Desod Obao Men Tatto Aqua R-On 65G
update public.productos set nombre = 'Men Tatto Aqua R-On', marca = 'Obao', presentacion = '65 G' where sku = 'FC-52876406';

-- 77827 L6 | Desod Axe Men Young Spy 150Ml
update public.productos set nombre = 'Men Young Spy', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-30622622';

-- 77827 L7 | Desod Axe Icechi E-Frio Spy 150Ml
update public.productos set nombre = 'Icechi E-Frio Spy', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-06213906';

-- 77827 L8 | Desod Rexona Men Marine Spy 150Ml
update public.productos set nombre = 'Men Marine Spy', marca = 'Rexona', presentacion = '150 ML' where sku = 'FC-93037806';

-- 77827 L9 | Desod Obao Men Tato Rebel R-On65
update public.productos set nombre = 'Men Tato Rebel R-On65', marca = 'Obao' where sku = 'FC-55280956';

-- 77827 L10 | Desod Axe Excite Seco Spy 152Ml
update public.productos set nombre = 'Excite Seco Spy', marca = 'Axe', presentacion = '152 ML' where sku = 'FC-93025919';

-- 77827 L11 | Desod Rexona Men V8 Tun Spy 90G
update public.productos set nombre = 'Men V8 Tun Spy', marca = 'Rexona', presentacion = '90 G' where sku = 'FC-93022567';

-- 77827 L12 | Desod Axe Intense 48H Spy 150Ml
update public.productos set nombre = 'Intense 48H Spy', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-06244795';

-- 77827 L13 | Desod Rexona 48H Happy-M Stick 45G
update public.productos set nombre = '48H Happy-M Stick', marca = 'Rexona', presentacion = '45 G' where sku = 'FC-75076009';

-- 77827 L14 | Desod Axe Men Dark Temp Spy150Ml
update public.productos set nombre = 'Men Dark Temp Spy150Ml', marca = 'Axe' where sku = 'FC-93025797';

-- 77827 L15 | Desod Rexona Men Sport Spy 150Ml
update public.productos set nombre = 'Men Sport Spy', marca = 'Rexona', presentacion = '150 ML' where sku = 'FC-93038223';

-- 77827 L16 | Desod Rexona Bamboo 48H Stick 45G
update public.productos set nombre = 'Bamboo 48H Stick', marca = 'Rexona', presentacion = '45 G' where sku = 'FC-75062897';

-- 77827 L17 | Desod Axe Men Epic-F 48H Spy 150Ml
update public.productos set nombre = 'Men Epic-F 48H Spy', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-06245686';

-- 77827 L18 | Desod Axe Men Gold Temp
update public.productos set nombre = 'Men Gold Temp', marca = 'Axe' where sku = 'FC-93025865';

-- 77827 L19 | Jbn Grisi Neutro 150 G
update public.productos set nombre = 'Grisi Neutro', presentacion = '150 G' where sku = 'FC-22105207';

-- 77827 L20 | Jbn Dove Barra Blanca
update public.productos set nombre = 'Barra Blanca', marca = 'Dove' where sku = 'FC-38891190';

-- 77827 L21 | Desod Rexona Pom-Dry48H Stick45G
update public.productos set nombre = 'Pom-Dry48H Stick45G', marca = 'Rexona' where sku = 'FC-75062927';

-- 77827 L22 | Jbn Asepxia Bicarbon Sod 100G
update public.productos set nombre = 'Asepxia Bica on Sod', marca = 'Rb', presentacion = '100 G' where sku = 'FC-40036965';

-- 77827 L23 | Jbn Asexia Exfol 100G
update public.productos set nombre = 'Asexia Exfol', presentacion = '100 G' where sku = 'FC-40004643';

-- 77827 L24 | Jbn Grisi Avena 125G
update public.productos set nombre = 'Grisi Avena', presentacion = '125 G' where sku = 'FC-22150801';

-- 77827 L25 | Jbn Escudo Antibact 110Gr
update public.productos set nombre = 'Escudo Antibact', presentacion = '110 G' where sku = 'FC-25605514';

-- 77827 L28 | Jbn Dove Barra Karite Vainill 135G
update public.productos set nombre = 'Barra Karite Vainill', marca = 'Dove', presentacion = '135 G' where sku = 'FC-06230507';

-- 77827 L29 | Jbn Grisi Leche De Burra 125G
update public.productos set nombre = 'Grisi Leche De Burra', presentacion = '125 G' where sku = 'FC-22150092';

-- 77827 L30 | Jbn Grisi Corp Diabecare 125 G
update public.productos set nombre = 'Grisi Corp Diabecare', presentacion = '125 G' where sku = 'FC-22111352';

-- 77827 L31 | Desod Rex Mot-Sen Sport Stick
update public.productos set nombre = 'Rex Mot-Sen Sport Stick' where sku = 'FC-75069223';

-- 77827 L32 | Jbn Liq Palmol N-Bal Dermol 221Mln
update public.productos set nombre = 'Liq N-Bal Dermol 221Mln', marca = 'Palmol' where sku = 'FC-46059556';

-- 77827 L33 | Jbn Liq Blumen Coconut Para 221Ml
update public.productos set nombre = 'Liq Blumen Coconut Para', presentacion = '221 ML' where sku = 'FC-67905186';

-- 77827 L34 | Jbn Palmol N-Bal Dermo Limp 120G
update public.productos set nombre = 'N-Bal Dermo Limp', marca = 'Palmol', presentacion = '120 G' where sku = 'FC-46683133';

-- 77827 L35 | Desod Dove Dermac Sk-C 48H Spy150Ml
update public.productos set nombre = 'Dermac Sk-C 48H Spy150Ml', marca = 'Dove' where sku = 'FC-06241206';

-- 77827 L36 | Jbn Escudo Rosa Prot Y Cuid 110G
update public.productos set nombre = 'Escudo Rosa Prot Y Cuid', presentacion = '110 G' where sku = 'FC-43489004';

-- 77827 L37 | Agua Mic Garnier De Rosas 400 Ml
update public.productos set nombre = 'Agua Mic De Rosas 400', marca = 'Garnier' where sku = 'FC-42326414';

-- 77827 L38 | Agua Mic Vitacilina Ros-Sab 500Mln
update public.productos set nombre = 'Agua Mic Ros-Sab 500Mln', marca = 'Vitacilina' where sku = 'FC-76000284';

-- 77827 L39 | Desmaq Bifasico Oil Nuvel 125Ml
update public.productos set nombre = 'Desmaq Bifasico Oil Nuvel', presentacion = '125 ML' where sku = 'FC-82790504';

-- 77827 L40 | Agua Mice Natural-G Bifasic 120Ml
update public.productos set nombre = 'Agua Mice Natural-G Bifasic', presentacion = '120 ML' where sku = 'FC-45722547';

-- 77827 L41 | Jbn Liq Blumen Cherry Bloss 221Ml
update public.productos set nombre = 'Liq Blumen Cherry Bloss', presentacion = '221 ML' where sku = 'FC-67905131';

-- 77827 L42 | Tas Hum Claris Desmaq Aloe C/40
update public.productos set nombre = 'Tas Hum Claris Desmaq Aloe', presentacion = 'C/40' where sku = 'FC-21012303';

-- 77827 L44 | Jbn Escudo Azul Rey 135G
update public.productos set nombre = 'Escudo Azul Rey', presentacion = '135 G' where sku = 'FC-25652716';

-- 77827 L45 | Deo Aero Dove Tono Uniforme 150Ml 3Pack
update public.productos set nombre = 'Deo Aero Tono Uniforme 150Ml', marca = 'Dove', presentacion = '3 PACK' where sku = 'FC-06248052';

-- 77827 L46 | Deo Dove Spy Invisible Dry 150Ml C3
update public.productos set nombre = 'Deo Spy Invisible Dry C3', marca = 'Dove', presentacion = '150 ML' where sku = 'FC-06248045';

-- 77827 L47 | Jbn Liq Palmol Aquarium 221Ml
update public.productos set nombre = 'Liq Aquarium', marca = 'Palmol', presentacion = '221 ML' where sku = 'FC-35911208';

-- 77827 L48 | Desod Nivea Pearlb Mspy150Ml
update public.productos set nombre = 'Pearlb Mspy150Ml', marca = 'Nivea' where sku = 'FC-08837311';

-- 77827 L49 | Deo Axe Spy 150Ml 48H Anarchy Fresh Love Fo
update public.productos set nombre = 'Deo Spy 48H Anarchy Fresh Love Fo', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-06209862';

-- 77827 L50 | Jbn Liq Escudo Blanco Neut 225Ml
update public.productos set nombre = 'Liq Escudo Blanco Neut', presentacion = '225 ML' where sku = 'FC-43489165';

-- 77827 L51 | Jaloma Agua De Rosas 130Ml Spray
update public.productos set nombre = 'Jaloma Agua De Rosas Spray', presentacion = '130 ML' where sku = 'FC-84900280';

-- 77827 L52 | Desod Axe Wom Anarchy Spy 150Ml
update public.productos set nombre = 'Wom Anarchy Spy', marca = 'Axe', presentacion = '150 ML' where sku = 'FC-06226852';

-- 77827 L53 | Jbn Lio Palmol Flor Czo-Rsa 221Ml
update public.productos set nombre = 'Lio Flor Czo-Rsa', marca = 'Palmol', presentacion = '221 ML' where sku = 'FC-46657035';

-- 77827 L54 | Loc Limp Ponds Bio-Hydra Dual 200Ml
update public.productos set nombre = 'Loc Limp Bio-Hydra Dual', marca = 'Ponds', presentacion = '200 ML' where sku = 'FC-56330378';

-- 77827 L55 | Deo Mexsana P/Pies Spy 150Ml
update public.productos set nombre = 'Deo Mexsana P/Pies Spy', presentacion = '150 ML' where sku = 'FC-76040436';

-- 77827 L57 | Odolex Naturals 300Gr Talco Desodorante
update public.productos set nombre = 'Odolex Naturals Talco Desodorante', presentacion = '300 G' where sku = 'FC-61123009';

-- 77827 L59 | Sh Pert Plus Ac-Oliva 400Ml
update public.productos set nombre = 'Pert Plus Ac-Oliva', presentacion = '400 ML' where sku = 'FC-20500201';

-- 77827 L60 | Ting Polvo 85G
update public.productos set nombre = 'Ting Polvo', presentacion = '85 G' where sku = 'FC-72300171';

-- 77827 L61 | Ico Desod Rexona Effi Fresh 200G
update public.productos set nombre = 'Ico Desod Effi Fresh', marca = 'Rexona', presentacion = '200 G' where sku = 'FC-06217461';

-- 77827 L62 | Quita Esm Nuvel Humec 125Ml
update public.productos set nombre = 'Quita Esm Nuvel Humec', presentacion = '125 ML' where sku = 'FC-82740011';

-- 77827 L63 | Cra Fructis Pei B-Dano Quim 300Ml
update public.productos set nombre = 'Fructis Pei B-Dano Quim', presentacion = '300 ML' where sku = 'FC-52910971';

-- 77827 L64 | Cra Fructis Pei Oil-R L-Coco 300Ml
update public.productos set nombre = 'Fructis Pei Oil-R L-Coco', presentacion = '300 ML' where sku = 'FC-52816297';

-- 77827 L66 | Sh Int Lomecan V 200Ml
update public.productos set nombre = 'Int Lomecan V', presentacion = '200 ML' where sku = 'FC-40025839';

-- 77827 L68 | Sh Int Lomecan V Aclar 200Ml
update public.productos set nombre = 'Int Lomecan V Aclar', presentacion = '200 ML' where sku = 'FC-40030338';

-- 77827 L69 | Silkhair Quita Esmalte Mora Azul 100Ml
update public.productos set nombre = 'Silkhair Quita Esmalte Mora Azul', presentacion = '100 ML' where sku = 'FC-45720550';

-- 77827 L70 | Cra Nutribela1O Bio Colageno 300Gn
update public.productos set nombre = 'Nutribela1O Bio Colageno 300Gn' where sku = 'FC-92511261';

-- 77827 L71 | Cra Nutribela Nutrice Tarro 300G
update public.productos set nombre = 'Nutribela Nutrice Tarro', presentacion = '300 G' where sku = 'FC-92509213';

-- 77827 L73 | Rexona 1O0Gr Tco Pies Efficient Orig
update public.productos set nombre = '1O0Gr Tco Pies Efficient Orig', marca = 'Rexona' where sku = 'FC-06257597';

-- 77827 L74 | Sh Caprice Nat Mzna 380 Ml
update public.productos set nombre = 'Caprice Nat Mzna 380' where sku = 'FC-46073156';

-- 77827 L75 | Cra Pert Oliv+Ac Agu P/Pein 100 Ml
update public.productos set nombre = 'Pert Oliv+Ac Agu P/Pein 100' where sku = 'FC-20500171';

-- 77827 L76 | Ac Pantene Bambu 400Ml
update public.productos set nombre = 'Bambu', marca = 'Pantene', presentacion = '400 ML' where sku = 'FC-35155922';

-- 77827 L79 | Cra Sedal Rizos Obedie 300Ml
update public.productos set nombre = 'Sedal Rizos Obedie', presentacion = '300 ML' where sku = 'FC-56340131';

-- 77827 L80 | Acond Pant Rizos Definid 400Ml
update public.productos set nombre = 'Acond Pant Rizos Definid', presentacion = '400 ML' where sku = 'FC-01165321';

-- 77827 L81 | Sh Sedal Rizos Def Inf-Act 180Ml
update public.productos set nombre = 'Sedal Rizos Def Inf-Act', presentacion = '180 ML' where sku = 'FC-06249783';

-- 77827 L82 | Tco Desod Eficc Pies 200 G
update public.productos set nombre = 'Tco Desod Eficc Pies', presentacion = '200 G' where sku = 'FC-56360429';

-- 77827 L83 | Cra Sedal Sos Recon-Estru 300Ml
update public.productos set nombre = 'Sedal Sos Recon-Estru', presentacion = '300 ML' where sku = 'FC-56340025';

-- 77827 L84 | Cra Sedal Rizos Obedientes 135Ml
update public.productos set nombre = 'Sedal Rizos Obedientes', presentacion = '135 ML' where sku = 'FC-56342227';

-- 77827 L85 | Sh Sedal Ceramidas Inf-Act 180Ml
update public.productos set nombre = 'Sedal Ceramidas Inf-Act', presentacion = '180 ML' where sku = 'FC-06249776';

-- 77827 L86 | Sh Pant Ctrcaida A/Pv 400Ml
update public.productos set nombre = 'Pant Ctrcaida A/Pv', presentacion = '400 ML' where sku = 'FC-01303454';

-- 77827 L87 | Sh Pant Brillo Extremo
update public.productos set nombre = 'Pant Brillo Extremo' where sku = 'FC-07457796';

-- 77827 L89 | Sh Pant Bambu Ctrl Caida 400 Ml
update public.productos set nombre = 'Pant Bambu Ctrl Caida 400' where sku = 'FC-35155847';

-- 77827 L90 | Sh Savile Ker-Sab Fza Repar 700Ml
update public.productos set nombre = 'Savile Ker-Sab Fza Repar', presentacion = '700 ML' where sku = 'FC-06249240';

-- 77827 L91 | Sh Savile Bio-Sab Creci Res 700Ml
update public.productos set nombre = 'Savile Bio-Sab Creci Res', presentacion = '700 ML' where sku = 'FC-06249226';

-- 77827 L93 | Cra Sedal Anti Nudos 300 Ml
update public.productos set nombre = 'Sedal Anti Nudos 300' where sku = 'FC-06234062';

-- 77827 L94 | Cra Sedal Recons Estructur 135Ml
update public.productos set nombre = 'Sedal Recons Estructur', presentacion = '135 ML' where sku = 'FC-56342258';

-- 77827 L95 | Tco Desdo Odolex 150 G
update public.productos set nombre = 'Tco Desdo Odolex', presentacion = '150 G' where sku = 'FC-61111501';

-- 77827 L96 | Tco Odolex Fresh 150G
update public.productos set nombre = 'Tco Odolex Fresh', presentacion = '150 G' where sku = 'FC-61124013';

-- 77827 L97 | Cra Sedal Sos Ceramida 300Ml
update public.productos set nombre = 'Sedal Sos Ceramida', presentacion = '300 ML' where sku = 'FC-56340124';

-- 77827 L98 | Sh Hbs Limp Renoy 375Ml
update public.productos set nombre = 'Hbs Limp Renoy', presentacion = '375 ML' where sku = 'FC-35020008';

-- 77827 L99 | Mousse Herbal Ess Rizo 200G
update public.productos set nombre = 'Mousse He al Ess Rizo', marca = 'Rb', presentacion = '200 G' where sku = 'FC-35169035';

-- 77827 L100 | Sh Hash Anti Comezon 375Ml
update public.productos set nombre = 'Hash Anti Comezon', presentacion = '375 ML' where sku = 'FC-35168991';

-- 77827 L101 | Sh Hash Anti Comezon 375Ml
update public.productos set nombre = 'Hash Anti Comezon', presentacion = '375 ML' where sku = 'FC-35231237';

-- 77827 L102 | Cera Mod Ego Met 25 G
update public.productos set nombre = 'Cera Mod Ego Met', presentacion = '25 G' where sku = 'FC-92504539';

-- 77827 L103 | Cera Gel Moco De Gorila Citr 100G
update public.productos set nombre = 'Cera Gel Moco De Gorila Citr', presentacion = '100 G' where sku = 'FC-38312374';

-- 77827 L104 | Sh H&S Anti Comezon 180 Ml
update public.productos set nombre = 'Anti Comezon 180', marca = 'H&S' where sku = 'FC-35231244';

-- 77827 L105 | Sh Hbs Alivio Instant
update public.productos set nombre = 'Hbs Alivio Instant' where sku = 'FC-35020077';

-- 77827 L106 | Gel Ego Magnetic Fij-Alta 200 Ml
update public.productos set nombre = 'Gel Ego Magnetic Fij-Alta 200' where sku = 'FC-92503558';

-- 77827 L107 | Gel X-Extreme Titan 250G
update public.productos set nombre = 'Gel X-Extreme Titan', presentacion = '250 G' where sku = 'FC-99425580';

-- 77827 L108 | Gel Moco De Gorila Punk 80 G
update public.productos set nombre = 'Gel Moco De Gorila Punk', presentacion = '80 G' where sku = 'FC-99428024';

-- 77827 L109 | Sh Caprice Sp Biotina Fza 200Ml
update public.productos set nombre = 'Caprice Sp Biotina Fza', presentacion = '200 ML' where sku = 'FC-46073040';

-- 77827 L110 | Sh Caprice Sp Acti Ceramida 200Ml
update public.productos set nombre = 'Caprice Sp Acti Ceramida', presentacion = '200 ML' where sku = 'FC-46073033';

-- 77827 L111 | Silica Shine Sily Oleo Argan 120Ml
update public.productos set nombre = 'Silica Shine Sily Oleo Argan', presentacion = '120 ML' where sku = 'FC-54073302';

-- 77827 L112 | Silica Shine Sily 3/1 Mora 120Ml
update public.productos set nombre = 'Silica Shine Sily 3/1 Mora', presentacion = '120 ML' where sku = 'FC-24511711';

-- 77827 L114 | Brill Palmol Lio 115M
update public.productos set nombre = 'Brill Lio 115M', marca = 'Palmol' where sku = 'FC-75001865';

-- 77827 L115 | Mousse Caprice Volum-Cirl 200 G
update public.productos set nombre = 'Mousse Caprice Volum-Cirl', presentacion = '200 G' where sku = 'FC-46655055';

-- 77827 L116 | Gel Ego Fresh C-Cas Fij-Alt 200Ml
update public.productos set nombre = 'Gel Ego Fresh C-Cas Fij-Alt', presentacion = '200 ML' where sku = 'FC-06247468';

-- 77827 L117 | Gel Ego For Men Attraction 200 Ml
update public.productos set nombre = 'Gel Ego For Men Attraction 200' where sku = 'FC-92506601';

-- 77827 L118 | Cep Dent Oral-B Indicat35Sve
update public.productos set nombre = 'Cep Dent Indicat35Sve', marca = 'Oral-B' where sku = 'FC-86494262';

-- 77827 L119 | Cera Ego Firme Matte 25 G
update public.productos set nombre = 'Cera Ego Firme Matte', presentacion = '25 G' where sku = 'FC-92506045';

-- 77827 L120 | Acetona Jaloma 60 Ml
update public.productos set nombre = 'tona Jaloma 60', marca = 'Ace' where sku = 'FC-84431050';

-- 77827 L121 | Silkhair Quita Esmalte Coco 100 Ml
update public.productos set nombre = 'Silkhair Quita Esmalte Coco 100' where sku = 'FC-45720567';

-- 77827 L122 | Acetona Jaloma 120 Ml
update public.productos set nombre = 'tona Jaloma 120', marca = 'Ace' where sku = 'FC-84437151';

-- 77827 L128 | Cra Nivea Sdatarr Giga 400Ml
update public.productos set nombre = 'Sdatarr Giga', marca = 'Nivea', presentacion = '400 ML' where sku = 'FC-54500216';

-- 77827 L129 | Desod Ego Force 24H R-On 45Ml Dic26
update public.productos set nombre = 'Ego Force 24H R-On Dic26', presentacion = '45 ML' where sku = 'FC-75064938';

-- 77827 L130 | Cra Hinds Liq Agave Azul 400Ml
update public.productos set nombre = 'Hinds Liq Agave Azul', presentacion = '400 ML' where sku = 'FC-20501673';

-- 77827 L131 | Cra Nivea B Sofmilk Sec400Ml
update public.productos set nombre = 'B Sofmilk Sec400Ml', marca = 'Nivea' where sku = 'FC-08802838';

-- 77827 L133 | Cra Grisi Conchnac P/Manos 80 Ml
update public.productos set nombre = 'Grisi Conchnac P/Manos 80' where sku = 'FC-36040450';

-- 77827 L134 | Cra Clarant B3 Nml/Gsa 100G
update public.productos set nombre = 'Clarant B3 Nml/Gsa', presentacion = '100 G' where sku = 'FC-56330309';

-- 77827 L135 | Cra Nivea Cuidada Clar-Nat 200Ml
update public.productos set nombre = 'Cuidada Clar-Nat', marca = 'Nivea', presentacion = '200 ML' where sku = 'FC-42270027';

-- 77827 L136 | Gel Niv Fac Ref Hidra Hyalu 200Ml
update public.productos set nombre = 'Gel Niv Fac Ref Hidra Hyalu', presentacion = '200 ML' where sku = 'FC-00942760';

-- 77827 L137 | Cra Corp Niveamilk 400Ml+Cra100Ml
update public.productos set nombre = 'Corp milk +Cra100Ml', marca = 'Nivea', presentacion = '400 ML' where sku = 'FC-54558682';

-- 77827 L138 | Cra Teatrical Cel-Ma Nutrit 400Ml
update public.productos set nombre = 'Teatrical Cel-Ma Nutrit', presentacion = '400 ML' where sku = 'FC-40030963';

-- 77827 L140 | Cra Lubriderm Uv Fps15 120Ml
update public.productos set nombre = 'Uv Fps15', marca = 'Lubriderm', presentacion = '120 ML' where sku = 'FC-35469151';

-- 77827 L141 | Sh Grisi Ricitos Oro Biopure 250Ml
update public.productos set nombre = 'Grisi Ricitos Oro Biopure', presentacion = '250 ML' where sku = 'FC-36032776';

-- 77827 L142 | Jbn Johnson'S Baby Antes/Dor 75 G
update public.productos set nombre = '''S Baby Antes/Dor', marca = 'Johnson', presentacion = '75 G' where sku = 'FC-07502441';

-- 77827 L143 | Jbn Palmol N-Bal Corp Baby0% 90G
update public.productos set nombre = 'N-Bal Corp Baby0%', marca = 'Palmol', presentacion = '90 G' where sku = 'FC-46655079';

-- 77827 L145 | Cra Hinds Hidr-Extr Almendras 500Ml
update public.productos set nombre = 'Hinds Hidr-Extr Almendras', presentacion = '500 ML' where sku = 'FC-36041402';

-- 77827 L146 | Cra Lubriderm Thint Psec120Ml
update public.productos set nombre = 'Thint Psec120Ml', marca = 'Lubriderm' where sku = 'FC-07528939';

-- 77827 L147 | Cra Lubriderm P/Normal 120Ml
update public.productos set nombre = 'P/Normal', marca = 'Lubriderm', presentacion = '120 ML' where sku = 'FC-31244486';

-- 77827 L149 | Sh Mennen Zero% Sve 400Ml
update public.productos set nombre = 'Mennen Zero% Sve', presentacion = '400 ML' where sku = 'FC-46074504';

-- 77827 L150 | Sh Ricitos Oro Agua De Coco 250Ml
update public.productos set nombre = 'Ricitos Oro Agua De Coco', presentacion = '250 ML' where sku = 'FC-36033735';

-- 77827 L151 | Sh Mennen Lavan-Extrac Aven 200Ml
update public.productos set nombre = 'Mennen Lavan-Extrac Aven', presentacion = '200 ML' where sku = 'FC-46650708';

-- 77827 L152 | Sh Grisi Rici Oro Miel 250Ml
update public.productos set nombre = 'Grisi Rici Oro Miel', presentacion = '250 ML' where sku = 'FC-22133286';

-- 77827 L154 | Sensodyne Protec Complet + Acc Lim Efec 90G
update public.productos set nombre = 'Sensodyne Protec Complet + Acc Lim Efec', presentacion = '90 G' where sku = 'FC-09498091';

-- 77827 L155 | Cep Dent Oral-B 3Dw Advant Med2X1
update public.productos set nombre = 'Cep Dent 3Dw Advant Med2X1', marca = 'Oral-B' where sku = 'FC-95129166';

-- 77827 L156 | Cra Nivea Cuidado Int P/Mano 75Ml
update public.productos set nombre = 'Cuidado Int P/Mano', marca = 'Nivea', presentacion = '75 ML' where sku = 'FC-42417644';

-- 77827 L158 | Cra Teatrical Lanol/Ros 52Gr
update public.productos set nombre = 'Teatrical Lanol/Ros', presentacion = '52 G' where sku = 'FC-40013898';

-- 77827 L159 | Cra Corp Niv Soft M P/Seca 100Ml
update public.productos set nombre = 'Corp Niv Soft M P/Seca', presentacion = '100 ML' where sku = 'FC-54549819';

-- 77827 L160 | Tas San Kotex Ant Flujo Abundante S/A 10Pz
update public.productos set nombre = 'Tas San Ant Flujo Abundante S/A 10Pz', marca = 'Kotex' where sku = 'FC-17360604';

-- 77827 L161 | Sh Mennen Miel-Mza Sve 200Ml
update public.productos set nombre = 'Mennen Miel-Mza Sve', presentacion = '200 ML' where sku = 'FC-46072050';

-- 77827 L162 | Jbn Ricitos D Oro Neutro 90 G
update public.productos set nombre = 'Ricitos D Oro Neutro', presentacion = '90 G' where sku = 'FC-22150221';

-- 77827 L163 | Cra Grisi Aloe Vera P/Manos 80 Mln
update public.productos set nombre = 'Grisi Aloe Vera P/Manos 80 Mln' where sku = 'FC-20501765';

-- 77827 L164 | Cra S Ponds Humectante 100G
update public.productos set nombre = 'S Humectante', marca = 'Ponds', presentacion = '100 G' where sku = 'FC-56326142';

-- 77827 L166 | Enj Buc List Anticari-Al 250Ml
update public.productos set nombre = 'Enj Buc List Anticari-Al', presentacion = '250 ML' where sku = 'FC-31976394';

-- 77827 L167 | Tas Sanit Kotex Nat Flex Noct C/5
update public.productos set nombre = 'Tas Sanit Nat Flex Noct', marca = 'Kotex', presentacion = 'C/5' where sku = 'FC-43427754';

-- 77827 L169 | Enj Buc List Care Zero Mta 250Ml
update public.productos set nombre = 'Enj Buc List Care Zero Mta', presentacion = '250 ML' where sku = 'FC-31887928';

-- 77827 L170 | Cra Nivea Sda Tarro 100 Ml
update public.productos set nombre = 'Sda Tarro 100', marca = 'Nivea' where sku = 'FC-54503095';

-- 77827 L171 | Tas Hum Th Bebin Super C/80
update public.productos set nombre = 'Tas Hum Th Bebin Super', presentacion = 'C/80' where sku = 'FC-85800198';

-- 77827 L173 | Enj Buc List Zero Mta Sve 250Ml
update public.productos set nombre = 'Enj Buc List Zero Mta Sve', presentacion = '250 ML' where sku = 'FC-10974329';

-- 77827 L174 | Nivea 75Ml Cra P/Manos 3En1 Ant-Arrugas
update public.productos set nombre = 'Cra P/Manos 3En1 Ant-Arrugas', marca = 'Nivea', presentacion = '75 ML' where sku = 'FC-00701992';

-- 77827 L175 | Jbn Mennen Baby Magic Lavan 90 G
update public.productos set nombre = 'Mennen Baby Magic Lavan', presentacion = '90 G' where sku = 'FC-46655727';

-- 77827 L177 | Tco Mennen Azul 200G
update public.productos set nombre = 'Tco Mennen Azul', presentacion = '200 G' where sku = 'FC-35908130';

-- 77827 L179 | Tco Mennen Rosa 200G
update public.productos set nombre = 'Tco Mennen Rosa', presentacion = '200 G' where sku = 'FC-35908147';

-- 77827 L180 | Tas Sanit Saba Inv Alas C/10
update public.productos set nombre = 'Tas Sanit Saba Inv Alas', presentacion = 'C/10' where sku = 'FC-19006371';

-- 77827 L183 | C D Sensodyne Rapido Alivio 100G
update public.productos set nombre = 'C D Sensodyne Rapido Alivio', presentacion = '100 G' where sku = 'FC-40171550';

-- 112558 L1 | DIBAR ALCOHOL 125ML ROJO
update public.productos set nombre = 'Alcohol Rojo', marca = 'Dibar', presentacion = '125 ML' where sku = 'FC-68900264';

-- 112558 L2 | DIBAR ALCOHOL ILT ROJO
update public.productos set nombre = 'Alcohol Ilt Rojo', marca = 'Dibar' where sku = 'FC-68960257';

-- 112558 L3 | ADIBAR ALCOHOL 250ML. ROJO
update public.productos set nombre = 'A Alcohol . Rojo', marca = 'Dibar', presentacion = '250 ML' where sku = 'FC-68900226';

-- 112558 L4 | DIBAR ALCOHOL 500ML. ROJO
update public.productos set nombre = 'Alcohol . Rojo', marca = 'Dibar', presentacion = '500 ML' where sku = 'FC-68990023';

-- 112558 L5 | AGUA DESTILADA LA FLOR 1 LT
update public.productos set nombre = 'Agua Destilada La Flor 1 Lt' where sku = 'FC-77620056';

-- 112558 L6 | ARNICA MERCURIO
update public.productos set nombre = 'Arnica Mercurio' where sku = 'FC-00003920';

-- 112558 L7 | CREMA AMARILLA VITACILINA ACLARADORA
update public.productos set nombre = 'Crema Amarilla Aclaradora', marca = 'Vitacilina' where sku = 'FC-76000260';

-- 112558 L8 | CREMA ROJA VITACILINA ANTIARRUGAS 100GR
update public.productos set nombre = 'Crema Roja Antiarrugas', marca = 'Vitacilina', presentacion = '100 G' where sku = 'FC-76000253';

-- 112558 L9 | DIAPRO CONFORT MED C/10
update public.productos set nombre = 'Diapro Confort Med', presentacion = 'C/10' where sku = 'FC-16800803';

-- 112558 L10 | DABAN ALCOHOL AZUL 125ML.
update public.productos set nombre = 'Daban Alcohol Azul', presentacion = '125 ML' where sku = 'FC-86901100';

-- 112558 L11 | ALCOHOL AZUL 1LT
update public.productos set nombre = 'Alcohol Azul 1Lt' where sku = 'FC-68901131';

-- 112558 L12 | DIBAR ALCOHOL AZUL 250ML
update public.productos set nombre = 'Alcohol Azul', marca = 'Dibar', presentacion = '250 ML' where sku = 'FC-68901117';

-- 112558 L13 | ALCOHOL AZUL 500ML
update public.productos set nombre = 'Alcohol Azul', presentacion = '500 ML' where sku = 'FC-68901124';

-- 112558 L14 | BOLO EUROBION TAB C/20
update public.productos set nombre = 'Bolo Eurobion Tab', presentacion = 'C/20' where sku = 'FC-98223704';

-- 112558 L15 | LIO 236ML CHTE
update public.productos set nombre = 'Lio Chte', presentacion = '236 ML' where sku = 'FC-33950100';

-- 112558 L16 | BASUYE LIQ 236ML FSA
update public.productos set nombre = 'Basuye Liq Fsa', presentacion = '236 ML' where sku = 'FC-33950063';

-- 112558 L17 | ENSURE LIQ 236ML VNLLA
update public.productos set nombre = 'Ensure Liq Vnlla', presentacion = '236 ML' where sku = 'FC-33950070';

-- 112558 L18 | LUCERNA LIQ 237ML
update public.productos set nombre = 'Lucerna Liq', presentacion = '237 ML' where sku = 'FC-33956133';

-- 112558 L19 | GLUCERNA SR LIQ 237ML FRESA
update public.productos set nombre = 'Glucerna Sr Liq Fresa', presentacion = '237 ML' where sku = 'FC-33956140';

-- 112558 L20 | GOTERO CRISTAL
update public.productos set nombre = 'Gotero Cristal' where sku = 'FC-07521317';

-- 112558 L21 | NATURELLA FLUJO MOD C/ALAS C/8
update public.productos set nombre = 'Naturella Flujo Mod C/Alas', presentacion = 'C/8' where sku = 'FC-01157296';

-- 112558 L22 | NATURELLA NOCHE CON ALAS C/8
update public.productos set nombre = 'Naturella Noche Con Alas', presentacion = 'C/8' where sku = 'FC-01405335';

-- 112558 L23 | EDIASURE LIQ 236ML CHTE
update public.productos set nombre = 'Ediasure Liq Chte', presentacion = '236 ML' where sku = 'FC-33951008';

-- 112558 L24 | PEDIASURE LIQ 236ML FSA
update public.productos set nombre = 'Pediasure Liq Fsa', presentacion = '236 ML' where sku = 'FC-33954245';

-- 112558 L25 | PEDIASURE LIQ 236ML VNLLA
update public.productos set nombre = 'Pediasure Liq Vnlla', presentacion = '236 ML' where sku = 'FC-33950209';

-- 112558 L26 | SABA BUENAS NOCHES
update public.productos set nombre = 'Saba Buenas Noches' where sku = 'FC-19006623';

-- 112558 L27 | TB 3 SURT
update public.productos set nombre = '3 Surt' where sku = 'FC-65054135';

-- 112558 L28 | FASELINE PURO 42G
update public.productos set nombre = 'Faseline Puro', presentacion = '42 G' where sku = 'FC-56323066';

-- 112558 L29 | VASELINE PURO 85G
update public.productos set nombre = 'Vaseline Puro', presentacion = '85 G' where sku = 'FC-56323059';

-- 112558 L30 | VAPORUB POM 12G C12 LATAS
update public.productos set nombre = 'Vaporub Pom C12 Latas', presentacion = '12 G' where sku = 'FC-01246730';

-- 112558 L31 | VICK NAPORUB UNG 100G
update public.productos set nombre = 'Vick Naporub Ung', presentacion = '100 G' where sku = 'FC-02012475';

-- 112558 L32 | VICK VAPORUB UNG 50G
update public.productos set nombre = 'Vick Vaporub Ung', presentacion = '50 G' where sku = 'FC-02012468';

-- IFC1-080826 L1 | POMADA REOMATOLUM DEL VIEJITO 60G
update public.productos set nombre = 'Reomatolum Del Viejito', presentacion = '60 G' where sku = 'FC-1FBF5206';

-- IFC1-080826 L2 | POMADA REOMATOLUM DEL VIEJITO 60G VARFAM LAVA OJOS VIDRIO ABR56 81606
update public.productos set nombre = 'Reomatolum Del Viejito Varfam Lava Ojos Vidrio Abr56 81606', presentacion = '60 G' where sku = 'FC-2E5B7248';

-- IFC1-080826 L4 | MERCURIO ESPIRITUS UNTAR C/25 1770823
update public.productos set nombre = 'Mercurio Espiritus Untar 1770823', presentacion = 'C/25' where sku = 'FC-62034164';

-- IFC1-080826 L5 | MERCURIO ESPIRITUS TOMAR C/25 1760823
update public.productos set nombre = 'Mercurio Espiritus Tomar 1760823', presentacion = 'C/25' where sku = 'FC-3676D5DC';

-- IFC1-080826 L6 | MERCURIO ACEITE OLIVO C/25 1000625 83825
update public.productos set nombre = 'Mercurio Ite Olivo 1000625 83825', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-5A697CC2';

-- IFC1-080826 L7 | MERCURIO GLICERINA C/25 1230723 83125
update public.productos set nombre = 'Mercurio Glicerina 1230723 83125', presentacion = 'C/25' where sku = 'FC-39036C88';

-- IFC1-080826 L8 | MERCURIO JARABE DE GRANADA. C/25 1750823
update public.productos set nombre = 'Mercurio Jarabe De Granada. 1750823', presentacion = 'C/25' where sku = 'FC-DFF99C3F';

-- IFC1-080826 L9 | MERCURIO ACEITE COCO C/25 800523 83064
update public.productos set nombre = 'Mercurio Ite Coco 800523 83064', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-931B4809';

-- IFC1-080826 L10 | MERCURIO ACEITE ALMENDRAS C/25 790523
update public.productos set nombre = 'Mercurio Ite Almendras 790523', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-D4AC123B';

-- IFC1-080826 L11 | MERCURIO ACEITE ROMERO C/25 1910923
update public.productos set nombre = 'Mercurio Ite Romero 1910923', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-38CAFE6B';

-- IFC1-080826 L12 | KOHN MERTIOLATE ROJO C/25 012023 82912
update public.productos set nombre = 'Kohn Mertiolate Rojo 012023 82912', presentacion = 'C/25' where sku = 'FC-926099D3';

-- IFC1-080826 L13 | MADRID ACEITE EUCALIPTO C/25 2712017 83401
update public.productos set nombre = 'Madrid Ite Eucalipto 2712017 83401', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-E69F2E63';

-- IFC1-080826 L14 | MERCURIO ARNICA UNTAR C/25 1790823 83156
update public.productos set nombre = 'Mercurio Arnica Untar 1790823 83156', presentacion = 'C/25' where sku = 'FC-25E452B6';

-- IFC1-080826 L15 | MERCURIO ARNICA TOMAR C/25 1780823 83156
update public.productos set nombre = 'Mercurio Arnica Tomar 1780823 83156', presentacion = 'C/25' where sku = 'FC-127F5753';

-- IFC1-080826 L16 | MERCURIO YODO UNTAR C/25 1810623 83156
update public.productos set nombre = 'Mercurio Yodo Untar 1810623 83156', presentacion = 'C/25' where sku = 'FC-D3D28E20';

-- IFC1-080826 L17 | MERCURIO ACEITE GOMENOLADO C/25 1160623
update public.productos set nombre = 'Mercurio Ite Gomenolado 1160623', marca = 'Ace', presentacion = 'C/25' where sku = 'FC-69387811';

-- IFC1-080826 L18 | MERCURIO YODO TOMAR C/25 1800823 83156
update public.productos set nombre = 'Mercurio Yodo Tomar 1800823 83156', presentacion = 'C/25' where sku = 'FC-A680F97E';

-- IFC2-080826 L1 | MERCURIO OXIDO DE ZINC C/50 1620824 83521
update public.productos set nombre = 'Mercurio Oxido De Zinc 1620824 83521', presentacion = 'C/50' where sku = 'FC-C4530823';

-- IFC2-080826 L2 | MERCURIO BISMUTO SUBNITRATO C/50 1390724
update public.productos set nombre = 'Mercurio Bismuto Subnitrato 1390724', presentacion = 'C/50' where sku = 'FC-D037156B';

-- IFC2-080826 L3 | MERCURIO BICARBONATO SOBRES C/50
update public.productos set nombre = 'Mercurio Bica Onato Sobres', marca = 'Rb', presentacion = 'C/50' where sku = 'FC-B8D7C997';

-- IFC2-080826 L4 | MERCURIO MAGNESIA ANISADA C/50 1560824
update public.productos set nombre = 'Mercurio Magnesia Anisada 1560824', presentacion = 'C/50' where sku = 'FC-CB5C11ED';

-- IFC2-080826 L5 | / 2.00 PIEZA EDIGAR PERILLA N 6 CAJA 1649 81608
update public.productos set nombre = '/ 2.00 Pieza Edigar Perilla N 6 Caja 1649 81608' where sku = 'FC-A871D831';

-- IFC2-080826 L6 | MERCURIO BORAX POLVO C/50 140072483490
update public.productos set nombre = 'Mercurio Borax Polvo', presentacion = 'C/50' where sku = 'FC-578F060C';

-- IFC2-080826 L7 | MERCURIO PERLAS DE ETER C/50 1630824
update public.productos set nombre = 'Mercurio Perlas De Eter 1630824', presentacion = 'C/50' where sku = 'FC-FBD776D2';

-- IFC2-080826 L8 | MERCURIO FLOR DE ARNICA C/50 1430724
update public.productos set nombre = 'Mercurio Flor De Arnica 1430724', presentacion = 'C/50' where sku = 'FC-5EF90195';

-- IFC2-080826 L9 | EDIGAR PERILLA N O CAJA
update public.productos set nombre = 'Edigar Perilla N O Caja' where sku = 'FC-9A1C64E7';

-- IFC2-080826 L10 | MERCURIO SULFATIAZOL POLVO C/50 1710824
update public.productos set nombre = 'Mercurio Sulfatiazol Polvo 1710824', presentacion = 'C/50' where sku = 'FC-47AAF23B';

-- IFC2-080826 L11 | EDIGAR PERILLA N 4 CAJA 1439 81608
update public.productos set nombre = 'Edigar Perilla N 4 Caja 1439 81608' where sku = 'FC-FFC25DD1';

-- IFC2-080826 L12 | EDGAR PERILLA N 3 C A 1334 81608
update public.productos set nombre = 'Edgar Perilla N 3 C A 1334 81608' where sku = 'FC-614E4F82';

-- IFC2-080826 L13 | EDIGAR PERILLA N 2 CAJA 1145 81608
update public.productos set nombre = 'Edigar Perilla N 2 Caja 1145 81608' where sku = 'FC-C22EBFE6';

-- IFC2-080826 L14 | EDIGAR PERILLA N 1 CAJA 1113 81608
update public.productos set nombre = 'Edigar Perilla N 1 Caja 1113 81608' where sku = 'FC-BCF59548';

-- IFC2-080826 L15 | MERCURIO HABA ALCANFORADA C/50 1510724
update public.productos set nombre = 'Mercurio Haba Alcanforada 1510724', presentacion = 'C/50' where sku = 'FC-9507CD66';

-- IFC2-080826 L16 | MERCURIO POMADA TEPEZCOHUITE C/25
update public.productos set nombre = 'Mercurio Pomada Tepezcohuite', presentacion = 'C/25' where sku = 'FC-FEAECBF1';

-- IFC2-080826 L17 | MERCURIO POMADA VENENO DE ABEJA C/25
update public.productos set nombre = 'Mercurio Pomada Veneno De Abeja', presentacion = 'C/25' where sku = 'FC-9827438F';

-- IFC2-080826 L18 | MERCURIO POMADA PAN PUERCO C/25 25401233
update public.productos set nombre = 'Mercurio Pomada Pan Puerco', presentacion = 'C/25' where sku = 'FC-EFB599B5';

-- IFC2-080826 L19 | VELAZQUEZ BICARBONATO GRANDE 200G C/10
update public.productos set nombre = 'Velazquez Bica Onato Grande 200G', marca = 'Rb', presentacion = 'C/10' where sku = 'FC-08DB70CB';

-- IFC2-080826 L20 | MERCURIO POMADA ARNICA C/25 2550123
update public.productos set nombre = 'Mercurio Pomada Arnica 2550123', presentacion = 'C/25' where sku = 'FC-89F00320';

-- IFC2-080826 L21 | MERCURIO POMADA SULFATIAZOL C/25 2600223
update public.productos set nombre = 'Mercurio Pomada Sulfatiazol 2600223', presentacion = 'C/25' where sku = 'FC-FD718DF3';

-- IFC2-080826 L22 | MERCURIO POMADA OXIDO DE ZINC C/25
update public.productos set nombre = 'Mercurio Pomada Oxido De Zinc', presentacion = 'C/25' where sku = 'FC-0ACC5B6A';

-- IFC2-080826 L23 | MERCURIO CLORURO DE MAGNESIO C/10 CAJITA
update public.productos set nombre = 'Mercurio Cloruro De Magnesio Cajita', presentacion = 'C/10' where sku = 'FC-5D59ED54';

-- FMX-080826 L1 | FC 01/03/2030
update public.productos set nombre = 'Fc 01/03/2030' where sku = 'FC-E5BA49B2';

-- FMX-080826 L2 | FC 01/11/2030|
update public.productos set nombre = 'Fc 01/11/2030' where sku = 'FC-895EA161';

-- FMX-080826 L4 | MEDITEST PRUEBA EMBARAZO C/1
update public.productos set nombre = 'Meditest Prueba Embarazo', presentacion = 'C/1' where sku = 'FC-66055303';

-- FMX-080826 L5 | FC 01/09/2028
update public.productos set nombre = 'Fc 01/09/2028' where sku = 'FC-DF92D3CF';

-- FMX-080826 L6 | FC 01/04/2029
update public.productos set nombre = 'Fc 01/04/2029' where sku = 'FC-757DEC8A';

-- FMX-080826 L7 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-108AB6B6';

-- FMX-080826 L8 | FC 01/05/2029
update public.productos set nombre = 'Fc 01/05/2029' where sku = 'FC-22ECC02C';

-- FMX-080826 L9 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-23B68FA1';

-- FMX-080826 L10 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-87621652';

-- FMX-080826 L11 | FC 01/12/2028
update public.productos set nombre = 'Fc 01/12/2028' where sku = 'FC-2E70DB7E';

-- FMX-080826 L12 | FC 01/11/2028
update public.productos set nombre = 'Fc 01/11/2028' where sku = 'FC-A166D66F';

-- FMX-080826 L13 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-7B88B47E';

-- FMX-080826 L14 | FC 01/12/2027
update public.productos set nombre = 'Fc 01/12/2027' where sku = 'FC-F349C6DD';

-- FMX-080826 L15 | ANIMALIN GOTAS C/30 ML
update public.productos set nombre = 'Animalin Gotas', presentacion = 'C/30' where sku = 'FC-D751525D';

-- FMX-080826 L16 | GELCAVIT-9M CAPSULAS C/30
update public.productos set nombre = 'Gelcavit-9M Capsulas', presentacion = 'C/30' where sku = 'FC-4F05124E';

-- FMX-080826 L17 | FC 01/01/2028
update public.productos set nombre = 'Fc 01/01/2028' where sku = 'FC-85632ABD';

-- FMX-080826 L18 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-0906E3E1';

-- FMX-080826 L19 | FC 01/09/2027
update public.productos set nombre = 'Fc 01/09/2027' where sku = 'FC-4C3B3B9C';

-- FMX-080826 L20 | HUCIUS CAPSULAS C/30
update public.productos set nombre = 'Hucius Capsulas', presentacion = 'C/30' where sku = 'FC-1812D26D';

-- FMX-080826 L21 | FC 01/02/2028
update public.productos set nombre = 'Fc 01/02/2028' where sku = 'FC-EC96A027';

-- FMX-080826 L22 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-3B7A358D';

-- FMX-080826 L23 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-16C9352F';

-- FMX-080826 L24 | FC 01/03/2029
update public.productos set nombre = 'Fc 01/03/2029' where sku = 'FC-70F50FD7';

-- FMX-080826 L25 | FC 01/03/2028
update public.productos set nombre = 'Fc 01/03/2028' where sku = 'FC-D33D7A48';

-- FMX-080826 L26 | FOTOSUN-UV100 CREMA C/125 ML S0-FP$
update public.productos set nombre = 'Fotosun-Uv100 Crema S0-Fp$', presentacion = 'C/125' where sku = 'FC-00E8A9C7';

-- FMX-080826 L27 | FC 01/01/2028
update public.productos set nombre = 'Fc 01/01/2028' where sku = 'FC-D4342B8E';

-- FMX-080826 L28 | FC 01/02/2028
update public.productos set nombre = 'Fc 01/02/2028' where sku = 'FC-CF0AF2F6';

-- FMX-080826 L29 | FC 01/05/2028
update public.productos set nombre = 'Fc 01/05/2028' where sku = 'FC-5CA1622C';

-- FMX-080826 L30 | FC 01/04/2027
update public.productos set nombre = 'Fc 01/04/2027' where sku = 'FC-D0A49FC8';

-- FMX-080826 L31 | FC 01/02/2029
update public.productos set nombre = 'Fc 01/02/2029' where sku = 'FC-EB5DCEBE';

-- FMX-080826 L32 | ERBITRAX TABLETAS 250 MG C/7
update public.productos set nombre = 'E Itrax Tabletas 250 Mg', marca = 'Rb', presentacion = 'C/7' where sku = 'FC-DA34D88D';

-- FMX-080826 L33 | VALNAIT CAPSULAS C/30
update public.productos set nombre = 'Valnait Capsulas', presentacion = 'C/30' where sku = 'FC-BE2ACF63';

-- FMX-080826 L34 | FC 01/03/2027
update public.productos set nombre = 'Fc 01/03/2027' where sku = 'FC-D259E551';

-- FMX-080826 L35 | FC 01/12/2027
update public.productos set nombre = 'Fc 01/12/2027' where sku = 'FC-2782A4D6';

-- FMX-080826 L36 | FC 01/02/2028
update public.productos set nombre = 'Fc 01/02/2028' where sku = 'FC-E3CFD0A7';

-- FMX-080826 L37 | FC 01/04/2028
update public.productos set nombre = 'Fc 01/04/2028' where sku = 'FC-39E059E2';

-- FMX-080826 L38 | ALEVARIN CAPSULAS C/45
update public.productos set nombre = 'Alevarin Capsulas', presentacion = 'C/45' where sku = 'FC-DF39BB27';

-- FMX-080826 L39 | FC 01/09/2027
update public.productos set nombre = 'Fc 01/09/2027' where sku = 'FC-79C61297';

-- FMX-080826 L40 | FC 01/06/2028
update public.productos set nombre = 'Fc 01/06/2028' where sku = 'FC-EC93AE62';

-- FMX-080826 L41 | FC 01/05/2028
update public.productos set nombre = 'Fc 01/05/2028' where sku = 'FC-223B5D76';

-- FMX-080826 L42 | FC 01/09/2027
update public.productos set nombre = 'Fc 01/09/2027' where sku = 'FC-86606791';

-- FMX-080826 L44 | FC 01/03/2028
update public.productos set nombre = 'Fc 01/03/2028' where sku = 'FC-2E7C6CD6';

-- FMX-080826 L45 | FC 01/03/2028
update public.productos set nombre = 'Fc 01/03/2028' where sku = 'FC-D3FB53E9';

-- FMX-080826 L46 | FC 01/06/2028
update public.productos set nombre = 'Fc 01/06/2028' where sku = 'FC-E3C83D59';

-- FMX-080826 L47 | FC 01/05/2028
update public.productos set nombre = 'Fc 01/05/2028' where sku = 'FC-99F357DC';

-- FMX-080826 L48 | FC 01/06/2028
update public.productos set nombre = 'Fc 01/06/2028' where sku = 'FC-23CE9602';

-- FMX-080826 L49 | FC 01/01/2028
update public.productos set nombre = 'Fc 01/01/2028' where sku = 'FC-CAABC42B';

-- FMX-080826 L50 | FC 01/06/2028
update public.productos set nombre = 'Fc 01/06/2028' where sku = 'FC-E94C79BA';

-- FMX-080826 L51 | FC 01/10/2028
update public.productos set nombre = 'Fc 01/10/2028' where sku = 'FC-D75138BB';

-- FMX-080826 L52 | FC 01/11/2027
update public.productos set nombre = 'Fc 01/11/2027' where sku = 'FC-6E084251';

-- FMX-080826 L53 | FC 01/11/2028
update public.productos set nombre = 'Fc 01/11/2028' where sku = 'FC-30F56906';

-- FMX-080826 L54 | FC 01/05/2028
update public.productos set nombre = 'Fc 01/05/2028' where sku = 'FC-046D8251';

-- FMX-080826 L55 | FC 01/03/2028
update public.productos set nombre = 'Fc 01/03/2028' where sku = 'FC-D69881BF';

-- FMX-080826 L56 | FC 01/03/2028
update public.productos set nombre = 'Fc 01/03/2028' where sku = 'FC-C3B611F3';

-- FMX-080826 L57 | FC 01/04/2030
update public.productos set nombre = 'Fc 01/04/2030' where sku = 'FC-98518364';

-- FMX-080826 L58 | FC 01/04/2030
update public.productos set nombre = 'Fc 01/04/2030' where sku = 'FC-F89008C6';

-- FMX-080826 L59 | FC 01/05/2030
update public.productos set nombre = 'Fc 01/05/2030' where sku = 'FC-355851E7';

-- FMX-080826 L60 | FC 01711/2030
update public.productos set nombre = 'Fc 01711/2030' where sku = 'FC-C8B741F6';

-- FMX-080826 L61 | FC 01/11/2030
update public.productos set nombre = 'Fc 01/11/2030' where sku = 'FC-3B0C76C8';

-- FMX-080826 L62 | CATETER/INTRAVENOSO-SUMITEX PU 22 G X 25 MM C/1 AZUL
update public.productos set nombre = 'Cateter/Intravenoso-Sumitex Pu 22 G X 25 Mm Azul', presentacion = 'C/1' where sku = 'FC-BE0A0E46';

-- FMX-080826 L63 | FC 01/05/2028
update public.productos set nombre = 'Fc 01/05/2028' where sku = 'FC-ED3B0AD4';

-- FMX-080826 L64 | FC 01/06/2030
update public.productos set nombre = 'Fc 01/06/2030' where sku = 'FC-83941A95';

-- FMX-080826 L65 | FC 01/01/2031
update public.productos set nombre = 'Fc 01/01/2031' where sku = 'FC-E9FA700D';

-- FMX-080826 L66 | FC 01/06/2030
update public.productos set nombre = 'Fc 01/06/2030' where sku = 'FC-BE977010';

-- FMX-080826 L67 | FC 01/02/2028
update public.productos set nombre = 'Fc 01/02/2028' where sku = 'FC-35A0F20F';

-- FMX-080826 L68 | FC 01/12/2027
update public.productos set nombre = 'Fc 01/12/2027' where sku = 'FC-AE88EDDC';

-- FMX-080826 L69 | FC 13/12/2030
update public.productos set nombre = 'Fc 13/12/2030' where sku = 'FC-EE6593B4';

-- FMX-080826 L70 | FC 01/04/2030
update public.productos set nombre = 'Fc 01/04/2030' where sku = 'FC-93322783';

-- FMX-080826 L71 | FC 01/12/2030
update public.productos set nombre = 'Fc 01/12/2030' where sku = 'FC-20C90A6D';

-- FMX-080826 L72 | FC 01/03/2030
update public.productos set nombre = 'Fc 01/03/2030' where sku = 'FC-7607DDA7';

-- FMX-080826 L73 | FC 06/06/2030
update public.productos set nombre = 'Fc 06/06/2030' where sku = 'FC-8C9A304D';

-- FMX-080826 L74 | FC 15/04/2030
update public.productos set nombre = 'Fc 15/04/2030' where sku = 'FC-BA60704A';

-- FMX-080826 L75 | FC 01/11/2029
update public.productos set nombre = 'Fc 01/11/2029' where sku = 'FC-8EF34E83';

-- FL-080826 L1 | Desenfriolito Tab C/24 2 Pack Bayer Otc $ 93.80 Desenfriolito Tab C/24
update public.productos set nombre = 'ito Tab 2 Pack Bayer ito Tab 2 Pack', marca = 'Desenfriol', presentacion = 'C/24' where sku = 'FC-76040610';

-- FL-080826 L2 | Noche Tab C/12 Descto: 6.0K Tempra , Xt Noche Tab C/12 Tempra
update public.productos set nombre = 'Noche Tab K , Xt Noche Tab', marca = 'Tempra', presentacion = 'C/12' where sku = 'FC-60101231';

-- FL-080826 L3 | Graneodin E Naranja Tab C/16 Rb Health 135.10 Graneodin E Naranja Tab 
update public.productos set nombre = 'E Naranja Tab Rb Health 135.10 E Naranja Tab', marca = 'Graneodin', presentacion = 'C/16' where sku = 'FC-87154871';

-- FL-080826 L4 | Lubricante Soft Lub Pleasüre 56.7 Gr Health 1 $ 100.80 Soft Lub Pleasü
update public.productos set nombre = 'Soft Lub Pleasüre 56.7 Health 1 Soft Lub Pleasüre Er 28 Ksk', marca = 'Vitacilina' where sku = 'FC-60101521';

-- FL-080826 L5 | Dtc (Rojo) 20 Descto: 2.0% Afrin Spray (Rojo) Afrin Spray Ml | Bayer
update public.productos set nombre = '(Rojo) 20 Spray (Rojo) Spray Bayer', marca = 'Afrin' where sku = 'FC-06134531';

-- FL-080826 L6 | Pomada 100 Gr Descto: 2.0% Bepanthen Pomada Bepanthen
update public.productos set nombre = '100 Pomada', marca = 'Bepanthen' where sku = 'FC-08427330';

-- FL-080826 L7 | Tempra 24 Hrs Cab C/12 Rb Health $ Tempra 24 Hrs Cab C/12 135431222502
update public.productos set nombre = '24 Hrs Cab $', marca = 'Rb Health', presentacion = 'C/12' where sku = 'FC-58792792';

-- FL-080826 L8 | Eomelubrina Tab C/10 | Opella $ 73.70 Descto: 2.0% $ 72.23 Eomelubrina
update public.productos set nombre = 'Tab Opella', marca = 'Eomelubrina', presentacion = 'C/10' where sku = 'FC-50002301';

-- FL-080826 L9 | Histiacil Ne Jar Adto 150 Mi | Opella $ 124.40 $ 124.40 Descto: 2.0% $
update public.productos set nombre = 'Histiacil Ne Jar Adto 150 Mi Jar Adto 150 Mi', marca = 'Opella' where sku = 'FC-28979502';

-- FL-080826 L10 | Histiacil Ne Jar Ine 150 Ml | Opella 1 $ 125.80 $ 125.80 Descto: 2.0% 
update public.productos set nombre = 'Histiacil Ne Jar Ine 150 123.28 Jar Ine 150 G 123.28', marca = 'Opella', presentacion = '1 G' where sku = 'FC-89794961';

-- FL-080826 L11 | Bisolvon Jbe Ine 120 Ml | Lăb Hormona $ 147.90 Descto: 2.0% $ 144.94 $
update public.productos set nombre = 'Jbe Ine 120 Lăb Hormona Ine 120 Lăb Hormona', marca = 'Bisolvon' where sku = 'FC-79071241';

-- FL-080826 L12 | Nailex Desenterrador Unas 12 Ml Nailex Desenterrador Unas
update public.productos set nombre = 'Nailex Desenterrador Unas 12 Nailex Desenterrador Unas' where sku = 'FC-47624171';

-- FL-080826 L13 | "Lasico Enz C/. Dwightnd Descto: 15.0% "Lasico Dwightnd Cond Tro Jan
update public.productos set nombre = '"Lasico Enz C/. Dwightnd "Lasico Dwightnd Cond Tro Jan' where sku = 'FC-80950139';

-- FL-080826 L14 | Tribedoce Tab /30 Nvo Bruluart 5 $ 18.00 Tribedoce Tab /30 Nvo Bruluar
update public.productos set nombre = 'Tribedoce Tab /30 Nvo Bruluart 5 Tribedoce Tab /30 Nvo Bruluart' where sku = 'FC-88947797';

-- FL-080826 L15 | Performance Tab Descto: 2.0% Centrum C/30 Pg Pere Performance Tab Cent
update public.productos set nombre = 'Performance Tab Centrum Performance Tab Centrum', presentacion = 'C/30' where sku = 'FC-50959781';

-- FL-080826 L16 | È Tre & Ice C/3 Dwightnd Descto: 15.0% Cond Trojan È Tre & Ice C/3 Dwi
update public.productos set nombre = 'È Tre & Ice Dwightnd Cond Trojan È Tre & Ice Dwightnd', presentacion = 'C/3' where sku = 'FC-80953017';

-- FL-080826 L17 | Tempra 500 Mg Lab C/10 Rb Health $ 48.80 Descto: 6.0% Tempra 500 Mg {8
update public.productos set nombre = '500 Mg Rb Health Tempra 500 Mg {8 Ung I Ksk', marca = 'Vitacilina', presentacion = 'C/10' where sku = 'FC-54521161';

-- FL-080826 L18 | Hipoglos Pac Turo 45 Gr | Andromaco 1 $ 71.00 Descto: 2.0% $ 69.58 Tur
update public.productos set nombre = 'Hipoglos Pac Turo 45 Andromaco 1 Turo 45 Andromaco' where sku = 'FC-95201021';

-- FL-080826 L19 | Tabcin Eferv Tab C/12 | Bayer Ot C Descto: 2.0% 38.50 $ 37.73 Tab C/12
update public.productos set nombre = 'Tabcin Eferv Tab Ot C 38.50 Tab Ot C', marca = 'Bayer', presentacion = 'C/12' where sku = 'FC-08485316';

-- FL-080826 L20 | Centrum Silver Tab C/30 Pg Pere 1 Centrum Silver Tab C/30 Pere
update public.productos set nombre = 'Centrum Silver Tab 1 Centrum Silver Tab', presentacion = 'C/30' where sku = 'FC-65095947';

-- FL-080826 L21 | /10 | Rb Healte Sal De Uvas $ 37.90 Descto: 2.0% $ 37.14 /10 | Rb Heal
update public.productos set nombre = '/10 Healte Sal De Uvas /10 Healte Sal De Uvas Fazolin E Gotas', marca = 'Rb' where sku = 'FC-95451096';

-- FL-080826 L22 | Sanfer Descto: 8.04 Syncol Tab $ 107.40 $ 107.40 8 98.81 Sanfer Syncol
update public.productos set nombre = 'Sanfer Syncol Tab 8 98.81 Sanfer Syncol Tab 871210734092301 Syncol Max Tab' where sku = 'FC-79400556';

-- FL-080826 L23 | Lubricante Sico Sens Calor 50 Ml | Rb Health 1 $ 101.90 Lubricante Sic
update public.productos set nombre = 'Sico Sens Calor 50 1 Lubricante Sico Sens Calor 50 Rb', marca = 'Rb Health' where sku = 'FC-58793249';

-- FL-080826 L24 | Sal De Uvas Ixh C/50 | Rb Healti 1 $ 163.50 Descto: 2.0% $ 160.23 Sal 
update public.productos set nombre = 'Sal De Uvas Ixh Healti 1 Sal De Uvas Ixh Healti', marca = 'Rb', presentacion = 'C/50' where sku = 'FC-95467264';

-- FL-080826 L25 | Lubricante Ico Cereza 50 Ml Rb Health 1 $ 101.90 Ico Cereza 50 Microda
update public.productos set nombre = 'Ico Cereza 50 1 Ico Cereza 50 Microdacyn', marca = 'Rb Health' where sku = 'FC-87932321';

-- FL-080826 L26 | Tab C/100 Descto: 2.0% Alka-Seltzer Bayer C/100 Alka-Seltzer Ğel Rojo
update public.productos set nombre = 'Tab Alka-Seltzer Alka-Seltzer Ğel Rojo', marca = 'Bayer', presentacion = 'C/100' where sku = 'FC-08443026';

-- FL-080826 L27 | Tylenol Tab Kenvue 1 $ 50.00 Descto: 2.0% $ 49.00 $ Kenvue
update public.productos set nombre = 'Tylenol Tab Kenvue 1 $ Kenvue' where sku = 'FC-75354321';

-- FL-080826 L28 | Aspirina Tab 80 2 Paci Bayer Onc 1 $ 124.80 Aspirina Tab 80 2 Paci [73
update public.productos set nombre = 'Aspirina Tab 80 2 Paci Onc 1 Aspirina Tab 80 2 Paci [ Manzaniila', marca = 'Bayer' where sku = 'FC-08491074';

-- FL-080826 L29 | (A) Treda Tab €/20 Sanfer 2 $ 152.00 $ 304.00 Descto: 8.0% Sanfer Brun
update public.productos set nombre = '(A) Treda Tab €/20 Sanfer 2 Sanfer Brunadol Tab Desato: 2.0%' where sku = 'FC-70612368';

-- FL-080826 L30 | Anara Tab C/20 Chinoin 1 $ 162.60 Descto: 2.0% $ 159.35 Chinoin
update public.productos set nombre = 'Anara Tab Chinoin 1 Chinoin', presentacion = 'C/20' where sku = 'FC-88508929';

-- FL-080826 L31 | Forte Tab C/24 Descto: 2.0% Caf Iaspirina Forte C/24 Caf Iaspirina
update public.productos set nombre = 'Forte Tab Caf Iaspirina Forte Caf Iaspirina', presentacion = 'C/24' where sku = 'FC-84335531';

-- FL-080826 L32 | Sr I Lab Ting Crema 28 Hormona $ 73.60 Sr I Ting Crema 28 Hormona
update public.productos set nombre = 'Sr I Ting Crema 28 Hormona' where sku = 'FC-23001331';

-- FL-080826 L33 | Scabisan Crema Er I Chinoin 1 $ 194.60 Descto: 2.0% $ 190.71 Scabisan 
update public.productos set nombre = 'Scabisan Crema Er I Chinoin 1 Scabisan Crema Er I Chinoin' where sku = 'FC-85592111';

-- FL-080826 L34 | Boost Tar C/50 Descto: 2.0% Alka-Seltzer Bayer Boost Tar C/50 Alka-Sel
update public.productos set nombre = 'Boost Tar Alka-Seltzer Boost Tar Alka-Seltzer', marca = 'Bayer', presentacion = 'C/50' where sku = 'FC-84999001';

-- FL-080826 L35 | Bepanthen Multiusos Pomada Otc 30 Bepanthen Multiusos Pomada
update public.productos set nombre = 'Multiusos Pomada 30 Multiusos Pomada', marca = 'Bepanthen' where sku = 'FC-08498798';

-- FL-080826 L36 | Cafiaspirina Tar C/100 2 Pace Bayer Otc 221.90 Descto: 2.0% Cafiaspiri
update public.productos set nombre = 'Cafiaspirina Tar 2 Pace 221.90 Cafiaspirina Tar 2 Pace Corega Ultra', marca = 'Bayer', presentacion = 'C/100' where sku = 'FC-08491096';

-- FL-080826 L37 | Iv Neomelubrina Jbe 100 Ml I Opella 121.00 Neomelubrina Jbe 100 Ml I O
update public.productos set nombre = 'Iv N Jbe 100 I Opella 121.00 N Jbe 100 I Opella', marca = 'Eomelubrina' where sku = 'FC-50003151';

-- FL-080826 L38 | (A) Loxcel Adto Tab C/1 | Lab Hormona 2 $ 78.00 Descto: 6.0% $ 73.32 A
update public.productos set nombre = '(A) Loxcel Adto Tab Hormona 2 Adto Tab Hormona 2', presentacion = 'C/1' where sku = 'FC-24227339';

-- FL-080826 L39 | Herklin Shai 20 Ml Armstroni 1 $ 128.80 Descto: 2.0% $ 126.22 $ 128.80
update public.productos set nombre = 'Herklin Shai 20 Armstroni 1 20 Armstroni 265024 Genomma Alli-Triple' where sku = 'FC-98100381';

-- FL-080826 L40 | Supos Adto C/10 Otc Descto: 7.0% Senosiain Senosiain Supos Adto C/10 S
update public.productos set nombre = 'Supos Adto Senosiain Senosiain Supos Adto Senosiain Senosiain', presentacion = 'C/10' where sku = 'FC-14704156';

-- FL-080826 L41 | Supos Ine C/10 Descto: 7.0% Senosiain Supos C/10 Senosiain
update public.productos set nombre = 'Supos Ine Senosiain Supos Senosiain', presentacion = 'C/10' where sku = 'FC-14704163';

-- FL-080826 L42 | Lactopram 430 Mg Cap C/20 Progela 29.30 Descto: Lactopram 430 Mg Cap C
update public.productos set nombre = 'Lactopram 430 Mg Cap 29.30 Descto: Lactopram 430 Mg Cap', marca = 'Progela', presentacion = 'C/20' where sku = 'FC-08344488';

-- FL-080826 L43 | / 30 | Pg Pere Descto: 2.0% Centrum Tab $ 152.20 Pg Pere Centrum Tab
update public.productos set nombre = '/ 30 Centrum Tab Centrum Tab' where sku = 'FC-65095718';

-- FL-080826 L45 | Aspirina Eferv Tab C/12 Bayer Otc Aspirina Eferv C/12
update public.productos set nombre = 'Aspirina Eferv Tab Aspirina Eferv', marca = 'Bayer', presentacion = 'C/12' where sku = 'FC-08496701';

-- FL-080826 L46 | Tarmin 2 Mg /12 Tab Bruluagsa Descto: 2.05 6. Tarmin 2 Mg /12 Tab Brul
update public.productos set nombre = 'Tarmin 2 Mg / Bruluagsa 6. Tarmin 2 Mg / Bruluagsa', presentacion = '12 TABLETAS' where sku = 'FC-88915491';

-- FL-080826 L47 | Descto: 2.0% Afrodit 400 Ui 46.00 $ $ 45.08 Afrodit 400 Ui
update public.productos set nombre = 'Afrodit 400 Ui 46.00 $ Afrodit 400 Ui' where sku = 'FC-08344747';

-- FL-080826 L48 | Ky6 Tab C/10 Bruluart 5 $ 9.50 $ 9.31 $ 47.50 Bruluart E74011 Bayer 67
update public.productos set nombre = 'Ky6 Tab Bruluart 5 Bruluart E74011 67 Aspirina Tab', marca = 'Bayer', presentacion = 'C/10' where sku = 'FC-08895196';

-- FL-080826 L49 | Herklin Ne Sham 60 Ml | Armstrong 1 $ 81.00 Herklin Ne Sham 60 Ml | Ar
update public.productos set nombre = 'Herklin Ne Sham 60 Armstrong 1 Herklin Ne Sham 60 Armstrong' where sku = 'FC-89810021';

-- FL-080826 L50 | Lubricante Piel Con Piel 50 Mi Health 1 $ 102.50 Lubricante Piel Con P
update public.productos set nombre = 'Piel Con Piel 50 Mi Health 1' where sku = 'FC-60101378';

-- FL-080826 L51 | Desenfriol D Dab C/30 | Bayer Otc $ 63.00 Descto: 2.0% Desenfriol D Da
update public.productos set nombre = 'D Dab Bayer', marca = 'Desenfriol', presentacion = 'C/30' where sku = 'FC-60403681';

-- FL-080826 L52 | Iv Cilocid 5 Mg Tab C/20 | Bruluari 7.40 Descto: 2.0% $ 7.25 Iv Ciloci
update public.productos set nombre = 'Iv Cilocid 5 Mg Tab Bruluari 7.40', presentacion = 'C/20' where sku = 'FC-88923551';

-- FL-080826 L53 | Ab Pis. Descto: 2.0% Agrifen Tab 5. $ 19.50 Ab Pis. Agrifen Tab
update public.productos set nombre = 'Ab Pis. Agrifen Tab 5. Ab Pis. Agrifen Tab' where sku = 'FC-25116810';

-- FL-080826 L54 | Vick Drops Tengibre Pastillas C/20 Vick Drops Tengibre
update public.productos set nombre = 'Vick Drops Tengibre Pastillas Vick Drops Tengibre', presentacion = 'C/20' where sku = 'FC-35246309';

-- FL-080826 L55 | Ecuperador Una Lab Pisa Descto: 2.0% Aile Marilla 15 M Ecuperador Una 
update public.productos set nombre = 'Ecuperador Una Aile Marilla 15 M Ecuperador Una Aile Marilla 15 M', marca = 'Pisa' where sku = 'FC-47640531';

-- FL-080826 L56 | Saridon Tab 120 Bayer Oto $ 64.75 Saridon Tab
update public.productos set nombre = 'Saridon Tab 120 Oto Saridon Tab', marca = 'Bayer' where sku = 'FC-84095411';

-- FL-080826 L58 | Afrin Spray No Drip Extra Humectante Afrin Spray Drip Extra
update public.productos set nombre = 'Spray No Drip Extra Humectante Spray Drip Extra', marca = 'Afrin' where sku = 'FC-06247327';

-- FL-080826 L59 | Flanax 550 Mc Tab C/12 | Bayér Otc 203.00 Descto: 10.0% $ 182.70 Tab C
update public.productos set nombre = 'Flanax 550 Mc Tab Bayér 203.00 Tab Chinoin', presentacion = 'C/12' where sku = 'FC-84973401';

-- FL-080826 L60 | Gr 5.58 Bayer Descto: 2.0% Flanax Gel 40 Otc Gr 5.58 Flanax Gel 40
update public.productos set nombre = '5.58 Flanax Gel 40 5.58 Flanax Gel 40', marca = 'Bayer' where sku = 'FC-08426944';

-- FL-080826 L61 | Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell C/1 | Pg Health9.2
update public.productos set nombre = 'Iv Sot.O-Neurobion Dc Ete Jga Sot.O-Neurobion Prell Health9.20', presentacion = 'C/1' where sku = 'FC-82176351';

-- FL-080826 L63 | Iv Dolo-Neurobion Dc Jga Preli C/3 3 Ml | Pg Health 23.25 Descto: 17.0
update public.productos set nombre = 'Iv Dolo-Neurobion Dc Jga Preli 3 Health 23.25 Dolo-Neurobion Dc Jga Preli 3 Health', presentacion = 'C/3' where sku = 'FC-98217659';

-- FL-080826 L64 | Crema Dent Colgate Max Clean 120 Ml Colgate Palmolive $ 25.50 Descto: 
update public.productos set nombre = 'Crema Dent Colgate Max Clean 120 Colgate Crema Dent Colgate Max Clean 120 C', marca = 'Palmolive' where sku = 'FC-66888171';

-- FL-080826 L65 | 90 Crema Dent Aot.Cate Me P Crema Dent Aot.Cate
update public.productos set nombre = 'Crema Dent Aot.Cate Me P Crema Dent Aot.Cate' where sku = 'FC-66873531';

-- FL-080826 L66 | Sigital Protec Desato: 2.0% Termometro Degasa 42.10 Sigital Protec Des
update public.productos set nombre = 'Sigital Protec Desato: 2.0% Termometro 42.10 Sigital Protec Desato: 2.0% Termometro', marca = 'Degasa' where sku = 'FC-86708021';

-- FL-080826 L67 | Tela Adhesiva Quirmex 2.5Cmxsm | Quirmex Descto: 2.0% 29.90 29.30 $ 89
update public.productos set nombre = 'Tela Adhesiva Quirmex 2.5Cmxsm Quirmex 29.90 29.30 Quirmex 2.5Cmxsm Quirmex' where sku = 'FC-03406600';

-- FL-080826 L68 | Tela Adhesiva Quirmex 1.25Cmx5M | Quirmex 19.00 Descto: 2.0% $ 18.62 $
update public.productos set nombre = 'Tela Adhesiva Quirmex 1.25Cmx5M Quirmex 19.00 $ Quirmex 1.25Cmx5M Quirmex' where sku = 'FC-03406501';

-- FL-080826 L69 | Tela Adhesiva Quirmex 2.5Cmxi̇m | Quirmex 5 $ 11.70 Descto: 2.0% $ 11.
update public.productos set nombre = 'Tela Adhesiva Quirmex 2.5Cmxi̇m Quirmex 5 Tela Adhesiva Quirmex 2.5Cmxi̇m Quirmex' where sku = 'FC-34063651';

-- FL-080826 L70 | Tela Adhesiva Quirmex 1.25Cmx1M | Quirmex 5 5.40 $ Tela Adhesiva Quirm
update public.productos set nombre = 'Tela Adhesiva Quirmex 1.25Cmx1M Quirmex 5 5.40 $ Tela Adhesiva Quirmex 1.25Cmx1M Quirmex' where sku = 'FC-34062421';

-- FL-080826 L71 | Crema Deni Colgate Trip Xtra B 50 Ml 1 Colgate Paimolive 14.00 Descto:
update public.productos set nombre = 'Crema Deni Trip Xtra B 50 1 Paimolive 14.00 Trip Xtra B 50', marca = 'Colgate' where sku = 'FC-60689091';

-- FL-080826 L72 | Panuelos Kleenex Pack C/8 1 Kimberly Clark $ 33.30 Descto: 2.04 Panuel
update public.productos set nombre = 'Kleenex Pack 1 Clark', marca = 'Kimberly', presentacion = 'C/8' where sku = 'FC-73629981';

-- FL-080826 L73 | Panuelos Leenex C/90 | Kimberly Clark 25. $ Descto: 2.0% Leenex C/90 |
update public.productos set nombre = 'Leenex Clark 25. $ Leenex Clark Bib Evenelo', marca = 'Kimberly', presentacion = 'C/90' where sku = 'FC-56131681';

-- FL-080826 L74 | Cremi Dent Colgate Triple Acc 75 Ml Colgate Paimolive $ 19.20 Descto: 
update public.productos set nombre = 'Cremi Dent Triple Acc 75 Paimolive K Dent Triple Acc 75', marca = 'Colgate' where sku = 'FC-60009851';

-- FL-080826 L75 | Jeringa Sens Imedicai Insul 0.5 Ml C/100 | Jayor 1 $ 217.20 Jeringa Se
update public.productos set nombre = 'Jeringa Sens Imedicai Insul 0.5 Jayor 1 Jeringa Sens Imedicai Insul 0.5', presentacion = 'C/100' where sku = 'FC-23273451';

-- FL-080826 L76 | Bib Evenelo Ensueno Azul 802 | Kimberly Clark 1 $ 15.80 Descto: 2.0K B
update public.productos set nombre = 'Bib Evenelo Ensueno Azul 802 Clark 1 K Bib Evenelo Ensueno Azul 802 Clark', marca = 'Kimberly' where sku = 'FC-75163051';

-- FL-080826 L77 | Bib Evenelo Colors 8 02 | Kimberly Clark $ 15.80 Descto: 2.0% $ 15.48 
update public.productos set nombre = 'Bib Evenelo Colors 8 02 Clark Colors 8 02 Clark', marca = 'Kimberly' where sku = 'FC-27512574';

-- FL-080826 L78 | Bib Evenelo Colors 4 02 Kimberly Clark $ 13.40 Descto: 2.0* $ 13.13 40
update public.productos set nombre = 'Bib Evenelo Colors 4 02 Clark * 40.20 Colors 4 02 Clark Cepillo', marca = 'Kimberly' where sku = 'FC-75125811';

-- FL-080826 L79 | Algodon Quirmex Quirmex Descto: 2.0% Torunda De 76 Algodon Quirmex Qui
update public.productos set nombre = 'Quirmex Quirmex Torunda De 76 Algodon Quirmex Quirmex Torunda De' where sku = 'FC-34067851';

-- FL-080826 L80 | Pads Facial Protec Redondos C/100 | Degasa 2 $ 21.70 Pads Facial Prote
update public.productos set nombre = 'Pads Facial Protec Redondos 2 Pads Facial Protec Redondos', marca = 'Degasa', presentacion = 'C/100' where sku = 'FC-48623006';

-- FL-080826 L81 | Jeringa Sensimedical Insul 0.3 Ml C/100 | Jayor 1 $ Jeringa Sensimedic
update public.productos set nombre = 'Jeringa Sensimedical Insul 0.3 Jayor 1 $ Jeringa Sensimedical Insul 0.3', presentacion = 'C/100' where sku = 'FC-23272151';

-- FL-080826 L82 | Algodon Dibar 5 Gr Dibar 12 $ 6.90 Descto: 2.0% $ 6.76 $ 82.80 5 Gr Di
update public.productos set nombre = '5 12 5', marca = 'Dibar' where sku = 'FC-68910041';

-- FL-080826 L83 | Algodon Dibar 200 Gr Dibak 2 $ 35.30 Descto: 2.0% $ 34.59 70.60 200 Gr
update public.productos set nombre = '200 Dibak 2 70.60 200 Dibak', marca = 'Dibar' where sku = 'FC-89100101';

-- FL-080826 L84 | Venda Quirmex 7.5 Cm | Quirmex 12 $ 6.80 Descto: 2.0% $ 6.66 7.5 Cm | 
update public.productos set nombre = 'Venda Quirmex 7.5 Cm Quirmex 12 7.5 Cm Quirmex 5 50300340R7231 Venda Quirmex Cm Quirmex' where sku = 'FC-34067301';

-- FL-080826 L85 | Venda Quirme) Lo Cm Quirmex 8.90 Descto: 2.0% $ 8.72 Lo Cm Quirmex
update public.productos set nombre = 'Venda Quirme) Lo Cm Quirmex 8.90 Lo Cm Quirmex' where sku = 'FC-34067471';

-- FL-080826 L86 | Venda Quirmex 30 Cm | Quirmex 24.20 Descto: 2.0% $ 23.72 96.80 30 Cm |
update public.productos set nombre = 'Venda Quirmex 30 Cm Quirmex 24.20 96.80 30 Cm Quirmex Algodon', marca = 'Dibar' where sku = 'FC-34067781';

-- FL-080826 L87 | 60 Gr | Dibar Descto: 2.0% Algodon Dibar $ 10.10 60 Gr | Dibar Algodon
update public.productos set nombre = 'Algodon 60 Algodon', marca = 'Dibar' where sku = 'FC-68910034';

-- FL-080826 L88 | Crema Dent Colgate Total Colgate Palmolive $ Colgate Total Colgate
update public.productos set nombre = 'Crema Dent Colgate Total Colgate $ Colgate Total Colgate', marca = 'Palmolive' where sku = 'FC-66534951';

-- FL-080826 L89 | Gel Antibacterial Protec 250 Ml Degasa 22.40 Antibacterial Protec 250 
update public.productos set nombre = 'Gel Antibacterial Protec 250 22.40 Antibacterial Protec 250', marca = 'Degasa' where sku = 'FC-83510531';

-- FL-080826 L90 | Gasa Dibar 10X10 Paq 10 Cajitas/10 126.10 Dibar Gasa Dibar 10X10 Paq 1
update public.productos set nombre = 'Gasa 10X10 Paq 10 Cajitas/10 126.10 Gasa 10X10 Paq 10 Cajitas/10', marca = 'Dibar' where sku = 'FC-68900127';

-- FL-080826 L91 | Lox10 Exh C/100 Descto: 2.0% Gasa Dibar Dibar 111.10 Lox10 Exh C/100 G
update public.productos set nombre = 'Lox10 Exh Gasa 111.10 Lox10 Exh Gasa', marca = 'Dibar', presentacion = 'C/100' where sku = 'FC-68900134';

-- FL-080826 L92 | Espuma 120 Mi Descto: 2.0% Dermodine Degasa Espuma 120 Mi Dermodine
update public.productos set nombre = 'Espuma 120 Mi ine Degasa Espuma 120 Mi ine', marca = 'Dermod' where sku = 'FC-50882017';

-- FL-080826 L93 | 0 Dermod Ine M 1 Degasa 37.60 Dermod Ine Degasa
update public.productos set nombre = 'Ine M 1 Degasa 37.60 Ine Degasa', marca = 'Dermod' where sku = 'FC-08820243';

-- FL-080826 L94 | Cre Vitacilina Humectante 100 Gr Vitacilina Humectante
update public.productos set nombre = 'Cre Humectante 100 Humectante', marca = 'Vitacilina' where sku = 'FC-76000277';

-- FL-080826 L95 | 0 Stick Tripack Des Old Spice Gr Pg Pere Descto: 2.0% Stick Tripack De
update public.productos set nombre = 'Tripack', marca = 'Old Spice' where sku = 'FC-51444145';

-- FL-080826 L96 | Jermocleen Agua Oxigenada 230Ml Degasa Jermocleen Agua Oxigenada
update public.productos set nombre = 'Jermocleen Agua Oxigenada Jermocleen Agua Oxigenada', marca = 'Degasa', presentacion = '230 ML' where sku = 'FC-83351691';

-- FL-080826 L97 | Dermocleen Agua Oxigenada 100Ml | Degasa $ Dermocleen Agua Oxigenada 1
update public.productos set nombre = 'Dermocleen Agua Oxigenada $ Dermocleen Agua Oxigenada', marca = 'Degasa', presentacion = '100 ML' where sku = 'FC-83351381';

-- FL-080826 L98 | Pedialyte Sr60 Uva 500 Mi Abbott $ 24.30 Pedialyte Sr60 Uva 500 Mi
update public.productos set nombre = 'Pedialyte Sr60 Uva 500 Mi Abbott Pedialyte Sr60 Uva 500 Mi' where sku = 'FC-33956775';

-- FL-080826 L99 | Fresa 500 Pedialyte Sr60 Ml Abbott $ Fresa 500 Pedialyte Sr60 Abbott
update public.productos set nombre = 'Fresa 500 Pedialyte Sr60 Abbott $ Fresa 500 Pedialyte Sr60 Abbott' where sku = 'FC-33961373';

-- FL-080826 L100 | Agua Oxigenada Dermocleen 480Ml | Degasa 15.00 Agua Oxigenada Dermocle
update public.productos set nombre = 'Agua Oxigenada Dermocleen 15.00 Agua Oxigenada Dermocleen', marca = 'Degasa', presentacion = '480 ML' where sku = 'FC-48335305';

-- FL-080826 L101 | Manzana 500 Ml Descto: 2.0% Pedialyte Manzana 500 Ml Pedialyte
update public.productos set nombre = 'Manzana 500 Pedialyte Manzana 500 Pedialyte' where sku = 'FC-33954740';

-- FL-080826 L102 | Inder 360 Gf Descto: 2.0% Leche Nido Marcas Nestle Inder 360 Gf Leche 
update public.productos set nombre = 'Inder 360 Gf Leche Nido Inder 360 Gf Leche Nido', marca = 'Nestle' where sku = 'FC-59225411';

-- FL-080826 L103 | 360 Gr | Marcas Descto: 2.0% Leche Nidal 1 Nestle $ 112.70 360 Gr | Ma
update public.productos set nombre = '1 360 Leche 1', marca = 'Nestle' where sku = 'FC-51067711';

-- FL-080826 L104 | Nestum Probioticos Marcas Nestle Avena 270 Nestum Probioticos Marcas N
update public.productos set nombre = 'Probioticos Nestle Avena 270 Probioticos Nestle', marca = 'Nestum' where sku = 'FC-86167151';

-- FL-080826 L105 | Nutri Rindes Leche Nido Marcas Nestle Bolsa 240 Gr Nutri Rindes Leche 
update public.productos set nombre = 'Nutri Rindes Leche Nido Bolsa 240 Nutri Rindes Leche Nido', marca = 'Nestle' where sku = 'FC-92821171';

-- FL-080826 L106 | Nutri Rindes Leche Nido Marcas Nestle Bolsa Nutri Rindes Leche Nido
update public.productos set nombre = 'Nutri Rindes Leche Nido Bolsa Nutri Rindes Leche Nido', marca = 'Nestle' where sku = 'FC-58611420';

-- FL-080826 L107 | Öpt Imal Leche Nan 1 Marcas Pro Öpt Imal Leche Nan 1
update public.productos set nombre = 'Öpt Imal Leche Nan 1 Pro Öpt Imal Leche Nan 1' where sku = 'FC-51078461';

-- FL-080826 L108 | Öptimal Marcas Nestle Bolsa Leche Nan 2 Gr Öptimal Marcas Nestle Bolsa
update public.productos set nombre = 'Öptimal Bolsa Leche Nan 2 Öptimal Bolsa', marca = 'Nestle' where sku = 'FC-51078531';

-- FL-080826 L109 | Vaso Recolector I Quirmex Quirmex Descto: 2.0% $ 3.70 Recolector I Qui
update public.productos set nombre = 'Vaso Recolector I Quirmex Quirmex Recolector I Quirmex Quirmex' where sku = 'FC-29003221';

-- FL-080826 L110 | 525 Ml | Lab Pisa Electrolit Uva $ 20,50 Descto: 2.0% $ 20.09 525 Ml |
update public.productos set nombre = 'Pisa Uva 525 Pisa Uva', marca = 'Electrolit' where sku = 'FC-51448511';

-- FL-080826 L111 | Electrolit Coco 625 Ml Lab Pisa 20.50 Descto: 2.0% Electrolit Coco 625
update public.productos set nombre = 'Coco 625 Pisa 20.50 Coco 625 Pisa', marca = 'Electrolit' where sku = 'FC-25104411';

-- FL-080826 L112 | Electrolit Eresa-Kiwi 625 Ml | Lab Pisa 2 20.50 Electrolit Eresa-Kiwi 
update public.productos set nombre = 'Eresa-Kiwi 625 Pisa 2 20.50 Eresa-Kiwi 625 Pisa', marca = 'Electrolit' where sku = 'FC-25149221';

-- FL-080826 L113 | Electrolit Èresa 625 Mi | Lab Pisa $ 20.50 Descto: 2.0K $ 20.09 [75011
update public.productos set nombre = 'Èresa 625 Mi Pisa K [ Electrolid Èresa 625 Mi Pisa', marca = 'Electrolit' where sku = 'FC-25104268';

-- FL-080826 L114 | Electrolid Mora Azul 625 Ml | Lab Pisa 2 $ 20.50 Descto: 2.0K $ 20.09 
update public.productos set nombre = 'Electrolid Mora Azul 625 2 K Mora Azul 625', marca = 'Pisa' where sku = 'FC-51747971';

-- FL-080826 L115 | Absorsec C/120 Clark Descto: 2.0% Toa Hum Kimberly Absorsec C/120 Clar
update public.productos set nombre = 'Absorsec Clark Toa Hum Absorsec Clark Toa Hum', marca = 'Kimberly', presentacion = 'C/120' where sku = 'FC-43471900';

-- FL-080826 L116 | Cotonetes Quirmex Tarro C/100 1 Quirmex 2 12.00 Cotonetes Quirmex Tarr
update public.productos set nombre = 'Cotonetes Quirmex Tarro 1 Quirmex 2 12.00 Cotonetes Quirmex Tarro 1 Quirmex', presentacion = 'C/100' where sku = 'FC-34064021';

-- FL-080826 L117 | Lubricante Prudence Grosella 75 Ml | Dkt Mexico $ 68.20 Lubricante Pru
update public.productos set nombre = 'Prudence Grosella 75 Dkt Mexico Lubricante Prudence Grosella 75 Dkt' where sku = 'FC-14983153';

-- FL-080826 L118 | Toa -Hum Huggies Cuidado Puro C/80 | Kimberly Clark $ 39.60 Descto: 2.
update public.productos set nombre = 'Hum Huggies Cuidado Puro Clark K 9 Huggies Cuidado Puro Clark', marca = 'Kimberly', presentacion = 'C/80' where sku = 'FC-43454811';

-- FL-080826 L119 | Retardante C/3 Descto: 9.0% [7502214985348] Cond Prudence 'Ull Retarda
update public.productos set nombre = 'Retardante [ ] Cond Prudence ''Ull Retardante', presentacion = 'C/3' where sku = 'FC-49824391';

-- FL-080826 L120 | Cond Prudence 'Ull Sensitive C/3 Dkt Cond Prudence 'Ull Sensitive
update public.productos set nombre = 'Cond Prudence ''Ull Sensitive Dkt Cond Prudence ''Ull Sensitive', presentacion = 'C/3' where sku = 'FC-14985348';

-- FL-080826 L121 | Cond Prudence Extra Pleasure C/3 Dkt Cond Prudence Extra Pleasure
update public.productos set nombre = 'Cond Prudence Extra Pleasure Dkt Cond Prudence Extra Pleasure', presentacion = 'C/3' where sku = 'FC-49853867';

-- FL-080826 L122 | Cond Prudence Iva C/3 Dki Mexico S Cond Prudence Iva C/3 Mexico
update public.productos set nombre = 'Cond Prudence Iva Dki Mexico S Cond Prudence Iva Mexico', presentacion = 'C/3' where sku = 'FC-49824911';

-- FL-080826 L124 | Lubricante Prudence Natural 75 Ml Lubricante Prudence Natural
update public.productos set nombre = 'Prudence Natural 75 Lubricante Prudence Natural' where sku = 'FC-14983726';

-- FL-080826 L125 | Fresa C/3 I Dkt Descto: 9.0% Cond Prudence Fresa I Dkt Cond Prudence
update public.productos set nombre = 'Fresa I Dkt Cond Prudence Fresa I Dkt Cond Prudence', presentacion = 'C/3' where sku = 'FC-49824771';

-- FL-080826 L126 | 0.9 Mt Hilo Dental Ğum Expanding Sunstar Americasi $ 18.90 Descto: 2.0
update public.productos set nombre = '0.9 Mt Hilo Dental Ğum Expanding Americasi Hilo Dental Ğum Expanding Americasi', marca = 'Sunstar' where sku = 'FC-58203691';

-- FL-080826 L127 | Chocolate C/3 Descto: 9.0% Cond Prudence Dkt Mexico $ 34.10 Chocolate 
update public.productos set nombre = 'Chocolate Cond Prudence Dkt Mexico', presentacion = 'C/3' where sku = 'FC-14982514';

-- FL-080826 L128 | Eresa Pomada Labello Bde Merico $ 56.50 Descto: 2.0% Eresa Pomada Labe
update public.productos set nombre = 'Eresa Pomada Labello Bde Merico' where sku = 'FC-45079011';

-- FL-080826 L129 | Mora C/3 Dkt Cond Prudence Mexico 34.10 Mora C/3 Cond Prudence Mexico
update public.productos set nombre = 'Mora Dkt Cond Prudence Mexico 34.10 Mora Cond Prudence Mexico', presentacion = 'C/3' where sku = 'FC-14980596';

-- FL-080826 L130 | Cond Prudence Clasico C/3 I Dkt Mexico 32.20 Descto: 9.0% Cond Prudenc
update public.productos set nombre = 'Cond Prudence Clasico I Dkt Mexico 32.20 Cond Prudence Clasico I Dkt Mexico', presentacion = 'C/3' where sku = 'FC-49800151';

-- FL-080826 L131 | Jarabe 250 Ml 1 Nat Descto: 2.0% Ajolotius Bioal Imentos Jarabe 250 Ml
update public.productos set nombre = 'Jarabe 250 1 Nat Bioal Imentos Jarabe 250 1 Bioal Imentos', marca = 'Ajolotius' where sku = 'FC-62746605';

-- FL-080826 L132 | Pomada Labello Hydro-C I Bde Mexico $ 56.50 Descto: 2.0% $ 55.37 Pomad
update public.productos set nombre = 'Labello Hydro-C I Bde Mexico' where sku = 'FC-45045281';

-- FL-080826 L133 | Pomada I.Abeili.C Lasico | Rde Mexic( 56.50 Descto: 2.0% $ 55.37 56.50
update public.productos set nombre = 'I.Abeili.C Lasico Rde Mexic( 56.50 56.50 Lasico Rde Mexic(' where sku = 'FC-54504870';

-- FL-080826 L134 | Ajolotius Jengibre Tab C/10 Bioalimentos Nati Jengibre C/10 Bioaliment
update public.productos set nombre = 'Jengibre Tab Nati Jengibre', marca = 'Bioalimentos', presentacion = 'C/10' where sku = 'FC-52400212';

-- FL-080826 L135 | Ajolotius Pastillas Elderberry Past Bioalimentos Nat $ 21.00 Descto: 2
update public.productos set nombre = 'Pastillas Elderberry Past Nat Ajolotius Pastillas Elderberry Past', marca = 'Bioalimentos' where sku = 'FC-24004581';

-- FL-080826 L136 | Toa Hum Escudo Intbacterial C/50 $ Besbfrzy Clark 15.60 Toa Hum Escudo
update public.productos set nombre = 'Hum Escudo Intbacterial $ Besbfrzy Clark 15.60 Toa Hum Escudo Intbacterial Besbfrzy Clark', presentacion = 'C/50' where sku = 'FC-56034041';

-- FL-080826 L137 | 1083 Oro Manzanilla Ml Hnos 31.40 Descto: 2.0% Oro Manzanilla Hnos
update public.productos set nombre = 'Oro Hnos 31.40 Oro Hnos', marca = 'Manzanilla' where sku = 'FC-21042481';

-- FL-080826 L138 | , Ajolotius Jbe Elderberry 2501 Bioalimentos Nati 74.70 $ $ 73.21 Elde
update public.productos set nombre = 'Jbe Elderberry 2501 Nati 74.70 $ Elderberry 2501 Nati', marca = 'Bioalimentos' where sku = 'FC-52400267';

-- FL-080826 L139 | Ajolotius Jarabe S/Azucar 250 Ml. I Bioalimentos Nati $ 89.20 $ 87.42 
update public.productos set nombre = 'Jarabe S/Azucar 250 . I Nati', marca = 'Bioalimentos' where sku = 'FC-62746612';

-- FL-080826 L140 | Ajolotius Menta Eucal S/Azucar Past Ajolotius Menta Eucal
update public.productos set nombre = 'Menta Eucal S/Azucar Past Menta Eucal', marca = 'Ajolotius' where sku = 'FC-52400038';

-- FL-080826 L141 | Ajolotius Jarabe Reforzado 250 Ml Bioalimentos Nat: Ajolotius Jarabe R
update public.productos set nombre = 'Jarabe Reforzado 250 Nat: Ajolotius Jarabe Reforzado', marca = 'Bioalimentos' where sku = 'FC-62746698';

-- FL-080826 L143 | Ajolotius Menta Fucal C/10 Bioalimentos Ajolotius Menta Fucal
update public.productos set nombre = 'Menta Fucal Ajolotius Menta Fucal', marca = 'Bioalimentos', presentacion = 'C/10' where sku = 'FC-62746643';

commit;
