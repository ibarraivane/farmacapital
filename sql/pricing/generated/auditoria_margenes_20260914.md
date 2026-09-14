# Auditoría de márgenes — 14 sep 2026

Catálogo vivo: **1504 productos activos**.

Calibración: Sedal Rizos Definidos 135 ml se compró a **$9.08** y se vendía a **$61** (recargo 572%). Ya está en **$20** (~2.2×). Esa es la regla de techo para higiene / cuidado personal.

No se toca el PVP solo. El SQL es sugerencia; hay que confirmarlo en Inventario o en el SQL Editor.

## Resumen

| Acción | SKUs |
|---|---:|
| Bajar PVP (margen abismal) | 49 |
| · de esos, higiene / cuidado personal | 32 |
| Se vende bajo costo | 13 |
| Revisar costo (ticket / caja vs pieza) | 27 |

## 1. Higiene y cuidado — el patrón de la crema de rizos

El **sugerido** es el techo 2.2× (como Sedal $9.08 → $20). En jabón/crema de $4–$7 eso da $10–$16: no es el precio de Oxxo, es para que no se venda a $42–$56. Si en la calle está a $18–$25, pon ese; no el de $40+.

| SKU | Producto | Costo | PVP | Sugerido | Recargo | Stock |
|---|---|---:|---:|---:|---:|---:|
| `FC-43489004` | Escudo Rosa Cuidado · 110 G | $4.48 | $42 | $10 | 838% | 2 |
| `FC-54558682` | Nivea Milk Crema corp 400 ML · 400 ML | $22.30 | $207 | $50 | 828% | 1 |
| `FC-22105207` | Jabon Grisi Neutro · 150 G | $6.96 | $56 | $16 | 705% | 1 |
| `FC-25605514` | Escudo Antibacterial Frescura · 110 G | $7.23 | $42 | $16 | 481% | 2 |
| `FC-27512574` | Evenflo Colors · 240 ML | $15.48 | $63 | $35 | 307% | 3 |
| `FC-20500164` | Pert crema para peinar kera + aguacate 100 ml · 100 ml | $14.80 | $55 | $33 | 272% | 2 |
| `FC-43427754` | Toallas Kotex Nocturna Ext Largo cn alas · C/5 | $5.01 | $16 | $12 | 219% | 0 |
| `FC-38891190` | Jabon Dove Original · 135 G | $15.10 | $47 | $34 | 211% | 1 |
| `FC-25652716` | Escudo Antibacterial Original · 135 G | $13.65 | $42 | $31 | 208% | 5 |
| `FC-21012303` | Claris toallas desmaquillantes aloe C/40 · C/40 | $9.43 | $27 | $21 | 186% | 2 |
| `FC-19006371` | Toallas Saba Invisible con alas C/10 · C/10 | $10.17 | $29 | $16 | 185% | 1 |
| `FC-75064938` | Desodorante Ego Force 24H roll-on · 45 ML | $11.95 | $34 | $27 | 184% | 1 |
| `FC-20500171` | Crema para peinar Pert aceite oliva aguacate · 100 ML | $7.40 | $21 | $17 | 184% | 3 |
| `FC-46683133` | Palmolive Neutro-Bal Dermo Limp · 120 G | $13.07 | $37 | $29 | 183% | 1 |
| `FC-99425580` | Gel X-Treme Titan · 250 G | $11.31 | $32 | $25 | 183% | 1 |
| `FC-99428024` | Gel Moco de Gorila Punk · 80 G | $14.15 | $40 | $32 | 183% | 2 |
| `FC-08837311` | Nivea Antitransp Pearlb Spray · 150 ML | $32.37 | $91 | $56 | 181% | 2 |
| `FC-06241206` | Dove tono uniforme 72h · SPRAY 150 ML | $32.14 | $90 | $71 | 180% | 1 |
| `FC-46059556` | Palmolive líquido neutro · 221 ML | $35.61 | $98 | $79 | 175% | 0 |
| `FC-52844825` | Desodorante Obao Ritual Natural Coco (Mujer) · Roll-ON 65 G | $24.95 | $68 | $41 | 172% | 2 |
| `FC-54549796` | Crema Nivea Milk Nutritiva · 100 mL | $25.86 | $69 | $57 | 167% | 4 |
| `FC-27250612` | Desodorante Obao Piel Delicada · R-ON 65 G | $25.83 | $68 | $57 | 163% | 2 |
| `FC-54549819` | Crema Nivea Softmilk · 100 ML | $26.30 | $69 | $56 | 162% | 0 |
| `FC-22150801` | Jabon Grisi Avena · 125 G | $21.72 | $56 | $31 | 158% | 1 |
| `FC-22150092` | Grisi Leche De Burra · 125 G | $21.88 | $56 | $49 | 156% | 1 |
| `FC-08802838` | Crema Nivea Softmilk · 400 mL | $84.49 | $207 | $186 | 145% | 1 |
| `FC-86472048` | PRO Cepillo Dent Mayor Alcance Pro · 1 PZ | $13.50 | $33 | $25 | 144% | 1 |
| `FC-86494262` | Cepillo Oral-B Indicat · 1 pz | $15.51 | $37 | $35 | 139% | 1 |
| `FC-17360604` | Toallas Kotex Regular Flujo Amb · 10 pzs | $10.61 | $25 | $24 | 136% | 2 |
| `FC-14983726` | Prudence Natural Lubricante Natural · 75 ML | $62.06 | $139 | $87 | 124% | 1 |
| `FC-14983153` | Lubricante Intimo Prudence Grosella · 75 ML | $62.06 | $139 | $115 | 124% | 1 |
| `FC-14980350` | Prudence Lub lubricante íntimo mora azul 75 ml · 75 ML | $62.06 | $139 | $87 | 124% | 1 |

