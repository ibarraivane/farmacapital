Quiero continuar la remediación de lecturas directas a RPCs seguras en FARMACAPITAL, enfocándome ahora en la capa clínica / consultorio (P2).

CONTEXTO
Ya se migró P0 y P1 de módulos más críticos de tienda, POS y admin.
El grep actual de lecturas directas sensibles en src/ muestra remanentes principales en:

- src/modules/clinical/ConsultorioModule.jsx
- src/modules/clinical/AgendaConsultasModule.jsx
- src/hooks/useSidebarBadges.js

TABLAS AFECTADAS
- citas
- procedimientos_medicos
- medicos
- cortes_caja

OBJETIVO
Eliminar estas lecturas directas sensibles y reemplazarlas por RPCs seguras, sin romper el flujo clínico ni el sidebar.

PRIORIDAD

P2-A (más importante)
1. src/modules/clinical/ConsultorioModule.jsx
2. src/modules/clinical/AgendaConsultasModule.jsx

P2-B (remate)
3. src/hooks/useSidebarBadges.js

QUÉ QUIERO QUE HAGAS

1. Revisa las lecturas directas actuales en esos archivos.
2. Diseña RPCs mínimas y seguras para cubrir estos casos clínicos, por ejemplo:
   - empleado_listar_cita_en_consulta_hoy
   - empleado_listar_citas_previas_paciente
   - empleado_listar_procedimientos_medicos
   - empleado_listar_medicos_activos
   - empleado_count_cortes_con_diferencia o equivalente para badges
   (ajusta nombres si ya existe algo parecido)

3. Crea el SQL necesario en sql/ con nombre claro.
4. Migra esos módulos a usar RPCs.
5. No hagas refactor masivo.
6. No rompas la UX clínica.
7. Mantén build funcionando.
8. Documenta qué quedó migrado y qué sigue pendiente.

IMPORTANTE
- El foco principal es la doctora/consultorio.
- No quiero romper agenda, consulta ni expediente.
- Si algún flujo requiere más de una RPC, documenta claramente por qué.
- Si el badge de sidebar necesita una RPC pequeña aparte, hazla.

VALIDACIÓN FINAL
Después de aplicar cambios:
1. corre npm run build
2. deja un resumen claro de:
   - RPCs nuevas creadas
   - archivos frontend modificados
   - qué lecturas directas fueron eliminadas
   - qué quedó pendiente
   - resultado de build

ENTREGABLE FINAL
Quiero:
1. Resumen ejecutivo corto
2. Qué quedó migrado en P2
3. SQL adicional creado
4. Archivos modificados
5. Qué sigue pendiente
6. Resultado de build
