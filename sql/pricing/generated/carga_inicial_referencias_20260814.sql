-- Carga inicial referencias de precio — FarmaCapital
-- Generado 2026-08-14 — fahorro 46, exprezo 32, similares 9
-- Ejecutar en Supabase SQL Editor (una sola vez)

BEGIN;

-- Permisos de secuencia (fix import UI/REST con anon key)
GRANT USAGE, SELECT ON SEQUENCE public.importaciones_referencia_id_seq TO anon, authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.producto_precios_referencia_id_seq TO anon, authenticated;

-- Migrar columnas legacy si aún tienen datos
-- Migración one-shot: columnas legacy → producto_precios_referencia
-- Ejecutar DESPUÉS de patch_producto_precios_referencia.sql
-- Idempotente: no duplica si ya migró (busca origen manual previo)


-- Similares
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, notas
)
SELECT
  p.id,
  'similares',
  'venta',
  p.precio_similares,
  COALESCE(p.fecha_actualizacion_precios, CURRENT_DATE),
  'manual',
  'Migrado desde productos.precio_similares'
FROM public.productos p
WHERE p.precio_similares IS NOT NULL
  AND p.precio_similares > 0
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r
    WHERE r.producto_id = p.id
      AND r.fuente = 'similares'
      AND r.origen = 'manual'
      AND r.notas = 'Migrado desde productos.precio_similares'
  );

-- Del Ahorro
INSERT INTO public.producto_precios_referencia (
  producto_id, fuente, tipo, precio, fecha, origen, notas
)
SELECT
  p.id,
  'fahorro',
  'venta',
  p.precio_del_ahorro,
  COALESCE(p.fecha_actualizacion_precios, CURRENT_DATE),
  'manual',
  'Migrado desde productos.precio_del_ahorro'
FROM public.productos p
WHERE p.precio_del_ahorro IS NOT NULL
  AND p.precio_del_ahorro > 0
  AND NOT EXISTS (
    SELECT 1 FROM public.producto_precios_referencia r
    WHERE r.producto_id = p.id
      AND r.fuente = 'fahorro'
      AND r.origen = 'manual'
      AND r.notas = 'Migrado desde productos.precio_del_ahorro'
  );


-- FAHORRO (46 SKUs)
WITH imp AS (
  INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  VALUES ('fahorro', 'venta', '2026-08-14', 'import_fahorro_listo.csv', 46, 'Claude capturas FDA')
  RETURNING id
)
INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza)
SELECT p.id, 'fahorro', 'venta', v.precio, '2026-08-14'::date, 'import_csv', imp.id, v.confianza
FROM imp, (VALUES
  ('FC-02012468', 125.0::numeric, 85::smallint),
  ('FC-06134531', 113.0::numeric, 85::smallint),
  ('FC-08895196', 43.0::numeric, 85::smallint),
  ('FC-09419324', 79.0::numeric, 85::smallint),
  ('FC-11294615', 55.0::numeric, 85::smallint),
  ('FC-2005DD57', 253.0::numeric, 85::smallint),
  ('FC-22105207', 30.0::numeric, 85::smallint),
  ('FC-22150801', 32.5::numeric, 85::smallint),
  ('FC-25104411', 25.0::numeric, 85::smallint),
  ('FC-25149221', 25.0::numeric, 85::smallint),
  ('FC-31887928', 97.0::numeric, 85::smallint),
  ('FC-33954740', 34.5::numeric, 85::smallint),
  ('FC-357D4A17', 261.0::numeric, 85::smallint),
  ('FC-3B001F9B', 282.0::numeric, 85::smallint),
  ('FC-3CAA7C5C', 77.0::numeric, 85::smallint),
  ('FC-405A75E3', 432.0::numeric, 85::smallint),
  ('FC-41339950', 236.0::numeric, 85::smallint),
  ('FC-51448511', 25.0::numeric, 85::smallint),
  ('FC-53506FA4', 102.0::numeric, 85::smallint),
  ('FC-5BC5F234', 67.0::numeric, 85::smallint),
  ('FC-60F627D5', 45.5::numeric, 85::smallint),
  ('FC-65095718', 199.0::numeric, 85::smallint),
  ('FC-6519183A', 143.0::numeric, 85::smallint),
  ('FC-74A5ABEE', 239.0::numeric, 85::smallint),
  ('FC-75354321', 118.0::numeric, 85::smallint),
  ('FC-7D1D9857', 32.5::numeric, 85::smallint),
  ('FC-7F90064A', 85.0::numeric, 85::smallint),
  ('FC-82F88FED', 58.0::numeric, 85::smallint),
  ('FC-84973401', 227.0::numeric, 85::smallint),
  ('FC-885F2723', 80.0::numeric, 85::smallint),
  ('FC-9A4E4C31', 135.0::numeric, 85::smallint),
  ('FC-A2B284E0', 423.0::numeric, 85::smallint),
  ('FC-ACA2A2F6', 133.0::numeric, 85::smallint),
  ('FC-BDB2E087', 400.0::numeric, 85::smallint),
  ('FC-C101D5B1', 366.0::numeric, 85::smallint),
  ('FC-C721E8D7', 158.0::numeric, 85::smallint),
  ('FC-C9F4ACCC', 151.0::numeric, 85::smallint),
  ('FC-D06E54FE', 143.0::numeric, 85::smallint),
  ('FC-D9391288', 212.0::numeric, 85::smallint),
  ('FC-DEAF33B0', 87.0::numeric, 85::smallint),
  ('FC-E4BE37BE', 217.0::numeric, 85::smallint),
  ('FC-E4EFC4C2', 266.0::numeric, 85::smallint),
  ('FC-E6B50AC3', 457.0::numeric, 85::smallint),
  ('FC-EADF1484', 364.0::numeric, 85::smallint),
  ('FC-F4E9C71F', 102.0::numeric, 85::smallint),
  ('FC-FD845E68', 334.0::numeric, 85::smallint)
) AS v(sku, precio, confianza)
JOIN public.productos p ON p.sku = v.sku AND p.activo = true;

