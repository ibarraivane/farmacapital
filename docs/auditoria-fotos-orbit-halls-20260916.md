# Fotos oficiales Orbit / Halls / Clorets + faltantes (16-sep-2026)

Las cuatro gomas de Dulcería La Victoria tenían fotos de celular (Open Facts). Se
cambiaron por packshot de la pieza de mostrador. En el mismo pase se cruzó el
listado de 129 SKUs sin foto (`fotos_pendientes_tras_lote_20260914.csv`).

## Qué se reemplazó (improvisada → oficial)

| SKU | Producto | Antes | Ahora |
|---|---|---|---|
| `FC-LV-CLORETS40` | Clorets Plus 4's | Celular Open Facts | Caja oficial 4's (SuperDulces / Mondelez). No hay packshot limpio de la pieza suelta. |
| `FC-LV-ORBITFRE40` | Orbit 4's Fresa | Celular Open Facts | Pieza 4 pastillas (render Mondelez, sin marca de agua) |
| `FC-LV-ORBITHB40` | Orbit 4's Hierbabuena | Celular Open Facts | Pieza 4 pastillas (render Mondelez, sin marca de agua) |
| `FC-LV-HALLSY12` / `7622210267832` | Halls Yerbabuena | Caja de celular | Tubo 25.2 g Fahorro EAN `7622210267832` |

## Faltantes conseguidos (EAN exacto Fahorro)

| SKU | EAN | Producto | Archivo |
|---|---|---|---|
| `FC-LV-SKITTLES24` | 7502226816944 | Skittles Original bolsa 22 g | `skittles-original-22g.jpg` |
| `FC-40071775` | 650240071775 | Nórdiko Original 130 g | `nordiko-original-130g.jpg` |
| `FC-58752796` | 7501058752796 | Lysol Crisp Linen 475 g | `lysol-crisp-linen-475g.jpg` |
| `FC-67923654` | 7506267923654 | Honey Keeper gel manzanilla 200 ml | `honey-keeper-gel-manzanilla-200ml.jpg` |

Skittles: el 10-sep se descartó porque Open Facts solo tenía el dorso. Fahorro sí
tiene el frente de la bolsa.

## Qué pegar en Supabase

1. Deploy de `public/catalogo-propia/` (los 4 JPG reemplazados + 4 nuevos).
2. `sql/patch_fotos_orbit_halls_faltantes_20260916.sql` **después** del deploy
   (`?v=2` en las gomas para que no quede el JPEG viejo en caché).

## Catálogo revisado — lo que sigue sin packshot usable

Se probaron 54 EANs buscables (se omitieron jeringas, goteros, cintas, Mercurio,
EANs `200…` e ítems sin identificar). Fahorro respondió en 4. Nadro i22 = 429.
Open Facts no aportó frentes nuevos.

No se inventó foto cuando el EAN de Fahorro era **otra presentación**:

- Aspirina `7501008491074` (80 tabs): Fahorro tiene 20 y 40, otros códigos.
- Losartán Alpharma / Sarox / Colchicina / LAÜR infantil: sin ficha pública.
- Gerber Etapa 2 100 g, Suerox Vitamins, Nórdiko Icy Blast, Dove 8-pack,
  quitaesmaltes SKN, Xiomara, Brut Deep Blue: sin packshot de ese EAN.
- Insumos y herbolario: misma regla de siempre.

## Fuentes

- Halls / Skittles / Nórdiko / Lysol / Honey Keeper: `production-media.fahorro.com` por EAN.
- Orbit 4's: render oficial (pieza), recorte del triángulo de mayoreo.
- Clorets Plus 4's: packshot oficial de la caja 40×4's (SuperDulces).
