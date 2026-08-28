-- ============================================================================
-- FARMA CAPITAL — Lote fotos IMG_5455–5720 (16-ago-2026)
--
-- 1) Pone EAN a 71 SKU EQ- del ticket Equilibrio que se cargaron sin código.
--    No toca nombre, costo, precio ni stock.
-- 2) Da de alta 29 productos que no estaban. Sin costo (la foto no lo trae).
--    precio=0, stock=0. Ibarra corrige a mano.
--
-- No toca las 26 cajas que son otra presentación (Figral 50, Faribrox adulto,
-- Laritol EX tabletas, Oxital-C 1000, Flexiver 15, etc.).
-- Idempotente. No va en transacción.
-- ============================================================================

-- 1) EAN en EQ- que ya existen y no tienen código
-- 0130 POPRAM (pantoprazol) Tableta 40 mg C/28 AMSA
update public.productos
   set codigo_barras = '7501349028845'
 where sku = 'EQ-AMS498'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501349028845'
                     and o.sku <> 'EQ-AMS498');

-- 0028 Espadiva (Hioscina / Ibuprofeno) tableta 20/400 mg C/10
update public.productos
   set codigo_barras = '7501277091034'
 where sku = 'EQ-APO142'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501277091034'
                     and o.sku <> 'EQ-APO142');

-- 0106 Soltadol (Paracetamol) Tableta 750 mg C/10 AVITUS
update public.productos
   set codigo_barras = '7502209858084'
 where sku = 'EQ-AVT216'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502209858084'
                     and o.sku <> 'EQ-AVT216');

-- 0053 Biomesina Compuesta (Butilbromuro de hioscina / Metamizol só
update public.productos
   set codigo_barras = '7501573900115'
 where sku = 'EQ-BIO003'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573900115'
                     and o.sku <> 'EQ-BIO003');

-- 0036 Docsi (Clorfenamina) tableta 4 mg C/20 BIOMEP
update public.productos
   set codigo_barras = '7501573900153'
 where sku = 'EQ-BIO021'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573900153'
                     and o.sku <> 'EQ-BIO021');

-- 0105 Wadil (Metformina - Glibenclamida) Tabletas 500 mg / 5 mg C/
update public.productos
   set codigo_barras = '7501573900252'
 where sku = 'EQ-BIO058'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573900252'
                     and o.sku <> 'EQ-BIO058');

-- 0008 Gristalit (Loratadina / Ambroxol) solución 100-600 mg/100 mL
update public.productos
   set codigo_barras = '7501573904700'
 where sku = 'EQ-BIO112'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573904700'
                     and o.sku <> 'EQ-BIO112');

-- 0017 Bixen (Naproxeno sódico) tabletas 550 mg C/12 BIOMEP
update public.productos
   set codigo_barras = '7501573908104'
 where sku = 'EQ-BIO167'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573908104'
                     and o.sku <> 'EQ-BIO167');

-- 0037 Broxtorfan Infantil (Dextrometorfano / Ambroxol) jarabe 113 
update public.productos
   set codigo_barras = '7501573908036'
 where sku = 'EQ-BIO188'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501573908036'
                     and o.sku <> 'EQ-BIO188');

-- 0030 Lo-Bruquin (Quinfamida / Albendazol) tableta 150/200 mg C/2 
update public.productos
   set codigo_barras = '7502208894915'
 where sku = 'EQ-BRL072'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502208894915'
                     and o.sku <> 'EQ-BRL072');

-- 0024 Materfol (Ácido fólico) tabletas 400 mcg frasco 90 cmd
update public.productos
   set codigo_barras = '7501590222214'
 where sku = 'EQ-CMD015'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501590222214'
                     and o.sku <> 'EQ-CMD015');

-- 0023 Maracina (Bencidamina) solución 150 mg/100 mL atomizador 30 
update public.productos
   set codigo_barras = '7503028771400'
 where sku = 'EQ-COD060'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7503028771400'
                     and o.sku <> 'EQ-COD060');

