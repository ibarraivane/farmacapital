# Handoff — módulo Finanzas (P&L + flujo de caja)

**Fecha:** 2026-09-04  
**Modo:** análisis primero. **No programes** hasta correr el SQL, pasar la compuerta de la consulta 4 y contestar las ocho preguntas de la Parte 6.

> **Cómo usar este documento:** pégalo completo en Cursor (Composer / Agent, modo *Ask* primero).
> La **Parte 0** es la orden de marcha. Las **Partes 1–2** son hallazgos ya leídos del repo: **no los vuelvas a derivar**.
> Las **cinco fases** están en la Parte 4. **No las hagas de un jalón.**
> La UI acordada está en [`docs/finanzas-maqueta.html`](finanzas-maqueta.html). Ábrela en el navegador antes de dibujar un pixel.
> Las nueve consultas de sólo lectura están en [`sql/diagnostico_finanzas_20260904.sql`](../sql/diagnostico_finanzas_20260904.sql).
> **La Parte 8 manda sobre la Parte 2** en nómina, servicios y “qué es automático en v1”. Se escribió con el resultado real de la consulta 9 (4-sep-2026).

Hay un documento hermano, [`PROMPT_CURSOR_RENTABILIDAD.md`](PROMPT_CURSOR_RENTABILIDAD.md), escrito antes. Cubre redondeo al peso, gastos y la cascada conceptual. **Este archivo gana** en tres puntos donde aquel se quedó corto o se equivocó:

1. El `0.55` ya no está en `DashboardModule.jsx:486` — se extrajo. Las líneas vivas están abajo.
2. Las ventas brutas del P&L **no** salen de los cortes (eso era un error de la maqueta; ver §2.5).
3. `fondo_inicial` nació tarde. Los cortes viejos valen 0 y `total_general` los sobreestima.

Si este documento y el de rentabilidad discrepan en **fuente de datos** o **compuerta**, gana este. El de rentabilidad sigue vigente para redondeo al peso y el esquema propuesto de `gastos` — y eso es la pregunta 7, no una licencia para implementarlo de contrabando.

---

## PARTE 0 — Instrucciones para el agente (leer primero)

Eres un ingeniero senior en **FarmaCapital**: POS + inventario + consultorio de una farmacia en México.

**Stack:** React 18 (CRA, JavaScript, sin TypeScript) · Supabase (Postgres) · Vercel · estilos inline con `C_LIGHT` de `src/constants.js` · sin librería de charts (barras = `div` con ancho %).

**Convenciones que no se negocian:**

- Lectura/escritura sensible por **RPC `security definer`**, nunca `supabase.from(...)` nuevo desde el cliente para costo, utilidad o caja. Primer parámetro: `p_session_token uuid`. Adentro: `fn_require_admin` o `fn_require_empleado`. Token: `sessionStorage.getItem("farmacapital_session_token")`.
- Los RPC de dashboard devuelven **un solo `jsonb`** (patrón *bundle*). El cliente lo desarma con `parseRpcJsonObject` / `parseRpcJsonArray` de `src/utils/rpcJson.js`.
- SQL nuevo en `sql/` con nombre + fecha, **idempotente**. Nunca edites un SQL ya aplicado.
- Dinero: `$()` de `src/utils.js` (`es-MX`, 2 decimales).
- UI reutilizable en `src/ui.jsx`: `KPI`, `KPI_ROW`, `Box`, `Tag`, `Btn`, `SkeletonKPIs`, `SkeletonTable`.

**Antes de escribir una sola línea de código:**

1. Lee este documento entero, abre la maqueta y pega el SQL en Supabase → SQL Editor. Corre **consulta por consulta**. Guarda los resultados.
2. **Compuerta (consulta 4).** Mide qué porcentaje del **ingreso vendido** (pedidos `completado` × `pedido_items`) tiene costo real capturado (`lotes.costo_unitario > 0` vía `lote_id`, o en su defecto `productos.costo > 0`).  
   - Si sale **< 80%**: **detente**. Dilo fuerte. Un P&L con costos faltantes reporta márgenes inflados justo cuando peor están los datos. Lo primero es capturar costos (Recibir / catálogo / lotes), no programar el módulo.  
   - Si sale ≥ 80% pero la cobertura **por lote** es mucho más baja que la del catálogo, dilo también: el P&L va a usar `productos.costo` actual y **se reescribe solo** cada vez que Recibir pise el costo.
3. Confirma contra el esquema real (no adivines) las columnas de: `pedidos`, `pedido_items`, `lotes`, `productos`, `devoluciones`, `devolucion_items`, `cortes_caja`, `nomina_empleados`, `compras`, `recepciones`, `pagos_servicio`, `configuracion`. Si el esquema no cuadra con este documento, **gana el código**. Pregunta; no implementes sobre una suposición.
4. Contesta las preguntas **aún abiertas** de la Parte 6 (1, 2, 5, 6, 7). Las 3, 4 y 8 las cerró la Parte 8 con la consulta 9. No las reabras.
5. Lista discrepancias entre este documento y lo que viste. Luego espera aprobación.

