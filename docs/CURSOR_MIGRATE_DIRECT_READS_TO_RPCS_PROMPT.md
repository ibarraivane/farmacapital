Quiero pasar de diagnóstico a remediación real: migrar lecturas directas de tablas sensibles a RPCs en FARMACAPITAL.

CONTEXTO
Ya se aplicaron políticas RLS estrictas en Supabase.
El frontend todavía hace lecturas directas con supabase.from('tabla').select() sobre tablas sensibles.
Eso ahora bloquea o pone en riesgo módulos completos.

NO quiero más auditoría.
Quiero empezar a arreglar.

OBJETIVO
Migrar por prioridad las lecturas directas más críticas hacia RPCs o lecturas seguras.

PRIORIDAD DE REMEDIACIÓN

P0 (primero)
- src/utils/pedidosTiendaWeb.js
- src/modules/sales/pos/POS.jsx
- src/Tienda.jsx

P1 (después)
- src/TransaccionesTab.jsx
- src/modules/sales/MiDia.jsx
- src/DashboardModule.jsx
- src/Admin.jsx
- src/ClientesModule.jsx
- src/CorteCajaModule.jsx
- src/FacturacionModule.jsx
- src/DevolucionesModule.jsx
- src/COFEPRISModule.jsx
- src/RRHHModule.jsx
- src/LotesModule.jsx

P2 (más delicado)
- src/modules/clinical/*
- expediente / agenda / citas / receta / sync clínica

TABLAS SENSIBLES / CRÍTICAS
- pedidos
- pedido_items
- citas
- clientes
- lotes
- proveedores
- facturas
- devoluciones
- cortes_caja
- bitacora_cofepris
- cualquier otra tabla operativa sensible

LO QUE QUIERO QUE HAGAS

1. Revisa el diagnóstico ya existente y confirma las lecturas directas más críticas.
2. Diseña RPCs mínimos y seguros para P0:
   - cliente_listar_mis_pedidos
   - cliente_listar_mis_citas
   - empleado_listar_pedidos_online_pendientes
   - empleado_buscar_clientes_pos
   - empleado_listar_citas_del_dia
   - empleado_obtener_pedido_detalle
   - empleado_obtener_stock_por_lotes_producto
   (ajusta nombres si ya existe algo parecido)
3. Crea el SQL necesario en sql/ con nombres claros.
4. Cambia los módulos P0 para usar RPCs en lugar de .from().select() directo donde aplique.
5. No rompas el flujo actual.
6. No hagas refactor masivo.
7. Mantén build funcionando.
8. Documenta qué quedó migrado y qué sigue pendiente.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre npm run build
2. deja un resumen claro de:
   - RPCs nuevas creadas
   - archivos frontend modificados
   - qué lecturas directas fueron eliminadas
   - qué quedó pendiente en P1/P2
   - resultado de build

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué quedó migrado en P0
3. SQL adicional creado
4. Archivos modificados
5. Qué sigue pendiente
6. Resultado de build
