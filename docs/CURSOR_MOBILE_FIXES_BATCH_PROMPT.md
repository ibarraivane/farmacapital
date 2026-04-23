Quiero que hagas una segunda ronda de correcciones UX/UI enfocada SOLO en la versión móvil/celular de FARMAX, basándote en problemas reales observados en capturas desde iPhone. No quiero observaciones generales: quiero que APLIQUES fixes seguros y de alta confianza en el repo.

CONTEXTO
- Proyecto FARMAX con tienda pública + panel Admin/POS.
- Ya existe una auditoría móvil previa y ya hubo correcciones responsive generales.
- Ya existe Playwright / e2e móvil en el repo.
- Esta nueva ronda es específica para pantallas y problemas REALES reportados visualmente en móvil.
- Todas las observaciones siguientes son para versión celular/móvil, no desktop.
- No quiero refactors masivos de arquitectura.
- No quiero cambios de lógica de negocio salvo donde sea necesario para corregir UX o estados claramente rotos.
- Si algo depende de backend/configuración que no esté disponible (por ejemplo IA con API key), no inventes una solución falsa: deja una UX correcta y documenta la limitación.

OBJETIVO
1) Corregir layout, jerarquía visual, alineación, overflow y usabilidad móvil en módulos señalados.
2) Mejorar presentación profesional en móvil.
3) Mantener desktop lo más intacto posible.
4) Reusar y/o ampliar las pruebas Playwright móviles si aporta valor.
5) Dejar un reporte claro de qué se corrigió.

==================================================
PROBLEMAS ESPECÍFICOS A CORREGIR (MÓVIL)
==================================================

A. SUBMÓDULOS / NAVEGACIÓN SECUNDARIA MAL ACOMODADA
Problema general:
- En varias pantallas los submódulos/tabs secundarios se ven mal acomodados, desalineados, poco profesionales.
- Se mezclan contextos de módulo con tabs o acciones.
- Los labels se rompen feo, algunos se bajan, se ven como chips amontonados.
- Iconos muy pequeños, desalineados o inconsistentes.
- Textos/títulos se empalman o se mueven.
Quiero:
- uniformar tabs/submódulos en móvil
- mantener una jerarquía clara entre contexto, navegación y acciones
- evitar múltiples filas desordenadas de chips
- iconos consistentes, alineados y de tamaño similar
- labels compactos y elegantes en móvil
- active state claro
- si hace falta, usar fila horizontal scrollable o reacomodo vertical limpio
Pantallas afectadas:
- Dashboard/reportes / proyecto / inversión / submódulos similares
- Metas y precios
- Consultorio
- Inventario
- cualquier pantalla con navegación secundaria similar

B. PUNTO DE VENTA (POS) — LAYOUT MÓVIL
Problemas reportados:
- En móvil la vista de Punto de Venta se ve mal acomodada.
- Al entrar, la página aparece con “zoom in” inicial y obliga a alejar con los dedos.
- “Cerrar turno” está mal colocado y roba espacio vertical.
- El botón flotante azul con “?” estorba.
- Hay una franja/espacio inferior pegado a la barra del navegador que no aporta valor visual.
- Todo eso quita espacio para ver productos y SKUs.
Quiero:
- revisar la causa del zoom inicial del POS móvil y corregirla si es un problema de layout/viewport/inputs/tamaños.
- mover “Cerrar turno” al lado de las tabs superiores (por ejemplo junto a “Consultas”), no en fila aparte.
- ocultar o reubicar el botón de ayuda “?” en móvil si estorba.
- eliminar/reducir cualquier franja inferior inútil que robe espacio visual dentro de la app.
- maximizar el área visible para la grilla de productos y SKUs.
- mantener la UX clara y táctil.

C. POS / COBRO DE CONSULTAS
Problemas reportados:
- También en la vista de cobro de consultas, “Cerrar turno” debe subir al lado de las tabs.
- En el formulario, los rectángulos grises de Fecha y Hora se traslapan / montan.
Quiero:
- alinear la cabecera del submódulo
- mover “Cerrar turno” junto a tabs
- corregir el layout de Fecha / Hora para que no se traslapen
- que se vea limpio y profesional en móvil

D. ASISTENTE IA
Problemas reportados:
- El AI sigue sin funcionar (se muestra error de API key inválida).
- La barra/input para escribir no se ve de entrada; hay que hacer scroll hacia abajo primero.
- Eso se siente muy incómodo y poco profesional.
Quiero:
- NO inventar backend si la API key no está disponible.
- Sí corregir la UX móvil:
  - el input de escritura debe estar visible sin necesidad de hacer scroll previo
  - la barra de entrada debe quedar anclada o claramente visible al fondo del viewport
  - el layout del chat debe ser usable en móvil
  - el estado de error de API debe verse ordenado, sin dejar una pantalla vacía/chueca
- si hay que mejorar altura, sticky input, safe-area o flex layout, hazlo

E. CONSULTORIO — ICONOS / TÍTULOS / SUBMÓDULOS
Problemas reportados:
- Iconos se ven mal, muy pequeños, desalineados
- Letras/títulos se empalman o se bajan feo
- Navegación secundaria en consultorio se ve poco profesional
Quiero:
- tabs/submódulos de consultorio alineados
- iconografía uniforme
- evitar que “Lista de espera” o similares se rompan en 3 líneas de forma fea
- mejorar percepción visual profesional en móvil

