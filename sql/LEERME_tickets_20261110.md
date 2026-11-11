# Tickets 10-nov-2026 → Recibir

Incluye Benavides del 09-nov (misma tanda de fotos). Pegar **todo** el SQL abajo en el chat / `sql/patch_recibir_tickets_1011_SOLO_pegar_esto.sql` en Supabase → SQL Editor → Run.

## Tickets

| Proveedor | Folio | Total | Renglones |
|---|---|---|---|
| Benavides | **7993605** | $2,208.00 | 1 |
| Cityfarma Iztapalapa | **S339687** | $3,211.17 | 18 |
| Equilibrio | **451326** | $202.63 | 2 |
| Farmalive | **16337** | $1,912.97 | 18 |
| Bodega F-42 | **28786** | $2,319.12 | 43 |
| Farmacias Especializadas | **1-5573418** | $1,084.46 | 1 |

## Notas

1. **Benavides 7993605:** ecommerce PayPal · EAN Vedipal `7730766001562` (no venía en el ticket).
2. **Cityfarma S339687:** ALMACEN · EANs validados por dígito de control.
3. **Equilibrio 451326:** claves SON → EAN Sons. Lote/cad del papel **no** se guarda.
4. **Farmalive 16337:** costo = P.U. **neto** tras descuento de renglón. Tukol EAN canónico `6502400315021`.
5. **Bodega F-42 28786:** Caja 4 · P.U. ya con IVA · stick Axe usan SKU corto (EAN 8 dígitos del ticket).
6. **FESA 1-5573418:** ACTÚA 2+1 Vilzermet → **3** piezas, costo unitario $361.49.
7. **Stock:** 0 hasta pistola + MMAA. No poner `0000`.
8. **Fotos:** varias ya en `catalogo-propia/`; el resto queda pendiente (no bloquea Recibir).

## Después del SQL

1. Recargar Recibir en la tablet.
2. Deben aparecer **6 botones** nuevos.
3. Escanear → MMAA → Guardar renglón.
