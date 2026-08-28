# Lote 4 — Análisis de fotos (27A7CE10 … IMG_5240)

Fecha de captura: 15-ago-2026, 20:13–20:20 h
Fotos analizadas: **121** (59 con nombre UUID + 62 `IMG_5179`–`IMG_5240`)
Productos identificados: **~64**

## Cómo vinieron las fotos

Son **dos series distintas** mezcladas en Descargas, y no se comportan igual:

| Serie | Archivos | EXIF | Patrón |
|---|---|---|---|
| UUID (`27A7CE10…` → `9C7D238A…`) | 59 | Sí, 20:13:00–20:20:27 | **Pares perfectos**: portada, código, portada, código… |
| Cámara (`IMG_5179`–`IMG_5240`) | 62 | No (se perdió al copiar) | **Sin patrón**: rachas de portadas y luego rachas de códigos |

Por eso los 29 pares de la serie UUID se resolvieron solos, mientras que la serie
`IMG_` hubo que emparejarla por contenido (laboratorio impreso, registro sanitario,
color de la caja) y quedaron muchas fotos sueltas.

Los códigos de barras se decodificaron con OpenCV (`scripts/leer_codigos_fotos.py`),
no por OCR visual, así que los EAN de esta tabla no arrastran el tipo de error que
tuvimos en el lote 3. Los 9 que el decodificador no pudo leer se transcribieron a
mano dígito por dígito y se validó su dígito verificador.

---

## A. Listos para cargar — EAN confirmado + costo del ticket Equilibrio 440393

El lote y la caducidad salen del ticket. En cuatro casos (Novagon ×2, Daclafin,
Playboy Playpack) el lote impreso en la foto **coincide exactamente** con el del
ticket, lo que confirma que el cruce es correcto.