## 2. Otros PVP inflados (medicamento / sin clasificar)

Solo entran si el recargo pasa el techo de su familia (genérico 2.6×; el recargo viejo de 60% sobre venta ≈ 2.5× se deja pasar).

| SKU | Producto | Costo | PVP | Sugerido | Recargo | Stock |
|---|---|---:|---:|---:|---:|---:|
| `EQ-AMS406` | AMSA Cinitaprida 25 Comp 1 Mg · Caja con comprimidos | $17.58 | $119 | $46 | 577% | 3 |
| `EQ-MAV187` | Maver Erispan Compuesto 1 Sol 5/100mg/60 Ml · Frasco 60 mL | $22.53 | $112 | $59 | 397% | 1 |
| `EQ-ULT103` | Ultra Diclofenaco 20 Tab 100 Mg · Caja con 20 tabletas | $7.60 | $35 | $20 | 360% | 3 |
| `FC-58715517` | Graneodin B Frambuesa · C/24 pastillas | $42.64 | $193 | $111 | 353% | 2 |
| `FC-40007651` | BIO ELCTRO | $16.60 | $75 | $44 | 352% | 4 |
| `EQ-ULT146` | Ultra Pioglitazona · C/7 | $13.35 | $60 | $35 | 349% | 5 |
| `FC-EADF1484` | beadvance Diosmina Hesperidina · 20 TABLETAS | $39.41 | $176 | $103 | 347% | 3 |
| `FC-F4E9C71F` | AMSA Amoxicilina · 1 SUSPENSION | $23.57 | $98 | $62 | 316% | 1 |
| `FC-CF18C740` | AMSA Clindamicina · 16 CAPSULAS | $30.54 | $120 | $80 | 293% | 3 |
| `EQ-PGE052` | PROGELA Ercatriv M Calcitriol 30 Caps 0.25 Mcg · Caja con 30 cápsulas | $47.13 | $167 | $95 | 254% | 1 |
| `FC-62746605` | Jarabe Ajolotiux Orig Con Miel · 250 mL | $28 | $98 | $43 | 250% | 1 |
| `FC-49029040` | Ketorolaco / Tramadol solución inyectable 10 mg - 25 mg / 1 mL AMSA ·  | $100 | $350 | $260 | 250% | 2 |
| `FMX-307626` | NEOLPHARMA Bromuro-Pinaverio-Alpharma Tabletas 100 Mg C/14 · C/14 | $16.88 | $59 | $44 | 250% | 1 |
| `FC-9233072` | Nido Kinder 1+ bolsa 144 g · 144 G | $30.28 | $92 | $61 | 204% | 1 |
| `FC-51078531` | Nestle Leche en Polvo NAN Optimal Pro 2 / 6 a 12 M · 120 g | $58.70 | $170 | $106 | 190% | 1 |
| `FC-0211225` | Dibenel cápsulas vitaminas omega 3 C/30 · C/30 | $47.08 | $127 | $95 | 170% | 1 |
| `FC-51078461` | Nestle Leche en polvo NAN Optimal Pro 1/ 0 a 6 M · 120 g | $63.41 | $170 | $115 | 168% | 2 |

