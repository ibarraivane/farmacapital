# Auditoría pre go-live — FARMAX (React + Supabase)

Fecha de referencia: abril 2026.

## Resumen ejecutivo

El riesgo principal antes de producción era que el **cliente web** (rol `anon` / `authenticated` con la publishable key) pudiera invocar RPCs **base** que reciben `p_user_id` sin validar sesión, o escribir en tablas que deben alimentarse solo desde servidor. En código se neutralizaron varios caminos legacy; en base de datos la migración **`sql/refactor_fase6f_hardening_execute_grants.sql`** revoca `EXECUTE` al cliente sobre las funciones base listadas y normaliza permisos de las envolturas **`*_secure`**.

## Hallazgos corregidos

- **RPCs base (inventario / venta)**: el script F6f revoca `EXECUTE` a `public`, `anon` y `authenticated` sobre `create_sale_transaction`, `create_sale_transaction_v2`, `abrir_caja_lote`, `adjust_stock_via_lotes`, `consume_stock_via_lotes`, `create_producto_with_lote`, `receive_merchandise_lote`. `service_role` mantiene grants previos si ya existían.
- **Wrappers `*_secure`**: se revoca `EXECUTE` a `PUBLIC` y se reafirma `EXECUTE` para `anon`, `authenticated` y `service_role`.
- **Frontend**: rutas que insertaban auditoría, movimientos o eventos desde el navegador, o reconstruían `sales_read_model` en producción, quedaron neutralizadas o acotadas (ver sección siguiente).

## Hallazgos pendientes

- **Aplicar F6f en Supabase** (proyecto remoto): hasta ejecutar el SQL, los grants antiguos pueden seguir vigentes.
- **Otras RPCs** no cubiertas por F6f (p. ej. otras firmas con `bigint` de actor, o funciones nuevas): revisar cada migración.
- **`marcar_pedido_listo`**, `restock_via_lote`, `get_lote_fefo`, etc.: no forman parte de este script F6f; valorar endurecimiento aparte si aún son invocables con privilegios de cliente.

## Funciones canónicas cliente (`*_secure`)

Para ventas POS, apertura de caja, ajustes y recepción con validación de sesión, el cliente debe usar:

| Función |
|--------|
| `create_sale_transaction_secure` |
| `abrir_caja_secure` |
| `restock_via_lote_secure` |
| `adjust_stock_secure` |
| `create_producto_secure` |
| `receive_merchandise_secure` |
| `consume_stock_secure` |

Todas reciben `p_session_token` (uuid) y delegan en la lógica interna con usuario resuelto en servidor.

## Código frontend legado neutralizado

- **`logAudit` / `logMovimiento`** (`src/utils.js`): no realizan `INSERT` al esquema público desde el navegador; en desarrollo pueden advertir una sola vez por consola.
- **`initEventStore`**: valida eventos en el bus; la persistencia en `event_log` no debe hacerse desde el cliente anónimo/autenticado de app.
- **`syncSalesModel`**: en producción desde el navegador no debe borrar/reinsertar `sales_read_model` salvo uso explícito de opciones de desarrollo/utilidad.

## Riesgos futuros

- **Nuevas RPCs** con `p_user_id bigint` y `GRANT` a `anon`/`authenticated` reabren suplantación trivial.
- **Filtrar `service_role`** al bundle del frontend o a repos públicos.
- **Regresiones**: tests o scripts que llamen firmas base desde el cliente fallarán tras F6f; migrar llamadas a `*_secure` o a jobs con `service_role`.

## Checklist corto de go-live

- [ ] Ejecutar `sql/refactor_fase6f_hardening_execute_grants.sql` en Supabase (revisar errores de firma si el DDL local difiere).
- [ ] Probar POS: venta, abrir caja, ajuste de stock, alta de producto, recepción de mercancía vía RPCs `*_secure`.
- [ ] Confirmar que ningún flujo productivo depende de las firmas base revocadas.
- [ ] Verificar RLS, auditoría (F6d/F6e) y backups según runbook del proyecto.
- [ ] Rotación y secretos: `service_role` solo en servidor; anon key solo en cliente.
