# Nadro folio 6091110421 · 13-oct-2026 · $720.23

Factura CFDI Nadro México Sur (foto 14-oct-2026) · 6 renglones · 11 piezas.

## Veredicto

| EAN pistola | Ticket | SKU | Piezas | Costo u. | Acción |
|---|---|---:|---:|---:|---|
| `7501349012011` | AMCEF CEFTRIA 1G SI FA 10ML LGEN | `FC-49012011` | 1 | $19.80 | **Alta nueva** (IV 1 g / 10 ml) |
| `7501349011007` | AMCEF IM CEFT500MG SI FA 2ML LGEN | `FC-07F04F88` | 4 | $16.10 | Ya en catálogo (Amcef IM 500 mg) |
| `7501022112274` | C-BOOST SUP ALIM OMEGA3 FCO 90GOM | `FC-22112274` | 1 | $118.18 | **Alta nueva** |
| `7501853805253` | COLAG/BIOTA HIA S ALIM FSA 14GOM | `FC-53805253` | 2 | $49.01 | **Alta nueva** (Glowy SKN / Natural Health) |
| `7503024083439` | JUST OMEGA3 S ALIM DHA EPA 120 GOM | `FC-24083439` | 1 | $188.48 | **Alta nueva** |
| `7502226293929` | METFORMINA LP 500 MG 30 TAB LGEN | `FC-26293929` | 2 | $77.82 | **Alta nueva** (Alpharma) |

Suma importes (sin IVA/IEPS): $644.52 · Total CFDI: **$720.23** ✓

## EAN corregidos (foto / OCR)

| Producto | OCR foto | Pistola (válido iNadro) |
|---|---|---|
| Just Omega 3 | `7503024083438` (check digit inválido) | **`7503024083439`** |
| Metformina LP | `7502226303829` (check digit inválido) | **`7502226293929`** |

## Qué pegar en Supabase

**Si el ticket no aparece en Recibir**, pega primero solo la cola:

1. `sql/patch_recepcion_nadro_6091110421_cola.sql` — borrador + 6 renglones (sin altas).
2. El `SELECT` final debe mostrar `renglones = 6` y `sin_confirmar = 6`.
3. Luego (opcional, para fichas/precios): `sql/patch_carga_nadro_6091110421.sql`.
4. Tras deploy Vercel: `sql/patch_fotos_nadro_6091110421.sql`.

Diagnóstico: `sql/diag_nadro_6091110421.sql`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

## Notas de ficha

- **Amcef IV 1 g:** distinto del Amcef IM 1 g (`FC-BE76D409` / `7501349012004`). Diluyente agua 10 ml.
- **Amcef IM 500 mg:** ya existe como `FC-07F04F88`; el patch enlaza EAN si faltaba.
- **C-Boost Omega 3:** Grisi / C-Boost, 90 gomitas (no confundir con C-Boost colágeno `7501022112250`).
- **Glowy SKN:** bolsa Natural Health «Ready to Go» 14 gomitas; no es el frasco de 100/120.
- **Just Omega 3:** Olnatura Just, sabor mandarina, 120 gomitas.
- **Metformina LP:** Alpharma genérico, frasco 30 tabletas.

## Recibir

Subir también `sql/generated/ticket_nadro_6091110421.csv` si prefieren CSV en lugar del SQL.

Regenerar: `python3 scripts/generar_carga_nadro_6091110421.py`
