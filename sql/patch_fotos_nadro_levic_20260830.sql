-- ============================================================================
-- Fotos Nadro + Levic para productos activos sin ninguna imagen
-- Fecha: 2026-08-30
-- YA APLICADO en producción (SQL Editor, 30 ago 2026). Idempotente si se reejecuta.
--
-- Cruce por EAN exacto (también acepta el mismo GTIN con/sin ceros a la
-- izquierda, p. ej. GUM 070942307109 = 70942307109).
-- Levic: CDN visoti.mx por clave EQ-XXXX.
--
-- NO se copian a Storage (este entorno no tiene service role). Las URLs son
-- las públicas de Nadro (nadro.vtexassets.com) y Levic (visoti.mx).
--
-- Descartadas a propósito (no coinciden presentación o la foto es genérica):
--   FC-070839  Alliviax Garganta C/8  ≠  Nadro ALLIVIAX 550 MG 6 TAB
--   FC-05405168 Saluk Fashion SA      ≠  Nadro ESTROPAJO F-CLEAN
--   FC-46504859 Xiomara Pomada B      →  Nadro generica_1.jpg
--
-- Ejecutar en Supabase SQL Editor (archivo completo). Idempotente.
-- El resto de productos sin foto: sql/generated/fotos_fotografiar_20260830.csv
-- ============================================================================

begin;

-- Galería (posición 1, principal, origen distribuidor)
insert into public.producto_imagenes
  (producto_id, url, posicion, es_principal, origen)
