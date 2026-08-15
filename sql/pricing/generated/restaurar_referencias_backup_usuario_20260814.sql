-- Restaurar referencias de precio desde backup usuario 2026-08-14
-- 1 inserts (solo faltantes o distintos; no borra nada)
-- Ejecutar en Supabase SQL Editor

BEGIN;

INSERT INTO public.producto_precios_referencia (producto_id, fuente, tipo, precio, fecha, origen, confianza, notas)
VALUES (388, 'fahorro', 'venta', 34.50, '2026-08-14'::date, 'manual', 100, 'Restaurado desde backup UI 2026-08-14');

COMMIT;