Trabaja **fase por fase**. Al terminar cada fase: `npm run build`, resumen de archivos, **espera aprobación**.

---

## PARTE 1 — Hallazgos ya leídos (archivo:línea)

No vuelvas a grepear esto para “confirmarlo”. Está leído el 4-sep-2026 sobre `main`. Si una línea se movió dos o tres posiciones, el símbolo sigue siendo el mismo.

### 1.1 El `0.55` — la “ganancia neta” es una constante

| Dónde | Qué hace |
|---|---|
| `src/lib/dashboardVentas.js:99` | `gananciaNetaEstMes(ventasMes, ratio = 0.55)` — `return v * factor` |
| `src/lib/dashboardVentas.js:102` | Si el ratio no es finito o es ≤ 0, **vuelve a 0.55** |
| `src/DashboardModule.jsx:591` | `const gananciaMes = gananciaNetaEstMes(ventasMes);` |
| `src/DashboardModule.jsx:794` | `paybackMeses` se calcula con esa ficción |
| `src/DashboardModule.jsx:1046` | KPI “GANANCIA NETA EST. / MES” — subtítulo: *“Aprox. operativa (55% ventas del mes en Operación)”* |
| `src/lib/dashboardVentas.test.js:129-132` | El test **clava** el 55%: `gananciaNetaEstMes(1000) === 550` |

`docs/PROMPT_CURSOR_RENTABILIDAD.md` citaba `DashboardModule.jsx:486`. Esa línea **ya no existe**: el helper se extrajo. No busques el `0.55` en el JSX; vive en `dashboardVentas.js`.

No lee costos. No resta un gasto. Alimenta el payback. Mientras esa función exista, el tablero miente.

### 1.2 `total_general` es GENERATED — y el fondo lo rompe en cortes viejos

Fórmula viva en Postgres (`sql/patch_corte_ciego_fondo_denominaciones.sql:47-51`):

```sql
total_general numeric generated always as
  ((efectivo_declarado - fondo_inicial)
    + total_tarjeta + total_spei + total_mercadopago) stored;
```

`diferencia` es la otra GENERATED (`:40-43`):

```sql
diferencia = efectivo_declarado - (fondo_inicial + efectivo_sistema)
```

El front **no escribe** esos dos campos. `sql/patch_cortes_caja_columnas_reales.sql:59-62` lo dice: los parámetros `p_diferencia` / `p_total_general` se conservan en la firma (el módulo los manda) y solo van a la bitácora. Postgres los recalcula.

Espejo en el cliente, para un corte **nuevo**:

| Dónde | Qué |
|---|---|
| `src/CorteCajaModule.jsx:109-113` | `total_general = (efDec - fondoNum) + tar + mp` — “el fondo no es venta” |
| `src/CorteCajaModule.jsx:500-509` | Comentario explícito: *“total_general es GENERATED”*. El tile de efectivo resta `fondo_inicial` para no inflar con la suma de fondos. **Esta es la “línea 505”.** |
| `src/utils/corteTicket.js:122,155,274` | El ticket de corte imprime `total_general` tal cual viene de la fila |

**La trampa:** `fondo_inicial` se agregó **después** de meses cortando (`sql/patch_corte_ciego_fondo_denominaciones.sql:19-25`, `default 0`). En los cortes viejos vale **0**. Entonces:

```
total_general_viejo = efectivo_declarado - 0 + electrónicos
```

Eso cuenta el fondo (el cambio que ya estaba en el cajón) como si fuera venta. Sobreestima el flujo de caja **por el tamaño del fondo** en cada corte histórico.

La consulta 2 del SQL te dice desde qué fecha `fondo_inicial > 0` de forma estable. **Corta ahí.** No promedies, no imputes, no “asumas $2,000”. Si no hay fecha limpia, el flujo de caja histórico se etiqueta *no confiable* y se arranca desde el primer corte con fondo real.

### 1.3 Jerarquía de costo por lote — la que hay vs. la que debe usarse

**Hoy el dashboard NO usa el lote.** `src/utils/margenVenta.js:37-45` (`costoUnitarioLinea`):

```
costo = productos.costo
si lineaEsVentaUnidad y unidades_por_caja > 1:
    costo = productos.costo / unidades_por_caja
```

No lee `lotes.costo_unitario`. No recibe `costo_lote` del RPC. Un `productos.costo = 0` entra como costo 0 → margen **100%** (`src/DashboardModule.jsx:732-747`).

El RPC `empleado_dashboard_reporte_bundle`, llave `peds_cat` (`sql/patch_dashboard_margen_unidad_20260816.sql:49-80`) manda `productos.costo`, `precio`, `precio_unidad`, `venta_unidad`, `unidades_por_caja`. **No manda `lote_id` ni `costo_lote`.**

**Infraestructura que YA existe y hay que usar:**