## 3. Se venden más barato de lo que costaron

Casi siempre el **costo está mal** (caja capturada como pieza, o al revés). Revisa el ticket antes de subir el PVP.

| SKU | Producto | Costo | PVP | Sugerido | Recargo | Stock |
|---|---|---:|---:|---:|---:|---:|
| `FC-08011145` | Just For Men tinte barba y bigote negro · Kit gel | $171.14 | $165 | $240 | -4% | 2 |
| `FC-73629981` | Pañuelos Kleenex · 15 pzs | $32.83 | $10 | $46 | -70% | 17 |
| `FC-06246652` | Jabón Dove blanco 90 g | $111.80 | $25 | $157 | -78% | 6 |
| `FC-05809248` | Enfagrow Premium etapa 3 lata 800 g | $568.96 | $408 | $740 | -28% | 1 |
| `FC-75005092` | Heinz pouch papilla manzana 113 g | $32.04 | $20 | $42 | -38% | 3 |
| `FC-58651129` | Gerber Junior pouch frutas mixtas 95 g | $38.38 | $18 | $50 | -53% | 3 |
| `FC-75102476` | Gerber Etapa 2 durazno 100 g | $32.04 | $15 | $42 | -53% | 3 |
| `FC-75102421` | Gerber Etapa 2 manzana 100 g | $32.04 | $15 | $42 | -53% | 3 |
| `FC-75102452` | Gerber Etapa 2 pera 100 g | $32.04 | $15 | $42 | -53% | 3 |
| `FC-75102469` | Gerber Etapa 2 mango 100 g | $32.04 | $15 | $42 | -53% | 3 |
| `FC-75102537` | Gerber Etapa 2 comida casera pollo 100 g | $42.72 | $15 | $56 | -65% | 4 |
| `FC-75102520` | Gerber Etapa 2 comida casera res 100 g | $42.72 | $15 | $56 | -65% | 4 |
| `EQ-MAV198` | Maver Oxatech 14 Tab 10 Mg · Caja con 14 tabletas | $26.46 | $8.27 | $43 | -69% | 3 |

## 4. Revisar costo, no bajar a ciegas

Costo < $2 o la última compra es mucho más cara que el costo del catálogo.

