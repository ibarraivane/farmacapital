# Auditoría fotos faltantes (10-sep-2026)

Snapshot live Supabase · productos activos sin `imagen_url` ni galería.

## Resumen

- Sin foto real al inicio: **279** (268 con stock)
- Conseguidas en este pase: **90**
- Siguen pendientes: **189** (ver `sql/generated/fotos_pendientes_tras_lote_20260910.csv`)

De las conseguidas, **14** ya estaban en `public/catalogo-propia/` desde el 6-sep; el SQL no se había pegado en Supabase.

## Fuentes de este pase

| Fuente | Fotos |
|---|---:|
| farmatodo | 62 |
| catalogo-propia | 14 |
| openfoodfacts | 8 |
| levic | 5 |
| openproductsfacts | 1 |

## Conseguidas ahora

| Stock | SKU | Producto | Archivo / origen |
|---:|---|---|---|
| 46 | FC-68900264 | Alcohol Etilico Rojo 96° | `dibar-alcohol-96-125ml.jpg` · catalogo-propia |
| 43 | FC-LV-ORBITHB40 | Orbit 4's Hierbabuena | `orbit-hierbabuena-4s.jpg` · openproductsfacts |
| 40 | FC-LV-CLORETS40 | Clorets Plus 4's | `clorets-plus-4s.jpg` · openfoodfacts |
| 40 | FC-LV-ORBITFRE40 | Orbit 4's Fresa | `orbit-fresa-4s.jpg` · openfoodfacts |
| 12 | 7622210267832 | Halls Yerbabuena pack | `halls-yerbabuena-pack.jpg` · openfoodfacts |
| 10 | FC-01246730 | Vicks Vaporub pomada 12 g | `vicks-vaporub-12g.jpg` · catalogo-propia |
| 6 | FC-40013805 | Alliviax desinflamatorio 550 mg 10 tabletas | `alliviax-550mg-10tab.jpg` · catalogo-propia |
| 6 | FC-54354677 | Desodorante Nivea Men | `nivea-men-black-white-rollon.jpg` · catalogo-propia |
| 5 | EQ-AMS318 | Losartan AMSA 30 comprimidos 50 mg | `losartan-amsa-50mg-30comp.jpg` · farmatodo |
| 5 | FC-7D1D9857 | Acetilsalicilico | `acido-acetilsalicilico-avivia-100mg-30tab.jpg` · catalogo-propia |
| 4 | FC-40007651 | BIO ELCTRO | `bio-electro-24tab.jpg` · farmatodo |
| 3 | EQ-BIO002 | Biomesina 10 tab 10 mg | `biomesina-10mg-10tab.jpg` · farmatodo |
| 3 | FC-070839 | Alliviax Garganta C/ 6tabletas | `alliviax-550mg-6tab.jpg` · farmatodo |
| 3 | FC-12225133 | Vitacilina ungüento 28 g | `vitacilina-unguento-28g.jpg` · farmatodo |
| 3 | FC-40053634 | Alli Triple 50/.25/50/50 mg 6 tabletas | `alli-triple-6tab.jpg` · farmatodo |
| 3 | FC-46029825 | DESOD NEUTRO B R-ON 65 ML | `neutro-balance-clear-rollon-65ml.jpg` · farmatodo |
| 3 | FC-58651129 | Gerber Junior pouch frutas mixtas 95 g | `gerber-junior-frutas-mixtas-95g.jpg` · openfoodfacts |
| 3 | FC-75005092 | Heinz pouch papilla manzana 113 g | `heinz-pouch-manzana-113g.jpg` · catalogo-propia |
| 3 | FC-75073107 | Rexona Woman Clinical Classic stick 46 g | `rexona-clinical-classic-stick-46g.jpg` · catalogo-propia |
| 3 | FC-75102421 | Gerber Etapa 2 manzana 100 g | `gerber-etapa2-manzana-100g.jpg` · openfoodfacts |
| 3 | FC-75102452 | Gerber Etapa 2 pera 100 g | `gerber-etapa2-pera-100g.jpg` · openfoodfacts |
| 2 | EQ-BEA367 | Losartan beadvance 60 tab 50 mg | `losartan-beadvance-50mg-60tab.webp` · levic |
| 2 | EQ-INN022 | Optimila-H Grin gotas 15 mL | `optimila-h-grin-15ml.jpg` · farmatodo |
| 2 | EQ-MAV102 | Lincover lincomicina 16 cáps 500 mg | `lincover-lincomicina-500mg-16caps.webp` · levic |
| 2 | EQ-MAV204 | Alderan Losartán 15 tab 100 mg | `alderan-losartan-100mg-15tab.jpg` · farmatodo |
| 2 | EQ-SON084 | Lisonin 1 amp 300 mg/1 ml | `lisonin-300mg-1ml.webp` · levic |
| 2 | FC-09740442 | Klarix Claritromicina 250 mg 10 tabletas | `klarix-claritromicina-250mg-10tab.jpg` · catalogo-propia |
| 2 | FC-12225140 | Vitacilina ungüento 16 g | `vitacilina-unguento-16g.jpg` · catalogo-propia |
| 2 | FC-16792760 | Omeprazol 20 mg 30 cápsulas LGEN | `omeprazol-20mg-30caps-ultra.jpg` · farmatodo |
| 2 | FC-16804708 | Irbesartán 150 mg frasco 28 tabletas LGEN | `irbesartan-150mg-28tab-avivia.jpg` · farmatodo |
| 2 | FC-24028827 | ENJ BUC COLGATE TOTAL12 CLEAN 60ML | `colgate-total12-enjuague-60ml.jpg` · farmatodo |
| 2 | FC-25195105 | Cefuroxima 750 mg FA + ampolleta 5 ml | `cefuroxima-750mg-amp-amsa.jpg` · farmatodo |
| 2 | FC-35911024 | C D COLGATE MFP 125ML | `colgate-mfp-familiar-125ml.jpg` · farmatodo |
| 2 | FC-41751594 | Bocasan Premium enjuague bucal polvo menta 24 sobres 1.75 g | `bocasan-premium-24-sobres.jpg` · catalogo-propia |
| 2 | FC-46029139 | DESOD SPEED S 24/7COOL-NIG STIK 85G | `speed-stick-cool-night-85g.jpg` · farmatodo |
| 2 | FC-46674018 | C D COLGATE LUMIN WHIT CARBON 66ML | `colgate-luminous-white-carbon-66ml.jpg` · farmatodo |
| 2 | FC-49022768 | Cefalotina 1 g solución inyectable FA 5 ml LGEN | `cefalotina-1g-im-amsa.jpg` · farmatodo |
| 2 | FC-65011649 | Buscapina 10 mg 24 grageas | `buscapina-10mg-24tab.jpg` · farmatodo |
| 2 | FC-65628121 | POMADA DE LA CAMPANA 19 g | `pomada-la-campana-19g.jpg` · farmatodo |
| 2 | FC-65628145 | POMADA DE LA CAMPANA | `pomada-la-campana-35g.jpg` · farmatodo |
| 2 | FC-68541491 | Electrolife Zero uva 625 ml | `electrolife-zero-uva-625ml.jpg` · farmatodo |
| 2 | FC-78924338 | DESOD REXONA WOM POW R-ON 53G | `rexona-woman-powder-rollon.jpg` · farmatodo |
| 2 | FC-B25B4654 | Cina (Ciprofloxacino) | `cina-levofloxacino-750mg-7tab.jpg` · catalogo-propia |
| 1 | EQ-AMS349 | Cefotaxima IM 500 mg/2 ml | `eq-ams349.webp` · levic |
| 1 | EQ-SON083 | Lisonin 1 amp 600 mg/2 ml | `eq-son083.webp` · levic |
| 1 | EQ-VAL129 | Eldoquin crema 4% 30 g | `eldoquin-crema-4-30-g.jpg` · farmatodo |
| 1 | FC-00450210 | Bactrim F 800/160 mg 15 tabletas | `bactrim-f-800-160-mg-15-tabletas.jpg` · farmatodo |
| 1 | FC-00450227 | Bactrim 200/40 mg suspensión 100 ml | `bactrim-200-40-mg-suspension-100-ml.jpg` · farmatodo |
| 1 | FC-00631702 | Eucerin pH5 pomada labial | `eucerin-ph5-pomada-labial.jpg` · farmatodo |
| 1 | FC-00948670 | Labello Caring Beauty Red 4.8 g | `labello-caring-beauty-red-4-8-g.jpg` · farmatodo |
| 1 | FC-05809248 | Enfagrow Premium etapa 3 lata 800 g | `enfagrow-premium-etapa3-800g.jpg` · catalogo-propia |
| 1 | FC-07532363 | DRAMAMINE | `dramamine-50mg-24tab.jpg` · farmatodo |
| 1 | FC-08498866 | Flanax 550 mg 6 tabletas | `flanax-550mg-6tab.jpg` · farmatodo |
| 1 | FC-08499092 | Flanax Nocto 220/25 mg 20 comprimidos | `flanax-nocto-20comp.jpg` · farmatodo |
| 1 | FC-08499412 | Flanax 660 mg 8 tabletas | `flanax-660mg-8tab.jpg` · farmatodo |
| 1 | FC-18001071 | GILLETTTE  MACH 3 | `gillette-mach3.jpg` · farmatodo |
| 1 | FC-18874729 | GILLETTE PRESTOBARBA 3 | `gillette-prestobarba3-hombre.jpg` · farmatodo |
| 1 | FC-18874781 | GILLETTE PRESTOBARBA 3 | `gillette-prestobarba3-mujer.jpg` · farmatodo |
| 1 | FC-19006104 | SABA INTIMA REGULAR 10 TOALLAS | `saba-intima-regular-10.jpg` · farmatodo |
| 1 | FC-19006296 | SABA ULTRA INVISLE 10 TOALLAS | `saba-ultra-invisible-10.jpg` · farmatodo |
| 1 | FC-19006418 | SABA INVISIBLE DELGADA 14 TOALLAS 0429 | `saba-invisible-delgada-14.jpg` · farmatodo |
| 1 | FC-19006692 | SABA BUENAS NOCHES 24 TOALLAS NOCTURNA | `saba-buenas-noches-24.jpg` · farmatodo |
| 1 | FC-19031144 | SABA REGULAR AMORE 8 TOALLAS | `saba-regular-amore-8.jpg` · farmatodo |
| 1 | FC-19032424 | Tampones Saba compactos super | `saba-tampones-compactos.jpg` · farmatodo |
| 1 | FC-19050473 | Toalla húmeda Tena adulto EG | `tena-toallas-humedas-40.jpg` · farmatodo |
| 1 | FC-21440013 | Buscapina Duo 10/500 mg 10 tabletas | `buscapina-duo-10tab.jpg` · farmatodo |
| 1 | FC-24183182 | HILO DENT COLGATE ENCERA 25M | `colgate-hilo-dental-25m.jpg` · farmatodo |
| 1 | FC-25108709 | KOLESTON NEGRO 20 | `koleston-negro-20.jpg` · farmatodo |
| 1 | FC-27286000 | DESOD OBAO OCEAN R-ON 65G | `obao-ocean-rollon-65g.jpg` · farmatodo |
| 1 | FC-35129367 | DESOD SECRET PH-BALAN STICK GEL 45G | `secret-ph-balanced-lavender-45g.jpg` · openfoodfacts |
| 1 | FC-42302463 | CEP DENT GUM GO-BET MICROFINO C/6 | `gum-gobet-microfino.jpg` · farmatodo |
| 1 | FC-42303460 | CEP DENT GUM TRAV-LER INTERDENTA 0.8 | `gum-trav-ler-0-8mm.jpg` · farmatodo |
| 1 | FC-46057545 | DESOD LADYSS PRO 5EN1 STICK 45G ABRIL27 | `lady-speed-stick-pro5-45g.jpg` · farmatodo |
| 1 | FC-46073774 | DESOD STEFANO SPAZ SPY 113G | `stefano-spazio-spray-113g.jpg` · farmatodo |
| 1 | FC-49013223 | Deflazacort 30 mg 10 tabletas LGEN | `deflazacort-30mg-10tab-amsa.jpg` · farmatodo |
| 1 | FC-49026377 | Gentamicina 160 mg solución inyectable 2 ml AMSA | `gentamicina-160mg-amp-amsa.jpg` · farmatodo |
| 1 | FC-49028234 | Omeprazol 40 mg solución inyectable ampolleta LGEN | `omeprazol-40mg-iny-amsa.jpg` · farmatodo |
| 1 | FC-49029613 | Combedi DX Complejo B / Dexametasona 6 amp AMSA | `combedi-dx-amsa.jpg` · farmatodo |
| 1 | FC-50342570 | VITACILINA SERUM VITAMINA C | `vitacilina-serum-vitc-30ml.jpg` · farmatodo |
| 1 | FC-52906158 | DESOD OBAO FRESQUISSIMA R-ON 65G | `obao-fresquissima-rollon-65g.jpg` · openfoodfacts |
| 1 | FC-54503637 | Labello Med Protection 4.8 g | `labello-med-protection-4-8g.jpg` · farmatodo |
| 1 | FC-56729917 | Oxímetro Inhala Care pulso dedo FS10E | `oximetro-inhala-care-fs10e.jpg` · farmatodo |
| 1 | FC-58715913 | Picot Plus 9 sobres efervescentes | `picot-plus-9-sobres.jpg` · farmatodo |
| 1 | FC-70600709 | Syncol 500/25/15 mg 12 comprimidos | `syncol-12-comp.jpg` · catalogo-propia |
| 1 | FC-75784054 | CeraVe gel limpiador contra imperfecciones 236 ml | `cerave-gel-imperfecciones-236ml.jpg` · catalogo-propia |
| 1 | FC-82790481 | TAS DESMAQ NUVEL HIDRATANTES C25 | `nuvel-toallitas-hidratantes-25.jpg` · farmatodo |
| 1 | FC-93888302 | Doxiciclina 100 mg 10 cápsulas Ken LGEN | `kenciclen-doxiciclina-100mg-10caps.jpg` · farmatodo |
| 0 | FC-16792555 | Omeprazol 20 mg 14 cápsulas LGEN | `omeprazol-20mg-14caps-ultra.jpg` · farmatodo |
| 0 | FC-16798878 | Pioglitazona 30 mg 7 tabletas LGEN | `pioglitazona-30mg-7tab-ultra.jpg` · farmatodo |
| 0 | FC-19068911 | Panty protector Saba largo 28 | `saba-pantiprotector-largo-28.jpg` · farmatodo |

