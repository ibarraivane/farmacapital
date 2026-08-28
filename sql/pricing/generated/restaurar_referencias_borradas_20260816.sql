-- Restaurar referencias de venta borradas el 15-ago (limpieza no comparables).
-- 326 inserts. NO borra ni pisa filas existentes.
-- Ejecutar en Supabase SQL Editor si no usas --apply.

BEGIN;

INSERT INTO public.importaciones_referencia (fuente, tipo, fecha_lista, archivo, filas_ok, notas)
VALUES ('similares', 'venta', '2026-08-16', 'restaurar_referencias_borradas_20260816', 326,
        'restauracion backup UI + imports Claude/Excel/Fahorro. insert only');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 114, 'fahorro', 'venta', 87.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 114 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 439, 'fahorro', 'venta', 125.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 439 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 438, 'fahorro', 'venta', 175.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Vicks Vaporub ungüento 100g'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 438 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 444, 'fahorro', 'venta', 113.00, '2026-08-16'::date, 'import_csv', 90, 'Restaurado import_fahorro_listo.csv'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 444 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 484, 'fahorro', 'venta', 43.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 484 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 487, 'fahorro', 'venta', 43.00, '2026-08-16'::date, 'import_csv', 90, 'Restaurado import_fahorro_listo.csv'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 487 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 547, 'fahorro', 'venta', 43.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 547 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 311, 'fahorro', 'venta', 79.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 311 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 75, 'fahorro', 'venta', 55.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 75 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 76, 'fahorro', 'venta', 55.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 76 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 32, 'fahorro', 'venta', 253.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 32 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 181, 'fahorro', 'venta', 30.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 181 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 186, 'fahorro', 'venta', 32.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 186 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 401, 'fahorro', 'venta', 25.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 401 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 402, 'fahorro', 'venta', 25.00, '2026-08-16'::date, 'import_csv', 90, 'Restaurado import_fahorro_listo.csv'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 402 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 322, 'fahorro', 'venta', 97.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 322 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 391, 'fahorro', 'venta', 34.50, '2026-08-16'::date, 'import_csv', 90, 'Restaurado import_fahorro_listo.csv'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 391 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 388, 'fahorro', 'venta', 34.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 388 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 126, 'fahorro', 'venta', 43.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 126 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 123, 'fahorro', 'venta', 261.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 123 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 582, 'fahorro', 'venta', 73.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 582 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 103, 'fahorro', 'venta', 282.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 103 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 91, 'fahorro', 'venta', 77.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 91 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 57, 'fahorro', 'venta', 432.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 57 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 41, 'fahorro', 'venta', 236.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 41 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 25, 'fahorro', 'venta', 100.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 25 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 400, 'fahorro', 'venta', 25.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 400 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 152, 'fahorro', 'venta', 102.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 152 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 292, 'fahorro', 'venta', 121.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 292 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 144, 'fahorro', 'venta', 67.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 144 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 52, 'fahorro', 'venta', 143.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 52 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 510, 'fahorro', 'venta', 20.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 510 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 21, 'fahorro', 'venta', 45.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 21 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 482, 'fahorro', 'venta', 199.00, '2026-08-16'::date, 'import_csv', 90, 'Restaurado import_fahorro_listo.csv'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 482 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 459, 'fahorro', 'venta', 135.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Centrum Tab C/30 - versión estándar'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 459 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 65, 'fahorro', 'venta', 143.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 65 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 503, 'fahorro', 'venta', 42.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 503 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 348, 'fahorro', 'venta', 55.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 348 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 349, 'fahorro', 'venta', 63.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 349 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 347, 'fahorro', 'venta', 92.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 347 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 30, 'fahorro', 'venta', 239.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 30 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 270, 'fahorro', 'venta', 90.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 270 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 466, 'fahorro', 'venta', 118.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 466 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 450, 'fahorro', 'venta', 183.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 450 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 53, 'fahorro', 'venta', 32.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 53 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 50, 'fahorro', 'venta', 85.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 50 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 452, 'fahorro', 'venta', 69.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 452 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 455, 'fahorro', 'venta', 69.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 455 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 101, 'fahorro', 'venta', 58.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 101 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 470, 'fahorro', 'venta', 86.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 470 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 498, 'fahorro', 'venta', 227.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 498 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 346, 'fahorro', 'venta', 16.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 346 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 469, 'fahorro', 'venta', 167.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 469 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 106, 'fahorro', 'venta', 80.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 106 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 7, 'fahorro', 'venta', 135.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 7 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 145, 'fahorro', 'venta', 423.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 145 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 4, 'fahorro', 'venta', 133.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 4 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 161, 'fahorro', 'venta', 400.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 161 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 15, 'fahorro', 'venta', 366.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 15 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 2, 'fahorro', 'venta', 158.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 2 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 67, 'fahorro', 'venta', 151.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 67 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 17, 'fahorro', 'venta', 118.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 17 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 58, 'fahorro', 'venta', 143.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 58 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 40, 'fahorro', 'venta', 212.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 40 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 127, 'fahorro', 'venta', 217.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 127 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 18, 'fahorro', 'venta', 266.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 18 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 92, 'fahorro', 'venta', 457.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 92 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 158, 'fahorro', 'venta', 364.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 158 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 71, 'fahorro', 'venta', 102.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 71 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 73, 'fahorro', 'venta', 334.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 73 AND x.fuente = 'fahorro' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 437, 'otros_venta', 'venta', 28.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Vicks Vaporub pomada 12g - precio base'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 437 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 37, 'otros_venta', 'venta', 61.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Fasiclor Cefaclor 125mg suspensión 75ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 37 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 47, 'otros_venta', 'venta', 62.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Valclan 500/125mg (12 en lugar de 10)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 47 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 481, 'otros_venta', 'venta', 36.59, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Lactopram 430MG C/20'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 481 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 486, 'otros_venta', 'venta', 53.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Afrodit 400 UI - 30 cápsulas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 486 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 499, 'otros_venta', 'venta', 109.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Flanax Gel 40g (Naproxeno 5.5%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 499 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 465, 'otros_venta', 'venta', 308.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Alka-Seltzer C/100 - precio base recomendado'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 465 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 467, 'otros_venta', 'venta', 97.89, '2026-08-16'::date, 'import_csv', 75, 'Vitau.mx - Aspirina 500mg genérica 40 tabletas (tu presentación es 80)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 467 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 475, 'otros_venta', 'venta', 128.90, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Cafiaspirina Tar C/100'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 475 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 64, 'otros_venta', 'venta', 117.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Clamoxin 600/42.9mg suspensión 50ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 64 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 76, 'otros_venta', 'venta', 38.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Amikacina 500mg/2ml ampolleta'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 76 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 268, 'otros_venta', 'venta', 25.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Silica Shine/Nat Gloss 120ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 268 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 159, 'otros_venta', 'venta', 80.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Irbesartán 150mg'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 159 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 294, 'otros_venta', 'venta', 26.90, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Chupón Ternura Ortodóntico 3Pack Miel - AlSuper. SKU exacto no verificado en catálogos públicos.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 294 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 14, 'otros_venta', 'venta', 127.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Cefagen Cefalexina tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 14 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 353, 'otros_venta', 'venta', 66.00, '2026-08-16'::date, 'import_csv', 75, 'Vitau.mx - Ensure Advance 237ml (referencia similar)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 353 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 351, 'otros_venta', 'venta', 61.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Ensure chocolate 236ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 351 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 567, 'otros_venta', 'venta', 66.00, '2026-08-16'::date, 'import_csv', 75, 'Vitau.mx - Ensure Advance 237ml (referencia)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 567 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 568, 'otros_venta', 'venta', 75.00, '2026-08-16'::date, 'import_csv', 60, 'Estimado basado en Ensure; Glucerna agotado en mayoría de farmacias'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 568 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 354, 'otros_venta', 'venta', 75.00, '2026-08-16'::date, 'import_csv', 60, 'Estimado; Glucerna agotado'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 354 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 355, 'otros_venta', 'venta', 75.00, '2026-08-16'::date, 'import_csv', 60, 'Estimado; Glucerna agotado'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 355 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 126, 'otros_venta', 'venta', 28.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Amikacina 100mg/2ml ampolleta'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 126 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 69, 'otros_venta', 'venta', 276.94, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Beneventol 400mg 6 cápsulas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 69 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 290, 'otros_venta', 'venta', 39.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Nivea Cuidada Aclarado Natural 200ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 290 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 72, 'otros_venta', 'venta', 40.52, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · GIMALXINA 500mg 12 cápsulas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 72 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 24, 'otros_venta', 'venta', 285.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Cefagen Cefalexina 500mg 10 tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 24 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 62, 'otros_venta', 'venta', 224.29, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Beneventol 400mg 3 cápsulas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 62 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 46, 'otros_venta', 'venta', 39.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Vanmoxol 250/15mg'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 46 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 454, 'otros_venta', 'venta', 150.00, '2026-08-16'::date, 'import_csv', 75, 'Farmacias referencia - Centrum Multivitamínico 30 tabletas (verificar en Fahorro/Walmart)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 454 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 404, 'otros_venta', 'venta', 26.50, '2026-08-16'::date, 'import_csv', 75, 'Farmatodo.com.mx - Electrolit suero oral 625ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 404 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 171, 'otros_venta', 'venta', 40.50, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Obao Men Tattoo Intense Rebel 65g'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 171 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 446, 'otros_venta', 'venta', 84.02, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Tempra C/12'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 446 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 131, 'otros_venta', 'venta', 23.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Gelubrin 10 CAPSULAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 131 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 52, 'otros_venta', 'venta', 112.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Clamoxin 500/125mg 10 tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 52 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 434, 'otros_venta', 'venta', 93.90, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TUMS Carbonato de Calcio precio base'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 434 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 378, 'otros_venta', 'venta', 26.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Colgate Total 12 Clean Mint 50ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 378 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 202, 'otros_venta', 'venta', 21.50, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Blumen Cherry Blossom 221ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 202 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 194, 'otros_venta', 'venta', 25.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Blumen Coconut Paradise 221ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 194 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 19, 'otros_venta', 'venta', 75.42, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CEPOBROM Cefadroxil/Bromhexina encontrado'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 19 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 221, 'otros_venta', 'venta', 124.95, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Ting polvo decolorante 85g'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 221 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 368, 'otros_venta', 'venta', 23.90, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Evenflo Biberón Colors Flujo Lento 4oz/120ml - Disponible. SKU público: 466510'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 368 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 16, 'otros_venta', 'venta', 65.43, '2026-08-16'::date, 'import_csv', 60, 'Basado en precio Ciprofloxacino 500mg genérico; presentación de 3 tab no encontrada'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 16 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 500, 'otros_venta', 'venta', 300.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Neurobion DC 100/100/25mg C/1 inyectable. Precio base estimado $300 (rango $274-$312 según fuente). SKU FC-82176351 no encontrado en catálogos; posible discrepancia de SKU interno.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 500 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 473, 'otros_venta', 'venta', 260.00, '2026-08-16'::date, 'import_csv', 75, 'Farmacias San Isidro - Alka-Seltzer Boost 50 tabletas efervescentes'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 473 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 36, 'otros_venta', 'venta', 197.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Fasiclor Cefaclor 250mg suspensión 75ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 36 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 63, 'otros_venta', 'venta', 57.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Gimalxina 250mg/5ml suspensión 75ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 63 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 502, 'otros_venta', 'venta', 339.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Dolo-Neurobión Diclofenaco Complejo B'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 502 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 118, 'otros_venta', 'venta', 328.57, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Beneventol suspensión 50ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 118 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 132, 'otros_venta', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Zitriasol 100mg 15 cápsulas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 132 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 11, 'otros_venta', 'venta', 128.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Cefagen suspensión 250mg'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 11 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 20, 'otros_venta', 'venta', 54.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Diclephen Diclofenaco 500mg'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 20 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 49, 'otros_venta', 'venta', 52.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Ampicilina 1g ampolleta'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 49 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 12, 'otros_venta', 'venta', 96.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Cefagen suspensión 125mg'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 12 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 42, 'otros_venta', 'venta', 176.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Nalixone/Fenazopiridina'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 42 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 125, 'otros_venta', 'venta', 65.43, '2026-08-16'::date, 'import_csv', 75, 'Vitau.mx - Ciprofloxacino genérico 500mg 14 tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 125 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 60, 'otros_venta', 'venta', 135.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Clamoxin 875/125mg 10 tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 60 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 29, 'otros_venta', 'venta', 117.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Fasiclor Cefaclor'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 29 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 61, 'otros_venta', 'venta', 92.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · Clamoxin 250/62.5mg suspensión 60ml'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 61 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 51, 'otros_venta', 'venta', 67.00, '2026-08-16'::date, 'import_csv', 75, 'Vitau.mx - Ampicilina genérica 1g 10 tabletas'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 51 AND x.fuente = 'otros_venta' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 598, 'similares', 'venta', 34.00, '2026-08-16'::date, 'import_csv', 70, 'excel:articulos_farmacias.xlsx | principios activos completos; concentracion coincide; forma difiere gel≠crema | BINAFEX TERBINAFINA CLORHIDRATO 15GR 10MG/1G CREMA 15GR'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 598 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 483, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · GEL LUBRICANTE VAGINAL 113GR.. (Score: 67%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 483 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 729, 'similares', 'venta', 71.00, '2026-08-16'::date, 'import_csv', 100, 'excel:articulos_farmacias.xlsx | misma marca comercial; cantidad coincide; forma coincide | DIBENEL SIMI DIAB PLUS 30CAP 30 CAPSULAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 729 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 150, 'similares', 'venta', 74.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ESCITALOPRAM 10MG 14TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 150 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 55, 'similares', 'venta', 36.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 55 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 210, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 210 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 169, 'similares', 'venta', 69.01, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 169 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 174, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 174 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 179, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 179 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 122, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 122 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 721, 'similares', 'venta', 107.00, '2026-08-16'::date, 'import_csv', 100, 'excel:articulos_farmacias.xlsx | misma marca comercial; cantidad coincide; forma coincide | LA FEMME CIMICIFUGA/VIT/ISOFLAV 30CAPGEL 30 CAPSULAS GELATINA BLANDA'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 721 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 445, 'similares', 'venta', 34.00, '2026-08-16'::date, 'import_csv', 100, 'excel:articulos_farmacias.xlsx | marca parecida (88.88888888888889); principios activos completos; concentracion coincide; forma coincide | BEPHANTEN DEXPANTENOL 5/100GR POMADA 30GR TATUAJES 5/100GR POMADA 30GR'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 445 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 458, 'similares', 'venta', 132.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · SALES DE POTASIO 50TAB  EFERVESCENTES.. (Score: 68%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 458 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 484, 'similares', 'venta', 48.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 484 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 474, 'similares', 'venta', 25.50, '2026-08-16'::date, 'import_csv', 75, 'Match generico: DEXPANTENOL 5/100GR CREMA 30GR SIMIBABY (equivalente generico de Bepanthen Multiusos Pomada, misma concentracion 5% y mismo tamano 30g)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 474 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 487, 'similares', 'venta', 23.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | principios activos completos; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | PIRAFRIN AGRIFEN CLORFENAMINA 10TAB 500MG/25MG/5MG/4MG 10 TABLETAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 487 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 550, 'similares', 'venta', 19.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · OXIDO DE ZINC 25GR/100GR 30GR.. (Score: 74%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 550 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 112, 'similares', 'venta', 99.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 112 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 75, 'similares', 'venta', 60.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 75 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 188, 'similares', 'venta', 56.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JABON DE AZUFRE CON LANOLINA 100GR.. (Score: 67%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 188 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 68, 'similares', 'venta', 69.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 68 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 555, 'similares', 'venta', 139.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | HUCIUS CASTAÑO INDIAS/RUSCUS 250MG/70MG 30CAP 250MG/70MG 30 CAPSULAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 555 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 143, 'similares', 'venta', 17.50, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · FLUOCINOLONA CREMA 20GR.. (Score: 82%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 143 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 90, 'similares', 'venta', 56.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · BETAMETASONA DIP/BETA FOS 1AMP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 90 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 10, 'similares', 'venta', 25.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 10 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 76, 'similares', 'venta', 44.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 76 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 99, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · LEVODROP/AMBROX 0.6/0.3GR/100ML SOL120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 99 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 119, 'similares', 'venta', 94.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMPICILINA/MET/GUA/CLO AD 3AMP+3JER.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 119 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 32, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 32 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 84, 'similares', 'venta', 88.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CEFOTAXIMA 1GR SOL INY.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 84 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 471, 'similares', 'venta', 99.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 471 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 403, 'similares', 'venta', 65.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda limitada por Electrolit. Precio estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 403 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 492, 'similares', 'venta', 23.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · AGRIFEN CLORFENAMINA 10TAB.. (Score: 67%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 492 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 105, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TOBRAMICINA/DEXAMET 5ML SOL OFT.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 105 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 165, 'similares', 'venta', 69.01, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 165 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 166, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 166 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 109, 'similares', 'venta', 164.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 109 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 147, 'similares', 'venta', 24.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · HIDROCLOROTIAZIDA 25MG 20TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 147 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 86, 'similares', 'venta', 60.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CETIRIZINA 10MG 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 86 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 146, 'similares', 'venta', 93.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · HIERRO DEXTRAN 100MG/2ML 3AMP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 146 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 14, 'similares', 'venta', 195.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | CEFAGEN CEFUROXIMA 500MG 10TAB 500MG 10 TABLETAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 14 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 501, 'similares', 'venta', 57.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Otro. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 501 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 168, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 168 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 767, 'similares', 'venta', 63.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | PLUS GEL ALUMINIO/MAGN/DIMET 50TAB MAST 200MG/200MG/20MG 50 TABLETAS MASTICABLES'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 767 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 352, 'similares', 'venta', 184.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Suplemento. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 352 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 351, 'similares', 'venta', 38.62, '2026-08-16'::date, 'import_csv', 60, 'No se encontro marca Ensure; Similares maneja varias ''DIETA POLIMERICA'' sabor chocolate 236ML genericas (sin fibra $38.62, con fibra $39.75, hipercalorica $42.00); se reporta la variante sin fibra estandar como la mas cercana a Ensure regular, pero existe ambiguedad real sobre cual formulacion corresponde'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 351 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 388, 'similares', 'venta', 25.50, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ELECTROLITO PED UVA 500ML.. (Score: 84%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 388 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 389, 'similares', 'venta', 25.50, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · ELECTROLITO PED UVA 500ML.. (Score: 75%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 389 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 509, 'similares', 'venta', 22.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TELA ADHESIVA SEDOSA 1.25CMX5MTS.. (Score: 76%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 509 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 126, 'similares', 'venta', 17.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 126 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 123, 'similares', 'venta', 121.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 123 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 521, 'similares', 'venta', 61.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 521 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 91, 'similares', 'venta', 52.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 91 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 149, 'similares', 'venta', 63.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · GLIMEPIRIDA 2MG 30TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 149 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 134, 'similares', 'venta', 58.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · METOCARBAMOL/IBUPRO 375/200MG 12CAP.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 134 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 226, 'similares', 'venta', 59.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CLOTRIMAZOL DUAL (CREM VAG 10GR 3 OVU).. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 226 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 227, 'similares', 'venta', 59.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CLOTRIMAZOL DUAL (CREM VAG 10GR 3 OVU).. (Score: 75%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 227 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 8, 'similares', 'venta', 90.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CEFALEXINA 1GR 12TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 8 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 41, 'similares', 'venta', 133.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 41 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 408, 'similares', 'venta', 35.26, '2026-08-16'::date, 'import_csv', 75, 'Match generico: toallitas humedas para bebe SIMIBABY 80 piezas, equivalente generico de Huggies Toallitas Cuidado Puro, misma cantidad C/80'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 408 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 24, 'similares', 'venta', 195.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 24 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 89, 'similares', 'venta', 147.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 89 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 418, 'similares', 'venta', 59.25, '2026-08-16'::date, 'import_csv', 85, 'Match exacto de marca: BALSAMO LABIAL LABELLO 1 PIEZA'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 418 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 538, 'similares', 'venta', 58.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 538 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 390, 'similares', 'venta', 17.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 74%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 390 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 334, 'similares', 'venta', 10.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · VENDA ELASTICA 5CMX5MTS DR SIMI.. (Score: 75%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 334 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 336, 'similares', 'venta', 11.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · VENDA ELASTICA 7.5CMX5MTS DR SIMI.. (Score: 76%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 336 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 319, 'similares', 'venta', 16.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · VENDA ELASTICA 10CMX5MTS DR SIMI.. (Score: 76%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 319 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 330, 'similares', 'venta', 22.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · VENDA ELASTICA 15CMX5MTS DR SIMI.. (Score: 76%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 330 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 22, 'similares', 'venta', 46.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 22 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 25, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 25 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 85, 'similares', 'venta', 35.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMLODIPINO 5MG 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 85 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 62, 'similares', 'venta', 149.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 62 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 82, 'similares', 'venta', 27.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMBROXOL 0.3G/100ML SOL 120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 82 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 447, 'similares', 'venta', 139.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · METAMIZOL 5G/100ML JBE100ML NEOMELUBRINA.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 447 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 476, 'similares', 'venta', 51.00, '2026-08-16'::date, 'import_csv', 100, 'excel:articulos_farmacias.xlsx | misma marca comercial; concentracion coincide; forma coincide | NEO MELUBRINA METAMIZOL SODICO 5G/100ML JBE 120ML 5GR/100ML JARABE 120ML'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 476 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 38, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 38 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 108, 'similares', 'venta', 42.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · LORATADINA/BETAMETASONA 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 108 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 136, 'similares', 'venta', 111.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · GABAPENTINA 300MG 15CAP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 136 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 393, 'similares', 'venta', 63.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CIPROFLOXA/HIDRO/LIDO OTICA 10ML.. (Score: 78%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 393 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 397, 'similares', 'venta', 109.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · FORMULA LACTEA 0-6MESES 230GR NAN 1.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 397 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 54, 'similares', 'venta', 64.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 54 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 163, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 70%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 163 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 167, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 167 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 164, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 70%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 164 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 456, 'similares', 'venta', 6.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 456 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 313, 'similares', 'venta', 56.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CREMA CORP NIVEA PIEL EXT SECA 220ML.. (Score: 82%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 313 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 634, 'similares', 'venta', 56.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CREMA CORP NIVEA PIEL EXT SECA 220ML.. (Score: 78%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 634 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 426, 'similares', 'venta', 18.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TOALLA HUMEDA ANTIBAC P/MANOS.. (Score: 69%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 426 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 318, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CREMA HUMECTANTE P/ TATUAJES 74ML.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 318 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 239, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 85%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 239 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 155, 'similares', 'venta', 16.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · GLIBENCLAMIDA 5MG 50TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 155 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 462, 'similares', 'venta', 84.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · GEL LUBRICANTE VAGINAL 113GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 462 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 392, 'similares', 'venta', 63.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CIPROFLOXA/HIDRO/LIDO OTICA 10ML.. (Score: 78%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 392 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 124, 'similares', 'venta', 59.25, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 124 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 52, 'similares', 'venta', 95.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 52 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 441, 'similares', 'venta', 51.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · PARACETAMOL 300MG 6 SUPOS.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 441 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 443, 'similares', 'venta', 60.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · VITAMINAS A/D/ALANTO POM 40GR SIMIBABY.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 443 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 80, 'similares', 'venta', 59.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · BEZAFIBRATO 200MG 30TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 80 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 218, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 85%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 218 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 540, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 540 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 65, 'similares', 'venta', 42.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 65 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 552, 'similares', 'venta', 37.50, '2026-08-16'::date, 'import_csv', 75, 'Match generico: PRUEBA DE EMBARAZO ANALOGA (PICK UP), equivalente generico de prueba Meditest, presentacion C/1 pieza asumida equivalente'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 552 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 504, 'similares', 'venta', 16.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CREMA DE ARNICA 30GR.. (Score: 75%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 504 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 338, 'similares', 'venta', 199.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Botiquín. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 338 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 129, 'similares', 'venta', 63.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 129 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 340, 'similares', 'venta', 199.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Botiquín. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 340 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 27, 'similares', 'venta', 119.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AC FUSIDICO/BETA 20/1MG CREMA.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 27 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 87, 'similares', 'venta', 45.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMBROXOL/SALBUTAMOL SOL 120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 87 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 93, 'similares', 'venta', 69.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría GENERAL. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 93 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 102, 'similares', 'venta', 110.25, '2026-08-16'::date, 'import_csv', 75, 'Interpretando ''125 Mg/Ml'' como 0.125 mg/ml (formato comun de captura sin punto decimal), coincide con BUDESONIDA SUSPENSION 0.250MG/2ML O 0.125MG/ML PARA NEBULIZACION 5 AMPOLLETAS, mismo numero de ampolletas (5)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 102 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 19, 'similares', 'venta', 72.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 19 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 468, 'similares', 'venta', 43.50, '2026-08-16'::date, 'import_csv', 75, 'Match generico: NEOMICINA / CAOLIN / PECTINA 20 TABLETAS, equivalente generico de Treda (confirmado por fuentes externas que Treda = neomicina/caolin/pectina), misma cantidad C/20'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 468 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 30, 'similares', 'venta', 39.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 30 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 270, 'similares', 'venta', 339.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · AC URSODEOXICOLICO 250MG 50CAP.. (Score: 67%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 270 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 178, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 178 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 183, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 183 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 162, 'similares', 'venta', 111.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · GABAPENTINA 300MG 15CAP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 162 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 344, 'similares', 'venta', 234.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CREMA ANTIARRUGAS 40+ 50GR ETERNAL SEC.. (Score: 68%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 344 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 199, 'similares', 'venta', 60.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 199 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 115, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · Similares: búsqueda por categoría Producto. Precio base estimado.'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 115 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 35, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 35 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 53, 'similares', 'venta', 24.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 53 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 603, 'similares', 'venta', 119.00, '2026-08-16'::date, 'import_csv', 70, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma difiere inyectable≠solucion | ADEROGYL PALMITATO RET/ERGOC/AC ASC 4AMP ADEROGYL 6000/1200UI/499.65MG 4 AMPOLLETAS/3ML'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 603 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 101, 'similares', 'venta', 27.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 101 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 28, 'similares', 'venta', 54.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ALGESTONA/ESTRADIOL 1AMP 1ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 28 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 387, 'similares', 'venta', 17.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 74%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 387 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 386, 'similares', 'venta', 17.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AGUA OXIGENADA SOL 224ML.. (Score: 80%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 386 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 731, 'similares', 'venta', 23.00, '2026-08-16'::date, 'import_csv', 70, 'excel:articulos_farmacias.xlsx | principios activos completos; concentracion coincide; forma difiere crema≠unguento | VASELINA P/BEBE 60GR 60 GR'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 731 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 644, 'similares', 'venta', 39.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | ALKA SELTZER AC ACETIL/BICARBO/A CITRICO 10TAB ALKA 0.324G/1.976G/1.0G 10 TABLETAS EFERVESCENTES'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 644 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 472, 'similares', 'venta', 111.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · PERMETRINA 5G/100ML SOL 100ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 472 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 34, 'similares', 'venta', 40.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 34 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 394, 'similares', 'venta', 51.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · PROBIOTICOS 30TAB MAST UVA SIMIPROBIOT.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 394 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 505, 'similares', 'venta', 63.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TERMOMETRO DIGITAL 1PZA.. (Score: 74%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 505 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 26, 'similares', 'venta', 62.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ERITROMICINA 500MG 20TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 26 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 464, 'similares', 'venta', 379.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · GOTAS LUBRICANTES OCULARES 10ML.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 464 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 106, 'similares', 'venta', 36.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 106 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 491, 'similares', 'venta', 15.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AC FOLICO 5MG 20TAB.. (Score: 82%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 491 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 453, 'similares', 'venta', 112.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · HIDROXOCOBALAMINA 50000UI 5AMP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 453 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 13, 'similares', 'venta', 124.50, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 13 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 173, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 173 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 176, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 176 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 180, 'similares', 'venta', 69.01, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · DESODORANTE AER CAB 150ML OLD SPICE.. (Score: 67%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 180 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 172, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 172 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 170, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · TALCO DESODORANTE 200GR.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 170 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 177, 'similares', 'venta', 82.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · SPRAY DESODORANTE PARA PIES 160ML.. (Score: 66%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 177 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 457, 'similares', 'venta', 60.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · VITAMINAS A/D/ALANTO POM 40GR SIMIBABY.. (Score: 76%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 457 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 45, 'similares', 'venta', 18.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 45 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 63, 'similares', 'venta', 42.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; forma coincide | GIMALXINA AMOXICILINA 500MG SUSP 75ML 500MG/5ML SUSPENSION 75ML'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 63 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 113, 'similares', 'venta', 35.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMLODIPINO 5MG 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 113 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 142, 'similares', 'venta', 86.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 142 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 7, 'similares', 'venta', 47.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 7 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 118, 'similares', 'venta', 149.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 118 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 110, 'similares', 'venta', 38.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · DICLOXACILINA SUSP 60ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 110 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 44, 'similares', 'venta', 29.25, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 44 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 132, 'similares', 'venta', 110.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | ZITRIASOL ITRACONAZOL 100MG 15CAP 100MG 15 CAPSULAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 132 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 11, 'similares', 'venta', 139.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 11 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 533, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 533 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 100, 'similares', 'venta', 66.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ATORVASTATINA 10MG 20TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 100 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 77, 'similares', 'venta', 54.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ALGESTONA/ESTRADIOL 1AMP 1ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 77 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 4, 'similares', 'venta', 33.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 4 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 78, 'similares', 'venta', 31.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TRIMETOPRI/SULFA 800/4000MG SUSP 120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 78 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 31, 'similares', 'venta', 34.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AC MEFENAMICO 500MG 20TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 31 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 74, 'similares', 'venta', 81.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ALENDRONATO 70MG 4TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 74 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 104, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ACICLOVIR 4GR/100ML SUSP 120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 104 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 3, 'similares', 'venta', 229.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · LEVOFLOXACINO 750MG 7TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 3 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 70, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · ACICLOVIR 4GR/100ML SUSP 120ML.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 70 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 39, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMPICILINA 1GR 10TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 39 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 542, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 542 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 558, 'similares', 'venta', 89.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | VALNAIT SIMIPZ VALERIANA + 250MG 30CAP 250MG 30 CAPSULAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 558 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 121, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 71%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 121 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 15, 'similares', 'venta', 152.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 15 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 541, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 541 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 116, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · CEFTRIAXONA 1GR 1AMP.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 116 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 67, 'similares', 'venta', 110.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 67 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 130, 'similares', 'venta', 31.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | misma marca comercial; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | DOLPROFEN IBUPROFENO 800MG 10TAB 800MG 10 TABLETAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 130 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 17, 'similares', 'venta', 90.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 17 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 151, 'similares', 'venta', 99.00, '2026-08-16'::date, 'import_csv', 70, 'excel:articulos_farmacias.xlsx | misma marca comercial; concentracion coincide; forma difiere jarabe≠solucion | VALGAB DESLORATADINA 50MG SOL 120ML 50MG/100ML SOLUCION 120ML'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 151 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 520, 'similares', 'venta', 131.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CREMA ACEITE DE ALMENDRA 225ML.. (Score: 68%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 520 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 40, 'similares', 'venta', 104.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 40 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 557, 'similares', 'venta', 34.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TERBINAFINA CLORHIDRATO 15GR.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 557 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 83, 'similares', 'venta', 37.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · BETAMETASONA 8MG/2ML 1AMP+JER.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 83 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 94, 'similares', 'venta', 76.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CALCIO/VIT A/VIT D2 60COMP.. (Score: 75%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 94 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 66, 'similares', 'venta', 33.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 66 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 120, 'similares', 'venta', 45.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · AMANTADINA/CLOR/PARA 60ML INF.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 120 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 127, 'similares', 'venta', 116.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 127 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 137, 'similares', 'venta', 13.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · FUROSEMIDA 40MG 20TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 137 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 92, 'similares', 'venta', 99.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 92 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 81, 'similares', 'venta', 79.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · LINCOMICINA 600MG/2ML 6AMP.. (Score: 81%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 81 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 60, 'similares', 'venta', 99.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 60 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 61, 'similares', 'venta', 64.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 61 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 88, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · BIFONAZOL UNGUENTO 20GR.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 88 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 51, 'similares', 'venta', 49.00, '2026-08-16'::date, 'import_csv', 80, 'excel:articulos_farmacias.xlsx | principios activos completos; nuestro catalogo sin concentracion; cantidad coincide; forma coincide | AMPITECNO T AMPICILINA 1GR 10TAB 1GR 10 TABLETAS'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 51 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 79, 'similares', 'venta', 39.00, '2026-08-16'::date, 'manual', 90, 'Claude 20260815 · TRIMETO/SULF 160/800MG 14TAB.. (Score: 100%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 79 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 95, 'similares', 'venta', 170.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · CALCITRIOL 0.25MCG 50CAP.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 95 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 73, 'similares', 'venta', 179.00, '2026-08-16'::date, 'manual', 100, 'Restaurado backup UI 2026-08-14'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 73 AND x.fuente = 'similares' AND x.tipo = 'venta');

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
SELECT 539, 'similares', 'venta', 49.00, '2026-08-16'::date, 'manual', 70, 'Claude 20260815 · JERINGA PERA NO.3 1PZA SIMIBABY.. (Score: 65%)'
WHERE NOT EXISTS (SELECT 1 FROM public.producto_precios_referencia x WHERE x.producto_id = 539 AND x.fuente = 'similares' AND x.tipo = 'venta');

COMMIT;

SELECT fuente, count(*) refs FROM public.producto_precios_referencia
WHERE tipo = 'venta' GROUP BY fuente ORDER BY refs DESC;
