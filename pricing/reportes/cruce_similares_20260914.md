# Cruce FarmaCapital vs surtido Similares (2026-09-14)

Fuente: **excel:articulos_farmacias.xlsx**.

El match es por **genérico** (principio + concentración + forma), no por marca comercial.
Si Similares vende ibuprofeno 400 mg 10 tabletas y nosotros tenemos AMSA/Ultra de esa misma presentación, cuenta como cubierto.

## Resumen

- Artículos únicos Similares (farmacia, sin souvenirs/perfumería/alimentos): **1281**
- Productos activos en nuestro inventario: **1503**
- Ya cubiertos (los tenemos, aunque sea otra marca): **433** (33.8%)
  - con stock suficiente: **98**
  - hay que rellenar (bajo el mínimo sucursal): **335**
- Huecos (Similares lo vende y nosotros no): **848**
  - clase A (rotación alta): **85**
  - clase B: **203**
  - clase C: **509**
  - inyectables: **0**
  - curación: **51**

Para igualar el surtido de mostrador de Similares, el pedido útil es **clase A + B + curación**
(339 huecos).
Clase C (especialidad / marca propia Simi) se pide de 2 en 2 cuando ya hay consulta.

Archivos:

- `pricing/reportes/pedido_alta_rotacion_surtir_20260914.xlsx` — **Excel para surtir** (solo alta rotación de mostrador)
- `pricing/reportes/cruce_similares_pedido_20260914.xlsx` — cruce completo (A/B/curación + rellenar)
- `pricing/reportes/cruce_similares_20260914_prioridad.csv` — huecos A + B + curación (comprar primero)
- `pricing/reportes/cruce_similares_20260914_huecos.csv` — resto de huecos (especialidad)
- `pricing/reportes/cruce_similares_20260914_rellenar.csv` — ya los tenemos, stock bajo el mínimo
- `pricing/reportes/cruce_similares_20260914_cubiertos.csv` — ya cubiertos

## Huecos prioridad por línea

| Línea | Huecos A/B/curación |
| --- | ---: |
| CURACION Y MEDICION | 60 |
| RESPIRATORIOS | 51 |
| ESTOMACALES (GASTRO) | 47 |
| CARDIOVASCULARES | 43 |
| ANALGESICOS | 26 |
| ANTIBIOTICOS | 24 |
| DIABETES | 15 |
| SISTEMA NERVIOSO | 15 |
| MULTIVITAMINICOS | 9 |
| ANTIMICOTICOS | 9 |
| ANTIHISTAMINICOS | 7 |
| OFTALMOLOGICOS | 6 |
| ENFERMEDADES DE LA PIEL | 5 |
| MATERNIDAD Y LACTANTES | 4 |
| ESPECIALIDAD | 4 |
| CUIDADO DE LA PIEL | 3 |
| SEXUALIDAD | 3 |
| MATERIAL DE CURACION | 2 |
| PESO Y METABOLISMO | 2 |
| HORMONALES | 2 |

## Huecos clase A (muestra)

