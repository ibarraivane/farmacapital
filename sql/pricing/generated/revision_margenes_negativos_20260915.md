# Márgenes negativos — 15 sep 2026

Catálogo vivo: **13 SKUs** con `precio < costo`. Causa pedida: se tomó el **importe del renglón** (qty × unitario) como costo de una pieza.

SQL: `sql/patch_costos_unitarios_ticket_qty_20260915.sql`

## 1. Importe de N piezas guardado como costo (Exprezo 1279718)

El alta original ya traía el unitario. Recibir / última compra pisó con el total.

| SKU | Producto | Qty ticket | Unitario | Importe (lo que quedó) | PVP | Tras el parche |
|---|---|---:|---:|---:|---:|---|
| `FC-06246652` | Dove blanco 90 g | 6 | $18.63 | **$111.80** | $25 | costo $18.63 · margen +25% |
| `FC-75102421` | Gerber E2 manzana 100 g | 3 | $10.68 | **$32.04** | $15 | costo $10.68 · +29% |
| `FC-75102452` | Gerber E2 pera 100 g | 3 | $10.68 | **$32.04** | $15 | igual |
| `FC-75102469` | Gerber E2 mango 100 g | 3 | $10.68 | **$32.04** | $15 | igual |
| `FC-75102476` | Gerber E2 durazno 100 g | 3 | $10.68 | **$32.04** | $15 | igual |
| `FC-75102520` | Gerber E2 res 100 g | 4 | $10.68 | **$42.72** | $15 | igual |
| `FC-75102537` | Gerber E2 pollo 100 g | 4 | $10.68 | **$42.72** | $15 | igual |
| `FC-58651129` | Gerber Junior pouch 95 g | 3 | $12.79 | **$38.38** | $18 | costo $12.79 · +29% |

PVP no se toca: ya era el de una pieza.

## 2. Se pegó el importe de OTRO renglón del mismo ticket

| SKU | Producto | Unitario real | Costo vivo | De dónde salió el número |
|---|---|---:|---:|---|
| `FC-75005092` | Heinz pouch manzana 113 g | $14.40 (3 pzas = $43.19) | **$32.04** | importe de Gerber Etapa 2 |
| `FC-05809248` | Enfagrow Premium 3 / 800 g | $306.00 (1 pza) | **$568.96** | importe de Flanax 3 × $189.65 |

Flanax (`FC-84973401`) se quedó bien: costo $189.65, PVP $220.

## 3. Farmalive cobró el C/8; el EAN es de una

| SKU | Producto | Ticket | Costo vivo | Unitario |
|---|---|---|---:|---:|
| `FC-73629981` | Kleenex Sellapack 15 pañuelos | Farmalive 97: 1 × PACK C/8 **$32.83**; 9861: 2 × $32.63 | $32.83 | **$4.10** (32.83 ÷ 8) |

El EAN `7501017362998` es el sellapack. Se vende a $10. Con $32.83 de costo parecía margen −228%.

## 4. El costo está bien; el PVP no

| SKU | Producto | Ticket | Costo | PVP vivo | Qué era el $8.27 |
|---|---|---|---:|---:|---|
| `EQ-MAV198` | Oxatech 14 tab 10 mg | Equilibrio 440393: **1 × $26.46** | $26.46 | $8.27 | unitario de Erispan Comp 10 tab (3 × $8.27) |

Se pone PVP $43 (`ceil(26.46 × 1.6)`). Similares andaba en $149; no se sube a ciegas.

## 5. Sin ticket — no se parte

| SKU | Producto | Costo | PVP | Stock | Nota |
|---|---|---:|---:|---:|---|
| `FC-08011145` | Just For Men barba/bigote negro | $171.14 | $165 | 2 | Alta mostrador sin costo. Calle $192–$302 el kit. $171 cabe en 1 pieza. No se divide a $85.57. |

Queda el único margen negativo (−3.7%) hasta que aparezca la compra.

## Qué no se tocó

- Alliviax `FC-40013805`: Exprezo 3 × $100.50; Farmalive después 3 × $59.29. Catálogo $59.29 / PVP $110.
- Escudo azul `FC-25652716`: Exprezo 3 × $13.65. Catálogo $13.65 / PVP $31.
- Optims `FC-EXP-OPT48`: pack $75.30 ÷ 48 = $1.57 (ya partido).

## 6. Precio de dos como costo de uno (tras el primer parche)

SQL: `sql/patch_costos_dos_como_uno_regalos_20260915.sql`

Sí: en higiene de Bodega el CSV pone el **importe de 2** en `precio_unitario`. El resto de qty≥2 de ese ticket ya estaba partido (Sedal $9.08, Escudo Rosa $4.48, Pert oliva $7.40). Quedaron:

| SKU | Producto | Qué quedó | Unitario |
|---|---|---:|---:|
| `FC-46682815` | Speed Stick sensitive | **$29.91** = importe de 2 | **$14.95** |
| `FC-20500164` | Pert kera 100 ml | **$14.80** pegado del oliva (2 pzas) | **$7.40** |

## 7. Paquete que se vende por pieza

| SKU | Producto | Costo vivo | Pieza |
|---|---|---:|---:|
| `FC-C4530823` | Mercurio óxido de zinc C/50 | **$9** (pomada C/25 pegada) | **$1.08** (caja $54 ÷ 50) |
| `FC-0ACC5B6A` | Mercurio Oxido De Zinc | $1.08 | ya partido · no se toca |

## 8. Regalos por caducar (costo $0)

No se inventa caducidad.

| SKU | Producto | Costo vivo | Tras el parche |
|---|---|---:|---|
| `EQ-PYG016` | Metamucil 504 g | $0.01 | **$0** |
| `FC-98062243` | Pharmaton C/100 | $0 (ya) | **$0** + nota de regalo |
