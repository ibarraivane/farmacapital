# Fichas enriquecidas y banners por plantilla

Especificación aprobada el 21 de septiembre de 2026. **Nada de esto entra a `main` sin PR revisado por Iván.**

## Archivos

| Archivo | Uso |
|---|---|
| `CATALOGO_FICHAS_SPEC.md` | Modelo, UI de ficha, pipeline y criterios. |
| `BANNERS_AUTOMATICOS_SPEC.md` | Plantillas de banner y animación de entrada. |
| `prompt_investigacion.md` | System prompt del agente (solo servidor). |
| `monografias_semilla.json` | 10 monografías `borrador_ia` (formato §4). Control de calidad; fuentes vacías hasta cotejar instructivo. |
| `cobertura_catalogo_20260816.csv` | Snapshot de clasificación (id, sku, nombre, EAN, sustancia, tipo). **Sin costos.** Regenerar desde el catálogo vivo. |

## Cómo aplicar (después del merge)

1. En Supabase SQL Editor, en este orden:
   - `sql/patch_catalogo_fichas_20260921.sql`
   - `sql/patch_banners_plantilla_20260921.sql`
2. Variables de servidor (nunca en el cliente): `ANTHROPIC_API_KEY`, `ENRICH_DAILY_MAX`, `CRON_SECRET`.
3. Cron: `/api/catalog/enrich` (rewrite a `/api/backup?job=catalog-enrich`). En Hobby Vercel el cron es diario; para cada 10 min usá un cron externo o plan Pro.
4. Regenerar cobertura:

```bash
python3 scripts/exportar_catalogo_supabase.py
node scripts/regenerar_cobertura_fichas.js sql/preview_catalogo_campos_y_precios.csv
```

El script de cobertura **omite** columnas de costo.

## Qué no toca este cambio

POS, inventario, lotes, precios y pagos. Solo contenido de ficha, banners de plantilla y la animación de entrada.
