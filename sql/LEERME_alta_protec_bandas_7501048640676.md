# Alta: Protec bandas adhesivas 22 mm C/100

## Qué es

| Campo | Valor |
|---|---|
| EAN | `7501048640676` |
| SKU | `FC-48640676` |
| Nombre | Protec bandas adhesivas tela elástica 22 mm |
| Presentación | Caja C/100 (circulares 22 mm, color piel, libre de látex) |
| Lote / cad | `503500048` · cad **2029-03-31** (caja: 2029-03) |

No es `FC-89975530` (mismo producto en bajo pedido Ewafra **sin** EAN).

## Precios

| | Monto | Nota |
|---|---|---|
| Costo caja | **$41.67** | Ancla Ewafra 503500 |
| PVP caja | **$53** | Marca +25% sobre costo |
| **Pieza** | **$1** | Ya vendieron una; margen ~58% vs costo ~$0.42 |

`$1` la pieza está bien. Retail vende la caja cerrada ~$34–$72; en mostrador la curita suelta a $1 es normal. El sugerido automático del POS (~$6) es la regla de “pieza suelta” genérica; aquí el dueño fija $1.

## Cómo correr

1. Supabase → SQL Editor → pegar todo `patch_alta_protec_bandas_adhesivas_7501048640676.sql` → Run.
2. Tras el deploy: la foto en `public/catalogo-propia/protec-bandas-adhesivas-22mm-c100-7501048640676.jpg` queda en `imagen_url`.
3. Quedan **99 piezas** sueltas (caja abierta −1 vendida fuera del sistema). Siguientes ventas: POS → modo pieza a $1.
