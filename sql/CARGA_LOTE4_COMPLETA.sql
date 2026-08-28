-- ============================================================================
-- FARMA CAPITAL — Carga completa del lote 4 (fotos del 15-ago-2026)
--
-- ARCHIVO GENERADO. No lo edites a mano: se produce con
--   python3 scripts/generar_carga_lote4_completa.py
--
-- Este es el único script que hay que correr. Hace todo de corrido:
--
--   1. Guarda en public.carga_fotos_lote4 lo que se leyó de las fotos, para
--      que quede el registro de de dónde salió cada dato.
--   2. Respalda los productos que va a tocar.
--   3. Crea en public.productos todo lo que no exista, con su lote,
--      caducidad, costo y la cantidad que dice el ticket Equilibrio 440393.
--   4. A lo que ya exista sólo le completa el costo si venía en cero y le
--      agrega el lote si le faltaba. Nunca pisa un costo o precio capturado.
--   5. Recalcula el stock a partir de los lotes.
--
-- Los códigos de barras se decodificaron del código con OpenCV, no a ojo.
-- El costo, lote, caducidad y cantidad vienen del ticket de Equilibrio.
--
-- Se puede correr más de una vez: no duplica nada.
--
-- A propósito NO va dentro de una transacción: si algo falla a la mitad, lo
-- que ya se cargó se queda cargado y el error apunta al renglón exacto. Como
-- el script es idempotente, se vuelve a correr y continúa donde se quedó.
--
-- Al terminar, correr sql/pricing/004_apply_pricing_idempotente.sql para que
-- el motor de precios fije el precio de venta definitivo.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1) Lo que se leyó de las fotos
-- ---------------------------------------------------------------------------
create table if not exists public.carga_fotos_lote4 (
  ean           text primary key,
  nombre        text not null,
  presentacion  text,
  laboratorio   text,
  codigo_prov   text,
  lote          text,
  caducidad     date,
  costo         numeric(12,4),
  pmp_etiqueta  numeric(12,2),
  cantidad      integer not null default 1,
  confianza     text not null default 'alta',
  notas         text
);

truncate public.carga_fotos_lote4;

insert into public.carga_fotos_lote4
  (ean, nombre, presentacion, laboratorio, codigo_prov, lote, caducidad,
   costo, pmp_etiqueta, cantidad, confianza, notas)
