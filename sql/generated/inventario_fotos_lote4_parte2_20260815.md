# Lote 4 — parte 2: IMG_5241–IMG_5302 y las 93 fotos UUID restantes

155 fotos, mismo criterio que la parte 1: cada producto son dos tomas, la cara
principal y el código de barras. Los EAN se decodificaron del código con
OpenCV, no se leyeron a ojo. El costo, lote y caducidad salen del ticket
Equilibrio 440393.

- 70 fotos con código legible, 85 portadas.
- 60 productos quedaron completos (portada + EAN) y están en el SQL de staging.
- 12 de ellos traen **el lote impreso idéntico al del ticket**, que es la
  confirmación más fuerte que se puede tener sin escanear en tienda.

## Lo que esta tanda vino a cerrar

Cinco productos que en la parte 1 se habían quedado con portada pero sin código
aparecieron aquí con su código de barras:

| Producto | Portada (parte 1) | Código (parte 2) | EAN |
| --- | --- | --- | --- |
| Precicol gotas 20 mL | IMG_5219 | IMG_5241 | 7501836003621 |
| Omeprazol Aktyzar 120 cáps | IMG_5211 | IMG_5277 | 7501482200016 |
| Oppelver lactulosa 125 mL | IMG_5195 | IMG_5283 | 7502009745584 |
| Lumboxen parche | IMG_5227 | IMG_5268 | 7502009749209 |
| Benciefedril jarabe 120 mL | 9C7D238A | CDD1272E | 7501075710465 |

Además, **Bactiver suspensión** (IMG_5261 + IMG_5271) trae el lote 262631
impreso, que es exactamente el de la línea MAV003 del ticket. Ese código de
proveedor estaba marcado como conflicto en el lote 3 porque su lote se le había
asignado a otro producto; con esta foto queda claro a qué artículo pertenece.

## Los 12 con lote verificado contra el ticket

Estos no dependen de que el nombre se parezca: el número de lote de la etiqueta
y el del ticket son el mismo, así que el costo es el correcto.

| Producto | Lote | Costo | PMP etiqueta |
| --- | --- | --- | --- |
| Cobadex Adulto 120 mL | 260606 | 19.31 | 123.00 |
| Culminax Adulto 150 mL | 261984 | 50.05 | 255.00 |
| Fedrimin 150 mL | 263034 | 34.25 | 171.00 |
| Siracux Adulto 120 mL | 263295 | 42.66 | 213.00 |
| Laritol EX jarabe 120 mL | 252141 | 19.11 | 123.00 |
| Bioxover jarabe 120 mL | 255469 | 28.84 | 156.00 |
| Exhantil 320 mL | 26061512 | 33.00 | 219.00 |
| Nineka suspensión 75 mL | 460056 | 23.45 | 80.00 |
| Normex 360 mL | 26B099 | 41.82 | 165.00 |
| Bactiver suspensión 120 mL | 262631 | 21.28 | 111.00 |
| Lumboxen parche | 20251225 | 14.37 | 35.00 |
| Omeprazol Aktyzar 120 cáps | 61168 | 46.79 | 279.00 |

El de Cobadex es el `$19.31` que mencionaste hace rato: ahí está su línea.

## Lo que hay que resolver antes de dar de alta

**Dos lotes que no cuadran por un dígito.** En Caltrón la etiqueta dice 26540038
y el ticket 26540138; en Normex 60 mL la etiqueta dice 26B128 y el ticket
26B098. Los demás datos coinciden, pero conviene mirar la caja física.

**Tres pares emparejados por contexto, no por texto.** En Ridin Pediátrica,
Bruluaquil y los hisopos Jaloma la foto del código no muestra el nombre del
producto; los emparejé por color de empaque, laboratorio y posición en la
secuencia. Van marcados con confianza `media`.

**Voldratol, Floroglucinol, Broncolin Bicoestol, Tobramicina oftálmica, los
Ajolotius y el Playboy Max Sens** tienen EAN confirmado pero no aparecen en el
ticket de Equilibrio: son de otro proveedor y hay que capturarles el costo a
mano.

## Códigos sueltos, sin portada

Estas fotos son de código de barras que no tienen una cara principal
identificable en la secuencia. Necesitan que vuelvas a fotografiar el frente:

`7502009749421` (caja negra Maver), `7502227426982` (caja Gelpharma),
`7502211784029` (caja azul Loeffler), `7502009745027` (frasco verde Maver, lote
262654, PMP $282), `7502009745522` (caja de sobres Maver), `7501349022485`
(caja azul AMSA), `7503004908738` (caja Alpharma, probablemente la lidocaína
ungüento de IMG_5270), `7501109763986` (caja índigo Quifa, probablemente el
Magsokon de IMG_5267), `7503008344501` (frasco Progela, probablemente el
Promega 3 de IMG_5179), `0759684432071` y `0759684391156` (artículos Jaloma),
`7502009740435` (5 cajas blancas Maver).

## Portadas sin código en esta tanda

Zimeton, Plusgel, Zukedib, X-TRID, Galaver sobres, Novagon sabor natural,
Fermig, Treda, Metamucil 504 g, Magsokon, Lidocaína ungüento, Laritol tabletas,
Daclafin, Supratex jarabe, Drosequim infantil, Omeprazol avivia, Vaselina bebé
Jaloma, Ricitos de Oro, Bronco Rub y Pantoprazol AMSA. Todos tienen línea en el
ticket salvo los de higiene, así que sólo falta la foto del código.

## Cómo correrlo

```
sql/patch_lote4_1_STAGING.sql        -- crea la tabla y carga los 40 de la parte 1
sql/patch_lote4_2_STAGING_PARTE2.sql -- agrega los 60 de esta tanda
```

Ninguno de los dos toca `productos` ni `lotes`. Al final devuelven el conteo de
altas nuevas contra las que ya existen; con eso decidimos qué se inserta y qué
sólo actualiza costo.
