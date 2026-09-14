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

1. Deploy de los JPG en `public/catalogo-propia/` (keto + pirinovag + calazin + culminax + eucalin + reomatolum + dove-original-90g + aktyzar + bocetix + **12 JPG de la tercera pasada**).
2. `sql/patch_fotos_frente_y_faltantes_20260914.sql` (ya corrido).
3. `sql/patch_fotos_nombre_exprezo_levic_20260914.sql` (ya corrido).
4. `sql/patch_fotos_resto_129_20260914.sql` (ya corrido: 22 fotos).
5. Deploy de los 7 JPG de fabricante + `sql/patch_fotos_meds_fabricante_20260914.sql`.
6. Deploy de 5 JPG más + `sql/patch_fotos_resto_busqueda_20260914.sql`.

## Segunda pasada: Exprezo + Levic + Nadro por nombre (14-sep tarde)

Exprezo no tiene API pública (portal con login). Se cruzó el CSV de piso y se buscó la foto en Nadro.

Levic: el portal sí tiene clave exacta (`VIT073` Bocetix, `BIO212` Colchicina, `NAT0617`, `NAT0220`, `SOF054` Aktyzar C/120). El CDN `visoti.mx` no responde SSL; no se bajó el webp. Donde Nadro/internet tenían el **mismo** producto (nombre + marca + presentación, EAN 12/13 ok), se usó esa foto. Cada imagen se abrió para confirmar el frente.

Cada renglón del SQL extra (`sql/patch_fotos_nombre_exprezo_levic_20260914.sql`) es un match verificado. Resumen:

| Grupo | Ejemplos |
|---|---|
| Exprezo / Levic + Nadro | Teatrical 52 g ×2, Naturex citrato/colágeno, CafiAspirina C/100, Dove 90 g, Aktyzar C/120, Bocetix 150 ml |
| Cuidado EAN exacto Nadro | Axe Black Remix / Anarchy, Adidas Fresh Endurance, Koleston 40/466/70, Lomecan Intimemo 200 ml ×2, Asepxia bicarbonato, Saba Extra C/12, Old Spice Wolfthorn, Gillette Cool Wave, Nuvel, Lady Speed Stick, Stefano ×3, Caprice, Pert oliva, Ricitos Bio-Pure, Savile roll-on, Rexona Active Emotion R-ON, Colgate Luminous 66 ml, Hair Food banana, Sensodyne 3 pz, Revlon ×3, Conse/Grisi perro, Quirmex, Saluk |
| JPG ya en repo | Adidas Control / Teamforce |

Lomecan: el ticket decía «jabón»; el EAN es shampoo íntimo Intimemo 200 ml. Se puso esa foto.

No se usó: Gerber 113 g ≠ 100 g; Dove 135 g ≠ 90 g; Pantene 400 ml ≠ EAN 3454; Sarox 14 ≠ 28; Losartán de otro lab; LAÜR adulto ≠ infantil; Honey Keeper solo el dorso; Brut Deep Blue ilegible; Nordiko 130 g (otro EAN); Xiomara pomada = `generica_1.jpg`.

JPG nuevos (piden **deploy**): `dove-original-90g.jpg`, `aktyzar-omeprazol-20mg-120cap.jpg`, `bocetix-levocetirizina-150ml.jpg`.

## Tercera pasada: los 129 (14-sep noche)

Se buscó otra vez en Nadro i22, Fahorro CDN + VTEX, Farmatodo, Similares, San Pablo, Open Facts, Levic (claves), Curitek, Buscamed, MiFarma, WeCare, Medi Beyond, Farmamedical.

`sql/patch_fotos_resto_129_20260914.sql` — **22 packshots** verificados (frente). Los 12 JPG nuevos piden **deploy**.

