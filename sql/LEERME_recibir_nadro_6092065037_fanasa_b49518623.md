# Tickets Recibir · Nadro 6092065037 + Fanasa B49518623

## Pegar en Supabase

1. Supabase → SQL Editor → New query
2. Copia **todo** el SQL de abajo en el chat (o el archivo `sql/patch_recibir_nadro_6092065037_fanasa_b49518623_SOLO_pegar_esto.sql`) → **Run**
3. Debe salir `VERIFICACION FINAL` con folios `6092065037` y `B49518623` en `borrador`
4. Tablet Recibir → recargar

| Folio | Proveedor | Fecha | Total | Renglones |
|---|---|---|---|---|
| **6092065037** | Nadro | 08-nov-2026 | $1,507.27 | 3 |
| **B49518623** | Fanasa | 09-nov-2026 | $257.67 | 1 |

## Nadro 6092065037

CFDI `74991B89-39FB-4CF5-BFC6-BB6EBB4F7352` · efectivo · entrega FarmaCapital.

| Cant | EAN | Nombre mostrador | Costo | PVP | Tipo |
|---|---|---|---|---|---|
| 1 | `7501349029460` | Diosmina Hesperidina 450/50 mg | $49.88 | $80 (+60%) | genérico AMSA |
| 1 | `7502235760276` | Transvital D | $358.97 | $449 (+25%) | marca Exeltis |
| 1 | `7501101600630` | Vaxtifen 20/160 mg | $1,040.98 | $1,302 (+25%) | marca Silanes |

Notas: no usar `LGEN` como marca. IVA 16% solo en Transvital ($57.44); el costo del renglón es sin IVA. Distinto del Diosmina Beadvance `7501342804484` / `FC-EADF1484`.

## Fanasa B49518623

Pedido **57125564** · efectivo · FarmaCapital La Capi.

| Cant | EAN | Nombre mostrador | Costo | PVP | Tipo |
|---|---|---|---|---|---|
| 1 | `7501088542865` | Meladinina 10 mg | $257.67 | $323 (+25%) | marca Chinoin |

Lab ticket **PRO** = Productos Farmacéuticos Chinoin. Principio: metoxaleno (ammoidin).

## Fotos (`public/catalogo-propia/`)

Visibles tras deploy Vercel:

- `diosmina-hesperidina-450-50-20tab-7501349029460.jpg`
- `transvital-d-30caps-7502235760276.jpg`
- `vaxtifen-20-160-30tab-7501101600630.jpg`
- `meladinina-10mg-30tab-7501088542865.jpg`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Botones **Nadro 6092065037** y **Fanasa · B49518623**.
3. Escanear → MMAA de la caja → Guardar. Stock 0 hasta confirmar. No inventar `0000`.
