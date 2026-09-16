# FarmaCapital — SKUs sin imagen, lote 2026-09-15

## Qué se publica en este PR

24 productos con packshot en `public/catalogo-propia/` + SQL para
después del deploy. Más el parche gratis de los 10 que ya tenían galería.

| SQL | Cuándo |
|---|---|
| `sql/patch_imagen_principal_faltante_20260915.sql` | Ya: copia galería → `imagen_url` si la portada está vacía |
| `sql/patch_fotos_lote_20260915.sql` | **Después** del deploy de Vercel |

Fuentes que sí entregaron foto usable: Farmatodo VTEX por EAN (`_01` frente),
Farmacias Especializadas solo cuando el hash no era el placeholder
«Imagen no disponible», Super D'Todo (Gerber), Sanorim, Phemedica y Curitek
(Maver, con la caja a la vista). Baby Einstein ya estaba en el repo.

**No se usó** (aunque el CSV de candidatos lo traía):

- `ifarma.com.mx` — Cloudflare 403. El nombre del archivo es el EAN, pero
  desde aquí no se puede bajar.
- Droguería Mercurio — las 12 oficiales miden ~100 px. No sirven en catálogo.
- Farmasuper alcohol 250 ml — placeholder genérico.
- FESA path Magento `{ean}_1_1.jpg` — 86 de 89 eran el mismo JPG de
  «Imagen no disponible» (84278 bytes, hash `340a70fa…`).
- Dolver Farmatodo — la ficha dice C/10 y la foto enseña C/20. Se usó Curitek
  (caja de 10).
- Frinver Curitek — la caja dice 6 ml; el SKU es 24 ml. Se dejó fuera.

Los 60 de `siguen_sin_imagen_20260915.csv` siguen, menos Tretinoína Randall
(1768) e Hidropharm (1795), que Farmatodo sí tenía por EAN.

## El tamaño real del problema

| | |
|---|---|
| Productos activos | 1,544 |
| Sin imagen principal (`imagen_url` vacío) | 122 |
| **Sin ninguna imagen** (ni principal ni galería) | **112** |
| Con galería pero sin principal — se arreglan sin buscar nada | **10** |
| Con foto principal pero sin galería (oportunidad de carrusel) | 341 |

Los 112 se parten así: **72 son altas nuevas desde agosto** que nunca se habían
buscado, y **27 ya estaban marcados `FOTOGRAFIAR`** en el corte v2 de agosto
(los difíciles, con el motivo escrito uno por uno). Los 13 restantes no tienen
código de barras.

## Resultado de esta corrida

**52 de 112 productos quedaron con imagen candidata — 63 imágenes en total,
7 de ellos con galería de 2 o más para carrusel.**

Por nivel de confianza:

| Confianza | Imágenes | Qué significa |
|---|---|---|
| `EAN_EXACTO` | 40 | El archivo de imagen se llama igual que el código de barras, o el EAN está impreso en la ficha. Sin ambigüedad posible. |
| `EAN_EN_PAGINA` | 11 | El código de barras aparece en la página del producto. Verificado. |
| `MARCA_OFICIAL_NOMBRE` | 12 | Catálogo oficial del fabricante (Droguería Mercurio), match por nombre. Sin EAN en la ficha → **revisar visualmente antes de publicar**. |

Fuentes usadas, en orden de peso: `ifarma.com.mx` (37 productos, nombra sus
imágenes con el EAN), `drogueriamercurio.com.mx` (12, catálogo del fabricante),
`sanorim.mx` y `curitek.com` (galerías reales de Maver), `phemedica.com.mx`,
`farmasuper.com.mx`, `superdtodo.com`.

## Lo que NO se resolvió, y por qué

60 productos siguen sin imagen. No es que falte buscar más — para la mayoría
no existe nada que encontrar:

- **10 tienen código interno de la farmacia** (prefijo `2008…`: perillas Edigar,
  peines, cubrebocas, copa lavaojos, Gillette suelto, dona IJJ-10). Ese prefijo
  es el rango GS1 de uso interno: ustedes se lo asignaron. **No existe en ningún
  catálogo del mundo y nunca va a existir.** Van directo a foto propia.
- **13 no tienen código de barras** (Perilla N2/N3/N4/N6, Tratidri, Gentamicina,
  Eferox, Ursodesoxicólico, "Mercurio" a secas, "FC producto botiquín").
  Varios de estos además tienen el nombre incompleto — conviene arreglar el
  registro antes que la foto.