| # | EAN | Producto | Presentación | Cód. prov. | Lote | Caducidad | Costo |
|---|---|---|---|---|---|---|---|
| 1 | 7501573902584 | Sarox (omeprazol) 20 mg | Caja c/14 cáps | BIO067 | 5D2618 | 2028-04-01 | 8.42 |
| 2 | 7501573909859 | Sarox (omeprazol) 20 mg | Caja c/28 cáps | BIO213 | 5E2646 | 2028-05-01 | 15.61 |
| 3 | 7503001007656 | Wamindel gotas paracetamol 100 mg/mL | Frasco 30 mL c/gotero | BIO087 | LF2607 | 2028-06-30 | 12.02 |
| 4 | 7503001007663 | Wamindel solución infantil 3.2 g/100 mL | Frasco 120 mL | BIO068 | LB2645 | 2028-02-01 | 15.44 |
| 5 | 7501825304555 | Braxigort (nifuroxazida) susp. 4.4 g/100 mL | Frasco 90 mL | DEG186 | 487AA | 2028-05-31 | 39.45 |
| 6 | 7501836006042 | Virindrez Adulto (oximetazolina) 0.050% | Atomizador 20 mL | LIF160 | 26D035 | 2028-04-30 | 23.85 |
| 7 | 7501836006028 | Virindrez Infantil (oximetazolina) 0.025% | Atomizador 20 mL | LIF161 | 26C079 | 2028-04-30 | 20.70 |
| 8 | 7503014377074 | Playboy Playpack mixtos | Blíster c/3 pzas | PBY004 | 1991025 | 2030-09-30 | 30.83 |
| 9 | 7503004908714 | Miconazol crema 2% (Alpharma) | Tubo 20 g | ALP0520 | 2512183 | 2027-12-01 | 10.87 |
| 10 | 7506624901059 | beadvance Senósidos A-B 8.6 mg | Caja c/20 tabs | BEA483 | 540346 | 2028-03-01 | 11.14 |
| 11 | 7501075723137 | Novakosid Senósidos A-B 8.6 mg (Novag) | Caja c/20 tabs | NOV136 | 540266 | 2028-05-01 | 13.93 |
| 12 | 7502211788928 | Desyn-N lidocaína/hidrocortisona 60/5 mg | Caja c/6 supositorios | LOE119 | R2508053 | 2027-08-31 | 31.62 |
| 13 | 7503008344150 | Prugnex senósidos 12 mg + ciruela 50 mg | Caja c/30 cáps | PGE040 | T0885 | 2027-10-16 | 37.07 |
| 14 | 7503003738879 | Rosel-T 300/50/3 mg | Caja c/15 tabs | WER015 | 251070 | 2028-01-01 | 21.26 |
| 15 | 7502240450230 | Rosel solución infantil 0.5/0.02/3 g | Frasco 60 mL | WER033 | 260204 | 2028-04-01 | 26.88 |
| 16 | 7502211783282 | Erbitrax (terbinafina) crema 1% | Tubo 30 g | LOE076 | R2602067 | 2028-03-31 | 28.62 |
| 17 | 7501573902966 | Nafich (terbinafina) crema 1% | Tubo 15 g | BIO103 | CD2603 | 2028-04-01 | 13.06 |
| 18 | 7501836009661 | Dualgos paracetamol/ibuprofeno 325/200 | Caja c/20 tabs | LIF147 | 25J081 | 2027-11-30 | 29.02 |
| 19 | 0780083142308 | Tempire paracetamol gotas 100 mg/mL | Frasco 30 mL c/pipeta | COL090 | 26140833 | 2029-04-06 | 20.00 |
| 20 | 7502001165045 | Dolzycam (piroxicam) gel 0.5% | Tubo 60 g | SON044 | 26010268 | 2028-01-01 | 24.81 |
| 21 | 7503008344303 | Ladexgel 300/2/10 mg | Caja c/12 cáps | PGE018 | U0150 | 2028-01-08 | 20.55 |
| 22 | 7502001165953 | Rexurdir (nifuroxazida) 400 mg | Caja c/16 cáps | SON226 | 26051290 | 2028-05-01 | 29.92 |
| 23 | 7501825300366 | Espabion (trimebutina) 20 mg/mL gotas | Frasco 30 mL | DEG030 | 449AA | 2029-05-31 | 25.67 |
| 24 | 7502009745997 | Pamedan (dexpantenol) crema 5% | Tubo 30 g | MAV279 | 261562 | 2028-03-01 | 19.53 |
| 25 | 0785118752637 | Itamol subsalicilato de bismuto 262 mg | Caja c/24 tabs mast. | MAI080 | 6C0337 | 2028-03-31 | 34.09 |
| 26 | 7502006920021 | Motilaxil-T picosulfato de sodio 5 mg | Caja c/20 tabs | FAC0059 | ITF26S084 | 2028-06-30 | 17.02 |
| 27 | 7502009745539 | Lumboxen gel naproxeno/lidocaína 10/2 g | Tubo 35 g | MAV247 | 256834 | 2027-12-01 | 39.54 |
| 28 | 7501258207010 | Oxital-C vitamina C 2 g efervescente | Tubo c/10 comp | SER141 | 260140 | 2028-01-26 | 62.48 |
| 29 | 7502009747236 | Exaliv 325/5/2 mg (Maver) | Caja c/24 tabs | MAV341 | 260224 | 2028-05-01 | 19.82 |
| 30 | 7502227427392 | ML-PRIM metocarbamol/naproxeno 375/200 | Caja c/12 cáps | GEP030 | 260735 | 2028-03-01 | 47.28 |
| 31 | 7501075718676 | Novagon polvo piña-naranja | Frasco 400 g | NOV098 | 491066 | 2030-04-01 | 97.10 |
| 32 | 7501075713770 | Novagon polvo 49.7 g/100 g | Frasco 400 g | NOV017 | 500546 | 2030-01-01 | 99.10 |
| 33 | 7502253601339 | Daclafin subsalicilato de bismuto | Frasco 120 mL | DAC005 | 26C0037 | 2028-03-31 | 31.49 |
| 34 | 7500435145497 | NyQuil Z (difenhidramina) 25 mg | Caja c/30 cáps | PYG024 | A00056 | 2026-10-31 | 281.55 |

