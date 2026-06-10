Quiero que hagas una ronda consolidada de mejoras funcionales, visuales y operativas en FARMACAPITAL, reuniendo TODOS los hallazgos acumulados hasta ahora. No quiero solo recomendaciones: quiero que analices el repo y apliques cambios seguros y de alta confianza donde sea claro, y documentes lo que no pueda cerrarse del todo sin datos/DB/entorno real.

IMPORTANTE
- No hagas refactors grandes de arquitectura.
- No migres a TypeScript.
- No toques seguridad SQL salvo que sea estrictamente necesario y de bajo riesgo.
- No rehagas toda la app.
- Mantén compatibilidad funcional.
- Si algo es dudoso, documenta el hallazgo y deja un fix conservador.
- Todo cambio debe intentar mantener desktop funcional.
- Todo cambio debe intentar mejorar móvil/celular sin romper escritorio.
- Al final corre build. Si existen pruebas razonables, corre tests. Si Playwright móvil ya existe, reúsalo o amplíalo cuando aporte valor.
- No cierres solo con “observaciones”: aplica cambios concretos y deja un resumen claro.

==================================================
BLOQUE A — SIDEBAR POR PERFIL (YA DEFINIDO)
==================================================

Implementa / consolida esta lógica visual por perfil:

1. ADMINISTRADOR
- perfil único y completo
- NO usar “administrador por rol”, ni “vista vendedor”, ni “vista doctora”
- sidebar agrupado por secciones de trabajo

Sidebar admin final:
1. Operación diaria
   - Dashboard
   - POS
   - Transacciones
   - Clientes
   - Caja / Corte
   - Pedidos online
   - (NO mostrar “Cobro consulta” como módulo aparte; debe vivir dentro de POS)
2. Inventario
   - Inventario / Productos
   - Lotes
   - Reabasto
3. Consultorio
   - Agenda de consultas
   - Consultorio
   - Expedientes
4. Control y cumplimiento
   - COFEPRIS
   - Devoluciones
   - Facturación
5. Comercial y crecimiento
   - Promociones
   - Banners
   - Reportes
   - Asistente IA
   - Metas / precios / configuración comercial (si existe)
6. Administración interna
   - Usuarios
   - RRHH
7. Sistema
   - PWA / Instalar app
   - Configuración general (si existe)

2. VENDEDOR
- perfil operativo y segregado del admin
- navegación corta y clara

Sidebar vendedor final:
- Inicio operativo
- POS
- Agenda de consultas / Consultas del día
- Transacciones
- Clientes
- Inventario (consulta)
- Caja / Corte (si aplica)
- COFEPRIS
- Pedidos online (si aplica a su operación)
- PWA

NO debe ver:
- RRHH
- Usuarios
- Promociones
- Banners
- Facturación
- IA si no aporta al mostrador
- Dashboard estratégico completo
- Configuración general
- Consultorio clínico completo si no hace falta

3. DOCTORA
- perfil clínico puro
- NO cobra consulta
- NO usa POS
- NO usa caja
- NO ve transacciones financieras ni módulos administrativos/comerciales

Sidebar doctora final:
- Agenda médica
- Expedientes
- Pacientes / Clientes
- Consultorio (solo si tiene sentido como módulo clínico amplio)
- PWA

NO debe ver:
- Cobro consulta
- POS
- Caja
- Transacciones
- Dashboard financiero
- RRHH
- Usuarios
- Promociones
- Banners
- Facturación
- COFEPRIS de mostrador
- Inventario general

CAMBIOS EXTRA EN SIDEBAR
- Quitar del sidebar la opción “Restaurar lista de módulos”.
- Ya no hace falta porque el menú quedó bien acomodado.
- Si la lógica interna se conserva para soporte, que no sea visible en UI.

==================================================
BLOQUE B — AGENDA DE CONSULTAS (FUENTE ÚNICA)
==================================================

La agenda de consultas debe quedar como el lugar oficial para AGENDAR / MOVER / REVISAR DISPONIBILIDAD.

PUNTO CLAVE:
- Mantener la agenda en “Agenda de consultas”
- Eliminar la duplicidad de “agendar consulta” dentro de Punto de Venta
- En POS dejar solo el flujo de cobro / localización de consultas ya agendadas
- Si hace falta, desde POS dejar botón “Ir a agenda”, pero NO formulario duplicado de agendado

MODELO DESEADO:
1. Vista principal: calendario mensual
   - mostrar mes completo
   - marcar días con consultas
   - resaltar día actual
   - navegar entre meses
   - click/tap en día → agenda del día
