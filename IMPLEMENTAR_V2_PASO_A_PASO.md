# 🚀 IMPLEMENTAR V2 - PASO A PASO (20 MINUTOS)

**Objetivo:** Cambiar de sistema V1 (simple) a V2 (con análisis de precios entre proveedores)

---

## PASO 1: SUPABASE SQL (5 minutos)

### 1.1 Abre Supabase
```
https://supabase.com → Tu proyecto FarmaCapital
```

### 1.2 Ve a SQL Editor
```
Dashboard → SQL Editor → New Query
```

### 1.3 Copia TODO esto
```
Archivo: sql/schema_inventario_v2_con_proveedores.sql
← Copiar COMPLETO
```

### 1.4 Pega en Supabase
```
Click en SQL Editor
Paste (Ctrl+V)
Click ▶️ RUN
```

**Resultado esperado:**
```
✓ Query executed successfully
✓ Creadas tablas: productos_v2, ofertas_proveedor, lotes_v2, movimientos_v2
✓ Creadas vistas: vw_mejor_precio, vw_comparativa_precios
```

❌ Si da error de "RLS policy denied":
```
→ Ve a Authentication → Policies
→ Desactiva temporalmente RLS en estas tablas
→ Vuelve a ejecutar SQL
→ Reactiva RLS después
```

---

## PASO 2: CÓDIGO REACT (NO NECESITA CAMBIOS)

El componente `InventarioModule.jsx` que ya creamos **funciona con ambas versiones**.

✓ Ya está listo para V2
✓ No hay que cambiar nada
✓ Los mismos 3 tabs funcionan igual

---

## PASO 3: PROCESAR PDFS (10 minutos)

### Opción A: Automática (Recomendado)

```
1. Abre http://localhost:3000/admin/inventario
2. Tab "Cargar PDF"
3. Arrastra: Bodega F-42.pdf
   → Espera 2-3 seg
   → ✓ Preview muestra ~100-200 productos
   → Click "Procesar PDF"
4. Repite para cada PDF:
   ├─ Equilibrio.pdf
   ├─ IFC 1.pdf
   ├─ IFC 2.pdf
   ├─ Farma Mx.pdf
   ├─ El surtidor...pdf
   └─ FarmaLive.pdf

⏱️ 1 minuto por PDF × 7 = ~7 minutos TOTAL
```

### Opción B: Manual (Si PDFs fallan)

```
python3 /Users/ibarra/farmacapital/scripts/extraer_productos_de_pdfs.py

Esto genera:
├─ PRODUCTOS_EXTRAIDOS.xlsx (Excel para revisar)
└─ SQL script con INSERT de todos los productos
```

---

## PASO 4: REVISAR DATOS (5 minutos)

### Descargar Excel de revisión
```
Archivo: PRODUCTOS_EXTRAIDOS.xlsx (si lo generaste)
```

### Verificar campos críticos
```
Abrir en Excel y revisar:

1. NOMBRE
   ✓ Completo: "AMOXICILINA 500 MG"
   ✓ NO abreviado: "AMOX 500"

2. PRESENTACION
   ✓ Expandido: "40 CAPSULAS"
   ✓ NO abreviado: "40 CAPS"

3. CONTENIDO / CONTENIDO_UNIDAD
   ✓ Separado: "500" | "MG"
   ✓ NO junto: "500MG"

4. CANTIDAD
   ✓ Número de unidades compradas
   ✓ Ej: Compraste 2 cajas → CANTIDAD=2

5. PRECIO_UNITARIO
   ✓ Precio por caja/unidad comprada
   ✓ Si pagaste $90 por 2 cajas → $45 unitario

6. PROVEEDOR
   ✓ Consistente: "Bodega F-42" (siempre igual)

7. CATEGORIA
   ✓ Automática pero revisar si está correcta
   ✓ "AMOXICILINA" debe ser "ANTIBIÓTICOS"
```

### Corregir si es necesario
```
Edita las columnas problemáticas
Guarda Excel
Re-carga si cambios son mayores (>10%)
```

---

## PASO 5: VERIFICAR EN BD (2 minutos)

### Abre Supabase SQL Editor

```sql
-- Ver productos cargados
SELECT COUNT(*) FROM productos_v2;
-- Resultado: debería tener ~500-800 productos

-- Ver ofertas de proveedores
SELECT 
  proveedor,
  COUNT(*) as num_productos,
  ROUND(AVG(precio_unitario), 2) as precio_promedio
FROM ofertas_proveedor
GROUP BY proveedor;

-- Resultado: Tabla de proveedores con precios
```

### Ver comparativas
```sql
-- Productos con más de un proveedor
SELECT * FROM vw_comparativa_precios
WHERE num_proveedores > 1
ORDER BY % diferencia DESC
LIMIT 10;

-- Resultado: Medicamentos donde puedes ahorrar
```

