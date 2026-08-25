-- ============================================================================
-- Lote 4 (fotos 27A7CE10 … IMG_5240 del 15-ago-2026) — STAGING + DIAGNÓSTICO
--
-- Este script NO modifica public.productos ni public.lotes.
-- Sólo carga lo que se leyó de las fotos en una tabla de staging y devuelve
-- las consultas que dicen qué hacer con cada renglón.
--
-- Los EAN se decodificaron del código de barras con OpenCV, no por OCR visual.
-- El costo, lote y caducidad vienen del ticket Equilibrio 440393.
--
-- Correr entero. Al final salen 5 consultas de diagnóstico.
-- ============================================================================

create table if not exists public.staging_fotos_lote4 (
  id             bigserial primary key,
  ean            text not null,
  nombre         text not null,
  presentacion   text,
  laboratorio    text,
  codigo_prov    text,
  lote           text,
  caducidad      date,
  costo          numeric(12,4),
  pmp_etiqueta   numeric(12,2),   -- precio máximo al público impreso en el empaque
  foto_portada   text,
  foto_codigo    text,
  confianza      text not null default 'alta',
  notas          text
);

create unique index if not exists staging_fotos_lote4_ean_uidx
  on public.staging_fotos_lote4 (ean);

truncate public.staging_fotos_lote4 restart identity;

insert into public.staging_fotos_lote4
  (ean, nombre, presentacion, laboratorio, codigo_prov, lote, caducidad, costo,
   pmp_etiqueta, foto_portada, foto_codigo, confianza, notas)
