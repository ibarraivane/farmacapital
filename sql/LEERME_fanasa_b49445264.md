# Fanasa folio B49445264 · 02-nov-2026 · $667.19

Factura Fanasa (lado EAN + lado precios). Pedido **57020464**. Entrega FarmaCapital La Capi.

## Veredicto

**Ticket nuevo.** 2 renglones, ambos alta Fluxedan (Carnot).

| EAN | Ticket | SKU | Nombre mostrador | Qty | Costo |
|---|---|---|---|---|---|
| `7501070903237` | FLUXEDAN BROMHEXINA OXELADINA 24 COM | `FC-70903237` | Fluxedan 6/12 mg | 1 | $313.41 |
| `7501070900441` | FLUXEDAN CLORHIDRATO DE BROMHEXINA 6/12 mg/10 ml 1 JBE 225 ml | `FC-70900441` | Fluxedan jarabe | 1 | $353.78 |

### Cantidades

Columna **CANT = 1** en ambos. La columna **BUL** (2 / 1) es bulto/logística,
no piezas facturadas: el importe neto = precio farmacia × 1.

## Qué pegar en Supabase

1. `sql/patch_carga_fanasa_b49445264.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_fanasa_b49445264.sql`.

CSV: `sql/generated/ticket_fanasa_b49445264.csv`.

Stock **0** hasta pistola + MMAA de la caja.

Regenerar: `python3 scripts/generar_carga_fanasa_b49445264.py`