select v.producto_id, v.url, 1, true, 'distribuidor'
from (values
  (1300, 'https://nadro.vtexassets.com/arquivos/ids/155660/7501314701957_01.jpg', 'FC-14701957', 'Adel suspensión 250 mg / 5 mL 60 mL', 'nadro'),
  (1233, 'https://nadro.vtexassets.com/arquivos/ids/203333/13117001341_01.jpg', 'FC-11700134', 'Affective Cover Pro protector desechable unitalla C/16', 'nadro'),
  (486, 'https://nadro.vtexassets.com/arquivos/ids/217486/7503008344747_01.jpg', 'FC-08344747', 'Afrodit', 'nadro'),
  (473, 'https://nadro.vtexassets.com/arquivos/ids/231634/7501008499900_01.jpg', 'FC-84999001', 'Alka-Seltzer', 'nadro'),
  (1291, 'https://nadro.vtexassets.com/arquivos/ids/170742/7501349024045_01.jpg', 'EQ-AMS075', 'Butilhioscina 3 Amp 20 Mg/1 Ml', 'nadro'),
  (1298, 'https://visoti.mx/imagenes/Grande/MAV088.webp', 'EQ-MAV088', 'Cefabroxil Susp 250/15 Mg/5/75 Ml', 'levic'),
  (1292, 'https://visoti.mx/imagenes/Grande/AMS491.webp', 'EQ-AMS491', 'Cefalexina Susp 100 Ml 250 Mg/5 Ml', 'levic'),
  (1296, 'https://nadro.vtexassets.com/arquivos/ids/192012/7503000422610_01.jpg', 'EQ-MAV007', 'Cefalver Susp 125 Mg/5/90 Ml', 'nadro'),
  (1297, 'https://nadro.vtexassets.com/arquivos/ids/200089/7503000422627_01.jpg', 'EQ-MAV008', 'Cefalver Susp 250 Mg/5/90 Ml', 'nadro'),
  (691, 'https://nadro.vtexassets.com/arquivos/ids/199571/7702010631207_01.jpg', 'FC-10631207', 'Cepillo Dent Punta poderosa Medio 2 pack', 'nadro'),
  (1299, 'https://nadro.vtexassets.com/arquivos/ids/240786/7502009740978_01.jpg', 'EQ-MAV089', 'Cepobrom Susp 100 Ml 250/4.39 Mg/5 Ml', 'nadro'),
  (294, 'https://nadro.vtexassets.com/arquivos/ids/165376/7501026462061_01.jpg', 'FC-26462061', 'Chupon Ternura Ortodontic Miel C3', 'nadro'),
  (283, 'https://nadro.vtexassets.com/arquivos/ids/157415/7501026462245_01.jpg', 'FC-26462078', 'Chupón con miel Ternura', 'nadro'),
  (203, 'https://nadro.vtexassets.com/arquivos/ids/201679/7502221012303_01.jpg', 'FC-21012303', 'Claris toallas desmaquillantes aloe C/40', 'nadro'),
  (295, 'https://nadro.vtexassets.com/arquivos/ids/158415/7702035469151_01.jpg', 'FC-35469151', 'Crema Lubriderm Uv Fps15', 'nadro'),
  (287, 'https://nadro.vtexassets.com/arquivos/ids/198903/4005808802838_01.jpg', 'FC-08802838', 'Crema Nivea Softmilk', 'nadro'),
  (1301, 'https://nadro.vtexassets.com/arquivos/ids/179989/7501299301968_01.jpg', 'FC-99301968', 'Dafloxen F 100/200 mg supositorios C/5', 'nadro'),
  (1302, 'https://nadro.vtexassets.com/arquivos/ids/178984/7501385491085_01.jpg', 'FC-85491085', 'Danzen 10 mg C/20 tabletas', 'nadro'),
  (706, 'https://nadro.vtexassets.com/arquivos/ids/205482/70942302289_01.jpg', 'FC-42302289', 'Enjuague Bucal GUM Paroex Gengivitis', 'nadro'),
  (1245, 'https://nadro.vtexassets.com/arquivos/ids/159414/5000174305449_01.jpg', 'FC-74305449', 'Fixodent Original crema dental 40 mL', 'nadro'),
  (1303, 'https://nadro.vtexassets.com/arquivos/ids/205582/70942307109_01.jpg', 'FC-42307109', 'GUM Flossers hilo dental con mango C/30', 'nadro'),
  (1307, 'https://nadro.vtexassets.com/arquivos/ids/240456/7502227879559_01.jpg', 'FC-27879559', 'JULAB norfloxacino/fenazopiridina 400/100 mg C/8', 'nadro'),
  (1294, 'https://visoti.mx/imagenes/Grande/COL252.webp', 'EQ-COL252', 'Kenzoflex Duo 1 Sol 3.5/1 Mg/5 Ml', 'levic'),
  (741, 'https://nadro.vtexassets.com/arquivos/ids/191862/7502009740435_01.jpg', 'FC-09740435', 'Laritol (Loratadina) 10 mg', 'nadro'),
  (1066, 'https://visoti.mx/imagenes/Grande/BRL072.webp', 'EQ-BRL072-1', 'Lo Bruquin 2 Tab 150/200 Mg', 'levic'),
  (650, 'https://nadro.vtexassets.com/arquivos/ids/159009/736085278507_01.jpg', 'FC-85278507', 'Manzanilla Sophia Solucion 15 ml', 'nadro'),
  (1308, 'https://nadro.vtexassets.com/arquivos/ids/238228/7501258210379_01.jpg', 'FC-58210379', 'Minociclina 100 mg C/10 Serral', 'nadro'),
  (669, 'https://nadro.vtexassets.com/arquivos/ids/160718/736085132069_01.jpg', 'FC-85132069', 'Nazil Ofteno Solucion Oftalmica 15 ml', 'nadro'),
  (1305, 'https://nadro.vtexassets.com/arquivos/ids/194576/650240001314_01.jpg', 'FC-40001314', 'Nikzon 90 tabletas masticables', 'nadro'),
  (1293, 'https://visoti.mx/imagenes/Grande/COL080.webp', 'EQ-COL080', 'Pasmodil 1 Fa 250/20 Mg', 'levic'),
  (311, 'https://nadro.vtexassets.com/arquivos/ids/217049/7896009419324_01.jpg', 'FC-09419324', 'Pasta Dent Sensodyne Original', 'nadro'),
  (666, 'https://nadro.vtexassets.com/arquivos/ids/168412/7501289511421_01.jpg', 'FC-9511421', 'Pasta Lassar Andromaco 30 g', 'nadro'),
  (565, 'https://nadro.vtexassets.com/arquivos/ids/158011/7501943475014_01.jpg', 'FC-43475014', 'Pañal Diapro Grande', 'nadro'),
  (700, 'https://nadro.vtexassets.com/arquivos/ids/204389/759684471476_01.jpg', 'FC-84471476', 'Repelente de Insectos Jaloma Bio Clap', 'nadro'),
  (1277, 'https://nadro.vtexassets.com/arquivos/ids/164259/7502245720024_01.jpg', 'FC-45720024', 'Silk Hair Silica · variante 024 · confirmar', 'nadro'),
  (1279, 'https://nadro.vtexassets.com/arquivos/ids/156841/7502245720031_01.jpg', 'FC-45720031', 'Silk Hair Silica · variante 031 · confirmar', 'nadro'),
  (1276, 'https://nadro.vtexassets.com/arquivos/ids/164468/7502245720062_01.jpg', 'FC-45720062', 'Silk Hair Silica · variante 062 · confirmar', 'nadro'),
  (1275, 'https://nadro.vtexassets.com/arquivos/ids/200500/7502245720086_01.jpg', 'FC-45720086', 'Silk Hair Silica · variante 086 · confirmar', 'nadro'),
  (1278, 'https://nadro.vtexassets.com/arquivos/ids/164262/7502245720093_01.jpg', 'FC-45720093', 'Silk Hair Silica · variante 093 · confirmar', 'nadro'),
  (1280, 'https://nadro.vtexassets.com/arquivos/ids/184971/7502245720109_01.jpg', 'FC-45720109', 'Silk Hair Silica · variante 109 · confirmar', 'nadro'),
  (598, 'https://nadro.vtexassets.com/arquivos/ids/194603/650240007408_01.jpg', 'FC-00740024', 'Silka Medic Gel', 'nadro'),
  (617, 'https://nadro.vtexassets.com/arquivos/ids/155724/736085405422_01.jpg', 'FC-54054221', 'Splash Tears Sol oftálmica', 'nadro'),
  (221, 'https://nadro.vtexassets.com/arquivos/ids/174195/7501072300171_01.jpg', 'FC-72300171', 'Talco Desodorante Ting polvo', 'nadro'),
  (1242, 'https://nadro.vtexassets.com/arquivos/ids/217998/7501019064807_01.jpg', 'FC-19064807', 'Tena Pants Comfort grande C/13', 'nadro')
) as v(producto_id, url, sku, nombre, fuente)
where exists (
        select 1 from public.productos p
         where p.id = v.producto_id
           and p.sku = v.sku
           and p.activo = true
      )
  and not exists (
        select 1 from public.producto_imagenes g
         where g.producto_id = v.producto_id
      )
