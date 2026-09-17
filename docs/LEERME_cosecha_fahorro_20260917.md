# Cosecha Fahorro — 17-sep-2026

Sí: el catálogo lo armé yo. No hay que copiar producto por producto ni dar claves B2B.

El script `scripts/cosechar-fahorro-vitrina.js` leyó el GraphQL público de Fahorro (SKU = EAN, packshot, precio de lista), filtró kits / higiene íntima / códigos de 14 dígitos dudosos, bajó las fotos a `public/catalogo-propia/` y `scripts/alta-bajo-pedido-desde-fichas.js` armó el SQL.

**Lo único que falta de tu lado:** después de publicar este PR, pegar en Supabase → SQL Editor:

`sql/patch_alta_bajo_pedido_cosecha_fahorro_20260917.sql`

Idempotente. Stock 0. Sin lote ni caducidad. Si el EAN ya existe **con stock de anaquel**, no se marca bajo pedido. Las fotos apuntan a `https://www.farmacapital.mx/catalogo-propia/…` — si corres el SQL antes del deploy, se ven cuando publique.

80 SKUs (de 935 candidatas). Precio = lista Fahorro, ancla de mostrador (no es tu costo B2B).

## Dermocosmética → `/dermocosmetica` (61)

| EAN | Mostrador | Ancla |
| --- | --- | ---: |
| 3337875921336 | La Roche Posay Toleriane Dermallergo Serum 30 ml | 1004 |
| 8470003808576 | Isdin Ureadin Crema Facial 50Ml | 564 |
| 8470001776211 | Heliocare 360° 500 Mg Suplemento Alimenticio 30 Cápsulas | 911 |
| 8429979201058 | Sesderma Serum Acglicolic 30 ml | 1250 |
| 3337875782357 | CeraVe Blemish Control Gel 40 ml | 537 |
| 3701129802076 | Bioderma Atoderm Intensive Bálsamo 500 ml | 830 |
| 3282770396881 | Avène Leche Solar Adulto 250 ml | 753 |
| 3282770389234 | Ducray Melascreen Contorno de Ojos 15 ml | 948 |
| 3661434009204 | Uriage Agua Micelar Piel Sensible 100Ml | 169 |
| 3282770393712 | A-Derma Epitheliale Ultra Repair Bálsamo 50 g | 372 |
| 4006000077000 | Eucerin Epigenetic Serum facial Anti-edad 30 ml | 1434 |
| 8436574360844 | Endocare Hydractive Micelar 400 ml | 556 |
| 7501089804525 | Leti At4 Leche Corporal 250 ml | 828 |
| 3337875908368 | Vichy Refill Booster M89 50 ml | 749 |
| 7897930778634 | Cetaphil Oil Control Hidratante Facial Matificante Antimanchas 89 ml | 613 |
| 3504105032937 | Mustela Cicastela Crema Reparadora 40 ml | 244 |
| 3337875892872 | La Roche-Posay Pure Vitamin C12 Oil Control Serum 30ml | 1426 |
| 8470001507983 | ISDIN Reparador Labial 10 ml | 190 |
| 8436574364460 | Heliocare 360° Acnimat FPS 50+ 50 ml | 745 |
| 8470002259539 | Sesderma Azelac Loción 100 ml | 544 |
| 3337875795456 | Cerave SA Limpiador Anti-rugosidades 473ml | 604 |
| 3701129802069 | Bioderma Atoderm Intensive Bálsamo 200 ml | 598 |
| 3282770396317 | Avène Spray Solar Niños FPS 50+ 200 ml | 804 |
| 3282779368612 | Ducray Keracnyl PP+ 30 ml | 972 |
| 3661434005503 | Uriage Mascarilla De Noche Con Agua Termal 50Ml | 615 |
| 3282771057392 | A-Derma Dermalibour+ Cica-Crema Calmante Reparadora 50 ml | 408 |
| 4005900436979 | Eucerine Dermopure Crema Facial de Noche 40 ml | 865 |
| 8470001529688 | Endocare Tensage Suero 30 ml | 1116 |
| 7501089804433 | Leti At4 Intensive 1 Crema 100 ml | 664 |
| 3337875920971 | Vichy Dercos Collagen 17 Acondicionador 200 ml | 694 |
| 7640203240242 | Cetaphil Exfoliante Ultra Suave 178 ml | 374 |
| 3504108090743 | Mustela Jabon Natural Facial y Corporal Piel Normal 100 g | 102 |
| 3337875725897 | La Roche Posay Agua Micelar Ultra en Aceite Bifásica 400 ml | 885 |
| 8429420251366 | Isdin Ureadin Lotion 10 400Ml | 563 |
| 8470001592453 | Heliocare 360° Advanced Gel FPS 50+ 250 ml | 809 |
| 8470002073241 | Sesderma Azelac Gel Hidratante 50 ml | 905 |
| 3337875684118 | Cerave SA Limpiador Anti-rugosidades 236ml | 464 |
| 3401528509551 | Bioderma Photoderm Aquafluido Pocket 30 ml | 406 |
| 3282770207774 | Avène Cleanance Gel Limpiador 400 ml | 858 |
| 3282770398168 | Ducray Anaphase Shampoo Anticaída Ocasional 200 ml | 661 |
| 3661434000522 | Uriage Agua Termal 300 ml | 487 |
| 3282770393859 | A-Derma Exomega Control Aceite de Limpieza 500 ml | 669 |
| 4005900436993 | Eucerin Dermopure Exfoliante 100 ml | 583 |
| 8470003310338 | Cantabria Endocare Crema 30 ml | 978 |
| 8431166181852 | Leti At4 Multiprotect Loción Corporal Fps50+ 100 Ml | 842 |
| 3337875921008 | Vichy Dercos Collagen 17 Shampoo 200 ml | 694 |
| 7897930778641 | Cetaphil Oil Control Serum Facial Triple Acción 30 ml | 451 |
| 3504105025816 | Crema Mustela para Rozaduras Bebe 50 ml | 145 |
| 3337875816847 | La Roche Posay Cicaplast 100 ml | 649 |
| 8429420251632 | Isdin Ureadin Shower Gel 400Ml | 643 |
| 8436574363388 | Heliocare 360° Mattifying Brush 3 gr | 694 |
| 8470001613233 | Sesderma Salises Gel Hidrat 50 ml | 1329 |
| 3337875904292 | Cerave Loción Hidratante Intensiva 236 ml | 482 |
| 3701129805329 | Bioderma Atoderm Crema Ultra 200 ml | 295 |
| 3282779003131 | Agua Termal Avène 300 ml | 562 |
| 3282770389197 | Ducray Melascreen Concentrado Despigmentante 30 ml | 1165 |
| 3661434009976 | Uriage Age Absolu Serum Anti Edad 30Ml | 1086 |
| 3282770153002 | A-Derma Biology AC Gel Espumoso Purificante 400 ml | 743 |
| 4006000028828 | Eucerin DermoPure Gel Concentrado 150 ml | 544 |
| 8470003468237 | Endocare Tensage Crema 30 ml | 1259 |
| 7501089804518 | Leti At4 Gel de Baño 250 ml | 529 |