| Pedir | Precio Simi | Genérico | Línea |
| ---: | ---: | --- | --- |
| 6 | $119 | AMBROXOL 20MG 18PAST HISTIACIL GR3 | RESPIRATORIOS |
| 5 | $119 | METOPROLOL 95MG 20TAB LP | CARDIOVASCULARES |
| 5 | $119 | RACECADOTRILO 30MG PVO 18 SOBRES GRANUL | ESTOMACALES (GASTRO) |
| 5 | $119 | TRIBENOSIDO/LIDOCAINA 5GR/2GR 30GR CREMA | ANALGESICOS |
| 5 | $116 | FLOROGLUCINOL 2GR/100ML GTS 30ML SAB LIM | ESTOMACALES (GASTRO) |
| 5 | $112 | HIDROXOCOBALAMINA 50000UI 5AMP | ANALGESICOS |
| 5 | $110 | BISOPROLOL 5MG 30TAB | CARDIOVASCULARES |
| 5 | $107 | NORFENEFRINA 10MG/1ML SOL 24ML | CARDIOVASCULARES |
| 5 | $99 | ESPORAS BAC CLAUSII 4BILL UFC SUSP 5AMP | ESTOMACALES (GASTRO) |
| 6 | $99 | IBUPROFENO/DIFENHID 200MG/25MG 10CAP GEL | ANALGESICOS |
| 5 | $99 | ITOPRIDA 50MG 30TAB | ESTOMACALES (GASTRO) |
| 5 | $99 | RACECADOTRILO 10MG PVO 18 SOBRES GRANUL | ESTOMACALES (GASTRO) |
| 5 | $99 | RAMIPRIL 5MG 16TAB | CARDIOVASCULARES |
| 5 | $95 | FELODIPINO 5MG 20TAB LP | CARDIOVASCULARES |
| 5 | $94 | CLONIX LIS/BUTI 125/10MG 20TAB | ESTOMACALES (GASTRO) |
| 5 | $94 | LOXCELL QUINF/ALBEND 300/400MG 1TAB | ESTOMACALES (GASTRO) |
| 5 | $94 | METFOR/GLIB 1GR/5MG 40TAB | DIABETES |
| 6 | $94 | PARACETAMOL/FENIRA/FENIL 6SOB MZNA/CANEL | RESPIRATORIOS |
| 5 | $91 | CLOROPIRAMINA 25MG 20TAB | ANTIHISTAMINICOS |
| 6 | $89 | NAPROXENO/CARISOPRODOL 250MG/200MG 30CAP | ANALGESICOS |
| 5 | $83 | LOXCELL QUINF/ALBEND 100/200MG SUSP 10ML | ESTOMACALES (GASTRO) |
| 5 | $83 | LOXCELL QUINF/ALBEND 200/400MG SUSP 20ML | ESTOMACALES (GASTRO) |
| 5 | $82 | SUCRALFATO 1GR CAJA 40TAB | ESTOMACALES (GASTRO) |
| 5 | $81 | ALENDRONATO 70MG 4TAB | ANALGESICOS |
| 6 | $79 | METFORMINA 1000MG 30TAB | DIABETES |
| 5 | $77 | ATENOLOL 100MG 28TAB | CARDIOVASCULARES |
| 6 | $74 | METFORMINA 1000MG 40TAB | DIABETES |
| 5 | $73 | CARBONATO D CALCIO 500MG 100TAB SABORES | ESTOMACALES (GASTRO) |
| 6 | $71 | CIPROFLOXACINO/DEXAMET OFT 5ML | ANTIBIOTICOS |
| 5 | $71 | CLONIX LIS/BUTI 250/10MG 10TAB | ESTOMACALES (GASTRO) |
| 5 | $71 | SIMI DIAB PLUS 30CAP | DIABETES |
| 5 | $69 | CUO PROTECT 100MG 30TAB LR | CARDIOVASCULARES |
| 6 | $69 | DICLOFENACO AC LIBRE SUSP 120ML | ANALGESICOS |
| 5 | $66 | ACARBOSA 50MG 30TAB | DIABETES |
| 6 | $66 | ATORVASTATINA 10MG 20TAB | CARDIOVASCULARES |
| 6 | $66 | CAPTOPRIL 50MG 30TAB | CARDIOVASCULARES |
| 5 | $66 | METILDOPA 250MG 30TAB | CARDIOVASCULARES |
| 6 | $66 | METRONIDAZOL/DIYODOH SUSP 120ML | ESTOMACALES (GASTRO) |
| 6 | $65 | LORATADINA/FENIL/PARA JBE 120ML | RESPIRATORIOS |
| 6 | $64 | LEVOCETIRIZINA 0.5MG SOL | ANTIHISTAMINICOS |