on conflict (producto_id, url) do nothing;


-- Ficha: solo si imagen_url sigue vacía
update public.productos p
   set imagen_url = v.url,
       imagen_mobile_url = v.url
from (values
  (1300, 'https://nadro.vtexassets.com/arquivos/ids/155660/7501314701957_01.jpg'),
  (1233, 'https://nadro.vtexassets.com/arquivos/ids/203333/13117001341_01.jpg'),
  (486, 'https://nadro.vtexassets.com/arquivos/ids/217486/7503008344747_01.jpg'),
  (473, 'https://nadro.vtexassets.com/arquivos/ids/231634/7501008499900_01.jpg'),
  (1291, 'https://nadro.vtexassets.com/arquivos/ids/170742/7501349024045_01.jpg'),
  (1298, 'https://visoti.mx/imagenes/Grande/MAV088.webp'),
  (1292, 'https://visoti.mx/imagenes/Grande/AMS491.webp'),
  (1296, 'https://nadro.vtexassets.com/arquivos/ids/192012/7503000422610_01.jpg'),
  (1297, 'https://nadro.vtexassets.com/arquivos/ids/200089/7503000422627_01.jpg'),
  (691, 'https://nadro.vtexassets.com/arquivos/ids/199571/7702010631207_01.jpg'),
  (1299, 'https://nadro.vtexassets.com/arquivos/ids/240786/7502009740978_01.jpg'),
  (294, 'https://nadro.vtexassets.com/arquivos/ids/165376/7501026462061_01.jpg'),
  (283, 'https://nadro.vtexassets.com/arquivos/ids/157415/7501026462245_01.jpg'),
  (203, 'https://nadro.vtexassets.com/arquivos/ids/201679/7502221012303_01.jpg'),
  (295, 'https://nadro.vtexassets.com/arquivos/ids/158415/7702035469151_01.jpg'),
  (287, 'https://nadro.vtexassets.com/arquivos/ids/198903/4005808802838_01.jpg'),
  (1301, 'https://nadro.vtexassets.com/arquivos/ids/179989/7501299301968_01.jpg'),
  (1302, 'https://nadro.vtexassets.com/arquivos/ids/178984/7501385491085_01.jpg'),
  (706, 'https://nadro.vtexassets.com/arquivos/ids/205482/70942302289_01.jpg'),
  (1245, 'https://nadro.vtexassets.com/arquivos/ids/159414/5000174305449_01.jpg'),
  (1303, 'https://nadro.vtexassets.com/arquivos/ids/205582/70942307109_01.jpg'),
  (1307, 'https://nadro.vtexassets.com/arquivos/ids/240456/7502227879559_01.jpg'),
  (1294, 'https://visoti.mx/imagenes/Grande/COL252.webp'),
  (741, 'https://nadro.vtexassets.com/arquivos/ids/191862/7502009740435_01.jpg'),
  (1066, 'https://visoti.mx/imagenes/Grande/BRL072.webp'),
  (650, 'https://nadro.vtexassets.com/arquivos/ids/159009/736085278507_01.jpg'),
  (1308, 'https://nadro.vtexassets.com/arquivos/ids/238228/7501258210379_01.jpg'),
  (669, 'https://nadro.vtexassets.com/arquivos/ids/160718/736085132069_01.jpg'),
  (1305, 'https://nadro.vtexassets.com/arquivos/ids/194576/650240001314_01.jpg'),
  (1293, 'https://visoti.mx/imagenes/Grande/COL080.webp'),
  (311, 'https://nadro.vtexassets.com/arquivos/ids/217049/7896009419324_01.jpg'),
  (666, 'https://nadro.vtexassets.com/arquivos/ids/168412/7501289511421_01.jpg'),
  (565, 'https://nadro.vtexassets.com/arquivos/ids/158011/7501943475014_01.jpg'),
  (700, 'https://nadro.vtexassets.com/arquivos/ids/204389/759684471476_01.jpg'),
  (1277, 'https://nadro.vtexassets.com/arquivos/ids/164259/7502245720024_01.jpg'),
  (1279, 'https://nadro.vtexassets.com/arquivos/ids/156841/7502245720031_01.jpg'),
  (1276, 'https://nadro.vtexassets.com/arquivos/ids/164468/7502245720062_01.jpg'),
  (1275, 'https://nadro.vtexassets.com/arquivos/ids/200500/7502245720086_01.jpg'),
  (1278, 'https://nadro.vtexassets.com/arquivos/ids/164262/7502245720093_01.jpg'),
  (1280, 'https://nadro.vtexassets.com/arquivos/ids/184971/7502245720109_01.jpg'),
  (598, 'https://nadro.vtexassets.com/arquivos/ids/194603/650240007408_01.jpg'),
  (617, 'https://nadro.vtexassets.com/arquivos/ids/155724/736085405422_01.jpg'),
  (221, 'https://nadro.vtexassets.com/arquivos/ids/174195/7501072300171_01.jpg'),
  (1242, 'https://nadro.vtexassets.com/arquivos/ids/217998/7501019064807_01.jpg')
) as v(producto_id, url)
where p.id = v.producto_id
  and p.activo = true
  and coalesce(trim(p.imagen_url), '') = '';

commit;

-- Comprobación: deben salir 44 filas (o las que ya estuvieran).
select p.sku, p.nombre, i.origen, i.url
  from public.producto_imagenes i
  join public.productos p on p.id = i.producto_id
 where i.origen = 'distribuidor'
   and p.sku in (
     'FC-14701957','FC-11700134','FC-08344747','FC-84999001','EQ-AMS075',
     'EQ-MAV088','EQ-AMS491','EQ-MAV007','EQ-MAV008','FC-10631207',
     'EQ-MAV089','FC-26462061','FC-26462078','FC-21012303','FC-35469151',
     'FC-08802838','FC-99301968','FC-85491085','FC-42302289','FC-74305449',
     'FC-42307109','FC-27879559','EQ-COL252','FC-09740435','EQ-BRL072-1',
     'FC-85278507','FC-58210379','FC-85132069','FC-40001314','EQ-COL080',
     'FC-09419324','FC-9511421','FC-43475014','FC-84471476','FC-45720024',
     'FC-45720031','FC-45720062','FC-45720086','FC-45720093','FC-45720109',
     'FC-00740024','FC-54054221','FC-72300171','FC-19064807'
   )
 order by p.nombre;