| Pieza | Dónde |
|---|---|
| `pedido_items.lote_id → lotes(id)` | `sql/refactor_fase2_dual_write.sql:68-71` |
| Ventas por **caja** persisten `lote_id` | `sql/patch_precio_exclusivo_caducidad_20260824.sql:471-475` (y el parche anterior `sql/patch_create_sale_precio_unidad_regla.sql:347-350`) |
| Ventas por **pieza** (`modo_venta = 'unidad'`) guardan `lote_id = null` | `sql/patch_precio_exclusivo_caducidad_20260824.sql:431-435` |
| Recibir **pisa** `productos.costo` y escribe `lotes.costo_unitario` | `src/RecepcionModule.jsx:769,800,809` (`p_costo` / `p_costo_unitario`) |
| `lotes.costo_unitario` | `sql/schema_inventario.sql:53` |

**Jerarquía obligatoria, en este orden:**

1. `lotes.costo_unitario` vía `pedido_items.lote_id` — costo histórico de esa caja. El correcto.
2. `productos.costo` — respaldo cuando no hay lote o el lote no tiene costo.
3. `null` — **no lo trates como 0.** La línea se marca *sin costo*, se excluye del margen %, y cuenta en el indicador de cobertura.

Ajuste de pieza suelta: `costo_caja / unidades_por_caja`. La heurística `lineaEsVentaUnidad()` (`margenVenta.js:17-34`) ya existe — reutilízala. **No reescribas el archivo.** Extiéndelo para preferir `item.costo_lote` y devolver `null` cuando no hay costo.

`pedido_items.modo_venta` **no existe** (buscado en todo `sql/`: cero `add column`). El modo se usa al vender y se tira. Las piezas sueltas no quedan amarradas a un lote. El COGS de esas líneas cae al respaldo de catálogo, o a *sin costo*.

### 1.4 Dónde vive cada dato

No inventes tablas. Esto es lo que hay:

| Dato | Tabla / origen | Columnas que importan | Quién lo escribe |
|---|---|---|---|
| Venta (ticket) | `pedidos` | `total`, `estado`, `tipo` (`fisica` / `online` / `consulta` / …), `metodo_pago`, `created_at`, `atendido_por` | `create_sale_transaction_v2` / wrappers |
| Renglón vendido | `pedido_items` | `pedido_id`, `producto_id`, `cantidad`, `precio_unitario`, `lote_id` | El mismo RPC. **No** guarda `modo_venta` ni el precio del carrito (lo pisa con el de catálogo: `sql/create_sale_transaction.sql:443-450`) |
| Costo histórico | `lotes` | `costo_unitario`, `cantidad_actual`, `fecha_caducidad` | Recibir / altas |
| Costo de catálogo (se pisa) | `productos` | `costo`, `precio`, `precio_unidad`, `unidades_por_caja`, `venta_unidad`, `categoria` | Recibir pisa; el dashboard de margen lee **solo esto** |
| Dinero contado | `cortes_caja` | `efectivo_declarado`, `efectivo_sistema`, `fondo_inicial`, `total_tarjeta`, `total_spei`, `total_mercadopago`, **`total_general` GENERATED**, **`diferencia` GENERATED**, `anulado_at`, `fecha`, `turno` | `registrar_corte_caja` |
| Devoluciones | `devoluciones` + `devolucion_items` | `total_devuelto`, `estado`, `metodo_reembolso`; items: `producto_id`, `cantidad`, `precio_unitario`. `lote_id` se agregó en `sql/patch_devoluciones_caja_credito_20260820.sql:43` — verifica si el RPC lo persiste | `crear_devolucion` |
| Nómina | `nomina_empleados` | `neto_pagar`, `periodo_inicio`, `periodo_fin`, `pagado` (insert en `sql/refactor_fase6b_rpcs_transacciones.sql:529-538`) | RRHH |
| Compras (documento, no siempre dinero) | `compras` / `compra_items` | `total`, `estado` (`pendiente`…), `costo_unitario` (`sql/refactor_fase1_aditivo.sql:49-71`) | Poco usado frente a Recibir |
| Recibir (lo que de verdad entra) | `recepciones` / `recepcion_items` | `total_ticket`, `estado`, `costo_estimado` (`sql/patch_recepcion_fefo_caducidad_20260821.sql:190-221`) | Recibir |
| Pagos de servicio (CFE, recargas) | `pagos_servicio` | `monto_servicio`, `comision`, `total_cobrado`, `metodo_pago` (`sql/patch_pagos_servicio_pos.sql:8-23`) | POS |
| Sesión de caja | `caja_sesiones` | Abre/cierra turno; el corte encadena desde la sesión (`sql/patch_caja_sesiones_vendedor.sql`) | Abrir/cerrar caja |
| CAPEX del proyecto | **`localStorage`** `farmacapital_proyecto_capex_v1` | `src/DashboardModule.jsx:64-113`, montos default `:67-73` | Admin en la pestaña Proyecto. Se pierde al limpiar el navegador |
| Metas | `configuracion` | `meta_ventas_dia/semana/mes`, etc. (`sql/rpc_p1_lecturas_admin.sql:373-377`) | Dashboard / config |
| **Gastos operativos** | **No existe** `public.gastos` | Cero `create table` en `sql/` | — |
| Ventas acumuladas (el “recuperado” falso) | Bundle operación, llave `ventas_acumuladas` | `sql/rpc_p1_lecturas_admin.sql:395` — `sum(pedidos.total)` de todos los completados | Se muestra como “TOTAL RECUPERADO” en `DashboardModule.jsx:575-589,1045` |

