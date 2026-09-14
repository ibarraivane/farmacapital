# Cruce FarmaCapital vs surtido Similares (2026-09-14)

El Excel de artículos (`pricing/fuentes/articulos_farmacias.xlsx`) no se versiona.
Este cruce usó el catálogo público de Similares (VTEX) del 2026-09-14: la misma lista de farmacia, precios al día.

El match es por **genérico** (principio + concentración + forma), no por marca comercial.
Si Similares vende ibuprofeno 400 mg 10 tabletas y nosotros tenemos AMSA/Ultra de esa misma presentación, cuenta como cubierto.

## Resumen

- Artículos únicos Similares (farmacia, sin souvenirs/perfumería/alimentos): **1313**
- Productos activos en nuestro inventario: **1503**
- Ya cubiertos (los tenemos, aunque sea otra marca): **437** (33.3%)
  - con stock suficiente: **135**
  - hay que rellenar (bajo el mínimo sucursal): **302**
- Huecos (Similares lo vende y nosotros no): **876**
  - clase A (rotación alta): **63**
  - clase B: **172**
  - clase C: **576**
  - inyectables: **16**
  - curación: **49**

Para igualar el surtido de mostrador de Similares, el pedido útil es **clase A + B + curación**
(284 huecos).
Clase C (especialidad / marca propia Simi) se pide de 2 en 2 cuando ya hay consulta.

Archivos:

- `pricing/reportes/cruce_similares_20260914_prioridad.csv` — huecos A + B + curación (comprar primero)
- `pricing/reportes/cruce_similares_20260914_huecos.csv` — resto de huecos (especialidad)
- `pricing/reportes/cruce_similares_20260914_rellenar.csv` — ya los tenemos, stock bajo el mínimo
- `pricing/reportes/cruce_similares_20260914_cubiertos.csv` — ya cubiertos

## Huecos prioridad por línea

| Línea | Huecos A/B/curación |
| --- | ---: |
| Material de curación | 50 |
| Analgésicos | 34 |
| Funcionamiento gastrointestinal | 18 |
| Antihipertensivo | 16 |
| Medicamentos éticos | 16 |
| Aparato respiratorio | 13 |
| Antibiótico | 12 |
| Antimicótico | 10 |
| Dermatológico | 9 |
| Antigripal | 8 |
| Antialérgico | 7 |
| Antiinflamatorio | 6 |
| Diabetes | 6 |
| Material de diagnóstico | 6 |
| Gripa y tos | 5 |
| Oftalmológico | 5 |
| Protector solar | 5 |
| Sistema inmune | 4 |
| Enfermedades mentales | 4 |
| Antiparasitario | 3 |

## Huecos clase A (muestra)