-- 0067 Baño Coloide () Polvo pH 5.75 C/sobre 90 g SUANCA
update public.productos
   set codigo_barras = '7503028771684'
 where sku = 'EQ-COD086'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7503028771684'
                     and o.sku <> 'EQ-COD086');

-- 0131 Bonazin (Meclozina, Piridoxina, Lidocaína) Solución Inyectab
update public.productos
   set codigo_barras = '0780083139575'
 where sku = 'EQ-COL016'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0780083139575'
                     and o.sku <> 'EQ-COL016');

-- 0127 Nosipren (Prednisona) Tableta 20 mg C/30 Collins
update public.productos
   set codigo_barras = '0780083142827'
 where sku = 'EQ-COL133'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0780083142827'
                     and o.sku <> 'EQ-COL133');

-- 0035 Volfenac GEL (Diclofenaco) gel 2.32% C/1 Collins
update public.productos
   set codigo_barras = '0780083149024'
 where sku = 'EQ-COL239'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0780083149024'
                     and o.sku <> 'EQ-COL239');

-- 0025 Alzocid (Tadalafil) tableta 20 mg C/4 Collins
update public.productos
   set codigo_barras = '0780083149055'
 where sku = 'EQ-COL258'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0780083149055'
                     and o.sku <> 'EQ-COL258');

-- 0006 Delaphil (Tadalafil) tableta 5 mg C/14 DLP Pharma
update public.productos
   set codigo_barras = '7506476200126'
 where sku = 'EQ-DEN074'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7506476200126'
                     and o.sku <> 'EQ-DEN074');

-- 0033 Farmiver infantil (Quinfamida - Albendazol) suspensión 100 m
update public.productos
   set codigo_barras = '7502006921967'
 where sku = 'EQ-FAC0057'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502006921967'
                     and o.sku <> 'EQ-FAC0057');

-- 0055 CIFHIR (Bencidamina) gel 5% C/1 Farmacéutica Hispanoamerican
update public.productos
   set codigo_barras = '7502213040871'
 where sku = 'EQ-HIS045'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502213040871'
                     and o.sku <> 'EQ-HIS045');

-- 0123 FARMAREST (Salbutamol) Aerosol 100 µg C/1 FH
update public.productos
   set codigo_barras = '7502213042738'
 where sku = 'EQ-HIS081'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502213042738'
                     and o.sku <> 'EQ-HIS081');

-- 0065 Carbafen (Metocarbamol / Paracetamol) Tableta 400 mg / 350 m
update public.productos
   set codigo_barras = '7501836000118'
 where sku = 'EQ-LIF006'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501836000118'
                     and o.sku <> 'EQ-LIF006');

-- 0002 Queratal (Tretinoína) crema 0.05% tubo 20 g LIFERPAL
update public.productos
   set codigo_barras = '7501836002020'
 where sku = 'EQ-LIF033'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501836002020'
                     and o.sku <> 'EQ-LIF033');

-- 0016 Cineprac (Trimebutina) tabletas 200 mg C/20 LIFERPAL
update public.productos
   set codigo_barras = '7501836002969'
 where sku = 'EQ-LIF064'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501836002969'
                     and o.sku <> 'EQ-LIF064');

-- 0047 Realdrax-MXD (Hioscina, Ibuprofeno) tableta 20 mg / 400 mg C
update public.productos
   set codigo_barras = '7501836010087'
 where sku = 'EQ-LIF153'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501836010087'
                     and o.sku <> 'EQ-LIF153');

-- 0102 NEOSEDAL (METAMIZOL SÓDICO) Jarabe 5 g / 100 mL C/120 mL LOE
update public.productos
   set codigo_barras = '7502211780687'
 where sku = 'EQ-LOE014'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502211780687'
                     and o.sku <> 'EQ-LOE014');

