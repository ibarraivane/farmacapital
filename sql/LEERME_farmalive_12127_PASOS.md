# Farmalive 12127 — pasos cortos

Si A1+A2 ya corrieron, **empieza en B1-01**. Uno por uno.

## Staging (solo si falta)

1. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_A1_staging.sql
2. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_A2_staging.sql

## Altas (8 lotes)

1. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_01_altas.sql
2. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_02_altas.sql
3. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_03_altas.sql
4. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_04_altas.sql
5. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_05_altas.sql
6. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_06_altas.sql
7. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_07_altas.sql
8. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_08_altas.sql

## Cierre

9. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B1_costos.sql
10. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B2_recibir.sql
11. https://raw.githubusercontent.com/ibarraivane/farmacapital/cursor/ticket-farmalive-12127-7887/sql/patch_carga_farmalive_12127_B3_fotos.sql

Cada B1-XX debe responder `ya_en_catalogo` = 8 (o 6 en el ultimo).
