# 📦 MÓDULO DE INVENTARIO - Guía de Integración

Sistema completo de 3 flujos para ingreso de productos farmacéuticos.

---

## 🎯 FLUJOS INCLUIDOS

### 1️⃣ **Escaneo Manual** 
- Escanea código de barras
- Carga todos los detalles del producto (nuevo)
- Genera SKU automático
- Crea lote con caducidad
- Perfecto para: productos nuevos, auditoría física

### 2️⃣ **Producto Existente**
- Escanea código de barras
- Si existe: solo pide cantidad + caducidad + lote
- Actualiza stock automáticamente
- Perfecto para: reabastecimiento, compras recurrentes

### 3️⃣ **PDF del Proveedor**
- Carga PDF de ticket/factura
- Claude Vision lee automáticamente
- Extrae: nombre, marca, cantidad, precio, código
- Preview antes de confirmar
- Carga en lote todos los productos
- Perfecto para: procesar compras masivas, ticket digital

---

## 📂 ARCHIVOS CREADOS

```
src/
├── modules/
│   └── inventario/
│       ├── InventarioModule.jsx    ← Componente React
│       └── inventario.css           ← Estilos
│
api/
└── inventario.js                   ← Backend APIs

sql/
└── schema_inventario.sql           ← Tablas + funciones

GUIA_INVENTARIO_MODULO.md          ← Este archivo
```

---

## ⚙️ INTEGRACIÓN PASO A PASO

### 1. BASE DE DATOS (Supabase)

Abre **Supabase Dashboard** → **SQL Editor** → New Query:

```sql
-- Copia TODO el contenido de sql/schema_inventario.sql
-- Pégalo aquí y ejecuta (Click ▶️)
```

Esto crea:
- ✅ Tabla `productos` (catálogo maestro)
- ✅ Tabla `lotes` (caducidades)
- ✅ Tabla `movimientos_inventario` (auditoría)
- ✅ Función `create_producto_with_lote()`
- ✅ Triggers para actualizar stock automáticamente
- ✅ Row Level Security (RLS) para permisos

---

### 2. DEPENDENCIAS (Claude AI SDK)

Instala el SDK de Anthropic para Claude Vision:

```bash
npm install @anthropic-ai/sdk
```

**¿Por qué?** El módulo lee PDFs con Claude Vision AI y extrae productos automáticamente.

---

### 3. FRONTEND (React)

Ya está integrado en **Admin.jsx**:

- ✅ Importado con lazy loading
- ✅ Agregado a rutas en `shared/adminRoutes.js`
- ✅ Disponible en `/admin/inventario`

No necesitas hacer nada más en React.

---

## 🚀 CÓMO USAR

### Desde Admin Panel

1. **Navega a**: `/admin/inventario`
   - O desde el menú lateral → Inventario → Ingreso de Productos

2. **Elige flujo según necesidad**:

   **Tab "Escaneo Manual"** → Producto nuevo
   - Escanea código
   - Llena: nombre, marca, presentación, contenido, precio, cantidad, caducidad, lote
   - Click "Guardar Producto"

   **Tab "Producto Existente"** → Reabastecimiento
   - Escanea código
   - Sistema busca automáticamente
   - Llena: cantidad adicional, caducidad, lote
   - Click "Confirmar + Actualizar Stock"

   **Tab "Cargar PDF"** → Compra en lote
   - Carga PDF del ticket/factura
   - Espera a Claude Vision (2-3 seg)
   - Revisa preview de productos detectados
   - Click "Procesar PDF"

---

## 🔌 FUNCIONES DEL SERVICIO

El módulo usa **funciones Supabase** directamente (RPC + queries):

### `crearNuevoProducto(datos)`
Crea un nuevo producto con lote automático usando `create_producto_with_lote()` RPC.

