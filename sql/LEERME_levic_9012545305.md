# Ticket Levic · A 9012545305

**Fecha CFDI:** 2026-10-26 (America/Mexico_City) · Hoja 1 de 2 · TOT 59 pzas
**Total:** $1844.92 (subtotal $1750.53 + IVA $94.39)
**IVA:** Cintapore $20.07 + Microdacyn $74.32 · PUE efectivo
**Folio fiscal (OCR foto):** `B57229E5-7DBB-4B9F-A23E-B1D28E33B872` — confirmar en PDF/timbre
**Receptor:** LUIS ANGEL PALILLERO VENTURA

## Renglones

| # | Clave | Ticket | Cant | Neto | EAN | SKU | Match |
|---|-------|--------|------|------|-----|-----|-------|
| 1 | `ALP0598` | `ACETONIDO DE FLUOCINOLONA CMA 40/01/100G` | 5 | $19.79 | `7503004908721` | `FC-1BF03D35` | recibir |
| 2 | `ALP0673` | `ACETONIDO DE FLUOCINOLONA CMA 20/01/100G` | 5 | $11.46 | `7502226294476` | `EQ-ALP0673` | alta |
| 3 | `BEA215` | `DICLOFENACO 20 TAB 100 MG` → **caja AMSA iny** | 5 | $7.67 | `7501349025929` | `EQ-AMS362` | recibir |
| 4 | `BIO149` | `LOZAMIR V C/3 APLICS 1 CMA 2% 20G` | 5 | $22.52 | `7501573906407` | `FC-73906407` | recibir |
| 5 | `BIO213` | `SAROX 28 CAPS 20 MG` | 5 | $15.00 | `7501573909859` | `FC-73909859` | recibir |
| 6 | `BRU053` | `NEDICLON 20 GRAG 100 MG` | 20 | $8.84 | `7501537102845` | `EQ-BRU053` | recibir |
| 7 | `BRU070` | `SOLTRIM 1 SUSP 40/200/5/120 ML` | 2 | $28.00 | `7501537102067` | `EQ-BRU070` | alta |
| 8 | `CHI029` | `MYDOCALM A 30 CAPS 300 MG/50 MG` | 1 | $363.75 | `7501088545658` | `EQ-CHI029` | alta |
| 9 | `COD106` | `CINTAPORE PIEL 12 PZAS 2.5 CM X 5 M` | 1 | $125.43 | `7506484500034` | `FC-84500034` | recibir |
| 10 | `FAC0059` | `MOTILAXIL 20 TAB 5 MG` | 5 | $17.95 | `7502006920021` | `FC-06920021` | recibir |
| 11 | `RAM092` | `RAAMCEDO 10 TAB 100 MG` | 2 | $46.04 | `7502227874417` | `EQ-RAM092` | alta |
| 12 | `SFE159` | `MICRODACYN 1 SOL 120 ML` | 3 | $154.84 | `7503006698316` | `FC-06698316` | recibir |

## Cómo aplicar

1. Pegar `sql/patch_carga_levic_9012545305.sql` en Supabase → SQL Editor → Run.
2. Recibir → pistola → MMAA de la caja. No poner `0000`.
3. **BEA215 en factura, caja AMSA:** el papel dice Beadvance 20 tab; en mostrador llegó AMSA iny 75 mg/3 mL C/2 (`7501349025929` / `EQ-AMS362`). Pegar `sql/patch_levic_9012545305_bea215_a_amsa.sql`.
4. Packshots de altas ya están en `public/catalogo-propia/` (imagen_url apunta a farmacapital.mx; aplica **después** del deploy).

## Altas nuevas

- `EQ-ALP0673` · Acetónido de fluocinolona Alpharma crema 0.01% · Tubo 20 g · EAN `7502226294476` · foto ok
- `EQ-BEA215` · alta por factura (Beadvance); **no recibir esa caja** — renglón redirigido a AMSA `EQ-AMS362` / `7501349025929`
- `EQ-BRU070` · Soltrim trimetoprima/sulfametoxazol 40/200 · Frasco suspensión 120 mL · EAN `7501537102067` · foto ok
- `EQ-CHI029` · Mydocalm-A paracetamol/tolperisona 300/50 mg · Caja con 30 cápsulas · EAN `7501088545658` · foto ok
- `EQ-RAM092` · Raamcedo aceclofenaco 100 mg · Caja con 10 tabletas · EAN `7502227874417` · foto ok

## Archivos

- `sql/generated/ticket_levic_9012545305.csv`
- `sql/patch_carga_levic_9012545305.sql`
- `scripts/generar_carga_levic_9012545305.py`