**Universos que no se mezclan:**

```
PEDIDOS / pedido_items     →  P&L (ingreso, COGS, utilidad bruta)
CORTES_CAJA.total_general  →  flujo de caja (dinero que se contó)
RECEPCIONES.total_ticket   →  mercancía que entró (activo, no gasto)
NOMINA / gastos futuros    →  salida operativa
```

### 1.5 Otros huecos que ya están medidos (no reabrirlos)

**(a) El precio del carrito se descarta.** `sql/create_sale_transaction.sql:443-450` (y los parches posteriores hacen lo mismo): `v_db_precio` sale del catálogo. Las promos del POS (`calcularTotalConPromos`) viven en `pedidos.total`. Entonces, con promoción, `SUM(pedido_items.precio_unitario × cantidad) > pedidos.total`. La pestaña Margen suma renglones → ingreso inflado. La consulta 8 lo cuantifica.

**(b) “Total recuperado” son ventas brutas.** `DashboardModule.jsx:575-589` + `rpc_p1_lecturas_admin.sql:395`. Vender $710,000 no recupera $710,000 de CAPEX. Lo que recupera capital es la utilidad.

**(c) CAPEX en localStorage.** `DashboardModule.jsx:64-113`. Cada equipo ve un denominador distinto. Es el denominador del ROI.

**(d) No hay `total_bruto` ni `ajuste_redondeo` en `pedidos`.** Grep en `sql/` = 0. El redondeo al peso está propuesto en el doc de rentabilidad; no está aplicado. No lo asumas.

**(e) `devolucion_items.lote_id`.** La columna se agregó; el COGS revertido sin lote cae a `productos.costo`. Verifica en el esquema vivo si el RPC la llena.

**(f) No hay módulo Finanzas en el nav.** `src/constants.js:52-71` (`NAV_ADMIN`, `ADMIN_NAV_SECTIONS`): Dashboard, Corte de Caja, RRHH. Cero “Finanzas” / “Gastos”.

---

## PARTE 2 — Decisiones ya cerradas

No las reabras. Si una te parece mal, **pregunta** — no la “mejores” en silencio.

1. **P&L y flujo de caja son dos reportes, no uno.** El P&L responde “¿cuánto gané después del medicamento y de los gastos?”. El flujo responde “¿cuánto dinero conté?”. Mezclarlos produce un margen que no cuadra. Ver §2.5.
2. **El P&L se arma sobre `pedidos` + `pedido_items`.** El costo se calcula renglón por renglón. El ingreso del P&L tiene que ser **el mismo universo**. Si usas `cortes.total_general` arriba y `pedido_items` abajo, el margen es basura.
3. **El flujo de caja se arma sobre `cortes_caja`.** Dinero contado: `total_general` (GENERATED) a partir de la fecha en que `fondo_inicial` es confiable. Antes de esa fecha, no se usa o se etiqueta *no confiable*.
4. **La brecha pedidos vs. cortes se muestra**, no se esconde. Es el control de descuadre (efectivo no cortado, cortes con fondo 0, tickets fuera de sesión, anulados, pagos de servicio). Ver maqueta, bloque “Descuadre”.
5. **Jerarquía de costo:** lote → catálogo → `null`. `null ≠ 0`. Margen % solo sobre líneas con costo. Cobertura a la vista, semáforo: verde ≥ 95%, ámbar 80–95%, rojo < 80%.
6. **Compuerta 80%.** Si la consulta 4 sale abajo, se detiene el desarrollo del P&L y se captura costo. Un margen con costos faltantes se ve *mejor* precisamente cuando los datos están peor.
7. **Comprar inventario no es gasto.** `recepciones.total_ticket` y `compras.total` son cambio de dinero por activo. Se vuelven COGS al vender. Meterlos en el P&L hunde los meses de resurtido.
8. **Nada de constantes.** Se mata el `0.55`. Si un dato no se puede calcular, se muestra “No disponible” y se dice qué capturar.
9. **Gastos manuales vs. derivados, sin doble conteo.** Renta/luz/etc. a mano. ~~Nómina desde `nomina_empleados`~~ → **v1 es captura manual** (Parte 8; la tabla está vacía). Comisión TPV / plataforma = % configurable. Merma = lotes vencidos × `costo_unitario`. Índice único `(origen, ref_id)` para que un job no duplique.
10. **La UI es la de la maqueta.** `docs/finanzas-maqueta.html`. No rediseñes. Estilos `C_LIGHT` / `BRAND`. Cambios quirúrgicos a `DashboardModule.jsx` (1,200+ líneas: metas, drag & drop, pendientes). No lo reescribas de cero.
11. **Recuperación de inversión = utilidad acumulada / CAPEX**, no ventas / CAPEX. Las ventas acumuladas se quedan como métrica secundaria con otro nombre.
12. **RPC + bundle.** Un jsonb, no diez round-trips. `fn_require_admin` para números financieros.

