-- Similares lote1 Claude: 9 productos — 2026-08-14
begin;
with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('similares', 'venta', '2026-08-14', 'referencias_venta_lote1_20260815.csv', 9, 'Claude lote1 Chrome')
  returning id
)
insert into public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas)
select p.id, 'similares', 'venta', v.precio, '2026-08-14'::date, 'import_csv', imp.id, v.confianza, v.notas
from imp, (values
  ('FC-5D9DFA3D', 59.25::numeric, 75::smallint, 'Norquinol = marca de Norfloxacino. Match generico: NORFLOXACINO 400 MG 20 TABLETAS, misma concentracion y cantidad.'),
  ('FC-DDFBABDF', 24.75::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 200/28.5MG SUSPENSION 40 O 50 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40ML).'),
  ('FC-A0D320D1', 29.25::numeric, 85::smallint, 'AMOXICILINA 500 MG 12 CAPSULAS -- coincidencia exacta.'),
  ('FC-CF18C740', 90.0::numeric, 85::smallint, 'CLINDAMICINA 300 MG 16 CAPSULAS -- coincidencia exacta.'),
  ('FC-48F732CF', 46.5::numeric, 60::smallint, 'Similares solo tiene ERITROMICINA 500MG en TABLETAS (20), tu presentacion original es CAPSULAS (EPICIN 20 CAPS 500 MG). Misma mg y cantidad pero forma farmaceutica distinta.'),
  ('FC-8FB65B79', 124.5::numeric, 60::smallint, 'CLARITROMICINA 250MG/5ML SUSPENSION -- el catalogo no especifica volumen del frasco (dice ''1 pieza''), no se puede confirmar si son los 60ml de tu presentacion.'),
  ('FC-08496701', 36.38::numeric, 85::smallint, 'ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA -- coincidencia exacta de marca, mg y cantidad.'),
  ('FC-54521161', 6.0::numeric, 75::smallint, 'Tempra 500mg C/10 no esta como marca en Similares; se usa el generico PARACETAMOL 500 MG 10 TABLETAS (PICK UP), misma concentracion y cantidad exacta.'),
  ('FC-516C2E89', 48.0::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 400/57 SUSPENSION 50-60 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50ML).')
) as v(sku, precio, confianza, notas)
join public.productos p on p.sku = v.sku and p.activo = true;

commit;