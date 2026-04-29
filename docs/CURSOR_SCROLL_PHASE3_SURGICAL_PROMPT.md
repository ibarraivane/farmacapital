Quiero una tercera ronda quirúrgica para el problema de scroll móvil en FARMAX, basada en los diffs reales de la fase anterior.

CONTEXTO REAL
Ya hubo una segunda ronda, pero el resultado quedó incompleto.

Difusión real del último cambio:
- ClientesModule.jsx: sí cambió overflowY:auto a visible en móvil en algunos contenedores. Bien.
- POS.jsx: sí cambió height/max-height rígidos en móvil a auto/none y añadió touchAction. Bien.
- Admin.jsx: solo agregó touchAction:"pan-y" en root y main. Eso es insuficiente.
- AsistenteIA.jsx: NO fue modificado, aunque el resumen decía que sí. Eso está mal.

OBJETIVO
No rehacer todo.
Quiero atacar SOLO lo pendiente real:
1. src/Admin.jsx
2. src/AsistenteIA.jsx
Y revisar si hace falta un ajuste final menor en:
3. src/ClientesModule.jsx
4. src/modules/sales/pos/POS.jsx

PROBLEMA TÉCNICO
El patrón de fondo sigue siendo:
- min-height / height / max-height con 100vh / 100dvh
- wrappers con overflowY:auto o overflow:hidden
- scroll anidado
- shell móvil rígido

Lo ya hecho en Clientes y POS puede ayudar.
Lo pendiente serio sigue siendo Admin shell y Asistente IA.

QUÉ QUIERO QUE HAGAS

A. Admin.jsx
1. Revisa el shell móvil completo.
2. No basta con touchAction:"pan-y".
3. Evalúa si farmax-admin-root / farmax-admin-main / sidebar siguen atrapando el scroll por:
   - min-height 100vh / 100dvh
   - height / max-height
   - overflow en capas internas
4. Corrige el patrón móvil para que el shell no se comporte como contenedor rígido que compite con el scroll del viewport.
5. Mantén desktop funcional.

B. AsistenteIA.jsx
1. Revisa el layout del chat en móvil.
2. Hoy NO fue tocado y sigue siendo sospechoso por:
   - height / maxHeight / minHeight con 100dvh
   - área interna de mensajes con overflowY
3. Corrige el patrón para que:
   - el chat no congele el scroll
   - el teclado no rompa el layout
   - la barra inferior siga usable
4. Mantén experiencia de chat buena en móvil.

C. ClientesModule.jsx
1. Solo revisa si queda algún contenedor interno móvil con overflow innecesario.
2. No rehagas lo que ya quedó bien.

D. POS.jsx
1. Solo revisa si todavía hay un punto de scroll anidado fuerte.
2. No rehagas el cambio si ya está mejor.
3. Asegúrate de que el área principal en móvil no siga atrapando el gesto.

IMPORTANTE
- No me des un resumen inflado.
- Quiero cambios reales y verificables.
- No afirmes que tocaste archivos que no tocaste.
- Si modificas un archivo, que el diff lo refleje claramente.
- No hagas refactor masivo.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre npm run build
2. dime exactamente:
   - qué archivos sí modificaste
   - qué patrón corregiste en cada uno
   - qué sigue pendiente manual
3. No incluyas archivos no modificados en el resumen.

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto y preciso
2. Archivos realmente modificados
3. Qué cambiaste en cada uno
4. Resultado de build
