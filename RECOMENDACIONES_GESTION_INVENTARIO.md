# 🎯 RECOMENDACIONES - Gestión Profesional de Inventario

**Para FarmaCapital:** Sistema de múltiples proveedores con análisis de precios

---

## 📊 ARQUITECTURA RECOMENDADA

### Problema Actual
```
❌ Un producto en varios proveedores
   ├─ Bodega F-42: AMOXICILINA 500mg → $45.00
   ├─ Equilibrio: AMOXICILINA 500mg → $42.00
   └─ IFC: AMOXICILINA 500mg → $48.00
   
❌ No se puede comparar fácilmente
❌ No se rastrea histórico de precios
❌ No se sabe dónde comprar más barato
```

### Solución Implementada
```
✅ Tabla PRODUCTOS_V2: Un registro único por medicamento
   └─ Código de barras, nombre, marca, presentación

✅ Tabla OFERTAS_PROVEEDOR: Historial de precios
   ├─ Precio por proveedor y fecha
   ├─ Permite rastrear cambios
   └─ Identifica mejores fuentes

✅ Tabla LOTES_V2: Inventario real
   ├─ Cantidad por lote y proveedor
   └─ Caducidades

✅ Vista VW_COMPARATIVA_PRECIOS: Dashboard de análisis
   ├─ Precio mínimo/máximo
   ├─ % de diferencia
   └─ Proveedores disponibles
```

**Resultado:**
```sql
SELECT * FROM vw_comparativa_precios 
WHERE nombre LIKE '%AMOXICILINA%';

┌─────────────────────────────────────────────────────────────┐
│ nombre         │ precio_min │ precio_max │ % diferencia    │
├─────────────────────────────────────────────────────────────┤
│ AMOXICILINA    │ $42.00     │ $48.00     │ 14.3%           │
│ Proveedores    │ Equilibrio │ IFC        │ Compra en 42   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 CAMPOS QUE DEBES REVISAR/LLENAR

### 1. CÓDIGO DE BARRAS (QR)
```
STATUS: ⚠️ CRÍTICO - Necesario para POS

❌ Si NO tiene QR en ticket:
   → Déjalo vacío
   → Escanea manualmente cuando llegue producto
   → Actualiza en PRODUCTOS_V2.codigo_barras

✅ Si está en ticket:
   → Cópialo exactamente
   → Será clave para búsquedas rápidas
```

### 2. NOMBRE DEL PRODUCTO
```
STATUS: ✅ DEDUCIBLE

ANTES:     "AMOX 500MG 40C"
DESPUÉS:   "AMOXICILINA 500 MILIGRAMOS 40 CAPSULAS"

Scripts busca:
├─ Abreviaturas comunes (CAPS→CAPSULAS, MG→MILIGRAMOS)
├─ Nombres conocidos de medicamentos
└─ Deduce presentación completa
```

### 3. MARCA
```
STATUS: ✅ EXTRAÍDO DE TICKET

IMPORTANTE:
├─ Normalizar mayúsculas: "farmalab" → "FARMALAB"
├─ Eliminar espacios extra
└─ Si no está, dejar vacío (algunos genéricos no tienen marca)

IMPACTO: Facilita búsquedas por marca en tienda
```

### 4. PRESENTACIÓN (CRITICAL)
```
STATUS: ✅ AUTO-NORMALIZADO

FORMATOS A DEDUCIR:
├─ "40 CAPS"        → "40 CAPSULAS"
├─ "500 ML"         → "500 MILILITROS"
├─ "30 COMP"        → "30 COMPRIMIDOS"
├─ "1 FRASCO"       → "1 FRASCO"
└─ "30 SOL INYECT"  → "30 SOLUCIÓN INYECTABLE"

IMPACTO:
├─ Usuarios ven presentación clara
├─ Búsquedas funcionan mejor
└─ Comparativas de precio por presentación

VERIFICAR MANUALMENTE:
❌ Si dice "40" pero en PDF pone "60"
❌ Si pone "CAPS" pero debería ser "ML" (error scanner)
```

### 5. CONTENIDO (VERY IMPORTANT)
```
STATUS: ✅ AUTO-NORMALIZADO EN NÚMERO + UNIDAD

DETALLES SEPARADOS:
├─ Número: 500 (se guarda como DECIMAL)
├─ Unidad: MG (se guarda por separado)
└─ Visión: "500 MG"

IMPACTO: Permite comparar precios por miligramo/gramo
├─ Si cuesta $42 por 500mg → $0.084 por mg
├─ Si cuesta $45 por 500mg → $0.090 por mg
└─ Bodega F-42 es más barato (aunque dice precio mayor)

CASOS ESPECIALES:
├─ "1%" → (1, PORCIENTO)
├─ "7.48 G" → (7.48, GRAMOS)
├─ "250 MG/5 ML" → (250, MG/ML) ← debes revisar esto
```

### 6. CANTIDAD
```
STATUS: ✅ VERIFICABLE

