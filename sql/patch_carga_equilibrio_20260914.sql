-- Equilibrio POS · foto 14-sep-2026 · cliente 307513 Palillero.
-- Folio no venía en el recorte: usamos 20260914.
-- Subtotal $3,498.95 · IVA $0.00 · 41 renglones / 112 pzas.
-- Dos capturas = mismo ticket con scroll (Venta al Público / PreEQF).
-- Costo = PreEQF. Lote de fábrica sí. Caducidad NO: Recibir pide MMAA.
-- Fichas desde EQF / DISA / Sufarmed / Farma City, no el código truncado del POS.
-- 27 EANs a alta (stock 0). 13 EANs ya en historial: solo costo, no PVP.
-- Foto TODO (packshot pendiente en catalogo-propia): 40 EANs.
-- SIN bloques dollar-quote. Pegar TODO en Supabase → SQL Editor → Run.

begin;

create temp table _fc_eq20260914 (
  linea integer primary key,
  ean text not null,
  sku text not null,
  nombre text not null,
  snap text not null,
  qty integer not null,
  costo numeric(12,2) not null,
  precio numeric(12,2) not null,
  tipo text not null,
  categoria text not null,
  subcategoria text,
  forma text,
  marca text,
  laboratorio text,
  presentacion text,
  principio_activo text,
  concentracion text,
  receta boolean not null,
  ya boolean not null,
  imagen text,
  foto_file text,
  lote text
) on commit drop;

