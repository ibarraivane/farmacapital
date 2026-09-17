# Primer lote vitrina «Te lo conseguimos»

La UI de `/conseguir` ya estaba (PR #237). Faltaban filas `bajo_pedido = true`.
Este lote las crea. **Hasta que pegues el SQL en Supabase, la vitrina sigue vacía.**

En la tienda: home → Dermocosmética y Vitaminas y suplementos
(`/dermocosmetica`, `/vitaminas`; aliases `/conseguir?seccion=…`).
Fase 2: las páginas mezclan anaquel + encargo. Chip **Nutrición deportiva**.

## Qué pegar (en este orden)

1. `sql/patch_bajo_pedido_20260916.sql` — si aún no corre (columna + RPCs).
2. `sql/patch_alta_bajo_pedido_vitrina_20260916.sql` — primer lote (26).
3. `sql/patch_alta_bajo_pedido_derm_recetadas_20260916.sql` — marcas que recetan dermatólogos (21).
4. `sql/patch_fase2_vitrina_nutricion_deportiva_20260917.sql` — reclasifica proteína/creatina. No marca bajo_pedido.

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

## Segundo lote — marcas que recetan dermatólogos (21)

No solo Effaclar / ISDIN / SVR. Investigación de consulta dermatológica en México
(Pierre Fabre, L'Oréal Dermatological Beauty, NAOS, Cantabria, Galderma, Leti)
cruzada con fichas reales Fahorro (SKU = EAN + packshot). Nadro i22 respondió 429
en esta pasada; no se inventó ficha.

| EAN | Nombre de mostrador | Ancla |
| --- | --- | ---: |
| 3337875816809 | La Roche-Posay Cicaplast Baume B5+ 40 ml | 426 |
| 3337875696548 | La Roche-Posay Lipikar Baume AP+M 400 ml | 834 |
| 3337875583626 | La Roche-Posay Hyalu B5 Suero 30 ml | 851 |
| 3337875543248 | Vichy Minéral 89 Suero 50 ml | 946 |
| 3337871330286 | Vichy Dercos Shampoo Anti-Caspa Grasa 200 ml | 708 |
| 3499320012850 | Cetaphil Loción Limpiadora Piel Sensible 473 ml | 598 |
| 3499320015530 | Cetaphil Limpiador Facial Piel Grasa 473 ml | 630 |
| 8470001724137 | Heliocare 360 Gel Oil-Free FPS 50+ 50 ml | 788 |
| 3701129812075 | Bioderma Sensibio H2O Agua Micelar 100 ml | 248 |
| 3401399277092 | Bioderma Sébium Gel Moussant 500 ml | 829 |
| 3337875597388 | CeraVe Crema Hidratante 454 g | 575 |
| 3282776385421 | Avène Cicalfate+ Crema Reparadora 100 ml | 644 |
| 3282776382109 | Ducray Kelual DS Champú Tratante 100 ml | 584 |
| 8470002094857 | Endocare Hyaluboost Age Barrier Sérum 30 ml | 1084 |
| 3661434004735 | Uriage Bariéderm Cica Crema Reparadora 40 ml | 319 |
| 3282770073577 | A-Derma Exomega Control Crema Emoliente 400 ml | 801 |
| 8470001541871 | Isdin Ureadin Ultra 20 Crema 100 ml | 450 |
| 4005800164361 | Eucerin UreaRepair Loción Corporal 10% 400 ml | 682 |
| 8431166181418 | Leti AT4 Multiprotect Facial FPS 50+ 50 ml | 632 |
| 8429979444448 | Sesderma C-VIT Crema Facial 50 ml | 1235 |
| 3504105025878 | Mustela Crema para Rozaduras Bebé 100 ml | 202 |

Buscadas y **sin** alta (sin ficha MX con EAN + foto + precio usable): SkinCeuticals,
Neostrata, Filorga, ACM, Isispharma, Noreva, Physiogel, Topicrem, Medik8, Differin (Rx).

Fotos en `public/catalogo-propia/`. El SQL apunta a `https://www.farmacapital.mx/catalogo-propia/…`
**después del deploy**.

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