-- 0094 Pensodil-S (Naproxeno - Paracetamol) Supositorios 100 mg / 2
update public.productos
   set codigo_barras = '7502211784043'
 where sku = 'EQ-LOE066'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502211784043'
                     and o.sku <> 'EQ-LOE066');

-- 0022 Faribrox TM Infantil (Ambroxol / Dextrometorfano) jarabe 150
update public.productos
   set codigo_barras = '7502211789284'
 where sku = 'EQ-LOE131'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502211789284'
                     and o.sku <> 'EQ-LOE131');

-- 0057 ROSANIL (Nitazoxanida) tabletas 500 mg C/7 LOEFFLER
update public.productos
   set codigo_barras = '7502211783954'
 where sku = 'EQ-LOE135'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502211783954'
                     and o.sku <> 'EQ-LOE135');

-- 0086 Figral (Sildenafil) Tableta 100 mg C/10 MAVI
update public.productos
   set codigo_barras = '0785118753962'
 where sku = 'EQ-MAI144'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0785118753962'
                     and o.sku <> 'EQ-MAI144');

-- 0097 MAVIGLIN (Metformina / Glibenclamida) Tableta 500 mg / 5 mg 
update public.productos
   set codigo_barras = '0785118754204'
 where sku = 'EQ-MAI150'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0785118754204'
                     and o.sku <> 'EQ-MAI150');

-- 0093 CROSTOX (Rosuvastatina) Tableta 20 mg C/30 MAVI
update public.productos
   set codigo_barras = '0785120755466'
 where sku = 'EQ-MAI163'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '0785120755466'
                     and o.sku <> 'EQ-MAI163');

-- 0098 Dolxen (NAPROXENO) Tableta 500 mg C/10 Maver
update public.productos
   set codigo_barras = '7502009741593'
 where sku = 'EQ-MAV162'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009741593'
                     and o.sku <> 'EQ-MAV162');

-- 0073 Flexiver Compuesto (Meloxicam / Metocarbamol) Cápsula 7.5 mg
update public.productos
   set codigo_barras = '7502009742101'
 where sku = 'EQ-MAV175'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009742101'
                     and o.sku <> 'EQ-MAV175');

-- 0110 Oxatech (OLANZAPINA) Tableta 10 mg C/14 Maver
update public.productos
   set codigo_barras = '7502009744426'
 where sku = 'EQ-MAV196'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009744426'
                     and o.sku <> 'EQ-MAV196');

-- 0010 Versalver (Valsartán) comprimido 80 mg C/30 Maver
update public.productos
   set codigo_barras = '7502009744839'
 where sku = 'EQ-MAV206'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009744839'
                     and o.sku <> 'EQ-MAV206');

-- 0027 Linexel (Venlafaxina) cápsula LP 75 mg C/20 Maver
update public.productos
   set codigo_barras = '7502009745386'
 where sku = 'EQ-MAV239'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009745386'
                     and o.sku <> 'EQ-MAV239');

-- 0089 Berniver (Mupirocina) Ungüento 2 % C/tubo 15 g Maver
update public.productos
   set codigo_barras = '7502009745836'
 where sku = 'EQ-MAV266'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009745836'
                     and o.sku <> 'EQ-MAV266');

-- 0120 VERATRIN (BETAMETASONA, INDOMETACINA, METOCARBAMOL) Cápsula 
update public.productos
   set codigo_barras = '7502009746420'
 where sku = 'EQ-MAV307'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009746420'
                     and o.sku <> 'EQ-MAV307');

-- 0126 Lonvitol (BROMURO DE IPRATROPIO, SALBUTAMOL) Solución 0.5 mg
update public.productos
   set codigo_barras = '7502009747021'
 where sku = 'EQ-MAV331'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009747021'
                     and o.sku <> 'EQ-MAV331');

-- 0096 Cetilver (PIRFENIDONA) Gel 8 g / 100 g C/10 g Maver
update public.productos
   set codigo_barras = '7502009748448'
 where sku = 'EQ-MAV392'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009748448'
                     and o.sku <> 'EQ-MAV392');

