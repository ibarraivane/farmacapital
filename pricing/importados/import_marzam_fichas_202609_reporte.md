# Marzan / Marzam — Fichas septiembre 2026 → referencias de compra

- Renglones en PDF: **123**
- Matches seguros cargados: **17** (`importaciones_referencia.id = 48`)
- Sin match / no comparables: **106**
- Precio: **Precio Fcia con oferta**
- Fuente: `marzam` · tipo `compra` · fecha lista `2026-09-01`
- Ya aplicados en Supabase (tabla `producto_precios_referencia`)
- SQL de respaldo: `sql/pricing/generated/import_referencias_marzam_20260901.sql`
- Re-correr: `python3 scripts/importar_marzam_fichas.py --apply`

## Matches

| SKU | Precio Marzam | vs costo | Fuente | Catálogo |
|---|---:|---:|---|---|
| FC-C9F4ACCC | 49.64 | -3.5% | ACEMETACINA 90MG CAPS C14 | Acemetacina |
| FC-FD845E68 | 57.22 | -10.7% | ACICLOVIR 400MG TAB C35 | Aciclovir |
| FC-11780359 | 19.58 | -0.1% | AFLUSIL 120ML | Aflusil (Ibuprofeno) suspensión 2 g/100 mL |
| FC-25116810 | 25.96 | +33.1% | AGRIFEN TAB C10 | Agrifen |
| FC-8505003 | 64.95 | -5.6% | ALIN AMP 2ML C1 | Alin Dexametasona 8 mg/2 mL amp |
| FC-053610 | 135.29 | +130.1% | ALLI-TRIPLE TAB C10 | Alli-Triple C/10 tabletas |
| FC-40013805 | 102.94 | +73.6% | ALLIVIAX 550MG TAB C10 | Alliviax desinflamatorio 550 mg 10 tabletas |
| FC-BE76D409 | 17.59 | -10.8% | AMCEF IM 1G IM 3.5ML | Amcef IM 1 g (Inyectable) |
| FC-07F04F88 | 17.45 | -10.2% | AMCEF IM 500MG SOL 2ML | Amcef IM 500 mg (Inyectable) |
| FC-4A0245DA | 31.03 | -4.6% | AMLODIPINO 5MG TAB C100 | Amlodipino |
| FC-3B001F9B | 10.72 | +18.6% | AMLODIPINO 5MG TAB C30 | Amlodipino |
| FC-A0D320D1 | 18.38 | +0.1% | AMOXICILINA 500MG CAP C12 | Amoxicilina |
| FC-F82A6E4B | 26.81 | -0.9% | AMPICILINA 1G TAB C10 | Ampicilina |
| FC-88508929 | 138.56 | -14.8% | ANARA TAB C20 | Anara |
| FC-01508201 | 162.87 | +4.0% | ANTIFLU DES CAP C24 | Antiflu-Des C/24 |
| FC-85097661 | 125.02 | -0.3% | ANTIFLU DES JR SOL 60ML | Antiflu-Des Jr Antigripal |
| FL-8509810 | 141.04 | -3.4% | ANTIFLU DES PED 30ML | Antiflu-Des pediátrico solución 30 ml |

Más baratos que tu costo actual: **10**

## Limitaciones

- El PDF exporta EAN en notación científica; no se pudo cruzar por código de barras.
- Solo se cargaron coincidencias revisadas (misma marca/presentación).
- No se igualaron líneas de otra marca (algodón/alcohol PG vs Dibar).
- Para ampliar: exportá la lista Marzam en Excel (no PDF) con EAN completos, o agregá SKUs al mapa `MANUAL_SKU` en `scripts/importar_marzam_fichas.py`.
