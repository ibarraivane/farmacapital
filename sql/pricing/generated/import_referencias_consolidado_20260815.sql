-- Import referencias consolidado — 29 filas
-- Archivo: referencias_venta_consolidado_20260815_2.csv
-- Requiere fuentes otros_* (incluido abajo si falta en Supabase)

begin;

insert into public.fuentes_precio (id, nombre, tipo, metodo, notas) values
  ('otros_compra', 'Otros (compra)', 'compra', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)'),
  ('otros_venta', 'Otros (venta)', 'venta', 'manual', 'Promedio de mercado o consulta manual (Claude, Google, etc.)')
on conflict (id) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  metodo = excluded.metodo,
  notas = excluded.notas;

-- ── otros_venta (12 filas) ──
with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('otros_venta', 'venta', '2026-08-15', 'referencias_venta_consolidado_20260815_2.csv', 12, 'importar_referencias_precio.py')
  returning id
)
insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas
)
select
  p.id,
  'otros_venta',
  'venta',
  v.precio,
  '2026-08-15'::date,
  'import_csv',
  imp.id,
  v.confianza,
  v.notas
from imp, (values
  ('FC-F82A6E4B', 67.0::numeric, 75::smallint, 'Vitau.mx - Ampicilina genérica 1g 10 tabletas'),
  ('FC-E9C38DC4', 65.43::numeric, 75::smallint, 'Vitau.mx - Ciprofloxacino genérico 500mg 14 tabletas'),
  ('FC-7AF7ACB5', 65.43::numeric, 60::smallint, 'Basado en precio Ciprofloxacino 500mg genérico; presentación de 3 tab no encontrada'),
  ('FC-50959781', 150.0::numeric, 75::smallint, 'Farmacias referencia - Centrum Multivitamínico 30 tabletas (verificar en Fahorro/Walmart)'),
  ('FC-84999001', 260.0::numeric, 75::smallint, 'Farmacias San Isidro - Alka-Seltzer Boost 50 tabletas efervescentes'),
  ('FC-08491074', 97.89::numeric, 75::smallint, 'Vitau.mx - Aspirina 500mg genérica 40 tabletas (tu presentación es 80)'),
  ('FC-33954078', 66.0::numeric, 75::smallint, 'Vitau.mx - Ensure Advance 237ml (referencia)'),
  ('FC-33950070', 66.0::numeric, 75::smallint, 'Vitau.mx - Ensure Advance 237ml (referencia similar)'),
  ('FC-33956126', 75.0::numeric, 60::smallint, 'Estimado basado en Ensure; Glucerna agotado en mayoría de farmacias'),
  ('FC-33956133', 75.0::numeric, 60::smallint, 'Estimado; Glucerna agotado'),
  ('FC-33956140', 75.0::numeric, 60::smallint, 'Estimado; Glucerna agotado'),
  ('FC-51747971', 26.5::numeric, 75::smallint, 'Farmatodo.com.mx - Electrolit suero oral 625ml')
) as v(sku, precio, confianza, notas)
join public.productos p on p.sku = v.sku and p.activo = true
where v.sku is not null;

-- ── similares (17 filas) ──
with imp as (
  insert into public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  values ('similares', 'venta', '2026-08-15', 'referencias_venta_consolidado_20260815_2.csv', 17, 'importar_referencias_precio.py')
  returning id
)
insert into public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas
)
select
  p.id,
  'similares',
  'venta',
  v.precio,
  '2026-08-15'::date,
  'import_csv',
  imp.id,
  v.confianza,
  v.notas
