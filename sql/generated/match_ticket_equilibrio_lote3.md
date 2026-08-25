# Ticket Equilibrio Farmacéutico 440393 — transcripción y cruce con lote 3

**Fecha del ticket:** 08/03/2026 11:41 · **Cliente:** 301558 Victor Hugo Aguilar Zarco
**Sucursal:** Iztapalapa, Central de Abastos pasillo EF loc E-43

## Transcripción

| | |
| --- | --- |
| Páginas | 41 |
| Líneas | 481 |
| Artículos | 862 |
| Subtotal | $28,536.72 |
| IVA | $20.66 |
| **Total** | **$28,557.38** |
| Usted ahorró | $163,792.18 |

Archivo: `sql/generated/ticket_equilibrio_440393.csv`

### Validación

Los tres totales impresos cuadran al centavo contra la suma del CSV, y las 481
líneas cumplen `P.U. × cantidad = subtotal`. El IVA de $20.66 se explica
exactamente con las 5 únicas líneas gravadas (Flausiver, los 3 Playboy y el
parche Lumboxen): 6.01 + 3.71 + 3.71 + 4.93 + 2.30.

Único dato ilegible: la caducidad de `AMS501 ACIDO URSODESOXICOLICO 50 CAP
250 MG` (el escaneo muestra "01/32/2028", mes inválido). Queda en `null`.

### Estructura de cada línea

```
AMS033  CLINDAMICINA 5 FA 600MG/4 ML
lote : B25N206  caducidad :01/11/2027
2 X 396.00 D:77.67 D2: 0.01 ...
   P.U.      SUBTOTAL   IVA    TOTAL
  88.42       176.84    0.00   176.84
```

`396.00` es precio de lista, `D` el descuento (%), y **`88.42` es el costo real
unitario**. Ese P.U. es el que se carga como `costo`, no el precio de lista ni
el de la caja.

## Hallazgo clave

Cada línea trae **lote y caducidad además del costo**. Eso convierte al número
de lote en un identificador casi único para emparejar foto ↔ ticket, mucho más
fiable que el nombre. De hecho, el cruce por lote destapó cuatro asignaciones
equivocadas del lote 3 (ver conflictos abajo).

## Cruce confirmado: 23 productos

Se aplican en `sql/patch_ticket_equilibrio_440393_2_COSTOS_LOTE3.sql`.

