# Auditoría UX móvil / responsive — FARMAX

**Fecha:** abril 2026.  
**Método:** revisión de código + **Playwright** (`e2e/mobile-responsive.spec.js`) sobre build estático: viewports 360×800, 390×844, 412×915, 768×1024, 820×1180 y 320×568; rutas **`/`** (tienda home) y **`/admin`** (login o shell); comprobación de overflow horizontal en `document`/`#root` y capturas PNG. Correcciones de layout aplicadas en repo.

---

## 1. Resumen ejecutivo

La app ya tenía piezas pensadas para móvil (`useMediaQuery`, sidebar admin deslizable, POS con reglas `@media`). Se corrigieron **fugas horizontales** (grids con `minmax` rígido, `100vw` en shell de tienda, modales, KPIs), **toasts**, **inputs** (riesgo zoom iOS), **tablas** con scroll donde hacía falta, y se añadió un **contenedor raíz en `Tienda.jsx`** con `overflow-x: hidden` para eliminar el último desbordamiento medible en 320px. **Playwright: 12/12 tests OK** en la última corrida (tras `npm run build`). Siguen siendo útiles **pruebas manuales** con sesión admin/cliente, checkout y tablas muy densas.

**Clasificación:** **Verde** en rutas auditadas automáticamente (tienda home + admin entrada); **ámbar** en cobertura funcional completa (módulos internos sin E2E por vista).

---

## 2. Hallazgos detectados (antes del fix)

| Área | Problema |
|------|----------|
| Global | Sin `overflow-x` explícito en `body`/`#root` a nivel CRA base; riesgo de scroll horizontal por hijos. |
| `ui.jsx` `Modal` | `minWidth: 320` + padding del overlay podía exceder viewport &lt; 360px. |
| `ui.jsx` toasts | Anclados `top/right` fijos; en móvil estrecho quedaban desbalanceados o cortados. |
| `ui.jsx` `Inp` / `SearchDropdown` | `fontSize: 13` → en iOS suele forzar zoom al enfocar. |
| `ui.jsx` `Btn` | Área táctil pequeña (`sm` muy compacto). |
| `Tienda.jsx` | Grid “similares” con `minmax(200px,1fr)` sin `min(100%,…)` → posible overflow. |
| `Tienda.jsx` header | Chip de usuario con `maxWidth: 200` + texto `maxWidth: 160` podía comprimir mal el flex. |
| `TicketPreviewModal` | `95vw` sin safe-area; fila final de botones sin wrap. |
| `ExpedientesDoctora` | Búsqueda con `minWidth: 220`; tabla ancha sin `overflow-x` dedicado. |
| `PromocionesModule` | Cabecera sin `flexWrap`; filas con `minWidth: 200` rígido. |
| `TransaccionesTab` | Modal detalle con grid 2 columnas fijas; modales sin safe-area. |
| Tienda shell (E2E) | En 320px persistía overflow horizontal en `document`/`#root` pese a `main` acotado; la causa era contenido/header fuera de `main` o interacción con medición de ancho. |

---

## 3. Archivos modificados y qué se corrigió

| Archivo | Cambio |
|---------|--------|
| `src/index.css` | `overflow-x: clip` + `max-width: 100%` en `body`/`#root`; `text-size-adjust`; media query para `.farmax-confirm-actions` en móvil. |
| `src/ui.jsx` | `Modal` sin `minWidth` forzado, `maxHeight` + scroll; safe-area en overlays; toasts centrados ancho completo; `ConfirmDialog` scroll + botones táctiles + `flexWrap`; `Btn`/`Inp`/`SearchDropdown`/`KPI`/`SkeletonKPIs` más aptos táctil y sin KPI overflow. |
| `src/components/tickets/TicketPreviewModal.jsx` | Safe-area en overlay; `width`/`maxHeight` con `dvh`; botones inferiores con `flexWrap` y `minHeight` 44. |
| `src/Tienda.jsx` | Grid similares responsive; CTAs detalle y header usuario con `minWidth: 0`; `main` sin `100vw`; **wrapper raíz** `overflow-x: hidden` + `width: 100%` para header+main en viewports estrechos. |
| `src/modules/clinical/patients/ExpedientesDoctora.jsx` | Fila herramientas envuelve; input búsqueda 100% en móvil; tabla con `overflow-x: auto` + `minWidth` tabla. |
| `src/PromocionesModule.jsx` | Cabecera con `flexWrap`; texto promo `minWidth: 0`. |
| `src/TransaccionesTab.jsx` | Modal detalle grid `auto-fit`; safe-area y alturas `dvh`; reimpresión ticket botones wrap + táctil; bloque resumen `minWidth: 0`. |
| `playwright.config.js`, `e2e/mobile-responsive.spec.js` | Servidor `serve build` en 4173; pruebas de overflow + screenshots. |
| `package.json` | Scripts `playwright:install`, `test:e2e:mobile`; devDeps `@playwright/test`, `serve`. |
| `src/setupTests.js` | Mock `window.matchMedia` para Jest (Admin `useMediaQuery`). |

---

## 4. Pantallas pendientes / revisión manual

Recomendado probar con sesión **admin** y **cliente** en DevTools (360×800, 390×844, 412×915, 768×1024, 820×1180):