insert into _fc_eq20260914 (
  linea, ean, sku, nombre, snap, qty, costo, precio, tipo, categoria,
  subcategoria, forma, marca, laboratorio, presentacion, principio_activo,
  concentracion, receta, ya, imagen, foto_file, lote
) values
  (1, '7501075711035', 'EQ-NOV006', 'Debisor sublingual 5 mg C/20 Novag', 'DEBISOR SUBLINGUAL 20 TAB 5 MG', 2, 56.32, 71, 'marca', 'Medicamentos', 'Cardiovascular', 'Tableta sublingual', 'Debisor', 'Novag', 'Caja con 20 tabletas sublinguales', 'Dinitrato de isosorbida', '5 mg', true, false, null, null, '140185'),
  (2, '7501075711011', 'EQ-NOV007', 'Debisor 10 mg C/20 Novag', 'DEBISOR 20 TAB 10 MG', 4, 8.87, 12, 'marca', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Debisor', 'Novag', 'Caja con 20 tabletas', 'Dinitrato de isosorbida', '10 mg', true, false, null, null, '150066'),
  (3, '7502226291871', 'EQ-ALP0120', 'Hidropharm clortalidona 50 mg C/30 Alpharma', 'HIDROPHARM 30 TAB 50 MG', 2, 16.35, 21, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Hidropharm', 'Alpharma', 'Caja con 30 tabletas', 'Clortalidona', '50 mg', true, false, null, null, '2603022'),
  (4, '7501125100123', 'FC-25100123', 'Solución CS Pisa cloruro de sodio 0.9% 500 ml', 'SOLUCION CLORURO DE SODIO 0.9% 500 ML', 1, 52.84, 85, 'generico', 'Medicamentos', 'Soluciones', 'Solución parenteral', 'CS Pisa', 'Pisa', 'Frasco 500 ml', 'Cloruro de sodio', '0.9%', false, false, null, null, 'P26M713'),
  (5, '7501349025929', 'EQ-AMS362', 'Diclofenaco 75 mg/3 ml C/2 ampolletas AMSA', 'DICLOFENACO 2 FA 75MG/3 ML', 2, 16.24, 26, 'generico', 'Medicamentos', 'Dolor', 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 2 ampolletas de 3 ml', 'Diclofenaco sódico', '75 mg/3 ml', true, true, null, null, '26E039'),
  (6, '7502226293776', 'EQ-ALP0628', 'Metamizol sódico 1 g/2 ml C/3 ampolletas', 'METAMIZOL SODICO 3 AMP 1G/2 ML', 2, 19.25, 31, 'generico', 'Medicamentos', 'Dolor', 'Solución inyectable', 'Alpharma', 'Alpharma', 'Caja con 3 ampolletas de 2 ml', 'Metamizol sódico', '1 g/2 ml', true, true, null, null, 'B25T515'),
  (7, '7502009749100', 'EQ-MAV297', 'Orfeox propafenona 150 mg C/20 Maver', 'ORFEOX 20 TAB 150 MG', 5, 36.05, 46, 'marca', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Orfeox', 'Maver', 'Caja con 20 tabletas', 'Propafenona', '150 mg', true, false, null, null, '261633'),
  (8, '7506386100158', 'EQ-LOE173', 'Benvia jarabe infantil dimenhidrinato 120 ml', 'BENVIA 1 JBE 250 MG/100/120 ML', 2, 33.99, 43, 'marca', 'Medicamentos', 'Gastro', 'Jarabe', 'Benvia', 'Loeffler', 'Frasco 120 ml', 'Dimenhidrinato', '250 mg/100 ml', false, false, null, null, 'R2605431'),
  (9, '7501836003140', 'FC-36003140', 'Contraxen carisoprodol/naproxeno 200/250 mg C/30', 'CONTRAXEN 30 CAPS 200/250 MG', 3, 80.23, 101, 'marca', 'Medicamentos', 'Dolor', 'Cápsula', 'Contraxen', 'Liferpal MD', 'Caja con 30 cápsulas', 'Carisoprodol / Naproxeno', '200/250 mg', true, false, null, null, '26E039'),
  (10, '780083148928', 'EQ-COL252', 'Kenzoflex Duo solución oftálmica 5 ml Collins', 'KENZOFLEX DUO 1 SOL', 2, 48.76, 61, 'marca', 'Medicamentos', 'Oftalmología', 'Solución oftálmica', 'Kenzoflex Duo', 'Collins', 'Frasco gotero 5 ml', 'Ciprofloxacino / Dexametasona', '3.5 mg / 1 mg por ml', true, true, null, null, '26340627'),
  (11, '7502009747328', 'FC-09747328', 'Lapriver itoprida 50 mg C/30 Maver', 'ITOPRIDA 30 TAB 50 MG', 3, 60.51, 76, 'marca', 'Medicamentos', 'Gastro', 'Tableta', 'Lapriver', 'Maver', 'Caja con 30 tabletas', 'Itoprida', '50 mg', true, false, null, null, '6FN231C'),
  (12, '7501825301752', 'FC-25301752', 'Biofilen atenolol 100 mg C/28 Degort''s', 'BIOFILEN 28 TAB 100 MG', 3, 49.67, 63, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Biofilen', 'Degort''s', 'Caja con 28 tabletas', 'Atenolol', '100 mg', true, false, null, null, '281AA'),
  (13, '7502009744341', 'FC-09744341', 'Prilver ramipril 5 mg C/16 Maver', 'PRILVER 16 TAB 5 MG', 3, 38.18, 48, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Prilver', 'Maver', 'Caja con 16 tabletas', 'Ramipril', '5 mg', true, false, null, null, '256221'),
  (14, '7502009744891', 'FC-09744891', 'Frinver norfenefrina gotas 24 ml Maver', 'FRINVER 1 GOT 24 ML', 2, 62.56, 79, 'marca', 'Medicamentos', 'Respiratorio', 'Gotas orales', 'Frinver', 'Maver', 'Frasco gotero 24 ml', 'Norfenefrina', '10 mg/ml', false, false, null, null, '264353'),
  (15, '7503004908875', 'EQ-ALP0210', 'Acarbosa 50 mg C/30 Alpharma', 'ACARBOSA 30 TAB 50 MG', 3, 43.74, 70, 'generico', 'Medicamentos', 'Diabetes', 'Tableta', 'Alpharma', 'Alpharma', 'Caja con 30 tabletas', 'Acarbosa', '50 mg', true, false, null, null, 'N2512248'),
  (16, '7501075717860', 'EQ-NOV094', 'Oxivag ácido alendrónico 70 mg C/4 Novag', 'OXIVAG 4 TAB 70 MG', 2, 31.94, 40, 'marca', 'Medicamentos', 'Osteoporosis', 'Tableta', 'Oxivag', 'Novag', 'Caja con 4 tabletas', 'Ácido alendrónico', '70 mg', true, true, null, null, '650136'),
  (17, '7502211780069', 'EQ-LOE020', 'Stomffler Plus suspensión 120 ml Loeffler', 'STOMFFLER PLUS 1 SUSP', 2, 41.72, 53, 'marca', 'Medicamentos', 'Gastro', 'Suspensión oral', 'Stomffler Plus', 'Loeffler', 'Frasco 120 ml', 'Metronidazol / Diyodohidroxiquinoleína', '2.5 g / 2.0 g por 100 ml', true, false, null, null, 'R2604367'),
  (18, '7502211784180', 'FC-11784180', 'Calaffler diclofenaco gotas 15 mg/ml Loeffler', 'CALAFFLER 1 GOT 15 ML', 2, 32.22, 41, 'marca', 'Medicamentos', 'Dolor', 'Gotas orales', 'Calaffler', 'Loeffler', 'Frasco gotero (ticket 15 ml; ficha retail 20 ml)', 'Diclofenaco potásico', '15 mg/ml', true, false, null, null, 'R2503424'),
  (19, '7501349024267', 'EQ-AMS328', 'Ketorolaco 30 mg/1 ml C/3 ampolletas AMSA', 'KETOROLACO 3 AMP 30 MG', 2, 11.34, 19, 'generico', 'Medicamentos', 'Dolor', 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 3 ampolletas de 1 ml', 'Ketorolaco trometamina', '30 mg/1 ml', true, true, null, null, '26F009'),
  (20, '7502009744884', 'EQ-MAV211', 'Odivitor atorvastatina 10 mg C/20 Maver', 'ODIVITOR 20 TAB 10 MG', 5, 22.12, 28, 'marca', 'Medicamentos', 'Cardiovascular', 'Tableta', 'Odivitor', 'Maver', 'Caja con 20 tabletas', 'Atorvastatina', '10 mg', true, false, null, null, '254489'),
  (21, '7502216796348', 'FC-16796348', 'Felodipino LP 5 mg C/20 Ultra', 'FELODIPINO 20 TAB 5 MG', 4, 21.89, 36, 'generico', 'Hipertensión', 'Cardiovascular', 'Tableta liberación prolongada', 'Ultra', 'Ultra', 'Caja con 20 tabletas LP', 'Felodipino', '5 mg', true, false, null, null, '6DN237A'),
  (22, '7501075713862', 'EQ-NOV034', 'Novapres captopril 25 mg C/30 Novag', 'NOVAPRES 30 TAB 25 MG', 5, 9.87, 13, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Novapres', 'Novag', 'Caja con 30 tabletas', 'Captopril', '25 mg', true, false, null, null, '550016'),
  (23, '7502216793439', 'EQ-ULT117', 'Sucralfato 1 g C/40 Ultra', 'SUCRALFATO 40 TAB 1 G', 3, 47.07, 76, 'generico', 'Medicamentos', 'Gastro', 'Tableta', 'Ultra', 'Ultra', 'Caja con 40 tabletas', 'Sucralfato', '1 g', false, false, null, null, '6H445'),
  (24, '785118754204', 'EQ-MAI150', 'Maviglin metformina/glibenclamida 500/5 mg C/60', 'MAVIGLIN 60 TAB 500/5 MG', 3, 62.64, 79, 'marca', 'Medicamentos', 'Diabetes', 'Tableta', 'Maviglin', 'Mavi', 'Caja con 60 tabletas', 'Metformina / Glibenclamida', '500/5 mg', true, true, null, null, '6E0865'),
  (25, '7501825300366', 'EQ-DEG030', 'Espabion gotas pediátricas trimebutina 30 ml', 'ESPABION 1 SUSP 20MG/1ML 30 ML', 1, 25.67, 33, 'marca', 'Medicamentos', 'Gastro', 'Suspensión gotas', 'Espabion', 'Degort''s', 'Frasco 30 ml con gotero', 'Trimebutina', '20 mg/ml', false, true, null, null, '527AA'),
  (26, '7502001162525', 'EQ-SON091', 'Meclison meclizina/piridoxina 25/50 mg C/20 Son''s', 'MECLISON 20 TAB 50/25 MG', 2, 22.06, 28, 'marca', 'Medicamentos', 'Gastro', 'Tableta', 'Meclison', 'Química Son''s', 'Caja con 20 tabletas', 'Meclizina / Piridoxina', '25/50 mg', false, true, null, null, '26051277'),
  (27, '7502006922728', 'EQ-FAC0046', 'Motilaxil picosulfato de sodio solución 120 ml', 'MOTILAXIL 1 SOL 100MG/5/120 ML', 2, 25.04, 32, 'marca', 'Medicamentos', 'Gastro', 'Solución oral', 'Motilaxil', 'Fármacos Continentales', 'Frasco 120 ml', 'Picosulfato de sodio', '5 mg/5 ml', false, true, null, null, 'ITE26L157'),
  (28, '7501825301721', 'FC-25301721', 'Biofilen atenolol 50 mg C/28 Degort''s', 'BIOFILEN 28 TAB 50 MG', 2, 38.18, 48, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Biofilen', 'Degort''s', 'Caja con 28 tabletas', 'Atenolol', '50 mg', true, false, null, null, '512AA'),
  (29, '7501825300373', 'EQ-DEG029', 'Espabion suspensión trimebutina 100 ml Degort''s', 'ESPABION 1 SUSP 100MG/5ML 100 ML', 2, 44.45, 56, 'marca', 'Medicamentos', 'Gastro', 'Suspensión oral', 'Espabion', 'Degort''s', 'Frasco 100 ml', 'Trimebutina', '2 g/100 ml', false, true, null, null, '505AA'),
  (30, '7501075715378', 'FC-75715378', 'Toparal metildopa 250 mg C/30 Novag', 'TOPARAL 30 TAB 250 MG', 4, 40.36, 51, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Toparal', 'Novag', 'Caja con 30 tabletas', 'Metildopa', '250 mg', true, false, null, null, '760175'),
  (31, '7502216803893', 'EQ-AVI026', 'Ketorolaco 10 mg C/10 Avivia', 'KETOROLACO 10 TAB 10 MG', 4, 5.61, 9, 'generico', 'Medicamentos', 'Dolor', 'Tableta', 'Avivia', 'Avivia', 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, false, null, null, '530056'),
  (32, '7502216803893', 'EQ-AVI026', 'Ketorolaco 10 mg C/10 Avivia', 'KETOROLACO 10 TAB 10 MG', 2, 5.61, 9, 'generico', 'Medicamentos', 'Dolor', 'Tableta', 'Avivia', 'Avivia', 'Caja con 10 tabletas', 'Ketorolaco', '10 mg', true, false, null, null, '530175'),
  (33, '7501471889352', 'FC-71889352', 'Vepiltax verapamilo 80 mg C/20 Tecnofarma', 'VEPILTAX 20 TAB 80 MG', 3, 28.79, 36, 'marca', 'Hipertensión', 'Cardiovascular', 'Tableta', 'Vepiltax', 'Tecnofarma', 'Caja con 20 tabletas', 'Verapamilo', '80 mg', true, false, null, null, '441068'),
  (34, '7501573900245', 'EQ-BIO059', 'Wadil metformina/glibenclamida 500/2.5 mg C/30', 'WADIL 30 TAB 500/2.5 MG', 2, 26.53, 34, 'marca', 'Medicamentos', 'Diabetes', 'Tableta', 'Wadil', 'Biomep', 'Caja con 30 tabletas', 'Metformina / Glibenclamida', '500/2.5 mg', true, false, null, null, 'SE2624'),
  (35, '7501349020979', 'FC-49020979', 'Ketoprofeno 100 mg C/15 cápsulas AMSA', 'KETOPROFENO 15 CAPS 100 MG', 1, 35.50, 57, 'generico', 'Medicamentos', 'Dolor', 'Cápsula', 'AMSA', 'AMSA', 'Caja con 15 cápsulas', 'Ketoprofeno', '100 mg', true, false, null, null, 'U26M109'),
  (36, '7502001162518', 'EQ-SON092', 'Meclison gotas 15 ml Son''s', 'MECLISON 1 GOT 16.66/8.33 MG/15 ML', 3, 21.01, 27, 'marca', 'Medicamentos', 'Gastro', 'Gotas orales', 'Meclison', 'Química Son''s', 'Frasco gotero 15 ml', 'Meclizina / Piridoxina', '8.33/16.66 mg por ml', false, true, null, null, '26051373'),
  (37, '7502009740176', 'EQ-MAV028', 'Dolxen naproxeno 250 mg C/20 Maver', 'DOLXEN 20 TAB 250 MG', 2, 17.14, 22, 'marca', 'Medicamentos', 'Dolor', 'Tableta', 'Dolxen', 'Maver', 'Caja con 20 tabletas', 'Naproxeno', '250 mg', false, false, null, null, '261858'),
  (38, '7502227425039', 'EQ-GEP019', 'Nifedipino / Gelprim 10 mg C/20 Gelpharma', 'NIFEDIPINO 20 CAPS 10 MG', 4, 21.80, 35, 'generico', 'Hipertensión', 'Cardiovascular', 'Cápsula', 'Gelprim', 'Gelpharma', 'Caja con 20 cápsulas', 'Nifedipino', '10 mg', true, false, null, null, '260717'),
  (39, '7501299309278', 'EQ-LIO148', 'Tusigen NF ambroxol/dextrometorfano C/20 Liomont', 'TUSIGEN NF 20 TAB 22.5/22.5 MG', 3, 59.60, 75, 'marca', 'Medicamentos', 'Respiratorio', 'Tableta', 'Tusigen NF', 'Liomont', 'Caja con 20 tabletas', 'Ambroxol / Dextrometorfano', '22.5/22.5 mg', false, false, null, null, '005189'),
  (40, '7501349023369', 'EQ-AMS160', 'Ketorolaco sublingual 30 mg C/6 AMSA', 'KETOROLACO TROMETAMINA 6 TAB SL 30 MG', 6, 5.81, 10, 'generico', 'Medicamentos', 'Dolor', 'Tableta sublingual', 'AMSA', 'AMSA', 'Caja con 6 tabletas sublinguales', 'Ketorolaco trometamina', '30 mg', true, true, null, null, 'U26J016'),
  (41, '7501349024151', 'EQ-AMS418', 'Metoclopramida 10 mg/2 ml C/6 ampolletas AMSA', 'METOCLOPRAMIDA 6 AMP 10MG/2 ML', 2, 21.02, 34, 'generico', 'Medicamentos', 'Gastro', 'Solución inyectable', 'AMSA', 'AMSA', 'Caja con 6 ampolletas de 2 ml', 'Metoclopramida', '10 mg/2 ml', true, true, null, null, '26M507');

-- Una fila por EAN para el catálogo (Ketorolaco 10 mg va dos lotes).
insert into public.productos (
  nombre, sku, codigo_barras, categoria, subcategoria, tipo, descripcion,
  costo, precio, stock, stock_minimo, activo, requiere_receta,
  marca, presentacion, forma_farmaceutica, principio_activo, concentracion,
  laboratorio, imagen_url, imagen_mobile_url
)
select
  t.nombre,
  case
    when exists (
      select 1 from public.productos p
      where p.sku = t.sku and coalesce(p.codigo_barras, '') <> t.ean
    ) then 'EQ-' || t.ean
    else t.sku
  end,
  t.ean,
  t.categoria,
  t.subcategoria,
  t.tipo,
  'Alta Equilibrio 20260914 · foto ticket · listo para pistola',
  t.costo,
  t.precio,
  0,
  1,
  true,
  t.receta,
  t.marca,
  t.presentacion,
  t.forma,
  t.principio_activo,
  t.concentracion,
  t.laboratorio,
  t.imagen,
  t.imagen
from (
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
where public.fc_buscar_producto_escaneo(t.ean) is null
  and public.fc_buscar_producto_escaneo(t.sku) is null;

-- Ya existía: costo de este ticket. PVP solo si está en 0. No pisa foto buena.
update public.productos p
set
  costo = t.costo,
  precio = case
    when coalesce(p.precio, 0) <= 0 then t.precio
    else p.precio
  end,
  marca = coalesce(nullif(trim(p.marca), ''), t.marca),
  presentacion = coalesce(nullif(trim(p.presentacion), ''), t.presentacion),
  principio_activo = coalesce(nullif(trim(p.principio_activo), ''), t.principio_activo),
  concentracion = coalesce(nullif(trim(p.concentracion), ''), t.concentracion),
  laboratorio = coalesce(nullif(trim(p.laboratorio), ''), t.laboratorio),
  subcategoria = coalesce(nullif(trim(p.subcategoria), ''), t.subcategoria),
  forma_farmaceutica = coalesce(nullif(trim(p.forma_farmaceutica), ''), t.forma),
  imagen_url = coalesce(nullif(trim(p.imagen_url), ''), t.imagen),
  imagen_mobile_url = coalesce(nullif(trim(p.imagen_mobile_url), ''), t.imagen),
  codigo_barras = coalesce(nullif(trim(p.codigo_barras), ''), t.ean)
from (
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
where p.id = coalesce(
  public.fc_buscar_producto_escaneo(t.ean),
  public.fc_buscar_producto_escaneo(t.sku)
);

insert into public.producto_imagenes (producto_id, url, storage_path, posicion, es_principal, origen)
select
  v.pid,
  t.imagen,
  t.foto_file,
  0,
  true,
  'distribuidor'
from (
  select distinct on (ean) *
  from _fc_eq20260914
  order by ean, linea
) t
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
where t.imagen is not null
  and v.pid is not null
  and not exists (
    select 1 from public.producto_imagenes x
    where x.producto_id = v.pid and x.url = t.imagen
  );

insert into public.recepciones (proveedor, folio, fecha, total_ticket, estado, notas)
select
  'Equilibrio',
  '20260914',
  '2026-09-14',
  3498.95,
  'borrador',
  'Ticket Equilibrio POS · cliente 307513 Palillero · foto 14-sep-2026 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja · Calaffler R2503424 salía en rojo en el POS'
where not exists (
  select 1 from public.recepciones
  where folio = '20260914' and coalesce(proveedor, '') ilike '%equilibrio%'
);

update public.recepciones
set
  total_ticket = 3498.95,
  fecha = '2026-09-14',
  proveedor = 'Equilibrio',
  notas = 'Ticket Equilibrio POS · cliente 307513 Palillero · foto 14-sep-2026 · cola Recibir; stock al confirmar pistola · lote de fábrica en el papel; MMAA de la caja · Calaffler R2503424 salía en rojo en el POS'
where folio = '20260914'
  and coalesce(proveedor, '') ilike '%equilibrio%'
  and estado = 'borrador';

delete from public.recepcion_items i
using public.recepciones r
where i.recepcion_id = r.id
  and r.folio = '20260914'
  and coalesce(r.proveedor, '') ilike '%equilibrio%'
  and r.estado = 'borrador';

insert into public.recepcion_items (
  recepcion_id, producto_id, codigo_escaneado, nombre_snapshot,
  cantidad, fecha_caducidad, numero_lote, costo_estimado, pendiente_alta,
  origen, confirmado, lote_distinto, lote_id
)
select
  r.id,
  v.pid,
  t.ean,
  t.nombre,
  t.qty,
  null,
  t.lote,
  t.costo,
  (v.pid is null),
  'pdf',
  false,
  (
    v.pid is not null and exists (
      select 1 from public.lotes l
      where l.producto_id = v.pid
        and coalesce(l.activo, true)
        and coalesce(l.cantidad_actual, 0) > 0
        and l.numero_lote is distinct from t.lote
    )
  ),
  null
from _fc_eq20260914 t
join public.recepciones r
  on r.folio = '20260914'
 and coalesce(r.proveedor, '') ilike '%equilibrio%'
 and r.estado = 'borrador'
left join lateral (
  select coalesce(
    public.fc_buscar_producto_escaneo(t.ean),
    public.fc_buscar_producto_escaneo(t.sku)
  ) as pid
) v on true
order by t.linea;

commit;

select
  i.id,
  i.codigo_escaneado as ean,
  left(i.nombre_snapshot, 52) as nombre,
  i.cantidad,
  i.costo_estimado,
  i.numero_lote,
  case when i.pendiente_alta then 'ALTA NUEVA' else 'YA EXISTE' end as estado
from public.recepcion_items i
join public.recepciones r on r.id = i.recepcion_id
where r.folio = '20260914' and coalesce(r.proveedor, '') ilike '%equilibrio%'
order by i.id;

select
  p.sku,
  p.codigo_barras as ean,
  left(p.nombre, 52) as nombre,
  p.marca,
  p.presentacion,
  p.costo,
  p.precio,
  p.stock,
  left(coalesce(p.imagen_url, ''), 56) as foto
from public.productos p
where p.codigo_barras in (
  '7501075711035',
  '7501075711011',
  '7502226291871',
  '7501125100123',
  '7501349025929',
  '7502226293776',
  '7502009749100',
  '7506386100158',
  '7501836003140',
  '780083148928',
  '7502009747328',
  '7501825301752',
  '7502009744341',
  '7502009744891',
  '7503004908875',
  '7501075717860',
  '7502211780069',
  '7502211784180',
  '7501349024267',
  '7502009744884',
  '7502216796348',
  '7501075713862',
  '7502216793439',
  '785118754204',
  '7501825300366',
  '7502001162525',
  '7502006922728',
  '7501825301721',
  '7501825300373',
  '7501075715378',
  '7502216803893',
  '7501471889352',
  '7501573900245',
  '7501349020979',
  '7502001162518',
  '7502009740176',
  '7502227425039',
  '7501299309278',
  '7501349023369',
  '7501349024151'
)
order by p.nombre;