## Nutrición / suplementos → `/vitaminas` (9)

| EAN | Mostrador | Ancla |
| --- | --- | ---: |
| 7503025737386 | BIRDMAN Minerales 300ml | 431 |
| 7503057040362 | Falcon Proteina Chocolate 480 g | 600 |
| 748927051254 | Optimum Nutrition Gold Standard Proteína Whey Sabor Chocolate 907 gr | 1253 |
| 7503053835191 | Birdman Creatina Monohidratada 125 Caps | 402 |
| 7503057040539 | Falcon Performance Vainilla 552 g | 600 |
| 748927068023 | Optimum Nutrition Gold Standard 100% Plant Protein Vainilla 444 gr | 635 |
| 7503037273315 | Birdman Fitmingo Proteína Vegetal Sabor Vainilla 34 gr | 44 |
| 7503057040478 | Falcon Performance Choco Bronze 552 g | 600 |
| 748927068047 | Optimum Nutrition Gold Standard 100% Plant Protein Chocolate 480 gr | 635 |

## Dispositivos → `/dispositivos` (10)

| EAN | Mostrador | Ancla |
| --- | --- | ---: |
| 073796801212 | Omron Nebulizador con Compresor Modelo Ne-C801 | 1231 |
| 7503012700065 | Nebulizador Nebucor N-102 portátil silencioso de pistón - fácil de usar | 980 |
| 7500399003154 | HANDY Nebulizador de Pistón | 1065 |
| 4015630082988 | Accu-Chek Active Glucómetro | 623 |
| 073796451011 | Omron Nebulizador de Compresor Ne-C101 | 1133 |
| 7503012700034 | Baumanómetro Digital de muñeca Nebucor HL-158 - monitor de presión arterial | 625 |
| 7500399003215 | Micronebulizador Adulto Handy | 199 |
| 4015630066834 | Accu-Chek Guide Tiras 25 | 244 |
| 073796612429 | Omron Monitor de Presión Automático | 847 |
| 756058792632 | Accu-Chek Instant Tiras Reactivas 50+25 piezas | 463 |

## Qué se omitió a propósito

- Higiene íntima (no es vitrina de derma).
- EAN de 14 dígitos que Fahorro mete como SKU interno (no es GTIN usable).
- Kits, packs y “de regalo”.
- MuscleTech: Fahorro no devolvió ficha con EAN + foto + precio usable en esta pasada.
- SKU Promexsa tipo `ORT-…` / `DIS-…`: no son EAN.

Para otro corte, sin tocar producto por producto:

```
FC_COSECHA_MAX=80 node scripts/cosechar-fahorro-vitrina.js
node scripts/alta-bajo-pedido-desde-fichas.js docs/fichas_cosecha_fahorro.json sql/patch_alta_bajo_pedido_cosecha_fahorro_SIGUIENTE.sql
```
