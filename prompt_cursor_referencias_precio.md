# Prompt para Cursor — Pestaña «Referencias de precio»

Pega esto completo en Cursor.

---

Ya definimos el alcance de la pestaña nueva «Referencias de precio» en Inventario (FarmaCapital, `/Users/ibarra/farmacapital`, React + Supabase, tabla `productos`). Antes de que empieces a construir, necesito que resuelvas un punto que quedó abierto: **de dónde y cómo se van a sacar los precios de cada fuente en automático**, porque no todas las fuentes funcionan igual.

## Estado real de cada fuente (confirmado, no asumas nada distinto)

**Farmacias Similares (venta):** SÍ es automatizable de verdad. Es una tienda VTEX pública, sin login:
`https://www.farmaciasdesimilares.com/api/catalog_system/pub/products/search/{TERMINO}`
Devuelve JSON con precio real en `items[].sellers[0].commertialOffer.Price`. Ya lo probé con productos reales del catálogo (Amoxicilina, etc.) y funciona. Se puede hacer un job que busque por nombre/principio activo y traiga precio real.

**Farmacia del Ahorro (venta):** NO tiene API pública equivalente. Ya probé el mismo patrón VTEX (`fahorro.com/api/catalog_system/pub/products/search/...`) y no responde igual — o no está en VTEX o lo bloquea. Por ahora es **manual**: alguien captura precios a mano y los sube. No inviertas tiempo en scraping automático de este sitio hasta confirmar que existe algún endpoint público real; si encuentras uno, perfecto, pero no lo asumas.

**Exprezo (compra):** No es un sitio público — es una app/portal de mayoreo con cuenta. No tenemos forma de automatizar la extracción desde ahí (no hay API, y el login no se puede compartir con un agente). El flujo real es: el dueño exporta o descarga un CSV/lista desde la app de Exprezo manualmente, cada cierto tiempo (ya tenemos uno: `pricing/precios_proveedores/Exprezo_20260812.csv`, ~1421 filas, sin barcode, con errores de OCR ocasionales). La automatización posible aquí NO es "ir a buscar el precio a internet", es: **subir el CSV nuevo → el sistema hace el match automático contra el catálogo (ya existe la lógica fuzzy en `scripts/pricing_pipeline.py`)**.

**Nadro / Marzam / Levic (compra, medicamentos):** Todavía no sabemos cómo opera cada uno — pueden ser portal B2B con login, pedido por WhatsApp con un representante, o un PDF/Excel de lista de precios que le mandan al cliente registrado. No lo asumas. El dueño tiene que confirmar con cada distribuidor si existen:
1. Portal de cliente con lista de precios descargable/exportable
2. API o integración para punto de venta
3. Solo PDF/WhatsApp/lista impresa

Mientras no se confirme, diseña la ingestión de estas tres fuentes igual que Exprezo: **subir archivo (CSV/Excel/PDF) → match automático**, no scraping. Si en el futuro alguno sí tiene API, se agrega como una fuente más sin rediseñar nada (por eso recomendamos guardar los precios en una tabla normalizada, no en columnas fijas — ver abajo).

Nota aparte, no bloqueante: COFECE multó a Nadro, Marzam, Fanasa, Saba y Almacén de Drogas por colusión de precios en medicamentos. No es razón para no usarlos, pero un precio "bueno" de Nadro o Marzam no necesariamente refleja competencia real de mercado — trátalo como una fuente más, no como benchmark absoluto.

## Resumen del diseño ya acordado (no lo cambies, constrúyelo así)

**Modelo de datos:** tabla normalizada `producto_precios_referencia (producto_id, fuente, tipo['compra'|'venta'], precio, fecha)`, NO columnas fijas por proveedor en `productos`. Así se agregan fuentes nuevas sin migración y el historial semanal sale gratis (no se borran filas viejas, se agregan). Ya existe un boceto de esto (`ofertas_proveedor`) en `sql/schema_inventario_v2_con_proveedores.sql`, revísalo antes de diseñar el schema desde cero.

**Tabla de compra** en la pestaña: Tu costo actual · una columna por proveedor con su precio + % de diferencia contra tu costo (`(precio_proveedor − tu_costo) / tu_costo`) · rojo si el proveedor sale más caro, azul si sale más barato (oportunidad) · columna "Mejor proveedor" con el mínimo.

**Exportar pedido por proveedor:** ya existe la lógica de cantidad sugerida en `src/ReabastoModule.jsx` (`cantidadSugerida = max(stock_minimo*3 - stock, 1)`) y un flujo de "selecciona productos → ajusta cantidad → Generar orden de compra". Reutilízalo, no lo reconstruyas — solo agrega que la selección de mejor proveedor sea automática (el más barato de la tabla de compra) y que el Excel se separe por proveedor.

**Tabla de venta:** Tu precio actual · Del Ahorro · Similares · Precio sugerido (mínimo de las dos referencias, respetando margen mínimo por tipo: genérico ~60%, marca ~30%, higiene ~40% — ver `docs/PRICING_DIAGNOSTICO.md`) · botón "Aplicar" por fila que pide confirmación y hace `UPDATE productos SET precio = sugerido WHERE id = producto_id`. Nunca automático sin confirmar.

**Regla de negocio:** las referencias externas (precios de proveedores/competencia) SÍ se actualizan solas al subir un archivo o correr el job de Similares. `costo` y `precio` de FarmaCapital NUNCA se tocan automáticamente, solo con el botón "Aplicar" y confirmación explícita del dueño.

**Ligado al inventario:** todo vive sobre el mismo `producto_id`/`sku` de la tabla `productos` — no es un catálogo paralelo.

## Lo que necesito que hagas ahora

1. Confirma que entendiste la diferencia entre fuentes automatizables (Similares) y fuentes de "subir archivo" (Exprezo, Nadro, Marzam, Levic, y por ahora Del Ahorro).
2. Diseña el flujo de importación de archivos (CSV/Excel/PDF) de forma genérica — un solo componente que sirva para cualquier proveedor nuevo, no uno por proveedor.
3. Propón el schema de `producto_precios_referencia` basado en `ofertas_proveedor` si aplica.
4. Dime qué necesitas de mí (el dueño) para cada distribuidor de medicamentos antes de poder construir su ingestión — sé específico por proveedor.
5. Orden de implementación con archivos a tocar.

Sé crítico, no solo valides. Responde en español.
