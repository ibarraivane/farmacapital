# 🔴 ERRORES DE CANTIDAD ENCONTRADOS EN TICKETS

## FarmaLive - Productos cargados con cantidad 1 pero deberían ser 2+

### ✅ CONFIRMADOS (Análisis manual):

| Producto | Línea | Cantidad Real | Cantidad Cargada | Ticket |
|----------|-------|---------------|------------------|--------|
| **ELECTROLIT UVA 525 ML** | 2132 | 2 | 1 | ❌ INCORRECTO |
| **ELECTROLIT COCO 625 ML** | 2142 | 2 | 1 | ❌ INCORRECTO |
| **ELECTROLIT ERESA-KIWI 625 ML** | 2155 | 2 | 1 | ❌ INCORRECTO |
| **ELECTROLIT ÈRESA 625 ML** | 2163 | 2 | 1 | ❌ INCORRECTO |
| **ELECTROLIT MORA AZUL 625 ML** | 2166 | 2 | 1 | ❌ INCORRECTO |
| **REPELENTE BIOCLAP 265 ML** | 2250 | 2 | 1 | ❌ INCORRECTO |
| **PROMEGA 3 CAPS C/30** | 1067 | 2 | 1 | ❌ INCORRECTO |
| **TRIBEDOCE TAB C/30** | 215 | 5 | 1 | ❌ INCORRECTO |
| **ALGODON DIBAR 200 GR** | 1605 | 2 | 1 | ❌ INCORRECTO |
| **ALGODON DIBAR 60 GR** | 1657 | 2 | 1 | ❌ INCORRECTO |
| **JERINGA SENSIMEDICAL INSUL 0.3 ML C/100** | 1589 | 1 | 1 | ✅ CORRECTO |
| **JERINGA SENSIMEDICAL INSUL 0.5 ML C/100** | 1518 | 1 | 1 | ✅ CORRECTO |

### ⚠️ SOSPECHOSOS (OCR poco clara, requiere verificación manual):

- Cond Prudence (múltiples variantes con cantidad > 1)
- Colgate (varios productos dentales)
- Shampo Ricitos de Oro Miel

---

## Otros Tickets (Pendiente análisis):

- [ ] Bodega F-42.pdf (65 páginas)
- [ ] Equilibrio.pdf (318 páginas - GRANDE)
- [ ] Farma Mx.pdf (38 páginas)
- [ ] El surtidor de su farmacia.pdf (17 páginas)
- [ ] IFC 1.pdf (11 páginas)
- [ ] IFC 2.pdf (16 páginas)

---

## 🎯 ACCIÓN INMEDIATA:

1. **Ejecutar en Supabase SQL Editor:**
   ```sql
   sql/corregir_stock_electrolit.sql
   ```

2. **Buscar estos productos en BD y actualizar:**
   - REPELENTE BIOCLAP
   - PROMEGA 3 CAPS
   - TRIBEDOCE TAB
   - ALGODON DIBAR (ambos)

---

## 📊 IMPACTO:

- **Electrolits**: 5 productos x 1 unidad faltante = **5 unidades de error**
- **Otros**: ~6 productos con errores de cantidad
- **Total**: ~15-20 unidades no registradas correctamente

---

## NOTA:

El SQL generado (`carga_tickets_20260810_part0014.sql`) cargó todos los productos con cantidad 1, 
ignorando las cantidades reales del ticket. Esto afecta el inventario disponible y puede causar 
problemas al vender (diciendo que no hay stock cuando sí lo hay, o viceversa).
