# Estado — CURSOR_FINAL_BATCH (consolidado)

Última actualización: 2026-04-20. Resumen de lo aplicado en código y lo que sigue dependiendo de datos, producto o entorno real.

## Cerrado en esta ronda (código)

- **Navegación / perfiles:** Eliminado el módulo lateral **«Cobrar consulta»** (`cons_cobro`). El cobro de consultas queda en **POS → pestaña Consultas**. Rutas `/admin/cobrar-consulta` y slug `cons_cobro` redirigen a **pos** y, vía `sessionStorage` + `pathnameSuggestsPosTab`, abren la pestaña **consultas** cuando aplica.
- **Admin:** Quitado el botón **«Restaurar lista de módulos»** del sidebar (el orden se puede seguir gestionando con la lógica existente en `adminNavOrder` si se expone de otra forma).
- **Agenda:** Vendedor ya no queda forzado solo a vista «día»; puede usar **mes**. No se agenda en **fechas pasadas**; en días pasados los huecos libres muestran texto de solo lectura. Validación extra al guardar cita (hoy + horario futuro). CTA **Ir a POS (cobrar consulta)** usa `onNavigate("pos", { posTab: "consultas" })`. Cabecera con contenedor visual más claro.
- **POS:** Eliminado el formulario duplicado **«Nueva cita (mostrador)»**; mensaje + **Ir a agenda**. Búsqueda de cliente con **sugerencias** (teléfono normalizado + nombre vía Supabase) en `SearchDropdown` para venta y cobro de consulta. Al entrar en **Online**, **re-fetch** de pedidos pendientes para reducir carreras. Sincronización de pestaña inicial con `farmax_pos_initial_tab`.
- **Mi Día:** «Lista de espera» abre **POS** con pestaña **consultas**.
- **Dashboard:** Pestaña **Proyecto / inversión** fuera de la tira reordenable; solo **Operación, Resumen, Transacciones, Margen** en el strip. Eliminado el bloque de CAPEX dentro de **Resumen** y el párrafo macro duplicado en **Operación** (el detalle queda en **Proyecto**).
- **Utilidades agenda:** `horariosDisponiblesCita` devuelve `[]` para fechas **anteriores a hoy** (coherente con «no agendar en el pasado»).

## Verificación local

- `npm run build` — OK.
- `CI=true npm test -- --watchAll=false` — OK.
- **Playwright** (`npm run test:e2e:mobile`): no ejecutado en esta sesión (requiere build + chromium; conviene correrlo en CI o localmente cuando haya tiempo).

## Pendiente / no cerrable solo con frontend

- **Catálogo / SKUs (vitaminas, electrolitos, etc.):** No se añadió seed CSV en repo; los datos reales viven en Supabase. Si hace falta plantilla: columnas sugeridas `sku, nombre, categoria, precio, activo, requiere_receta` y carga vía SQL `INSERT` o herramienta de importación del proyecto.
- **Controlados vs receta en POS:** La lógica sigue siendo `requiere_receta || categoria === "Antibiótico"`. Un campo explícito tipo `controlado` en BD unificaría reglas COFEPRIS con el catálogo; requiere migración y revisión legal/operativa.
- **Usuarios con `modulos_custom` que aún listen `cons_cobro`:** El ítem se filtra por `puedeVerModulo`; no rompe, pero esos registros JSON quedan con un id huérfano hasta que un admin guarde de nuevo permisos (opcional: script SQL de limpieza en `modulos_custom`).
- **Búsqueda de clientes:** Depende de cómo esté almacenado `clientes.telefono` en producción (solo dígitos vs formato con espacios). Se usa `ilike` + comparación de dígitos en cliente; si hay casos raros (múltiples países), habría que afinar índices o normalización en BD.

## Archivos tocados (referencia)

`src/constants.js`, `src/utils/permissions.js`, `src/shared/adminRoutes.js`, `src/utils/citasAgenda.js`, `src/Admin.jsx`, `src/modules/clinical/AgendaConsultasModule.jsx`, `src/modules/sales/pos/POS.jsx`, `src/modules/sales/MiDia.jsx`, `src/DashboardModule.jsx`.
