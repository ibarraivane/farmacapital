# Nadro folio 6091017798 · 2026-10-11 · $877.98

Factura CFDI (foto `sql/generated/factura_nadro_6091017798.jpg`) · UUID E11D25BA-… · subtotal ~$867.28 + IVA Hypafix $10.70 = **$877.98**.
Suma de renglones a costo unitario: $867.31 (3 centavos de redondeo vs subtotal impreso).

## Veredicto

| EAN | Ticket | SKU | Acción |
|---|---|---|---|
| `7503008344785` | Ibuprofeno 400 mg C/10 ×3 | `EQ-PGE033` | Solo costo (Gelubrín) |
| `4042809591446` | Leukoplast Hypafix 10 cm × 2 m ×1 | `FC-09591446` | **Alta nueva** |
| `0785120755459` | Rosuvastatina 10 mg C/30 ×1 | `FC-20755459` | **Alta nueva** (Crostox) |
| `0785120755466` | Rosuvastatina 20 mg C/30 ×2 | `EQ-MAI163` | Solo costo (Crostox) |
| `7501088505454` | Synalar-S 0.025% crema 20 g ×1 | `FC-88505454` | **Alta nueva** |
| `7501349029736` | Telmisartán/HCTZ 80/12.5 C/28 ×2 | `FC-49029736` | **Alta nueva** |
| `7501349025844` | Telmisartán 40 mg C/28 ×2 | `FC-49025844` | Solo costo |
| `5415062392317` | Terramicina oft. ungüento 10 g ×1 | `FC-62392317` | **Alta nueva** |

Fichas desde iNadro (no el código del ticket). Marca real: Gelubrín / Leukoplast / Crostox / Synalar / AMSA / Terramicina — no LGEN ni casa Nadro.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6091017798.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6091017798.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja. No inventar `0000`.

CSV: `sql/generated/ticket_nadro_6091017798.csv`.
