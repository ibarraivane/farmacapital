Quiero que corrijas el perfil de la DOCTORA en FARMAX porque hoy la lógica no está alineada con la operación real del consultorio.

IMPORTANTE
- No quiero refactors grandes de arquitectura.
- No quiero cambiar seguridad SQL agresivamente.
- No quiero romper el flujo actual del sistema.
- Quiero cambios funcionales y visuales seguros, claros y coherentes.
- Si algo no puede cerrarse por completo sin tocar DB/SQL, documenta claramente qué faltaría.
- Mantén compatibilidad con lo ya existente cuando sea posible.

==================================================
DEFINICIÓN FUNCIONAL CORRECTA DEL PERFIL DOCTORA
==================================================

La doctora NO:
- no necesita PWA en el menú
- no agenda citas
- no cobra consultas
- no usa POS
- no usa caja
- no ve transacciones financieras
- no ve módulos administrativos/comerciales

La doctora SÍ:
- ve su agenda médica
- ve expedientes/pacientes
- cuando llega el paciente, da clic en "Iniciar consulta"
- eso abre la consulta clínica activa / expediente del paciente
- captura signos vitales
- captura diagnóstico
- captura receta / indicaciones
- captura observaciones
- al guardar o terminar consulta:
  - se agrega al expediente general del paciente
  - se registra duración de consulta
  - ese tiempo queda visible para administradores/reportes

==================================================
LÓGICA DE LA CITA
==================================================

La cita NO la agenda la doctora.
La cita la agenda:
- el cliente en línea
- o el vendedor en farmacia

Estados deseados:
1. confirmada
   - la cita ya existe y le aparece a la doctora
2. pagada
   - cuando el cliente paga su cita
   - este estatus confirma que la consulta puede avanzar

REGLA IMPORTANTE:
- La doctora puede ver las citas confirmadas
- pero el botón “Iniciar consulta” debe estar habilitado solo si la cita está pagada
  (o dejar un estado visual clarísimo si todavía no está pagada)

==================================================
FLUJO CLÍNICO CORRECTO
==================================================

1. Se crea la cita
2. La cita queda confirmada
3. Cuando se paga, queda pagada
4. La doctora entra a Agenda médica
5. Ve sus citas del día
6. Da clic en "Iniciar consulta"
7. Se abre una pantalla clínica clara con:
   - datos del paciente
   - signos vitales
   - diagnóstico / evolución
   - receta / indicaciones
   - observaciones
8. Al iniciar consulta se registra timestamp de inicio
9. Al guardar/terminar:
   - se guarda la consulta dentro del expediente general del paciente
   - se guarda la receta
   - se guardan signos vitales
   - se registra tiempo total de consulta
   - el estado final de la consulta queda como atendida
10. El log de duración debe servir a administradores/reportes

==================================================
EXPEDIENTE DEL PACIENTE
==================================================

Quiero que el expediente sea el contenedor maestro del historial clínico.

Cada consulta debe quedar como una entrada clínica dentro del expediente del paciente con:
- fecha
- hora
- doctora
- signos vitales
- diagnóstico
- receta
- observaciones
- duración
- estado

Si el paciente ya tiene expediente:
- abrir el existente
Si no tiene:
- crear uno de forma segura y mínima

==================================================
INDICADORES / HISTORIAL CLÍNICO
==================================================

Quiero que cuando el paciente tenga varias consultas, la doctora pueda ver indicadores o gráficas útiles dentro del expediente, por ejemplo:
- peso a lo largo del tiempo
- presión arterial
- glucosa
- temperatura si aplica
- saturación si aplica
- número de consultas previas
- fechas de últimas consultas
- diagnósticos frecuentes
- medicamentos recetados previamente

No quiero una mega plataforma nueva, pero sí una base clínica coherente y más útil que una simple lista plana.

==================================================
CUENTA DEL PACIENTE EN LA TIENDA
==================================================

