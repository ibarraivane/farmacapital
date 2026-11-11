# Tickets 09–10-nov-2026 → Recibir

Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_0911_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.


## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Bodega F-42 | **383312** | $611.15 | 7 |
| IFC F8 Tienda | **132888** | $118.00 | 2 |
| Farmaceuticos Tenorio | **3854927** | $1,334.26 | 9 |
| Farmaceuticos Tenorio | **3857153** | $2,567.43 | 2 |
| Cityfarma Iztapalapa | **S339688** | $178.21 | 1 |

## Notas

1. **Bodega F-42 383312:** Caja 4 · P.U. ya con IVA. Folio leído del **CODE128** del pie (el encabezado `Caja 4/…` venía doblado). Si el papel muestra otro número, avisa y lo renombramos.
2. **IFC 132888:** menudeo · Aceite romero → EAN `3311000001537` (SKU `FC-38CAFE6B`) · Mertodol Jaloma → EAN `759684313257` (mismo frasco que en Bodega).
3. **Tenorio 3854927:** costo = importe/cantidad · IVA $0 · Laur EAN canónico `7502001166981` · Precazit `7506494600465`.
4. **Tenorio 3857153:** Relozibin EAN `7506331302002` · Systane UPC `300651429312` · IVA $78.29 solo en Systane (costo = importe sin IVA).
5. **Cityfarma S339688:** Tempra jarabe infantil EAN `7501058714305` · **pendiente de pago** $178.21 en el papel.
6. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
7. **Fotos:** GUM + enhebrador / Aktyzar / Bacat C/30 ya en `catalogo-propia/`; el resto pendiente (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **5 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.
