Quiero continuar la remediación real de FARMACAPITAL migrando la siguiente capa de lecturas directas a RPCs seguras.

CONTEXTO
Ya quedó una P0 migrada a RPCs para:
- pedidosTiendaWeb.js
- POS.jsx
- Tienda.jsx
- badges/contador online relacionados

Ahora quiero atacar P1:
- TransaccionesTab.jsx
- MiDia.jsx
- DashboardModule.jsx
- Admin.jsx
- ClientesModule.jsx
- CorteCajaModule.jsx
- FacturacionModule.jsx
- DevolucionesModule.jsx
- COFEPRISModule.jsx
- RRHHModule.jsx
- LotesModule.jsx

OBJETIVO
Eliminar lecturas directas con supabase.from(...).select() sobre tablas sensibles y reemplazarlas por RPCs seguras, sin refactor masivo.

TABLAS MÁS IMPORTANTES EN ESTA FASE
- pedidos
- pedido_items
- citas
- facturas
- devoluciones
- devolucion_items
- cortes_caja
- bitacora_cofepris
- lotes
- proveedores
- clientes
- usuarios (si aplica en comisiones)
- cualquier otra tabla sensible que esté bloqueada por RLS estricta

QUÉ QUIERO QUE HAGAS
1. Revisa las lecturas directas en los módulos P1.
2. Diseña RPCs mínimas y seguras para cubrir esos casos.
3. Crea el SQL necesario en sql/ con nombre claro.
4. Cambia el frontend P1 para usar RPCs.
5. No rompas el flujo actual.
6. No hagas refactor masivo.
7. Mantén build funcionando.
8. Documenta qué quedó migrado y qué sigue pendiente.

PRIORIDAD INTERNA
Primero:
- TransaccionesTab.jsx
- MiDia.jsx
- DashboardModule.jsx
- Admin.jsx

Después:
- ClientesModule.jsx
- CorteCajaModule.jsx
- FacturacionModule.jsx
- DevolucionesModule.jsx

Luego:
- COFEPRISModule.jsx
- RRHHModule.jsx
- LotesModule.jsx

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre npm run build
2. deja un resumen claro de:
   - RPCs nuevas creadas
   - archivos frontend modificados
   - qué lecturas directas fueron eliminadas
   - qué quedó pendiente
   - resultado de build

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué quedó migrado en P1
3. SQL adicional creado
4. Archivos modificados
5. Qué sigue pendiente
6. Resultado de build
