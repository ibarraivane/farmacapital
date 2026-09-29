-- OBSOLETO: este archivo hace Load failed (api.supabase.com) por fc_buscar en masa.
-- Usa en su lugar los lotes chicos:
--   patch_carga_farmalive_12127_B1_01_altas.sql
--   ...
--   patch_carga_farmalive_12127_B1_08_altas.sql
--   patch_carga_farmalive_12127_B1_costos.sql
-- Guia: sql/LEERME_farmalive_12127_PASOS.md

select 'Usa B1_01 .. B1_08 + B1_costos (ver LEERME_farmalive_12127_PASOS.md)' as aviso;