from imp, (values
  ('FC-5D9DFA3D', 59.25::numeric, 75::smallint, 'Norquinol = marca de Norfloxacino. Match generico: NORFLOXACINO 400 MG 20 TABLETAS, misma concentracion y cantidad.'),
  ('FC-DDFBABDF', 24.75::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 200/28.5MG SUSPENSION 40 O 50 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40ML).'),
  ('FC-A0D320D1', 29.25::numeric, 85::smallint, 'AMOXICILINA 500 MG 12 CAPSULAS -- coincidencia exacta.'),
  ('FC-CF18C740', 90.0::numeric, 85::smallint, 'CLINDAMICINA 300 MG 16 CAPSULAS -- coincidencia exacta.'),
  ('FC-48F732CF', 46.5::numeric, 60::smallint, 'Similares solo tiene ERITROMICINA 500MG en TABLETAS (20), tu presentacion original es CAPSULAS (EPICIN 20 CAPS 500 MG). Misma mg y cantidad pero forma farmaceutica distinta.'),
  ('FC-8FB65B79', 124.5::numeric, 60::smallint, 'CLARITROMICINA 250MG/5ML SUSPENSION -- el catalogo no especifica volumen del frasco (dice ''1 pieza''), no se puede confirmar si son los 60ml de tu presentacion.'),
  ('FC-08496701', 36.38::numeric, 85::smallint, 'ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA -- coincidencia exacta de marca, mg y cantidad.'),
  ('FC-54521161', 6.0::numeric, 75::smallint, 'Tempra 500mg C/10 no esta como marca en Similares; se usa el generico PARACETAMOL 500 MG 10 TABLETAS (PICK UP), misma concentracion y cantidad exacta.'),
  ('FC-516C2E89', 48.0::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 400/57 SUSPENSION 50-60 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50ML).'),
  ('FC-08498798', 25.5::numeric, 75::smallint, 'Match generico: DEXPANTENOL 5/100GR CREMA 30GR SIMIBABY (equivalente generico de Bepanthen Multiusos Pomada, misma concentracion 5% y mismo tamano 30g)'),
  ('FC-66055303', 37.5::numeric, 75::smallint, 'Match generico: PRUEBA DE EMBARAZO ANALOGA (PICK UP), equivalente generico de prueba Meditest, presentacion C/1 pieza asumida equivalente'),
  ('FC-1DA570E3', 18.75::numeric, 85::smallint, 'Confirmado por fuente externa que Cloxan = Ambroxol 30mg; match exacto AMBROXOL 30 MG 20 COMPRIMIDOS, misma cantidad de piezas (20)'),
  ('FC-33950100', 38.62::numeric, 60::smallint, 'No se encontro marca Ensure; Similares maneja varias ''DIETA POLIMERICA'' sabor chocolate 236ML genericas (sin fibra $38.62, con fibra $39.75, hipercalorica $42.00); se reporta la variante sin fibra estandar como la mas cercana a Ensure regular, pero existe ambiguedad real sobre cual formulacion corresponde'),
  ('FC-6C2878CF', 110.25::numeric, 75::smallint, 'Interpretando ''125 Mg/Ml'' como 0.125 mg/ml (formato comun de captura sin punto decimal), coincide con BUDESONIDA SUSPENSION 0.250MG/2ML O 0.125MG/ML PARA NEBULIZACION 5 AMPOLLETAS, mismo numero de ampolletas (5)'),
  ('FC-70612368', 43.5::numeric, 75::smallint, 'Match generico: NEOMICINA / CAOLIN / PECTINA 20 TABLETAS, equivalente generico de Treda (confirmado por fuentes externas que Treda = neomicina/caolin/pectina), misma cantidad C/20'),
  ('FC-43454811', 35.26::numeric, 75::smallint, 'Match generico: toallitas humedas para bebe SIMIBABY 80 piezas, equivalente generico de Huggies Toallitas Cuidado Puro, misma cantidad C/80'),
  ('FC-45079011', 59.25::numeric, 85::smallint, 'Match exacto de marca: BALSAMO LABIAL LABELLO 1 PIEZA')
) as v(sku, precio, confianza, notas)
join public.productos p on p.sku = v.sku and p.activo = true
where v.sku is not null;

commit;
