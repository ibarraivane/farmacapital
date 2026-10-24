# Cityfarma S334713 — Recibir

Cliente **Luis Ángel Palillero Ventura** · foto térmica 24-oct-2026 · pagado **tarjeta de crédito**.

## Qué correr

1. Pegar **todo** `sql/patch_carga_cityfarma_s334713.sql` en Supabase → SQL Editor → Run.
2. En Recibir debe aparecer el botón vivo **Cityfarma · S334713**.
3. Escanear cada caja → MMAA de la caja (no inventar `0000`) → confirmar.

## Totales

- 3 renglones / **7 pzas** / **$1,149.85**
- Folio **S334713**

| EAN | Producto (ficha) | Pzas | Costo |
|---|---|---|---|
| 7501070615277 | Daflon 500 mg (Servier, C/20) | 1 | $430.00 |
| 7502001165953 | Rexurdir nifuroxazida 400 mg (Son's, C/16) | 5 | $28.77 |
| 8020030091252 | Vessel Due-F sulodexida 250 LRU (AlfaSigma, C/50) | 1 | $576.00 |

## Notas

- **Daflon:** alta stock 0 si no existía (SKU `FC-70615277`). Foto packshot pendiente → `catalogo-propia/` + SQL de `imagen_url` después del deploy.
- Rexurdir y Vessel Due-F ya estaban en catálogo: solo se actualiza costo si cambió; no se pisa PVP.
- Sin lote/caducidad en el papel: la pistola pide MMAA de la caja.
