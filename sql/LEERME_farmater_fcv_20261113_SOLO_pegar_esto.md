# Farmater FCV-20261113 → Recibir

El merge a GitHub **no** crea la cola. Hay que **Run** el SQL en Supabase.

| Proveedor | Folio | Total | Renglones | Altas nuevas |
|---|---|---|---|---|
| Cityfarma Iztapalapa | **FCV-20261113** | $1,153.37 | 15 | 6 |

## Pasos

1. Supabase → SQL Editor → New query
2. Raw: https://raw.githubusercontent.com/ibarraivane/farmacapital/main/sql/patch_recibir_farmater_fcv_20261113_SOLO_pegar_esto.sql
3. Selecciona TODO → copiar → pegar → **Run**
4. Abajo: VERIFICACION con folio `FCV-20261113` en `borrador` (15 renglones)
5. Tablet: Recibir → recargar

## Renglones

| EAN | Snapshot carrito | SKU | Mostrador | Qty | P.U. |
|---|---|---|---|---|---|
| 7502231321778 | OLOPATADINA 2.0MG/ML GTS OFT 5ML *MIC* | `FC-31321778` | Olopatadina 2 mg/ml | 1 | $139.25 |
| 7501300420541 | ALIREN 50/3/300MG CAP C/24 *SGF* | `FC-00420541` | Aliren 50/3/300 mg | 1 | $118.68 |
| 7500462933746 | INHA-RUB UNG 40GR *ADN* | `FC-62933746` | Inha-Rub | 1 | $19.89 |
| 7590002012475 | VICK VAPORUB UNG 100GR *P&G* | `FC-02012475` | Vicks VapoRub | 1 | $194.38 |
| 7501573900269 | *FC* QUITADOL 750MG. TAB. C/10 *BMP* | `FC-73900269` | Quitadol 750 mg | 5 | $7.78 |
| 7502211783282 | *FC* ERBITRAX 1% CREMA 30GR. *LOE*PI | `FC-11783282` | Erbitrax 1% | 2 | $24.35 |
| 7502211783275 | *FC* ERBITRAX 1% CREMA 15GR. *LOE* | `FC-11783275` | Erbitrax 1% | 2 | $18.90 |
| 7501537102395 | *FC* NORAPRED 50MG. TAB. C/20 *BRU* | `FMX-502376` | Norapred 50 mg | 3 | $31.43 |
| 7501537103484 | *FC* OXOLBRUL ADT 225/225MG/100ML SOL 120M | `FC-37103484` | Oxolbrul adulto | 2 | $20.12 |
| 7502009746239 | *FC* ERISPAN COMPUESTO 5.0/0.25MG TAB C/10 | `EQ-MAV295` | Erispan compuesto 5/0.25 mg | 3 | $8.38 |
| 7502009740916 | *FC* ERISPAN 8MG/2ML SOL INY. C/1 *MVE* | `FC-50AC2C82` | Erispan Hypack 8 mg/2 ml | 3 | $23.31 |
| 7501109790739 | *FC* CADP 11-2027 NORMEX 8.5GR SUSP 60ML.  | `FC-09790739` | Normex leche de magnesia | 2 | $12.02 |
| 7503008344785 | *FC* GELUBRIN 400MG CAP C/10 *PRO* | `EQ-PGE033` | Gelubrin 400 mg | 10 | $12.27 |
| 7501842900099 | *FC* ADOPREN 400MG TAB C/10 *GEN* R | `FC-42900099` | Adopren 400 mg | 3 | $10.82 |
| 7501125100130 | *FC* SOLUC. CS 1000ML. *PIS* R | `FMX-503320` | Solución CS 0.9% | 4 | $36.73 |

## Notas

- Folio interno `FCV-20261113` porque el carrito aún no tenía No. de pedido en las fotos.
- Normex viene como CADP 11-2027 en vitrina: **caducidad null** hasta MMAA de caja.
- Fotos pendientes (alta sin packshot en `catalogo-propia/`): Olopatadina, Inha-Rub, Quitadol 750, Erbitrax 15 g, Oxolbrul, Adopren 400.