| SKU | Producto | Línea del ticket | Lote | Caducidad | Costo |
| --- | --- | --- | --- | --- | ---: |
| FC-00422511 | Bactiver susp. 120 mL | MAV003 BACTIVER 1 SUSP 40/200/5/120 ML | 262631 | 2028-05-01 | 21.28 |
| FC-53601339 | Daclafin susp. 120 mL | DAC005 DACLAFIN SUBSALICILATO BISMUTO | 26C0037 | 2028-03-31 | 31.49 |
| FC-82200016 | Aktyzar omeprazol C/120 | SOF054 OMEPRAZOL (AKTYZAR) 120 CAPS | 61168 | 2028-06-05 | 46.79 |
| FC-31405888 | Plusgel antiácido C/50 | COL083 PLUS GEL 50 TAB 200/200/20 MG | 26141277 | 2028-05-23 | 48.77 |
| FC-09749209 | Lumboxen parche C/1 | MAV400 LUMBOXEN 1 BOL C/1 PCHE | 20251225 | 2028-12-31 | 14.37 |
| FC-27875568 | Desrotan fexofenadina 180 mg | RAM100 DESROTAN 10 TAB 180 MG | RD085 | 2028-03-31 | 47.31 |
| FC-1FFBB505 | Supratex levodropropizina 120 mL | MAI157 SUPRATEX 1 JBE 600 MG 120 ML | 6BD201 | 2028-02-01 | 40.91 |
| FC-52D2A43A | Zukedib glimepirida 2 mg C/30 | LOE070 ZUKEDIB 30 TAB 2 MG | R25126048 | 2028-01-13 | 29.08 |
| FC-09745584 | Oppelver lactulosa 125 mL | MAV245 OPPELVER 1 JBE 10G/15ML 125 ML | 261962 | 2028-03-01 | 49.25 |
| FC-75723137 | Novakosid senósidos C/20 | NOV136 NOVAKOSID 20 TAB 8.6 MG | 540266 | 2028-05-01 | 13.93 |
| FC-03388008 | Velatuss levodropropizina 120 mL | RAY114 VELATUSS 1 SOL 600MG/120 ML | 25109 | 2027-05-01 | 34.55 |
| FC-73906469 | Biobend bencidamina 360 mL | BIO146 BIOBEND 1 SOL .15G/360 ML | LD2619 | 2028-04-01 | 39.49 |
| FC-27427392 | ML-PRIM metocarbamol/ibuprofeno | GEP030 ML-PRIM 12 CAPS 375/200MG | 260735 | 2028-03-01 | 47.28 |
| FC-03738879 | Rosel-t antigripal C/15 | WER015 ROSEL T 15 TAB 300/50/3 MG | 251070 | 2028-01-01 | 21.26 |
| FC-01165953 | Rexurdir nifuroxazida C/16 | SON226 REXURDIR 16 CAPS 400 MG | 26051290 | 2028-05-01 | 29.92 |
| FC-11165726 | Raspisons ungüento 35 g | SON173 RASPISONS 1 UNG 28/35 G | 25123585 | 2027-12-01 | 19.61 |
| FC-31144302 | Collifrin oximetazolina 20 mL | COL145 COLLIFRIN ADULTO 1 SOL 50MG/20 ML | 26140881 | 2028-04-06 | 33.61 |
| FC-04908738 | Lidocaína ungüento 5% 35 g | ALP0380 LIDOCAINA 1 UNG 5% 35 G | 2602578 | 2028-02-01 | 23.30 |
| FC-16803800 | Omeprazol Avivia C/60 | AVI004 OMEPRAZOL 60 CAPS 20 MG | 5LM253D | 2028-11-15 | 32.76 |
| FC-36003621 | Precicol gotas 20 mL | LIF162 PRECICOL 1 GOT 20 ML | 26C062 | 2028-03-31 | 37.22 |
| FC-27872123 | Raamcinet cetirizina 10 mg | RAM054 RAAMCINET 10 TAB 10 MG | 7220526 | 2028-03-31 | 19.65 |
| FC-27871416 | Raamfen difenidol 25 mg | RAM046 RAAMFEN 30 TAB 25 MG | RR184 | 2028-03-31 | 15.49 |
| FC-75718676 | Novagon psyllium 400 g | NOV098 NOVAGON PIÑA-NARANJA 1 PVO 35G/400 G | 491066 | 2030-04-01 | 97.10 |

En los primeros cinco el número de lote es idéntico al que ya estaba
registrado, así que el emparejamiento es directo. El resto cruza por nombre
comercial inequívoco: hay una sola línea candidata en las 481 del ticket.

Novagon es el único con holgura: el lote 3 registró `491866` y el ticket dice
`491066`, un dígito de diferencia, y la caducidad coincide (abril 2030).

## Conflictos: 4 lotes asignados al producto equivocado

Aquí el lote que quedó guardado en la base pertenece, según el ticket, a otro
producto. Es el mismo error de emparejamiento de fotos, pero propagado a los
lotes. **No los toca el patch**, hay que decidir cada uno.

| SKU y nombre en la base | Lote guardado | A qué producto pertenece ese lote en el ticket | Costo de esa línea |
| --- | --- | --- | ---: |
| FC-09745027 Treda infantil susp. Maver | 262654 | MAV250 GALAVER 1 GEL 8MG/1MG/250 ML | 48.22 |
| FC-09745560 Kao-Paver infantil susp. Maver | 255469 | MAV238 BIOXOVER 1 JBE 300MG/120 ML | 28.84 |
| FC-75717914 K-PEC susp. infantil Novag | 460056 | NOV090 NINEKA 1 SUSP 500/36/35MG/5/75 ML | 23.45 |
| FC-75713770 Metamizol sódico sol. Novag Infancia | 500546 | NOV017 NOVAGON 1 PVO 49.7G/100G DE 400 G | 99.10 |