values
  ('7501573902584', 'Sarox (Omeprazol) 20 mg', 'Caja con 14 cápsulas', 'Biomep', 'BIO067', '5D2618', '2028-04-01'::date, 8.42, null, 5, 'alta', '5 cajas en la foto del código'),
  ('7501573909859', 'Sarox (Omeprazol) 20 mg', 'Caja con 28 cápsulas', 'Biomep', 'BIO213', '5E2646', '2028-05-01'::date, 15.61, null, 5, 'alta', '5 cajas en la foto del código'),
  ('7503001007656', 'Wamindel (Paracetamol) gotas 100 mg/mL', 'Frasco 30 mL con gotero', 'Wandel', 'BIO087', 'LF2607', '2028-06-30'::date, 12.02, null, 1, 'alta', null),
  ('7503001007663', 'Wamindel (Paracetamol) solución infantil 3.2 g/100 mL', 'Frasco 120 mL con dosificador', 'Wandel', 'BIO068', 'LB2645', '2028-02-01'::date, 15.44, null, 2, 'alta', '2 cajas en la foto de portada'),
  ('7501825304555', 'Braxigort (Nifuroxazida) suspensión 4.4 g/100 mL', 'Frasco 90 mL con vasito', 'Degort''s Chemical', 'DEG186', '487AA', '2028-05-31'::date, 39.45, null, 1, 'alta', null),
  ('7501836006042', 'Virindrez Adulto (Oximetazolina) 0.050%', 'Frasco atomizador 20 mL', 'Liferpal MD', 'LIF160', '26D035', '2028-04-30'::date, 23.85, null, 2, 'alta', null),
  ('7501836006028', 'Virindrez Infantil (Oximetazolina) 0.025%', 'Frasco atomizador 20 mL', 'Liferpal MD', 'LIF161', '26C079', '2028-04-30'::date, 20.70, null, 1, 'alta', null),
  ('7503014377074', 'Playboy Playpack mixtos', 'Blíster con 3 piezas', 'Playboy', 'PBY004', '1991025', '2030-09-30'::date, 30.83, null, 1, 'alta', 'El lote de la foto coincide con el del ticket'),
  ('7503004908714', 'Miconazol crema 2%', 'Tubo 20 g', 'Alpharma', 'ALP0520', '2512183', '2027-12-01'::date, 10.87, null, 1, 'alta', null),
  ('7506624901059', 'beadvance Senósidos A-B 8.6 mg', 'Caja con 20 tabletas', 'Novag Infancia', 'BEA483', '540346', '2028-03-01'::date, 11.14, null, 2, 'alta', 'El mismo EAN aparece en IMG_5202'),
  ('7501075723137', 'Novakosid Senósidos A-B 8.6 mg', 'Caja con 20 tabletas', 'Novag', 'NOV136', '540266', '2028-05-01'::date, 13.93, null, 2, 'alta', 'Duplicados: IMG_5238 e IMG_5206'),
  ('7502211788928', 'Desyn-N (Lidocaína/Hidrocortisona) 60/5 mg', 'Caja con 6 supositorios', 'Loeffler', 'LOE119', 'R2508053', '2027-08-31'::date, 31.62, null, 1, 'alta', null),
  ('7503008344150', 'Prugnex Senósidos A-B 12 mg + ciruela 50 mg', 'Caja con 30 cápsulas', 'Progela', 'PGE040', 'T0885', '2027-10-16'::date, 37.07, null, 1, 'alta', null),
  ('7503003738879', 'Rosel-T 300/50/3 mg', 'Caja con 15 tabletas', 'Wermar', 'WER015', '251070', '2028-01-01'::date, 21.26, null, 2, 'alta', 'El mismo EAN aparece en IMG_5203'),
  ('7502240450230', 'Rosel solución infantil 0.5/0.02/3 g', 'Frasco 60 mL con vaso dosificador', 'Wermar', 'WER033', '260204', '2028-04-01'::date, 26.88, null, 2, 'alta', 'Segunda unidad fotografiada: 7E113744 + 7D6895C1'),
  ('7502211783282', 'Erbitrax (Terbinafina) crema 1%', 'Tubo 30 g', 'Loeffler', 'LOE076', 'R2602067', '2028-03-31'::date, 28.62, null, 2, 'alta', 'Segunda unidad fotografiada: 3E498024 + 088DA5DB'),
  ('7501573902966', 'Nafich (Terbinafina) crema 1%', 'Tubo 15 g', 'Biomep', 'BIO103', 'CD2603', '2028-04-01'::date, 13.06, null, 2, 'alta', '2 cajas en la foto del código'),
  ('7501836009661', 'Dualgos (Paracetamol/Ibuprofeno) 325/200 mg', 'Caja con 20 tabletas', 'Liferpal MD', 'LIF147', '25J081', '2027-11-30'::date, 29.02, null, 3, 'alta', null),
  ('0780083142308', 'Tempire (Paracetamol) gotas 100 mg/mL', 'Frasco 30 mL con pipeta', 'Collins', 'COL090', '26140833', '2029-04-06'::date, 20.00, null, 1, 'alta', 'UPC-A de 12 dígitos, guardado como EAN-13 con cero al frente'),
  ('7502001165045', 'Dolzycam (Piroxicam) gel 0.5%', 'Tubo 60 g', 'Química Son''s', 'SON044', '26010268', '2028-01-01'::date, 24.81, null, 1, 'alta', null),
  ('7503008344303', 'Ladexgel 300/2/10 mg', 'Caja con 12 cápsulas', 'Progela', 'PGE018', 'U0150', '2028-01-08'::date, 20.55, null, 2, 'alta', '2 cajas en la foto del código'),
  ('7502001165953', 'Rexurdir (Nifuroxazida) 400 mg', 'Caja con 16 cápsulas', 'Química Son''s', 'SON226', '26051290', '2028-05-01'::date, 29.92, null, 2, 'alta', 'Portada adicional: IMG_5198'),
  ('7501825300366', 'Espabion (Trimebutina) 20 mg/mL gotas', 'Frasco 30 mL con gotero', 'Degort''s Chemical', 'DEG030', '449AA', '2029-05-31'::date, 25.67, null, 1, 'alta', null),
  ('7502009745997', 'Pamedan (Dexpantenol) crema 5%', 'Tubo 30 g', 'Maver', 'MAV279', '261562', '2028-03-01'::date, 19.53, null, 1, 'alta', null),
  ('0785118752637', 'Itamol (Subsalicilato de bismuto) 262 mg', 'Caja con 24 tabletas masticables', 'Mavi / Sanfer', 'MAI080', '6C0337', '2028-03-31'::date, 34.09, null, 1, 'alta', 'UPC-A de 12 dígitos, guardado como EAN-13 con cero al frente'),
  ('7502006920021', 'Motilaxil-T (Picosulfato de sodio) 5 mg', 'Caja con 20 tabletas', 'Fármacos Continentales', 'FAC0059', 'ITF26S084', '2028-06-30'::date, 17.02, null, 1, 'alta', null),
  ('7502009745539', 'Lumboxen gel (Naproxeno/Lidocaína) 10/2 g', 'Tubo 35 g', 'Maver', 'MAV247', '256834', '2027-12-01'::date, 39.54, null, 2, 'alta', null),
  ('7501258207010', 'Oxital-C (Vitamina C) 2 g efervescente', 'Tubo con 10 comprimidos', 'Serral', 'SER141', '260140', '2028-01-26'::date, 62.48, null, 3, 'alta', null),
  ('7502009747236', 'Exaliv 325/5/2 mg', 'Caja con 24 tabletas', 'Maver', 'MAV341', '260224', '2028-05-01'::date, 19.82, null, 2, 'media', 'Emparejado por caja roja + Reg. 478M98; confirmar'),
  ('7502227427392', 'ML-PRIM (Metocarbamol/Naproxeno) 375/200 mg', 'Caja con 12 cápsulas', 'Gelpharma', 'GEP030', '260735', '2028-03-01'::date, 47.28, null, 2, 'media', 'Emparejado por laboratorio Gelpharma; 3 cajas en la foto'),
  ('7501075718676', 'Novagon polvo piña-naranja', 'Frasco 400 g', 'Novag', 'NOV098', '491066', '2030-04-01'::date, 97.10, 230.00, 1, 'alta', 'Lote impreso 491066 = lote del ticket'),
  ('7501075713770', 'Novagon polvo 49.7 g/100 g', 'Frasco 400 g', 'Novag', 'NOV017', '500546', '2030-01-01'::date, 99.10, 230.00, 1, 'alta', 'Lote impreso 500546 = lote del ticket; falta portada'),
  ('7502253601339', 'Daclafin (Subsalicilato de bismuto)', 'Frasco 120 mL', 'Columbia / Weser', 'DAC005', '26C0037', '2028-03-31'::date, 31.49, 69.00, 1, 'alta', 'Lote impreso 26C0037 = lote del ticket; falta portada'),
  ('7500435145497', 'NyQuil Z (Difenhidramina) 25 mg', 'Caja con 30 cápsulas', 'Vicks / P&G', 'PYG024', 'A00056', '2026-10-31'::date, 281.55, null, 1, 'alta', 'Caduca en oct-2026: revisar antes de publicar'),
  ('7501033956775', 'Pedialyte SR 60 mEq uva', 'Frasco 500 mL', 'Abbott', null, null, null::date, null, null, 1, 'alta', 'Sin línea en el ticket Equilibrio'),
  ('7501328979496', 'Histiacil NF jarabe infantil', 'Frasco 150 mL con vasito', 'Opella / Sanofi', null, null, null::date, null, null, 1, 'alta', 'Sin línea en el ticket Equilibrio'),
  ('7500462746612', 'Ajolotius jarabe original', 'Frasco 250 mL', 'Ajolotius', null, null, null::date, null, null, 1, 'alta', 'La misma foto muestra marca y código'),
  ('7501088579615', 'Topron (Nifuroxazida) 400 mg', 'Caja con 16 cápsulas', 'Chinoin', null, null, null::date, null, null, 1, 'media', 'Emparejado por caja azul marino + perfil antidiarreico; confirmar'),
  ('7503014377197', 'Playboy Max Sens Extra Delgados', '3 condones + 1 gratis', 'Playboy / RRT Medical', null, null, null::date, null, null, 1, 'media', 'Emparejado por empaque verde; confirmar contra PBY007/PBY008'),
  ('7500462746698', 'Ajolotius jarabe con propóleo', 'Frasco 250 mL', 'Ajolotius', null, null, null::date, null, null, 1, 'media', 'Emparejado por frasco naranja; confirmar'),
  ('7501075710465', 'Benciefedril jarabe dextrometorfano/guaifenesina', 'Frasco 120 mL', 'Novag', 'NOV101', '070115', '2027-12-01'::date, 22.74, null, 2, 'alta', 'Cierra el par que quedó abierto en la parte 1'),
  ('7502227424995', 'Difenhidramina 25 mg', 'Caja con 10 cápsulas', 'Gelpharma', 'GEP020', '260869', '2028-03-01'::date, 19.59, null, 2, 'alta', null),
  ('7501573903260', 'Bromhexina Adulto solución 160 mg/100 mL', 'Frasco 100 mL con vaso dosificador', 'Biomep', 'BIO108', 'LC2607', '2028-03-01'::date, 17.59, null, 1, 'alta', null),
  ('7501573903246', 'Bromhexina Infantil solución 80 mg/100 mL', 'Frasco 100 mL con vaso dosificador', 'Biomep', 'BIO109', 'LC2605', '2028-03-01'::date, 17.11, null, 1, 'alta', null),
  ('7501349025844', 'Telmisartán 40 mg', 'Caja con 28 tabletas', 'AMSA / PISA', 'AMS237', 'U26E105', '2028-01-01'::date, 35.10, null, 1, 'alta', 'El ticket trae dos lotes de AMS237: U25S032 y U26E105'),
  ('7502003388107', 'Vomisin (Dimenhidrinato) 50 mg', 'Caja con 20 tabletas', 'Rayere', 'RAY083', '26030', '2028-01-01'::date, 40.10, null, 1, 'alta', null),
  ('7502001166578', 'Baby Son''s pomada dexpantenol 5 g/100 g', 'Tubo 30 g', 'Química Son''s', 'SON258', '25102952', '2027-10-01'::date, 21.55, null, 1, 'alta', null),
  ('0785118753597', 'Lesaclor (Aciclovir) crema 5%', 'Tubo 5 g', 'Mavi Farmacéutica', 'MAI153', '5K1988', '2027-11-01'::date, 16.60, null, 5, 'alta', 'Segunda unidad fotografiada: 42591179 + 8F7EC3FD. UPC-A guardado como EAN-13'),
  ('0714908100099', 'Caltrón 600+D calcio 600 mg / vitamina D 125 UI', 'Frasco con 60 tabletas', 'Salud Natural', 'SAN007', '26540138', '2028-05-25'::date, 106.37, 450.00, 1, 'media', 'La etiqueta dice lote 26540038 y el ticket 26540138: difiere un dígito, confirmar cuál es'),
  ('7506386100158', 'Benvia Infantil (Dimenhidrinato) 250 mg/100 mL', 'Frasco 120 mL con vaso dosificador', 'Loeffler / Russek', 'LOE173', 'R2601738', '2028-01-31'::date, 32.38, null, 1, 'alta', null),
  ('7502006922711', 'Motilaxil gotas (Picosulfato de sodio) 7.5 mg/mL', 'Frasco gotero 30 mL', 'Fármacos Continentales', 'FAC0045', 'ITE26L147', '2028-06-30'::date, 27.53, null, 1, 'alta', null),
  ('7502006922728', 'Motilaxil solución (Picosulfato de sodio) 5 mg/5 mL', 'Frasco 120 mL con vaso dosificador', 'Fármacos Continentales', 'FAC0046', 'ITE26L157', '2028-05-31'::date, 25.04, null, 1, 'alta', null),
  ('7501590287992', 'Redbelgy (Cianocobalamina) 1000 mcg masticable', 'Frasco con 30 tabletas', 'Biofarma Natural CMD', 'CMD124', '25005840', '2027-11-25'::date, 34.69, null, 1, 'alta', null),
  ('7501573906407', 'Lozamir-V (Clotrimazol) crema 2% con 3 aplicadores', 'Tubo 20 g', 'Biomep', 'BIO149', 'CB2607', '2028-02-01'::date, 22.71, null, 3, 'alta', '3 cajas en la foto'),
  ('7501471800210', 'Floroglucinol / Trimetilfloroglucinol 80/80 mg', 'Caja con 20 cápsulas', 'Tecnofarma / Valeant', 'ATL109', '439491', '2028-04-30'::date, 152.51, null, 1, 'alta', 'El ticket lo abrevia FLOROGLU/TRIMETILFLORO'),
  ('7502227425008', 'Groobe (Dimenhidrinato) 50 mg', 'Caja con 24 cápsulas', 'Gelpharma', 'GEP053', '260729', '2028-03-01'::date, 30.31, null, 1, 'alta', null),
  ('0008400005823', 'Tobramicina / Dexametasona solución oftálmica 3-1 mg/mL', 'Frasco gotero 5 mL', 'Grin', 'INN023', 'XC00281', '2028-05-06'::date, 54.22, null, 2, 'alta', 'El ticket lo abrevia TOBR/DEXAM y coincide en 3-1 mg y 5 mL. La línea EXA040 es de 15 mL y es otro producto'),
  ('7501349020337', 'Sulindaco 200 mg', 'Caja con 20 tabletas', 'AMSA / PISA', 'AMS502', 'U26E326', '2028-01-01'::date, 47.30, null, 1, 'alta', null),
  ('7502226291475', 'Pharmafil LP (Teofilina) 100 mg liberación prolongada', 'Caja con 20 tabletas', 'Alpharma', 'ALP0192', '2512917', '2027-12-01'::date, 36.02, null, 1, 'alta', null),
  ('0780083144807', 'Fazolin (Nafazolina) solución oftálmica 1 mg/mL', 'Frasco gotero 15 mL', 'Collins', 'COL174', '26340537', '2028-04-29'::date, 23.75, null, 2, 'alta', 'UPC-A guardado como EAN-13'),
  ('7501836000828', 'Argental (Sulfadiazina de plata) crema 1%', 'Tubo 28 g', 'Liferpal MD', 'LIF048', '26A127', '2028-03-31'::date, 35.50, null, 2, 'alta', null),
  ('7501547521025', 'Hemoger (Sulfato ferroso) 300 mg', 'Frasco con 50 grageas', 'Streger', 'STR009', '5Z02DR', '2030-03-01'::date, 56.30, 300.00, 1, 'alta', 'Etiqueta: cad. mar-2030 y PMP $300.00'),
  ('7501109790739', 'Normex leche de magnesia 8.5 g/100 mL', 'Frasco 60 mL', 'Quifa', 'QUI016', '26B098', '2028-01-31'::date, 14.06, 55.44, 1, 'media', 'Etiqueta lote 26B128 vs ticket 26B098: revisar'),
  ('7501109790029', 'Normex leche de magnesia 8.5 g/100 mL', 'Frasco 180 mL', 'Quifa', 'QUI017', '25M088', '2027-11-30'::date, 26.67, 103.80, 1, 'alta', 'Lote confirmado (el ticket lo trae como 25M0BB, error de lectura)'),
  ('7501109760541', 'Normex leche de magnesia 8.5 g/100 mL', 'Frasco 360 mL', 'Quifa', 'QUI018', '26B099', '2028-01-31'::date, 41.82, 165.00, 1, 'alta', 'Lote confirmado'),
  ('7501075710113', 'Alu-Mag suspensión hidróxido de aluminio/magnesio 3.70/4.00 g', 'Frasco 240 mL con vaso dosificador', 'Novag', 'NOV049', '020036', '2028-04-01'::date, 23.77, null, 2, 'alta', null),
  ('7502001165298', 'Exhantil suspensión antiácido/antiflatulento', 'Frasco 320 mL sabor menta-limón', 'Química Son''s', 'SON231', '26061512', '2029-06-30'::date, 33.00, 219.00, 2, 'alta', 'Lote confirmado'),
  ('7502009747779', 'Culminax Adulto (Carbocisteína) 375 mg/5 mL', 'Frasco 150 mL con vaso dosificador', 'Maver', 'MAV363', '261984', '2028-04-01'::date, 50.05, 255.00, 1, 'alta', 'Lote confirmado'),
  ('7502009747168', 'Fedrimin (Teofilina/Ambroxol) 0.700-0.150 g/100 mL', 'Frasco 150 mL con vaso dosificador', 'Maver', 'MAV323', '263034', '2028-05-31'::date, 34.25, 171.00, 1, 'alta', 'Lote confirmado'),
  ('7501075717914', 'Nineka suspensión neomicina/caolín/pectina', 'Frasco 75 mL con vaso dosificador', 'Novag', 'NOV090', '460056', '2028-04-01'::date, 23.45, 80.00, 2, 'alta', 'Lote confirmado. Portada adicional: IMG_5257'),
  ('7501825304142', 'Hidrigort (Difenhidramina) 50 mg', 'Caja con 8 tabletas', 'Degort''s Chemical', 'DEG175', '477AA', '2028-05-31'::date, 10.11, null, 2, 'alta', '2 cajas en la foto'),
  ('7502009740268', 'Cobadex Adulto (Ambroxol/Dextrometorfano) 225-225 mg/100 mL', 'Frasco 120 mL con vaso dosificador', 'Maver', 'MAV015', '260606', '2028-01-01'::date, 19.31, 123.00, 1, 'alta', 'Lote confirmado'),
  ('7502009745393', 'Siracux Adulto (Oxeladina/Ambroxol) 0.200-0.225 g/100 mL', 'Frasco 120 mL con vaso dosificador', 'Maver', 'MAV233', '263295', '2028-05-31'::date, 42.66, 213.00, 1, 'alta', 'Lote confirmado'),
  ('7502009740657', 'Laritol EX (Loratadina/Ambroxol) 100-600 mg/100 mL', 'Frasco 120 mL con vaso dosificador', 'Maver', 'MAV042', '252141', '2028-05-01'::date, 19.11, 123.00, 2, 'alta', 'Lote confirmado'),
  ('7501075723830', 'Atroxolam (Teofilina/Ambroxol) 7.0-1.5 mg/mL jarabe', 'Frasco 150 mL con vaso dosificador', 'Novag', 'NOV148', '890066', '2028-01-30'::date, 29.77, null, 1, 'alta', null),
  ('7501825300373', 'Espabion (Trimebutina) suspensión 2 g/100 mL', 'Frasco 100 mL', 'Degort''s Chemical', 'DEG029', '414AA', '2029-05-31'::date, 44.45, null, 1, 'alta', null),
  ('7502001163232', 'Ridin Pediátrica jarabe dextrometorfano/guaifenesina/clorfenamina', 'Frasco 120 mL con vaso dosificador', 'Química Son''s', 'SON113', '26030795', '2028-03-01'::date, 26.62, null, 2, 'media', 'La foto del código no muestra el nombre; emparejado por color y logotipo'),
  ('7502208895042', 'Bruluaquil AAS/paracetamol/cafeína 250/250/65 mg', 'Frasco con 24 tabletas', 'Bruluagsa', 'BRL075', '5101455', '2027-10-23'::date, 42.35, null, 1, 'media', 'La foto del código no muestra el nombre; emparejado por Bruluagsa y posición'),
  ('7502211780359', 'Aflusil (Ibuprofeno) suspensión 2 g/100 mL', 'Frasco 120 mL con vaso dosificador', 'Loeffler / Russek', 'LOE001', 'R2602932', '2028-02-28'::date, 19.60, null, 2, 'alta', 'Sabor maracuyá'),
  ('7502211788690', 'Diotexona (Dimeticona) 10 g/100 mL pediátrico', 'Frasco gotero 30 mL', 'Loeffler / Russek', 'LOE123', 'R2511440', '2027-11-01'::date, 38.87, null, 1, 'alta', null),
  ('7502274792047', 'Voldratol Electrolitos sabor natural, sobre 27.9 g', 'Caja con 25 sobres', 'Solfran', 'SOF073', '60264', '2028-02-10'::date, 125.16, 825.00, 1, 'alta', 'Lote confirmado. El ticket lo escribe VOLDRATIL'),
  ('7502274792061', 'Voldratol Electrolitos sabor uva, sobre 28.14 g', 'Caja con 25 sobres', 'Solfran', 'SOF056', '51231', '2027-06-26'::date, 111.75, 825.00, 1, 'alta', 'Lote confirmado. El ticket lo escribe VOLDRATIL'),
  ('7501537103354', 'Brunadol Infantil paracetamol/naproxeno 100-125 mg/5 mL', 'Frasco 100 mL con cucharita', 'Bruluart', 'BRU136', '2605454', '2028-05-14'::date, 30.57, null, 1, 'alta', null),
  ('0780083141929', 'Dolprin (Ibuprofeno) suspensión 2 g/100 mL', 'Frasco 120 mL con dosificador', 'Collins', 'COL039', '26140862', '2028-04-16'::date, 27.52, null, 2, 'alta', 'UPC-A guardado como EAN-13'),
  ('7501836003621', 'Precicol (Hioscina/Paracetamol) gotas 2-100 mg/mL', 'Frasco gotero 20 mL', 'Liferpal MD', 'LIF162', '26C062', '2028-03-31'::date, 37.22, null, 1, 'alta', 'Cierra un pendiente de la parte 1'),
  ('7501573906469', 'Biobend (Bencidamina) solución 0.15 g/100 mL', 'Frasco 360 mL', 'Biomep', 'BIO146', 'LD2619', '2028-04-01'::date, 39.49, null, 2, 'alta', 'Enjuague bucal'),
  ('7501482200016', 'Omeprazol Aktyzar 20 mg', 'Frasco con 120 cápsulas', 'Solfran', 'SOF054', '61168', '2028-06-05'::date, 46.79, 279.00, 1, 'alta', 'Lote confirmado. Cierra un pendiente de la parte 1'),
  ('7502009745584', 'Oppelver (Lactulosa) 10 g/15 mL', 'Frasco 125 mL con vaso dosificador', 'Maver', 'MAV245', '261962', '2028-03-01'::date, 49.25, null, 1, 'alta', 'Cierra un pendiente de la parte 1'),
  ('7502009749209', 'Lumboxen parche (capsaicina/alcanfor/mentol/salicilato)', 'Bolsa con 1 parche', 'Maver', 'MAV400', '20251225', '2028-12-31'::date, 14.37, 35.00, 1, 'alta', 'Lote confirmado. Cierra un pendiente de la parte 1'),
  ('7503000422511', 'Bactiver suspensión sulfametoxazol/trimetoprima 200-40 mg/5 mL', 'Frasco 120 mL con vaso dosificador', 'Maver', 'MAV003', '262631', '2028-05-01'::date, 21.28, 111.00, 1, 'alta', 'Lote confirmado: aclara a qué producto pertenece el lote MAV003'),
  ('7502009745560', 'Bioxover (Dropropizina) jarabe 3 mg/mL', 'Frasco 120 mL con vaso dosificador', 'Maver', 'MAV238', '255469', '2027-10-01'::date, 28.84, 156.00, 2, 'alta', 'Lote confirmado'),
  ('0780083144302', 'Collifrin Adulto (Oximetazolina) 0.05% extra humectante', 'Frasco 20 mL', 'Collins', 'COL145', '26140881', '2028-04-06'::date, 33.61, null, 2, 'alta', 'UPC-A guardado como EAN-13'),
  ('0714706910906', 'Broncolin Bicoestol pastillas eucalipto/gordolobo/saúco', 'Caja con 16 pastillas de 2.5 g', 'Broncolin', null, null, null::date, null, null, 1, 'alta', 'Remedio herbolario 003RH2016. Sin línea en el ticket'),
  ('7502227871416', 'Raamfen (Difenidol) 25 mg', 'Caja con 30 tabletas', 'Laboratorio Raam', 'RAM046', 'RR184', '2028-03-31'::date, 15.49, null, 3, 'alta', '3 cajas en la foto de portada'),
  ('7502227875568', 'Desrotan (Fexofenadina) 180 mg', 'Caja con 10 tabletas', 'Laboratorio Raam', 'RAM100', 'RD085', '2028-03-31'::date, 47.31, null, 1, 'alta', null),
  ('7502227872123', 'Raamcinet (Cetirizina) 10 mg', 'Caja con 10 tabletas', 'Laboratorio Raam', 'RAM054', '7220526', '2028-03-31'::date, 19.65, null, 6, 'alta', '6 cajas en la foto de portada'),
  ('7503014377180', 'Playboy Max Sens Extra Sensible', '3 condones + 1 gratis', 'Playboy / RRT Medical', null, null, null::date, null, null, 1, 'media', 'El ticket sólo trae PBY007 Tropicana Mix ($23.17) y PBY008 Passion Mix ($23.21), que son otras variantes: confirmar cuál corresponde'),
  ('7501032911454', 'OFF! Extra Duración aerosol repelente (DEET 25%)', 'Lata 170 g', 'SC Johnson', null, '1208274', null::date, null, null, 1, 'alta', 'Ya existía un patch de alta previo con este EAN'),
  ('7506452400267', 'Ajolotius jarabe Elderberry / mora azul', 'Frasco 250 mL', 'Ajolotius', null, null, null::date, null, null, 1, 'alta', 'Suplemento alimenticio, sin línea en el ticket'),
  ('7500462746643', 'Ajolotius caramelos menta-eucalipto (con azúcar)', 'Caja con 10 caramelos de 2.5 g (25 g)', 'Ajolotius', null, null, null::date, null, null, 1, 'alta', 'Lleva sellos de exceso de calorías y azúcares'),
  ('7506452400038', 'Ajolotius caramelos menta-eucalipto sin azúcar', 'Caja con 10 caramelos de 2.2 g (22 g)', 'Ajolotius', null, null, null::date, null, null, 1, 'alta', 'Versión con isomalt'),
  ('0759684273094', 'Hisopos de algodón Jaloma, tarro reutilizable', 'Tarro con hisopos', 'Jaloma', null, null, null::date, null, null, 1, 'media', 'Confirmar si es el mismo artículo que los hisopos KIUTS de IMG_5213'),
  ('7506306234062', 'Sedal Hidratación (Unilever)', 'Botella con bomba', 'Unilever', null, '64915004', '2028-11-30'::date, null, null, 1, 'media', 'Producto de cuidado personal; falta la cara frontal con el volumen');