DEFINICIÓN:
├─ CANTIDAD = Unidades compradas en este ticket
├─ Ej: Compraste 2 cajas de AMOXICILINA → CANTIDAD = 2
├─ Ej: Compraste 5 frascos de jarabe → CANTIDAD = 5

RIESGO COMÚN:
❌ Confundir con cantidad por caja/presentación
❌ Ej: "40 CAPS por caja, compraste 2 cajas"
    → CANTIDAD debe ser 2 (2 cajas)
    → PRESENTACIÓN debe ser "40 CAPSULAS"
    → NO es "80 CAPSULAS"

VERIFICAR EN TICKET:
├─ Busca la línea de cantidad/units
├─ Si dice "2 x $45", CANTIDAD = 2
├─ Si dice "Caja 40 CAPS", CANTIDAD = 1
```

### 7. PRECIO
```
STATUS: ✅ AUTO-EXTRAÍDO

DOS CAMPOS:
├─ PRECIO_UNITARIO = Precio por unidad comprada
│  (Si compraste 2 cajas a $45 cada una → $45)
│
└─ PRECIO_TOTAL = Precio total de la línea
   (Si compraste 2 cajas a $45 → $90 total)

VERIFICAR:
├─ Si dice "2 x $45", PRECIO_UNITARIO = $45
├─ Si dice "3 x $42", PRECIO_UNITARIO = $42
└─ Si total está mal calculado, corrígelo

IMPACTO: Historial de precios
├─ Bodega F-42 el 01/08: $45.00
├─ Equilibrio el 05/08: $42.00
├─ Bodega F-42 el 15/08: $46.00 (subió)
└─ Decisión: Comprar en Equilibrio
```

### 8. CATEGORÍA (AUTO-DEDUCIDA)
```
STATUS: ✅ AUTO-DEDUCIDA, REVISABLE

ALGORITMO:
1. Busca palabras clave en nombre del producto
2. Si tiene "AMOXICILINA" → ANTIBIÓTICOS
3. Si tiene "IBUPROFENO" → ANALGÉSICOS
4. Si no coincide → GENERAL

CATEGORÍAS DISPONIBLES:
├─ ANTIBIÓTICOS
├─ ANALGÉSICOS
├─ ANTIINFLAMATORIOS
├─ DIGESTIVOS
├─ VITAMINAS
├─ ANTIHISTAMÍNICOS
├─ DERMATOLOGÍA
├─ ENDOCRINOLOGÍA
├─ GENERAL
└─ OTROS

IMPACTO:
├─ Filtros en POS
├─ Estadísticas por categoría
└─ Organización visual

REVISAR SI:
├─ Un "CLOTRIMAZOL" está como GENERAL (debe ser DERMATOLOGÍA)
├─ Un "OMEPRAZOL" está como GENERAL (debe ser DIGESTIVOS)
```

### 9. PROVEEDOR (CRITICAL)
```
STATUS: ✅ IDENTIFICADO DE ARCHIVO

ACTUAL:
├─ Bodega F-42
├─ Equilibrio Farmaceútico
├─ IFC
├─ Farma Mx
├─ El Surtidor de Su Farmacia
├─ FarmaLive
└─ (agregar más según necesites)

IMPACTO:
├─ Sabes dónde comprar cada producto
├─ Histórico de ofertas por proveedor
├─ Análisis de "si cambio proveedor, ahorro X%"

IMPORTANTE:
└─ Mantener nombres CONSISTENTES
   ├─ NO "BODEGA-F42", "Bodega F-42", "BODEGA F 42"
   ├─ SÍ siempre "Bodega F-42"
   └─ Esto permite agrupar correctamente
```

---

## 💰 ANÁLISIS DE PRECIOS (LO MÁS IMPORTANTE)

### Caso de Uso Real

```sql
-- Ver todos los medicamentos ordenados por ahorro potencial

SELECT
  nombre,
  ROUND(precio_minimo, 2) as precio_mas_barato,
  ROUND(precio_maximo, 2) as precio_mas_caro,
  ROUND(precio_maximo - precio_minimo, 2) as diferencia,
  ROUND(((precio_maximo - precio_minimo) / precio_minimo * 100), 1) as % ahorro,
  proveedores
FROM vw_comparativa_precios
ORDER BY diferencia DESC
LIMIT 10;

RESULTADO:
┌─────────────────────────────────────────────────────────────┐
│ nombre            │ min    │ max    │ dif  │ % ahorro      │
├─────────────────────────────────────────────────────────────┤
│ CEFALEXINA 500mg  │ $91.00 │ $102   │ $11  │ 12.1% (!!!)   │
│ AMOXICILINA 500mg │ $42.00 │ $48.00 │ $6   │ 14.3%         │
│ IBUPROFENO 200mg  │ $15.00 │ $18.00 │ $3   │ 20.0%         │
└─────────────────────────────────────────────────────────────┘

CONCLUSIÓN: Si compras en Bodega F-42 (más caro) en lugar de
Equilibrio (más barato), pierdes 12-20% en cada medicamento
frecuente. POTENAL AHORRO ANUAL: $5,000+ (estimado)
```

### Dashboard Recomendado

```sql
-- Cada semana, generar reporte:

