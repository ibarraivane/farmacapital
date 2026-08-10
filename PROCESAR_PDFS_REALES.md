# 📄 PROCESAR PDFs REALES - Guía Práctica

## 🎯 Objetivo
Procesar los 7 PDFs de proveedores y cargar 500+ productos reales en Supabase.

**PDFs disponibles en:** `/Users/ibarra/Library/CloudStorage/Dropbox/FarmaCapital/Tickets/`

---

## 🚀 OPCIÓN A: Procesar con Backend (Recomendado - Cuando esté listo)

### Requisito
Agregar `ANTHROPIC_API_KEY` completa en `.env`:

```bash
# En /Users/ibarra/farmacapital/.env
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx
```

### Pasos
1. Guardar clave en `.env`
2. Ir a `/admin/inventario` → Tab "📄 Cargar PDF"
3. Arrastra o clickea para cargar cada PDF
4. ✓ Sistema procesa automáticamente con Claude Vision

---

## 🔄 OPCIÓN B: Script Python (Ahora - Sin dependencias)

### Ejecutar
```bash
cd /Users/ibarra/farmacapital

# Asegúrate que ANTHROPIC_API_KEY esté en ambiente
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx"

# Ejecutar script
python3 /private/tmp/claude-501/-Users-ibarra-farmacapital/2bc1a13d-77ea-40e3-893c-378d4042f961/scratchpad/procesar_pdfs.py
```

### Resultado
- Genera: `productos_extraidos.json`
- Contiene: Lista de productos extraídos
- Siguiente: Cargar JSON en Supabase

---

## 🗄️ OPCIÓN C: Carga Manual Directa (Más rápido)

### Para prueba rápida (2 productos):
```bash
# Ejecutar script de carga
bash /private/tmp/claude-501/-Users-ibarra-farmacapital/2bc1a13d-77ea-40e3-893c-378d4042f961/scratchpad/cargar_productos.sh
```

Esto carga 2 productos de prueba en Supabase.

---

## 🔧 OPCIÓN D: SQL Manual (Control total)

### 1. Obtener datos de PDFs
```python
# Usar script procesar_pdfs.py para extraer datos
# Genera: productos_extraidos.json
```

### 2. Convertir JSON → SQL
```bash
python3 << 'EOF'
import json

# Leer JSON
with open('productos_extraidos.json') as f:
    data = json.load(f)

# Generar SQL INSERT
sql = "INSERT INTO productos (sku, nombre, marca, ...) VALUES "
for p in data['productos']:
    sql += f"(...), "

print(sql)
EOF
```

### 3. Ejecutar en Supabase SQL Editor
```sql
-- Dashboard → SQL Editor → New Query
-- Pega el SQL generado
-- Click: RUN
```

---

## ⚠️ BLOQUEANTES ACTUALES

| Item | Status | Solución |
|------|--------|----------|
| ANTHROPIC_API_KEY | Truncada en .env | Reemplazar con clave completa |
| `/api/inventario/procesar-pdf.js` | Stub | Implementar conversión PDF→imágenes |
| `/api/ai/receta.js` | No existe | Crear para recetas médicas |

---

## 📋 PRÓXIMOS PASOS

### Hoy
- [ ] Obtener/copiar ANTHROPIC_API_KEY completa
- [ ] Ejecutar Script Python para procesar Bodega F-42.pdf
- [ ] Verificar productos en `productos_extraidos.json`
- [ ] Cargar en Supabase (OPCIÓN C o D)

### Esta semana
- [ ] Procesar 7 PDFs (1 min cada uno)
- [ ] Validar datos
- [ ] Optimizar campos críticos

### Mes 1
- [ ] Escaneo manual para productos sin QR
- [ ] Análisis de precios con SQL views
- [ ] Decisiones de compra informadas

---

## 🎓 ¿Cómo Funciona la Extracción?

### Flujo Automático (Opción A)
```
PDF → Conversión a imágenes → Claude Vision AI → JSON de productos → Supabase
```

### Datos Extraídos por Producto
```json
{
  "codigo": "7501090131234",      // Código de barras
  "nombre": "AMOXICILINA",        // Nombre expandido
  "marca": "FARMALAB",            // Fabricante
  "presentacion": "40 CAPSULAS",  // Normalizado
  "contenido": "500",             // Cantidad
  "unidad": "MG",                 // Unidad
  "cantidad": 2,                  // Cajas compradas
  "precio": 85.50,                // Precio unitario
  "caducidad": "2025-12-15",      // Vencimiento
  "lote": "A123456",              // Número de lote
  "proveedor": "Bodega F-42"      // Origen
}
```

---

## 🔗 Archivos Relevantes

```
/Users/ibarra/farmacapital/
├─ .env → ANTHROPIC_API_KEY (necesita completarse)
├─ src/modules/inventario/
│  ├─ InventarioModule.jsx
│  ├─ inventarioService.js
│  └─ inventario.css
├─ api/inventario/
│  └─ procesar-pdf.js (necesita implementación)
├─ sql/
│  ├─ schema_inventario.sql (V1)
│  └─ schema_inventario_v2_con_proveedores.sql (V2)
└─ docs/
   ├─ QUICK_START_INVENTARIO.md
   ├─ GUIA_INVENTARIO_MODULO.md
   └─ IMPLEMENTAR_V2_PASO_A_PASO.md
```

---

## 💡 Tips

- **Python Script está listo:** Usa OPCIÓN B para empezar hoy
- **No necesita backend:** El script Python es standalone
- **Prueba local:** Genera JSON local antes de cargar en BD
- **Reversible:** Los INSERT en Supabase pueden deletrearse si hay error

---

## 🆘 Troubleshooting

### Error: "ANTHROPIC_API_KEY not found"
```bash
# Solución
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Error: "PDF conversion failed"
```bash
# Verificar poppler-utils
which pdftoimage
brew install poppler  # Si no existe
```

### Error: "JSON parse error"
```bash
# Verificar archivo de salida
cat productos_extraidos.json | python3 -m json.tool
```

---

## 📞 Contacto

Si tienes dudas sobre el procesamiento, revisa:
1. GUIA_INVENTARIO_MODULO.md
2. RESUMEN_COMPLETO_INVENTARIO.md
3. Los logs en scratchpad/

**Estado: ✅ LISTO PARA PROCESAR**