2. Vista secundaria: agenda del día por horas
   - horarios libres
   - horarios ocupados
   - consultas agendadas
   - permitir abrir detalle
   - permitir agendar en huecos disponibles
3. Vista terciaria: detalle / edición
   - paciente
   - fecha
   - hora
   - motivo
   - estado
   - observaciones
   - acceso a expediente si aplica
   - acciones según perfil

LÓGICA OPERATIVA:
- La doctora atiende la consulta
- Caja (vendedor o admin) realiza el cobro
- El sistema debe reflejar claramente esa separación

CAMBIOS ADICIONALES IMPORTANTES:
- El módulo de agenda actual “se siente muy simple y sin vida”; dale mejor jerarquía visual, encabezado, estados más claros y una experiencia más rica sin meter una librería pesada si no hace falta.
- NO permitir agendar en días pasados.
- NO permitir agendar en horarios pasados del día actual si ya quedaron atrás.
- Si se permite ver días pasados por historial, que sea solo lectura / detalle, NO con botón de agendar habilitado.
- Revisa que la presentación por perfil tenga sentido:
  - Admin: agenda completa + detalle
  - Vendedor: agenda operativa, con foco en paciente / hora / estado / pendiente de cobro
  - Doctora: agenda médica / clínica

ESTADOS VISUALES:
Usa los estados actuales si existen, pero presenta visualmente algo coherente tipo:
- disponible
- agendada
- confirmada
- paciente presente / en espera
- atendida
- pendiente de cobro
- pagada
- cancelada
- no asistió (si aplica)

==================================================
BLOQUE C — PUNTO DE VENTA / COBRO / ZOOM / ESPACIO
==================================================

Problemas reportados:
- En móvil, Punto de Venta se ve mal acomodado.
- Al entrar desde iPhone, el POS hacía “zoom in” y obligaba a alejar con los dedos.
- “Cerrar turno” roba espacio vertical.
- El botón “?” estorba.
- Hay una franja inferior inútil que roba espacio visual.
- Se necesita más espacio para ver productos/SKUs.
- En cobro de consultas, fecha/hora se traslapaban.
- NO quiero “agendar consulta” dentro del POS si la agenda ya lo resuelve mejor.
- En POS, el campo de teléfono del cliente no funciona o no hace nada.

Quiero:
1. Mantener Cobro consulta SOLO como pestaña dentro de POS, no como módulo aparte de sidebar.
2. Revisar el zoom inicial de iPhone/Safari y dejarlo resuelto:
   - no autofocus en móvil cuando eso cause zoom
   - inputs de 16px en móvil donde aplique
3. Mover “Cerrar turno” al lado de tabs superiores si mejora alineación y espacio.
4. Ocultar o reubicar el botón “?” en móvil si estorba.
5. Eliminar/reducir franja inferior inútil si sigue existiendo.
6. Maximizar área visible para productos/SKUs.
7. En POS > Consultas:
   - NO duplicar agendado
   - sí permitir localizar / cobrar consultas ya registradas
   - si hace falta, agregar botón “Ir a agenda”
8. Corregir layout de fecha/hora y cualquier traslape restante.
9. Revisar y corregir el campo de teléfono del cliente:
   - si debe buscar cliente existente, que funcione
   - si debe autocompletar, que funcione
   - si solo valida, que quede claro
   - si hoy no dispara nada, corregir el binding / lógica / UX

==================================================
BLOQUE D — DASHBOARD / REPORTES / KPIs
==================================================

Problemas reportados:
- En dashboard y reportes, la navegación secundaria / submódulos se ve mal acomodada, poco profesional, con iconos/títulos mal alineados.
- “Proyecto Farma · inversión” se mezcla como si fuera otro submódulo.
- Los KPIs superiores están mal organizados.
- El cuadro de “inversión del proyecto” NO debe estar en “Resumen de periodo”; para eso existe “Proyecto Farma - Inversión”.
- Los valores de algunos KPIs se parten raro (ej. ticket promedio) y visualmente parece que no cuadran.
- Cuando se cambia el tamaño de la página, el layout cambia feo y el sidebar desaparece.

Quiero:
1. Separar contexto de proyecto vs submódulos:
   - “Proyecto Farma / Inversión” como contexto, NO como tab igual a los demás
2. En móvil:
   - tabs/submódulos limpios, alineados y si hace falta scroll horizontal
   - ocultar manijas/reorder en móvil si ensucian
   - labels más cortos si ayuda
