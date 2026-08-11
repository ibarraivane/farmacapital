# Diagnóstico — Sistema de precios por categoría (FarmaCapital)

**Fecha:** 2026-08-10  
**Estado:** Diagnóstico + vista previa. **Sin cambios aplicados en Supabase.**

---

## 1. Estructura real inspeccionada

### Fuente de verdad de esquema

| Recurso | Ubicación |
|---------|-----------|
| DDL base | `sql/schema_inventario.sql` |
| Columnas catálogo | `sql/patch_productos_campos_catalogo.sql`, `sql/fix_producto_campos_busqueda_ubicacion.sql` |
| RPC ventas | `sql/create_sale_transaction.sql`, `sql/refactor_fase4a_rpcs_sin_legacy.sql` |
| RPC tienda | `sql/refactor_fase6b_rpcs_tienda.sql` |
| RPC POS catálogo | `sql/rpc_p0_lecturas_tienda_pos.sql` → `empleado_listar_productos_con_lotes_pos` |
| Edición admin | `admin_editar_producto` en `sql/fix_producto_campos_busqueda_ubicacion.sql` |
| Auditoría | `audit_log_detallado` + `trg_audit_productos` (`sql/refactor_fase6d_audit_triggers.sql`) |

**No existe** carpeta `supabase/migrations/` ni tabla `pricing_rules`.

### Tabla `public.productos` (campos relevantes confirmados)

| Campo | Existe en prod | Uso |
|-------|----------------|-----|
| `costo` | Sí | Costo neto de compra (también `lotes.costo_unitario`) |
| `precio` | Sí | **Precio de venta efectivo hoy** (no hay `precio_venta`) |
| `precio_unidad` | Sí | Venta suelta |
| `categoria` | Sí | Clasificación principal |
| `subcategoria` | **No** (columna ausente en Supabase; solo en whitelist RPC) | — |
| `tipo` | Sí | `generico` / `marca` / `MEDICAMENTO` / `GENERICO` (mixto en carga) |
| `presentacion` | Sí | Texto libre |
| `principio_activo`, `forma_farmaceutica`, `marca` | Sí | Clasificación auxiliar |
| `requiere_receta` | Sí | Antibióticos / controlados |
| `descuento_pct` | Sí | Descuento POS (cliente; RPC valida total aparte) |
| `precio_similares`, `precio_del_ahorro` | Sí | Referencia competencia (no venta) |
| **IVA / tasa fiscal** | **No hay columna** | UI asume 16% incluido globalmente |

### Inventario histórico de ventas (intocable)

| Tabla | Campo snapshot | Notas |
|-------|----------------|-------|
| `pedido_items` | `precio_unitario` | Precio al momento de la venta |
| `pedidos` | `total` | Sin desglose IVA en BD |
| `devolucion_items` | `precio_unitario` | Devoluciones |

Los RPC `create_sale_transaction_v2` y `cliente_crear_pedido_online` **leen `productos.precio` en el servidor** y escriben el snapshot en `pedido_items`. Cambiar `productos.precio` **no altera ventas pasadas**.

### Triggers actuales (productos / lotes)

- `trg_sync_productos_stock` — sincroniza `productos.stock` desde lotes (**no toca precios**).
- `trg_audit_productos` — audita cambios en `productos` (incluye `precio`, `costo`).
- **No hay** trigger que calcule `precio` desde `costo`.

### Integración app → precio efectivo

```
productos.precio
  ├─ POS: empleado_listar_productos_con_lotes_pos → carrito → create_sale_transaction_secure (re-lee BD)
  ├─ Tienda: select productos → cliente_crear_pedido_online (re-lee BD)
  ├─ Inventario: edición directa / admin_editar_producto
  └─ Promociones: tabla promociones NO aplicada en checkout (solo descuento_pct en POS)
```

---

## 2. Estado actual del catálogo (Supabase en vivo — lectura)

**Total productos:** 433  
**Con costo válido (>0):** 433 (100%)  
**Sin precio:** 0  

### Distribución por `categoria`

| Categoría | Productos |
|-----------|-----------|
| Otro | 162 |
| Higiene | 138 |
| Cuidado personal | 50 |
| Botiquín | 34 |
| Producto | 18 |
| GENERAL | 17 |
| Suplemento | 7 |
| Bebés | 4 |
| Abarrotes | 3 |

### Conflicto estructural #1 — Categorías vs reglas solicitadas

El formulario de inventario (`InventarioModule.jsx`) lista categorías clínicas (Analgésico, Antibiótico, etc.), pero **en producción casi todo está en `Otro`, `Higiene`, `Producto`, `GENERAL`**.  
La clasificación **debe** usar `categoria` + `tipo` + `forma_farmaceutica` + `marca` + palabras clave en nombre, **no** solo categoría clínica.

### Conflicto estructural #2 — Política de precios actual vs nueva

Los scripts `ACTUALIZACION_MASIVA_1_preparacion_catalogo.sql` aplicaron **~60% de recargo sobre costo** a casi todo el catálogo (comentarios `margen 60%`).

| Métrica (vista previa) | Valor |
|------------------------|-------|
| Precios que coinciden con recargo legacy ~60% | **303 / 433 (70%)** |
| Precios que coinciden con regla nueva propuesta | 19 / 433 |
| Precios “atípicos” (no 60% ni regla nueva) | 130 / 433 |

**Implicación:** Las reglas nuevas **bajarían** el precio de ~249 productos (OTC marca 35%, bebés 30%, higiene 40% vs 60% actual) y **subirían** ~9 productos (>30%, muchos por costos de ticket mal parseados).

