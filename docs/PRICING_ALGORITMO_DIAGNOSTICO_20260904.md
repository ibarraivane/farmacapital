# Diagnóstico — algoritmo de precios FarmaCapital

**Fecha:** 2026-09-04  
**Código leído en este repo.** Si este doc y el código no coinciden, gana el código.  
**Datos:** snapshot `sql/preview_catalogo_campos_y_precios.csv` (14-ago-2026, 626 SKUs). Regenerar números: `python3 scripts/diagnostico_pricing_20260904.py`.

No se aplicó ningún cambio en Supabase.

---

## 1. Venta sugerida: el mercado (el más barato) manda

[`src/lib/preciosReferencia.js`](../src/lib/preciosReferencia.js) `calcPrecioSugeridoVenta`:

```javascript
const refMin = Math.min(...vals);
const ancla = usarPromedio && refPromedio != null ? refPromedio : refMin;
const sugeridoCompetitivo = calcPrecioCompetitivo(ancla); // ceil(ref * 0.98)
let sugerido = sugeridoCompetitivo;
if (respetarPiso && piso && (sugerido == null || sugerido < piso)) {
  sugerido = roundPrecioVenta(piso);
}
```

`respetarPisoMargen` default = **false**.

La pestaña Referencias llama sin flags y encima toma el competitivo, no el piso:

```javascript
// src/PreciosReferenciaModule.jsx — resolveSugeridoFila
const base = calcPrecioSugeridoVenta(producto, refs);
let sugerido = ov?.precio ?? base.sugeridoCompetitivo ?? base.sugerido;
```

El piso se calcula (`classifyProductoMargen` + `calcPriceFloor`) y pinta la celda ámbar (`alerta === "debajo_piso"`). **No sube el precio sugerido.** Rappi sí pasa `usarPromedio: true` y `respetarPisoMargen: true`.

`Math.min` es el peor estadístico aquí: un match flojo o una promo de Similares (marca propia, ellos fabrican, tú compras) se vuelve el ancla. Ya existe `mediana()` en [`src/lib/monitorPrecios/matchCatalogo.js`](../src/lib/monitorPrecios/matchCatalogo.js); el resultado robusto se pierde al pasar por `min`.

Fuentes de venta en Referencias: `fahorro`, `similares`, `otros_venta`. No entra Guadalajara salvo vía Rappi (`rappi_gdl`).

---

## 2. Tres “60%” distintos

| Sitio | Fórmula | $10 de costo → |
|---|---|---|
| `classifyProductoMargen` → `calcPriceFloor` | markup sobre costo × 1.60 | **$16** |
| `margenMinimoSobreVentaPct` (Rappi) | 40% sobre venta en genérico | **~$16.67** |
| [`src/lib/recepcionAlta.js`](../src/lib/recepcionAlta.js) `MARGEN_ALTA_GENERICO = 60` + `precioDesdeMargen` | **60% sobre venta** = costo / 0.40 | **$25** |

Comentario literal de alta: “patente 25% / genérico 60% **sobre venta**”. Eso no es lo que el dueño describió (markup 60% sobre costo). Un alta desde Recibir nace ~56% más cara que el piso clásico.

60% markup = 37.5% margen real. 30% markup = 23.1% margen real. Ambos **brutos**, antes de merma, terminal (~2–3%) y descuentos POS.

---

## 3. Dos costos que no son intercambiables

| Campo | Semántica | Dónde |
|---|---|---|
| `producto_precios_referencia` fuente `ultima_compra` | Solo se pisa si el ticket **es más barato** | [`src/lib/ultimaCompra.js`](../src/lib/ultimaCompra.js) `debeReemplazarCompra`; hint en `FUENTE_META` |
| `productos.costo` | Recibir **siempre** lo pisa con `costo_estimado` | [`sql/patch_recibir_costo_manual_20260825.sql`](../sql/patch_recibir_costo_manual_20260825.sql) |
| Backfill tickets | `ORDER BY costo_estimado ASC` (el más barato) | [`sql/patch_completar_proveedor_tickets_20260824.sql`](../sql/patch_completar_proveedor_tickets_20260824.sql) |

La UI de comparación usa el mínimo histórico. El catálogo usa el último recibo. El margen que ves depende de cuál leas. El costo correcto para **precio de venta** es el de **reposición** (qué te costaría comprarlo hoy, neto de 13+1 / NC / flete). El mínimo histórico sirve para negociar, no para calcular piso.

