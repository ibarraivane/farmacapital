Quiero que corrijas el problema de scroll móvil de FARMACAPITAL con base en hallazgos reales del repo. No quiero una revisión superficial. Quiero atacar el patrón técnico que está causando que el scroll se atore en varias pantallas.

HALLAZGOS REALES DEL REPO
Se detectaron múltiples pantallas con este patrón problemático:
- wrapper con min-height / height / max-height en 100vh o 100dvh
- uno o más contenedores internos con overflowY:auto
- algunos subpaneles con overflow:hidden u overflowY:auto adicionales
Esto genera scroll anidado y en móvil el gesto se atora.

ARCHIVOS SOSPECHOSOS PRINCIPALES

1. src/Admin.jsx
Hallazgos:
- .farmacapital-admin-root con min-height:100vh / 100dvh
- layout con height:100vh / 100dvh y max-height
- sidebar / zonas internas con overflowY:auto

2. src/ClientesModule.jsx
Hallazgos:
- wrapper móvil con minHeight 100dvh
- overflow:auto en móvil
- contenedores internos con overflowY:auto
- bloques con overflow:hidden adicionales

3. src/modules/sales/pos/POS.jsx
Hallazgos:
- height/max-height calculado con 100dvh
- overflow-y:auto en contenedor principal
- scroll interno fuerte en móvil

4. src/AsistenteIA.jsx
Hallazgos:
- minHeight/maxHeight/height = 100dvh
- chat interno con overflowY:auto

5. Revisar también patrones similares en módulos clínicos y admin donde se repita:
- min-height 100vh/100dvh
- overflowY:auto
- nested scroll containers

PROBLEMA A RESOLVER
El scroll móvil se atora porque varias pantallas están construidas como mini-apps con altura fija + scroll interno, en lugar de usar un patrón más estable para móvil.

OBJETIVO
Implementar un fix de patrón:
- que cada pantalla móvil tenga un solo scroll vertical principal cuando sea posible
- reducir scrolls anidados
- mantener scroll interno solo en modales o casos muy puntuales
- no romper desktop

QUÉ QUIERO QUE HAGAS

1. Audita y corrige especialmente:
- src/Admin.jsx
- src/ClientesModule.jsx
- src/modules/sales/pos/POS.jsx
- src/AsistenteIA.jsx

2. Revisa si el patrón de estos módulos debe cambiar a:
- wrapper con min-height:100dvh
- sin height/max-height rígidos en la pantalla completa
- overflow visible o natural en el wrapper principal
- un solo contenedor scrolleable por vista

3. Corrige scroll anidado en móvil:
- elimina overflowY:auto innecesarios en capas intermedias
- evita combinaciones tipo:
  wrapper 100dvh + child overflowY:auto + grandchild overflowY:auto

4. Mantén scroll interno solo donde sí tiene sentido:
- modales
- paneles de resultados muy específicos
- listas largas puntuales
- tablas horizontales

5. No hagas refactor masivo.
6. Mantén desktop funcional.
7. Corre build al final.

TIPO DE CAMBIO QUE QUIERO
- fixes técnicos reales
- no cambios cosméticos
- no solo mover CSS sin resolver el patrón base

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre npm run build
2. deja un resumen claro de:
   - causas del scroll atascado
   - archivos modificados
   - qué patrón corregiste
   - qué módulos quedaron estabilizados
3. si algo queda pendiente de QA real en dispositivo, documentarlo

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Causas reales del scroll atascado
3. Archivos modificados
4. Qué cambiaste en cada archivo
5. Resultado de build
