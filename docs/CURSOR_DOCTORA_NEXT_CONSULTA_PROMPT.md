Quiero corregir específicamente el flujo principal del perfil de la doctora en FARMACAPITAL porque hoy no está resuelto correctamente.

PROBLEMA REAL
En el perfil de la doctora no está bien resuelto cómo entrar a la consulta que sigue.
Eso es lo más importante del flujo clínico y debe quedar claro y usable.

LO QUE QUIERO EXACTAMENTE

1. La pantalla principal de la doctora debe ser una vista operativa del día.
2. En esa vista debe poder ver:
   - sus consultas del día
   - ordenadas por hora
   - con estado visible
3. Debe existir una acción principal muy clara para la siguiente consulta:
   - "Entrar a consulta"
   o
   - "Iniciar consulta"
4. Esa acción debe estar disponible en la cita que sigue o en cualquier cita pagada/lista para atender.
5. Si la cita no está pagada, no debe poder avanzar clínicamente, o debe verse claramente bloqueada por pago pendiente.

FLUJO CORRECTO DE LA DOCTORA

A. Vista inicial doctora
Quiero que vea algo como:
- Próxima consulta
- Consultas del día
- Estado de cada cita
- Botón claro para entrar a la consulta activa / siguiente

B. Estados útiles
Las citas deben mostrar de forma clara estados como:
- confirmada
- pagada
- en espera
- en consulta
- atendida
- cancelada
- no asistió (si existe)

C. Regla principal
- La cita la agenda el cliente o el vendedor
- La doctora NO agenda
- La doctora NO cobra
- La doctora solo entra a la consulta cuando esté lista
- "Pagada" significa que la consulta ya puede avanzar

D. Acción “Entrar / Iniciar consulta”
Al dar clic en la siguiente consulta:
- se abre la ficha clínica activa del paciente
- no una agenda genérica
- debe abrir directamente una vista clínica con:
  - datos del paciente
  - motivo de consulta
  - signos vitales
  - diagnóstico
  - receta
  - observaciones

E. Inicio de consulta
Cuando la doctora entra/inicia:
- registrar timestamp de inicio
- asociar esa consulta a la cita y al expediente del paciente

F. Guardar / terminar
Al guardar o terminar:
- guardar consulta en expediente general del paciente
- guardar signos vitales
- guardar receta
- guardar diagnóstico
- registrar duración total
- marcar consulta como atendida
- permitir pasar a la siguiente consulta del día

G. UX que quiero
- La doctora no debe perder tiempo navegando entre módulos
- La próxima consulta debe estar visible
- Debe haber un flujo simple:
  1. ver siguiente consulta
  2. entrar
  3. atender
  4. guardar/terminar
  5. pasar a la siguiente

H. Sidebar doctora
Debe quedar simplificado:
- Agenda médica
- Expedientes / Pacientes
Nada de:
- PWA
- POS
- Caja
- Transacciones
- Cobro consulta

QUÉ QUIERO QUE HAGAS
1. Revisa cómo está hoy el perfil doctora.
2. Corrige la pantalla principal para que realmente permita entrar a la consulta que sigue.
3. Haz que la vista de agenda del día sea operativa y no solo informativa.
4. Asegura que el botón de entrar/iniciar consulta funcione con la lógica correcta.
5. Si hoy ya existe parte del flujo clínico, reutilízalo.
6. No hagas un refactor masivo.
7. Corre build al final.

ARCHIVOS PROBABLEMENTE IMPORTANTES
- src/modules/clinical/AgendaConsultasModule.jsx
- src/modules/clinical/ConsDoctora.jsx
- src/Admin.jsx
- src/constants.js
- src/utils/permissions.js
- cualquier módulo de expediente/consulta real

ENTREGABLE FINAL
Quiero que me entregues:
1. Resumen ejecutivo corto
2. Cómo quedó resuelto el acceso a la siguiente consulta
3. Archivos modificados
4. Qué cambiaste en cada archivo
5. Resultado de build