| Grupo | SKUs |
|---|---|
| Fahorro EAN exacto | Suerox Vitamins 630 ml, Skittles 22 g, Lysol 475 g, Dove 135 g, Honey Keeper gel 200 ml (frente; Nadro era el dorso), gotero Damaco |
| Nadro / Farmatodo EAN o nombre | Teatrical Células Madre 400 ml, Grisi concha nácar 80 ml, Brut Deep Blue, Pert oliva 180 ml |
| catalogo-propia | Savile manzanilla 150 ml, Colchicina Biomep C/30, Sarox C/28, Nordiko Original / Icy Blast, Pleniform-40, KY6 C/10, LAÜR Infantil C/3, SensiMedical 10 ml 22G, Sol-Sun Face 50 g, Tegaderm 1626W C/50, Vita Kid-C 240 ml |

No se usó: Aspirina EAN `…1074` (20/40 son otros códigos); Losartán Alpharma (placeholder Buscamed); Jaloma Mertodol 40 ml ≠ 60 ml; Gerber 113 g ≠ 100 g; Rexona stick ≠ R-ON; Ego aerosol ≠ roll-on; Sico lubricante ≠ condón.

JPG nuevos: `savile-manzanilla-spray-150ml.jpg`, `colchicina-biomep-1mg-c30.jpg`, `sarox-omeprazol-20mg-c28.jpg`, `nordiko-original-130g.jpg`, `nordiko-icy-blast-130g.jpg`, `pleniform-40-c30.jpg`, `ky6-clorfenamina-compuesta-c10.jpg`, `laur-infantil-c3.jpg`, `sensimedical-10ml-22gx32.jpg`, `solsun-cara-face-50g-fps50.jpg`, `tegaderm-3m-10x12-c50.jpg`, `vita-kid-c-jarabe-240ml.jpg`.

## Cuarta pasada: fabricante / Google (14-sep noche)

Se hizo lo que se hace a mano: Google + ficha del fabricante + ML. `sql/patch_fotos_meds_fabricante_20260914.sql` — **8 packshots** + corrección de typos. Los 7 JPG nuevos piden **deploy**.

