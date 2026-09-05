# Foto “productos Nadro” · 05-sep-2026

## Veredicto

**Estos productos NO están en las facturas Nadro que tenemos cargadas.**

| Folio Nadro | Qué trae | ¿Están Carticap / Neo-Melubrina Infantil / Oral-B gingivitis / Tylenol / Estomaquil susp.? |
|---|---|---|
| `1658128647824-01` (30-ago, $5,617.17) | Omeprazol, Irbesartán, Flanax, Buscapina, Labello, CeraVe, Rexona… | **No** |
| `20260901` (1-sep, $848.05) | Jabones Grisi/Dove, Pantene, Anthelios UV Air… | **No** |
| FALT `1658128647824-01-FALT` | Omeprazol 14 caps, Irbesartán 300, Suerox, Pioglitazona 30 | **No** |

La foto del mostrador (Carticap, Neo-Melubrina Infantil, Oral-B gingivitis 350 ml, Tylenol, Estomaquil suspensión) **no coincide** con ningún renglón de esos tickets. Si llegaron en una remisión distinta o de otro mayoreo, hace falta ese papel (folio + costos) para armar Recibir.

## Estado en catálogo (antes del patch)

| Producto de la foto | ¿En sistema? | Nota |
|---|---|---|
| Carticap FOR 60 cáps | **No** | Alta nueva EAN `7502227426067` |
| Neo-Melubrina Infantil jarabe 100 ml | Sí (`FC-50003151` / `7501165000315`) | Nombre/forma mal (llegó a decir “Inyectable”). El patch lo deja legible. |
| Oral-B enjuague gingivitis 350 ml | **No** | Alta nueva EAN `7501086453221` |
| Tylenol 500 mg C/10 | Sí (`FC-75354321` / `7501007535432`) | Buscar “Tylenol”. Si hay caja de **20** tabs, es otra presentación: escanear EAN de esa caja. |
| Estomaquil **suspensión** | **No** (solo hay **Polvo C/20** sobres) | Alta nueva EAN `7501369200108` (Exper3 **240 ml**). Si el frasco dice 120 ml, no uses este EAN. |

## Qué pegar en Supabase

1. `sql/patch_alta_foto_mostrador_20260905.sql` — altas + fix Neo-Melubrina (stock 0).
2. Tras deploy Vercel: `sql/patch_fotos_foto_mostrador_20260905.sql`.

No crea recepción Nadro (sería inventar). Cuando tengas el ticket real, se arma la cola Recibir con costos y qty.