## Qué pegar en Supabase

1. Las URLs de Farmatodo (`gruporfp.vteximg.com.br`) y Levic (`visoti.mx`) funcionan ya: se puede pegar el SQL en cuanto se apruebe.
2. Las JPG/WebP nuevas de `public/catalogo-propia/` (gomas, Gerber, Losartán AMSA, Vitacilina 28 g, Alderan, etc.) piden el deploy de Vercel. El lote del 6-sep **ya está** en el CDN.
3. Archivo: `sql/patch_fotos_conseguibles_20260910.sql`.

## Revisar en mostrador

- `FC-070839` Alliviax: el EAN `650240070839` en Farmatodo es **550 mg C/6**, no pastilla de garganta. La presentación local también dice 550 mg.
- `FC-19050473` Tena: Farmatodo lo publica como toalla húmeda femenina C/40. Confirmar que es la pieza del anaquel.
- `FC-B25B4654` Cina: la foto es Levofloxacino 750 mg c/7; el nombre en sistema sigue diciendo Ciprofloxacino (el patch del 6-sep no se pegó).

## Por qué no salen las demás

Nadro i22 respondió 429 en este entorno (por eso el cruce fue Farmatodo + Levic + Open Facts).
Jeringas SensiMedical, goteros, cintas, Mercurio y EANs internos 200… siguen sin packshot público usable.
Aspirina 80 tabs, Dove blanco 90 g, Rexona Men Clinical, alcohol Dibar 250 ml y Velázquez alcanfor no aparecieron en Farmatodo ni Open Facts.

## Descartadas a propósito

- Skittles (`FC-LV-SKITTLES24`): Open Facts solo tiene el dorso del empaque.
- Insumos genéricos y herbolario Mercurio: no se inventa foto.

