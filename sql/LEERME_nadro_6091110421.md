# Nadro folio 6091110421 · 13-oct-2026 · $644.52

Fotos factura (códigos EAN + cantidades circuladas + totales).

## Veredicto

**Ticket nuevo.** 6 renglones. Amcef IM 500 mg ya estaba; el resto es alta.

| EAN | Ticket | SKU | Nombre mostrador | Acción |
|---|---|---|---|---|
| `7501349012011` | AMCEF CEFTRIA 1G SI FA 10ML LGEN ×1 | `FC-49012011` | Amcef IV 1 g | Alta + foto |
| `7501349011007` | AMCEF IM CEFT500MG SI FA2ML LGEN ×4 | `FC-49011007` | Amcef IM 500 mg | Solo costo + ficha |
| `7501022112274` | C-BOOST SUP ALIM OMEGA3 FCO 90GOM ×1 | `FC-22112274` | C-Boost Omega 3 + vitaminas C, D y E | Alta + foto |
| `7501853805253` | COLAG/BIOT/A HIA S ALIM FSA 14GOM ×2 | `FC-53805253` | Natural Health colágeno + biotina + ácido hialurónico | Alta + foto |
| `7503024083439` | JUST OMEGA3 S ALIM DHA EPA 120 GOM ×1 | `FC-24083439` | Just Omega 3 DHA y EPA | Alta + foto |
| `7502226293929` | METFORMINA LP 500 MG 30 TAB LGEN ×2 | `FC-26293929` | Metformina LP 500 mg | Alta + foto |

### Amcef IV vs IM 1 g

Este ticket trae **IV 1 g / 10 ml** (`7501349012011`). El catálogo ya tenía
**IM 1 g / 3.5 ml** (`7501349012004` / `FC-BE76D409`). No se mezclan.

## Qué pegar en Supabase

1. `sql/patch_carga_nadro_6091110421.sql` — altas + cola Recibir borrador.
2. Tras deploy Vercel: `sql/patch_fotos_nadro_6091110421.sql`.

CSV: `sql/generated/ticket_nadro_6091110421.csv`.

Stock **0** hasta escanear con pistola y capturar MMAA de la caja.

### Fotos

Packshots en `public/catalogo-propia/` (Amcef Farmamedical, C-Boost packshot real copiado, Just Omega BuscaMed, Metformina Alpharma). Natural Health 14 gomitas: imagen del **reverso del sobre** (confirma EAN `…05253`); si aparece el frente del pouch, reemplazar.

Amcef costos con **OFTA 15%** del ticket (VALOR UNITARIO 19.80 / 16.10, no PR FAR sin oferta).

Regenerar: `python3 scripts/generar_carga_nadro_6091110421.py`
