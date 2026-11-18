# Imágenes candidatas · 24 sep 2026

Corte de productos activos con `imagen_url` vacío. La versión 4 de la
búsqueda es la vigente. **Ninguna de esas fotos se descargó ni se subió
a Storage.** El CSV de las 2,293 filas (`imagenes_candidatas_farmacapital_20260924_v4.csv`)
se bajó en el navegador a Descargas y **no está en el repositorio**.

## Catálogo vivo (25 sep 2026)

Consulta de lectura al catálogo público:

| | Reporte 24 sep | Vivo 25 sep |
|---|---|---|
| Activos | 5,739 | **5,738** |
| `imagen_url` vacío | 2,293 | **2,293** |

La diferencia de un activo cabe en altas o bajas de un día. El hueco de
fotos es el mismo. El corte del 15 sep hablaba de 1,544 activos: eso era
antes del catálogo extendido (suplementos y dermocosmética bajo pedido).

## Versión 4 (lo que ya se buscó)

- **1,537 con imagen candidata** (67%). **756 sin candidata.**
- **388 por código de barras exacto.** **468 `REVISAR_VISUALMENTE`**
  (nombre con baja confianza o tamaño distinto). El resto es nombre +
  marca + tamaño con puntaje alto.
- Una fila por producto: estado, URL, página de origen, fuente, confianza
  y nota de licencia. Reemplaza a las versiones 1, 2 y 3.

Fuentes de esa corrida: catálogos Shopify de dermamedina.com,
dermapharma.mx, shop.martiderm.mx, dermaexpress.com.mx; cruce por código
en farmasuper.com.mx y derma.shop; APIs tipo VTEX de klyns.mx,
lacolonia.com, farmatodo.com.mx, lagranbodega.com.mx y chedraui.com.mx;
sitios de fabricante y tiendas de suplementos (Dragon Pharma, Evogen,
Insane Labz, Cellucor, Hi-Tech, Nutrex, MuscleTech, Ghost, Gaspari, MHP,
Ronnie Coleman, GAT, Finaflex, AllMax, Panda, ProSupps, Redcon1, Ryse,
AF Supplements, Suplementos Alex, Fitstore, SDM, GetFit, Optimum
Nutrition MX). Soriana no respondió.

### Reglas para usar ese CSV

- Coincidencia por EAN: identidad segura. Por nombre: mirar la foto antes
  de aprobar, sobre todo `REVISAR_VISUALMENTE`.
- Las fotos de otras tiendas no entran a producción sin permiso. Las del
  fabricante también piden verificar permiso.
- No se enlaza el CDN ajeno. Las aprobadas se copian a Supabase Storage
  con `origen`, `fuente_url` y `licencia`. Esas columnas ya existen en
  `producto_imagenes`.

Hasta que el CSV v4 esté en el repo no se puede probar el hotlink de esas
1,537 URLs ni armar el lote de Storage.

## Lo que el 15 sep sí y no cargó

`candidatos_imagenes_20260915.csv` tiene 63 imágenes de **52 productos**.
En el catálogo vivo, **29 ya tienen `imagen_url`** (25 apuntan a
`catalogo-propia/`). **23 siguen vacíos.** No es un lote pendiente de
pegar tal cual: el reporte del 15 y la revisión del 17 dejaron fuera
Mercurio (foto de ~100 px), Frinver (la caja no es de 24 ml) y otros
candidatos ambiguos.

Siguen sin foto de ese corte: 519, 527, 529, 530, 531, 532, 534, 536,
538, 545, 1178 y 1192 (Mercurio y bicarbonato), y los medicamentos 1759
Prochor, 1761 Pakid, 1767 Tinitrend 40 g, 1775 Novapres, 1776 Toparal,
1779 Vepiltax, 1780 Wadil, 1787 Frinver, 1789 Orfeox, 1790 Stomffler Plus
y 1796 Gelprim.

## Patyka: sitio oficial, 25 sep

En la base la marca **Senti2** agrupa a Patyka. Hay **31 activos**, todos
con EAN `3700591…` y **ninguno con foto**. El prefijo es de Patyka; Senti2
es el distribuidor.

