# Bajo pedido — contrato único (tienda, altas, checkout, admin)

Estado: implementado en `feat/bajo-pedido`. Este documento manda sobre briefs anteriores
(el de Cursor y el plan de subcatálogos con anticipo 50%, que quedó descartado).

## Qué es
Producto que **no está en anaquel** y se consigue con mayorista en 24-48 hrs.
`productos.bajo_pedido = true`, `stock = 0`, sin lote ni caducidad.

## Altas (SQL / Inventario)
| Campo | Regla |
| --- | --- |
| `bajo_pedido` | `true` (columna creada por `sql/patch_bajo_pedido_20260916.sql`; correr ANTES de las altas) |
| `precio` | **Ancla de mostrador** (costo + margen de lista). Nunca con Mercado Pago incluido |
| `precio <= 0.01` | Sale en vitrina con **Cotizar**; no se puede pagar en línea |
| `stock` | 0. No inventar lote/caducidad |
| `categoria` / `subcategoria` | Dermatología = `Cuidado personal` + `Dermatología` · Vitaminas = `Vitaminas` · Suplementos = `Suplemento` · Proteína = `Suplemento` + `Proteína`. **No** hay categoría nueva |
| nombre, marca, foto, SKU | Nombre de mostrador, marca real, foto obligatoria, `FC-` + últimos 8 del EAN |
| Anaquel | Si hay stock real de góndola, **no** se marca (el RPC de Inventario lo rechaza) |

## Precio web
`precio web = ceil(round(ancla / (1 − 0.040484), 2))` (Checkout MX 3.49% + IVA).
- JS: `src/lib/precioOnlineMp.js` · API: `api/_lib/precioOnlineMp.js` · SQL: `public.fc_precio_online_mp(numeric)`.
- Solo líneas bajo pedido y **una vez**: la tienda lo aplica al cargar (`prepararListaTienda`) y el servidor al crear el pedido. Sin promociones ni `descuento_pct`.
- POS y catálogo con stock: ancla sin cambio.

## Tienda
- `/conseguir`: vitrina por rubro (Todos · Dermatología · Vitaminas · Suplementos · Proteína) + formulario «Levantar pedido».
- Buscador de home/catálogo/ficha: tercer botón «Te lo conseguimos» (celular: «Conseguir»). El header no lo lleva.
- Tarjeta y ficha: badges **Bajo pedido** + **24-48 hrs**, nunca «Agotado». CTA **Encargar** (con precio) o **Cotizar** (sin precio → formulario prellenado).
- Carrito: máx. 12 por línea; **no mezcla** encargos con productos de anaquel.

## Cobro: reserva en tarjeta (no cae a la cuenta hasta conseguirlo)
1. Checkout crea el pedido con `cliente_crear_pedido_bajo_pedido` (no toca `cliente_crear_pedido_online`). Queda `metodo_pago = 'tarjeta'`, `logistics_meta.bajo_pedido = true`.
2. Paso 3: formulario seguro de Mercado Pago → `POST /api/payments/mp/create-preference` con `modo: "reserva"` → `POST /v1/orders` con `capture_mode: "manual"`. Solo **tarjeta de crédito**. `payment_status = 'authorized'`, vence en **5 días**.
3. Mostrador → *Lo que buscan* → pestaña **Encargos web (reserva)**: pedir al mayorista, recibir por Recibir, **Cobrar reserva** (`point?action=reserva-cobrar`) → `approved`, puntos y WhatsApp de pago aprobado → aparece en pedidos por surtir.
4. Si no se consigue: **Cancelar reserva** (`point?action=reserva-cancelar`) → el banco libera, sin comisión; pedido `cancelado`.
- Una preferencia normal (liga) para un pedido bajo pedido se rechaza (`pedido_bajo_pedido_usa_reserva`).
- El webhook no degrada un pedido cobrado ni pisa una reserva viva.
- Sin funciones Serverless nuevas (Vercel Hobby 12/12).

## Reabasto
`nivelStockUrgencia` devuelve `null` para bajo pedido: no salen en agotados, stock bajo ni «Pedir agotados». Inventario tiene el filtro «Bajo pedido (vitrina)».
Pendiente menor: el bundle SQL del dashboard (`bajo_stock`, top 5 nombres) aún los cuenta.

## Compatibilidad con `cursor/encargo-medicamentos-fase-a-a675`
Se combina con un conflicto trivial de `import` en `Tienda.jsx`. «Avísame cuando esté disponible» no aparece en bajo pedido porque `productoAgotadoTienda` los excluye.
