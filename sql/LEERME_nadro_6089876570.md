# Nadro folio 6089876570 · 09-sep-2026 · $426.83

PDF: `Archivo_escaneado_20260910-1158.pdf`

## Veredicto

**Este ticket no estaba cargado.** Solo había una nota vieja de fotos Nadro/Levic.

| EAN | Ticket | SKU | Acción |
|---|---|---|---|
| `7702031244486` | Lubriderm P/Normal 120 ml ×2 | `FC-31244486` | Solo costo |
| `7502208892638` | Dirpasid 10 mg C/20 ×2 | `EQ-BRL053` | Solo costo |
| `7503005405168` | Estropajo F-Clean ×3 | `FC-05405168` | **Renombrar** (era «Saluk Fashion Sa») |
| `7501563310269` | Metoclopramida 10 mg C/20 ×4 | `FC-63310269` | **Alta nueva** |
| `7702003477270` | Curitas El Gallo callos C/6 ×2 | `FC-03477270` | **Alta nueva** |
| `7501836010087` | Realdrax MXD 20/400 C/10 ×3 | `EQ-LIF153` | Solo costo |
| `650240032295` | Suerox Mora Azul 630 ml ×2 | `FC-40032295` | Solo costo |
| `7501361111501` | Odolex 150 g ×1 | `FC-61111501` | Solo costo |

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6089876570.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6089876570.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja (el PDF trae lote/cad de algunos renglones, pero Recibir lo confirma en caja).

## Nota Saluk / F-Clean

El EAN `7503005405168` **sí** es el estropajo Saluk Fashion / F-Clean. En POS salía «Saluk Fashion Sa» sin lotes: era el mismo producto con nombre corto. El patch deja el nombre de mostrador correcto.