3. Reorganizar KPIs:
   - NO mezclar inversión del proyecto en resumen de periodo
   - separar KPIs operativos de KPIs de proyecto / conversión médica
4. Arreglar visualmente KPIs que se rompen / números partidos
5. Revisar si los cálculos visibles parecen inconsistentes por presentación
6. Comportamiento responsive del layout:
   - Desktop: sidebar completo
   - ancho medio/tablet: sidebar colapsado o rail visible
   - móvil: drawer con botón visible
   - el sidebar NO debe desaparecer sin reemplazo claro
   - al redimensionar no debe sentirse como otra app distinta

==================================================
BLOQUE E — NAVEGACIÓN SECUNDARIA / ICONOS / PRESENTACIÓN GENERAL
==================================================

Problemas recurrentes reportados en varias pantallas:
- submódulos mal acomodados
- iconos muy pequeños o desalineados
- títulos movidos
- textos empalmados o partidos feo
- apariencia “chafa” / poco profesional
- existe un icono / botón de ayuda con signo de interrogación en círculo en varias partes del sistema y estorba

Aplica una pasada de pulido en:
- Dashboard / Reportes
- Consultorio
- Metas y precios / Config consultorio
- Inventario / Inventario hub
- cualquier navegación secundaria similar

Quiero:
- tabs/submódulos más uniformes
- iconos consistentes
- labels compactos y elegantes
- active state claro
- evitar varias filas desordenadas de chips
- contexto visual limpio
- quitar el signo de interrogación en círculo donde hoy ensucia la interfaz
- si existe una función de ayuda detrás, moverla a un lugar menos invasivo o dejarla oculta en móvil

==================================================
BLOQUE F — INVENTARIO
==================================================

Problemas reportados:
- “Catálogo / Reabasto / Lotes PEPS” y acciones como “Recibir mercancía / Importar CSV / Plantilla / Exportar CSV / Nuevo producto” se ven mezcladas y desalineadas.
- En móvil se ven como tabs/chips sin jerarquía clara.

Quiero:
1. Separar navegación del módulo (Catálogo / Reabasto / Lotes) de las acciones rápidas.
2. En móvil:
   - tabs arriba bien alineados
   - acciones debajo como botones reales, no tabs
3. Si ayuda, acortar labels:
   - “Recibir mercancía” → “Recibir”
   - “Importar CSV” → “Importar”
   - “Exportar CSV” → “Exportar”
   - “Lotes PEPS” → “Lotes” si no rompe semántica importante
4. “Nuevo producto” como acción principal destacada
5. Grid de acciones uniforme y limpio
6. Mejorar visibilidad general del catálogo móvil

==================================================
BLOQUE G — RH / NÓMINA / HORARIO / EMPLEADOS
==================================================

Problemas reportados:
- En móvil, “Horario semanal” obliga a scroll lateral
- Los nombres de empleados se empalman
- En nómina, deducciones / neto a pagar se salen de márgenes
- Se siente poco legible / apretado

Quiero:
1. En desktop puedes conservar tabla si ya funciona
2. En móvil:
   - cambiar horario semanal a acordeón, tarjetas o vista por empleado sin scroll lateral
   - mejorar presentación de empleados con nombres largos
   - evitar columnas comprimidas
   - hacer nómina más vertical / apilada / wrap limpio
3. Mantener lógica actual de datos/guardado

==================================================
BLOQUE H — CONSULTORIO
==================================================

Problemas reportados:
- Iconos mal alineados
- Labels/títulos rotos o empalmados
- Submódulos como “Lista de espera”, “En consulta”, “Procedimientos”, “Médicos” se ven poco profesionales
- Agenda/citas debe sentirse más viva y clara

Quiero:
- tabs clínicos más limpios y consistentes
- iconografía alineada
- evitar labels partidos en 3 líneas de forma fea
- mejorar percepción profesional del módulo
- integrar la nueva agenda como pieza principal donde corresponda

==================================================
BLOQUE I — ASISTENTE IA
==================================================

Problemas reportados:
- El AI mostraba error de API key
- La barra para escribir no se veía de entrada, había que hacer scroll
- La experiencia en móvil era incómoda

