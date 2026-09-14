# Fotos: frente de caja + faltantes (14-sep-2026)

Snapshot live Supabase · 1503 activos · 199 sin `imagen_url` ni galería (193 con stock).

## Qué se arregló del lado de la caja

| SKU | Producto | Antes | Ahora |
|---|---|---|---|
| `FC-49029040` | Ketorolaco/Tramadol AMSA 10/25 mg 3 amp | Solo el **costado legal** (vía de administración) | Frente AMSA con el nombre del producto. Mismo archivo `catalogo-propia/ketorolaco-tramadol-amsa-10-25-iny-3amp.jpg` — pide **deploy** |
| `EQ-AMS075` | Hioscina AMSA 20 mg/1 ml C/3 amp | Nadro `_01` de canto | Farmatodo frente verde (`7501349024045_01.jpg`) |

Otras cajas altas (Acetif SI, Mometasona nasal, Losil spray, Cefotaxima, Cefuroxima, Valtrover G, Ampigrin, Busconet) **sí muestran la cara con el nombre**. En inyectables/sprays esa cara es el frente, no el costado del código.

## Fotos nuevas (frente de caja / frasco)

### Por EAN exacto (Farmatodo / Nadro)

| Stock | SKU | Producto | Fuente |
|---:|---|---|---|
| 7 | `FC-75073114` | Rexona Men Clinical Clean stick 46 g | Nadro |
| 4 | `FC-63310269` | Biopram Metoclopramida 10 mg C/20 | Farmatodo |
| 2 | `FC-LV-GNO016` | Lomecan Duo óvulos + crema | Nadro |
| 2 | `FC-40036354` | Genoprazol 20 mg C/7 | Farmatodo |
| 2 | `FC-00024798` | Always nocturnas alas C/8 | Farmatodo |
| 2 | `FC-86494286` | Oral-B cepillo EAN 7501086494286 | Farmatodo |
| 2 | `FC-03477270` | Curitas El Gallo callos C/6 | Farmatodo |
| 2 | `FC-98062243` | Pharmaton Complete C/100 | Nadro `_01` (frente; `_02` es el costado legal) |
| 1 | `FC-27870259` | Roxidolin Doxiciclina 100 mg C/10 | Nadro |
| 1 | `FC-42700643` | Irbesartán/HCTZ 150/12.5 C/28 Camber | Farmatodo |
| 1 | `FC-49022492` | Irbesartán 150 mg C/28 AMSA | Nadro |
| 0 | `FC-42700629` | Irbesartán 300 mg C/28 Camber | Nadro |
| 1 | `FC-00315021` | Tukol-D Infantil 125 ml | Farmatodo |
| 1 | `FC-00661391` | Suerox 8 Iones Frutos Rojos 630 ml | Farmatodo |
| 1 | `FC-19039355` | Parches Saba térmicos C/3 | Nadro |

### Internet / mayoreo (copiadas a catalogo-propia)

| Stock | SKU | Producto | Archivo |
|---:|---|---|---|
| 5 | `EQ-NOV176` | Pirinovag 500 mg C/10 | `pirinovag-500mg-10tab.jpg` |
| 2 | `FMX-502046` | Calazin suspensión 180 ml | `calazin-suspension-180ml.jpg` |
| 2 | `FC-2E5B7248` | Reomatolum del Viejito | `reomatolum-del-viejito.jpg` |
| 1 | `FC-09747786` | Culminax Pediátrico 150 ml | `culminax-pediatrico-150ml.jpg` |
| 1 | `FMX-501619` | Eucalin Miel 120 ml | `eucalin-miel-120ml.jpg` |

### Nombre + presentación (sin EAN en inventario, Nadro sí)

| Stock | SKU | Producto | Fuente |
|---:|---|---|---|
| 1 | `FMX-500998` | Gelcavit Platinum C/30 | Nadro `7501130713851_01` |
| 1 | `FMX-501000` | Gelcavit Colors C/30 | Nadro `7501130713547_01` |
| 1 | `FMX-501003` | Gelcavit Q-10 C/30 | Nadro `7501130711642_01` |

## Qué pegar en Supabase

1. Deploy de los JPG en `public/catalogo-propia/` (keto + pirinovag + calazin + culminax + eucalin + reomatolum).
2. `sql/patch_fotos_frente_y_faltantes_20260914.sql`.

## Lo que queda — `sql/generated/fotos_pendientes_tras_lote_20260914.csv`

Nadro i22 a veces responde con **otro EAN** (no se usa). Farmatodo no trae estas presentaciones. Open Facts vacío.

### Medicamentos con EAN, sin packshot público de esa caja

No se usó otra presentación (Aspirina 20/40 ≠ `7501008491074`; Cafiaspirina C/100 pública es `7501008433515`; Sixol ≠ Colchicina `7501573909958`; Pharmaton C/30-C/60 ≠ este C/100, que sí se encontró).

| Stock | SKU | EAN | Producto |
|---:|---|---|---|
| 16 | `FC-08491074` | 7501008491074 | Aspirina (no hay ficha de este EAN; las de 20/40 son otros códigos) |
| 5 | `EQ-ALP0634` | 7502226294766 | Losartán Alpharma 50 mg C/30 |
| 4 | `FC-73909859` | 7501573909859 | Sarox Omeprazol 20 mg C/28 (solo fotos con marca de agua) |
| 2 | `EQ-BIO212` | 7501573909958 | Colchicina Biomep 1 mg C/30 (Sixol es otro EAN) |
| 2 | `FC-08491096` | 7501008491096 | Cafiaspirina tartrato C/100 (el packshot público es otro EAN) |
| 1 | `EQ-VIT073` | 7501478317421 | Bocetix 50 mg/150 ml |
| 1 | `FC-01167001` | 7502001167001 | LAÜR Infantil C/3 |
| 1 | `FC-82200016` | 7501482200016 | Omeprazol Aktyzar |

### Realmente no se sabe qué son (sin EAN / nombre de ticket)

Ramcinet, Compl, Acetilsalicílico Ef, Amoxicilina, Gentamicina, Mertiolate Kohn Rojo, Hidroxon, Tratidri, Ursodesoxicólico, Aquito, Drosquim, Eferox, «Susp 125 Mg/Ml», «FC producto botiquín», Naturex/Vita Kid/Sol-Sun/Pleniform sin código (Pleniform solo tenía foto de lifestyle, no packshot).

No se inventa foto a ciegas.

### No se busca packshot (regla del catálogo)

Jeringas SensiMedical, goteros, cintas, cubrebocas, perillas, Tegaderm C/50, Mercurio/Velázquez, EANs internos `200…`, alcohol Dibar 250 ml (el 125 ml ya tiene foto propia).
