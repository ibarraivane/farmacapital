# Nadro 6092422484 → Recibir

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

| Proveedor | Folio | Fecha | Total | Renglones |
|---|---|---|---|---|
| Nadro | **6092422484** | 17-nov-2026 | $774.92 | 7 |

## Pasos

1. Supabase → SQL Editor → New query
2. Pegar `sql/patch_carga_nadro_6092422484_SOLO_pegar_esto.sql` → **Run**
3. VERIFICACION: folio `6092422484` en `borrador`, 7 renglones, `sin_confirmar = 7`
4. Tablet: Recibir → recargar

## Renglones

| EAN | Snapshot CFDI | SKU | Mostrador | Qty | P.U. |
|---|---|---|---|---|---|
| `7501300420541` | ALIKAN 500/300MG CAPS 24 | `FC-00420541` | Aliren 50/3/300 mg | 1 | $126.25 |
| `7502009749698` | BROMHEXINA/GUAIF 60/120… | `FC-09749698` | Bromhexina/oxeladina | 2 | $81.44 |
| `7502211783275` | ERITRAX … TBO15G | `FC-11783275` | Erbitrax 1% 15 g | 1 | $25.32 |
| `7502231321778` | OLOPATADINA 2.0MG/ML | `FC-31321778` | Olopatadina 2 mg/ml | 1 | $132.72 |
| `7502211783282` | TERBINAFINA CRA 1% 30 G | `FC-11783282` | Erbitrax 1% 30 g | 1 | $32.39 |
| `7590002012475` | VAPORUB REG UNG 100 G | `FC-02012475` | Vicks VapoRub 100 g | 1 | $185.09 |
| `7590002012468` | VAPORUB REG UNG 50 G | `FC-02012468` | Vicks VapoRub 50 g | 1 | $110.27 |

## Notas

- CFDI OCR: Aliren salía `…0641` (dígito mal) → canónico `7501300420541`.
- «BROMHEXINA/GUAIF» Maver 60/120 = **bromhexina/oxeladina** `7502009749698` (no LGEN como marca).
- Caducidad **null** hasta MMAA de la caja.
- IFC **134202** y Farma Mayoreo **V01000004500** ya van en el lote 17-nov (PR #551 / `patch_recibir_tickets_1711_SOLO_pegar_esto.sql`).
