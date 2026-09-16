# Nadro folio 000004568 · 13-sep-2026 · $526.22

Fotos del remisión (lado A códigos EAN + lado B impuestos).

## Veredicto

**Ticket nuevo.** 5 renglones, todos alta de catálogo (ficha iNadro, no el código del PDF).

| EAN pistola | Ticket | SKU | Nombre mostrador | Acción |
|---|---|---|---|---|
| `7501446000553` | ACIDO-FOLICO 5 MG 50 TAB | `FC-46000553` | A.F. Valdecasas ácido fólico 5 mg 50 tabletas | Alta + foto (receta) |
| `7501022112250` | C-BOOST SUP ALIM COLAGENO FCO90GOM | `FC-22112250` | C-Boost colágeno + biotina + AH 90 gomitas | Alta + foto |
| `7502009746321` | PREDNIS 1MG/1ML SOL FCO100ML LGEN | `FC-09746321` | Nisolver (prednisolona) 1 mg/ml 100 ml | Alta + foto (receta) |
| `7509552875461` | SERUM GARNIER EXPRES BOOS 4% 30ML | `FC-52875461` | Garnier Express Aclara sérum 4% 30 ml | Alta + foto |
| `7501587010404` | VIVIOPTAL 30 CAPS | `FC-87010404` | Vivioptal oral 30 cápsulas | Alta + foto |

### Garnier EAN

El papel imprime `7509552875481` (dígito verificador **inválido**). iNadro y retailers usan `7509552875461` (válido). La pistola debe leer **5461**.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_000004568.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_000004568.sql`.

CSV de auditoría / Subir CSV: `sql/generated/ticket_nadro_000004568.csv`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja (el papel trae lote/cad, pero Recibir lo confirma en caja).

Regenerar: `python3 scripts/generar_carga_nadro_000004568.py`