F. RH / HORARIO SEMANAL
Problema reportado:
- El bloque “Horario semanal” obliga a scroll lateral y se siente incómodo.
Quiero:
- evitar tabla horizontal en móvil
- mantener desktop si ya funciona
- en móvil, cambiar a una vista más usable, por ejemplo:
  - acordeón por empleado
  - o tarjeta por empleado con días verticales
  - o una alternativa equivalente sin scroll lateral
- mantener la lógica de guardado y edición
- que sea claramente mejor que la tabla comprimida

G. RH / EMPLEADOS REGISTRADOS
Problema reportado:
- Los nombres de los empleados se ven empalmados / mal acomodados.
- La tabla/lista en móvil se ve apretada.
Quiero:
- mejorar la presentación de empleados en móvil
- permitir wrap limpio o layout en tarjeta si hace falta
- evitar columnas demasiado comprimidas
- que nombres largos se vean legibles
- revisar también rol / teléfono para que no choquen entre sí

H. NÓMINA / RESUMEN FINANCIERO
Problema reportado:
- En la tarjeta de percepciones/deducciones, “Deducciones” se sale de márgenes.
- “Neto a pagar” también se desborda / se ve mal.
Quiero:
- corregir ese layout para móvil
- si hace falta, pasar de columnas rígidas a stack vertical
- que números, labels y totales quepan bien
- mantener claridad visual de percepciones, deducciones y neto

I. INVENTARIO — SUBCATEGORÍAS Y ACCIONES
Problema reportado:
- “Catálogo / Reabasto / Lotes PEPS” y acciones como “Recibir mercancía / Importar CSV / Plantilla / Exportar CSV / Nuevo producto” se ven desalineadas y mezcladas.
Quiero:
- separar navegación del módulo (Catálogo / Reabasto / Lotes) de acciones rápidas
- en móvil:
  - tabs arriba bien alineados
  - acciones debajo como botones de acción, no como tabs
- labels más cortos si ayudan:
  - “Recibir mercancía” -> “Recibir”
  - “Importar CSV” -> “Importar”
  - “Exportar CSV” -> “Exportar”
  - “Lotes PEPS” -> “Lotes” si tiene sentido y no rompe semántica importante
- botón principal “Nuevo producto” destacado
- resto de acciones en grid uniforme 2 columnas o layout equivalente limpio

J. CONSISTENCIA VISUAL GENERAL
Problemas recurrentes observados:
- íconos mal alineados
- títulos movidos
- labels que se bajan
- chips/tabs amontonados
- componentes que se ven “chafas”
Quiero:
- una pasada de pulido visual móvil en componentes de navegación secundaria, headings, action bars, cards y formularios
- sin cambiar la identidad visual del sistema
- priorizando alineación, spacing, tipografía, wrap y jerarquía

==================================================
ALCANCE TÉCNICO
==================================================

Revisa especialmente:
- src/Admin.jsx
- src/Tienda.jsx
- src/ui.jsx
- src/index.css
- src/components/tickets/TicketPreviewModal.jsx
- src/PromocionesModule.jsx
- src/TransaccionesTab.jsx
- src/InstalarPWA.jsx
- src/RRHHModule.jsx
- src/COFEPRISModule.jsx
- src/DashboardModule.jsx
- src/modules/sales/pos/POS.jsx
- src/modules/sales/MiDia.jsx
- src/modules/clinical/ConsDoctora.jsx
- src/modules/clinical/ConfigConsultorioModule.jsx
- src/modules/clinical/patients/ExpedientesDoctora.jsx
- cualquier archivo real implicado por las pantallas reportadas
- e2e/mobile-responsive.spec.js
- docs/MOBILE_UX_AUDIT_FARMAX.md

==================================================
REGLAS IMPORTANTES
==================================================

- Todo esto es para móvil/celular.
- No rompas desktop.
- No cambies SQL.
- No toques seguridad salvo que un fix de UI lo requiera mínimamente.
- No reescribas toda la app.
- Si una mejora en móvil requiere cambiar presentación (por ejemplo tabla -> acordeón solo en móvil), hazlo de forma segura.
- Si una pantalla requiere login o datos reales y no puedes abrirla automáticamente, haz fix por código + documenta pendiente manual.
- Si Playwright ya existe, úsalo para ampliar o revalidar al menos lo que puedas cubrir razonablemente.

==================================================
VALIDACIÓN FINAL
==================================================

Después de aplicar cambios:
1. corre build
2. si procede, corre tests
3. si Playwright móvil ya existe, reúsalo o amplíalo
4. busca errores de consola obvios
5. resume qué se corrigió y qué quedó pendiente manual

==================================================
ENTREGABLE
==================================================

Quiero que me entregues:
1. Resumen ejecutivo corto
2. Lista de hallazgos atacados
3. Archivos modificados
4. Qué cambiaste en cada archivo
5. Qué sigue pendiente manual
6. Resultado de build/tests/Playwright
7. Clasificación final móvil tras esta segunda ronda

NO te quedes en recomendaciones.
Analiza el repo y aplica fixes seguros y coherentes con estos hallazgos visuales reales de móvil.