---

## PASO 6: INTEGRAR EN ADMIN (SIN CAMBIOS)

El Admin Panel ya tiene integrado:
```
✓ /admin/inventario
✓ 3 tabs (Escaneo Manual, Existente, PDF)
✓ Funciona con V2 automáticamente
```

**Nada que cambiar.** Se usa igual.

---

## ✅ CHECKLIST

- [ ] SQL V2 ejecutado en Supabase
- [ ] Tablas creadas: productos_v2, ofertas_proveedor, lotes_v2
- [ ] Vistas creadas: vw_mejor_precio, vw_comparativa_precios
- [ ] 7 PDFs procesados (~500-800 productos)
- [ ] Datos revisados en Excel
- [ ] Query SQL verifica productos: ~500-800
- [ ] Query SQL verifica comparativas de precio
- [ ] /admin/inventario funciona (abre sin errores)

---

## 🎯 QUÉ PUEDES HACER AHORA

### 1. Ver mejor precio de cada medicamento
```sql
SELECT * FROM vw_mejor_precio
WHERE precio_rank = 1  -- Solo el más barato
ORDER BY nombre
LIMIT 20;
```

**Resultado:**
```
AMOXICILINA 500mg
  Mejor precio: $42.00 en Equilibrio (01/08/2026)

CEFALEXINA 500mg
  Mejor precio: $91.00 en Bodega F-42 (02/08/2026)
```

### 2. Comparar proveedores
```sql
SELECT * FROM vw_comparativa_precios
WHERE precio_maximo - precio_minimo > 5
ORDER BY % diferencia DESC;
```

**Resultado:** Medicamentos donde cambiar proveedor ahorra dinero

### 3. Análisis de ahorro
```sql
SELECT
  nombre,
  ROUND(precio_minimo, 2) as comprar_aca,
  ROUND(precio_maximo, 2) as no_aca,
  ROUND(precio_maximo - precio_minimo, 2) as ahorras_por_unidad
FROM vw_comparativa_precios
WHERE precio_maximo > precio_minimo
ORDER BY (precio_maximo - precio_minimo) DESC;
```

---

## 🔄 WORKFLOW FUTURO (DESPUÉS)

### Para próxima compra en Bodega F-42

```
1. Recibes ticket
2. Foto o PDF del ticket
3. /admin/inventario → Tab "Cargar PDF"
4. Arrastra foto/PDF
5. Click "Procesar PDF"
6. ✓ Automáticamente:
   ├─ Actualiza stock
   ├─ Registra nuevo precio
   ├─ Crea lotes con caducidades
   └─ Sistema sabe dónde compraste
```

### Comparar antes de comprar

```
Antes de hacer nueva compra:

1. Abre Supabase Query Editor
2. Corre:
   SELECT * FROM vw_comparativa_precios
   WHERE nombre LIKE '%AMOXICILINA%';

3. Ve precios actuales de todos los proveedores
4. Decide dónde comprar
5. Potencial ahorro: 10-20%
```

---

## ⚠️ TROUBLESHOOTING

### ❌ Error: "Tabla productos_v2 no existe"
**Solución:** Re-ejecuta SQL V2 en Supabase

### ❌ Error: "RLS policy denied"
**Solución:**
```
Dashboard → Authentication → Policies
Desactiva RLS temporalmente
Ejecuta SQL
Reactiva RLS
```

### ❌ Error: "violates unique constraint"
**Solución:** Ya existe un producto con ese código
```
→ Update en lugar de Insert
→ O deletea duplicados primero
```

### ❌ /admin/inventario da error
**Solución:**
```
1. Reinicia servidor: npm start
2. Limpia caché: Ctrl+Shift+R
3. Si persiste: Revisa DevTools (F12)
```

---

## 📊 RESULTADO FINAL

Después de implementar V2, tendrás:

```
✅ 500-800 PRODUCTOS
   └─ Con código de barras, nombre, marca, presentación
   └─ Categorización automática

✅ HISTÓRICO DE PRECIOS
   └─ Sabes cuánto cuesta en cada proveedor
   └─ Cambios de precio a lo largo del tiempo

✅ ANÁLISIS DE PROVEEDORES
   └─ Quién tiene mejor precio
   └─ Potencial ahorro: 10-20% en compras

✅ AUDITORÍA COMPLETA
   └─ Cada compra registrada
   └─ Cada proveedor identificado
   └─ Cada caducidad registrada

✅ STOCK EN TIEMPO REAL
   └─ Por lote
   └─ Por proveedor
   └─ Por caducidad próxima
```

---

## 🎉 ¡LISTO!

Tu sistema ahora es **profesional, auditable y optimizado para ahorrar dinero**.

**Tiempo total:** ~20 minutos
**Beneficio:** Decisiones de compra informadas + Ahorros significativos

🚀 Adelante con FarmaCapital V2
