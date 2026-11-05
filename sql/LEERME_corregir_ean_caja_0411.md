# Corrección EAN caja 04-nov-2026

Fotos de la caja vs lo mapeado en ticket.

| Ticket | Mal | Bien (caja) |
|---|---|---|
| Sahuayo 432467 | Huggies E5 `7501943441804` | E4 Unisex 36 `7501943441767` |
| Sahuayo 432467 | Saba `7501019006609` | Buenas Noches 10 `7501019070532` |
| Sahuayo 432467 | Kotex Anatómica `7501943424623` | Regular con alas `7501943424562` |
| Farma Mayoreo V01000002384 | Nuvel Beauty roll-on `7501082731323` | Softy spray 170 ml `7501082731064` |
| Farma Mayoreo V01000002384 | Aclarado Ideal roll-on `7501082730258` | Aclarado Ideal spray 150 ml `7501082736021` |

Pegar `sql/patch_corregir_ean_caja_0411_SOLO_pegar_esto.sql` → Run → recargar Recibir.