**Parámetros:**
```javascript
{
  codigo_barras: "7509552933307",
  nombre: "AMOXICILINA 500MG",
  marca: "FARMALAB",
  presentacion: "40 CAPS",
  contenido: "500MG",
  unidad: "UNIT",
  precio: 45.00,
  cantidad: 5,
  caducidad: "2028-12-31",
  lote: "LOTE-2028-001",
  categoria: "ANTIBIÓTICOS",
  proveedor: "EQUILIBRIO FARMACEÚTICO"
}
```

**Respuesta:**
```javascript
{
  success: true,
  producto: { id, sku, nombre, ... },
  mensaje: "Producto AMOXICILINA 500MG creado exitosamente"
}
```

---

### `buscarProducto(codigo_barras)`
Busca si un producto ya existe.

**Respuesta:**
```javascript
{
  existe: true,
  producto: { id, nombre, marca, stock, precio, ... }
}
```

---

### `actualizarStock(datos)`
Actualiza stock de producto existente creando nuevo lote.

**Parámetros:**
```javascript
{
  codigo_barras: "7509552933307",
  cantidad_adicional: 10,
  caducidad: "2028-12-31",
  lote: "LOTE-2028-002"
}
```

**Respuesta:**
```javascript
{
  success: true,
  producto: { ...actualizado },
  nuevo_stock: 15,
  mensaje: "Stock actualizado: 15 unidades"
}
```

---

### `procesarPDF(base64Data, proveedor)`
Lee PDF con Claude Vision y carga productos automáticamente.

**Parámetros:**
```javascript
await procesarPDF(base64, 'EQUILIBRIO FARMACEÚTICO')
```

**Respuesta:**
```javascript
{
  success: true,
  total_procesados: 47,
  productos: [ { ...cada producto }, ... ],
  mensaje: "47 productos cargados desde PDF"
}
```

---

## 🔑 VARIABLES DE ENTORNO

En tu `.env`:

```
ANTHROPIC_API_KEY=sk-ant-...  # Para Claude Vision PDF
```

---

## 📊 BASE DE DATOS - Estructura

### Tabla `productos`
```
id (PK)
sku (UNIQUE)
nombre
marca
codigo_barras (UNIQUE)
categoria
presentacion
contenido
unidad
precio
costo
stock (calculado desde lotes)
proveedor
requiere_receta
activo
visible_tienda
created_at
updated_at
```

### Tabla `lotes`
```
id (PK)
producto_id (FK → productos)
numero_lote
cantidad_inicial
cantidad_actual
fecha_caducidad
costo_unitario
activo
created_at
updated_at
```

### Tabla `movimientos_inventario`
```
id (PK)
producto_id (FK → productos)
tipo ('entrada', 'salida', 'ajuste', 'devolución')
cantidad
motivo
usuario_id
documento_referencia
created_at
```

---

## ✅ CHECKLIST INTEGRACIÓN

- [ ] Ejecuté `sql/schema_inventario.sql` en Supabase
- [ ] Instalé `@anthropic-ai/sdk`: `npm install @anthropic-ai/sdk`
- [ ] Configuré `.env` con `ANTHROPIC_API_KEY` (necesaria para Claude Vision)
- [ ] Guardé cambios: `git add -A && git commit -m "feat: módulo de inventario completo"`
- [ ] Probé acceso a `/admin/inventario` 
- [ ] Intenté escanear un producto (Flujo Manual) → debería crear producto
- [ ] Intenté reabastecimiento (Flujo Existente) → debería actualizar stock
- [ ] Cargué un PDF de proveedor (Flujo PDF) → debería procesar 40+ productos

---

## 🐛 TROUBLESHOOTING

### ❌ Error: "Tabla productos no existe"
**Solución:**
1. Abre Supabase Dashboard
2. Vé a SQL Editor
3. Crea Nueva Query
4. Copia TODO el contenido de `sql/schema_inventario.sql`
5. Ejecuta (click ▶️)

### ❌ Error: "Auth.uid() returned null" o RLS issue
**Solución:**
- Las RLS policies permitirán acceso sin autenticación para SELECT
- Si el usuario no está logueado, asegúrate de que las policies en Supabase lo permitan
- O simplemente desactiva temporalmente RLS si es entorno de desarrollo