values
  ('7501573902584','Sarox (Omeprazol) 20 mg','Caja con 14 cápsulas','Biomep','BIO067','5D2618','2028-04-01',8.42,null,'27A7CE10','6DD4578C','alta','5 cajas en la foto del código'),
  ('7501573909859','Sarox (Omeprazol) 20 mg','Caja con 28 cápsulas','Biomep','BIO213','5E2646','2028-05-01',15.61,null,'093E0A9C','C5C5C897','alta','5 cajas en la foto del código'),
  ('7503001007656','Wamindel (Paracetamol) gotas 100 mg/mL','Frasco 30 mL con gotero','Wandel','BIO087','LF2607','2028-06-30',12.02,null,'250A155A','72349D6F','alta',null),
  ('7503001007663','Wamindel (Paracetamol) solución infantil 3.2 g/100 mL','Frasco 120 mL con dosificador','Wandel','BIO068','LB2645','2028-02-01',15.44,null,'38C3B4CF','C262D33D','alta','2 cajas en la foto de portada'),
  ('7501825304555','Braxigort (Nifuroxazida) suspensión 4.4 g/100 mL','Frasco 90 mL con vasito','Degort''s Chemical','DEG186','487AA','2028-05-31',39.45,null,'C1BE604D','EF398EDB','alta',null),
  ('7501836006042','Virindrez Adulto (Oximetazolina) 0.050%','Frasco atomizador 20 mL','Liferpal MD','LIF160','26D035','2028-04-30',23.85,null,'A68E40F0','FC4E05B9','alta',null),
  ('7501836006028','Virindrez Infantil (Oximetazolina) 0.025%','Frasco atomizador 20 mL','Liferpal MD','LIF161','26C079','2028-04-30',20.70,null,'B9588A0F','A87B9D4D','alta',null),
  ('7503014377074','Playboy Playpack mixtos','Blíster con 3 piezas','Playboy','PBY004','1991025','2030-09-30',30.83,null,'234F45FA','07F78EE5','alta','El lote de la foto coincide con el del ticket'),
  ('7503004908714','Miconazol crema 2%','Tubo 20 g','Alpharma','ALP0520','2512183','2027-12-01',10.87,null,'BDF4F77D','E0CF187A','alta',null),
  ('7506624901059','beadvance Senósidos A-B 8.6 mg','Caja con 20 tabletas','Novag Infancia','BEA483','540346','2028-03-01',11.14,null,'8E4CDC37','8E814FF1','alta','El mismo EAN aparece en IMG_5202'),
  ('7501075723137','Novakosid Senósidos A-B 8.6 mg','Caja con 20 tabletas','Novag','NOV136','540266','2028-05-01',13.93,null,'IMG_5236','IMG_5223','alta','Duplicados: IMG_5238 e IMG_5206'),
  ('7502211788928','Desyn-N (Lidocaína/Hidrocortisona) 60/5 mg','Caja con 6 supositorios','Loeffler','LOE119','R2508053','2027-08-31',31.62,null,'703B2E1C','87821B44','alta',null),
  ('7503008344150','Prugnex Senósidos A-B 12 mg + ciruela 50 mg','Caja con 30 cápsulas','Progela','PGE040','T0885','2027-10-16',37.07,null,'68C6F4D1','580C6055','alta',null),
  ('7503003738879','Rosel-T 300/50/3 mg','Caja con 15 tabletas','Wermar','WER015','251070','2028-01-01',21.26,null,'6504C0CB','EA764742','alta','El mismo EAN aparece en IMG_5203'),
  ('7502240450230','Rosel solución infantil 0.5/0.02/3 g','Frasco 60 mL con vaso dosificador','Wermar','WER033','260204','2028-04-01',26.88,null,'6E25E862','199B80C8','alta','Segunda unidad fotografiada: 7E113744 + 7D6895C1'),
  ('7502211783282','Erbitrax (Terbinafina) crema 1%','Tubo 30 g','Loeffler','LOE076','R2602067','2028-03-31',28.62,null,'1D473A02','53C05603','alta','Segunda unidad fotografiada: 3E498024 + 088DA5DB'),
  ('7501573902966','Nafich (Terbinafina) crema 1%','Tubo 15 g','Biomep','BIO103','CD2603','2028-04-01',13.06,null,'237FBE1E','BA5A9E8F','alta','2 cajas en la foto del código'),
  ('7501836009661','Dualgos (Paracetamol/Ibuprofeno) 325/200 mg','Caja con 20 tabletas','Liferpal MD','LIF147','25J081','2027-11-30',29.02,null,'4CFA8341','A6BC7DCB','alta',null),
  ('0780083142308','Tempire (Paracetamol) gotas 100 mg/mL','Frasco 30 mL con pipeta','Collins','COL090','26140833','2029-04-06',20.00,null,'7632E454','22E120A7','alta','UPC-A de 12 dígitos, guardado como EAN-13 con cero al frente'),
  ('7502001165045','Dolzycam (Piroxicam) gel 0.5%','Tubo 60 g','Química Son''s','SON044','26010268','2028-01-01',24.81,null,'E89493EC','6165DF80','alta',null),
  ('7503008344303','Ladexgel 300/2/10 mg','Caja con 12 cápsulas','Progela','PGE018','U0150','2028-01-08',20.55,null,'E2CBD830','83BB62BB','alta','2 cajas en la foto del código'),
  ('7502001165953','Rexurdir (Nifuroxazida) 400 mg','Caja con 16 cápsulas','Química Son''s','SON226','26051290','2028-05-01',29.92,null,'D35E4E25','5DBBDD3E','alta','Portada adicional: IMG_5198'),
  ('7501825300366','Espabion (Trimebutina) 20 mg/mL gotas','Frasco 30 mL con gotero','Degort''s Chemical','DEG030','449AA','2029-05-31',25.67,null,'41D1703A','1A1E3FF9','alta',null),
  ('7502009745997','Pamedan (Dexpantenol) crema 5%','Tubo 30 g','Maver','MAV279','261562','2028-03-01',19.53,null,'0AF68193','31B77F4E','alta',null),
  ('0785118752637','Itamol (Subsalicilato de bismuto) 262 mg','Caja con 24 tabletas masticables','Mavi / Sanfer','MAI080','6C0337','2028-03-31',34.09,null,'7F38B16F','78430482','alta','UPC-A de 12 dígitos, guardado como EAN-13 con cero al frente'),
  ('7502006920021','Motilaxil-T (Picosulfato de sodio) 5 mg','Caja con 20 tabletas','Fármacos Continentales','FAC0059','ITF26S084','2028-06-30',17.02,null,'B1C183DA','247D784E','alta',null),
  ('7502009745539','Lumboxen gel (Naproxeno/Lidocaína) 10/2 g','Tubo 35 g','Maver','MAV247','256834','2027-12-01',39.54,null,'B4041F93','E7DF5779','alta',null),
  ('7501258207010','Oxital-C (Vitamina C) 2 g efervescente','Tubo con 10 comprimidos','Serral','SER141','260140','2028-01-26',62.48,null,'F5C191F7','3250C155','alta',null),
  ('7502009747236','Exaliv 325/5/2 mg','Caja con 24 tabletas','Maver','MAV341','260224','2028-05-01',19.82,null,'IMG_5230','IMG_5218','media','Emparejado por caja roja + Reg. 478M98; confirmar'),
  ('7502227427392','ML-PRIM (Metocarbamol/Naproxeno) 375/200 mg','Caja con 12 cápsulas','Gelpharma','GEP030','260735','2028-03-01',47.28,null,'IMG_5193','IMG_5192','media','Emparejado por laboratorio Gelpharma; 3 cajas en la foto'),
  ('7501075718676','Novagon polvo piña-naranja','Frasco 400 g','Novag','NOV098','491066','2030-04-01',97.10,230.00,'IMG_5184','IMG_5237','alta','Lote impreso 491066 = lote del ticket'),
  ('7501075713770','Novagon polvo 49.7 g/100 g','Frasco 400 g','Novag','NOV017','500546','2030-01-01',99.10,230.00,null,'IMG_5229','alta','Lote impreso 500546 = lote del ticket; falta portada'),
  ('7502253601339','Daclafin (Subsalicilato de bismuto)','Frasco 120 mL','Columbia / Weser','DAC005','26C0037','2028-03-31',31.49,69.00,null,'IMG_5210','alta','Lote impreso 26C0037 = lote del ticket; falta portada'),
  ('7500435145497','NyQuil Z (Difenhidramina) 25 mg','Caja con 30 cápsulas','Vicks / P&G','PYG024','A00056','2026-10-31',281.55,null,'IMG_5224','IMG_5205','alta','Caduca en oct-2026: revisar antes de publicar'),
  -- Con EAN confirmado pero sin costo del ticket (proveedor distinto a Equilibrio)
  ('7501033956775','Pedialyte SR 60 mEq uva','Frasco 500 mL','Abbott',null,null,null,null,null,'IMG_5191','IMG_5183','alta','Sin línea en el ticket Equilibrio'),
  ('7501328979496','Histiacil NF jarabe infantil','Frasco 150 mL con vasito','Opella / Sanofi',null,null,null,null,null,'IMG_5216','IMG_5217','alta','Sin línea en el ticket Equilibrio'),
  ('7500462746612','Ajolotius jarabe original','Frasco 250 mL','Ajolotius',null,null,null,null,null,'IMG_5232','IMG_5232','alta','La misma foto muestra marca y código'),
  ('7501088579615','Topron (Nifuroxazida) 400 mg','Caja con 16 cápsulas','Chinoin',null,null,null,null,null,'IMG_5225','IMG_5186','media','Emparejado por caja azul marino + perfil antidiarreico; confirmar'),
  ('7503014377197','Playboy Max Sens Extra Delgados','3 condones + 1 gratis','Playboy / RRT Medical',null,null,null,null,null,'IMG_5209','IMG_5215','media','Emparejado por empaque verde; confirmar contra PBY007/PBY008'),
  ('7500462746698','Ajolotius jarabe con propóleo','Frasco 250 mL','Ajolotius',null,null,null,null,null,'IMG_5222','IMG_5201','media','Emparejado por frasco naranja; confirmar');

