# Tenorio folio 3838940 · 02-nov-2026 · $1,148.52

Factura Farmacéuticos Tenorio (foto). Cliente **20077** Palillero Ventura. Ref **2150638**.

## Veredicto

**Ticket nuevo.** 6 renglones, 37 piezas. Gelubrin ya estaba; el resto es alta.

| EAN | Ticket | SKU | Nombre mostrador | Qty | Costo |
|---|---|---|---|---|---|
| `7503027446279` | GELUBRIN 600MG CAP C/10 *PRO* | `FC-5C8C9C11` | Gelubrin 600 mg | 30 | $18.11 |
| `7502003386547` | GEMFIBROZILO 600MG TAB C/14 *RAY* | `FC-03386547` | Raypid 600 mg | 2 | $89.19 |
| `7502009746222` | DEXKETOPROFENO 25MG TAB C/10 *MVE* | `FC-09746222` | Doxon 25 mg | 2 | $59.00 |
| `7502009748844` | DEXKETOPROFENO 25MG TAB C/20 *MVE* | `FC-09748844` | Doxon 25 mg | 1 | $113.77 |
| `7503045798336` | DEXKETOPROFENO 25MG/10ML SOBRES | `FC-45798336` | Dexketoprofeno 25 mg/10 ml | 1 | $80.96 |
| `7501300420541` | ALIREN 50/3/300MG CAP C/24 *SGF* | `FC-00420541` | Aliren 50/3/300 mg | 1 | $114.11 |

### Notas

1. Costo unitario = importe ÷ cantidad (IVA $0).
2. Lote de la factura. Caducidad **null** → MMAA de la caja. No `0000`.
3. Dexketoprofeno sobres (`7503045798336`): marca no salió en ficha pública; nombre por molécula.
4. Fotos: Gelubrin / Raypid / Doxon C/10 / Aliren en `catalogo-propia/`. Doxon C/20 y sobres: pendientes.

## Qué pegar en Supabase

1. `sql/patch_carga_tenorio_3838940.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: las URLs `farmacapital.mx/catalogo-propia/…` ya apuntan a las fotos del PR.

CSV: `sql/generated/ticket_tenorio_3838940.csv`.

Stock **0** hasta pistola + MMAA.

Auditoría de tickets recientes: `sql/diag_recepciones_recientes_20261103.sql`.

Regenerar: `python3 scripts/generar_carga_tenorio_3838940.py`