| Stock | SKU | Ticket | Ahora | Fuente |
|---:|---|---|---|---|
| 5 | `FC-46601138` | Merthorab 20 ml Kohn | Merthiolate Rojo Kohn 20 ml | [kohnmexico.com](https://kohnmexico.com/producto/merthiolate-rojo-kohn/) |
| 5 | `FC-926099D3` | Mertiolate Kohn Rojo | Merthiolate Rojo Kohn 20 ml (C/25 = paquete) | misma foto oficial |
| 6 | `FC-26EA40A4` | Ramcinet | Raamcinet cetirizina 10 mg C/10 | WeCare / [ML](https://www.mercadolibre.com.mx/raamcinet-tableta-10-mg-10-tabletas/p/MLM39474398) |
| 5 | `EQ-ALP0634` | Losartán Alpharma 50 mg C/30 | igual | foto de la caja de mostrador |
| 1 | `FC-AA7B0686` | Drosquim 300/160 | Drosequim Adulto 200 ml | Sanorim / Quimpharma (no infantil 150/80) |
| 1 | `FC-6C2878CF` | Susp 125 Mg/Ml | Budenova 0.125 mg/ml 5 amp × 2 ml | Curitek / Novag |
| 1 | `FC-1321B34F` | Hidroxon | Hidroxin 10 mg C/30 | [Mavi](https://www.mavifarmaceutica.com/hidroxin) |
| 1 | `FC-44B6751A` | Aquito 500/100/30/4 | LAÜR Adulto C/3 | MiFarma (no es el infantil) |

No se copió EAN: ya está en `FC-27872123` / `EQ-MAI099` / `EQ-QUM070` / `EQ-SON264` (`codigo_barras` UNIQUE).

## Quinta pasada: el resto, Google + fabricante

El inventario sí traía presentación en varios (Aspirina **80** tabs, Compl = **1 FA**, AAS Ef = **20** tabs). Con eso se buscó otra vez.

`sql/patch_fotos_resto_busqueda_20260914.sql` — **5 packshots**. Piden **deploy**.

| Stock | SKU | Ticket | Ahora | Fuente |
|---:|---|---|---|---|
| 16 | `FC-08491074` | Aspirina | Aspirina 500 mg C/80 | BuscaMed / Chedraui (no es C/20 ni C/40) |
| 5 | `FC-64EB83AA` | Compl | Bencil/Benz Comp AMSA 1.2 M UI 1 FA | Galarza; EQ-AMS398 ya tiene el EAN |
| 5 | `FC-95779436` | Acetilsalicílico Ef | AAS efervescente Psicofarma 300 mg C/20 | [Farmasmart](https://farmasmart.com/acido-acetilsalicilico-ef-20-tab-300-mg) · EAN `7501384504908` ya en EQ-ALP0300 |
| 100 | `FMX-506386` | SensiMedical 5 ml 22G | igual | Promexsa caja C/100 |
| 50 | `FMX-307658` | SensiMedical 20 ml 21G | igual | Promexsa caja C/50 |

No se usó: Dibar 250 (la foto pública es de **1 L**); Ursofalk (el ticket no dice lab); Jaloma Mertodol 60 ml (en web solo hay 40 ml); otras jeringas SensiMedical (3 ml / 21G / insulina ≠ esta caja).

## Corrección: Farmasmart + Vitau (AAS y Alendrónico)

`sql/patch_fotos_aas_psicofarma_alendronico_20260914.sql` — pisa el AAS si el lote anterior lo dejó como AMSA. El JPG de Alendrónico pide **deploy** (la URL de `EQ-AMS147` ya existía y daba 404).

| Stock | SKU | Ticket / catálogo | Ahora | Fuente |
|---:|---|---|---|---|
| 5 | `FC-95779436` | Acetilsalicílico Ef | AAS efervescente **Psicofarma** 300 mg C/20 | [Farmasmart](https://farmasmart.com/acido-acetilsalicilico-ef-20-tab-300-mg) · EAN `7501384504908` ya en `EQ-ALP0300` |
| 3 | `EQ-AMS147` | Ácido alendrónico 10 mg C/30 AMSA | misma ficha; foto de la caja | [Vitau](https://vitau.mx/acido-alendronico-10mg-caja-con-30-tabletas-15236) + caja de mostrador · EAN `7501349014190` |

No se copió el EAN del AAS (UNIQUE). Farmasmart tiene **otro** SKU AMSA efervescente (`7501349020719`); el ticket dice *Acetilsalicílico Ef* = línea Psicofarma / ALP0300.

## Sexta pasada: Google + ficha oficial (URLs del mostrador)

`sql/patch_fotos_google_chedraui_20260914.sql` — **13 packshots**. Piden **deploy**. Adidas / Allegra D / Jaloma 250 pisan URLs `cm-…` que daban 404.

| SKU | Ahora | Fuente |
|---|---|---|
| `FC-42478359` | Garnier Agua Micelar Carbón 400 ml | [garnier.com.mx](https://www.garnier.com.mx/skin-active/agua-micelar-carbon) · EAN `3600542478359` |
| `FC-84900204` | Jaloma Agua de Rosas **250 ml** | [jaloma.com.mx](https://jaloma.com.mx/product/agua-de-rosas-250-ml/) |
| `FC-84900259` | Jaloma Agua de Arroz 250 ml | jaloma.com.mx / DAX EAN `759684900259` |
| `FC-03842420` | Adidas Power Booster spray 150 ml | [Chedraui](https://www.chedraui.com.mx/antitranspirante-adidas-power-booster-spray-hombre-150ml-3783701/p) |
| `FC-65006386` | Allegra D 60/25 mg C/10 | [allegra.com.mx](https://www.allegra.com.mx/productos/alivio-para-alergias-y-congestion/allegra-D) |
| `FC-46505283` | Xiomara Cera Mate 60 g | Chedraui EAN `7501846505283` |
| `FC-50343102` | Vitacilina Facial Melatonina | Chedraui EAN `7502250343102` |
| `FC-75075996` | Rexona Happy Morning roll-on 50 ml | Chedraui EAN `75075996` |
| `FC-06215528` | Savilé bicarbonato+limón spray 150 ml | [savilemexico.com.mx](https://www.savilemexico.com.mx/p/antitranspirante-en-aerosol-savile-bicarbonato-y-limon.html/07506306215528) |
| `FC-75068639` | Savilé bicarbonato+limón stick 45 g | Chedraui EAN `75068639` |
| `FC-25629442` | Escudo antiséptico spray 200 ml | Chedraui EAN `7506425629442` |
| `FC-66022610` | Honey Keeper Kids Chamomile 414 ml | Chedraui EAN `814266022610` (el ticket decía Honey) |
| `FC-66022627` | Honey Keeper Kids Lavender 414 ml | Chedraui EAN `814266022627` |

No se usó: Jaloma rosas **130 ml** (el packshot público es de 250 ml); Gerber 113 g ≠ 100 g; Sico `7501685171113` ≠ `7501685171118`.

## Séptima pasada: Google + Nadro/Farmatodo/Chedraui/Fahorro por EAN

Se buscó cada pendiente vivo (146 sin `imagen_url`) por EAN en Nadro i22, Farmatodo, Chedraui y Fahorro, más fichas de marca. `sql/patch_fotos_google_ean_20260914.sql` — **41 packshots**. Piden **deploy**.

Medicamentos: Aderogyl C/4, Pharmaton C/30, Dolo-Neurobión C/20 y DC C/3, Dolac C/10, Brunadol C/10, Alli-Triple C/10, Pepto-Bismol 118 ml, Alka-Seltzer C/100 y Boost C/10, Bronco Rub 40 g.

Cuidado: Rexona Marine/Sport/V8 + sticks Bamboo/Powder Dry/Happy Morning; Axe Excite/Dark/Gold; Listerine ×3; Oral-B 250 ml; Sensodyne ×2; Nivea Facial 5 en 1 (el ticket decía 7 en 1; el EAN es 5 en 1); Nivea Milk combo 400+100; Kleenex, Huggies 80, Diapro C/10, Curitas Transpiel 100; Xiomara Classic / Telaraña 60 g / Elastik 100 g; Palmolive brillantina; Honey Keeper oat 414 ml; GUM 129 m; Savilé roll-on; Colgate Premier Clean; Suerox Vitamins Naranja Mango 630 ml.

No se usó: Pasta Lassar (solo costado legal); Enterogermina 4 billones ≠ 2 billones C/10; placeholders `generica_1`; Pantene `…3454` ≠ `…3464`.

## Lo que queda — `sql/generated/fotos_pendientes_tras_lote_20260914.csv`

~105 SKUs (146 vivos menos este lote; varios ya tenían SQL anterior sin correr).

### Medicamentos todavía sin caja pública de *esa* pieza

| Stock | SKU | Qué hay | Por qué no |
|---:|---|---|---|
| 5 | `FC-A0D320D1` | Amoxicilina 12 cápsulas | sin laboratorio |
| 3 | `FC-63975795` | Gentamicina 25 comprimidos | sin laboratorio (oral es raro) |
| 1 | `FC-3E863E37` | Tratidri 1 gel | no hay ficha; Triderm es crema |
| 1 | `FC-405A75E3` | Ursodesoxicólico 50 cáps | Ursofalk / Durcox / Marca del Ahorro |
| 1 | `FC-DB4A39AE` | Eferox (Cefalexina) 12 comp | Eferox DE = levotiroxina |
| 1 | `FC-6B2ADEE9` | Protect 200 dosis 12.80 g | ≠ Protaisol / Spiriva |
| 2 | `FC-C8B741F6` | FC producto botiquín | no se sabe qué es |

No se inventa foto a ciegas.

### Insumos / herbolario / EAN interno todavía sin packshot usable

Otras jeringas SensiMedical (3 ml 21G, 5 ml 21G, insulina 1 ml, 60 ml — no se reutiliza otra caja), cintas Cintapore, cubrebocas, perillas, Mercurio/Velázquez, EANs `200…`, alcohol Dibar 96° 250 ml (la foto pública es de 1 L), Jaloma Mertodol 60 ml / agua de rosas **130 ml**.