- Login admin + flujo joyride / tour si aplica.
- **POS** carrito modal y teclado virtual.
- **Inventario / Lotes / RRHH / COFEPRIS / Facturación** tablas anchas (solo se ajustó expedientes y transacciones en profundidad; el resto ya tenía `overflowX: auto` en muchos sitios).
- **Tienda** checkout paso a paso y **MercadoPago** iframe.
- **PWA** `InstalarPWA.jsx` en iOS Safari.
- Módulos con formularios muy largos (consultorio, citas) sin cambios específicos en esta pasada.

---

## 5. Build y tests unitarios

- `npm run build` — OK (última verificación en la misma sesión que Playwright).
- `CI=true npm test -- --watchAll=false` — OK (2 tests).

---

## 6. Playwright / screenshots

**Instalación una vez (Chromium en `node_modules`):**

```bash
npm run playwright:install
```

**Correr auditoría de overflow + capturas:**

```bash
npm run test:e2e:mobile
```

Equivale a `build` + `PLAYWRIGHT_BROWSERS_PATH=0 playwright test e2e/mobile-responsive.spec.js`. El flag `PLAYWRIGHT_BROWSERS_PATH=0` evita conflictos de caché/arquitectura con binarios de Playwright.

**Salida:** PNG en `e2e/artifacts/screenshots/` (ignorados en git salvo `.gitkeep`). **Último resultado:** 12 passed (tienda `/` + admin `/admin`, 6 viewports c/u).

**Nota:** en algunos entornos el `webServer` (`serve`) puede fallar al enumerar interfaces de red; ejecutar los E2E fuera de sandbox restrictivo o en máquina local si aparece `uv_interface_addresses`.

---

## 7. Clasificación final

| Criterio | Nivel |
|----------|--------|
| Overflow horizontal en `/` y `/admin` (viewports del prompt) | **Verde** (Playwright) |
| Coherencia layout móvil en módulos profundos | **Ámbar** (revisión manual recomendada) |
| Cobertura E2E por pantalla (catálogo, POS, checkout…) | **Ámbar** (solo home + entrada admin) |

**Experiencia móvil global: Ámbar con núcleo verde** — bases y shell público/admin verificados automáticamente; el resto de flujos sigue dependiendo de prueba manual o ampliar specs.

---

## 8. Segunda ronda (abril 2026) — fixes por hallazgos reales en móvil

**Objetivo:** tabs/navegación secundaria, inventario, RRHH, consultorio, metas/precios, dashboard, asistente IA; sin refactors masivos; desktop preservado donde aplica.

### Hallazgos atacados

| Área | Cambio |
|------|--------|
| **Dashboard** | Pestañas en fila con scroll horizontal en ≤768px; etiquetas cortas; handles de arrastre y texto “Orden:” solo en desktop. |
| **Inventario (hub)** | Tabs con scroll horizontal; “Lotes PEPS” → “Lotes” en móvil; iconos un poco mayores; subtítulo largo oculto en móvil. |
| **Inventario (catálogo)** | Título y acciones separados en columna; grid 2 columnas; “Nuevo producto” ancho completo arriba; textos cortos (Recibir, Importar, Exportar). |
| **Consultorio** | Tabs con scroll; etiquetas compactas (“Lista”, “Consulta”, “Procedim.”). |
| **Metas y precios** (`ConfigConsultorioModule`) | Tabs con scroll; etiquetas cortas en móvil. |
| **RRHH** | Empleados en tarjetas (sin tabla apretada); horario semanal en acordeón por empleado (sin scroll lateral); nómina percepciones/deducciones apiladas con filas que no desbordan. |
| **Asistente IA** | Layout `100dvh` con área de mensajes flexible y composer fijo abajo + safe-area; input 16px en móvil (menos zoom iOS); **clave solo por `REACT_APP_GEMINI_API_KEY` / `REACT_APP_GEMINI_KEY`** (eliminada clave en código); pantalla de configuración si falta la variable; copy alineado a Gemini. |
| **POS / consultas cobro** | (Ronda previa en esta sesión de trabajo) tabs + cerrar turno, zoom, tour “?” — ver historial de commit si aplica. |

### Archivos tocados (esta ronda)

`src/DashboardModule.jsx`, `src/InventarioHub.jsx`, `src/InventarioModule.jsx`, `src/modules/clinical/ConsultorioModule.jsx`, `src/modules/clinical/ConfigConsultorioModule.jsx`, `src/RRHHModule.jsx`, `src/AsistenteIA.jsx` (+ cambios POS previos en `src/modules/sales/pos/POS.jsx` si están en el mismo batch).

### Validación (esta ronda)

- `npm run build` — OK  
- `CI=true npm test -- --watchAll=false` — OK (2 tests)  
- `npm run test:e2e:mobile` — **12 passed** (tienda `/` + admin `/admin`, viewports existentes)

### Pendiente manual

- Probar en iPhone real: Dashboard scroll de tabs, RRHH acordeón de horario, Inventario acciones, Consultorio/Metas tabs, Asistente IA con `.env` y sin clave (mensaje de configuración).  
- Asistente: las keys `REACT_APP_*` quedan en el bundle del cliente; para producción dura conviene proxy/backend si la política de Google no permite uso desde navegador.

### Clasificación tras esta ronda

Misma base **verde** en rutas E2E; módulos tocados pasan de “solo manual” a **mejoras aplicadas en código** — seguir en **ámbar** hasta QA sesión en dispositivo físico.