Precios máximos al público que venían impresos en la etiqueta y sirven de techo:
Novagon $230.00, Daclafin $69.00.

## B. Con costo del ticket pero **falta la foto del código de barras**

Se identificó el producto y su línea en el ticket, pero ninguna foto del rango
muestra su EAN. Hay que volver a fotografiar el código.

| Producto | Portada | Cód. prov. | Lote | Caducidad | Costo |
|---|---|---|---|---|---|
| Benciefedril jarabe dextrometorfano/guaifenesina 120 mL | `9C7D238A…` | NOV101 | 070115 | 2027-12-01 | 22.74 |
| Galaver gel 8 mg/1 mg 250 mL (Maver) | `IMG_5185` | MAV250 | 262654 | 2028-04-01 | 48.22 |
| Oppelver lactulosa 10 g/15 mL 125 mL (Maver) | `IMG_5195` | MAV245 | 261962 | 2028-03-01 | 49.25 |
| Velatuss levodropropizina 600 mg/120 mL (Rayere) | `IMG_5208` | RAY114 | 25109 | 2027-05-01 | 34.55 |
| Omeprazol Aktyzar 20 mg, frasco 120 cáps (Solfran) | `IMG_5211` | SOF054 | 61168 | 2028-06-05 | 46.79 |
| Raspisons ungüento neomicina/retinol 28 g (Son's) | `IMG_5212` | SON173 | 25123585 | 2027-12-01 | 19.61 |
| Precicol hioscina/paracetamol gotas 20 mL (Liferpal) | `IMG_5219` | LIF162 | 26C062 | 2028-03-31 | 37.22 |
| Revenox melatonina 3 mg, 60 tabs | `IMG_5221` | SAN025 | 26340240 | 2028-02-17 | 72.13 |
| Lumboxen parche, bolsa c/1 | `IMG_5227` | MAV400 | 20251225 | 2028-12-31 | 14.37 |
| Pharmacaine lidocaína 10%, 115 mL (Quimpharma) | `IMG_5228` | QUM014 | 26DP57 | 2028-04-01 | 101.30 |

Dos de estos tienen un EAN candidato entre los códigos huérfanos, pero no me
consta: Raspisons podría ser `7502001165724` (`IMG_5239`, caja Son's blanca con
filos azul marino) y Pharmacaine podría ser `7502223111202` (`IMG_5188`, caja
Quimpharma azul rey). **No los cargué con ese EAN**; requieren confirmación.

## C. EAN leído pero **sin portada** — no sé qué producto es

Son fotos de código sin ninguna otra foto que muestre el nombre. Hace falta la
foto de la cara principal.

| EAN | Pista del empaque | Foto | Dato extra impreso |
|---|---|---|---|
| 7501022104248 | Grisi «Nicos de Oro» crema corporal, frasco tapa amarilla | `IMG_5199` | Lote L26A0587 |
| 7502001165397 | Caja verde limón, Laboratorios Química Son's | `IMG_5200` | — |
| 7501075717914 | Frasco Novag, neomicina + caolín + pectina (antidiarreico) | `IMG_5204` | Lote 460056, cad. mar-2028, PMP $80.00 |
| 0020800790246 | Metamucil, bote naranja P&G | `IMG_5207` | — |
| 7502216803800 | Caja Ultra Laboratorios / avivia, antiácido | `IMG_5214` | Reg. 148M2003 |
| 7502009745522 | Caja Maver con sobres, filo verde | `IMG_5187` | Reg. 194M2014 |
| 7502223111202 | Caja Quimpharma azul rey | `IMG_5188` | Reg. 476M2005 |
| 0714706800900 | Frasco morado tapa verde, suplemento alimenticio | `IMG_5189` | Reg. 003P2018 |
| 7502223111387 | Caja verde Quimpharma, dropropizina 150 mg + bromhexina 80 mg | `IMG_5235` | Reg. receta médica |
| 7501070612368 | Caja roja, Grimann / Sanfer | `IMG_5231` | Reg. 82212 |
| 0780083140588 | Frasco Collins con tabletas | `IMG_5233` | Lote 26141277, cad. may-2028, PMP $214.29 |
| 0759684154096 | Talquera Jaloma bebé, tapa morada | `IMG_5194`, `IMG_5234` | — |
| 0785118754259 | Caja azul claro Supratex (Mavi) | `IMG_5240` | Ticket: MAI157 jbe 600 mg 120 mL ($40.91) o MAI158 sol DAC ($42.14) — falta saber cuál |
| 7502003388008 | Caja blanca con líneas rojas, Farmacéuticos Rayere | `IMG_5181` | Reg. 167M2006 |

## D. Portada sin código y sin línea en el ticket

Productos que no vienen de Equilibrio (otro proveedor) y que además no tienen
foto de código en este rango.

| Producto | Foto | EAN si ya lo tenemos |
|---|---|---|
| Pedialyte SR 60 mEq uva, frasco 500 mL (Abbott) | `IMG_5191` + `IMG_5183` | 7501033956775 ✔ |
| Histiacil NF jarabe infantil 150 mL | `IMG_5216` + `IMG_5217` | 7501328979496 ✔ |
| Topron nifuroxazida 400 mg, 16 cáps (Chinoin) | `IMG_5225` + `IMG_5186` | 7501088579615 (probable) |
| Playboy Max Sens Extra Delgados 3+1 | `IMG_5180`, `IMG_5209` + `IMG_5215` | 7503014377197 (probable) |
| Promega 3 omega 3, 60 cáps de 1221 mg | `IMG_5179` | falta |
| Ajolotius original 250 mL (frasco azul) | `IMG_5232` | 7500462746612 ✔ (foto muestra ambas caras) |
| Ajolotius con propóleo 250 mL (naranja) | `IMG_5222` + `IMG_5201` | 7500462746698 (probable) |
| Ajolotius sin azúcar 250 mL (azul) | `IMG_5197` | falta — ojo, se confunde con el original |
| Broncolin Bicoestol pastillas, 16 pzas | `IMG_5226` | falta |
| Vaselina blanca Jaloma 60 g | `IMG_5196` | falta |
| Hisopos KIUTS 50 pzas (Jaloma) | `IMG_5213` | falta |
| OFF! Extra Duración aerosol 170 g | `IMG_5190` | 7501032911454 (ya dado de alta en patch previo) |

## E. Requiere volver a tomar la foto

- `IMG_5220`: bote amarillo, foto movida. No se lee ni marca ni código.
- `IMG_5212` (Raspisons): el código aparece en la foto pero borroso.

## F. Duplicados detectados

No son productos distintos, son segundas unidades del mismo artículo
fotografiadas dos veces. **No hay que darlas de alta dos veces.**

- Erbitrax crema 30 g `7502211783282`: pares `1D473A02+53C05603` y `3E498024+088DA5DB`
- Rosel solución 60 mL `7502240450230`: pares `6E25E862+199B80C8` y `7E113744+7D6895C1`
- Novakosid: `IMG_5236` e `IMG_5238` son la misma caja; `IMG_5206` e `IMG_5223` el mismo código
- Talquera Jaloma: `IMG_5194` e `IMG_5234` son el mismo frasco

## G. El rango se quedó corto

El corte en `IMG_5240` parte la sesión a la mitad. En Descargas siguen existiendo,
de la misma tanda del 15-ago:

- **`IMG_5241` – `IMG_5302`** (62 fotos más de la misma serie de cámara)
- **93 fotos UUID más**, de 20:20:30 a 20:32:12, que por el patrón de la serie
  deberían ser ~46 pares portada+código adicionales

Es muy probable que ahí estén las portadas de la sección C y los códigos de la
sección B. Conviene procesarlas antes de generar altas definitivas, para no
crear productos duplicados o incompletos como pasó en el lote 3.
