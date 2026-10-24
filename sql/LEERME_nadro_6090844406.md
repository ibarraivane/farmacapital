# Nadro folio 6090844406 · 06-oct-2026 · $343.20

Factura CFDI (foto) · FARMACAPITAL (LA CAP) · 2 piezas oftálmicas.

## Veredicto

| EAN | Ticket | SKU | Acción |
|---|---|---|---|
| `7502231320696` | BIMATOPROST 0.3MG SOL 3 ML LGEN ×1 | `FC-31320696` | **Alta nueva** · $209.38 → $336 |
| `75055813` | LATANOPR .05MG OFTA 3ML GTS LGEN ×1 | `FC-75055813` | **Alta nueva** · $133.82 → $215 |

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6090844406.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6090844406.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Notas

- Nombres de mostrador desde ficha iNadro (Mictrobil / Exakta), no el código LGEN del ticket.
- EAN Bimatoprost: `7502231320696` (iNadro + Farmacias Especializadas). EAN Latanoprost: `75055813` (iNadro / Prixz / San Jorge).
- Recargo genérico +60% sobre costo. Receta: sí (oftálmicos fracción IV).
- Regenerar: `python3 scripts/generar_carga_nadro_6090844406.py`
