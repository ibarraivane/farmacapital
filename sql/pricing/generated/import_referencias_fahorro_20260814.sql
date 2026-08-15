-- Import referencias fahorro — 46 filas
-- Archivo: import_fahorro_listo.csv

begin;

with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('fahorro', 'venta', '2026-08-14', 'import_fahorro_listo.csv', 46, 'importar_referencias_precio.py')
  returning id
)
insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, nombre_fuente, confianza, origen, import_id
)
select
  v.producto_id,
  'fahorro',
  'venta',
  v.precio,
  '2026-08-14'::date,
  v.nombre_fuente,
  v.confianza,
  'import_csv',
  imp.id
from imp, (values
  (439::bigint, 125.0::numeric, 'Vicks Vaporub ungüento 50G', 100::smallint),
  (444::bigint, 113.0::numeric, 'Afrin Dtc (Rojo) 20', 100::smallint),
  (487::bigint, 43.0::numeric, 'Aspirina', 100::smallint),
  (311::bigint, 79.0::numeric, 'Pasta Dent Sensodyne Original', 100::smallint),
  (75::bigint, 55.0::numeric, 'Amikacina', 100::smallint),
  (32::bigint, 253.0::numeric, 'Cefalexina', 100::smallint),
  (181::bigint, 30.0::numeric, 'Jabon Grisi Neutro', 100::smallint),
  (186::bigint, 32.5::numeric, 'Jabon Grisi Avena', 100::smallint),
  (401::bigint, 25.0::numeric, 'Electrolit Coco', 100::smallint),
  (402::bigint, 25.0::numeric, 'Electrolit Eresa-Kiwi', 100::smallint),
  (322::bigint, 97.0::numeric, 'Enjuague Buc Listerine Cuidado Total', 100::smallint),
  (391::bigint, 34.5::numeric, 'Pedialyte', 100::smallint),
  (123::bigint, 261.0::numeric, 'Ceftazidima', 100::smallint),
  (103::bigint, 282.0::numeric, 'Amlodipino', 100::smallint),
  (91::bigint, 77.0::numeric, 'Cinarizina', 100::smallint),
  (57::bigint, 432.0::numeric, 'Ursodesoxicolico', 100::smallint),
  (41::bigint, 236.0::numeric, 'Claritromicina', 100::smallint),
  (400::bigint, 25.0::numeric, 'Electrolit Uva', 100::smallint),
  (152::bigint, 102.0::numeric, 'Enalapril', 100::smallint),
  (144::bigint, 67.0::numeric, 'Fluconazol', 100::smallint),
  (21::bigint, 45.5::numeric, 'Gentamicina', 100::smallint),
  (482::bigint, 199.0::numeric, 'Centrum', 100::smallint),
  (65::bigint, 143.0::numeric, 'Clamoxin', 100::smallint),
  (30::bigint, 239.0::numeric, 'Ciprofloxacino', 100::smallint),
  (466::bigint, 118.0::numeric, 'Tylenol', 100::smallint),
  (53::bigint, 32.5::numeric, 'Acetilsalicilico', 100::smallint),
  (50::bigint, 85.0::numeric, 'Ampicilina', 100::smallint),
  (101::bigint, 58.0::numeric, 'Captopril', 100::smallint),
  (498::bigint, 227.0::numeric, 'Flanax', 100::smallint),
  (106::bigint, 80.0::numeric, 'Carbamazepina', 100::smallint),
  (7::bigint, 135.0::numeric, 'Clindamicina', 100::smallint),
  (145::bigint, 423.0::numeric, 'Hialuronato De Sodio 4Mg', 100::smallint),
  (4::bigint, 133.0::numeric, 'Alopurinol', 100::smallint),
  (161::bigint, 400.0::numeric, 'Irbesartan', 100::smallint),
  (15::bigint, 366.0::numeric, 'Bisoprolol', 100::smallint),
  (2::bigint, 158.0::numeric, 'Levofloxacino', 100::smallint),
  (67::bigint, 151.0::numeric, 'Acemetacina', 100::smallint),
  (58::bigint, 143.0::numeric, 'Valclan', 100::smallint),
  (40::bigint, 212.0::numeric, 'Azitromicina', 100::smallint),
  (114::bigint, 87.0::numeric, 'Bactiver', 100::smallint),
  (127::bigint, 217.0::numeric, 'Atorvastatina', 100::smallint),
  (18::bigint, 266.0::numeric, 'Fasiclor', 100::smallint),
  (92::bigint, 457.0::numeric, 'Celecoxib', 100::smallint),
  (158::bigint, 364.0::numeric, 'Diosmina Hesperidina', 100::smallint),
  (71::bigint, 102.0::numeric, 'Amoxicilina', 100::smallint),
  (73::bigint, 334.0::numeric, 'Aciclovir', 100::smallint)
) as v(producto_id, precio, nombre_fuente, confianza)
where v.producto_id is not null;

commit;
