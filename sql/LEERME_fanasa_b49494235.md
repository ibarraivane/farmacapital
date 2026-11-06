# Ticket Fanasa B49494235 → Recibir

Factura Fanasa (06-nov-2026) entregada a FarmaCapital La Capi. Pegar **todo** `sql/patch_fanasa_b49494235_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Ticket

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Fanasa | **B49494235** | $178.03 | Meladinina FS ungüento 30 g ×1 |

## Notas

1. Ticket imprime `MELADININA MELADININA 1 POM 30 g`; ficha real **Meladinina FS** (Chinoin / metoxaleno).
2. Lab ticket **PRO** = Productos Farmacéuticos Chinoin. Principio: metoxaleno 0.40 g / 100 g. Con receta (dermatología).
3. Costo farmacia **$178.03** (tasa 0%). PVP sugerido marca **+25%** → **$223**.
4. Pedido Fanasa **57094311**. Condiciones: efectivo.
5. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
6. Foto en `public/catalogo-propia/meladinina-fs-pomada-30g-7501088542756.jpg` → tras deploy: `sql/patch_fotos_fanasa_b49494235.sql`.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Fanasa · B49494235**.
3. Escanear `7501088542756` → MMAA → Guardar renglón.

CSV: `sql/generated/ticket_fanasa_b49494235.csv`.
