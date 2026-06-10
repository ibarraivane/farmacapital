Quiero que hagas una auditoría visual y funcional de la versión móvil/responsive de FARMACAPITAL y que APLIQUES correcciones seguras y de alta confianza directamente en el repo si detectas problemas claros de layout, overflow, jerarquía visual o usabilidad móvil.

CONTEXTO
- Proyecto React + Supabase + SQL para FARMACAPITAL.
- Hay tienda pública + panel Admin/POS.
- El sistema ya pasó una auditoría de seguridad pre-go-live y ya se endurecieron funciones críticas.
- Ya existe trabajo previo de hardening y no quiero refactors grandes de arquitectura.
- Quiero una auditoría específica de UX/UI móvil: que TODAS las vistas se vean bien, completas, coherentes y usables en celular/tablet.
- No quiero refactors grandes de arquitectura. Quiero correcciones de responsive, layout y UX móvil de bajo riesgo.
- Si detectas algo dudoso, documenta el hallazgo en vez de romper el flujo.

OBJETIVO
1) Auditar visualmente la app en móvil/tablet
2) Detectar pantallas rotas, incompletas o incoherentes
3) Corregir problemas claros de responsive y layout
4) Dejar un reporte de hallazgos y cambios

IMPORTANTE
- Quiero que ejecutes tú el análisis dentro del repo.
- No quiero solo recomendaciones.
- Si puedes automatizarlo con Playwright o navegador controlado, hazlo.
- Si hace falta instalar una dependencia mínima de dev para testing visual (por ejemplo @playwright/test), puedes hacerlo SOLO si es necesario y documentándolo.
- Si necesitas levantar el servidor local, hazlo.
- Si alguna vista requiere login y no hay credenciales disponibles en el entorno, igual audita:
  - la pantalla de login
  - el layout base
  - y documenta claramente qué rutas quedaron bloqueadas por autenticación
- Si la app ya tiene rutas claras:
  - /  -> tienda
  - /admin -> admin
  úsalas como base.

ALCANCE A AUDITAR

A. TIENDA PÚBLICA
- Home
- catálogo / listado
- cards de producto
- detalle de producto
- carrito
- checkout
- login/registro cliente
- sección de citas / consultorio público
- footer / políticas / banners

B. ADMIN
- login admin
- dashboard
- menú lateral / navegación
- POS
- inventario
- lotes
- clientes
- RRHH
- COFEPRIS
- devoluciones
- facturación
- promociones
- banners
- transacciones
- consultorio
- expedientes
- pantallas PWA / instalación

C. COMPONENTES CRÍTICOS
- modales
- tablas
- formularios largos
- tickets / previews
- toasts
- skeletons
- fallbacks / pantallas de error
- scroll interno vs scroll de página
- overlays
- botones primarios/secundarios
- inputs, selects, textarea
- grids y cards

BREAKPOINTS A USAR
Prueba mínimo en:
- 360x800
- 390x844
- 412x915
- 768x1024
- 820x1180
Opcional extra:
- 320x568

CRITERIOS DE ACEPTACIÓN VISUAL
Considera error / hallazgo si existe cualquiera de estos:
- overflow horizontal
- contenido cortado
- botones fuera de pantalla
- inputs demasiado pequeños o no clicables
- tablas ilegibles o no desplazables correctamente
- modal que excede pantalla y no se puede usar
- header/footer tapando contenido
- sidebar roto o imposible de cerrar
- cards deformadas
- tipografía demasiado pequeña
- paddings inconsistentes
- jerarquía visual confusa
- CTA importante escondido
- doble scroll molesto
- ticket o preview ilegible
- componentes pegados al borde sin aire
- elementos apilados sin coherencia
- layout que funciona en desktop pero no en touch/móvil
- errores de consola relacionados con layout/carga al entrar a vistas

INSTRUCCIONES DE EJECUCIÓN
1. Inspecciona el repo para entender rutas y pantallas principales.
2. Busca componentes clave y puntos críticos:
   - src/Admin.jsx
   - src/Tienda.jsx
   - src/DashboardModule.jsx
   - src/ui.jsx
   - src/styles/ticket.css
   - src/modules/sales/pos/POS.jsx
   - módulos de inventario / clientes / promociones / transacciones / expedientes
3. Levanta la app local si hace falta.
4. Si es posible, usa Playwright o herramienta equivalente para:
   - abrir vistas
   - simular viewport móvil/tablet
   - capturar screenshots
   - detectar overflow horizontal básico
   - registrar errores de consola
5. Audita primero sin cambiar nada.
6. Luego aplica SOLO correcciones seguras y claras.

TIPO DE CAMBIOS QUE SÍ QUIERO
- corregir overflow horizontal
- mejorar stacks/columnas en móvil
- ajustar paddings, gaps, widths, min-width, max-width
- mejorar tablas para móvil (scroll, cards, truncado, wrap, responsive container)
- corregir modales para que quepan y sean utilizables
- mejorar tamaño de botones e inputs en touch
- arreglar layouts de sidebar, header, toolbar, cards y formularios
- ajustar tickets/previews si quedan cortados o ilegibles
- hacer que pantallas vacías / errores / loaders se vean correctos en móvil
- si ves texto o bloques muy pequeños, mejorar legibilidad
- si hay grids complejos, convertirlos a 1 columna en móvil cuando convenga

TIPO DE CAMBIOS QUE NO QUIERO
- no reescribas toda la app
- no cambies la lógica de negocio
- no refactorices masivamente Admin.jsx o Tienda.jsx por estética
- no migres a otra arquitectura
- no cambies SQL
- no elimines módulos
- no toques seguridad salvo que un fix de UI lo requiera mínimamente

ENTREGABLES
Al final quiero:
1. Resumen ejecutivo corto del estado móvil
2. Lista de hallazgos encontrados
3. Lista de archivos modificados
4. Qué se corrigió en cada archivo
5. Qué pantallas siguen pendientes o requieren revisión manual
6. Resultado de build
7. Si usaste Playwright/screenshots, dime dónde quedaron
8. Clasificación final:
   - rojo / ámbar / verde para experiencia móvil

VALIDACIÓN FINAL
Después de aplicar cambios:
- corre build
- busca errores de consola obvios
- confirma que no rompiste desktop
- resume si la experiencia móvil mejoró realmente

CRITERIOS DE ÉXITO
El trabajo es exitoso si:
- se auditan varias vistas en móvil/tablet sin depender de mí
- se corrigen problemas claros de responsive
- el proyecto sigue compilando
- queda un reporte útil
- y las pantallas críticas móviles quedan mejor que antes

NO TE QUEDES SOLO EN RECOMENDACIONES.
Analiza el repo, ejecuta pruebas automáticas si puedes, aplica fixes seguros y deja evidencia clara.