-- ---------------------------------------------------------------------------
-- 2) Respaldo de lo que este script podría modificar
-- ---------------------------------------------------------------------------
create table if not exists public.productos_backup_lote4_20260815 (
  backup_at     timestamptz not null default now(),
  producto_id   bigint primary key,
  sku           text,
  nombre        text,
  codigo_barras text,
  costo         numeric(10,2),
  precio        numeric(10,2),
  stock         integer
);

insert into public.productos_backup_lote4_20260815
  (producto_id, sku, nombre, codigo_barras, costo, precio, stock)
select p.id, p.sku, p.nombre, p.codigo_barras, p.costo, p.precio, p.stock
from public.productos p
join public.carga_fotos_lote4 c on c.ean = p.codigo_barras
on conflict (producto_id) do nothing;

-- ---------------------------------------------------------------------------
-- 3) Alta y actualización
-- ---------------------------------------------------------------------------
do $carga$
declare
  r             record;
  v_pid         bigint;
  v_sku         text;
  v_sufijo      integer;
  v_categoria   text;
  v_tipo        text;
  v_forma       text;
  v_pa          text;
  v_precio      numeric;
  v_activo      boolean;
  v_set         text;
  v_cols        text;
  v_vals        text;
  n_altas       integer := 0;
  n_costos      integer := 0;
  n_lotes       integer := 0;
  n_sin_precio  integer := 0;
