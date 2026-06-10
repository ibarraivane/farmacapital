Quiero que hagas una auditoría integral, profunda y FULL STACK de toda la aplicación FARMACAPITAL.

IMPORTANTE
No quiero una revisión superficial.
No quiero solo frontend.
No quiero solo UX.
Quiero una auditoría completa de:
- frontend
- backend
- base de datos
- permisos
- flujos end-to-end
- mobile
- laptop/desktop
- operación real de farmacia
- consultorio
- POS
- tienda online
- administración
- RH
- reportes
- banners/promociones
- cumplimiento sanitario/fiscal
- integridad de datos

==================================================
OBJETIVO GENERAL
==================================================

Auditar FARMACAPITAL como sistema real FULL STACK, no solo como app visual.

Quiero revisar:
- la experiencia visible
- la lógica interna
- la consistencia entre frontend y backend
- la integridad de datos
- la seguridad
- los permisos por rol
- los flujos reales de farmacia
- la experiencia en móvil y laptop
- la coherencia entre módulos
- la preparación para crecer y operar bien

==================================================
ALCANCE COMPLETO (FULL STACK)
==================================================

Quiero que revises TODO lo que aplique en estas capas:

1. FRONTEND
- componentes
- pantallas
- navegación
- UX/UI
- responsive
- mobile
- laptop/desktop
- accesibilidad
- estados de error/vacío/carga
- consistencia visual
- formularios
- modales
- tablas
- sidebars
- cards
- flows por usuario

2. BACKEND / LÓGICA DE NEGOCIO
- lógica de permisos
- llamadas a Supabase
- queries
- RPCs
- edge functions si existen
- validaciones
- consistencia entre módulos
- seguridad del flujo
- dependencias entre frontend y backend

3. BASE DE DATOS / STORAGE / DATOS
- tablas
- columnas
- relaciones
- integridad de datos
- columnas faltantes o mal usadas
- importadores CSV
- carga de imágenes
- buckets/storage
- trazabilidad
- bitácoras
- estados inconsistentes
- posibilidad de datos huérfanos o duplicados

4. SEGURIDAD / CONTROL DE ACCESO
- rutas
- acciones sensibles
- roles
- permisos reales
- exposición de datos
- errores visibles
- malas prácticas
- funciones sensibles expuestas
- validación de inputs
- auditoría con mentalidad OWASP / AppSec

5. OPERACIÓN REAL
- farmacia
- mostrador
- consultorio
- venta
- agenda
- expediente
- inventario
- RH
- facturación
- banners/promociones
- tienda online
- experiencia de cliente
- experiencia de vendedor
- experiencia de doctora
- experiencia de admin

==================================================
EJE 1 — AUDITORÍA POR PERFIL / PERSONA
==================================================

Analiza la experiencia, permisos, riesgos y lógica para:

1. CLIENTE WEB
- home
- banners
- catálogo
- búsqueda
- detalle de producto
- carrito
- checkout
- login/registro
- cuenta
- historial de pedidos
- historial de consultas si aplica
- experiencia en móvil
- experiencia en laptop

2. VENDEDOR / POS
- búsqueda de productos
- venta rápida
- ubicación física del producto
- stock
- receta/controlados/antibióticos
- cobro
- velocidad operativa
- errores comunes
- experiencia móvil/tablet/laptop si aplica

3. DOCTORA
- agenda del día
- acceso a la siguiente consulta
- iniciar consulta
- expediente
- signos vitales
- diagnóstico
- receta
- guardar/terminar consulta
- duración/log
- historial clínico
- indicadores
- vista doctora vs vista paciente
- que no vea funciones que no le corresponden

4. ADMINISTRADOR
- dashboard
- navegación
- control general
- inventario
- usuarios
- reportes
- banners
- promociones
- configuración
- alertas
- trazabilidad
- sensación real de control del negocio

5. RH / NÓMINA
- empleados
- comisiones
- incidencias
- flujo operativo
- seguridad de datos laborales

6. CONTABILIDAD / FACTURACIÓN
- flujo actual
- trazabilidad
- preparación para CFDI
- relación ticket/venta/factura
- riesgos si se activa facturación

==================================================
EJE 2 — AUDITORÍA TRANSVERSAL
==================================================

A. FRONTEND
- claridad de pantallas
- consistencia UI
- navegación
- responsive
- mobile
- laptop
- estados de carga/error
- modales
- tablas
- formularios
- componentes base

B. BACKEND
- queries
- RPCs
- edge functions
- lógica de negocio real
- consistencia con frontend
- errores silenciosos
- validaciones faltantes
- dependencias peligrosas

C. BASE DE DATOS / STORAGE
- modelo de datos
- relaciones
- campos que faltan
- campos que no usa el frontend
- importadores CSV
- mapeos
- imágenes
- storage buckets
- URLs
- integridad

D. SEGURIDAD
- roles
- rutas
- acciones restringidas
- control de acceso
- exposición de datos
- logs
- secrets
- funciones inseguras
- errores de seguridad
- revisar con mentalidad OWASP

E. UX/UI
- claridad
- pasos innecesarios
- módulos confusos
- botones ambiguos
- información mal jerarquizada
- problemas visuales o funcionales que afecten productividad

F. MOBILE
- scroll
- touch
- cards
- modales
- sidebars
- teclado
- formularios
- objetivos táctiles
- performance percibido
- experiencia real con dedo

