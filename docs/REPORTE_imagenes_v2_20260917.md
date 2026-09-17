# FarmaCapital — SKUs sin imagen, lote 2 (revisión visual)

Tenías razón: buscar solo por código de barras dejaba fuera todo lo que no está
indexado así. Esta corrida busca **por nombre**, como lo haces tú, y agrega el
paso que faltaba: **mirar cada imagen antes de aceptarla**.

## Lo que cambió

| | Lote 1 (15-sep) | Lote 2 (17-sep) |
|---|---|---|
| Productos con imagen | 52 | **61** |
| Imágenes totales | 63 | **70** |
| Con carrusel (2+) | 7 | 6 |
| Rechazadas al mirarlas | — | **10** |
| Siguen sin imagen | 60 | **51** |

## Lo más importante: te entregué imágenes malas en el lote 1

Nunca las miré. Al renderizarlas una por una encontré esto, y ya está corregido
en los archivos nuevos:

| Producto | Fuente | Qué pasaba |
|---|---|---|
| 1765 Dolver, 1786 Odivitor, 1787 Frinver | curitek | **Marca de agua "Curitek" repetida sobre toda la imagen.** Los tres conservan su packshot limpio de ifarma; solo se quitaron las de galería. |
| 339 Alcohol Dibar | farmasuper | Era el ícono gris de "sin imagen", no una foto |
| 547 Bicarbonato Velázquez | farmasuper | Lo mismo, placeholder gris |
| 1317 Gerber durazno | superdtodo | No es packshot: es un recorte de la etiqueta azul |
| 1319 Gerber mango | superdtodo | La imagen no carga |
| 1315 / 1316 Gerber res y pollo | surtace | **Sticker de precio "$11" quemado en la foto** |
| 1289 Peine para piojos | Similares | **Imagen equivocada**: mostraba una manopla de baño "Mittenz" |

Las cuatro papillas Gerber siguen sin imagen usable: las tres fuentes que las
tienen traen precio encima o recortes. Van a foto propia.

## Lo que sí pasó la revisión

- **Las 37 de iFarma**: las miré todas. Packshots limpios, fondo blanco, sin
  marca de agua, sin logo de tienda. Es la mejor fuente que encontramos.
- **Las 12 de Droguería Mercurio**: son el producto correcto y vienen del
  fabricante, pero la foto es amateur — sombras visibles, fondo de color,
  alguna borrosa (la magnesia anisada sobre todo). Marcadas
  `MARCA_OFICIAL_CALIDAD_BAJA`: sirven para no tener hueco, pero son las
  primeras candidatas a re-fotografiar cuando tengas sesión.
- **9 nuevas verificadas**: Perilla N3 Edigar, Esencia de clavo Herbotec,
  Mertodol Jaloma, Vaso recolector Dibar, Zagapsol, Clorofil Jahvs, Tretinoína
  Randall, Hidropharm y Cloropiramina. Todas fondo limpio.

## Tres que quedan a tu criterio (`REVISAR` en el CSV)

- **1270 Xiomara Pomada B** — el código de barras coincide exacto en Chedraui,
  pero ahí el producto se llama "Cera Black Xiomara 60g" y la foto es un pomo de
  cera para cabello. Si "Pomada B" era "Pomada Black", está bien y de paso te
  corrige el nombre. Confírmalo contra el empaque.
- **1252 Copa lavaojos** — es el producto, pero la foto es de la bolsa sellada y
  se ve mal.
- **586 Cinta micropore** — imagen genérica de baja resolución y el ancho no
  coincide con el tuyo. Las otras cuatro cintas quedaron fuera por lo mismo.

## Por qué quedan 51 sin imagen

No es falta de buscar. Los busqué por EAN contra iFarma, Open Food Facts,
Chedraui, Similares, Soriana, farmasuper y surtace, y por nombre contra
fabricantes y farmacias. Lo que queda es de tres tipos:

1. **Códigos internos tuyos** (`2008…`): perillas, peines, cubrebocas, tijera,
   dona, Gillette suelto. No existen fuera de tu sistema.
2. **Registros que no describen una cosa concreta**: "Quitaesmalte SKN ·
   variante 215 · confirmar", "FC producto botiquín", "Mercurio" a secas,
   "Protect aerosol 12.80 G". Aquí lo que falta es arreglar el registro, no la
   foto.
3. **Genéricos sin marca**: pinzas, brochas, peines. Hay mil fotos en internet
   y ninguna es de *tu* producto. Una sesión de fotos los resuelve en una hora.

## Archivos

| Archivo | Qué es |
|---|---|
| `candidatos_imagenes_v2_20260917.csv` | 70 imágenes, 61 productos, con nota de verificación visual una por una |
| `rechazadas_en_revision_visual_20260917.csv` | Las 10 que descarté y por qué |
| `siguen_sin_imagen_v2_20260917.csv` | Los 51 pendientes con motivo |
| `cargar_imagenes_lote_20260917.py` | Baja, normaliza, sube al bucket y siembra `producto_imagenes` |
| `patch_imagen_principal_faltante_20260915.sql` | Sigue vigente: arregla 10 productos sin buscar nada |

Orden: primero el SQL del patch, luego `--dry-run`, revisas la carpeta
`catalogo-imagenes/lote_20260917/`, y entonces la carga. Con `--solo-ean-exacto`
cargas únicamente las 48 con código de barras confirmado y dejas fuera las que
van por nombre.

## Fuentes

[iFarma](https://www.ifarma.com.mx/) · [Droguería Mercurio](https://www.drogueriamercurio.com.mx/catalogo-drogueria-mercurio.php) · [Sanorim](https://sanorim.mx/) · [Phemedica](https://phemedica.com.mx/) · [BS Pharma](https://bspharma.net/) · [Farmacias Lolyta](https://www.farmaciaslolyta.com/) · [Farmasuper](https://farmasuper.com.mx/) · [Farmacias Dr. Ahorro](https://www.farmaciasdrahorro.com.mx/) · [Almacenes Farah](https://almacenesfarah.mx/) · [Promexsa](https://www.promexsa.com.mx/) · [Farmacia Herrera](https://farmaciaherrera.com.mx/) · [Chedraui](https://www.chedraui.com.mx/) · [Distribuidora San Antonio](https://distribuidorasanantonio.com/)
