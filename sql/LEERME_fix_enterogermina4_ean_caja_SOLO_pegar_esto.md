# Fix EANs de caja

| Producto | Ticket/OCR mal | Caja |
|---|---|---|
| Enterogermina 4 billones | `7501165010628` | **`7501165010826`** / `FC-65010826` |
| Arluy Duo 200/300 mg | `7841141004068` | **`7841141004051`** / `FC-41004051` |
| Naturella regulares sin alas C/8 | `7501001157296` (con alas) | **`7506195158739`** / `FC-95158739` |

1. Pegar `sql/patch_fix_enterogermina4_ean_caja_SOLO_pegar_esto.sql` → Run
2. VERIFICACION con los 3 EANs buenos
3. Recibir: escanear las cajas en esos renglones