El caso de Novag es el más claro: los lotes `500546` y `491066` son los dos
Novagon en polvo del ticket (natural y piña-naranja). Que uno haya quedado
como "Metamizol sódico Novag Infancia" apunta a que esa foto era en realidad
el Novagon natural.

**Decisión (2026-08-15):** no se corrigen a ciegas. Quedan pendientes hasta
revisar las fotos originales de esos cuatro productos.

## Probables, falta confirmar

| SKU | Nombre en la base | Candidato en el ticket | Costo | Por qué dudo |
| --- | --- | --- | ---: | --- |
| FC-09747236 | Bactiver infantil tabletas Maver | MAV001 BACTIVER 20 TAB 400/80 MG | 16.89 | también está MAV002 BACTIVER F 14 TAB 160/800 MG a 21.01 |
| FC-23111387 | Jarabe dropropizina/bromhexina Quimpharma 100 mL | QUM068 QUIMUNEX 1 SOL 100 MG/100 ML | 68.48 | los Drosequim (QUM069/QUM070) también son Quimpharma jarabe |
| FC-14377180 | Playboy Max Sens C/4 3+1 | PBY007 MAX SENS TROPICANA MIX | 23.17 | hay dos presentaciones, falta saber cuál EAN es cuál |
| FC-14377197 | Playboy Max Sens Extra Sensible C/4 3+1 | PBY008 MAX SENS PASSION MIX | 23.21 | igual que el anterior |

**Decisión (2026-08-15):** tampoco entran al patch. Se confirman con foto.

## Sin match en este ticket

- **FC-18754259** Levocetirizina Mavi Reg. 086M2019 — no hay ninguna
  levocetirizina en las 481 líneas.
- **FC-09745522** Treda antidiarreico sobres Maver — no aparece "Treda" en el
  ticket. El Treda C/20 que ya tiene costo ($139.84) venía de otro ticket, así
  que este lote probablemente también.
- Los **9 registros fantasma** (`FC-09740435`, `FC-24901059`, `FC-49022485`,
  `FC-27426982`, `FC-01165397`, `FC-01165724`, `FC-23111202`, `FC-11784029`,
  `FC-09763986`) no tienen nombre real, así que no hay por dónde cruzarlos. Se
  resuelven identificando el producto de la foto, no desde el ticket.

## En el ticket pero no en el catálogo

Tres que saltan a la vista porque son variantes de productos que sí cargamos:

- **LOE071 ZUKEDIB 30 TAB 4 MG** — lote R2506781, cad. 2027-06-30, costo 27.98
- **PBY004 PLAYBOY PLAYPACK 1 BLISTER C/3 PZAS** — lote 1991025, costo 30.83
- **MAI158 SUPRATEX DAC 1 SOL 300/600 MG 120 ML** — lote 5K2102, costo 42.14
  (distinto del Supratex simple que sí está)

El resto de las 481 líneas hay que cruzarlas contra el catálogo completo. Para
eso está el staging.

## Cómo correrlo

1. `sql/patch_ticket_equilibrio_440393_1_STAGING.sql` — carga las 481 líneas en
   `public.ticket_equilibrio_440393` y trae tres consultas de cruce: por número
   de lote, por nombre comercial, y el listado de productos con costo 0.
2. `sql/patch_ticket_equilibrio_440393_2_COSTOS_LOTE3.sql` — aplica los 23
   costos confirmados. Respalda en `public.costos_ticket_440393_respaldo`.
3. `sql/pricing/003_preview_pricing.sql` y `004_apply_pricing_idempotente.sql` —
   recalculan el precio de venta con las reglas de recargo.

El patch de costos no fija precio a propósito: el motor de pricing ya tiene las
reglas por categoría (genérico 60%, marca RX 25%, OTC marca 35%, etc.) y marca
los productos con `price_needs_review = true` para que entren en el recálculo.
