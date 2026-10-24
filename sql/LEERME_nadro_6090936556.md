# Nadro folio 6090936556 · 8-oct-2026 · $778.42

Factura CFDI Nadro México Sur · 7 renglones · 25 piezas.

## Veredicto

| EAN caja | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---|---:|---:|---|
| `7503001007281` | AMOXICILINA 250 MG 12 CAPS LGEN | `FC-01007281` | 5 | $15.48 | **Alta** Vandix 250 mg |
| `7501349021570` | AMOXICILINA 500 MG 12 CAPS LGEN | `FC-49021570` | 5 | $18.76 | Solo costo (ya en catálogo) |
| `7501349022881` | AMPICILINA 1 G 10 TAB LGEN | `FC-F82A6E4B` | 4 | $24.63 | Solo costo (ya en catálogo) |
| `7503001007137` | AMPICILINA 250 MG 60 ML SUSP LGEN | `FC-01007137` | 4 | $16.71 | **Alta** Mexapin 250 mg/5 ml |
| `7503001007168` | AMPICILINA 500 MG 20 CAPS LGEN | `FC-01007168` | 3 | $29.35 | **Alta** Mexapin 500 mg |
| `7502247375543` | BONGLIXAN 100UI S I FA 10ML LGEN | `FC-47375543` | 1 | $224.99 | **Alta** Bonglixan 100 UI |
| `7506022327635` | BRESALTEC 100 UG INH 200 DOSIS LGEN | `FC-22327635` | 3 | $42.94 | **Alta** Bresaltec 100 µg |

Suma renglones: $77.40 + $93.80 + $98.52 + $66.84 + $88.05 + $224.99 + $128.82 = **$778.42** ✓

PVP altas nuevas = costo × 1.60 (recargo genérico). No pisa un precio que ya esté.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6090936556.sql` — altas + cola Recibir borrador + fotos.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

Las fotos viven en `public/catalogo-propia/`. Tras el deploy de Vercel se ven en tienda.

## Notas de ficha

- **EAN pistola** = barcode de la caja (Sufarmed / Prixz / Farma24). Varios números del papel fallan el dígito GS1 (mismo patrón que Garnier en folio 000004568).
- **LGEN / LIFEFACTOR / JAYOR** en el ticket son casa Nadro, no marca de mostrador.
- **Vandix / Mexapin:** marca de caja Wandel. No usar Wandel como marca.
- **Bonglixan:** insulina glargina, **cadena fría**. Laboratorio Landsteiner Scientific (caja). Requiere receta.
- **Bresaltec:** salbutamol 100 µg, 200 dosis, BiosynTec. Jayor no es la marca.
- No confundir Mexapin 250 mg/5 ml 60 ml (`7503001007137`) con Mexapin 125 mg (`7503001007120` / `FC-50587FA6`).

## Recibir

Subir también `sql/generated/ticket_nadro_6090936556.csv` si prefieren CSV en lugar del SQL.