| SKU | Producto | Costo | PVP | Sugerido | Recargo | Stock |
|---|---|---:|---:|---:|---:|---:|
| `FC-IFC-PEI02` | Peine mango chico colores C/12 pzs · Paquete con 12 | $1.75 | $5 | — | 186% | 11 |
| `FC-IFC-DON01` | Dona / bolsa IJJ-10 C/12 · Paquete con 12 | $6.16 | $15 | — | 144% | 1 |
| `FC-EXP-OPT48` | Palmolive Optims Vital Keratina 2 en 1 sobre 10 ml · Sobre 10 ml | $1.57 | $3 | — | 91% | 48 |
| `EQ-PYG016` | Metamucil Metanucil 1 Polvo Sabor Natural 504 G · Bote 504 g sabor nat | $0.01 | $150 | — | 1499900% | 0 |
| `FC-0ACC5B6A` | Mercurio Oxido De Zinc · C/50 | $1.08 | $14 | — | 1196% | 1 |
| `FC-00100013` | Cubrebocas tricapa desechable C/100 · Caja C/100 | $0.80 | $6 | — | 650% | 98 |
| `FC-C4530823` | Mercurio óxido de zinc C/50 · frasco 50 g | $9 | $54 | — | 500% | 3 |
| `FC-22300775` | Jeringa Sensi Medical 3 mL 22G x 32 mm negra · 1 pieza 3 mL 22G x 32 m | $1.40 | $8 | — | 471% | 99 |
| `FC-22300881` | Jeringa insulina SensiMedical 1 mL 27G x 13 mm · 1 pieza 1 mL 27G x 13 | $1.37 | $7 | — | 411% | 99 |
| `FMX-506388` | Jeringa SensiMedical 3 mL 21G x 32 mm verde · Pieza 3 mL 21G x 32 mm ( | $1.40 | $7 | — | 400% | 100 |
| `FMX-506386` | Jeringa SensiMedical 5 mL 22G x 32 mm negra · Pieza 5 mL 22G x 32 mm ( | $1.48 | $7 | — | 373% | 100 |
| `FMX-506389` | Jeringa SensiMedical 5 mL 21G x 32 mm verde · Pieza 5 mL 21G x 32 mm ( | $1.48 | $7 | — | 373% | 92 |
| `FC-07521317` | Genérico Gotero cristal | $1.20 | $5 | — | 317% | 98 |
| `FC-23272151` | Jeringa insulina 0.3 ml Sensi Medical · 1 pz | $2.13 | $8 | — | 276% | 97 |
| `FC-23273451` | Jeringa insulina 0.5 ml Sensi Medical · 1 pz | $2.13 | $8 | — | 276% | 100 |
| `FC-68900134` | Dibar Gasa Lox10 C/100 · C/100 | $1.09 | $3 | — | 175% | 93 |
| `FC-0287855` | Vita Kid-C jarabe vitamina C naranja 240 ml · 240 ML | $29.14 | $65 | — | 123% | 1 |
| `FMX-300644` | PROTEC Guante/Esteril-Protec Clasico C/100 Mediano · 100 PZ | $1.61 | $3 | — | 86% | 89 |
| `FMX-504321` | SENSIMEDICAL Aguja-Hipodermica-Sensimedical 22 G X 32 Mm C/1 Negro · C | $0.55 | $1 | — | 82% | 100 |
| `FC-5145497` | NyQuil Z difenhidramina 25 mg C/30 · C/30 | $0 | $100 | — | — | 0 |
| `FC-98062243` | Pharmaton Complete tabletas C/100 · Caja con 100 tabletas de 773 mg | $0 | $100 | — | — | 2 |
| `FC-58752796` | Lysol desinfectante antibacterial Crisp Linen 475 g | $0 | $175 | — | — | 1 |
| `FMX-71074` | Termo Fifa | $0 | $100 | — | — | 1 |
| `FC-45116656` | Baby Einstein Neptune's Busy Bubbles juguete sensorial Ocean Explorers | $0 | $250 | — | — | 1 |
| `FC-06241152` | Dove antitranspirante aerosol Tono Uniforme Caléndula 150 ml · Aerosol | $0 | $90 | — | — | 2 |
| `FC-58796882` | Lysol desinfectante antibacterial Crisp Linen 354 g · Aerosol 354 g | $0 | $140 | — | — | 1 |
| `FC-09272342` | Takeda Exkruthera Fruquintinib 1 mg caja con frasco 21 cápsulas · Caja | $0.01 | $0.01 | — | 0% | 4 |

## Cómo aplicar

1. Inventario → chip **Margen raro** (queda en este PR).
2. O corre `sql/patch_sugerencias_margenes_20260914.sql` en Supabase — solo filas `bajar` con costo validado.
3. No pisa un PVP que ya esté en el sugerido o más bajo.