### ❌ Error al procesar PDF: "ANTHROPIC_API_KEY no configurada"
**Solución:**
1. En `.env.local` (desarrollo) o `.env` (producción), agrega:
   ```
   REACT_APP_ANTHROPIC_API_KEY=sk-ant-...
   ```
2. O en Backend si usas servidor Node:
   ```
   ANTHROPIC_API_KEY=sk-ant-...
   ```
3. Reinicia servidor de desarrollo: `npm start`

### ❌ Error: "No se pudo extraer JSON de la respuesta" (PDF)
**Solución:**
- El PDF debe ser legible (texto, no imagen escaneada)
- Foto de ticket físico funciona bien
- Prueba con PDF simple primero
- Si es escaneo antiguo, OCR puede no funcionar

### ❌ Stock no se actualiza correctamente
**Verificación:**
1. Abre Supabase → SQL Editor
2. Corre: `SELECT * FROM lotes WHERE producto_id = XXX;`
3. Verifica que los lotes se crearon
4. Los triggers automáticos deben actualizar `productos.stock`
5. Si no funciona, ejecuta manualmente:
   ```sql
   UPDATE productos 
   SET stock = (SELECT COALESCE(SUM(cantidad_actual), 0) FROM lotes WHERE producto_id = id AND activo = true)
   WHERE id = XXX;
   ```

### ❌ "Producto no encontrado" al escanear (Flujo Existente)
**Solución:**
- El código de barras debe existir exactamente igual en BD
- Sin espacios ni caracteres extras
- Prueba primero con "Escaneo Manual" para crear el producto
- Usa el mismo código que aparece en sistema

### ❌ Módulo no aparece en Admin
**Verificación:**
1. Abre `/admin/inventario` en navegador
2. Si error 404, verifica `adminRoutes.js` tiene `inventario: "inventario"`
3. Verifica `Admin.jsx` tiene `case "inventario": return <InventarioModule />`
4. Reinicia servidor: `npm start`

---

## 🎓 EJEMPLOS DE USO

### Ejemplo 1: Añadir nuevo medicamento
```
1. Click "Escaneo Manual"
2. Escanea: 7509552933307
3. Nombre: AMOXICILINA 500MG
4. Marca: FARMALAB
5. Presentación: 40 CAPS
6. Cantidad: 5
7. Precio: 45.00
8. Caducidad: 31/12/2028
9. Lote: LOTE-2028-001
10. Click "Guardar Producto"
→ Producto creado ✓
```

### Ejemplo 2: Reabastecimiento de producto existente
```
1. Click "Producto Existente"
2. Escanea: 7509552933307
→ Sistema encuentra: AMOXICILINA 500MG (Stock: 5)
3. Cantidad adicional: 10
4. Caducidad: 30/06/2029
5. Lote: LOTE-2029-001
6. Click "Confirmar + Actualizar Stock"
→ Stock actualizado: 15 unidades ✓
```

### Ejemplo 3: Cargar ticket en PDF
```
1. Click "Cargar PDF"
2. Arrastra ticket.pdf o selecciona archivo
→ Claude Vision lee y extrae 47 productos
→ Preview muestra: AMOXICILINA, CEFALEXINA, IBUPROFENO...
3. Revisa que esté correcto
4. Click "Procesar PDF"
→ 47 productos cargados ✓
```

---

## 📞 SOPORTE

Si hay problemas:

1. Verifica **logs de Supabase**: Dashboard → Logs
2. Verifica **logs del servidor**: `npm start` output
3. Abre **DevTools** (F12) → Console para errores JS
4. Comprueba que `.env` tiene `ANTHROPIC_API_KEY`

---

## 🎉 ¡LISTO!

Tu módulo de inventario está operativo. Puedes empezar a:
- ✅ Escanear productos uno a uno
- ✅ Actualizar stock de existentes
- ✅ Cargar compras en PDF automáticamente

¡Adelante con FarmaCapital! 🚀
