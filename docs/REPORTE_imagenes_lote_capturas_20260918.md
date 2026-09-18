# FarmaCapital — fotos del lote de capturas (18-sep-2026)

Cuatro agentes buscaron packshots de las tarjetas de tienda (caja vacía o foto mala).
SQL: `sql/patch_fotos_lote_capturas_20260918.sql` **después del deploy**.

## Resultado

| | |
|---|---|
| Fotos nuevas en `catalogo-propia/` | **20** |
| Siguen sin foto usable | **3** (Dextrometorfano Gendibar, Dexketoprofeno Gendibar, FC producto botiquín) |
| Fotos actuales que se dejan | Desrotan, Desyn-N (sí son la caja) |

## Entran

### Medicamentos

| Producto | EAN | Fuente |
|---|---|---|
| Dorixina Forte 250 mg C/20 | `7501300422750` | Farmatodo (Siegfried Rhein) |
| Dosteril lisinopril 10 mg C/30 | `7501573925071` | BS Pharma |
| Dolxen naproxeno 250 mg C/20 | `7502009740176` | BS Pharma |
| Dolac ketorolaco SL 30 mg C/6 | `7501300420824` | Farmatodo. **No** es `7501300422750` (eso es Dorixina) |
| Debisor 10 mg C/20 Novag | `7501075711011` | BS Pharma. No es el Debisor 5 mg sublingual |
| Contraxen 200/250 C/30 | `7501836003140` | Farmacia Herrera |
| Coniax citicolina 500 mg C/10 | `7502009749322` | Sanorim · SKU `EQ-MAV394` |

### Desodorantes

| Producto | EAN | Fuente |
|---|---|---|
| Savilé manzanilla stick 45 g | `75065102` | DelSol |
| Savilé sábila + nácar spray 150 ml | `7506306215511` | DAX |
| Savilé manzanilla spray 150 ml | `7506306209763` | DelSol |
| Rexona Women Bamboo roll-on 50 ml | `78924345` | DelSol |
| Old Spice **Mar Profundo** spray 150 ml | `7500435141796` | DelSol. El ticket `MAR PROF` es Mar Profundo, no Mariner |
| Lady Speed Stick Powder Fresh roll-on 50 ml | `7509546060477` | DelSol |
| Lady Speed Stick Powder Fresh spray 60 g | `7509546071275` | Farmacia San Jorge (508 px; misma línea Powder Fresh) |
| Gillette Arctic Ice spray 150 ml | `7506309864822` | Farmacorp. Ticket `ENDUR ARTIC` |
| Gillette Cool Wave roll-on 60 g | `7702018913954` | DelSol. Ticket `3X CL WAVE` = Cool Wave, no Clinical |

### Internos / reemplazo

| Producto | EAN | Nota |
|---|---|---|
| Cubrebocas tricapa **negro** | `2008500100013` | Imagen genérica negra (el dueño la pidió así). Sin logo de otra farmacia |
| Dona IJJ-10 C/12 | `2008550100018` | Dona de chongo negra, pieza suelta |
| Copa lavaojos de vidrio | `2008490100017` | Copa sola (no la bolsa Cali). Resolución baja |
| Trojan Pro-Tech C/3 | `7501080950139` | **Reemplaza** la foto lifestyle (pareja). Caja azul C/3 |

## No se tocan / no hay foto

| Producto | Por qué |
|---|---|
| Desrotan 180 mg C/10 | La caja rosa de la captura **sí** es Raam. No pisar |
| Desyn-N 60/5 C/6 | La caja blanca/azul **sí** es Loeffler. No pisar |
| Dextrometorfano 1 Jbe 120 ml | Sigue el watermark Gendibar. No hay packshot MX limpio (Randall `7501563380408` solo tiene render en portugués) |
| Dexketoprofeno 10 Tab 25 mg | Sigue Gendibar. Alpharma MX `7502226295954` sin packshot limpio (la caja en red está en portugués) |
| FC producto botiquín | `Fc 01711/2030` no identifica el objeto. Foto propia |

## Orden

1. Merge / deploy (los JPG viven en `public/catalogo-propia/`).
2. Pegar `sql/patch_fotos_lote_capturas_20260918.sql` en Supabase.