`scripts/buscar_patyka_por_ean.py` busca cada EAN en patyka.com y solo
acepta la variante cuyo `barcode` es ese código. No descarga archivos ni
escribe `imagen_url`.

| Estado | n | Qué es |
|---|---|---|
| `EAN_EXACTO` | 15 | El código y los ml coinciden con la ficha oficial |
| `REVISAR_VISUALMENTE` | 7 | El código coincide y el tamaño (o el producto) no |
| `SIN_CANDIDATA` | 9 | El sitio actual no publica esa variante |

Salida: `sql/generated/candidatos_patyka_oficial_20260925.csv`.
Lista de entrada: `sql/generated/senti2_sin_foto_20260925.csv`.

Las 22 URLs de imagen (15 + 7) respondieron **HTTP 200** a un `HEAD` sin
`Referer` (CDN de Shopify). Eso no autoriza publicarlas: el permiso del
fabricante no está verificado y la spec de fichas pide copia en Storage,
no hotlink.

### Tamaño o producto distinto (no aprobar la foto todavía)

| EAN | Catálogo | Ficha oficial |
|---|---|---|
| 3700591900099 | Serum Corrector Antimanchas 50 ml | Sérum Correcteur Anti-Taches **30 ml** |
| 3700591913327 | Serum Intensivo Anti-Imperfecciones 30 ml | Gelée Nettoyante Purifiante **150 ml** |
| 3700591913372 | Loción Purificante 200 ml | Soin Ciblé Stop-Boutons **15 ml** |
| 3700591913341 | Fluido Matificante 40 ml | Sérum Intensif Anti-Imperfections **30 ml** |
| 3700591900358 | Exfoliante Alisante 50 ml | Patchs Lift Regard 360° |
| 3700591913334 | Gel Limpiador Purificante 150 ml | Lotion Purifiante Perfectrice **200 ml** |
| 3700591913365 | Tratamiento Localizado 15 ml | Masque Charbon Désincrustant **50 ml** |

El código de la caja es el de la ficha oficial. El nombre y los ml del
catálogo, en estas siete, describen otra cosa. Hay que corregir la ficha
antes de colgar la foto.

Dos más coinciden en ml y aun así el nombre en español parece cruzado:

| EAN | Catálogo | Oficial |
|---|---|---|
| 3700591911286 | Aceite desmaquillante clarificante 200 ml | Lait Démaquillant Apaisant 200 ml |
| 3700591911255 | Leche desmaquillante calmante 150 ml | Huile Démaquillante Éclair 150 ml |

### Marca

`sql/patch_marca_senti2_patyka_20260925.sql` pasa `marca` de Senti2 a
Patyka en esos 31 EAN. No está aplicado. No renombra productos: el nombre
de mostrador de las filas de arriba hay que cerrarlo contra la caja o
contra la ficha oficial, no a ojo.

## Sigue sin foto (756 del corte v4)

Sobre todo suplementos con nombre abreviado o de marcas sin catálogo
abierto (RAW, Shaker), más cuidado personal y vitaminas.

**85 con código de barras** no salieron en las fuentes del 24 sep. Entre
ellos: Avène (6), Senti2/Patyka (6), Farmapiel (5), Sesderma (5), Noreva
(5), SKN (4), Eucerin (4), MartiDerm (3), Armstrong (3), Mercurio (2).
Esos van al sitio de la marca o a una foto del distribuidor. De los 31
Patyka, 22 ya tienen candidata oficial en el CSV de esta corrida; 9 no
están en la tienda actual de patyka.com.

Los códigos internos `2008…` y los que no tienen código no existen en
catálogos ajenos: foto propia.

## Próxima corrida

1. Meter en el repo el CSV v4 de Descargas (2,293 filas).
2. Separar EAN exacto de `REVISAR_VISUALMENTE` y mirar esas fotos.
3. Probar hotlink y, solo con permiso, copiar las aprobadas a Storage
   con `origen`, `fuente_url` y `licencia`.
4. Contar activos sobre el catálogo vivo (~5,740), no sobre 1,544.
5. No rehacer los 29 del 15 sep que ya tienen portada.