-- ---------------------------------------------------------------------------
-- 1. Qué ya existe en la base con ese EAN
-- ---------------------------------------------------------------------------
select
  s.ean,
  s.nombre                       as nombre_foto,
  p.id                           as producto_id,
  p.sku,
  p.nombre                       as nombre_bd,
  p.costo                        as costo_bd,
  s.costo                        as costo_ticket,
  p.precio                       as precio_bd,
  p.stock,
  case
    when p.id is null                              then 'ALTA NUEVA'
    when coalesce(p.costo,0) = 0 and s.costo > 0   then 'ACTUALIZAR COSTO'
    when abs(coalesce(p.costo,0) - s.costo) > 0.01 then 'COSTO DISTINTO'
    else 'OK'
  end as accion
from public.staging_fotos_lote4 s
left join public.productos p on p.codigo_barras = s.ean
order by accion, s.nombre;

-- ---------------------------------------------------------------------------
-- 2. Posibles duplicados: el EAN no está, pero hay un producto con nombre parecido
--    (evita crear un segundo registro del mismo artículo)
-- ---------------------------------------------------------------------------
select
  s.ean,
  s.nombre        as nombre_foto,
  p.id            as producto_id_candidato,
  p.sku,
  p.nombre        as nombre_bd,
  p.codigo_barras as ean_bd,
  p.costo
from public.staging_fotos_lote4 s
join public.productos p
  on p.nombre ilike '%' || split_part(s.nombre, ' ', 1) || '%'
where not exists (
  select 1 from public.productos p2 where p2.codigo_barras = s.ean
)
order by s.nombre, p.nombre;

-- ---------------------------------------------------------------------------
-- 3. El EAN ya está en la base pero con otro nombre — revisar antes de tocar
-- ---------------------------------------------------------------------------
select
  s.ean,
  s.nombre        as nombre_foto,
  p.sku,
  p.nombre        as nombre_bd,
  p.marca
from public.staging_fotos_lote4 s
join public.productos p on p.codigo_barras = s.ean
where lower(p.nombre) not like '%' || lower(split_part(s.nombre, ' ', 1)) || '%'
order by s.nombre;

-- ---------------------------------------------------------------------------
-- 4. Lotes: cuáles de estos números de lote ya están registrados
-- ---------------------------------------------------------------------------
select
  s.ean,
  s.nombre,
  s.lote          as lote_foto,
  s.caducidad     as caducidad_ticket,
  l.id            as lote_id,
  l.numero_lote   as lote_bd,
  l.fecha_caducidad,
  l.cantidad_actual
from public.staging_fotos_lote4 s
left join public.productos p on p.codigo_barras = s.ean
left join public.lotes l     on l.producto_id = p.id and l.numero_lote = s.lote
where s.lote is not null
order by (l.id is not null), s.nombre;

-- ---------------------------------------------------------------------------
-- 5. Resumen
-- ---------------------------------------------------------------------------
select
  count(*)                                          as renglones_staging,
  count(*) filter (where p.id is null)              as altas_nuevas,
  count(*) filter (where p.id is not null)          as ya_existen,
  count(*) filter (where s.costo is not null)       as con_costo_de_ticket,
  count(*) filter (where s.confianza = 'media')     as requieren_confirmacion
from public.staging_fotos_lote4 s
left join public.productos p on p.codigo_barras = s.ean;
