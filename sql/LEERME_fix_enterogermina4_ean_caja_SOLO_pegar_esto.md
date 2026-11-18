# Fix EANs de caja (Cityfarma 15341570)

| Producto | Mal (OCR) | Caja |
|---|---|---|
| Enterogermina 4 billones | `7501165010628` | **`7501165010826`** / `FC-65010826` |
| Arluy Duo 200/300 mg | `7841141004068` | **`7841141004051`** / `FC-41004051` |

1. Pegar `sql/patch_fix_enterogermina4_ean_caja_SOLO_pegar_esto.sql` → Run
2. VERIFICACION con ambos EANs buenos
3. En Recibir, escanear las cajas en esos renglones