-- EXPREZO (32 SKUs)
WITH imp AS (
  INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  VALUES ('exprezo', 'compra', '2026-08-14', 'import_exprezo_listo.csv', 32, 'Claude + lista Exprezo')
  RETURNING id
)
INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza)
SELECT p.id, 'exprezo', 'compra', v.precio, '2026-08-14'::date, 'import_csv', imp.id, v.confianza
FROM imp, (VALUES
  ('FC-01157296', 12.95::numeric, 85::smallint),
  ('FC-01405335', 21.25::numeric, 85::smallint),
  ('FC-06257597', 71.49::numeric, 85::smallint),
  ('FC-07528939', 38.99::numeric, 85::smallint),
  ('FC-08443026', 267.68::numeric, 85::smallint),
  ('FC-08485316', 70.6::numeric, 85::smallint),
  ('FC-14982514', 33.5::numeric, 85::smallint),
  ('FC-19006371', 16.84::numeric, 85::smallint),
  ('FC-19006623', 20.11::numeric, 85::smallint),
  ('FC-22150221', 21.94::numeric, 85::smallint),
  ('FC-25104411', 19.17::numeric, 85::smallint),
  ('FC-25149221', 19.17::numeric, 85::smallint),
  ('FC-31244486', 38.99::numeric, 85::smallint),
  ('FC-35469151', 42.49::numeric, 85::smallint),
  ('FC-36033735', 69.73::numeric, 85::smallint),
  ('FC-40013898', 34.66::numeric, 85::smallint),
  ('FC-46073040', 15.53::numeric, 85::smallint),
  ('FC-48335305', 15.95::numeric, 85::smallint),
  ('FC-51448511', 19.17::numeric, 85::smallint),
  ('FC-56330309', 79.19::numeric, 85::smallint),
  ('FC-60009851', 24.94::numeric, 85::smallint),
  ('FC-60403681', 72.37::numeric, 85::smallint),
  ('FC-60689091', 16.96::numeric, 85::smallint),
  ('FC-66534951', 20.58::numeric, 85::smallint),
  ('FC-68901131', 36.9::numeric, 85::smallint),
  ('FC-70612368', 142.24::numeric, 85::smallint),
  ('FC-73629981', 31.73::numeric, 85::smallint),
  ('FC-83351381', 13.2::numeric, 85::smallint),
  ('FC-83510531', 13.0::numeric, 85::smallint),
  ('FC-92506601', 18.84::numeric, 85::smallint),
  ('FC-95451096', 156.0::numeric, 85::smallint),
  ('FC-DE106642', 18.21::numeric, 85::smallint)
) AS v(sku, precio, confianza)
JOIN public.productos p ON p.sku = v.sku AND p.activo = true;

-- SIMILARES (9 SKUs)
WITH imp AS (
  INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
  VALUES ('similares', 'venta', '2026-08-14', 'import_similares_lote1_listo.csv', 9, 'Claude lote1 Similares')
  RETURNING id
)
INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, import_id, confianza, notas)
SELECT p.id, 'similares', 'venta', v.precio, '2026-08-14'::date, 'import_csv', imp.id, v.confianza, v.notas
FROM imp, (VALUES
  ('FC-08496701', 36.38::numeric, 85::smallint, 'ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA -- coincidencia exacta de marca, mg y cantidad.'),
  ('FC-48F732CF', 46.5::numeric, 60::smallint, 'Similares solo tiene ERITROMICINA 500MG en TABLETAS (20), tu presentacion original es CAPSULAS (EPICIN 20 CAPS 500 MG). Misma mg y cantidad pero forma farmaceutica distinta.'),
  ('FC-516C2E89', 48.0::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 400/57 SUSPENSION 50-60 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H JR 1 SUSP 400/57MG/5/50ML).'),
  ('FC-54521161', 6.0::numeric, 75::smallint, 'Tempra 500mg C/10 no esta como marca en Similares; se usa el generico PARACETAMOL 500 MG 10 TABLETAS (PICK UP), misma concentracion y cantidad exacta.'),
  ('FC-5D9DFA3D', 59.25::numeric, 75::smallint, 'Norquinol = marca de Norfloxacino. Match generico: NORFLOXACINO 400 MG 20 TABLETAS, misma concentracion y cantidad.'),
  ('FC-8FB65B79', 124.5::numeric, 60::smallint, 'CLARITROMICINA 250MG/5ML SUSPENSION -- el catalogo no especifica volumen del frasco (dice ''1 pieza''), no se puede confirmar si son los 60ml de tu presentacion.'),
  ('FC-A0D320D1', 29.25::numeric, 85::smallint, 'AMOXICILINA 500 MG 12 CAPSULAS -- coincidencia exacta.'),
  ('FC-CF18C740', 90.0::numeric, 85::smallint, 'CLINDAMICINA 300 MG 16 CAPSULAS -- coincidencia exacta.'),
  ('FC-DDFBABDF', 24.75::numeric, 85::smallint, 'AMOXICILINA/ACIDO CLAVULANICO 200/28.5MG SUSPENSION 40 O 50 ML -- coincide concentracion exacta (recuperada del inventario original: CLAMOXIN 12H PED 1 SUSP 200/28.5MG/40ML).')
) AS v(sku, precio, confianza, notas)
JOIN public.productos p ON p.sku = v.sku AND p.activo = true;

COMMIT;