| Pedir | Precio Simi | Genérico | Línea |
| ---: | ---: | --- | --- |
| 6 | $119 | AMBROXOL 20MG 18 PASTILLAS HISTIACIL GR3 | Gripa y tos |
| 5 | $119 | CLORZOXAZONA / KETOPROFENO 250/50MG 10 TABLETAS | Analgésicos |
| 5 | $116 | FLOROGLUCINOL 2GR/100ML  SOLUCION GOTAS SABOR LIMON 30 ML 1 PIEZA | Analgésicos |
| 6 | $103 | PARACETAMOL 80MG 30 TABLETAS MASTICABLES TEMPRA | Analgésicos |
| 6 | $99 | IBUPROFENO / DIFENHIDRAMINA 200MG/25MG 10 CAPSULAS GEL | Analgésicos |
| 5 | $99 | ITOPRIDA 50 MG 30 TABLETAS | Funcionamiento gastrointestinal |
| 5 | $98 | BUSCAPINA 12 TABLETAS CON HIOSCINA. AUXILIAR EN EL ALIVIO DEL DOLOR DE | Analgésicos |
| 6 | $94 | PARACETAMOL / FENIRAMINA / FENILEFRINA SABOR MANZANA CANELA GRANULADO  | Antigripal |
| 5 | $89 | GEL TOPICO MENTOL / ARNICA / CALENDULA / SABILA 100 GR 1 PIEZA | Analgésicos |
| 6 | $89 | NAPROXENO/CARISOPRODOL 250MG/200MG 30CAPSULAS | Antiinflamatorio |
| 6 | $84 | LEVODROPROPIZINA / AMBROXOL 0.6/0.3GR/100ML SOLUCION 120ML | Aparato respiratorio |
| 5 | $82 | SUCRALFATO 1 GR 40 TABLETAS | Funcionamiento gastrointestinal |
| 6 | $72 | PARACETAMOL 80MG 30 TABLETAS MASTICABLES MEJORALITO | Analgésicos |
| 6 | $71 | CIPROFLOXACINO / DEXAMETASONA 3.5/1 MG SOLUCION OFTALMICA 5 ML 1 PIEZA | Oftalmológico |
| 6 | $69 | CLOTRIMAZOL/ DEXAMETASONA 1GR/0.04GR CREMA 30 GR GENERICO | Antimicótico |
| 5 | $69 | CUO PROTECT 100 MG 30 TABLETAS LIBERACION RETARDADA | Analgésicos |
| 6 | $69 | DICLOFENACO .18 GR SUSPENSION 120 ML 1 PIEZA | Antiinflamatorio |
| 5 | $66 | ACARBOSA 50 MG 30 TABLETAS | Diabetes |
| 6 | $66 | CAPTOPRIL 50 MG 30 TABLETAS | Antihipertensivo |
| 6 | $66 | METRONIDAZOL / DIYODOHIDROXIQUINOLEINA SUSPENSION 120 ML 1 PIEZA | Antiparasitario |
| 6 | $64 | DICLOFENACO SODICO / VITAMINAS B1 / B6 / B12 30 TABLETAS | Antiinflamatorio |
| 6 | $64 | LEVOCETIRIZINA 0.5MG SOLUCION | Antialérgico |
| 6 | $62 | METFORMINA 750 MG 30 TABLETAS LIBERACION PROLONGADA | Diabetes |
| 6 | $61 | DEXTROMETORFANO 10 MG/ PARACETAMOL 250 MG/ BROMFENIRAMINA 2 MG/ FENILE | Antigripal |
| 6 | $59 | CLOTRIMAZOL DUAL (CREMA VAGINAL 10 GR/ 3 OVULOS) | Antimicótico |
| 6 | $59 | IBUPROFENO 40MG/1ML SUSPENSION 15 ML 1 PIEZA | Analgésicos |
| 5 | $55 | ARNICA 6C 30 TABLETAS | Analgésicos |
| 5 | $54 | ARNICA MONTANA / HAMAMELIS VIRGINIANA UNGÜENTO 30 GR 1 PIEZA | Analgésicos |
| 5 | $53 | BUTILHIOSCINA SOLUCION 15 ML 1 PIEZA | Analgésicos |
| 6 | $52 | PARACETAMOL/CAFEINA/FENILEFRINA 10 TABLETAS SEDALMERCK | Analgésicos |
| 6 | $51 | PARACETAMOL 300 MG 6 SUPOSITORIOS | Analgésicos |
| 5 | $49 | ALUMINIO / MAGNESIO / DIMETICONA / METOCLOPRAMIDA 30 TABLETAS | Funcionamiento gastrointestinal |
| 6 | $49 | AMBROXOL/DEXTROMETORFANO 22.5/22.5MG 20 TABLETAS | Gripa y tos |
| 6 | $49 | DEXTROMETORFANO / PARACETAMOL / CLORFENAMINA / FENILEFRINA 12 CAPSULAS | Antigripal |
| 6 | $49 | METFORMINA / GLIBENCLAMIDA 500/2.5MG 60 TABLETAS | Diabetes |
| 6 | $48 | ACIDO ACETILSALICILICO 500MG 12 TABLETAS EFERVESCENTES ASPIRINA | Analgésicos |
| 6 | $48 | FENILEFRINA / CLORFENAMINA / GUAIFENESINA / PARACETAMOL INFANTIL JARAB | Antigripal |
| 6 | $48 | KETOPROFENO / PARACETAMOL 100/300MG 12 TABLETAS | Antiinflamatorio |
| 6 | $48 | PARACETAMOL / BUTILHIOSCINA 100/2 MG SOLUCION GOTAS 20 ML 1 PIEZA | Analgésicos |
| 6 | $42 | LORATADINA / BETAMETASONA  5 /.25 MG 10 TABLETAS | Antialérgico |
