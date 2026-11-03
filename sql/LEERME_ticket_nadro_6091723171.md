# Ticket Nadro 6091723171 → Recibir

Factura Nadro **29-oct-2026** · folio **6091723171** · total **$1,119.31** (subtotal $1,036.14 + IVA 16% $83.17).
UUID CFDI `C371578D-9D96-4DB3-9287-EEEF524F59EB`. Forma de pago: efectivo.

Pegar **todo** `sql/patch_carga_nadro_6091723171.sql` en Supabase → SQL Editor → Run.

## Renglones

| Cant | EAN | Nombre mostrador | Costo | PVP sugerido | Tipo |
|---|---|---|---|---|---|
| 2 | `4015630018277` | Accu-Chek Softclix lancetas | $65.92 | $83 (+25%; catálogo ya $85) | marca |
| 1 | `7502002461290` | Bpollen gel 2.5% | $170.78 | $214 | marca |
| 1 | `7502002461306` | Bpollen gel 5% | $185.63 | $233 | marca |
| 1 | `5016003770500` | Contour Plus tiras reactivas | $136.01 | $171 | marca |
| 1 | `650240032424` | Asepxia polvo compacto Beige Claro | $126.02 | $158 | marca |
| 1 | `650240032431` | Asepxia polvo compacto Canela | $126.02 | $158 | marca |
| 3 | `7501349025844` | Telmisartán 40 mg | $34.00 | $55 (+60%) | genérico AMSA |
| 2 | `7501349025400` | Telmisartán 80 mg | $28.92 | $47 (+60%) | genérico AMSA |

## Notas

1. Nombres de ficha iNadro / packshot, **no** del código del ticket (`MJE ASEPXIA…`, `LGEN`).
2. Marca real: Accu-Chek · Farmapiel · Contour Plus · Asepxia · AMSA. No usar casas Nadro (`EYPRO`, `COSMIATRIA`, `LGEN`, `GENOMMAL`).
3. Contour Plus: EAN canónico pistola **`5016003770500`** (Ascensia).
4. Softclix y Telmisartán 40 mg ya estaban en catálogo: solo actualiza costo si el ticket es distinto; **no baja** un PVP bueno.
5. Stock **0** hasta pistola + MMAA de la caja. No inventar `0000` ni pegar lote/caducidad del PDF.
6. Asepxia Canela: Nadro devolvió placeholder verde «NADRO»; packshot real desde Farmacorp → `catalogo-propia/`.

## Fotos (`public/catalogo-propia/`)

Tras merge/deploy de Vercel:

- `accu-chek-softclix-25-4015630018277.jpg` (ya estaba)
- `bpollen-gel-2.5-7502002461290.jpg`
- `bpollen-gel-5-7502002461306.jpg`
- `contour-plus-tiras-25-5016003770500.jpg`
- `asepxia-polvo-beige-claro-650240032424.jpg`
- `asepxia-polvo-canela-650240032431.jpg`
- `telmisartan-40mg-28tab-7501349025844.jpg`
- `telmisartan-80mg-14tab-7501349025400.jpg`

## Después del SQL

1. Recargar Recibir en la tablet.
2. Debe aparecer el botón **Nadro 6091723171** (no pisa otros tickets vivos).
3. Escanear → MMAA → Guardar renglón.