### Conflicto estructural #3 — IVA

- No existe `tasa_iva`, `iva_incluido_en_costo` ni equivalente.
- POS y factura PDF usan **16% fijo** en código (`total * 0.16 / 1.16`).
- **No es seguro** recalcular ni asumir tasa 0% en medicamentos sin columna fiscal.
- **Propuesta:** agregar `tasa_iva` (nullable) + `iva_revision_pendiente`; no auto-modificar IVA.

### Conflicto estructural #4 — Costos sospechosos

Productos con costo muy bajo (error de parseo de ticket, ej. $0.92) generan subidas extremas al aplicar utilidad mínima $5:

| SKU | Nombre | Costo | Precio actual | Propuesto |
|-----|--------|-------|---------------|-----------|
| FC-34067301 | Venda Quirmex | ~0.92 | 0.92 | 6 |
| FC-68910041 | Algodón 5g | ~0.93 | 0.93 | 6 |

Estos deben ir a **`price_needs_review = true`** sin cambio automático.

---

## 3. Vista previa de reglas (433 productos)

Generada con `scripts/pricing_preview.py` → `sql/pricing/generated/preview_precios_productos.csv`

### Productos por regla (simulación)

| Regla | Recargo | Productos |
|-------|---------|-----------|
| higiene | 40% | 174 |
| med_otc_marca | 35% | 153 |
| material_curacion | 50% | 32 |
| med_generico | 60% | 39 |
| bebidas_sueros | 30% | 13 |
| bebe | 30% | 10 |
| vitaminas | 45% | 8 |
| impulso | 40% | 4 |

### Validaciones simuladas

| Check | Resultado |
|-------|-----------|
| Precio propuesto < costo | **0** |
| Precio negativo | **0** |
| Sin costo válido (skip) | **0** |
| Subida > 30% | **9** (revisar costos) |
| Bajada de precio | **249** (cambio de política 60% → reglas) |
| Ambiguos marcados | Ver CSV columna `needs_review` |

### Ejemplos Electrolit (regla bebidas_sueros 30%)

| SKU | Costo | Actual | Propuesto | Variación |
|-----|-------|--------|-----------|-----------|
| FC-51448511 Uva | 20.50 | 32.81 | 27 | −17.7% |
| FC-25104411 Coco | 20.09 | 32.15 | 27 | −16.0% |

*(Hoy están a ~60%; la regla solicitada es 30%.)*

---

## 4. Arquitectura propuesta (adaptada al proyecto)

### Nueva tabla `public.pricing_rules`

Ver migración `sql/pricing/001_create_pricing_rules.sql`.

### Nuevas columnas en `productos` (no existían)

- `pricing_rule_id` → FK a regla aplicada
- `markup_percentage` → recargo usado (decimal, ej. 0.35)
- `calculated_price` → resultado de fórmula
- `manual_price_override` → boolean
- `price_needs_review` → boolean
- `price_updated_at` → timestamptz
- `tasa_iva` → nullable (sin valor = revisión fiscal pendiente)
- `costo_incluye_iva` → nullable boolean

**Precio efectivo:**

```sql
precio_efectivo = CASE
  WHEN manual_price_override THEN precio  -- conservar manual
  ELSE calculated_price
END
```

En fase 1: actualizar `precio = calculated_price` solo donde `manual_price_override = false` y `price_needs_review = false`.

### Historial

Reutilizar `audit_log_detallado` (ya audita `productos`) + tabla mínima `productos_precio_historial` (migración 001) con respaldo `productos_precio_backup_20260810`.

---

## 5. Qué NO se hará automáticamente

- ❌ Borrar costos, lotes, códigos de barras, movimientos
- ❌ Modificar `pedido_items` históricos
- ❌ Asumir IVA 16% en medicamentos exentos
- ❌ Recalcular productos sin costo válido
- ❌ Sobrescribir precios con `manual_price_override = true`
- ❌ Aplicar a productos con `price_needs_review = true` (costos sospechosos, ambiguos)

---

## 6. Archivos generados (siguiente paso)

| Archivo | Propósito |
|---------|-----------|
| `sql/pricing/001_create_pricing_rules.sql` | Tabla reglas + columnas + historial + backup |
| `sql/pricing/002_fn_pricing_calculate.sql` | Función de cálculo (recargo + utilidad mínima + ceil) |
| `sql/pricing/003_preview_pricing.sql` | Vista `vw_pricing_preview` |
| `sql/pricing/004_apply_pricing_idempotente.sql` | Aplicación controlada |
| `sql/pricing/005_rollback_pricing.sql` | Restauración desde backup |
| `scripts/pricing_preview.py` | Reporte CSV + markdown |
| `sql/pricing/generated/preview_precios_productos.csv` | Vista previa por producto |

---

## 7. Decisión requerida antes de aplicar

1. **¿Confirmas bajar ~249 precios** que hoy están a ~60% hacia reglas 25–40%?  
2. **¿Electrolit a 30%** (precio ~$27) en lugar de ~$33 actual?  
3. **¿Agregamos columna `tasa_iva`** y llenamos manualmente antes de tocar fiscal?  
4. **¿Productos con costo < $2** se marcan solo para revisión (recomendado)?

Cuando confirmes, ejecutar en orden:

```sql
-- 1) sql/pricing/001_create_pricing_rules.sql
-- 2) sql/pricing/002_fn_pricing_calculate.sql
-- 3) sql/pricing/003_preview_pricing.sql   ← revisar SELECT *
-- 4) sql/pricing/004_apply_pricing_idempotente.sql
```

Rollback:

```sql
-- sql/pricing/005_rollback_pricing.sql
```