- **37 se buscaron y solo aparecieron candidatos ambiguos.** Los quitaesmaltes
  SKN se llaman literalmente "variante 215 · confirmar" en tu propio catálogo;
  el condón Sico C/3 no dice si es Sensitive, Safety o Invisible; "Protect
  aerosol 12.80 G" no identifica un producto. No es un problema de búsqueda,
  es que el registro no describe una cosa concreta.

## Dos cosas que encontré de paso

**1. Un EAN que probablemente está mal.** El producto 243 "Pantene Control
caída anticaída 400 ML" tiene `7501001303454`, pero el Pantene Control Caída
400 ml que venden Farmacias Medina y La Colonia es `7501001303464` — un dígito
de diferencia en la penúltima posición. Vale la pena verificar contra el
empaque físico antes de cargarle foto.

**2. La política de fuentes cambió.** En v2 excluiste explícitamente Ahorro,
Guadalajara y Amazon. En esta corrida autorizaste retail, así que lo usé como
fuente válida. Lo dejo escrito para que quede rastro de cuándo y por qué cambió
el criterio. En la práctica casi no hizo falta: lo que resolvió el lote fueron
catálogos de distribuidor y del fabricante, no retail.

**3. Open Food Facts no sirve para esto.** Consulté los 99 códigos de barras
contra su API: **0 coincidencias**. Coincide con el `APROBADA_GS1: 0` de tu
corte v2. No vale la pena volver a intentarlo.

## Entregables y orden de ejecución

1. **`patch_imagen_principal_faltante_20260915.sql`** — corre esto primero.
   No busca ni sube nada: toma los 10 productos que ya tienen fotos en
   `producto_imagenes` y les copia la principal a `imagen_url`. Es gratis.

2. **`candidatos_imagenes_20260915.csv`** — las 63 imágenes con su producto,
   posición, si es principal, URL de origen, fuente y confianza.

3. **`cargar_imagenes_lote_20260915.py`** — baja, valida, normaliza (webp
   cuadrado 1200px sobre fondo blanco), sube al bucket `productos` bajo
   `catalogo/lote-20260915/`, siembra `producto_imagenes` y pega la principal
   en `productos`. Genera además un SQL de respaldo en `sql/generated/`.

   ```bash
   python3 scripts/cargar_imagenes_lote_20260915.py --dry-run   # baja y valida, no sube
   # revisa catalogo-imagenes/lote_20260915/ con el ojo
   python3 scripts/cargar_imagenes_lote_20260915.py             # sube y carga
   ```

   El `--dry-run` no es opcional en la práctica: las 12 de Mercurio van por
   nombre, no por EAN. Una foto equivocada en catálogo cuesta más que un
   producto sin foto.

4. **`siguen_sin_imagen_20260915.csv`** — los 60 pendientes con el motivo
   concreto de cada uno, listo para armar la sesión de fotografía.

## Por qué el SQL apunta a tu bucket y no a las URLs de origen

Pediste SQL para cargar. El SQL que genera el script apunta a tu propio
Storage, no a `ifarma.com.mx` ni a `drogueriamercurio.com.mx`. Si guardaras la
URL ajena, la foto se cae el día que ellos reacomoden su CDN, y con 52
productos eso no se nota hasta que un cliente ve el hueco. El script hace el
rodeo de bajar y subir precisamente para evitar eso — es el mismo patrón que ya
usaste con Rappi y Levic.

## Siguiente paso natural

Los **341 productos con foto principal pero sin galería** son el lote grande de
carrusel, y ahí el trabajo es distinto: ya tienes una foto buena de cada uno, lo
que falta son los ángulos adicionales. Para medicamentos de caja eso rinde poco
—una caja se ve igual de todos lados—, pero para cuidado personal y consumo sí
cambia la conversión. Si quieres, el siguiente lote lo acoto a esas categorías.

## Fuentes

- [iFarma](https://www.ifarma.com.mx/) · [Droguería Mercurio](https://www.drogueriamercurio.com.mx/catalogo-drogueria-mercurio.php) · [Sanorim](https://sanorim.mx/) · [Curitek (Maver)](https://curitek.com/) · [Phemedica](https://phemedica.com.mx/) · [Farmasuper](https://farmasuper.com.mx/) · [Super D'Todo](https://superdtodo.com/) · [Farmacias Medina](https://farmaciasmedina.com/) · [Open Food Facts](https://world.openfoodfacts.org/)