SELECT
  proveedor,
  COUNT(DISTINCT producto_id) as num_productos,
  ROUND(AVG(precio_unitario), 2) as precio_promedio,
  ROUND(MIN(precio_unitario), 2) as producto_mas_barato,
  MAX(fecha_compra) as ultima_compra
FROM ofertas_proveedor
WHERE fecha_compra >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY proveedor
ORDER BY precio_promedio ASC;

RESULTADO: Ve qué proveedor en promedio es más barato
```

---

## 🔄 WORKFLOW RECOMENDADO

### 1. INGRESO INICIAL (HOY)
```
1. Procesar 7 PDFs en /admin/inventario
   └─ Cada uno: Cargar PDF → Preview → Procesar
2. Esto crea:
   └─ ~500-800 productos en BD
   └─ Histórico de precios de compra
   └─ Stock actual por proveedor

⏱️ Tiempo: ~10 minutos
```

### 2. REVISIÓN DE DATOS (HOY O MAÑANA)
```
1. Descargar Excel generado: PRODUCTOS_EXTRAIDOS.xlsx
2. Revisar campos problemáticos:
   ├─ Códigos de barras vacíos → Escanear luego
   ├─ Presentaciones raras → Corregir
   ├─ Categorías mal asignadas → Ajustar
   └─ Precios inconsistentes → Verificar
3. Guardar cambios
4. Re-cargar a BD si hubo cambios grandes

⏱️ Tiempo: ~30-60 minutos
```

### 3. ESCANEO MANUAL (GRADUAL)
```
Para productos SIN QR:

1. Cada vez que llega un producto sin código:
   └─ Escanea con dispositivo/app
   └─ Actualiza en Admin → Inventario → Buscar → Actualizar
   └─ O escanea manualmente desde Tab "Escaneo Manual"

2. Esto llena GRADUALMENTE los códigos de barras
   └─ No es urgente (puedes comprar sin QR)
   └─ Pero acelera checkout en POS

⏱️ Tiempo: 30 seg por producto
```

### 4. ACTUALIZACIONES FUTURAS
```
Para cada nueva compra:

OPCIÓN A (Recomendada): Con QR
├─ Foto del ticket
├─ /admin/inventario → Tab "Cargar PDF"
├─ Automático
└─ 1 minuto

OPCIÓN B: Sin QR
├─ Tab "Escaneo Manual" producto por producto
├─ O Tab "Producto Existente" si ya existe
└─ 2 minutos

OPCIÓN C: Escaneo en POS
├─ Cuando vendes, si código QR existe
├─ Automáticamente actualiza stock
├─ Sin hacer nada adicional
└─ 0 minutos
```

---

## ✅ CHECKLIST DE NORMALIZACIÓN

Antes de cargar datos a BD, verificar:

### Campos Críticos
- [ ] Nombre: Capitalizado y completo
- [ ] Presentación: Expandido (CAPS→CAPSULAS)
- [ ] Contenido: Número + unidad separados
- [ ] Cantidad: Coincide con unidades compradas
- [ ] Precio: Números reales del ticket
- [ ] Proveedor: Nombre consistente

### Campos Opcionales
- [ ] Código de barras: Si está, exacto; si no, vacío
- [ ] Marca: Normalizado; si no tiene, vacío
- [ ] Categoría: Deducida correctamente

### Validaciones
- [ ] No hay duplicados (mismo producto en lista 2x)
- [ ] Precios coherentes (no 0 ni negativos)
- [ ] Fechas válidas (entre 2020-2026)

---

## 🎯 BENEFICIOS FINALES

Con esta estructura:

```
✅ COMPRAS INTELIGENTES
   └─ Comparar precio real entre proveedores
   └─ Ahorrar 10-20% comprando en lugar correcto

✅ AUDITORÍA COMPLETA
   └─ Saber dónde compraste cada producto
   └─ Fecha exacta de compra
   └─ Precio que pagaste

✅ ANÁLISIS RÁPIDO
   └─ "¿Cuál es mi medicamento más vendido?"
   └─ "¿Qué categoría da más ganancia?"
   └─ "¿Cambió el precio de X proveedor?"

✅ PREPARADO PARA ESCALA
   └─ Agregar más proveedores
   └─ Integrar con compras automáticas
   └─ Análisis predictivo (demanda, rotación)
```

---

## 📞 PRÓXIMOS PASOS

### Hoy
1. [ ] Ejecutar SQL V2 en Supabase
2. [ ] Procesar 7 PDFs en /admin/inventario
3. [ ] Revisar/corregir datos en Excel

### Esta Semana
4. [ ] Escanear productos sin QR
5. [ ] Validar que precios coinciden con facturas
6. [ ] Pruebas en POS

### Este Mes
7. [ ] Análisis de "mejor proveedor"
8. [ ] Negociar con proveedores (datos reales)
9. [ ] Optimizar compras mensuales

---

**Sistema listo para producción y análisis profesional.** 🚀