### 2.5 P&L ≠ corte — el error que no se vuelve a cometer

La primera versión de la maqueta ponía las **ventas brutas del P&L** saliendo de `cortes_caja.total_general`. Está mal.

| Reporte | Universo | Por qué |
|---|---|---|
| **P&L** | `pedidos` completados + `pedido_items` (+ devoluciones) | El COGS se calcula **renglón por renglón**. Ingreso y costo tienen que ser el mismo conjunto. Un corte no tiene renglones ni lote. |
| **Flujo de caja** | `cortes_caja.total_general` (desde fondo confiable) − salidas pagadas | Es dinero que alguien contó. No sabe de margen. |

Si en un día el corte dice $12,400 y los pedidos dicen $11,980, **esa diferencia es el control**. Se muestra como “Descuadre pedidos vs. cortes”. Causas típicas: fondo_inicial = 0 en cortes viejos, corte no hecho, `pagos_servicio` que sí entraron al cajón, devolución en efectivo, tickets de consulta, anulación. No “ajusta” el P&L para que cuadre con el corte. No “ajusta” el corte para que cuadre con el P&L.

La consulta 7 del SQL te da esa brecha por día. La maqueta la pinta.

---

## PARTE 3 — Cascada que hay que construir (cuando la compuerta deje pasar)

```
    Ventas brutas                         ← SUM(pedidos.total) completados del período
  − Devoluciones                          ← SUM(devoluciones.total_devuelto) aprobadas
  = VENTAS NETAS
  − COGS                                  ← Σ costo_linea (jerarquía §1.3), mismo universo
  = UTILIDAD BRUTA                        ← “después del medicamento”
  − Gastos fijos                          ← renta, nómina, servicios, …
  − Gastos variables                      ← comisiones, mermas, insumos, …
  = UTILIDAD OPERATIVA                    ← “después de gastos”
```

Flujo de caja (otra tarjeta, otro universo):

```
    SUM(cortes.total_general)             ← desde fecha de fondo confiable, anulado_at is null
  − Nómina pagada
  − Gastos manuales pagados
  − (opcional, pregunta 8) pagos a proveedor
  = Efectivo generado del período
```

Punto de equilibrio (cuando haya gastos fijos y margen bruto):

```
PE mensual = gastos fijos ÷ margen bruto (decimal, solo líneas con costo)
PE diario  = PE mensual ÷ dias_operativos_mes
```

---

## PARTE 4 — Las cinco fases

Cada fase termina con build + revisión. No adelantes la siguiente.

### Fase 1 — Diagnóstico y compuerta (esta semana, sin código de producto)

1. Corre `sql/diagnostico_finanzas_20260904.sql` consulta por consulta.
2. Anota el % de la consulta 4. Si < 80%, **para** y reporta: cobertura, top categorías/SKUs sin costo, y que lo primero es capturar costos. No abras `gastos`, no toques el dashboard.
3. Anota la fecha de la consulta 2 (primer tramo estable con `fondo_inicial > 0`). Esa fecha es el piso del flujo de caja.
4. Anota la brecha de la consulta 7. Si es enorme, dilo: el control de descuadre va a ser el primer número que Ivan vea.
5. Contesta las ocho preguntas (Parte 6) con los números delante.

**Entregable:** un mensaje con los nueve resultados (o un resumen), la decisión go/no-go, y las ocho respuestas. Nada de PR de features.

### Fase 2 — Dejar de mentir

Meta: ningún número financiero en pantalla es una constante.

- Matar `gananciaNetaEstMes` / el `0.55`. El test de `dashboardVentas.test.js:129-132` se reescribe o se borra: ya no puede clavar 550.
- KPI Proyecto: **Utilidad bruta / mes** (no “ganancia neta”), subtítulo *“Antes de gastos operativos”*. Si aún no hay gastos, aviso discreto. Si cobertura < 80%, el número va en gris con *“cobertura de costo insuficiente”*.
- “Total recuperado” deja de ser `sum(pedidos.total)`. Pasa a utilidad bruta histórica (y en Fase 4, operativa). Las ventas acumuladas se quedan al lado con otro nombre.
- `costoUnitarioLinea` prefiere `costo_lote`, devuelve `null` si no hay costo. `peds_cat` manda `costo_lote` / `lote_id`.
- Margen por categoría: % solo sobre `ingresoConCosto`. Columna Cobertura. Banner si cobertura global < 80%.
- `grep -rn "0\.55" src/lib/dashboardVentas.js src/DashboardModule.jsx` no puede devolver lógica de utilidad.

Sin módulo nuevo. Sin tabla `gastos`. Sin redondeo (pregunta 7).

