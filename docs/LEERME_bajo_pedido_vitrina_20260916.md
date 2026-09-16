# Primer lote vitrina «Te lo conseguimos»

La UI de `/conseguir` ya estaba (PR #237). Faltaban filas `bajo_pedido = true`.
Este lote las crea. **Hasta que pegues el SQL en Supabase, la vitrina sigue vacía.**

## Qué pegar (en este orden)

1. `sql/patch_bajo_pedido_20260916.sql` — si aún no corre (columna + RPCs).
2. `sql/patch_alta_bajo_pedido_vitrina_20260916.sql` — este lote.

Supabase → SQL Editor → Run. Idempotente.

Fotos propias (Effaclar Duo+ M y SVR) viven en `public/catalogo-propia/`. El SQL apunta a
`https://www.farmacapital.mx/catalogo-propia/…` **después del deploy**. Si corres el SQL
antes del deploy, esas 3 fotos no se ven hasta publicar.

## Qué no se tocó

Si un EAN ya existe **con stock de anaquel** (p. ej. Pharmaton Complete 30, Elevit 1,
Ensure, CeraVe 236 ml de un ticket), **no** se marca bajo pedido.

SVR **no está en Nadro**. Se consigue con el importador / dermofarmacias (ficha oficial
`mx.svr.com`). El resto es Nadro i22, pedible hoy.

Isdin Fusion Water **sin color** se omitió: Nadro solo tenía foto genérica.

## Lote (26)

### Dermatología — Nadro

| EAN | Nombre de mostrador | Ancla |
| --- | --- | ---: |
| 3337872411991 | La Roche-Posay Effaclar Gel Limpiador Facial 400 ml | 538 |
| 3337875722827 | La Roche-Posay Effaclar Ultra Sérum Anti-Imperfecciones 30 ml | 706 |
| 3337875863377 | La Roche-Posay Effaclar Duo+ M Anti-Imperfecciones 40 ml | 605 |
| 3337875708289 | La Roche-Posay Effaclar Gel Micro-Exfoliante 400 ml | 591 |
| 8429420285644 | Isdin Fotoprotector Fusion Water Color Light 50 ml | 701 |
| 8429420227590 | Isdin Acniben Facial Cleanser Gel 400 ml | 548 |
| 8470003245920 | Isdin Acniben Gel-Crema Brillos y Granos 40 ml | 662 |
| 3337875597197 | CeraVe Gel Limpiador Espumoso 236 ml | 309 |
| 3337875923866 | CeraVe Limpiador Control Imperfecciones 473 ml | 422 |
| 4006000183572 | Eucerin Dermopure Clinical Gel Limpiador Purificante 400 ml | 455 |
| 3282770139204 | Avène Cleanance Gel Facial Sin Jabón 200 ml | 569 |

### Dermatología — SVR (no Nadro)

| EAN | Nombre | Ancla | Fuente |
| --- | --- | ---: | --- |
| 3662361003402 | SVR Sebiaclear Gel Moussant 400 ml | 913 | mx.svr.com + EAN Puntopiel |
| 3662361000364 | SVR Sebiaclear Sérum 30 ml | 1073 | mx.svr.com + EAN Halo Skin |

### Vitaminas — Nadro

| EAN | Nombre | Ancla |
| --- | --- | ---: |
| 3664798064704 | Pharmaton Complete Kids Jarabe 100 ml | 312 |
| 3664798027525 | Pharmaton Woman 50+ 750 mg 30 cápsulas | 345 |
| 7501008499177 | Elevit 2-Omegas 28 cápsulas | 529 |
| 7501008499580 | Elevit 3-Luteína 30 cápsulas | 549 |
| 7501065004000 | Centrum Gender+50 Mujeres 60 tabletas | 540 |
| 7501008409527 | Redoxon Ácido Ascórbico 1 g naranja 10 tabletas | 160 |

### Suplementos — Nadro

| EAN | Nombre | Ancla |
| --- | --- | ---: |
| 7503006545177 | Solanum Omega 3 Salmón Salvaje Alaska 60 cápsulas | 235 |
| 7503006073106 | Essential Omega 3 Forte 1000 mg 40 cápsulas | 283 |
| 7506241700813 | Essential Biotina 500 mg 30 cápsulas | 203 |
| 7501033956126 | Glucerna SR Vainilla 237 ml | 65 |
| 7501033956140 | Glucerna SR Fresa 237 ml | 65 |

### Proteína — Nadro

| EAN | Nombre | Ancla |
| --- | --- | ---: |
| 7501062910175 | Prowinner Proteína 90% chocolate 400 g | 488 |
| 7501062914531 | Pronat Proteína Vegetal vainilla 12 sobres de 30 g | 442 |

## Cómo dar de alta otro después

1. Buscar el EAN en Nadro (`buscarNadroPorEan` / i22) o en la ficha de Levic/Marzam.
2. Nombre de mostrador + marca de **esa página**, no del PDF.
3. Foto. SKU `FC-` + últimos 8 del EAN. `bajo_pedido = true`, `stock = 0`.
4. O en Inventario → Catálogo → *Bajo pedido (vitrina «Te lo conseguimos»)*.
