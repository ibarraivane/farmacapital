# Fotos oficiales Orbit / Halls / Clorets + faltantes (16-sep-2026)

Las cuatro gomas de Dulcería La Victoria tenían fotos de celular (Open Facts). Se
cambiaron por packshot de la pieza de mostrador. Snapshot vivo (16-sep): **1550**
activos, **90** sin `imagen_url` (88 con stock). Se cruzaron los 42 EANs/nombres
buscables; se omitieron jeringas, cintas, Mercurio, EANs `200…` e ítems sin
identificar.

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
| `FC-LV-HALLSX12` | (sin EAN) | Halls Extra Strong | `halls-extra-strong.jpg` · Benavides, pieza |
| `FC-LV-SKITTLES24` | 7502226816944 | Skittles Original bolsa 22 g | `skittles-original-22g.jpg` (copia propia; en vivo ya apuntaba a Fahorro) |
| `FC-40071775` | 650240071775 | Nórdiko Original 130 g | `nordiko-original-130g.jpg` |
| `FC-58752796` | 7501058752796 | Lysol Crisp Linen 475 g | `lysol-crisp-linen-475g.jpg` |
| `FC-67923654` | 7506267923654 | Honey Keeper gel manzanilla 200 ml | `honey-keeper-gel-manzanilla-200ml.jpg` |

## Por qué se veían igual (16-sep tarde)

El SQL se pegó **antes** del deploy. `?v=2` sigue sirviendo el JPG de celular
(el archivo en Vercel no cambió). Extra Strong, Skittles y Nórdiko apuntaban a
`catalogo-propia/…` que **aún no existe** en el CDN (el SPA devuelve HTML).

La galería no rotó a principal: el `LIKE` del primer SQL trató la URL vieja
como si ya estuviera.

**Corrección:** el mismo archivo SQL ahora usa packshots que ya cargan
(Fahorro / Scorpion / SuperDulces / Benavides). Pegarlo de nuevo. No espera
deploy. Las copias en `public/catalogo-propia/` quedan para el merge.

## Alka-Seltzer Boost: caja en Gastro, foto en la ficha

La tarjeta de categoría usa solo `es_principal`. En Boost C/10 esa URL es
`catalogo-propia/alka-seltzer-boost-c10.jpg`, que **no está en el CDN** (Vercel
devuelve `index.html` → el `<img>` falla → icono de caja). Al entrar, la ficha
carga toda `producto_imagenes` (Rappi `1.png`…`4.jpg`) y se ve el packshot.

Mismo patrón en **54** productos (principal propia 404 + galería Rappi viva).

- Código: la tarjeta prueba la galería si la principal no carga.
- SQL: `sql/patch_fotos_tarjeta_galeria_20260916.sql` (pega en Supabase; no espera deploy).
- Archivo: `public/catalogo-propia/alka-seltzer-boost-c10.jpg` para el merge.

## Catálogo revisado — lo que sigue sin packshot usable

Vivo: 90 sin foto. De los 42 buscables, Fahorro/Benavides no tenían packshot de
ese EAN (genéricos Novag/Maver/Raam, Gerber 100 g, quitaesmalte SKN, alcohol
Dibar 250 ml, etc.). Nadro i22 = 429. Open Facts no aportó frentes nuevos.

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
