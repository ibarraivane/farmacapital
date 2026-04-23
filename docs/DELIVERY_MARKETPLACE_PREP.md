# FARMAX — Preparación delivery, pickup y marketplaces

Documento de diseño y de cambios aplicados en código (sin integraciones OAuth reales). Objetivo: operar **tienda propia + pickup**, dejar listo **envío / Uber Direct** y **pedidos marketplace** (Rappi / Uber Eats) con un modelo de datos claro.

## 1. Resumen ejecutivo

- **Hoy en BD:** `pedidos` usa `estado` (p. ej. `pendiente`, `listo`, `completado`, `cancelado`), `tipo` (`online`, …), `tipo_entrega` (`recoger` | `envio`), `direccion`, `metodo_pago`. El RPC `cliente_crear_pedido_online` valida carrito y totales server-side.
- **Bug corregido (tienda):** el checkout llamaba al RPC con parámetros incorrectos (`p_items`, `p_notas`) y enviaba `pickup`/`cdmx`/`foraneo` donde el servidor solo acepta `recoger`/`envio`. Ahora se usa `p_cart` y el mapeo correcto.
- **Nuevo en frontend:** `src/utils/orderChannels.js` define canales, fulfillment, mapeo UI→RPC y reglas de elegibilidad de producto (alineadas a `visible_tienda`, `requiere_receta`, `controlado`; opcional `delivery_allowed`).
- **Nuevo (opcional en Supabase):** `sql/patch_pedidos_logistics_meta.sql` agrega `pedidos.logistics_meta` (jsonb) para IDs externos, proveedor, tracking, etc., **sin** cambiar RPCs todavía.
- **Placeholders:** `src/services/marketplace/adapters.js` para futuros conectores Rappi / Uber Eats / Uber Direct.
- **Catálogo propuesto:** `docs/catalogo_propuesta_vitaminas_electrolitos.csv` (plantilla importación; sin datos de producción).

## 2. Modelo conceptual

### A. Canal del pedido (`order_channel`)

| Valor (constante) | Uso |
|-------------------|-----|
| `web_pickup` | Checkout web, recoger en tienda |
| `web_delivery` | Checkout web, envío |
| `rappi_marketplace` | Pedido originado en Rappi |
| `uber_eats_marketplace` | Pedido originado en Uber Eats |
| `counter_pos` | Venta mostrador (ya cubierto por flujos POS) |

*Persistencia recomendada:* campo dedicado o clave dentro de `logistics_meta.order_channel` tras aplicar el patch SQL.

### B. Fulfillment (`fulfillment_type`)

| Valor | Uso |
|-------|-----|
| `pickup_store` | Cliente recoge en farmacia |
| `marketplace_courier` | Repartidor de la plataforma (Rappi / UE) |
| `uber_direct` | Última milla contratada por Farmax (Uber Direct) |
| `own_delivery` | Reparto propio (reservado; hoy no operativo) |

### C. Estados deseados vs `pedidos.estado` actual

El negocio puede evolucionar a estados más finos. Hoy el sistema usa pocos valores en columna `estado`. Mapeo sugerido (ver `ORDER_WORKFLOW_STATE` y `WORKFLOW_TO_DB_ESTADO` en `orderChannels.js`):

| Workflow (objetivo) | Columna actual típica |
|---------------------|------------------------|
| created, paid_pending_validation, accepted, preparing | `pendiente` |
| ready_for_pickup, courier_* , picked_up | `listo` |
| delivered | `completado` |
| cancelled | `cancelado` |

Ampliar estados en BD es posible con una migración acotada y actualización de RPCs (`marcar_pedido_listo`, etc.); **no** se hizo en esta entrega para no romper producción.

### D. Producto / SKU

Campos ya usados en admin/SQL: `requiere_receta`, `controlado`, `visible_tienda`.  
Opcional futuro: `delivery_allowed`, `sell_rappi`, `sell_uber` (añadir columna + whitelist en `admin_editar_producto`).

Reglas en tienda web (frontend):

- No agregar al carrito: `visible_tienda === false`, `requiere_receta`, `controlado`.
- Envío (`cdmx` / `foraneo`): además respeta `delivery_allowed === false` si la columna existe.

El RPC ya rechaza `requiere_receta` en línea; conviene añadir validación server-side de `controlado` en una migración pequeña cuando se apruebe.

### E. Tracking / referencias externas

Campos lógicos (guardar en `logistics_meta` tras el patch):

- `external_order_id`, `external_delivery_id`
- `logistics_provider` (`rappi`, `uber_eats`, `uber_direct`, …)
- `tracking_url`, `courier`, timestamps (`requested_at`, `picked_up_at`, …)

