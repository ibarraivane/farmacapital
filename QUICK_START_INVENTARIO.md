# ⚡ QUICK START - Módulo Inventario (5 minutos)

## 1️⃣ SUPABASE SQL (1 minuto)

**Abre:** https://supabase.com → Tu proyecto → SQL Editor → New Query

**Copia TODA esta línea y pégala:**
```
click en sql/schema_inventario.sql → copiar TODO
```

**Pega en Supabase y ejecuta (▶️)**

✓ Hecho. Tablas creadas automáticamente.

---

## 2️⃣ INSTALAR LIBRERÍA (1 minuto)

```bash
cd /Users/ibarra/farmacapital
npm install @anthropic-ai/sdk
```

✓ Listo.

---

## 3️⃣ CONFIGURAR API KEY (1 minuto)

**Obtén tu API key de Claude:**  
1. Ve a: https://console.anthropic.com
2. Copia tu key (empieza con `sk-ant-`)

**En `.env` o `.env.local`:**
```
REACT_APP_ANTHROPIC_API_KEY=sk-ant-v...
```

✓ Guardado.

---

## 4️⃣ REINICIAR SERVIDOR (1 minuto)

```bash
npm start
```

Espera a que compile...

---

## 5️⃣ PROBAR (1 minuto)

**Abre navegador:**
```
http://localhost:3000/admin/inventario
```

¿Ves las 3 tabs? 
- 🔍 Escaneo Manual
- ✓ Producto Existente
- 📄 Cargar PDF

✅ **¡LISTO!** Ya puedes empezar.

---

## 🎯 PRIMERAS ACCIONES

### Opción A: Escanear un producto (lo más rápido)
```
1. Tab "Escaneo Manual"
2. Código: 123456
3. Nombre: MI PRIMER PRODUCTO
4. Marca: MI MARCA
5. Presentación: 1 UNIT
6. Contenido: TEST
7. Precio: 50
8. Cantidad: 5
9. Caducidad: 2028-12-31
10. Lote: LOTE-001
11. Click "Guardar Producto"
→ ✓ Listo
```

### Opción B: Cargar un PDF (automatizado)
```
1. Tab "Cargar PDF"
2. Arrastra ticket.pdf o screenshot de ticket
3. Espera 2-3 seg (procesando con IA)
4. Revisa preview
5. Click "Procesar PDF"
→ ✓ 40-800+ productos cargados automáticamente
```

---

## 📚 SI NECESITAS MÁS DETALLES

Lee estos archivos en orden:

1. **GUIA_INVENTARIO_MODULO.md** — Guía completa
2. **INVENTARIO_RESUMEN_IMPLEMENTACION.md** — Resumen técnico
3. **sql/schema_inventario.sql** — Código SQL (si te interesa)

---

## ⚠️ TROUBLESHOOTING RÁPIDO

| Problema | Solución |
|----------|----------|
| "Tabla no existe" | Re-ejecuta SQL de Supabase |
| "ANTHROPIC_API_KEY error" | Verifica `.env` + reinicia servidor |
| "Módulo no aparece" | Asegúrate que `/admin/inventario` es la URL |
| "PDF falla" | Usa archivo legible (no escaneo antiguo) |

---

## 🚀 NEXT

Cuando tengas el ticket real de Bodega F-42:

```
1. Toma foto del ticket (o PDF)
2. Ve a /admin/inventario → Tab "Cargar PDF"
3. Arrastra la foto/PDF
4. Click "Procesar PDF"
5. ✓ Todos tus 200-800+ productos cargados en segundos
```

---

**¡Disfruta del módulo!** 🎉
