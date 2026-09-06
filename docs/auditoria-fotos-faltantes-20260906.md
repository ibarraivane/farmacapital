# Auditoría fotos faltantes (stock > 0)

Snapshot live Supabase · 2026-09-06

## Resumen

- Sin foto real (ni `imagen_url` ni galería): **185**
- Conseguidas en este pase (+ Amifarin/Cina/AAS del pase anterior): **15**
- Siguen pendientes: **170** (ver CSV)

## Conseguidas ahora

| SKU | Producto | Archivo |
|---|---|---|
| FC-40013805 | Alliviax desinflamatorio 550 mg 10 tabletas | `alliviax-550mg-10tab.jpg` |
| FC-070839 | Alliviax Garganta C/8 tabletas | `alliviax-garganta-8tab.jpg` |
| FC-70600709 | Syncol 500/25/15 mg 12 comprimidos | `syncol-12-comp.jpg` |
| FC-01246730 | Vicks Vaporub pomada 12 g | `vicks-vaporub-12g.jpg` |
| FC-12225140 | Vitacilina ungüento 16 g | `vitacilina-unguento-16g.jpg` |
| FC-75073107 | Rexona Woman Clinical Classic stick 46 g | `rexona-clinical-classic-stick-46g.jpg` |
| FC-09740442 | Klarix Claritromicina 250 mg 10 tabletas | `klarix-claritromicina-250mg-10tab.jpg` |
| FC-68900264 | Alcohol Etilico Rojo 96° | `dibar-alcohol-96-125ml.jpg` |
| FC-54354677 | Desodorante Nivea Men | `nivea-men-black-white-rollon.jpg` |
| FC-75005092 | Heinz pouch papilla manzana 113 g | `heinz-pouch-manzana-113g.jpg` |
| FC-75784054 | CeraVe gel limpiador contra imperfecciones 236 ml | `cerave-gel-imperfecciones-236ml.jpg` |
| FC-05809248 | Enfagrow Premium etapa 3 lata 800 g | `enfagrow-premium-etapa3-800g.jpg` |

## Por qué no salen las demás

| Motivo | Cantidad | Qué implica |
|---|---:|---|
| EAN sin packshot público | ~92 | Hay código, pero Nadro/Open Facts/retail no publican foto usable de esa presentación |
| Sin EAN | ~34 | No se busca packshot a ciegas (regla del catálogo) |
| Insumo genérico (jeringas, goteros, peines…) | ~15 | Casi nunca hay ficha pública; conviene foto de mostrador |
| Mercurio / herbolario | ~12 | Marca de mostrador sin CDN público confiable |
| EAN interno (200…) | ~10 | Código propio, no de fabricante |
| Genérico de lab sin packshot | ~8 | AMSA/Alpharma/etc. sin foto pública de esa caja |

## Siguiente paso práctico

1. Deploy + correr `sql/patch_fotos_amifarin_cina_aas_20260906.sql` y `sql/patch_fotos_lote_conseguibles_20260906.sql`.
2. Para el resto de alto stock: sesión Nadro/Levic o foto de mostrador (lista en `sql/generated/fotos_pendientes_tras_lote_20260906.csv`).