begin
  for r in select * from public.carga_fotos_lote4 order by nombre loop
    -- Si algo truena, este aviso dice en qué producto fue.
    raise debug 'procesando % (%)', r.nombre, r.ean;

    -- --- Clasificación, para que el motor de precios sepa qué recargo usar ---
    v_categoria := case
      when r.nombre ~* '(playboy|jaloma|hisopo|sedal|vaselina|off!|barra labial|ricitos)' then 'Higiene'
      when r.nombre ~* '(voldratol|pedialyte|electrolito|suero)'                          then 'Hidratación'
      when r.nombre ~* '(ajolotius|omega|caltrón|caltron|redbelgy|vitamina|hemoger)'      then 'Suplemento'
      else 'Medicamentos'
    end;

    v_tipo := case when v_categoria = 'Medicamentos' then 'marca' else 'otro' end;

    v_forma := case
      when coalesce(r.presentacion, r.nombre) ~* 'crema'                       then 'Crema'
      when coalesce(r.presentacion, r.nombre) ~* '(ungüento|unguento|pomada)'  then 'Ungüento'
      when coalesce(r.presentacion, r.nombre) ~* 'gel'                         then 'Gel'
      when coalesce(r.presentacion, r.nombre) ~* 'gotas'                       then 'Gotas'
      when coalesce(r.presentacion, r.nombre) ~* 'jarabe'                      then 'Jarabe'
      when coalesce(r.presentacion, r.nombre) ~* '(suspensión|suspension)'     then 'Suspensión'
      when coalesce(r.presentacion, r.nombre) ~* '(solución|solucion)'         then 'Solución'
      when coalesce(r.presentacion, r.nombre) ~* '(cápsula|capsula)'           then 'Cápsula'
      when coalesce(r.presentacion, r.nombre) ~* '(tableta|gragea|comprimido)' then 'Tableta'
      when coalesce(r.presentacion, r.nombre) ~* 'supositorio'                 then 'Supositorio'
      when coalesce(r.presentacion, r.nombre) ~* '(aerosol|atomizador|spray)'  then 'Aerosol'
      when coalesce(r.presentacion, r.nombre) ~* '(polvo|sobre)'               then 'Polvo'
      when coalesce(r.presentacion, r.nombre) ~* 'parche'                      then 'Parche'
      when coalesce(r.presentacion, r.nombre) ~* 'condón|condon|preservativo'  then 'Condón'
      else null
    end;

    -- El principio activo casi siempre viene entre paréntesis en el nombre:
    -- "Sarox (Omeprazol) 20 mg".
    v_pa := nullif(btrim(substring(r.nombre from '\(([^)]+)\)')), '');

    -- --- Precio provisional ---
    -- La columna precio no acepta nulos. Si hay costo, se pone ceil(costo*1.6),
    -- que es justo el valor que el motor de precios reconoce como "todavía no
    -- lo ha tocado nadie a mano" y luego reemplaza por el de la regla.
    -- Si no hay costo no se puede calcular nada: entra en 0 y desactivado,
    -- para que aparezca en el inventario pero no se pueda vender por error.
    if coalesce(r.costo, 0) > 0 then
      v_precio := ceil(r.costo * 1.6);
      v_activo := true;
    else
      v_precio := 0;
      v_activo := false;
      n_sin_precio := n_sin_precio + 1;
    end if;

    -- --- ¿Ya existe con ese código de barras? ---
    select p.id into v_pid
    from public.productos p
    where p.codigo_barras = r.ean
    limit 1;

    if v_pid is not null then
      update public.productos
         set costo = r.costo
       where id = v_pid
         and r.costo is not null
         and coalesce(costo, 0) = 0;
      if found then
        n_costos := n_costos + 1;
      end if;
    else
      -- SKU derivado del código de barras, con sufijo si ya estuviera ocupado.
      v_sku := 'FC-' || right(r.ean, 8);
      v_sufijo := 0;
      while exists (select 1 from public.productos where sku = v_sku) loop
        v_sufijo := v_sufijo + 1;
        v_sku := 'FC-' || right(r.ean, 8) || '-' || v_sufijo;
      end loop;

      insert into public.productos
        (nombre, sku, codigo_barras, categoria, tipo, descripcion,
         costo, precio, stock, stock_minimo, activo, requiere_receta)
      values
        (r.nombre, v_sku, r.ean, v_categoria, v_tipo,
         concat_ws(' · ', r.nombre, r.presentacion, r.laboratorio, 'EAN ' || r.ean),
         r.costo, v_precio, 0, 1, v_activo, false)
      returning id into v_pid;

      n_altas := n_altas + 1;
    end if;

    -- --- Columnas que no todos los ambientes tienen: se arman en dinámico ---
    v_set := 'marca = coalesce(marca, ' || quote_nullable(r.laboratorio) || ')';
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'presentacion') then
      v_set := v_set || ', presentacion = coalesce(presentacion, '
                     || quote_nullable(r.presentacion) || ')';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'forma_farmaceutica') then
      v_set := v_set || ', forma_farmaceutica = coalesce(forma_farmaceutica, '
                     || quote_nullable(v_forma) || ')';
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'principio_activo') then
      v_set := v_set || ', principio_activo = coalesce(principio_activo, '
                     || quote_nullable(v_pa) || ')';
    end if;
    if r.codigo_prov is not null
       and exists (select 1 from information_schema.columns
                   where table_schema = 'public' and table_name = 'productos'
                     and column_name = 'proveedor') then
      v_set := v_set || ', proveedor = ' || quote_literal('EQUILIBRIO FARMACEUTICO');
    end if;
    if exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'productos'
                 and column_name = 'price_needs_review') then
      -- Sin costo, o emparejamiento de fotos que quedó en duda: que el motor
      -- de precios no le ponga precio solo.
      v_set := v_set || ', price_needs_review = '
                     || case when coalesce(r.costo, 0) = 0 or r.confianza = 'media'
                             then 'true' else 'price_needs_review' end;
    end if;

    execute format('update public.productos set %s where id = %s', v_set, v_pid);

    -- --- Lote ---
    -- La tabla lotes no es igual en todos los ambientes (cantidad_inicial y
    -- activo existen en unos y en otros no), así que el insert se arma con las
    -- columnas que realmente estén.
    if r.lote is not null and not exists (
      select 1 from public.lotes l
      where l.producto_id = v_pid and l.numero_lote = r.lote
    ) then
      v_cols := 'producto_id, numero_lote, cantidad_actual, fecha_caducidad, costo_unitario';
      v_vals := v_pid || ', ' || quote_literal(r.lote) || ', '
                || greatest(r.cantidad, 1) || ', '
                || coalesce(quote_literal(r.caducidad::text) || '::date', 'null') || ', '
                || coalesce(r.costo::text, 'null');

      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'cantidad_inicial') then
        v_cols := v_cols || ', cantidad_inicial';
        v_vals := v_vals || ', ' || greatest(r.cantidad, 1);
      end if;
      if exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lotes'
                   and column_name = 'activo') then
        v_cols := v_cols || ', activo';
        v_vals := v_vals || ', true';
      end if;

      execute format('insert into public.lotes (%s) values (%s)', v_cols, v_vals);
      n_lotes := n_lotes + 1;
    end if;

  end loop;

  raise notice 'Productos nuevos creados: %', n_altas;
  raise notice 'Costos completados en productos que ya existían: %', n_costos;
  raise notice 'Lotes registrados: %', n_lotes;
  raise notice 'Sin costo en el ticket, quedaron desactivados: %', n_sin_precio;