## 3. Integraciones (sin credenciales)

| Sistema | Rol | Estado |
|---------|-----|--------|
| Rappi marketplace | Pedidos entrantes + courier de plataforma | Stub `ingestRappiOrderPlaceholder` |
| Uber Eats | Idem | Stub `ingestUberEatsOrderPlaceholder` |
| Uber Direct | Última milla desde tienda | Stub `requestUberDirectDeliveryPlaceholder` |

Flujo futuro típico: webhook o job → crear/actualizar `pedidos` + rellenar `logistics_meta` → UI admin para “solicitar courier” / ver tracking.

## 4. Archivos tocados / nuevos

| Archivo | Cambio |
|---------|--------|
| `src/Tienda.jsx` | RPC correcto, mapeo entrega, validación carrito, mensajes éxito/WhatsApp con resumen guardado, UX productos “solo mostrador”, aviso envío |
| `src/utils/orderChannels.js` | **Nuevo** — constantes y helpers |
| `src/services/marketplace/adapters.js` | **Nuevo** — placeholders |
| `sql/patch_pedidos_logistics_meta.sql` | **Nuevo** — columna opcional |
| `docs/catalogo_propuesta_vitaminas_electrolitos.csv` | **Nuevo** |
| `docs/DELIVERY_MARKETPLACE_PREP.md` | Este documento |
| `src/modules/sales/pos/POS.jsx` | Online: `tipo_entrega`, dirección, doc link (select sin `logistics_meta` hasta patch) |
| `src/TransaccionesTab.jsx` | Entrega / dirección en fila y modal de detalle |

## 5. Pendiente (credenciales / migraciones)

- Ejecutar en Supabase `patch_pedidos_logistics_meta.sql` cuando se quiera persistir metadatos.
- Extender `cliente_crear_pedido_online` para aceptar `p_logistics_meta` o columnas dedicadas (opcional).
- Validación server-side de `controlado` en el mismo RPC que `requiere_receta`.
- Estados intermedios (`preparing`, `courier_requested`) si el negocio los necesita en reportes.
- Integraciones reales: API keys, webhooks, idempotencia, pruebas en sandbox.

## 6. Build

Última verificación local: **`npm run build`** — compilación correcta (2026-04-20).

> Asegúrate de que en Supabase exista la firma de `cliente_crear_pedido_online` con parámetro **`p_cart`** (jsonb), como en `sql/refactor_fase6b_rpcs_tienda.sql`. Si tu proyecto aún tuviera una versión antigua con otro nombre de parámetro, alinear antes de desplegar el frontend.

## 7. Entregable final (checklist del prompt)

| Ítem | Estado |
|------|--------|
| **Resumen ejecutivo** | §1 de este documento |
| **Auditoría pedidos / productos / entrega** | §1–2; checkout y RPC alineados en `Tienda.jsx` |
| **Cambios seguros (sin refactors masivos)** | Helpers en `orderChannels.js`, stubs marketplace, patch SQL opcional |
| **Integraciones reales** | Pendiente (credenciales, webhooks); estructura en `adapters.js` y `logistics_meta` |
| **Documentación** | Este archivo + `docs/CURSOR_DELIVERY_MARKETPLACE_PREP_PROMPT.md` |
| **Build** | `npm run build` — OK (2026-04-20) |
| **Plantilla SKUs** | `docs/catalogo_propuesta_vitaminas_electrolitos.csv` |

**Archivos modificados o nuevos (lista consolidada):**

- `src/Tienda.jsx` — RPC `p_cart`, mapeo pickup/envío, validación carrito y elegibilidad
- `src/utils/orderChannels.js` — canales, fulfillment, mapeo UI→RPC, etiquetas entrega
- `src/services/marketplace/adapters.js` — placeholders Rappi / Uber Eats / Uber Direct
- `src/modules/sales/pos/POS.jsx` — pestaña Online: `tipo_entrega`, `direccion`, enlace a esta guía (sin `logistics_meta` en el select hasta aplicar el patch SQL, para no romper PostgREST)
- `src/TransaccionesTab.jsx` — línea de entrega y dirección en listado/detalle de pedidos online
- `sql/patch_pedidos_logistics_meta.sql` — columna opcional `logistics_meta`
- `docs/catalogo_propuesta_vitaminas_electrolitos.csv`, `docs/DELIVERY_MARKETPLACE_PREP.md`

**Listo vs pendiente:** lo operativo en tienda web + modelo documentado + UI admin (POS online, transacciones) está listo. Pendiente: ejecutar patch si quieres tracking en BD, ampliar RPCs, e integraciones marketplace/última milla reales (§5).
