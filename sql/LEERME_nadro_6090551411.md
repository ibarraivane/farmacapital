# Nadro folio 6090551411 · 28-sep-2026 · $440.18

Factura CFDI Nadro México Sur · UUID `63A7365A-98A6-4068-83F3-1897395A2AE8` · 4 renglones · 21 piezas.

Subtotal renglones $379.47 + IVA $60.71 = **$440.18**.

## Por qué Recibir seguía vacío (2026-09-30)

En producción **solo** se corrió `patch_fotos_…` (el chupón tiene la `imagen_url` nueva). **No** se corrió `patch_carga_…`:

| Chequeo vivo | Resultado |
|---|---|
| Hypafix `4042809591446` / Asepxia ×2 | **no existen** en `productos` |
| Chupón `FC-26462078` | sigue costo **$3.39** y nombre viejo (carga pondría **$3.10** + nombre flor/balón) |
| Fotos en `/catalogo-propia/…` | el deploy del PR **no** está en `main` → Vercel sirve `index.html` |

El deploy de Vercel **no** crea tickets. Sin fila en `recepciones` + `recepcion_items`, Recibir no muestra Nadro.

## Veredicto

| EAN pistola | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---|---:|---:|---|
| `7501026462245` | CHUPON TERNURA FLOR/BALON MIEL S | `FC-26462078` | 18 | $3.10 | Solo costo + renombrar ficha |
| `4042809591446` | LEUKOPLAST HYPAFIX 10 CM X 2M | `FC-09591446` | 1 | $71.63 | **Alta nueva** + foto |
| `650240032431` | MJE ASEPXIA PVO COM TONO CANELA 10G | `FC-40032431` | 1 | $126.02 | **Alta nueva** + foto |
| `650240032455` | MJE ASEPXIABBPVOCOMPNATMA 10G | `FC-40032455` | 1 | $126.02 | **Alta nueva** + foto |

## EANs corregidos (como Garnier)

| Factura (DV inválido) | Pistola / iNadro / caja |
|---|---|
| `7501025462245` | `7501026462245` |
| `4042809591448` | `4042809591446` |

## Qué hace falta

1. Aplicar **`sql/patch_carga_nadro_6090551411.sql`** en Supabase (o el one-shot del agente vía `/api/backup?action=aplicar-nadro-6090551411`).
   - SELECT final = **4 filas**. Si da 0, el ticket no existe.
2. Merge del PR + deploy (fotos en `public/catalogo-propia/`).
3. Después: `sql/patch_fotos_nadro_6090551411.sql`.

Diagnóstico rápido: `sql/diag_nadro_6090551411.sql`.

CSV: `sql/generated/ticket_nadro_6090551411.csv`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja. No inventar `0000`.

Regenerar: `python3 scripts/generar_carga_nadro_6090551411.py`
