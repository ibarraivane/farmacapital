# Ticket Fanasa B49626014 → Recibir

Factura Fanasa (19-nov-2026) entregada a FarmaCapital La Capi. Pegar **todo** `sql/patch_ticket_fanasa_b49626014_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Raw de main (después del merge)

https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_ticket_fanasa_b49626014_SOLO_pegar_esto.sql

## Ticket

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Fanasa | **B49626014** | $341.78 | Histofil 8000 · 30 tabletas ×1 |

## Notas

1. EAN `7501293203268`. Marca **Histofil**, lab **Medix**. Principio: colecalciferol 8000 UI. Presentación: caja con frasco con 30 tabletas (PLM).
2. Costo farmacia **$341.78** (tasa 0%). PVP sugerido marca **+25%** → **$428**. Precio público Fanasa $525 (referencia, no se publica como ancla).
3. Pedido Fanasa **57265818**. Condiciones: efectivo.
4. **Stock:** 0 hasta pistola + MMAA de la caja. No poner `0000`.
5. Foto en `public/catalogo-propia/histofil-8000-30tab-7501293203268.jpg` → tras deploy: `https://www.farmacapital.mx/catalogo-propia/histofil-8000-30tab-7501293203268.jpg`.

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Fanasa · B49626014**.
3. Escanear `7501293203268` → MMAA → Guardar renglón.
