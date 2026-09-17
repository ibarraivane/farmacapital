# Bajo pedido — contrato único (tienda, altas, checkout, admin)

Estado: en `cursor/bajo-pedido-7b37` (PR). Este documento manda sobre briefs anteriores
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
| `categoria` / `subcategoria` | Dermatología = `Cuidado personal` + `Dermatología` · Vitaminas = `Vitaminas` · Suplementos = `Suplemento` · Nutrición deportiva = `Suplemento` + `Nutrición deportiva` (alias `Proteína`). **No** hay categoría nueva |
| nombre, marca, foto, SKU | Nombre de mostrador, marca real, foto obligatoria, `FC-` + últimos 8 del EAN |
| Anaquel | Si hay stock real de góndola, **no** se marca (el RPC de Inventario lo rechaza) |

## Precio web
Tarjeta: solo 3.49% + IVA. Skittles $10 → **$11**.
**Servicio $5** una vez por pedido (peso entero). No es un SKU.
- 1 Skittles = $11 + $5 = **$16**. 5 Skittles = $55 + $5 = **$60**.
- SQL: `sql/patch_servicio_5_pedido_20260916.sql`.

## Tienda
- Catálogo: `/dermocosmetica` y `/vitaminas` (`?rubro=vitaminas|suplementos|proteina`). El chip de proteína se llama **Nutrición deportiva**. Formulario: `/pedidos-especiales`.
- Fase 2: las páginas de categoría mezclan anaquel + encargo. Badge **En tienda** vs **Sobre pedido · 24-48 h**. Agotado de anaquel sigue Agotado.
- Aliases eternos: `/conseguir?seccion=…` redirige a la canónica. `/conseguir` sin sección → Pedidos especiales. `?rubro=creatina` y `?seccion=deporte` abren Nutrición deportiva.
- Menú: Dermocosmética y Vitaminas y suplementos. El servicio se llama **Sobre pedido**; el pie enlaza **Pedidos especiales**.
- Búsqueda sin resultados: «Solicitarlo» abre el formulario con el término precargado.
- Tarjeta y ficha bajo pedido: badge **Sobre pedido · 24-48 h**, nunca «Agotado». CTA **Encargar** (con precio) o **Solicitar precio** (sin precio → formulario).
- Reserva: «Apártalo con tarjeta de crédito. Solo se cobra cuando llega; si no lo conseguimos, no pagas nada.»
- Carrito: máx. 12 por línea; **no mezcla** encargos con productos de anaquel (fase 2 no cambia esto).

## Cobro: reserva en tarjeta (no cae a la cuenta hasta conseguirlo)
1. Checkout crea el pedido con `cliente_crear_pedido_bajo_pedido` (no toca `cliente_crear_pedido_online`). Queda `metodo_pago = 'tarjeta'`, `logistics_meta.bajo_pedido = true`.
2. Paso 3: formulario seguro de Mercado Pago → `POST /api/payments/mp/create-preference` con `modo: "reserva"` → `POST /v1/orders` con `capture_mode: "manual"`. Solo **tarjeta de crédito**. `payment_status = 'authorized'`, vence en **5 días**.
3. Mostrador → *Lo que buscan* → pestaña **Encargos web (reserva)**: pedir al mayorista, recibir por Recibir, **Cobrar reserva** (`point?action=reserva-cobrar`) → `approved`, puntos y WhatsApp de pago aprobado → aparece en pedidos por surtir.
4. Si no se consigue: **Cancelar reserva** (`point?action=reserva-cancelar`) → el banco libera, sin comisión; pedido `cancelado`.
- Una preferencia normal (liga) para un pedido bajo pedido se rechaza (`pedido_bajo_pedido_usa_reserva`).
- El webhook no degrada un pedido cobrado ni pisa una reserva viva.
- Sin funciones Serverless nuevas (Vercel Hobby 12/12).

## Reabasto y alertas
`nivelStockUrgencia` / `filasAlertaStockAnaquel` ignoran bajo pedido. Inventario tiene el filtro «Bajo pedido (vitrina)».
Dashboard y badge del sidebar: correr **también** `sql/patch_bajo_pedido_alertas_dashboard_20260916.sql` (después de la columna). El JS del dashboard vuelve a filtrar por si el SQL viejo sigue vivo.

## CSV de propuesta (no es alta)
`docs/catalogo_propuesta_vitaminas_electrolitos.csv` es **borrador**. Todas las filas van `listo_para_cargar=false`. No tiene EAN, nombre de mostrador, foto ni precio. Categoría canónica: `Vitaminas` o `Hidratación` (nunca «Hidratación / electrolitos»).

## Runbook: `cliente_crear_pedido_online`
El encargo usa `cliente_crear_pedido_bajo_pedido`. La compra de anaquel usa `cliente_crear_pedido_online` y ahora cobra `fc_precio_online_mp` (`sql/patch_pedido_online_precio_mp_20260916.sql`).
Rx permitido; controlados no. `sql/refactor_fase6b_rpcs_tienda.sql` **rechaza** receta: no re-ejecutar ese bloque.
Verificar: `sql/verificar_cliente_crear_pedido_online_receta.sql`.

## Compatibilidad con `cursor/encargo-medicamentos-fase-a-a675`
Se combina con un conflicto trivial de `import` en `Tienda.jsx`. «Avísame cuando esté disponible» no aparece en bajo pedido porque `productoAgotadoTienda` los excluye.

## SQL en Supabase (orden)
1. `sql/patch_bajo_pedido_20260916.sql` — columna + RPC de encargo. **Antes** de cualquier alta `bajo_pedido = true`.
2. `sql/patch_bajo_pedido_alertas_dashboard_20260916.sql` — dashboard / sidebar.
3. `sql/patch_pedido_online_precio_mp_20260916.sql` — el checkout de anaquel cobra el precio web.
4. `sql/patch_servicio_5_pedido_20260916.sql` — % en tarjeta + Servicio $5 una vez.
5. `sql/patch_envio_cotiza_vendedor_20260916.sql` — POS ve pedidos de envío para cotizar; misma función de precio.
6. `sql/verificar_cliente_crear_pedido_online_receta.sql` — solo lectura.
7. En Mercado Pago: habilitar reservar y cobrar después; sandbox con tarjeta de **crédito**.
8. `sql/patch_fase2_vitrina_nutricion_deportiva_20260917.sql` — reclasifica proteína/creatina a `Nutrición deportiva`. **No** marca bajo_pedido.