### Fase 3 — P&L sobre pedidos

Meta: un solo número visible — **utilidad bruta** — que cuadre a mano con tres tickets.

- Bundle (o extensión del de reporte) con: ventas brutas, devoluciones, COGS, utilidad bruta, cobertura, utilidad por ticket. Todo desde `pedidos` / `pedido_items` / `lotes` / `devoluciones`.
- Pestaña Margen: KPIs de la maqueta (bloque P&L). Fila TOTAL ponderada (no promedio de porcentajes). Columnas % del ingreso y % de la utilidad.
- Control de descuadre: al lado, `SUM(cortes.total_general)` del mismo período (con el corte de fondo) vs. ventas de pedidos. No se usan para el margen; se muestran.
- Transacciones: columnas Costo / Utilidad; filtro “solo margen negativo”.
- Resumen: utilidad por empleado, no solo facturación.

Criterio: tomas 3 tickets, calculadora, cuadra.

### Fase 4 — Flujo de caja + gastos

Meta: “¿cuánto me quedó después de gastos?” y “¿cuánto dinero conté?”

- Tabla `gastos` + RPCs del doc de rentabilidad (`admin_registrar_gasto`, `admin_listar_gastos`, `admin_eliminar_gasto`, `admin_generar_gastos_derivados`). Índice único parcial `(origen, ref_id)`. Categorías en `src/constants/categoriasGasto.js`.
- Flujo de caja desde `cortes_caja` **a partir de la fecha de la consulta 2**. Cortes con `fondo_inicial = 0` anteriores: fuera o leyenda *no confiable*.
- Derivados: nómina, comisión TPV, merma. Config: `comision_tpv_pct`, `comision_online_pct`, `carga_patronal_pct`, `dias_operativos_mes`.
- Una compra / recepción **no** aparece como gasto.
- CAPEX sale de `localStorage` a `proyecto_capex` (RPC admin). Una migración.

### Fase 5 — Módulo Finanzas (la maqueta) + indicadores

Meta: la pantalla que ya se acordó, no otra.

- Nueva entrada de nav (pregunta 5 decide el rol). Id tentativo `finanzas`. Sección “Administración interna”, junto a RRHH.
- Pestañas de la maqueta: **P&L · Flujo · Gastos · Proyecto**.
- Cascada clickeable, PE diario, gastos por categoría, alta de gasto en < 10 s, tendencia 6 meses.
- Indicadores que faltan, por prioridad: valor de inventario a costo, rotación / DIO (etiquetar mientras no haya snapshot), GMROI, merma $, margen por canal, CxP si `compras` tiene datos, top por utilidad, productos bajo costo.
- `InsightCard` de utilidad del mes en Operación, con `meta_utilidad_mes`.

No inventes gráficas con librería. `div` + %. Móvil: `useMediaQuery("(max-width: 768px)")` ya está en el dashboard.

---

## PARTE 5 — Lo que NO debes hacer

1. No programes si la consulta 4 < 80%. Capturar costos primero.
2. No uses `cortes.total_general` como ventas brutas del P&L.
3. No escondas la brecha pedidos vs. cortes.
4. No trates costo faltante como 0.
5. No metas recepciones/compras en el P&L.
6. No imputes `fondo_inicial` en cortes viejos. Corta la serie.
7. No reintroduzcas un ratio (0.55, 0.35, “el margen típico de farmacia”).
8. No reescribas `DashboardModule.jsx` ni `margenVenta.js` de cero.
9. No hagas las cinco fases en un commit.
10. No agregues `supabase.from()` de costo/caja/utilidad en el cliente.
11. No redondees renglones (si el redondeo entra, es el total; pregunta 7).
12. Si el esquema real no coincide, detente y pregunta.

---

## PARTE 6 — Ocho preguntas. Contéstalas antes de programar

Con los resultados del SQL delante. Respuesta corta + número que la respalda. Si no puedes, la pregunta sigue abierta y no se escribe código de esa parte.

1. **¿Desde qué fecha `fondo_inicial` es confiable?** — **CERRADA (Parte 8.6).**  
   `caja_sesiones.fondo_contado` > 0 desde el **18-ago-2026**. El RPC lo copia al corte. Flujo de caja corta ahí. El fondo que crece ($282 → $3,881) es cambio que se quedó, no venta.

2. **¿Las consultas (`pedidos.tipo = 'consulta'`) van dentro de las ventas brutas del P&L o en un renglón aparte?**  
   Hoy el Resumen las mezcla y a veces las vuelve a sumar (`PROMPT_CURSOR_RENTABILIDAD.md` §1.5). El consultorio no tiene COGS de mercancía. ¿Ingreso operativo aparte, debajo de utilidad bruta de farmacia?

3. **¿`pagos_servicio` es ingreso o pass-through?** — **CERRADA (Parte 8).**  
   P&L = `comision + compensacion_mp` (`total_utilidad` del RPC). Flujo = las dos patas (entra `total_cobrado` vía el corte, sale `costo_liquidacion`) o ninguna.

