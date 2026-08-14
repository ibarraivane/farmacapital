# Comparativa precios FarmaCapital — 563 productos activos
Generado: 2026-08-12

## Estado de datos de mercado
- **Similares / Del Ahorro en BD:** 0 productos (columnas vacías)
- **Exprezo (Zorro):** no integrado aún — columna `precio_exprezo` lista en CSV para llenar
- **Vista en app:** Admin → Promociones → «Precios vs competencia» (hoy sin referencias)

## Tu inventario (costo vs venta)
- Productos con costo y precio: **563**
- Margen bruto: min **12.7%** · mediana **29.6%** · promedio **31.0%** · max **97.4%**
- Margen &lt; 20%: **2** productos (revisar primero)

## Archivo completo
`sql/pricing/generated/comparativa_mercado_farmacapital.csv` — abrir en Excel/Numbers; filtrar y ordenar por `margen_bruto_pct`, `dif_vs_teorico_pct`, etc.

## Próximo paso Exprezo
1. Consultar precios en app Exprezo (membresía) o sucursal Zorro
2. Pegar en columna `precio_exprezo` del CSV (match por barcode o SKU)
3. Importar con script (podemos crear `importar_precios_exprezo.py`)
