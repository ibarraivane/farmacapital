# Fix EAN Enterogermina 4 billones (caja)

La caja dice **`7501165010826`**. En el ticket Cityfarma 15341570 quedó mal (`7501165010628`).

1. Pegar `sql/patch_fix_enterogermina4_ean_caja_SOLO_pegar_esto.sql` → Run
2. VERIFICACION: producto con `7501165010826` / `FC-65010826`
3. En Recibir, escanear ese EAN en el renglón de Enterogermina 4
