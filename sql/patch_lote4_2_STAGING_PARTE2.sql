-- ============================================================================
-- Lote 4 — STAGING PARTE 2 (fotos IMG_5241–IMG_5302 y las 93 UUID de 20:20:30
-- a 20:32:12 del 15-ago-2026)
--
-- Requiere haber corrido antes patch_lote4_1_STAGING.sql, que crea la tabla.
-- Este script NO modifica public.productos ni public.lotes.
--
-- Los EAN se decodificaron del código de barras con OpenCV. El costo, lote y
-- caducidad vienen del ticket Equilibrio 440393.
--
-- En las filas marcadas "lote confirmado" el número de lote impreso en la
-- etiqueta coincide dígito por dígito con el del ticket: ahí el cruce es
-- seguro, no una coincidencia de nombre.
-- ============================================================================

insert into public.staging_fotos_lote4
  (ean, nombre, presentacion, laboratorio, codigo_prov, lote, caducidad, costo,
   pmp_etiqueta, foto_portada, foto_codigo, confianza, notas)
values
  -- ---- Serie UUID (pares portada + código) ----
  ('7501075710465','Benciefedril jarabe dextrometorfano/guaifenesina','Frasco 120 mL','Novag','NOV101','070115','2027-12-01',22.74,null,'9C7D238A','CDD1272E','alta','Cierra el par que quedó abierto en la parte 1'),
  ('7502227424995','Difenhidramina 25 mg','Caja con 10 cápsulas','Gelpharma','GEP020','260869','2028-03-01',19.59,null,'401A905E','06D85DFF','alta',null),
  ('7501573903260','Bromhexina Adulto solución 160 mg/100 mL','Frasco 100 mL con vaso dosificador','Biomep','BIO108','LC2607','2028-03-01',17.59,null,'4412F8EA','81ABBD32','alta',null),
  ('7501573903246','Bromhexina Infantil solución 80 mg/100 mL','Frasco 100 mL con vaso dosificador','Biomep','BIO109','LC2605','2028-03-01',17.11,null,'522703BC','9BED9AE8','alta',null),
  ('7501349025844','Telmisartán 40 mg','Caja con 28 tabletas','AMSA / PISA','AMS237','U26E105','2028-01-01',35.10,null,'52F9B729','98B66F93','alta','El ticket trae dos lotes de AMS237: U25S032 y U26E105'),
  ('7502003388107','Vomisin (Dimenhidrinato) 50 mg','Caja con 20 tabletas','Rayere','RAY083','26030','2028-01-01',40.10,null,'F35DDDCA','627BF2C7','alta',null),
  ('7502001166578','Baby Son''s pomada dexpantenol 5 g/100 g','Tubo 30 g','Química Son''s','SON258','25102952','2027-10-01',21.55,null,'436BF1EA','668DCF88','alta',null),
  ('0785118753597','Lesaclor (Aciclovir) crema 5%','Tubo 5 g','Mavi Farmacéutica','MAI153','5K1988','2027-11-01',16.60,null,'294BEDE2','1ACDB36B','alta','Segunda unidad fotografiada: 42591179 + 8F7EC3FD. UPC-A guardado como EAN-13'),
  ('0714908100099','Caltrón 600+D calcio 600 mg / vitamina D 125 UI','Frasco con 60 tabletas','Salud Natural','SAN007','26540138','2028-05-25',106.37,450.00,'0993059A','47D8DB85','media','La etiqueta dice lote 26540038 y el ticket 26540138: difiere un dígito, confirmar cuál es'),
  ('7506386100158','Benvia Infantil (Dimenhidrinato) 250 mg/100 mL','Frasco 120 mL con vaso dosificador','Loeffler / Russek','LOE173','R2601738','2028-01-31',32.38,null,'4F6C4C63','2E18320D','alta',null),
  ('7502006922711','Motilaxil gotas (Picosulfato de sodio) 7.5 mg/mL','Frasco gotero 30 mL','Fármacos Continentales','FAC0045','ITE26L147','2028-06-30',27.53,null,'C248D6C5','DFC3C49E','alta',null),
  ('7502006922728','Motilaxil solución (Picosulfato de sodio) 5 mg/5 mL','Frasco 120 mL con vaso dosificador','Fármacos Continentales','FAC0046','ITE26L157','2028-05-31',25.04,null,'E8D6EA73','35FA395C','alta',null),
  ('7501590287992','Redbelgy (Cianocobalamina) 1000 mcg masticable','Frasco con 30 tabletas','Biofarma Natural CMD','CMD124','25005840','2027-11-25',34.69,null,'94D9F3D4','15F224E4','alta',null),
  ('7501573906407','Lozamir-V (Clotrimazol) crema 2% con 3 aplicadores','Tubo 20 g','Biomep','BIO149','CB2607','2028-02-01',22.71,null,'9FAB8D3D','A992740C','alta','3 cajas en la foto'),
  ('7501471800210','Floroglucinol / Trimetilfloroglucinol 80/80 mg','Caja con 20 cápsulas','Tecnofarma / Valeant','ATL109','439491','2028-04-30',152.51,null,'0534F1DE','AE52B73F','alta','El ticket lo abrevia FLOROGLU/TRIMETILFLORO'),
  ('7502227425008','Groobe (Dimenhidrinato) 50 mg','Caja con 24 cápsulas','Gelpharma','GEP053','260729','2028-03-01',30.31,null,'43E7D2C8','11130E61','alta',null),
  ('0008400005823','Tobramicina / Dexametasona solución oftálmica 3-1 mg/mL','Frasco gotero 5 mL','Grin','INN023','XC00281','2028-05-06',54.22,null,'589E894B','22DC6FC8','alta','El ticket lo abrevia TOBR/DEXAM y coincide en 3-1 mg y 5 mL. La línea EXA040 es de 15 mL y es otro producto'),
  ('7501349020337','Sulindaco 200 mg','Caja con 20 tabletas','AMSA / PISA','AMS502','U26E326','2028-01-01',47.30,null,'9FA97D8F','3B9257DD','alta',null),
  ('7502226291475','Pharmafil LP (Teofilina) 100 mg liberación prolongada','Caja con 20 tabletas','Alpharma','ALP0192','2512917','2027-12-01',36.02,null,'10A4C395','6E52855C','alta',null),
  ('0780083144807','Fazolin (Nafazolina) solución oftálmica 1 mg/mL','Frasco gotero 15 mL','Collins','COL174','26340537','2028-04-29',23.75,null,'8E129D8C','DCA7B257','alta','UPC-A guardado como EAN-13'),
  ('7501836000828','Argental (Sulfadiazina de plata) crema 1%','Tubo 28 g','Liferpal MD','LIF048','26A127','2028-03-31',35.50,null,'992554F9','ED39979E','alta',null),
  ('7501547521025','Hemoger (Sulfato ferroso) 300 mg','Frasco con 50 grageas','Streger','STR009','5Z02DR','2030-03-01',56.30,300.00,'38A81B4D','2543D72C','alta','Etiqueta: cad. mar-2030 y PMP $300.00'),
  ('7501109790739','Normex leche de magnesia 8.5 g/100 mL','Frasco 60 mL','Quifa','QUI016','26B098','2028-01-31',14.06,55.44,'81FE9198','6FC817C0','media','Etiqueta lote 26B128 vs ticket 26B098: revisar'),
  ('7501109790029','Normex leche de magnesia 8.5 g/100 mL','Frasco 180 mL','Quifa','QUI017','25M088','2027-11-30',26.67,103.80,'8D6AC543','B7B41862','alta','Lote confirmado (el ticket lo trae como 25M0BB, error de lectura)'),
  ('7501109760541','Normex leche de magnesia 8.5 g/100 mL','Frasco 360 mL','Quifa','QUI018','26B099','2028-01-31',41.82,165.00,'F31ADA4B','80B55318','alta','Lote confirmado'),
  ('7501075710113','Alu-Mag suspensión hidróxido de aluminio/magnesio 3.70/4.00 g','Frasco 240 mL con vaso dosificador','Novag','NOV049','020036','2028-04-01',23.77,null,'82A3F919','B921B7E0','alta',null),
  ('7502001165298','Exhantil suspensión antiácido/antiflatulento','Frasco 320 mL sabor menta-limón','Química Son''s','SON231','26061512','2029-06-30',33.00,219.00,'5C0CDF4A','9BD80825','alta','Lote confirmado'),
  ('7502009747779','Culminax Adulto (Carbocisteína) 375 mg/5 mL','Frasco 150 mL con vaso dosificador','Maver','MAV363','261984','2028-04-01',50.05,255.00,'79A83897','9DFBFE8A','alta','Lote confirmado'),
  ('7502009747168','Fedrimin (Teofilina/Ambroxol) 0.700-0.150 g/100 mL','Frasco 150 mL con vaso dosificador','Maver','MAV323','263034','2028-05-31',34.25,171.00,'C247B78E','510CEEA1','alta','Lote confirmado'),
  ('7501075717914','Nineka suspensión neomicina/caolín/pectina','Frasco 75 mL con vaso dosificador','Novag','NOV090','460056','2028-04-01',23.45,80.00,'B638DE44','70926535','alta','Lote confirmado. Portada adicional: IMG_5257'),
  ('7501825304142','Hidrigort (Difenhidramina) 50 mg','Caja con 8 tabletas','Degort''s Chemical','DEG175','477AA','2028-05-31',10.11,null,'22D8E67D','39C8EC15','alta','2 cajas en la foto'),
  ('7502009740268','Cobadex Adulto (Ambroxol/Dextrometorfano) 225-225 mg/100 mL','Frasco 120 mL con vaso dosificador','Maver','MAV015','260606','2028-01-01',19.31,123.00,'D5DD0E5D','4C6A4082','alta','Lote confirmado'),
  ('7502009745393','Siracux Adulto (Oxeladina/Ambroxol) 0.200-0.225 g/100 mL','Frasco 120 mL con vaso dosificador','Maver','MAV233','263295','2028-05-31',42.66,213.00,'829600CA','BB0B55D9','alta','Lote confirmado'),
  ('7502009740657','Laritol EX (Loratadina/Ambroxol) 100-600 mg/100 mL','Frasco 120 mL con vaso dosificador','Maver','MAV042','252141','2028-05-01',19.11,123.00,'26213823','DE436103','alta','Lote confirmado'),
  ('7501075723830','Atroxolam (Teofilina/Ambroxol) 7.0-1.5 mg/mL jarabe','Frasco 150 mL con vaso dosificador','Novag','NOV148','890066','2028-01-30',29.77,null,'86FC32A3','EF2AAEF8','alta',null),
  ('7501825300373','Espabion (Trimebutina) suspensión 2 g/100 mL','Frasco 100 mL','Degort''s Chemical','DEG029','414AA','2029-05-31',44.45,null,'D2E29408','94E2CB1D','alta',null),
  ('7502001163232','Ridin Pediátrica jarabe dextrometorfano/guaifenesina/clorfenamina','Frasco 120 mL con vaso dosificador','Química Son''s','SON113','26030795','2028-03-01',26.62,null,'3F49C7FF','89417B23','media','La foto del código no muestra el nombre; emparejado por color y logotipo'),
  ('7502208895042','Bruluaquil AAS/paracetamol/cafeína 250/250/65 mg','Frasco con 24 tabletas','Bruluagsa','BRL075','5101455','2027-10-23',42.35,null,'93182155','5E718441','media','La foto del código no muestra el nombre; emparejado por Bruluagsa y posición'),
  ('7502211780359','Aflusil (Ibuprofeno) suspensión 2 g/100 mL','Frasco 120 mL con vaso dosificador','Loeffler / Russek','LOE001','R2602932','2028-02-28',19.60,null,'6C3D441A','CEA23777','alta','Sabor maracuyá'),
  ('7502211788690','Diotexona (Dimeticona) 10 g/100 mL pediátrico','Frasco gotero 30 mL','Loeffler / Russek','LOE123','R2511440','2027-11-01',38.87,null,'FBC30BEB','7B01960C','alta',null),
  ('7502274792047','Voldratol Electrolitos sabor natural, sobre 27.9 g','Caja con 25 sobres','Solfran','SOF073','60264','2028-02-10',125.16,825.00,'B4101532','1BC8F2F6','alta','Lote confirmado. El ticket lo escribe VOLDRATIL'),
  ('7502274792061','Voldratol Electrolitos sabor uva, sobre 28.14 g','Caja con 25 sobres','Solfran','SOF056','51231','2027-06-26',111.75,825.00,'9C5AF07A','ADFF7903','alta','Lote confirmado. El ticket lo escribe VOLDRATIL'),
  ('7501537103354','Brunadol Infantil paracetamol/naproxeno 100-125 mg/5 mL','Frasco 100 mL con cucharita','Bruluart','BRU136','2605454','2028-05-14',30.57,null,'33D69622','02CCD46B','alta',null),
  ('0780083141929','Dolprin (Ibuprofeno) suspensión 2 g/100 mL','Frasco 120 mL con dosificador','Collins','COL039','26140862','2028-04-16',27.52,null,'A632B96D','08020DE3','alta','UPC-A guardado como EAN-13'),
  -- ---- Serie de cámara IMG_5241–IMG_5302 ----
  ('7501836003621','Precicol (Hioscina/Paracetamol) gotas 2-100 mg/mL','Frasco gotero 20 mL','Liferpal MD','LIF162','26C062','2028-03-31',37.22,null,'IMG_5219','IMG_5241','alta','Cierra un pendiente de la parte 1'),
  ('7501573906469','Biobend (Bencidamina) solución 0.15 g/100 mL','Frasco 360 mL','Biomep','BIO146','LD2619','2028-04-01',39.49,null,'IMG_5301','IMG_5243','alta','Enjuague bucal'),
  ('7501482200016','Omeprazol Aktyzar 20 mg','Frasco con 120 cápsulas','Solfran','SOF054','61168','2028-06-05',46.79,279.00,'IMG_5211','IMG_5277','alta','Lote confirmado. Cierra un pendiente de la parte 1'),
  ('7502009745584','Oppelver (Lactulosa) 10 g/15 mL','Frasco 125 mL con vaso dosificador','Maver','MAV245','261962','2028-03-01',49.25,null,'IMG_5195','IMG_5283','alta','Cierra un pendiente de la parte 1'),
  ('7502009749209','Lumboxen parche (capsaicina/alcanfor/mentol/salicilato)','Bolsa con 1 parche','Maver','MAV400','20251225','2028-12-31',14.37,35.00,'IMG_5227','IMG_5268','alta','Lote confirmado. Cierra un pendiente de la parte 1'),
  ('7503000422511','Bactiver suspensión sulfametoxazol/trimetoprima 200-40 mg/5 mL','Frasco 120 mL con vaso dosificador','Maver','MAV003','262631','2028-05-01',21.28,111.00,'IMG_5261','IMG_5271','alta','Lote confirmado: aclara a qué producto pertenece el lote MAV003'),
  ('7502009745560','Bioxover (Dropropizina) jarabe 3 mg/mL','Frasco 120 mL con vaso dosificador','Maver','MAV238','255469','2027-10-01',28.84,156.00,'IMG_5260','IMG_5293','alta','Lote confirmado'),
  ('0780083144302','Collifrin Adulto (Oximetazolina) 0.05% extra humectante','Frasco 20 mL','Collins','COL145','26140881','2028-04-06',33.61,null,'IMG_5298','IMG_5274','alta','UPC-A guardado como EAN-13'),
  ('0714706910906','Broncolin Bicoestol pastillas eucalipto/gordolobo/saúco','Caja con 16 pastillas de 2.5 g','Broncolin',null,null,null,null,null,'IMG_5226','IMG_5266','alta','Remedio herbolario 003RH2016. Sin línea en el ticket'),
  ('7502227871416','Raamfen (Difenidol) 25 mg','Caja con 30 tabletas','Laboratorio Raam','RAM046','RR184','2028-03-31',15.49,null,'IMG_5290','IMG_5294','alta','3 cajas en la foto de portada'),
  ('7502227875568','Desrotan (Fexofenadina) 180 mg','Caja con 10 tabletas','Laboratorio Raam','RAM100','RD085','2028-03-31',47.31,null,'IMG_5290','IMG_5294','alta',null),
  ('7502227872123','Raamcinet (Cetirizina) 10 mg','Caja con 10 tabletas','Laboratorio Raam','RAM054','7220526','2028-03-31',19.65,null,'IMG_5290','IMG_5294','alta','6 cajas en la foto de portada'),
  ('7503014377180','Playboy Max Sens Extra Sensible','3 condones + 1 gratis','Playboy / RRT Medical',null,null,null,null,null,'IMG_5262','IMG_5262','media','El ticket sólo trae PBY007 Tropicana Mix ($23.17) y PBY008 Passion Mix ($23.21), que son otras variantes: confirmar cuál corresponde'),
  ('7501032911454','OFF! Extra Duración aerosol repelente (DEET 25%)','Lata 170 g','SC Johnson',null,'1208274',null,null,null,'IMG_5190','IMG_5242','alta','Ya existía un patch de alta previo con este EAN'),
  ('7506452400267','Ajolotius jarabe Elderberry / mora azul','Frasco 250 mL','Ajolotius',null,null,null,null,null,'IMG_5287','IMG_5244','alta','Suplemento alimenticio, sin línea en el ticket'),
  ('7500462746643','Ajolotius caramelos menta-eucalipto (con azúcar)','Caja con 10 caramelos de 2.5 g (25 g)','Ajolotius',null,null,null,null,null,'IMG_5280','IMG_5245','alta','Lleva sellos de exceso de calorías y azúcares'),
  ('7506452400038','Ajolotius caramelos menta-eucalipto sin azúcar','Caja con 10 caramelos de 2.2 g (22 g)','Ajolotius',null,null,null,null,null,'IMG_5273','IMG_5248','alta','Versión con isomalt'),
  ('0759684273094','Hisopos de algodón Jaloma, tarro reutilizable','Tarro con hisopos','Jaloma',null,null,null,null,null,'IMG_5246','IMG_5246','media','Confirmar si es el mismo artículo que los hisopos KIUTS de IMG_5213'),
  ('7506306234062','Sedal Hidratación (Unilever)','Botella con bomba','Unilever',null,'64915004','2028-11-30',null,null,null,'IMG_5253','media','Producto de cuidado personal; falta la cara frontal con el volumen');

-- ---------------------------------------------------------------------------
-- Diagnóstico rápido de esta segunda carga
-- ---------------------------------------------------------------------------
select
  count(*)                                            as total_staging,
  count(*) filter (where p.id is null)                as altas_nuevas,
  count(*) filter (where p.id is not null)            as ya_existen,
  count(*) filter (where s.costo is not null)         as con_costo_de_ticket,
  count(*) filter (where s.notas ilike '%lote confirmado%') as lote_verificado_contra_ticket,
  count(*) filter (where s.confianza = 'media')       as requieren_confirmacion
from public.staging_fotos_lote4 s
left join public.productos p on p.codigo_barras = s.ean;

-- Vuelve a correr las consultas 1 a 4 de patch_lote4_1_STAGING.sql para ver el
-- detalle de altas, duplicados por nombre y lotes ya registrados.