-- 0121 Daimant (RIMANTADINA) Cápsula 100 mg C/14 Maver
update public.productos
   set codigo_barras = '7502009749452'
 where sku = 'EQ-MAV407'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502009749452'
                     and o.sku <> 'EQ-MAV407');

-- 0122 Cirulan (METOCLOPRAMIDA) Tabletas 10 mg C/20 Novag
update public.productos
   set codigo_barras = '7501075710786'
 where sku = 'EQ-NOV004'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501075710786'
                     and o.sku <> 'EQ-NOV004');

-- 0125 Lambliquín (DIYODOHIDROXIQUINOLEÍNA, METRONIDAZOL) Tabletas 
update public.productos
   set codigo_barras = '7501075717044'
 where sku = 'EQ-NOV054'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501075717044'
                     and o.sku <> 'EQ-NOV054');

-- 0059 Nineka (Neomicina, Caolín y Pectina) tabletas 129 mg/280 mg/
update public.productos
   set codigo_barras = '7501075722253'
 where sku = 'EQ-NOV137'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501075722253'
                     and o.sku <> 'EQ-NOV137');

-- 0071 Glunovag (Metformina) Tableta 500 mg Frasco 60 Novag
update public.productos
   set codigo_barras = '7501075717013'
 where sku = 'EQ-NOV157'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501075717013'
                     and o.sku <> 'EQ-NOV157');

-- 0119 Pirinovag (METAMIZOL SÓDICO) Tableta 500.00 mg C/10 Novag
update public.productos
   set codigo_barras = '7501075727517'
 where sku = 'EQ-NOV176'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501075727517'
                     and o.sku <> 'EQ-NOV176');

-- 0004 Tefilinb (Tolterodina) tableta 2 mg C/28 Nucitec
update public.productos
   set codigo_barras = '7506353200645'
 where sku = 'EQ-NUC034'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7506353200645'
                     and o.sku <> 'EQ-NUC034');

-- 0029 Progelben (Benzonato) cápsula 100 mg C/20
update public.productos
   set codigo_barras = '7503008344211'
 where sku = 'EQ-PGE046'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7503008344211'
                     and o.sku <> 'EQ-PGE046');

-- 0128 Esterinol (Retinol) Cápsula 50,000 UI C/40
update public.productos
   set codigo_barras = '7503027446439'
 where sku = 'EQ-PGE061'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7503027446439'
                     and o.sku <> 'EQ-PGE061');

-- 0101 MITAFAR (NITAZOXANIDA) Suspensión 100 mg / 5 mL C/60 mL QUIM
update public.productos
   set codigo_barras = '7502223111073'
 where sku = 'EQ-QUM006'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502223111073'
                     and o.sku <> 'EQ-QUM006');

-- 0041 QUIMIKAN (Benzocaína) solución 200 mg/mL C/1 QUIMPHARMA
update public.productos
   set codigo_barras = '7502223112445'
 where sku = 'EQ-QUM052'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502223112445'
                     and o.sku <> 'EQ-QUM052');

-- 0060 QUIMUNEX (Prednisolona) solución 100 mg/100 mL C/1 QUIMPHARM
update public.productos
   set codigo_barras = '7502223111288'
 where sku = 'EQ-QUM068'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502223111288'
                     and o.sku <> 'EQ-QUM068');

-- 0107 Cyrux (Misoprostol) Tableta 200 mcg C/28 Serral
update public.productos
   set codigo_barras = '7501258205221'
 where sku = 'EQ-SER116'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501258205221'
                     and o.sku <> 'EQ-SER116');

-- 0011 Lisertil (Tibolona) tableta 2.5 mg C/30
update public.productos
   set codigo_barras = '7501258205474'
 where sku = 'EQ-SER117'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501258205474'
                     and o.sku <> 'EQ-SER117');

