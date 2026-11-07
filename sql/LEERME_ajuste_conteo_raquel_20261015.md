# Conteo Raquel (WhatsApp) — 15-oct-2026

Fotos de hoy: ajustes de stock, altas que no escaneaban / no se podían recibir, y venta por pieza.

Correr en Supabase SQL Editor **en este orden**:

1. `patch_ajuste_conteo_raquel_stock_20261015.sql`
2. `patch_ajuste_conteo_raquel_altas_20261015.sql`
3. `patch_ajuste_conteo_raquel_venta_pieza_20261015.sql`

## Stock (sistema → físico)

| SKU / clave | Producto | Sistema → Físico |
|---|---|---|
| `FC-09749209` | Lumboxen Parche gel x1 | 2 → **1** |
| `FC-45307181` | Curitas Parche León Árnica | 1 → **2** |
| `FC-EXP-OPT48` | Palmolive Optims sobre 10 ml | 41 → **39** |
| Lysol **354 g** | Aerosol 354 g ($140 en POS) | 5 → **3** |
| Lysol grandes | (475 g) | **4 — OK, no tocar** |
| `FC-84500140` | Venda cohesiva 7.5 cm (roja) | 1 → **2** |
| `FC-03406181` | Cinta Micropore Quirmex 2.5 cm | 4 → **3** |
| `FC-84500807` | Cinta Micropore Blanca (Nexcare) | 7 → **2** (ese tamaño) |
| `FC-85800198` | Toallitas Bebín | sin lotes → **1** |
| `FC-43454811` | Toallitas Huggies Cuidado Puro | 1 → **2** |
| `FC-42507240` | GUM Cera ortodoncia menta | 0 → **1** |
| `FC-06719932` | Oral-B Complete mediano 2×1 | 2 → **1** |
| `FC-86494286` | Oral-B Clásico 60 suave | 3 → **2** |
| `FC-07F04F88` | Amcef IM 500 mg | (conteo) → **4** |
| `FC-34067301` | Venda elástica Quirmex 7.5 cm | no encontraba → **12** |

## Barcodes / pistola

| EAN | SKU | Nota |
|---|---|---|
| `7503003406730` | `FC-34067301` | Caja física (antes 14 dígitos `…67301`) |
| `7501349011007` | `FC-07F04F88` | Amcef IM 500 mg (estaba sin EAN) |
| `7501349012004` | `FC-BE76D409` | Amcef IM 1 g (estaba sin EAN) |
| `7501054530718` | `FC-45307181` | Curitas León (si aún tenía 14 dígitos) |

## Altas nuevas

| EAN | SKU | Producto | Stock | Precio |
|---|---|---|---|---|
| `7509546073453` | `FC-46073453` | Colgate Kids Conejo cepillo C/2 | 2 | $45 ancla |
| `7502226293929` | `FC-26293929` | Metformina LP Alpharma 500 mg C/30 | 1 | costo $77.82 → +60% |
| `7501349012011` | `FC-49012011` | Amcef **IV** 1 g / 10 ml | 1 | costo $19.80 → +60% |
| `7501008485378` | `FC-08485378` | Tabcin efervescente exhibidor C/60 (324 mg) | (ya en POS) | venta por pieza |
| `7501008495339` | `FC-08495339` | Tabcin efervescente exhibidor C/60 (500 mg) | alta si falta | venta por pieza |

**Amcef:** el EAN que escaneó Raquel (`7501349012011`) es **IV 1 g**, no el IM. El IM 500 mg es `7501349011007`.

**Metformina:** dijo «este tampoco son 2» → stock **1**. Si en realidad hay 2 cajas, ajustar a mano.

## Venta por pieza

| Producto | Qué hace el patch |
|---|---|
| Schick Xtreme 3 bolsa 12 (`FC-274881475`) | `venta_unidad`, 12 pzas, `precio_unidad` $23 |
| Tabcin exhibidor C/60 (ambas) | `venta_unidad`, 60 pzas, `precio_unidad` $4 |
| Chicolastic etapa **2–5** | `venta_unidad`, 14 pzas; precio unidad ≈ bolsa÷14 |

Etapa 1 (RN) no se toca.

## Pendiente (sin EAN claro en las fotos)

- Sobres **Glowy Skin**, bote **Cboost** / omega, **Just gomitas** Omega 3 — «no pude recibirlo». Falta foto del código / ticket.
- Ligas / scrunchies en bolsita (aparte de `FC-IFC-DON01`).
- Tapones de catéter (ya identificados en el chat; sin conteo).

## Notas

- No inventar caducidades (`0000` inválido).
- Idempotente: si el stock ya está en el físico, no mueve.
- Tras correr: Raquel puede re-escanear Colgate Kids, Quirmex venda, Amcef y Metformina.
