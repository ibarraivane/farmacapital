# Tickets 09-nov-2026 → Recibir

Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_0911_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Bodega F-42 | **383312** | $611.15 | 7 |
| IFC F8 Tienda | **132888** | $118.00 | 2 |

## Notas

1. **Bodega F-42 383312:** Caja 4 · P.U. ya con IVA. Folio leído del **CODE128** del pie (el encabezado `Caja 4/…` venía doblado). Si el papel muestra otro número, avisa y lo renombramos.
2. **IFC 132888:** menudeo · Aceite romero → EAN `3311000001537` (SKU `FC-38CAFE6B`) · Mertodol Jaloma → EAN `759684313257` (mismo frasco que en Bodega).
3. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
4. **Fotos:** GUM + enhebrador ya en `catalogo-propia/`; Colgate / Oral-B / Mertodol 40 ml pendientes (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **2 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.