-- 0115 ESTRANIM (Oseltamivir) Cápsula 75 mg C/10 Serral
update public.productos
   set codigo_barras = '7501258208178'
 where sku = 'EQ-SER165'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501258208178'
                     and o.sku <> 'EQ-SER165');

-- 0019 Murreolak (Acetilcisteína) efervescente 600 mg 2 tubos x 10 
update public.productos
   set codigo_barras = '7501258215954'
 where sku = 'EQ-SER183'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501258215954'
                     and o.sku <> 'EQ-SER183');

-- 0078 Busconet (Metamizol sódico / Hioscina) Tableta 250 mg / 10 m
update public.productos
   set codigo_barras = '7502001160026'
 where sku = 'EQ-SON034'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001160026'
                     and o.sku <> 'EQ-SON034');

-- 0100 Magnil infantil (Metamizol Sódico) Jarabe 250 mg / 5 mL C/10
update public.productos
   set codigo_barras = '7502001160231'
 where sku = 'EQ-SON089'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001160231'
                     and o.sku <> 'EQ-SON089');

-- 0048 Meclison (Meclizina, Piridoxina) tabletas 25 mg, 50 mg C/20 
update public.productos
   set codigo_barras = '7502001162525'
 where sku = 'EQ-SON091'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001162525'
                     and o.sku <> 'EQ-SON091');

-- 0114 Fenimeth-v (Metronidazol, Nistatina) Óvulos 500 mg, 100 000 
update public.productos
   set codigo_barras = '7502001164697'
 where sku = 'EQ-SON096'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001164697'
                     and o.sku <> 'EQ-SON096');

-- 0113 Metroson (Metronidazol) Suspensión 250 mg / 5 mL C/120 mL SO
update public.productos
   set codigo_barras = '7502001164611'
 where sku = 'EQ-SON098'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001164611'
                     and o.sku <> 'EQ-SON098');

-- 0095 Neoderm-F (Acetónido de Fluocinolona, Neomicina) Crema 0.01 
update public.productos
   set codigo_barras = '7502001166028'
 where sku = 'EQ-SON104'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001166028'
                     and o.sku <> 'EQ-SON104');

-- 0032 Dual (Clotrimazol) óvulo 200 mg / crema 1% C/3 Son's
update public.productos
   set codigo_barras = '7502001163485'
 where sku = 'EQ-SON164'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001163485'
                     and o.sku <> 'EQ-SON164');

-- 0052 Ardosons (Indometacina, Betametasona, Metocarbamol) cápsulas
update public.productos
   set codigo_barras = '7502001162426'
 where sku = 'EQ-SON175'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502001162426'
                     and o.sku <> 'EQ-SON175');

-- 0043 Trociletas B (Cloruro de cetilpiridinio, Benzocaína) tableta
update public.productos
   set codigo_barras = '7501547522145'
 where sku = 'EQ-STR008'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501547522145'
                     and o.sku <> 'EQ-STR008');

-- 0082 Retoflam F (Metocarbamol / Meloxicam) Tableta 215 mg / 15 mg
update public.productos
   set codigo_barras = '7502216792197'
 where sku = 'EQ-ULT056'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502216792197'
                     and o.sku <> 'EQ-ULT056');

-- 0045 Rotumal GEL (Diclofenaco) gel 1.16%  GEL pharma
update public.productos
   set codigo_barras = '7502227426869'
 where sku = 'EQ-VIT055'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502227426869'
                     and o.sku <> 'EQ-VIT055');

-- 0039 Bocetix (Levocetirizina) solución 0.5 mg/mL C/1 vitae
update public.productos
   set codigo_barras = '7501478317421'
 where sku = 'EQ-VIT073'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7501478317421'
                     and o.sku <> 'EQ-VIT073');

-- 0009 Rosel (Amantadina / Clorfenamina / Paracetamol) cápsula 50/3
update public.productos
   set codigo_barras = '7503003738404'
 where sku = 'EQ-WER025'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7503003738404'
                     and o.sku <> 'EQ-WER025');