En la cuenta del paciente (lado tienda / cliente web), quiero que el paciente pueda ver:
- la consulta que tuvo
- diagnóstico
- medicamentos / receta
- indicaciones
- y también indicadores o historial resumido que se vaya formando con consultas previas (por ejemplo signos vitales históricos si es razonable y seguro mostrarlo)

IMPORTANTE:
- separar vista doctora / clínica de vista paciente
- la vista paciente debe ser más limpia y entendible
- no tiene que mostrar exactamente toda la vista clínica interna
- pero sí debe mostrar información útil del historial

==================================================
SIDEBAR CORRECTO DE DOCTORA
==================================================

Quiero que el perfil doctora quede simplificado y limpio:

Debe ver solo:
- Agenda médica
- Expedientes / Pacientes
- Consultorio (solo si realmente aporta algo distinto; si duplica agenda/expediente, simplifícalo)

Debe dejar de ver:
- PWA
- Cobro consulta
- POS
- Caja
- Transacciones
- módulos administrativos/comerciales

Si “Consultorio” y “Agenda médica” hoy duplican funciones, prioriza que:
- Agenda médica sea la entrada principal
- Expedientes/Pacientes sea la vista longitudinal
- y evita duplicidad innecesaria

==================================================
CAMBIOS DE UX/UI QUE QUIERO
==================================================

Quiero que la experiencia de doctora deje de sentirse como agenda genérica y se sienta más clínica.

En particular:
- la agenda médica debe verse clara y profesional
- el botón “Iniciar consulta” debe ser la acción principal
- la consulta activa debe verse como una ficha clínica real, no como un formulario pobre
- separar claramente:
  - agenda
  - consulta activa
  - expediente histórico
- estados de cita claros:
  - confirmada
  - pagada
  - en espera
  - en consulta
  - atendida
  - cancelada
  - no asistió (si aplica)

==================================================
ALCANCE TÉCNICO
==================================================

Revisa especialmente:
- src/Admin.jsx
- src/constants.js
- src/utils/permissions.js
- src/shared/adminRoutes.js
- src/modules/clinical/AgendaConsultasModule.jsx
- src/modules/clinical/ConsDoctora.jsx
- src/modules/clinical/patients/*
- cualquier módulo real de expediente/consulta/receta/signos vitales
- cualquier componente de vista paciente en tienda si ya existe

==================================================
TIPO DE CAMBIOS QUE SÍ QUIERO
==================================================

- corregir sidebar de doctora
- quitar módulos que no le corresponden
- hacer Agenda médica la entrada principal
- hacer “Iniciar consulta” el flujo principal
- guardar consulta en expediente general del paciente
- registrar duración de consulta
- separar claramente vista clínica vs vista paciente
- enriquecer expediente con indicadores/historial
- mejorar UX clínica sin rehacer toda la app

==================================================
TIPO DE CAMBIOS QUE NO QUIERO
==================================================

- no rehacer toda la arquitectura
- no meter un sistema hospitalario gigante
- no cambiar la lógica de cobro a la doctora
- no permitir que la doctora agende
- no permitir que la doctora cobre
- no romper lo que ya funciona en admin/vendedor
- no hacer refactors masivos por estética

==================================================
VALIDACIÓN FINAL
==================================================

Después de aplicar cambios:
1. corre build
2. revisa imports rotos
3. confirma que el perfil doctora:
   - no ve módulos incorrectos
   - sí ve Agenda médica
   - sí puede iniciar consulta
   - sí guarda en expediente
4. deja un resumen claro de:
   - archivos modificados
   - qué cambió
   - qué quedó pendiente
   - resultado de build

==================================================
ENTREGABLE FINAL
==================================================

Quiero que me entregues:
1. Resumen ejecutivo corto
2. Cómo quedó el flujo final de la doctora
3. Archivos modificados
4. Qué cambiaste en cada archivo
5. Qué quedó funcionando
6. Qué quedó pendiente (si aplica)
7. Resultado de build

NO te quedes en recomendaciones.
Analiza el repo e implementa los cambios seguros y coherentes con esta definición funcional correcta del perfil doctora.