Quiero:
1. Input/composer visible sin scroll previo
2. Layout de chat usable en móvil
3. 100dvh / safe-area / flex correcto si hace falta
4. Estado de error ordenado y claro
5. NO dejar API key hardcodeada en el repo
6. Si ahora depende de REACT_APP_GEMINI_API_KEY o REACT_APP_GEMINI_KEY, dejar documentada esa necesidad
7. Si puedes, deja preparado un camino futuro más seguro (nota/documentación) para evitar exponer la key en frontend, sin rehacer backend ahora

==================================================
BLOQUE J — PWA / INSTALAR APP (TIENDA VS ADMIN)
==================================================

Problema reportado:
- Al seguir “Instalar app”, se instaló la Tienda (/), no el Admin (/admin), que es lo que se quería.
- Debe poder quedar claro o soportado instalar:
  - Tienda
  - Admin

Quiero:
1. Revisar manifest / start_url / instalación actual
2. Implementar una solución clara para distinguir:
   - FarmaCapital Tienda
   - FarmaCapital Admin
3. En la UI de Instalar app mostrar ambas opciones
4. Explicar brevemente cómo instalar cada una
5. Si el navegador (especialmente Safari/iPhone) tiene limitaciones para dos PWAs desde el mismo dominio, documentarlo claramente
6. No romper la PWA actual

==================================================
BLOQUE K — PEDIDOS ONLINE INTERMITENTE
==================================================

Problema reportado:
- “Pedidos en línea” en un momento no funcionó; tras reiniciar/refrescar la página, volvió a funcionar.
- Puede ser algo intermitente de carga/estado/cache.

Quiero:
1. Revisar si hay causas obvias en frontend:
   - race conditions
   - estado no inicializado
   - dependencia de recarga
   - cache / service worker / fetch inicial
2. Aplicar fixes seguros si detectas algo claro
3. Si no se puede cerrar del todo sin reproducirlo, documenta hipótesis y deja defensas razonables (retry / refresh state / mejor manejo de loading) donde sea de bajo riesgo

==================================================
BLOQUE L — POS / MEDICAMENTOS CONTROLADOS VS NO CONTROLADOS
==================================================

Problema reportado:
- La lógica de productos/medicamentos controlados vs no controlados en POS parece estar mal.

Quiero:
1. Revisar cómo se clasifica hoy un producto en frontend:
   - controlado
   - sujeto a receta / antibiótico
   - no controlado / OTC
2. Ver si la UX/flujo del POS está mezclando cosas que no corresponden
3. Corregir lo que sea claro a nivel de lógica visual / validaciones front si aplica
4. No inventar un backend enorme
5. Si depende de estructura de datos que no esté clara, documenta el hallazgo y deja propuesta concreta

==================================================
BLOQUE M — CATÁLOGO / MÁS SKUs
==================================================

Problema reportado:
- El catálogo se siente corto.
- Se quiere ampliar especialmente:
  - vitaminas comunes de farmacia
  - electrolitos / sueros orales
  - y revisar si el surtido general está corto

Quiero:
1. Revisar si existe catálogo/seed/listado en repo que sí se pueda ampliar desde código
2. Si existe, agregar de forma ordenada familias mínimas útiles, especialmente:
   - multivitamínicos
   - vitamina C
   - vitamina D / D3
   - complejo B
   - multivitamínicos pediátricos
   - prenatal / ácido fólico si aplica
   - electrolitos orales / sueros / sobres / pediátricos / sin azúcar
3. Si el catálogo real vive 100% en Supabase y no en el repo:
   - NO inventes datos en la UI sin fuente real
   - crea una propuesta/archivo auxiliar/seed/CSV/SQL/documento con SKUs recomendados para importar después
4. El objetivo es que el sistema quede listo para ampliar mejor el surtido, no dejarlo corto

==================================================
VALIDACIÓN FINAL
==================================================

Después de aplicar cambios:
1. corre npm run build
2. si procede, corre tests
3. si Playwright móvil ya existe, úsalo o amplíalo cuando sirva
4. busca errores de consola obvios
5. resume qué se corrigió y qué quedó pendiente manual

==================================================
ENTREGABLE FINAL
==================================================

Quiero que me entregues:
1. Resumen ejecutivo corto
2. Lista de hallazgos atacados
3. Archivos modificados
4. Qué cambiaste en cada archivo
5. Qué sigue pendiente manual
6. Resultado de build/tests/Playwright
7. Clasificación final general de esta ronda
8. Si agregaste propuesta de catálogo/SKUs, dónde quedó

NO te quedes en recomendaciones.
Analiza el repo y aplica fixes seguros y coherentes con estos hallazgos acumulados.