end
$carga$;

-- ---------------------------------------------------------------------------
-- 4) Reactivar lo que se apagó por no tener costo y ahora sí lo tiene
--
-- En la primera versión de este script varios productos entraron sin costo
-- porque su línea del ticket no se había encontrado, y se quedaron apagados.
-- Al recuperar esos costos hay que volver a prenderlos.
-- ---------------------------------------------------------------------------
update public.productos p
set
  activo = true,
  precio = case when coalesce(p.precio, 0) = 0
                then ceil(p.costo * 1.6) else p.precio end
from public.carga_fotos_lote4 c
where p.codigo_barras = c.ean
  and p.activo is false
  and coalesce(p.costo, 0) > 0;

-- ---------------------------------------------------------------------------
-- 5) Stock = suma de los lotes activos
-- ---------------------------------------------------------------------------
update public.productos p
set stock = coalesce(t.total, 0)
from (
  select l.producto_id, sum(l.cantidad_actual) as total
  from public.lotes l
  where coalesce(l.activo, true)
  group by l.producto_id
) t
where p.id = t.producto_id
  and p.codigo_barras in (select ean from public.carga_fotos_lote4)
  and p.stock is distinct from coalesce(t.total, 0);

-- ---------------------------------------------------------------------------
-- 6) Verificación
-- ---------------------------------------------------------------------------
select
  count(*)                                            as renglones_del_lote,
  count(p.id)                                         as en_inventario,
  count(*) filter (where p.id is null)                as no_se_crearon,
  count(*) filter (where coalesce(p.costo, 0) > 0)    as con_costo,
  count(*) filter (where p.activo is false)           as desactivados_sin_costo
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean;

-- Detalle producto por producto
select
  c.ean,
  p.sku,
  p.nombre,
  p.costo,
  p.precio,
  p.stock,
  p.activo,
  l.numero_lote,
  l.fecha_caducidad
from public.carga_fotos_lote4 c
left join public.productos p on p.codigo_barras = c.ean
left join public.lotes l     on l.producto_id = p.id and l.numero_lote = c.lote
order by p.activo nulls first, p.nombre;

-- Los que quedaron sin costo: captura el costo aquí y vuelve a activarlos
select
  c.ean,
  c.nombre,
  c.laboratorio,
  c.pmp_etiqueta as precio_impreso_en_el_empaque,
  'update public.productos set costo = ?, activo = true where codigo_barras = '''
    || c.ean || ''';' as sql_para_completar
from public.carga_fotos_lote4 c
where coalesce(c.costo, 0) = 0
order by c.nombre;
