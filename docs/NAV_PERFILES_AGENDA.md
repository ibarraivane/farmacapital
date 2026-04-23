# Navegación por perfil y agenda de consultas (abril 2026)

## Resumen

- **Admin:** menú agrupado por secciones de trabajo (sin “vistas por rol”). Nuevos ítems: `agenda`, `trans` (Transacciones), `ped_online` (Pedidos online → POS pestaña online).
- **Vendedor:** barra operativa con agenda (`agenda`, etiqueta “Consultas del día”), transacciones, pedidos online, sin módulos de gestión estratégica.
- **Doctora:** sigue usando el id `cons_dr` (etiqueta “Agenda médica”); sin cobro en sidebar; mismo componente de agenda que admin/vendedor con variante clínica.
- **Agenda:** calendario mensual + vista por día con slots (`TODOS_HORARIOS_CITA`) + detalle; estados visuales mapeados sobre `citas.estado` y `pago_estado` existentes (sin cambios SQL).

## Mapeo de módulos

| Id | Ruta URL (slug) | Comportamiento |
|----|-----------------|----------------|
| `agenda` | `/admin/agenda-consultas` | Calendario + día (admin y vendedor). |
| `cons_dr` | `/admin/mi-consultorio` | Igual módulo de agenda; perfil doctora. Admin con sesión/ruta vieja `cons_dr` se redirige a `agenda`. |
| `trans` | `/admin/transacciones` | `TransaccionesTab` (antes solo en pestaña del dashboard). |
| `ped_online` | `/admin/pedidos-online` | `POS` con `initialTab="online"`. |

## Estados de cita (UI)

Los valores reales vienen de la tabla `citas`. La UI agrupa así:

- **Cancelada** → `estado === "cancelada"`.
- **Pagada** → `estado === "pagada"` o `pago_estado === "pagada"`.
- **Pendiente de cobro** → `estado === "completada"` y aún sin pago (`citaPagoPendiente`).
- **Atendida** → `completada` y pagada o sin pendiente según reglas de `consultaConstants`.
- **En consulta** → `en_consulta`.
- **Agendada (sin pago)** / confirmada → `confirmada` sin pago registrado.
- Huecos **Disponibles** vs “no disponible (pasado)” según `horariosDisponiblesCita`.

No se añadieron columnas ni RPCs nuevos.

## Riesgos / decisiones

1. **Orden del menú admin:** el arrastre personalizado entre ítems se retiró; el orden dentro de cada sección sigue el orden canónico en `NAV_ADMIN`. El botón “Restaurar lista de módulos” limpia `localStorage` del orden guardado.
2. **Migración `cons_dr` → `agenda`:** solo para rol `admin` (sesión y deep link).
3. **CitaFicha clínica:** admin y doctora abren `CitaFichaModal`; vendedor usa modal operativo y enlace a “Cobrar consulta”.
4. **Nuevas citas desde agenda:** RPC `crear_cita` con `canal: "mostrador"` (igual que flujo de mostrador en POS).
5. **“Reportes”** del brief de negocio no tienen id propio: siguen en las pestañas del **Dashboard** (`dash`).

## Archivos tocados (referencia)

- `src/constants.js` — `NAV_ADMIN`, `NAV_VENDEDOR`, `NAV_DOCTORA`, `ADMIN_NAV_SECTIONS`, ítems `agenda`, `trans`, `ped_online`.
- `src/utils/permissions.js` — whitelist vendedor.
- `src/utils/adminNavOrder.js` — normaliza `cons_dr` guardado a `agenda` en orden admin.
- `src/shared/adminRoutes.js` — slugs nuevos.
- `src/hooks/useSidebarBadges.js` — badge de pedidos en `ped_online`.
- `src/Admin.jsx` — sidebar agrupado, rutas `renderPage`, migración admin.
- `src/modules/clinical/AgendaConsultasModule.jsx` — nueva UI de agenda.
- `src/modules/clinical/ConsDoctora.jsx` — reexport hacia `AgendaConsultasModule`.

## Pendiente / mejoras futuras

- Sincronizar vista día ↔ mes al cambiar de mes con flechas si el día seleccionado cae fuera del mes visible (hoy el fetch mensual ya cubre el rango).
- Tour / onboarding si el admin echaba de menos el drag-and-drop del menú.
- Pruebas E2E por perfil (navegación + agenda).
