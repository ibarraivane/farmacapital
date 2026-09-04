-- FarmaCapital — lote 2026-09-04
-- Orquesta: backup + EAN + duplicados + laboratorio + PVP seguro.
-- Corre en Supabase SQL Editor. No incluye outliers ni revisar_compra.
--
-- Orden:
--  1) este archivo (PVP seguro + backup)
--  2) patch_barcodes_exactos_20260904.sql
--  3) patch_barcodes_duplicados_20260904.sql
--  4) patch_laboratorio_columna_20260904.sql
-- Opcional, a mano:
--  5) patch_precios_venta_revisar_compra_20260904.sql
-- Nunca:
--     patch_precios_venta_outliers_NO_CORRER_20260904.sql

\echo 'Usa los 4 archivos en orden, o pega este PVP y luego los otros 3.'

-- Ver patch_precios_venta_aplicar_20260904.sql (10 updates)