4. **Nómina en v1: ¿derivada o captura manual?** — **CERRADA (Parte 8).**  
   `nomina_empleados` tiene 0 filas. v1 es **manual**. Un ausente no es un cero.

5. **¿Quién ve Finanzas?**  
   ¿Sólo admin (`fn_require_admin`)? ¿Encargado también? El vendedor **no**. Hoy el nav admin no tiene el ítem (`src/constants.js:52-71`).

6. **¿La comisión de plataforma (Rappi / online) se resta del margen por canal desde el día 1?**  
   Hay `pedidos.tipo = 'online'`. No hay un % vivo en `configuracion` todavía (se propone `comision_online_pct`). ¿Se configura y se resta en Fase 3, o el canal online se muestra bruto hasta Fase 4?

7. **¿El redondeo al peso entra en este trabajo?**  
   Está especificado en `PROMPT_CURSOR_RENTABILIDAD.md` §1.5 y Fase 1.2. Toca POS, ticket, firma de `create_sale_transaction_secure` (riesgo de overload en PostgREST) y `cobrar_consulta`. ¿Va en un PR aparte, después de Finanzas, o es prerrequisito porque si no `SUM(items) ≠ pedidos.total`?

8. **¿De dónde sale “pagado a proveedor” para el flujo de caja?** — **CERRADA (Parte 8).**  
   `compras` = 0 filas. `recepciones` confirmadas = $3,710 en 12 movimientos: no es todo lo que se compra. v1 = **captura manual**. No uses `recepciones.total_ticket` como proxy de pagado.

---

## PARTE 7 — Criterios de aceptación (cuando sí se programe)

**Fase 1**

- [ ] Las nueve consultas corrieron. El resultado de la 4 está escrito en el handoff de respuesta.
- [ ] Si < 80%: no hay código de P&L en el PR.
- [ ] Fecha de fondo confiable anotada, o explícitamente “no hay tramo limpio”.
- [ ] Las ocho preguntas tienen respuesta o están marcadas abiertas con dueño.

**Fase 2**

- [ ] `grep` del `0.55` de utilidad: limpio.
- [ ] Producto con `costo = 0` no aparece con 100% de margen.
- [ ] Build sin warnings nuevos.

**Fase 3**

- [ ] Tres tickets cuadran a mano con la tarjeta UTILIDAD BRUTA.
- [ ] El % del TOTAL es ponderado.
- [ ] El descuadre pedidos vs. cortes es visible y no alimenta el margen.

**Fase 4**

- [ ] Capturar renta y verla en la cascada en < 10 s.
- [ ] `admin_generar_gastos_derivados` × 2 no duplica.
- [ ] Una recepción **no** aparece como gasto.
- [ ] Cortes anteriores a la fecha de fondo no inflan el flujo.

**Fase 5**

- [ ] La pantalla se parece a `docs/finanzas-maqueta.html` (mismas pestañas, misma cascada, mismo bloque de descuadre, mismo PE).
- [ ] Móvil usable.
- [ ] RPC validan sesión y rol.
- [ ] Cero `supabase.from()` nuevos de costo/caja.
- [ ] Completitud de captura visible junto a la utilidad (Parte 8). Nómina/renta/proveedores no capturados ≠ $0.
- [ ] Servicios: P&L usa `total_utilidad`; flujo usa las dos patas o ninguna.

---

## PARTE 8 — Lo que la consulta 9 ya cerró (manda sobre la Parte 2)

Escrito el 4-sep-2026 con el jsonb real de la consulta 9. **Si esta parte y la Parte 2 discrepan, gana esta.** Un dato ausente no es un dato en cero — el mismo pecado del `0.55`, al revés.

### 8.1 Resultado vivo (no volver a pedirlo)

```
nomina_filas: 0
compras_filas: 0
tabla_gastos_existe: false
recepciones_confirmadas: 12 · total_ticket $3,710.15
pagos_servicio: 21 · cobrado $1,146 · comision $11
merma_vencida: 6 pzas · $336.29 a costo
```

### 8.2 Nómina v1 = manual

`nomina_empleados` está vacía. Derivar `neto_pagar` pone la nómina en $0 y la utilidad operativa se ve mejor de lo que es. En v1 se captura a mano (igual que renta, luz, contador). Cuando RRHH tenga filas, el job derivado entra — no antes.

### 8.3 Servicios: el corte ya trae los $1,146, no los $11

`reconcile_shift_cash` / el bundle de corte (`sql/patch_corte_electronicos_servidor.sql:83-94`, vivo también en `sql/patch_caja_cadena_continua_20260824.sql:130`):

```
efectivo_sistema = v_ef_pedidos + v_ef_serv
v_ef_serv = SUM(pagos_servicio.total_cobrado) WHERE metodo_pago = 'efectivo'
```

