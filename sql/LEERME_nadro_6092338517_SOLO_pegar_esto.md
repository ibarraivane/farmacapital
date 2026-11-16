# Nadro 6092338517 → Recibir

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

| Proveedor | Folio | Fecha | Total | Renglones |
|---|---|---|---|---|
| Nadro | **6092338517** | 15-nov-2026 | $1,350.91 | 11 |

## Pasos

1. Supabase → SQL Editor → New query
2. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_nadro_6092338517_SOLO_pegar_esto.sql
3. Selecciona TODO → copiar → pegar → **Run**
4. Abajo: VERIFICACION con folio `6092338517` en `borrador` (11 renglones)
5. Tablet: Recibir → recargar

## Renglones

| EAN | Snapshot ticket | SKU | Mostrador | Qty | Costo |
|---|---|---|---|---|---|
| 7506306246874 | ACOND SEDAL HIDRATACION 620 ML | `FC-06246874` | Sedal Hidratación Anti-nudos | 1 | $40.13 |
| 7501318612655 | ASPIRINA PROTECT 100MG 28 TAB | `FC-18612655` | Aspirina Protect 100 mg | 2 | $150.23 |
| 7501417010253 | CARBONATO-MAG PANES 7 G | `FC-17010253` | Carbonato de magnesio | 3 | $25.06 |
| 7501349028586 | DICLOF/LIDOC/COMPB S.I. 5MG LGEN | `FC-49028586` | Combedi DL | 1 | $38.91 |
| 7506306245990 | JBN ZEST AQUA FRESCO 135 G | `FC-06245990` | Zest Aqua | 1 | $12.67 |
| 7506306246096 | JBN ZEST MEN HINOJO SAL MAR 135G | `FC-06246096` | Zest Men Hinojo y sales marinas | 1 | $12.67 |
| 7506306246058 | JBN ZEST NEUTRO SVE BALANC 135 G | `FC-06246058` | Zest Neutro Suave Balance | 1 | $12.67 |
| 7506306246010 | JBN ZEST PEPINO SABILA RENO 135G | `FC-06246010` | Zest Pepino y sábila | 1 | $12.67 |
| 7501361606205 | SINUBERASE 12 CAPS | `FC-61606205` | Sinuberase | 2 | $193.72 |
| 7501159580014 | SINUBERASE CPR 48 | `FC-59580014` | Sinuberase | 2 | $169.09 |
| 7501349029019 | TIA/PIRI/CI 100MG S.I. 5AMP LGEN | `FC-49029019` | Tiamina / piridoxina / cianocobalamina 100/50/10 mg | 2 | $46.68 |

## Notas

- EANs tomados de iNadro (ficha), no del OCR de la foto.
- Combedi DL y Combedi B iny: AMSA; PVP sugerido con recargo genérico +60%.
- Caducidad **null** hasta MMAA de la caja.
