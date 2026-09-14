-- Fotos por nombre (Exprezo / Levic / Nadro / internet) 2026-09-14
-- Pegar DESPUÉS de patch_fotos_frente_y_faltantes_20260914.sql
-- origen de galería: solo rappi | distribuidor | propia | gs1 | otro
--
-- visoti.mx (Levic) no responde SSL desde este entorno. Donde el portal
-- Levic/Exprezo tenía el mismo producto, la foto salió de Nadro o se
-- copió a catalogo-propia (Dove 90 g, Aktyzar, Bocetix).
--
-- No se usó: Gerber 113 g ≠ 100 g; Dove 135 g ≠ 90 g; Pantene 400 ml;
-- Lomecan vs otro EAN; Sarox 14 ≠ 28; Losartán otro lab; LAÜR adulto;
-- Honey Keeper solo costado legal; Brut Deep Blue packshot ilegible;
-- Nordiko 130 g (otro EAN); Xiomara pomada = generica_1.jpg.

begin;

create temporary table tmp_foto_nombre (
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_nombre (sku, url, origen)
values
  -- Ya cruzados Exprezo/Levic (Nadro, no gruporfp: ese host no resolvió)
  ('FC-40013850',
   'https://nadro.vtexassets.com/arquivos/ids/201486/650240013850_01.jpg',
   'distribuidor'), -- Teatrical lanolina 52 g · tapa = cara de mostrador
  ('FC-40013898',
   'https://nadro.vtexassets.com/arquivos/ids/201491/650240013898_01.jpg',
   'distribuidor'), -- Teatrical rosas + lanolina 52 g
  ('FMX-302947',
   'https://nadro.vtexassets.com/arquivos/ids/218191/7502259892403_01.jpg',
   'distribuidor'), -- Naturex citrato Mg C/30 · Levic NAT0617
  ('FMX-502465',
   'https://nadro.vtexassets.com/arquivos/ids/218404/7502009741524_01.jpg',
   'distribuidor'), -- Naturex colágeno C/60 700 mg · Levic NAT0220
  ('FC-08491096',
   'https://nadro.vtexassets.com/arquivos/ids/209991/7501008433515_01.jpg',
   'distribuidor'), -- CafiAspirina C/100 frente
  ('FC-03440534',
   'https://www.farmacapital.mx/catalogo-propia/adidas-control-150ml-3616303440534.jpg',
   'propia'),
  ('FC-03441302',
   'https://www.farmacapital.mx/catalogo-propia/adidas-teamforce-150ml-3616303441302.jpg',
   'propia'),

  -- EAN exacto Nadro (12/13 / sin cero a la izquierda)
  ('FC-40025839',
   'https://nadro.vtexassets.com/arquivos/ids/199751/650240025839_01.jpg',
   'distribuidor'), -- Lomecan Intimemo fresco 200 ml (ticket decía jabón; EAN es SH íntimo)
  ('FC-40030338',
   'https://nadro.vtexassets.com/arquivos/ids/201847/650240030338_01.jpg',
   'distribuidor'), -- Lomecan Intimemo aclarante 200 ml
  ('FC-40036965',
   'https://nadro.vtexassets.com/arquivos/ids/204090/650240036965_01.jpg',
   'distribuidor'), -- Asepxia bicarbonato 100 g
  ('FC-06251847',
   'https://nadro.vtexassets.com/arquivos/ids/199364/7506306251847_01.jpg',
   'distribuidor'), -- Axe Black Remix 210 ml
  ('FC-06209855',
   'https://nadro.vtexassets.com/arquivos/ids/215157/7506306209855_01.jpg',
   'distribuidor'), -- Axe Anarchy Flowers 150 ml
  ('FC-03842550',
   'https://nadro.vtexassets.com/arquivos/ids/205054/3616303842550_01.jpg',
   'distribuidor'), -- Adidas Fresh Endurance 150 ml
  ('FC-22107201',
   'https://nadro.vtexassets.com/arquivos/ids/185163/7501022107201_01.jpg',
   'distribuidor'), -- Conse anti olores 500 ml
  ('FC-36007279',
   'https://nadro.vtexassets.com/arquivos/ids/203646/37836007279_01.jpg',
   'distribuidor'), -- Conse Guau aloe 400 ml · EAN 037836007279
  ('FC-36084508',
   'https://nadro.vtexassets.com/arquivos/ids/203790/37836084508_01.jpg',
   'distribuidor'), -- Grisi Perro Agradecido avena 400 ml
  ('FC-50343065',
   'https://nadro.vtexassets.com/arquivos/ids/244232/7502250343065_01.jpg',
   'distribuidor'), -- Vitacilina 2x1 (caja; ficha 28 g)
  ('FC-50342563',
   'https://nadro.vtexassets.com/arquivos/ids/223165/7502250342563_01.jpg',
   'distribuidor'), -- Vitacilina serum colágeno 30 ml
  ('FC-46698137',
   'https://nadro.vtexassets.com/arquivos/ids/236287/7509546698137_01.jpg',
   'distribuidor'), -- Colgate Luminous White 66 ml
  ('FC-19036590',
   'https://nadro.vtexassets.com/arquivos/ids/207365/7501019036590_01.jpg',
   'distribuidor'), -- Saba Buenas Noches Extra C/12
  ('FC-39349146',
   'https://nadro.vtexassets.com/arquivos/ids/199610/7506339349146_01.jpg',
   'distribuidor'), -- Old Spice Wolfthorn 150 ml
  ('FC-52828078',
   'https://nadro.vtexassets.com/arquivos/ids/198914/7509552828078_01.jpg',
   'distribuidor'), -- Garnier Fructis Hair Food banana 350 ml
  ('FC-09864839',
   'https://nadro.vtexassets.com/arquivos/ids/210533/7506309864839_01.jpg',
   'distribuidor'), -- Gillette Endurance Cool Wave 150 ml
  ('FC-25108747',
   'https://nadro.vtexassets.com/arquivos/ids/201464/3614225108747_01.jpg',
   'distribuidor'), -- Koleston 40 castaño medio
  ('FC-25108761',
   'https://nadro.vtexassets.com/arquivos/ids/204775/3614225108761_01.jpg',
   'distribuidor'), -- Koleston 466 borgoña intenso
  ('FC-25108877',
   'https://nadro.vtexassets.com/arquivos/ids/204828/3614225108877_01.jpg',
   'distribuidor'), -- Koleston 70 rubio medio
  ('FC-82731071',
   'https://nadro.vtexassets.com/arquivos/ids/158598/7501082731071_01.jpg',
   'distribuidor'), -- Nuvel Tropic 170 ml
  ('FC-82736021',
   'https://nadro.vtexassets.com/arquivos/ids/229065/7501082736021_01.jpg',
   'distribuidor'), -- Nuvel Aclarado Ideal 150 ml
  ('FC-46015514',
   'https://nadro.vtexassets.com/arquivos/ids/199693/7509546015514_01.jpg',
   'distribuidor'), -- Lady Speed Stick Active Fresh 45 g
  ('FC-46029153',
   'https://nadro.vtexassets.com/arquivos/ids/209752/7509546029153_01.jpg',
   'distribuidor'), -- Lady Speed Stick Floral Fresh gel 65 g
  ('FC-46078434',
   'https://nadro.vtexassets.com/arquivos/ids/198962/7509546078434_01.jpg',
   'distribuidor'), -- Stefano Alpha (ticket 113 g; empaque actual 159 ml, mismo EAN)
  ('FC-46651743',
   'https://nadro.vtexassets.com/arquivos/ids/200246/7509546651743_01.jpg',
   'distribuidor'), -- Stefano Triumph 159 ml
  ('FC-46694702',
   'https://nadro.vtexassets.com/arquivos/ids/223155/7509546694702_01.jpg',
   'distribuidor'), -- Stefano Next Level 150 ml
  ('FC-46654997',
   'https://nadro.vtexassets.com/arquivos/ids/202273/7509546654997_01.jpg',
   'distribuidor'), -- Caprice Final Touch mousse 200 g
  ('FC-15592837',
   'https://nadro.vtexassets.com/arquivos/ids/217075/7896015592837_01.jpg',
   'distribuidor'), -- Sensodyne Gentle Care 3 pz
  ('FC-18132592',
   'https://nadro.vtexassets.com/arquivos/ids/230575/761318132592_01.jpg',
   'distribuidor'), -- Revlon peines carbón 2 pk
  ('FC-18020639',
   'https://nadro.vtexassets.com/arquivos/ids/198310/761318020639_01.jpg',
   'distribuidor'), -- Revlon cepillo acolchado
  ('FC-18128335',
   'https://nadro.vtexassets.com/arquivos/ids/204401/761318128335_01.jpg',
   'distribuidor'), -- Revlon paleta
  ('FC-75064891',
   'https://nadro.vtexassets.com/arquivos/ids/203215/75064891_01.jpg',
   'distribuidor'), -- Savile sábila / agua de rosas roll-on 45 ml
  ('FC-78926523',
   'https://nadro.vtexassets.com/arquivos/ids/201272/78926523_01.jpg',
   'distribuidor'), -- Rexona Active Emotion roll-on 50 ml
  ('FC-20500171',
   'https://nadro.vtexassets.com/arquivos/ids/215979/810120500171_01.jpg',
   'distribuidor'), -- Pert crema peinar oliva + aguacate
  ('FC-36032776',
   'https://nadro.vtexassets.com/arquivos/ids/203654/37836032776_01.jpg',
   'distribuidor'), -- Ricitos de Oro Bio-Pure 250 ml
  ('FC-05405168',
   'https://nadro.vtexassets.com/arquivos/ids/185994/7503005405168_01.jpg',
   'distribuidor'), -- Estropajo Saluk Fashion F-Clean
  ('FC-52900247',
   'https://nadro.vtexassets.com/arquivos/ids/244896/7506552900247_01.jpg',
   'distribuidor'), -- Almohadillas algodón Quirmex C/100

  -- Nombre + presentación (Exprezo / Levic) · JPG propia
  ('FC-06246652',
   'https://www.farmacapital.mx/catalogo-propia/dove-original-90g.jpg',
   'propia'), -- Dove blanco 90 g · Exprezo mismo nombre · EAN 7506306246652
  ('FC-82200016',
   'https://www.farmacapital.mx/catalogo-propia/aktyzar-omeprazol-20mg-120cap.jpg',
   'propia'), -- Aktyzar 20 mg C/120 · Levic SOF054 · EAN 7501482200016
  ('EQ-VIT073',
   'https://www.farmacapital.mx/catalogo-propia/bocetix-levocetirizina-150ml.jpg',
   'propia'); -- Bocetix 150 ml Vitae · Levic VIT073

create temporary table tmp_foto_match (
  producto_id bigint primary key,
  sku text not null,
  url text not null,
  origen text not null
) on commit drop;

insert into tmp_foto_match (producto_id, sku, url, origen)
select distinct on (p.id)
  p.id, m.sku, m.url, m.origen
from public.productos p
join tmp_foto_nombre m on p.sku = m.sku
where p.imagen_url is null
   or btrim(p.imagen_url) = ''
order by p.id;

update public.productos p
set imagen_url = m.url,
    imagen_mobile_url = m.url
from tmp_foto_match m
where p.id = m.producto_id;

insert into public.producto_imagenes
  (producto_id, url, storage_path, posicion, es_principal, origen)
select
  m.producto_id,
  m.url,
  null,
  coalesce((select max(i.posicion) from public.producto_imagenes i where i.producto_id = m.producto_id), 0) + 1,
  false,
  m.origen
from tmp_foto_match m
where not exists (
  select 1 from public.producto_imagenes i
  where i.producto_id = m.producto_id and i.url = m.url
);

update public.producto_imagenes i
set es_principal = false
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.es_principal
  and i.url not in (select url from tmp_foto_match);

update public.producto_imagenes i
set es_principal = true
where i.producto_id in (select producto_id from tmp_foto_match)
  and i.url in (select url from tmp_foto_match)
  and not i.es_principal;

commit;
