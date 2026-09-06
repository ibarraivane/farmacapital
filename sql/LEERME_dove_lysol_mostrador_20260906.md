# Foto mostrador · Dove + Lysol · 06-sep-2026

## Veredicto

| Producto (foto) | EAN | ¿En sistema? | Acción |
|---|---|---|---|
| Dove antitranspirante aerosol Tono Uniforme Caléndula 150 ml | `7506306241152` | **No** (hay cercanos con otro EAN) | Alta nueva `FC-06241152` |
| eGo Force roll-on 45 ml | `75064938` (oficial Unilever) | **Sí** `FC-75064938` | No tocar. Foto sigue pendiente. |
| Lysol Crisp Linen desinfectante antibacterial 354 g | `7501058796882` | **No** (sí hay el de **475 g**) | Alta nueva `FC-58796882` |
| Desenfriol D tabletas C/6 | `7502276040641` | **No** (sí hay C/30 `7502276040368`) | Alta nueva `FC-27604064` · cad JUL/2027 · stock 1 |

## No confundir

- Dove `7506306241206` / `FC-06241206` = otra variante (“tono uniforme 72h” / ticket Dermac).
- Dove `7506306248052` / `FC-06248052` = **3PACK** (nombre de pieza, barcode de caja).
- Lysol `7501058752796` / `FC-58752796` = Crisp Linen **475 g**, no el de 354 g de la foto.

## Fuentes de ficha

- Dove: ficha Dove MX `…/07506306241152` · Soriana ~$91.50.
- Lysol: Siltecsa SKU = EAN · Home Depot MX $139 (354 g).
- eGo: Unilever eGo Force roll-on 45 ml → código `75064938`.

## Qué pegar en Supabase

1. `sql/patch_alta_dove_lysol_mostrador_20260906.sql` — Dove + Lysol (stock 0).
2. `sql/patch_alta_desenfriol_d_c6_7502276040641.sql` — Desenfriol D C/6 (stock 1, lote cad 2027-07-31).
3. Tras deploy Vercel: `sql/patch_fotos_dove_lysol_mostrador_20260906.sql`.

Sin ticket de compra para Dove/Lysol/Desenfriol: no inventar recepción ni costo. Cuando haya remisión, armar Recibir.
