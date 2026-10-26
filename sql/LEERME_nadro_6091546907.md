# Nadro folio 6091546907 · 25-oct-2026 · $312.34

Factura CFDI (foto). Emisor NADRO · Receptor Luis Ángel Paillero Ventura · entrega FarmaCapital.

## Veredicto

**Ticket nuevo.** 4 renglones. Ficha iNadro (no el código del PDF). LGEN no va como marca.

| EAN | Ticket | SKU | Nombre mostrador | Acción |
|---|---|---|---|---|
| `7506306241206` | DESOD DOVE DERMAC SK-C 48H SPY150ML ×1 · $41.35 | `FC-06241206` | Dove Dermoaclarant Skin Calming | Ya existía mal nombrado («tono uniforme 72h») → renombrar + costo |
| `7506306241183` | DESOD DOVE ORIGINAL 48H SPY150ML ×2 · $41.04 | `FC-06241183` | Dove Original | **Alta nueva** |
| `7502242701200` | MEMANTINA 10 MG 28 TAB LGEN ×1 · $90.41 · lote 252570 | `FC-42701200` | Memantina 10 mg | **Alta nueva** (Corne, receta) |
| `7502223553477` | OMEPRAZOL 20 MG 30 CAPS LGEN ×5 · $15.75 · lote ZZ8011A | `FC-23553477` | Zolufen (Omeprazol) 20 mg | **Alta nueva** (Synthon) |

No confundir Omeprazol con el LGEN Ultra Lab `7502216792760` (`FC-16792760`): otro EAN / otro lab.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6091546907.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6091546907.sql`.

CSV: `sql/generated/ticket_nadro_6091546907.csv`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja (la factura trae lote/cad de Memantina y Omeprazol; Recibir lo confirma en caja). No poner `0000`.

## Totales factura

Subtotal $292.59 · IVA 16% $19.75 (solo Dove) · **Total $312.34**.
