# Comparativa de distribuidores · 18 sep 2026

**Pregunta:** ¿a quién conviene comprarle, y qué vale la pena poner en inventario, después de subirles ganancia?

**Respuesta corta:** Mepiel **no es la mejor**. Ni siquiera tenemos su lista. El que más renglones trae no es el que más conviene. Cada proveedor sirve para un rubro; ninguno gana en todo.

Regla FarmaCapital: `precio = costo mayoreo × 1.25` (marca) o `× 1.60` (genérico). Si eso queda arriba del PVP de mercado → no se encarga con precio; se cotiza o se busca otro mayoreo.

Los archivos `farmacapital-sprint0-politica-medicamentos.patch` y `Farmacapital_Sprint0_Revision_1.md` **no entran** en esta tabla: son la política de antibióticos / receta, no precios.

---

## 1. Quién es quién

| Proveedor | Qué es de verdad | Filas en lista | Costo usable | ¿Lista de mayoreo? | Rubro |
|---|---|---:|---:|---|---|
| **Dermaexpress** (`catalogo_farmacapital_1.csv`) | Mayoreo dermo con EAN, foto y PVP de referencia | 2,017 | **2,017** (1,492 “en existencia” en su web) | Sí | Dermatología / solar / capilar |
| **Bioinstrumental** (Farmacia Integral) | Mezcla Odoo: maquillaje + dermo + un poco de equipo. El 76% tiene precio $1 | 3,644 | **855** (solo 18 “disponibles en web”) | A medias: precio **sin IVA**, muchos simbólicos | Dermo barato + Pink Up / Yuya |
| **Ewafra / DIS** (lista ago-2026) | Mayoreo de insumos (lista 6 −20%) | 1,218 | **1,197** | Sí | Dispositivos, curación, jeringas |
| **Promexsa** | Precio **de vitrina**, no de compra | 1,179 | **0** costo mayoreo | No. El sitio pide WhatsApp para mayoreo | Techo de mercado de insumos |
| **Birdman** | Mayoreo de la marca (escalón chico) | 125 | ~110 (sin playeras) | Sí | Proteína / suplemento |
| **Mepiel** | Lista de precios 2026 (precio cliente c/IVA) | 2,213 | **2,213** | Sí | Dermatología |

Tener más filas no es mejor: Bioinstrumental “gana” en tamaño y pierde en costo usable.

---

## 2. Mepiel

La lista 2026 ya está en `mepiel_lista_2026.csv`. El costo usable es el **precio cliente c/IVA**. El cruce por EAN contra Dermaexpress se hace al generar el alta: si ambos tienen costo, se guarda el más barato. El precio público de la lista no se publica en la vitrina.

---

## 3. Dermaexpress · el único mayoreo dermo que sí tenemos

De `catalogo_farmacapital_1.csv` (mismo fondo que `catalogo_dermaexpress.csv`):

| Semáforo (si vendes al PVP de referencia) | Qué significa | Piezas (todas) | De las disponibles |
|---|---|---:|---:|
| **VERDE** | Cabe margen sano vs PVP | 3 | 2 |
| **AMARILLO** | Cabe el +25% de marca (~20% de margen) o cerca | 695 | 517 |
| **ROJO** | Al PVP te quedan ~12–19% de margen (mediana 16.8%). El +25% se pasa del mercado | 595 | 435 |
| **SIN_REF** | Hay costo, no hay PVP ancla | 724 | 538 |

| Prioridad | Piezas disp. | Capital si compras 1 pza de cada una |
|---|---:|---:|
| A (sí vale la pena cotizar / encargar) | 618 | ~$336,000 |
| Todas las disponibles | 1,492 | ~$1,007,000 |

Ticket mediano si pones +25% al costo: **~$727**. Marcas: Isdin, La Roche-Posay, Bioderma, Vichy, Uriage, Avène, Cantabria, Eucerin.

**Para inventario físico:** no las 2,017. Solo las **disponibles + prioridad A + AMARILLO/VERDE** (unas 488), las de rotación (Cicaplast, Lipikar, mineral 89, solares de mostrador). Las ROJO y las de $3,000+ (Alastin, Esthederm) se quedan en `/conseguir` o se cotizan.

**Para `/conseguir`:** las disponibles con costo usable. ROJO → Encargar solo si aceptas margen chico o si encuentras otro mayoreo más barato.

---

## 4. Bioinstrumental · grande, sucia, a veces más barata

| Filtro | Piezas |
|---|---:|
| Lista completa | 3,644 |
| Precio simbólico ($1 / “no válido”) | 2,789 |
| Precio válido | 855 |
| Válido **y** “disponible en web” | **18** |