-- 0072 Punab (Losartán) Tableta 50.0 mg C/30 WERMAR
update public.productos
   set codigo_barras = '7502240450070'
 where sku = 'EQ-WER040'
   and coalesce(codigo_barras, '') = ''
   and not exists (select 1 from public.productos o
                   where o.codigo_barras = '7502240450070'
                     and o.sku <> 'EQ-WER040');

-- 2) Altas nuevas (solo si no está el SKU ni el EAN)
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
    v_review := ', price_needs_review';
  end if;

  for r in
    select * from (values

      ('FC-01164413', '7502001164413',
       'Clotrimazol óvulo 500 mg C/1 SON''S'),
      ('FC-09747205', '7502009747205',
       'Benzocaína gel Maver'),
      ('FC-42802565', '7501342802565',
       'Metformina 850 mg C/30 beadvance'),
      ('FC-49024601', '7501349024601',
       'Butilhioscina 10 mg C/10 AMSA'),
      ('FC-04908677', '7503004908677',
       'Clioquinol crema 3% tubo 20 g Alpharma'),
      ('FC-49025943', '7501349025943',
       'Pregabalina 75 mg AMSA'),
      ('FC-16796843', '7502216796843',
       'Sildenafil 100 mg C/4 Ultra'),
      ('FC-24900908', '7506624900908',
       'Quetiapina 100 mg C/60 beadvance'),
      ('FC-16796737', '7502216796737',
       'Pioglitazona 15 mg Ultra'),
      ('FC-09858046', '7502209858046',
       'Menflixit (Meloxicam) 7.5 mg C/14 Avitus'),
      ('FC-11786788', '7502211786788',
       'Viladol Plus (Butilhioscina/Paracetamol) 10/500 mg C/20 Loeffler'),
      ('FC-42804408', '7501342804408',
       'Metoprolol 100 mg C/20 beadvance'),
      ('FC-49021310', '7501349021310',
       'Sertralina 50 mg AMSA'),
      ('FC-49025967', '7501349025967',
       'Pregabalina 75 mg C/14 AMSA'),
      ('FC-49028487', '7501349028487',
       'Pentoxifilina 400 mg LP C/30 AMSA'),
      ('FC-63380316', '7501563380316',
       'Metronidazol 500 mg C/30 RAAM'),
      ('FC-01162365', '7502001162365',
       'Mornin (Omeprazol) 40 mg C/7 SON''S'),
      ('FC-49024151', '7501349024151',
       'Metoclopramida inyectable 10 mg/2 mL C/6 AMSA'),
      ('FC-49010048', '7501349010048',
       'Sitagliptina 100 mg C/14 AMSA'),
      ('FC-75718041', '7501075718041',
       'Ixicrol (Paroxetina) 20 mg C/10 Novag'),
      ('FC-16797376', '7502216797376',
       'Piroxicam 20 mg C/20 Ultra'),
      ('FC-04908844', '7503004908844',
       'Nistatina suspensión 100000 UI/mL 24 mL Alpharma'),
      ('FC-01164086', '7502001164086',
       'Nysmoson''s-V (Metronidazol/Nistatina/Fluocinolona) óvulos C/10 SON''S'),
      ('FC-42804385', '7501342804385',
       'Metoclopramida 10 mg C/20 beadvance'),
      ('FC-49024175', '7501349024175',
       'Pioglitazona 30 mg AMSA'),
      ('FC-08892638', '7502208892638',
       'Dirpasid (Metoclopramida) 10 mg C/20 Bruluagsa'),
      ('FC-73900436', '7501573900436',
       'Colpradin (Pravastatina) 10 mg C/30 Biomep'),
      ('FC-42803807', '7501342803807',
       'Nifedipino 30 mg LP C/30 beadvance'),
      ('FC-42803104', '7501342803104',
       'Prednisona 5 mg C/20 beadvance')
    ) as t(sku, ean, nombre)
  loop
    v_pid := null;
    select id into v_pid from public.productos
     where sku = r.sku or codigo_barras = r.ean
     limit 1;

    if v_pid is not null then
      raise notice 'YA EXISTÍA % (id %)', r.sku, v_pid;
      continue;
    end if;

    if v_review <> '' then
      execute format(
        'insert into public.productos
           (nombre, sku, codigo_barras, categoria, tipo, descripcion,
            costo, precio, stock, stock_minimo, activo, requiere_receta,
            price_needs_review)
         values ($1,$2,$3,$4,$5,$6,0,0,0,1,true,false,true)'
      ) using r.nombre, r.sku, r.ean, 'Medicamentos', 'marca',
             'Alta lote fotos IMG_5455-5720 2026-08-16 · sin costo · Ibarra corrige';
    else
      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta)
      values
        (r.nombre, r.sku, r.ean, 'Medicamentos', 'marca',
         'Alta lote fotos IMG_5455-5720 2026-08-16 · sin costo · Ibarra corrige',
         0, 0, 0, 1, true, false);
    end if;
    raise notice 'CREADO %', r.sku;
  end loop;