G. LAPTOP / DESKTOP
- layouts amplios
- tablas
- navegación lateral
- productividad
- uso intensivo por admin/vendedor/doctora
- consistencia de pantallas grandes

H. ACCESIBILIDAD
- contraste
- labels
- focus
- teclado
- semántica
- componentes custom
- estructura entendible

I. OPERACIÓN DE FARMACIA REAL
- búsqueda por principio activo / genérico / marca
- ubicación física del producto
- stock mínimo
- caducidad/lotes
- restricciones por medicamento
- coherencia entre tienda y sucursal
- separación farmacia/minisúper

J. CONSULTORIO / CLÍNICA
- citas
- estados
- pago
- inicio de consulta
- expediente
- historia clínica
- indicadores
- receta
- duración/log
- vista paciente vs vista doctora

K. DATOS / INTEGRIDAD / AUDITORÍA
- consistencia entre pedido/venta/stock
- consistencia entre cita/consulta/expediente
- consistencia entre usuario/rol/permisos
- importaciones
- duplicados
- datos huérfanos
- bitácoras
- evidencia de acciones

L. RENDIMIENTO
- pantallas pesadas
- listas grandes
- búsqueda
- imágenes
- carga inicial
- experiencia móvil
- chunks
- renders innecesarios

M. FACTURACIÓN / FISCAL
- preparación real para CFDI
- faltantes críticos
- trazabilidad
- errores operativos/fiscales potenciales

N. CUMPLIMIENTO / REGULATORIO
- puntos delicados de farmacia/consultorio
- riesgos evidentes
- controles faltantes
- advertencias necesarias

==================================================
MODO MÓVIL Y MODO LAPTOP
==================================================

Quiero que explícitamente revises ambas experiencias:

1. MODO MÓVIL
- iPhone/Android style usage
- touch
- scroll
- teclado
- cards
- modales
- sidebars
- velocidad de operación
- facilidad de uso real con dedo

2. MODO LAPTOP / DESKTOP
- navegación administrativa
- productividad
- tablas
- uso intensivo por admin/vendedor/doctora
- distribución de espacios
- eficiencia real de trabajo

No quiero que revises solo una vista.
Quiero que compares:
- qué funciona en laptop pero falla en móvil
- qué está bien en móvil pero mal en laptop
- qué módulos no escalan bien entre ambos modos

==================================================
ENTREGABLES QUE QUIERO
==================================================

Quiero que me entregues una auditoría estructurada así:

1. RESUMEN EJECUTIVO
- nivel de madurez de FARMACAPITAL
- fortalezas
- debilidades
- riesgos principales

2. MAPA DEL SISTEMA
- módulos
- roles
- capa frontend
- capa backend
- capa datos
- cómo se conectan

3. HALLAZGOS POR PERFIL
- cliente
- vendedor
- doctora
- admin
- RH
- contabilidad

4. HALLAZGOS POR CAPA
- frontend
- backend
- base de datos / storage
- seguridad
- UX/UI
- mobile
- laptop
- datos
- operación
- cumplimiento
- rendimiento

5. PRIORIZACIÓN
Clasifica hallazgos como:
- crítico
- alto
- medio
- bajo

y por categoría:
- frontend
- backend
- datos
- seguridad
- UX
- mobile
- laptop
- operación
- regulatorio
- rendimiento

6. QUICK WINS
- arreglos pequeños con alto impacto

7. MEJORAS IMPORTANTES
- cambios grandes que sí valen la pena
- sin proponer refactor masivo innecesario

8. COSAS QUE NO RECOMIENDAS TOCAR
- si algo está bien, dilo
- no quiero cambios por cambiar

9. PLAN DE REMEDIACIÓN
- por fases o sprints
- con orden sugerido

10. VALIDACIÓN FINAL
- corre build
- revisa imports rotos
- documenta puntos que requieren QA manual real

==================================================
REGLAS IMPORTANTES
==================================================

- No quiero una auditoría superficial.
- No quiero una auditoría inflada o genérica.
- No quiero que te quedes solo en frontend.
- No quiero que ignores backend o datos.
- Quiero visión FULL STACK.
- Quiero visión de negocio/operación real.
- Quiero visión mobile y laptop.
- No propongas refactor masivo por defecto.
- Si algo está bien, dilo.
- Si algo está crítico, señálalo fuerte.
- Si algo necesita validación manual real, márcalo.

==================================================
ARCHIVOS / ZONAS QUE DEBES REVISAR
==================================================

- src/Tienda.jsx
- src/Admin.jsx
- src/InventarioModule.jsx
- src/ClientesModule.jsx
- src/RRHHModule.jsx
- src/modules/sales/pos/POS.jsx
- src/modules/clinical/*
- reportes
- banners/promociones
- módulos de facturación / COFEPRIS
- importadores CSV
- componentes UI base
- hooks/utilidades
- lógica de permisos/roles/rutas
- supabase.js
- RPCs / SQL / migrations si existen
- storage / image upload
- cualquier edge function o lógica backend equivalente

==================================================
ENTREGABLE FINAL
==================================================

Quiero:
1. Resumen ejecutivo corto
2. Auditoría completa FULL STACK
3. Riesgos críticos
4. Quick wins
5. Plan de remediación por fases
6. Resultado de build