O sea `cortes_caja.total_general` **ya incluye el cobro completo**. Ese dinero entra al cajón y tiene que salir a reponer el saldo de Mercado Pago. La salida está en `pagos_servicio.costo_liquidacion` (`sql/patch_pagos_servicio_compensacion_mp.sql:12, 39, 285`). La UI ya lo advierte en `src/CorteCajaModule.jsx:773-775`.

| Reporte | Qué usar | No usar |
|---|---|---|
| **P&L** | `comision + compensacion_mp` — el RPC ya lo nombra `total_utilidad` (`patch_pagos_servicio_compensacion_mp.sql:284`) | `total_cobrado` |
| **Flujo** | Las **dos** patas: entra el cobro (ya va en el corte), sale `costo_liquidacion` — **o ninguna** | Sólo la entrada |

Hoy la diferencia es ~$1,135 (`1,146 − 11`). Es chico, pero es error de **fórmula**, no de escala. Si pones sólo la entrada, el efectivo se ve libre cuando ya está comprometido.

Consulta 9 actualizada pide también `compensacion_mp` y `costo_liquidacion` para no volver a inferirlos.

### 8.4 En v1 casi todo el gasto es manual

Automático, de verdad:

- lo que entró por caja (`cortes.total_general`, desde fondo confiable)
- COGS, **si** la consulta 4 pasa la compuerta
- merma de lotes vencidos ($336 hoy)
- utilidad de servicios (`total_utilidad`, $11 + compensación)

A mano: nómina, renta, luz, contador, **pago a proveedores**. `recepciones` ($3,710 / 12) no es el resurtido real. `compras` está vacía.

Bájale a la promesa de la maqueta. No ofrezcas una columna “lo que llega solo” que en v1 no existe. Se siente peor que pedir la captura de frente.

### 8.5 Completitud de captura, junto a la utilidad

Mientras nómina y compras se tecleen, **un mes sin capturar se ve excelente**. Mismo veneno que el costo faltante → margen 100%.

Al lado de la utilidad operativa (y del “Quedó” del flujo) va un indicador de completitud, igual que la cobertura de costo:

- ¿Hay nómina este período?
- ¿Hay renta / fijos del mes?
- ¿Hay al menos un pago a proveedor, o está marcado “sin compra”?

Si falta alguno: el número va en gris / ámbar con *“captura incompleta — no es que hayas gastado $0”*. No se publica un % de rentabilidad que parezca limpio.

### 8.6 Fondo: la serie de sesiones ya cierra la fecha (pregunta 1)

Listado vivo de `caja_sesiones` (no es `cortes_caja`; es mejor). Al cortar, `registrar_corte_caja` copia `fondo_contado` → `cortes.fondo_inicial` (`sql/patch_caja_sesiones_vendedor.sql:519`).

- Primera sesión con fondo: **18-ago-2026** (id 3, Erika vespertino, $282, corte 5).
- Desde entonces **ninguna** sesión tiene fondo 0. Sube casi todos los días: $282 → $3,881.50 (Rene, 4-sep, sesión 32 todavía abierta).
- El flujo de caja **corta el 18-ago-2026**. Antes de eso, `fondo_inicial` del corte vale 0 y `total_general` cuenta el cambio como venta.
- Ese crecimiento del fondo **no es venta**. Es efectivo que se quedó en el cajón. `total_general` ya lo resta; no sumes `fondo_contado` como “entró”.
- Notas sucias, no bloquean: sesión 6 (19-ago, Mary, 22:45–22:50, 5 minutos); sesión 23 (29-ago 15:10 → 31-ago 09:57, fin de semana). Domingo 23 y 30-ago sin sesión.

Pregunta 1: **cerrada**. Piso del flujo = `2026-08-18`.

### 8.7 Sigue faltando: solo la consulta 4

Cobertura de costo de lo **vendido** (`veredicto` / `cobertura_algun_costo_pct`). Sin eso no hay go/no-go del P&L. No pegas tablas markdown en el SQL Editor — por eso salió `syntax error at or near "|"`.

---

## Resumen ejecutivo

**Pregunta del dueño:** “¿Cuánto gané de verdad?”

Hoy el tablero responde `ventas × 0.55` (`dashboardVentas.js:99`) y llama “recuperado” a la suma de tickets (`rpc_p1_lecturas_admin.sql:395`). El margen por categoría usa `productos.costo` actual (`margenVenta.js:37-45`) y trata el cero como cero (`DashboardModule.jsx:745`). No hay tabla de gastos. El corte tiene un `total_general` GENERATED (`patch_corte_ciego_fondo_denominaciones.sql:47-51`) que en la historia **incluye el fondo** porque `fondo_inicial` nació tarde (`CorteCajaModule.jsx:505`).

**Respuesta correcta, cuando la consulta 4 deje pasar:**

- Utilidad bruta = ventas de **pedidos** − devoluciones − COGS de **lote**.
- Utilidad operativa = eso menos gastos.
- Efectivo del período = **cortes** (desde fondo confiable) menos salidas pagadas.
- La diferencia entre los dos universos se **muestra**.

Si la consulta 4 < 80%: no hay respuesta correcta posible. Capturar costos. Luego programar.