end
$alta$;


-- Comprobación
select sku, nombre, codigo_barras, costo, precio, stock
from public.productos
where sku in ('EQ-AMS498', 'EQ-APO142', 'EQ-AVT216', 'EQ-BIO003', 'EQ-BIO021', 'EQ-BIO058', 'EQ-BIO112', 'EQ-BIO167', 'EQ-BIO188', 'EQ-BRL072', 'EQ-CMD015', 'EQ-COD060', 'EQ-COD086', 'EQ-COL016', 'EQ-COL133', 'EQ-COL239', 'EQ-COL258', 'EQ-DEN074', 'EQ-FAC0057', 'EQ-HIS045', 'EQ-HIS081', 'EQ-LIF006', 'EQ-LIF033', 'EQ-LIF064', 'EQ-LIF153', 'EQ-LOE014', 'EQ-LOE066', 'EQ-LOE131', 'EQ-LOE135', 'EQ-MAI144', 'EQ-MAI150', 'EQ-MAI163', 'EQ-MAV162', 'EQ-MAV175', 'EQ-MAV196', 'EQ-MAV206', 'EQ-MAV239', 'EQ-MAV266', 'EQ-MAV307', 'EQ-MAV331', 'EQ-MAV392', 'EQ-MAV407', 'EQ-NOV004', 'EQ-NOV054', 'EQ-NOV137', 'EQ-NOV157', 'EQ-NOV176', 'EQ-NUC034', 'EQ-PGE046', 'EQ-PGE061', 'EQ-QUM006', 'EQ-QUM052', 'EQ-QUM068', 'EQ-SER116', 'EQ-SER117', 'EQ-SER165', 'EQ-SER183', 'EQ-SON034', 'EQ-SON089', 'EQ-SON091', 'EQ-SON096', 'EQ-SON098', 'EQ-SON104', 'EQ-SON164', 'EQ-SON175', 'EQ-STR008', 'EQ-ULT056', 'EQ-VIT055', 'EQ-VIT073', 'EQ-WER025', 'EQ-WER040', 'FC-01164413', 'FC-09747205', 'FC-42802565', 'FC-49024601', 'FC-04908677', 'FC-49025943', 'FC-16796843', 'FC-24900908', 'FC-16796737', 'FC-09858046', 'FC-11786788', 'FC-42804408', 'FC-49021310', 'FC-49025967', 'FC-49028487', 'FC-63380316', 'FC-01162365', 'FC-49024151', 'FC-49010048', 'FC-75718041', 'FC-16797376', 'FC-04908844', 'FC-01164086', 'FC-42804385', 'FC-49024175', 'FC-08892638', 'FC-73900436', 'FC-42803807', 'FC-42803104')
order by sku;
