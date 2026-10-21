# Alta: Timolol · Dexal · Dexlansoprazol (fotos 2026-10-21)

Cajas en mostrador. No estaban en catálogo.

## Qué correr

1. Merge/deploy (para que vivan las fotos en `/catalogo-propia/`).
2. Pegar **todo** `sql/patch_alta_timolol_dexal_dexlansoprazol_20261021.sql` en Supabase → SQL Editor → Run.
3. Recibir: escanear → MMAA de la caja → Guardar. Stock 0 hasta entonces.

## Productos

| Producto | EAN caja | SKU | Costo → PVP |
|---|---|---|---|
| Timolol OPKO 5 mg/mL gotero 5 mL | **75049812** (alias `0000075049812`) | FC-75049812 | $31.02 → $50 (+60%) |
| Dexal Ceftibuteno Maver 400 mg C/5 | **7502009746352** | FC-09746352 | $220.70 → $276 (+25%) |
| Dexlansoprazol Avivia 60 mg C/7 LR | **7503049078281** | FC-49078281 | sin costo · ancla $114 |

## “Código de barras distinto por 1 número”

Las dos cajas de **Timolol** se ven iguales. En una el código impreso es `75049812`; en mayoreo (Dilopsan / recipe) el mismo producto aparece como GTIN `0000075049812` (ceros a la izquierda). El patch enlaza ambos en `fc_match` y en `EAN_PARES_CONOCIDOS`.

Si la **otra** caja Timolol escanea un dígito distinto (no solo padding), mandar ese EAN para sumarlo al alias — no dar de alta un segundo renglón.

## No confundir

- `7503049078281` = **Dexlansoprazol Avivia C/7**, no Timolol.
- Timolol OPKO ≠ HOREX de nombre comercial, pero es la misma molécula OPKO/Exakta; el código de estas cajas es `75049812`.

## No hacer

- No ir a Inventario → Catálogo a darlos de alta a mano.
- No poner caducidad `0000`.
- No pegar PVP de Del Ahorro / Similares como `productos.precio` sin costo.
