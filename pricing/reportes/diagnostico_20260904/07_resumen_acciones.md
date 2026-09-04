# Diagnóstico SKU por SKU — 2026-09-04

Fuente: `07_diagnostico_sku.csv` (626 filas).

## Acciones

| accion_principal | SKUs |
|---|---|
| `llenar_concentracion` | 170 |
| `limpiar_pa` | 101 |
| `capturar_laboratorio` | 100 |
| `asignar_ean` | 94 |
| `ok` | 45 |
| `capturar_al_recibir` | 38 |
| `revisar_compra` | 18 |
| `subir` | 17 |
| `fusionar_duplicado` | 15 |
| `revisar_ean` | 13 |
| `corregir_checksum` | 8 |
| `mantener` | 3 |
| `bajar` | 3 |
| `ean_propuesto_ya_usado` | 1 |

SQL EAN a aplicar (revisar): `patch_barcodes_exactos_20260904.sql` · 96 updates.
SQL duplicados: `patch_barcodes_duplicados_20260904.sql` · 10 liberaciones.
SQL laboratorio: `patch_laboratorio_columna_20260904.sql`.

No se escribió en Supabase. Corre los SQL en el Editor cuando los aceptes.