# Ticket Fanasa B49602160 → Recibir

Factura Fanasa (17-nov-2026) entregada a FarmaCapital La Capi. **No estaba** en el repo. Pegar **todo** `sql/patch_fanasa_b49602160_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Ticket

| Proveedor | Folio | Pedido | Total | Renglones |
|---|---|---|---|---|
| Fanasa | **B49602160** | 57257271 | **$1,049.42** | Histofil 4000 UI + Turnover Íntimo |

| EAN | Snapshot ticket | Nombre mostrador | Qty | Costo farmacia | PVP +25% |
|---|---|---|---|---|---|
| `7501293201936` | HISTOFIL COLECALCIFEROL 4000 UI 60 TAB \| MED | Histofil 4000 UI | 1 | $325.90 (0% IVA) | $408 |
| `7502235760177` | TURNOVER INTIMO CON 6 APLICADORES DESEC 1 CRE 30 ml \| EXT | Turnover Íntimo | 1 | $623.72 (+ IVA $99.80) | $780 |

## Notas

1. Lab ticket **MED** = Productos Medix. **EXT** = Exeltis.
2. Histofil: colecalciferol 4000 UI, tabletas dispersables, frasco 60. Sin receta.
3. Turnover Íntimo: crema vaginal polinucleótidos 0.2%, tubo 30 ml + 6 aplicadores. Sin receta (Fahorro/YZA).
4. Condiciones: efectivo. Brick 1008016.
5. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
6. Fotos en `public/catalogo-propia/` → tras deploy:
   - `https://www.farmacapital.mx/catalogo-propia/histofil-4000-ui-60-tab.jpg`
   - `https://www.farmacapital.mx/catalogo-propia/turnover-intimo-30ml.jpg`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Fanasa · B49602160**.
3. Escanear cada EAN → MMAA → Guardar renglón.