---

## 4. El catálogo no contiene señal de mercado

Markup implícito (precio/costo − 1) sobre 626 SKUs:

| p25 | p50 | p75 | p95 |
|---|---|---|---|
| 30.0% | 41.4% | 60.0% | 60.1% |

350 SKUs en 28–45%, 183 en 55–65%. Bimodal, clavado en 1.30 y 1.60. Coincide con `docs/PRICING_DIAGNOSTICO.md` (ago-10): ~70% del catálogo de entonces estaba a recargo 60%. Las reglas SQL `sql/pricing/001–004` **no se aplicaron** (el doc lo dice).

Con refs locales (Similares 3-sep + Del Ahorro import) solo **70** SKUs del snapshot tienen alguna ref de venta. En **20** el piso teórico ya es mayor que `ceil(min * 0.98)` — ahí el mercado pide menos que tu fórmula. Hoy el sistema resuelve a favor del mercado y solo avisa.

Ejemplo: XL-3 Xtra C/12 — costo $36.26, precio $48.96 (35%), Similares $36, piso de regla genérico $59. Sugerido competitivo $36. `piso_gt_mercado = si`.

---

## 5. Reabasto ciego a demanda y a molécula

```javascript
// src/lib/reporteReabasto.js
export function cantidadSugerida(p) {
  const min = stockMinimoEfectivo(p);
  const base = Math.max(min * 3 - stockDe(p), 0);
  return Math.max(base, 1);
}
```

Default `stock_minimo` = 5. Tres labs de amoxicilina con 2 piezas disparan tres órdenes. “Dónde comprar” sí usa el mínimo entre listas B2B (`calcMejorTienda`), no el último costo — esa parte está bien. Falta el **techo de compra**: `precio_objetivo_compra = precio_mercado_sostenible / (1 + markup_objetivo)`.

No hay KVI ni GMROI en código. Solo el prompt en [`docs/PROMPT_CURSOR_RENTABILIDAD.md`](PROMPT_CURSOR_RENTABILIDAD.md).

---

## 6. Laboratorio y comparabilidad

`productos` tiene `marca`, `principio_activo`, `concentracion`, `forma_farmaceutica`, `denominacion_generica`. **No tiene `laboratorio`.** Las cargas hacen `marca = coalesce(marca, laboratorio)`.

Sin PA limpio + concentración no se agrupa por molécula. El precio de Similares “amoxicilina 500 mg” no se hereda a Maver / AMSA / Wandel. Comparar cajas distintas sin normalizar a tableta/mL/mg distorsiona. IVA: medicamentos tasa 0%; higiene/abarrote 16%. No hay columna `tasa_iva` llena.

---

## 7. Códigos de barras

Ver anexo. Resumen:

- 478/626 con código (76.4%).
- 110/148 vacíos tienen candidato **clave o EAN exacto** (Equilibrio `codigo_prov` = Levic `sku_externo`, o EAN de ticket Nadro/Levic/FarmaLive/etc.).
- 38 sin puente: IFC Mercurio/perillas, Farma MX basura de OCR, 3 claves Equilibrio que el portal Levic de ago-18 no trae.
- 30 prefijo `650` (interno). El “fix OCR” les puso dígito verificador; siguen sin matchear catálogos GS1.
- 8 checksum inválido, 9 de 8 dígitos, 1 GTIN-14, 7 EAN duplicados (17 SKUs). El DDL dice `UNIQUE`; el export tiene colisiones.

No aplicar candidatos en lote. Presentación distinta (caja vs FA) se marca en Levic por nombre; hay que mirar.

---

## 8. Qué falta para cerrar ítem por ítem

- Unidades vendidas 12 meses → [`scripts/exportar_ventas_sku.py`](../scripts/exportar_ventas_sku.py)
- Refs vigentes en BD → [`scripts/exportar_referencias_precio.py`](../scripts/exportar_referencias_precio.py)
- Catálogo fresco → [`scripts/exportar_catalogo_supabase.py`](../scripts/exportar_catalogo_supabase.py)

Sin ventas, cada SKU pesa igual. El que vende 400/mes y el que vende 2 entran al mismo promedio.
