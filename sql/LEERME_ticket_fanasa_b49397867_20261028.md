# Ticket Fanasa B49397867 → Recibir

Factura Fanasa (28-oct-2026) entregada a FarmaCapital La Capi. Pegar **todo** `sql/patch_ticket_fanasa_b49397867_20261028.sql` en Supabase → SQL Editor → Run.

## Ticket

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Fanasa | **B49397867** | $224.18 | Lubrex 0.5% solución oftálmica 10 ml ×1 |

## Notas

1. La factura imprime **LIBREX**; la marca real es **Lubrex** (PLM / Ocufarma / Fahorro EAN `7502231320665`).
2. Lab ticket **MPM** = Micro Pharmaceuticals. Principio: carboximetilcelulosa sódica 0.5%. Sin receta.
3. Costo farmacia **$224.18** (tasa 0%). PVP sugerido marca **+25%** → **$281**.
4. Pedido Fanasa **56961663**. Condiciones: efectivo.
5. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
6. Foto en `public/catalogo-propia/lubrex-0.5-10ml.jpg` → tras deploy: `https://www.farmacapital.mx/catalogo-propia/lubrex-0.5-10ml.jpg`.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Fanasa · B49397867**.
3. Escanear `7502231320665` → MMAA → Guardar renglón.
