# Fotos faltantes / feas 19-sep-2026

Ligas del dueño (Flor de Aire, Chedraui, Guadalajara, PLM, Sufarmed, iFarma, Promexsa, Mercado Libre) y las tarjetas de vitrina que salían cortadas, oscuras, de espaldas o con marca de agua.

## Qué hacer

1. Esperar el deploy de este PR (`public/catalogo-propia/…` en farmacapital.mx).
2. Pegar **todo** `sql/patch_fotos_faltantes_urls_20260919.sql` en Supabase → Run.
3. Recargar la tienda.

## Lote

| Alcohol etílico Dibar azul 71.5° 500 ml | `7501868901124 ` | `FC-68901124 ` | `alcohol-etilico-dibar-azul-71-5-500-ml-7501868901124.jpg` | propia-recortada |
| Levofloxacino AMSA 500 mg C/7 tabletas | `7501349021419 ` | `FC-C721E8D7 ` | `levofloxacino-amsa-500-mg-c-7-tabletas-7501349021419.jpg` | nadro |
| Buscapina Fem hioscina/ibuprofeno 20/400 mg C/10 | `7501165011656 ` | `FC-65011656 ` | `buscapina-fem-hioscina-ibuprofeno-20-400-mg-c-10-7501165011656.jpg` | farmatodo |
| Cetilver pirfenidona gel 8% tubo 10 g | `7502009748448 ` | `EQ-MAV392 ` | `cetilver-pirfenidona-gel-8-tubo-10-g-7502009748448.jpg` | mercadolibre |
| Secret gel invisible lavanda 45 g | `7500435129367 ` | `FC-35129367 ` | `secret-gel-invisible-lavanda-45-g-7500435129367.jpg` | chedraui |
| Desrotan fexofenadina 180 mg C/10 | `7502227875568 ` | `FC-B3B8F9BB ` | `desrotan-fexofenadina-180-mg-c-10-7502227875568.jpg` | nadro |
| Aceite de almendras dulces Flor de Aire 125 ml | `— ` | `— ` | `aceite-de-almendras-dulces-flor-de-aire-125-ml.jpg` | flordeaire |
| Aceite para bebé Nuvel 250 ml | `7501082780246 ` | `— ` | `aceite-para-bebe-nuvel-250-ml-7501082780246.jpg` | chedraui |
| Advil ibuprofeno 200 mg C/10 cápsulas | `7501108763475 ` | `— ` | `advil-ibuprofeno-200-mg-c-10-capsulas-7501108763475.jpg` | farmatodo |
| Ampigrin PFC cápsulas C/24 | `— ` | `— ` | `ampigrin-pfc-capsulas-c-24.jpg` | plm |
| Betahistina AMSA 24 mg C/30 tabletas | `7501349029965 ` | `— ` | `betahistina-amsa-24-mg-c-30-tabletas-7501349029965.jpg` | chedraui |
| Broxtorfan adulto ambroxol/dextrometorfano jarabe 120 ml | `7501573907992 ` | `— ` | `broxtorfan-adulto-ambroxol-dextrometorfano-jarabe-12-7501573907992.jpg` | sufarmed |
| Calaffler diclofenaco gotas 15 mg/ml Loeffler | `7502211784180 ` | `FC-11784180 ` | `calaffler-diclofenaco-gotas-15-mg-ml-loeffler-7502211784180.jpg` | ifarma |
| Cánula nasal pediátrica 2 mm x 1.80 m Sensi Medical | `— ` | `— ` | `canula-nasal-pediatrica-2-mm-x-1-80-m-sensi-medical.jpg` | promexsa |
| Carnitina fibra y complejo B Naturex 30 cápsulas 560 mg | `— ` | `— ` | `carnitina-fibra-y-complejo-b-naturex-30-capsulas-560.jpg` | mercadolibre |
| Teatrical crema suavizante con lanolina tarro 400 g | `— ` | `— ` | `teatrical-crema-suavizante-con-lanolina-tarro-400-g.jpg` | mercadolibre |
| Teatrical crema suavizante con lanolina y rosas tarro 400 g | `— ` | `— ` | `teatrical-crema-suavizante-con-lanolina-y-rosas-tarr.jpg` | mercadolibre |

## Notas

- **Alcohol Dibar azul 500 ml:** se recortaron las franjas negras laterales y se dejó más aire blanco para que la botella no se vea cortada en la tarjeta.
- **Levofloxacino AMSA 500 mg C/7:** packshot Nadro de la caja blanca (la foto de celular estaba oscura). No se usa la caja verde de Farmatodo.
- **Buscapina Fem:** frente Farmatodo. Ya no sale el dorso con código de barras.
- **Cetilver:** caja + tubo de Mercado Libre, sin la marca de agua Gendiar.
- **Secret lavanda 45 g:** packshot Chedraui (misma liga/EAN 7500435129367). Sustituye la foto de celular.
- **Desrotan 180 mg C/10:** frente Nadro. No se usa la segunda foto de Nadro (es Frewer).
- **Broxtorfan de la liga Sufarmed es ADULTO 120 ml**, no el Broxtorfan infantil `EQ-BIO188`. El SQL solo pega si el nombre dice adulto o el EAN de la caja `7501573907992`.
- **Ampigrin PFC de PLM es cápsulas C/24**, no el jarabe infantil `EQ-COL213`.
- **Carnitina Naturex:** se recortó el frasco del montaje de Mercado Libre (quitamos logos Farmadealta / pesas) y se puso fondo blanco.
- **Advil 10 cápsulas:** Farmatodo (la de Guadalajara traía marca de agua de la cadena).
- Varias fichas (Nuvel, Betahistina, Teatrical 400 g, cánula, almendras) no tenían EAN/SKU fijo en el repo: el SQL las busca por código o por nombre.

No pisa foto si el producto no matchea EAN/SKU/nombre. No toca stock ni precio.