Precio mediano válido: **$150 sin IVA** (~$174 con IVA). Eso es otro universo que Dermaexpress ($584 de costo mediano): Pink Up, Yuya, Xiomara, Garnier, Cantu, condones, Nivea… y un bloque dermo (Isdin, Mustela, CeraVe, Avene, Eucerin).

Cruce por EAN contra Dermaexpress: **203 productos**. Detalle: `comparativo_ean_derma_bio_20260918.csv`.

| Quién sale más barato (Bio +16% IVA vs costo Derma) | Piezas |
|---|---:|
| **Dermaexpress** | 128 |
| **Bioinstrumental** | 53 |
| Empate | 22 |

Bio gana sobre todo en **Panalab** (Aminoter, Complidermol) y algo de **Farmapiel**. Derma gana en Eucerin, Bioderma, Ducray, DS Labs, varios Isdin.

Si le pones +25% al costo y lo comparas con el PVP de Dermaexpress, en esos 149 con ancla: Derma “cabe” en 136; Bio solo en 54. O sea: Bio a veces compra más barato, pero no siempre te deja vender al precio de mercado con nuestra ganancia (sus precios válidos a veces ya van altos, o el PVP está apretado).

**No cargar las 3,644 a inventario.** Son basura operativa (precio $1, sin existencia web). Sí vale como **segunda cotización** en los 53 EAN donde gana, y para maquillaje / consumo si algún día lo quieren en mostrador.

---

## 5. Insumos médicos · DIS sí, Promexsa no

Ya lo vimos con la lista Promexsa: su web está a ±2% del PVP de GOS / Lanceta / Medilandia. Si le subes +30% al “costo” Promexsa, quedas 30% caro y no vendes.

| | Ewafra / DIS | Promexsa web |
|---|---|---|
| Número que trae | Costo lista 6 (−20%) | Precio público |
| Mediana | ~$183 de **costo** | ~$134 de **PVP** (otro mix; no comparar 1:1) |
| Usar como | Costo de compra → +60% genérico / +25% marca, techo = Promexsa | Techo / nombre / foto |
| Encargar en `/conseguir` | Sí, si el costo es usable | No, salvo que te den mayoreo por WhatsApp (≥25–40% abajo de su web) |

Para **inventario físico de curación** (gasa, jeringa, guante, nelaton): DIS / Ewafra, no Promexsa. Compra las 80–150 de más rotación, no las 1,200.

---

## 6. Birdman

Lista chica y limpia. Sin playeras/shakers. El PVP de marca ya deja ~**25% de margen** sobre el costo base (escalón chico). Encaja en `/conseguir` (proteína), no en anaquel hasta que se venda seguido.

---

## 7. Tabla de decisión (después de la ganancia)

| Si quieres… | Cómprale a | No le compres a | ¿Anaquel o `/conseguir`? |
|---|---|---|---|
| La Roche, Vichy, Bioderma, Isdin, Avène, CeraVe de consultorio | **Dermaexpress** (mientras no exista Mepiel) | Promexsa; Bio salvo que el EAN salga más barato | `/conseguir` casi todo; anaquel solo A+amarillo de rotación |
| Panalab / Farmapiel más barato | **Bioinstrumental** (53 EAN del cruce) | Dermaexpress en esos EAN | Pedido; confirma que te surtan (su web dice “no”) |
| Maquillaje Pink Up / Yuya | Bioinstrumental (si te interesa el rubro) | Dermaexpress | No es el foco de la farmacia |
| Gasa, jeringa, sonda, cubrebocas | **Ewafra / DIS** | Promexsa como costo | Anaquel: top rotación. Resto `/conseguir` |
| Proteína Birdman | **Birdman** | — | `/conseguir` |
| “El catálogo más grande” | — | Elegir por filas | Infla inventario y no deja margen |

---

## 8. Qué haría yo con lo que ya tienes

1. **No esperes a Mepiel para decidir.** Cuando llegue, se cruza por EAN contra Dermaexpress y gana el más barato.
2. **Dermaexpress** = fuente principal de dermo bajo pedido. No llenar el anaquel con las 1,492.
3. **Bioinstrumental** = no se importa completo. Solo los EAN del CSV donde gana, y solo si confirman surtido real (WhatsApp / pedido de prueba).
4. **DIS** = costo de dispositivos. **Promexsa** = techo, no compra.
5. **Birdman** = proteína bajo pedido.
6. Ganancia: marca **+25% al costo** (margen 20%); genérico / insumo **+60%** (margen 37.5%). Si el PVP no aguanta, no inventes precio: Cotizar.

Comprobar un EAN concreto:

```text
docs/catalogos/comparativo_ean_derma_bio_20260918.csv
```
