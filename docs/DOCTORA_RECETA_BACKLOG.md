# Doctora / receta — backlog (Parte C, no implementado)

Implementado en este lote: **C1 seguimiento sugerido** y **C2 alerta de alergias**.
El resto queda documentado aquí. No rehacer lo que ya existe (ficha, expediente, `medicamentos_prescritos`, `recetaCitaSync`).

## Hecho

- **C1** — Seguimiento sugerido (7 / 14 / 30 días + nota). No agenda sola. Se guarda en `citas.seguimiento_*` y viaja al PDF. Visible en expediente.
- **C2** — Alerta al recetar si el nombre del medicamento cruza el texto de alergias. Las alergias también se imprimen en la receta.

## Backlog

### C3 — Interacciones medicamentosas
Cruzar líneas de la receta entre sí (y con antecedentes) con un listado mínimo de pares conocidos. No es un motor tipo Lexicomp.

### C4 — Gráficas de signos en ficha activa
El expediente ya promedia TA / FC / peso. Falta la misma tendencia *dentro* de la consulta en curso (sparkline), sin nueva plataforma.

### C5 — CIE-10
Catálogo corto de diagnósticos frecuentes con clave CIE-10. El campo actual sigue siendo texto libre.

### C6 — Controlados / recetario COFEPRIS
Esta plantilla es **receta ordinaria** (art. 29). Grupo I sigue en recetario oficial + bitácora POS (ya existe al vender controlado). No mezclar.

### C7 — Receta en la cuenta del paciente (tienda)
El paciente ya ve consultas previas. Falta el PDF/folio de su receta en «Mi cuenta», sin datos internos de caja.

### C8 — Firma digital con valor de autógrafa
Hoy: física (default) o canvas. Controlados y antibióticos: tinta + sello. No pretender que el canvas sustituya la firma autógrafa del RIS.

### C9 — Recordatorio automático de seguimiento
C1 solo anota. Un WhatsApp / aviso a mostrador para remarcar la cita sería otro flujo (y no lo agenda la doctora).

### C10 — Vincular usuario `doctora` ↔ fila `medicos`
Hoy el login es el perfil; la cédula vive en Consultorio → Médicos. Un FK evitaría elegir médico en cada receta.

## SQL obligatorio en Supabase

`sql/patch_recetas_doctora_20260902.sql` (no el 20260901: chocaba con `public.recetas` de COFEPRIS).

Sin ese parche: la ficha permite vista previa local y avisa. La cola de POS queda vacía.
