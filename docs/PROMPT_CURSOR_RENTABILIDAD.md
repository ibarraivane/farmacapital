# FarmaCapital — Rentabilidad real y redondeo al peso

> **Cómo usar este documento:** pégalo completo en Cursor (Composer / Agent, modo *Ask* primero).
> La **Parte 1** es la lógica de negocio: léela tú también, es el "por qué" de cada cambio.
> Las **Partes 2–5** son las fases de implementación. **No las hagas todas de un jalón.**
> Antes de escribir código, Cursor debe hacer lo que pide la **Parte 0**.

---

## PARTE 0 — Instrucciones para el agente (leer primero)

Eres un ingeniero senior trabajando en **FarmaCapital**, un sistema de punto de venta + inventario + consultorio para una farmacia en México.

**Stack:** React 18 (CRA, JavaScript, sin TypeScript) · Supabase (Postgres) · Vercel · estilos inline con el objeto `C_LIGHT` de `src/constants.js` · sin librería de charts (los gráficos son `div`s con ancho porcentual).

**Convenciones del repo que debes respetar:**

- Toda lectura/escritura sensible va por **RPC de Postgres con `security definer`**, nunca por `supabase.from(...)` directo desde el cliente. El primer parámetro siempre es `p_session_token uuid`, y adentro se valida con `public.fn_require_admin(p_session_token)` o `public.fn_require_empleado(...)`. El token vive en `sessionStorage.getItem("farmacapital_session_token")`.
- Los RPC de dashboard devuelven **un solo `jsonb`** con varias llaves adentro (patrón *bundle*), y el cliente lo desarma con `parseRpcJsonObject` / `parseRpcJsonArray` de `src/utils/rpcJson.js`. Sigue ese patrón, no agregues 10 llamadas nuevas.
- El SQL nuevo va en `sql/` como archivo con nombre descriptivo y fecha, **idempotente** (`create or replace`, `add column if not exists`). Nunca edites un archivo SQL ya aplicado.
- Formato de dinero: `$()` de `src/utils.js` (2 decimales, `es-MX`).
- Componentes de UI reutilizables en `src/ui.jsx`: `KPI`, `KPI_ROW`, `Box`, `Tag`, `Btn`, `SkeletonKPIs`, `SkeletonTable`.

**Antes de escribir una sola línea de código haz esto y repórtalo:**

1. Lee completo `src/DashboardModule.jsx`, `src/modules/sales/pos/POS.jsx`, `src/utils/margenVenta.js`, `sql/rpc_p1_lecturas_admin.sql`, `sql/create_sale_transaction.sql` y `sql/patch_caja_sesiones_vendedor.sql`.
2. Confirma en el esquema real de Supabase (no adivines) las columnas de: `pedidos`, `pedido_items`, `lotes`, `productos`, `devoluciones`, `nomina_empleados`, `caja_sesiones`, `configuracion`.
3. Dime **qué porcentaje de `productos` tiene `costo > 0`** y **qué porcentaje de `lotes` tiene `costo_unitario > 0`**. Este número decide si la Fase 2 es confiable o si primero hay que capturar costos. Si la cobertura es menor a ~80%, dilo fuerte y detente a discutirlo.
4. Lista cualquier discrepancia entre lo que dice este documento y lo que encontraste en el código. **Este documento fue escrito leyendo el repo, pero si algo no cuadra, gana el código.** No implementes sobre una suposición falsa.

Trabaja **fase por fase**. Al terminar cada fase: corre `npm run build`, entrega un resumen de archivos tocados, y **espera aprobación** antes de seguir.

---

## PARTE 1 — La lógica de negocio (el "por qué")

### 1.1 El problema de fondo

Hoy el dashboard mide **facturación**, no **rentabilidad**. Son cosas distintas y confundirlas es la forma más común de quebrar una farmacia rentable en papel.

La cadena correcta, de arriba hacia abajo, se llama **cascada de resultados** o **P&L** (*Profit & Loss*). Cada escalón resta algo:

```
    Ventas brutas                       ← lo que marcó la caja
  − Devoluciones y descuentos
  = VENTAS NETAS                        ← ingreso real
  − Costo de mercancía vendida (COGS)   ← lo que te costó el medicamento
  = UTILIDAD BRUTA                      ← "lo que gano después del medicamento"
  − Gastos operativos                   ← renta, nómina, luz, comisiones, mermas
  = UTILIDAD OPERATIVA (EBITDA)         ← "lo que gano después de gastos"
  − Depreciación − impuestos
  = UTILIDAD NETA                       ← lo que de verdad es tuyo
```

**Estado actual de FarmaCapital en esa cascada:**

| Escalón | ¿Existe? | Dónde |
|---|---|---|
| Ventas brutas | ✅ | Operación, Resumen, Transacciones |
| Devoluciones | ⚠️ Parcial | Solo en Margen, y no se restan del margen por categoría |
| Ventas netas | ⚠️ Mal nombrado | La pestaña Margen llama "Ventas netas" a bruto − devoluciones (correcto), pero el usuario lo lee como "lo que gané" |
| COGS | ⚠️ Parcial | Solo por categoría, sin total, y con costo incorrecto (ver 1.3) |
| **Utilidad bruta** | ❌ **Sin total** | — |
| Gastos operativos | ❌ **No existen en el sistema** | No hay tabla `gastos` en `sql/` |
| **Utilidad operativa** | ❌ | — |
| Utilidad neta | ❌ | — |

### 1.2 Los tres números que hoy mienten

**(a) La "ganancia neta" es un 55% inventado.**
`src/DashboardModule.jsx:486`

```js
const gananciaMes = ventasMes * 0.55;   // se muestra como "GANANCIA NETA EST. / MES"
```

No lee costos reales. No resta ni un gasto. Es una constante. Y como alimenta el cálculo de payback (`paybackMeses`, línea 677), el "te faltan ~X meses para recuperar" también es ficción.

**(b) "Total recuperado" son ventas brutas, no capital recuperado.**
`src/DashboardModule.jsx:485` suma `ped_todos`, que en `sql/rpc_p1_lecturas_admin.sql:377` es **la suma de `total` de todos los pedidos completados desde siempre**.

Conceptualmente está mal: vender $710,000 no recupera una inversión de $710,000. De esa venta, ~65% se fue en pagarle al proveedor y otro tanto en renta y nómina. **Lo que recupera capital es la utilidad, no la venta.** Con la fórmula actual, la barra de progreso va a marcar 100% mucho antes de que hayas visto ese dinero.

**(c) El margen por categoría se infla solo.**
`src/DashboardModule.jsx:624`

```js
margen: v.ingreso > 0 ? ((v.ingreso - v.costo) / v.ingreso * 100).toFixed(1) : 0
```

Si `productos.costo` es `0` (producto sin costo capturado), esa línea reporta **100% de margen** y arrastra hacia arriba el promedio de toda la categoría. Sin un indicador de *cobertura de costo*, esta tabla es peligrosa: se ve bien justo cuando peor está la captura de datos.

### 1.3 De dónde debe salir el costo (COGS)

Hoy `margenVenta.js` toma `productos.costo`, que es el **costo actual del catálogo**. Eso significa que si hoy actualizas el costo de la paracetamol, cambia retroactivamente la utilidad de todas las ventas de hace seis meses. Un P&L que se reescribe solo no sirve para nada.

La buena noticia: **el repo ya tiene la infraestructura correcta.** `sql/refactor_fase2_dual_write.sql:68` agregó `pedido_items.lote_id → lotes(id)`, y `lotes.costo_unitario` guarda el costo de compra real de ese lote específico.

**Jerarquía de costo a usar, en este orden:**

1. `lotes.costo_unitario` vía `pedido_items.lote_id` ← costo histórico real, el correcto
2. `productos.costo` ← respaldo cuando no hay lote
3. `null` ← **no lo trates como 0.** Si no hay costo, la línea se marca *sin costo* y se excluye del cálculo de margen %, contándose aparte en el indicador de cobertura.

El punto 3 es el más importante de esta sección. Un costo desconocido no es un costo de cero.

Ajuste extra: para venta por pieza suelta (`modo_venta = 'unidad'`), el costo unitario es `costo_del_lote / unidades_por_caja`. Esa lógica ya existe y está bien resuelta en `costoUnitarioLinea()` de `src/utils/margenVenta.js` — reutilízala, no la reescribas.

### 1.4 Un problema silencioso: los descuentos no se guardan por renglón

En `sql/create_sale_transaction.sql` (~línea 443) el precio que manda el POS **se descarta** y se reemplaza por el precio del catálogo:

```sql
v_db_precio := coalesce(v_precio_prod, 0);   -- ignora el precio que venía del carrito
...
insert into public.pedido_items (..., precio_unitario, ...) values (..., v_db_precio, ...);
```

Pero el POS **sí** aplica promociones antes de cobrar (`calcularTotalConPromos`, `POS.jsx:1307`) y esas promos van en el `total` del encabezado.

Resultado: **cuando hay promoción, `SUM(pedido_items.precio_unitario × cantidad) > pedidos.total`.** La pestaña Margen suma renglones, así que reporta más ingreso del que realmente entró y por lo tanto más utilidad de la que hubo.

Esto se arregla en la Fase 1. La razón de que el precio se pise en el servidor es correcta y hay que conservarla (evita que un cliente manipulado mande precios falsos); la solución es mandar el descuento de forma explícita y validarlo, no confiar ciegamente en el precio del carrito.

### 1.5 La lógica del redondeo al peso

**Decisión:** el cliente nunca paga centavos. El total del ticket se redondea **al peso más cercano** (`$124.40 → $124`, `$124.60 → $125`, `$124.50 → $125`).

**Principios que no se negocian:**

1. **Se redondea el total, nunca los renglones.** Redondear cada línea acumula error y descuadra el ticket. Los renglones conservan sus decimales; solo el gran total se redondea.
2. **Se guarda el bruto y el ajuste, no nada más el redondeado.** `pedidos.total_bruto` (con decimales), `pedidos.ajuste_redondeo` (entre −0.49 y +0.50) y `pedidos.total` (el redondeado, el que cobras). Sin esas tres columnas la contabilidad no cuadra y el margen se desalinea de la caja.
3. **El redondeo aplica a todos los métodos de pago.** Tentación: "en tarjeta no hace falta porque no hay monedas". Mala idea — el ticket impreso y el cobro en la terminal tendrían números distintos, y eso genera aclaraciones. Un solo número.
4. **Todo lo que se deriva del cobro usa el total redondeado:** cambio en efectivo, validación del "recibido", IVA, puntos de lealtad, corte de caja. Todo lo que se deriva del margen usa el bruto, más la línea de ajuste.
5. **El ajuste es una línea del P&L**, categoría `ajuste_redondeo`. Con redondeo al más cercano tiende a cero en el largo plazo (~±$0.25 por ticket en promedio, se compensa). Si en un mes ves un ajuste acumulado grande y de un solo signo, hay un sesgo en tus precios de lista y vale la pena revisarlo.
6. **Las devoluciones se redondean igual.** Si devuelves parte de un ticket, calculas el proporcional sobre el bruto, lo redondeas, y ese es el reembolso.

**Efecto secundario deseable:** una vez que el cobro se redondea, conviene mover los precios de lista a algo que caiga en pesos limpios. No es obligatorio y no lo incluyo como tarea, pero cuando lo hagas el ajuste de redondeo se va prácticamente a cero.

### 1.6 Gastos: manuales vs. derivados (evitar el doble conteo)

Cuando armas un módulo de gastos, el error clásico es capturar a mano algo que el sistema ya sabe, y contarlo dos veces. Regla:

| Gasto | Origen | Por qué |
|---|---|---|
| Renta, luz, agua, internet, limpieza, publicidad, mantenimiento | **Manual** (`origen = 'manual'`) | El sistema no tiene forma de saberlos |
| Nómina | **Derivado** de `nomina_empleados.neto_pagar` + carga patronal | Ya se captura en RRHH; teclearla otra vez la duplica |
| Comisión de terminal / tarjeta | **Derivado**: % configurable sobre ventas con `metodo_pago` de tarjeta | Es proporcional a la venta, no un monto fijo |
| Comisión de plataforma (Rappi/online) | **Derivado**: % configurable sobre ventas `tipo = 'online'` | Igual |
| Merma por caducidad | **Derivado** de lotes vencidos × `costo_unitario` | Ya está el dato en `lotes` |
| Compras a proveedor | **Ni uno ni otro** | ⚠️ Comprar inventario **no es gasto**, es cambiar dinero por activo. Se vuelve gasto (COGS) cuando lo vendes. Meter `compras.total` en el P&L es el error contable más común y hunde artificialmente los meses en que resurtes. |

Ese último renglón es crítico. Anótalo.

### 1.7 Punto de equilibrio — el número más útil para el mostrador

```
Punto de equilibrio mensual ($) = Gastos fijos del mes ÷ Margen bruto promedio (decimal)

Punto de equilibrio diario ($)  = Punto de equilibrio mensual ÷ días operativos del mes
```

Ejemplo con números plausibles: gastos fijos $45,000/mes y margen bruto promedio 32% →
`45,000 ÷ 0.32 = $140,625` al mes → entre 30 días = **$4,688 diarios**.

Ese único número convierte el dashboard en una herramienta de decisión: **"hoy llevas $3,200 y tu punto de equilibrio es $4,688"** le dice al encargado si hay que empujar antes de cerrar. Es más accionable que cualquier gráfica.

### 1.8 Recuperación de la inversión, bien planteada

Con la cascada completa, la pestaña Proyecto cambia a:

```
Recuperación real (%) = Utilidad operativa acumulada ÷ Inversión total (CAPEX)

Payback restante (meses) = (CAPEX − Utilidad operativa acumulada)
                           ÷ Utilidad operativa promedio de los últimos 3 meses
```

Dos detalles:

- **Promedio de 3 meses, no el mes actual.** Un mes bueno o malo distorsiona la proyección. Si hay menos de 3 meses de historia, usa lo que haya y **etiquétalo** como estimación de baja confianza.
- **Conserva las ventas brutas acumuladas** como métrica secundaria, claramente separada y con otro nombre ("Ventas acumuladas desde apertura"). Es el número al que Ivan ya está acostumbrado; no hay que quitarlo, hay que dejar de llamarlo "recuperado".

---

## PARTE 2 — FASE 1: Corregir lo que miente

> Meta: que ningún número mostrado sea falso. Sin funcionalidad nueva todavía.
> Si un dato aún no se puede calcular, **se oculta o se marca como no disponible** — nunca se estima con una constante.

### 1.1 · Módulo de redondeo

Crea `src/utils/redondeoPeso.js`:

```js
/** Redondeo del cobro al peso más cercano. El cliente nunca paga centavos. */

/** $124.40 → 124 · $124.50 → 125 · $124.60 → 125 */
export function redondearAPeso(n) {
  const x = parseFloat(n);
  if (!Number.isFinite(x)) return 0;
  return Math.round(x);
}

/** Ajuste aplicado: negativo si el cliente pagó menos, positivo si pagó más. Rango [-0.49, +0.50]. */
export function ajusteRedondeo(bruto) {
  const x = parseFloat(bruto);
  if (!Number.isFinite(x)) return 0;
  return Math.round((redondearAPeso(x) - x) * 100) / 100;
}

/** Devuelve { bruto, total, ajuste } listo para POS, ticket y RPC. */
export function desgloseCobro(bruto) {
  const b = Math.round((parseFloat(bruto) || 0) * 100) / 100;
  const total = redondearAPeso(b);
  return { bruto: b, total, ajuste: Math.round((total - b) * 100) / 100 };
}
```

Tests en `src/utils/__tests__/redondeoPeso.test.js`. Casos obligatorios: `124.40→124`, `124.50→125`, `124.49→124`, `0.40→0`, `0.50→1`, `-0.01→0`, `NaN→0`, `null→0`, y que `bruto + ajuste === total` siempre.

### 1.2 · Aplicar el redondeo en el POS

**SQL** — nuevo archivo `sql/patch_redondeo_peso_YYYYMMDD.sql`:

```sql
alter table public.pedidos
  add column if not exists total_bruto     numeric(12,2),
  add column if not exists ajuste_redondeo numeric(6,2) not null default 0;

-- Backfill: las ventas históricas no tuvieron redondeo.
update public.pedidos set total_bruto = total where total_bruto is null;
```

Después extiende `create_sale_transaction_v2` y su wrapper `create_sale_transaction_secure` con **dos parámetros nuevos al final y con default**, para no romper llamadas existentes:

```sql
p_total_bruto     numeric default null,
p_ajuste_redondeo numeric default 0
```

Dentro, guarda `total_bruto = coalesce(p_total_bruto, p_total)`.

> ⚠️ Al cambiar la firma, Postgres crea una **sobrecarga nueva**. Debes:
> 1. `drop function if exists public.create_sale_transaction_secure(uuid, text, numeric, jsonb, bigint, text, text, text);` (la firma vieja, tal cual aparece en `sql/patch_caja_sesiones_vendedor.sql:583`)
> 2. Re-emitir el `grant execute` con la firma nueva completa.
> 3. Si no lo haces, PostgREST va a fallar con *"Could not choose the best candidate function"*. Verifícalo con una venta de prueba antes de cerrar la fase.

Aplica el mismo tratamiento a `public.cobrar_consulta`.

**Frontend** — `src/modules/sales/pos/POS.jsx`, alrededor de la línea 1317:

```js
// ANTES
const sub   = calcularTotalConPromos();
const ptsG  = Math.floor(sub/10);
const total = sub;

// DESPUÉS
const sub = calcularTotalConPromos();
const { bruto: subBruto, total, ajuste: ajusteRedondeoVenta } = desgloseCobro(sub);
const ptsG = Math.floor(total / 10);
```

A partir de ahí `total` ya es el redondeado, así que el cálculo de cambio (línea 1327), la validación del recibido (líneas 1333 y 1376) y el IVA (línea 1498) quedan correctos sin tocarlos. **Verifícalo leyendo, no lo asumas.** Pasa `subBruto` y `ajusteRedondeoVenta` al RPC.

**Ticket** — en `src/components/tickets/TicketPreviewModal.jsx`, muestra el renglón de redondeo solo cuando `ajuste !== 0`:

```
Subtotal        $124.40
Redondeo        -$0.40
TOTAL           $124.00
```

**Tienda en línea** (`src/Tienda.jsx`) — aplica el mismo redondeo en el checkout, para que el cliente vea el mismo número en web y en ticket.

### 1.3 · Matar el 0.55 hardcodeado

En el RPC bundle de operación (`empleado_dashboard_operacion_bundle`, en `sql/rpc_p1_lecturas_admin.sql`) agrega una llave `utilidad_bruta_mes` calculada de verdad:

```sql
'utilidad_bruta_mes', coalesce((
  select jsonb_build_object(
    'ingreso',        coalesce(sum(x.precio_unitario * x.cantidad), 0),
    'costo',          coalesce(sum(
                        case
                          when coalesce(l.costo_unitario, pr.costo, 0) > 0
                          then coalesce(l.costo_unitario, pr.costo)
                               / case when lower(coalesce(x.modo_venta,'caja')) = 'unidad'
                                      then greatest(coalesce(pr.unidades_por_caja,1),1)
                                      else 1 end
                               * x.cantidad
                          else 0
                        end), 0),
    'ingreso_con_costo', coalesce(sum(
                        case when coalesce(l.costo_unitario, pr.costo, 0) > 0
                             then x.precio_unitario * x.cantidad else 0 end), 0)
  )
  from public.pedido_items x
  join public.pedidos  p  on p.id = x.pedido_id
  join public.productos pr on pr.id = x.producto_id
  left join public.lotes l on l.id = x.lote_id
  where p.estado::text = 'completado'
    and p.created_at >= (p_ctx->>'month_start')::timestamptz
), '{}'::jsonb),
```

> ⚠️ **`pedido_items.modo_venta` casi seguro NO existe.** Busqué `modo_venta` en todo `sql/` y no aparece ninguna referencia a esa columna en `pedido_items` — el modo se manda en el carrito y se usa para decidir el descuento de stock, pero **no se persiste**. Verifícalo contra el esquema real. Si en efecto no existe, la ruta correcta es:
> 1. `alter table public.pedido_items add column if not exists modo_venta text not null default 'caja';`
> 2. Persistirlo desde `create_sale_transaction_v2` (la variable `v_modo_venta` ya se calcula ahí, solo hay que guardarla).
> 3. Para los registros históricos, backfill con la heurística de `lineaEsVentaUnidad()` de `src/utils/margenVenta.js` (compara el precio cobrado contra `precio` y `precio_unidad` del producto), y **marca ese backfill como aproximado**.
>
> Sin esta columna, el COGS de la venta por pieza suelta queda mal calculado: cobras una pastilla pero cargas el costo de la caja entera, lo que hace ver esas ventas como pérdida.

En `DashboardModule.jsx`, sustituye la línea 486 por la utilidad bruta real menos los gastos del mes. **Mientras la Fase 3 no exista, no hay gastos**, así que:

- Renombra el KPI de la pestaña Proyecto a **"Utilidad bruta / mes"** (no "ganancia neta"), y agrega el subtítulo *"Antes de gastos operativos"*.
- Debajo, un aviso discreto: *"Los gastos operativos aún no se capturan. La utilidad neta estará disponible al activar el módulo de Gastos."*
- Si `ingreso_con_costo / ingreso < 0.8`, muestra el valor en gris con la leyenda *"cobertura de costo insuficiente"* en lugar de un número que parece confiable.

### 1.4 · Arreglar "Total recuperado"

Agrega al bundle una llave `utilidad_bruta_historica` con la misma consulta pero sin el filtro de fecha. En `DashboardModule.jsx:485`:

```js
// ANTES
const recuperado = (pedTodos || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);

// DESPUÉS
const ventasAcumuladas = (pedTodos || []).reduce((a, p) => a + parseFloat(p.total || 0), 0);
const recuperado = utilidadBrutaHistorica;  // en Fase 3 pasa a ser utilidad OPERATIVA acumulada
```

En la UI de la pestaña Proyecto:

- La barra de progreso y el `pctRecuperado` usan `recuperado` (utilidad).
- Agrega una tarjeta aparte, **"Ventas acumuladas desde apertura"**, con `ventasAcumuladas`, en color neutro.
- Bajo la barra, un pie de nota: *"La recuperación se mide con utilidad, no con ventas. Vender no es lo mismo que recuperar."*
- El payback pasa a promedio móvil de 3 meses (ver Parte 1.8). Con menos de 3 meses de datos, muestra "Datos insuficientes" en vez de un número.

### 1.5 · Corregir el doble conteo del Resumen

`DashboardModule.jsx:971` — hoy "Farmacia física" es `totalVentas − totalOnline`, que **sigue incluyendo las consultas**, y después las consultas se suman otra vez como tercera fuente. Los porcentajes rebasan el 100%.

```js
// ANTES
["Farmacia física", Math.max(0, totalVentas - totalOnline), C.blue],

// DESPUÉS
["Farmacia física", Math.max(0, totalVentas - totalOnline - ingresoConsultas), C.blue],
```

Y `totalFuentes` debe ser `totalVentas`, no la suma de las tres partes.

**Ya está verificado:** en `sql/patch_dashboard_margen_unidad_20260816.sql`, la llave `peds` trae **todos** los pedidos completados sin filtrar por tipo, mientras que `ponl` filtra `tipo = 'online'` y `pedsConsulta` filtra `tipo = 'consulta'` sobre el mismo conjunto. Los tres son subconjuntos de `peds`, así que restar ambos es lo correcto. Aun así, córrelo contra datos reales y confirma que las tres fuentes sumen exactamente el total.

**Mismo bloque, bug relacionado:** `ticketPromedio` (`DashboardModule.jsx:717`) divide entre `rep.ventas.length`, que incluye las consultas. Una consulta de $350 no es un ticket de mostrador y distorsiona el promedio. Calcula el ticket promedio solo sobre pedidos de venta (`tipo` distinto de `consulta`), y si quieres conserva el de consultas como métrica aparte.

### 1.6 · COGS desde el lote + cobertura de costo

En `empleado_dashboard_reporte_bundle` (`sql/patch_dashboard_margen_unidad_20260816.sql`, llave `peds_cat`), agrega el costo del lote al objeto de cada renglón:

```sql
left join public.lotes l on l.id = x.lote_id
...
'costo_lote', l.costo_unitario,
```

En `src/utils/margenVenta.js`, `costoUnitarioLinea()` debe preferir `item.costo_lote` sobre `item.productos.costo`, y **devolver `null`** (no `0`) cuando ninguno de los dos sea mayor a cero. Agrega un helper:

```js
export function lineaTieneCosto(item) {
  return Number.isFinite(costoUnitarioLinea(item)) && costoUnitarioLinea(item) > 0;
}
```

Luego, en el cálculo de `margenPorCat` (`DashboardModule.jsx:611-626`):

- Acumula por categoría: `ingreso`, `costo`, `ingresoConCosto`, `lineasSinCosto`.
- El margen % se calcula **solo sobre `ingresoConCosto`**, nunca sobre el ingreso total.
- Agrega columna **"Cobertura"** = `ingresoConCosto / ingreso`, con semáforo: verde ≥95%, ámbar 80–95%, rojo <80%.
- Si la cobertura global del período es <80%, banner ámbar arriba de la tabla: *"El margen mostrado cubre solo el X% de tus ventas. Captura los costos faltantes para que este número sea confiable."* con botón a Inventario.

### 1.7 · Que los descuentos sí lleguen a `pedido_items`

Modifica `create_sale_transaction_v2`: acepta `descuento_pct` dentro de cada objeto de `p_cart_items` y persiste el precio efectivamente cobrado, **validando en el servidor** que no exceda el precio de catálogo:

```sql
v_descuento_pct := least(greatest(coalesce((v_item->>'descuento_pct')::numeric, 0), 0), 100);
v_precio_cobrado := round(v_db_precio * (1 - v_descuento_pct / 100), 2);
```

Guarda `v_precio_cobrado` en `pedido_items.precio_unitario` y agrega `pedido_items.descuento_pct numeric(5,2) default 0` para trazabilidad.

**Criterio de aceptación:** para todo pedido nuevo,
`ABS(SUM(pedido_items.precio_unitario × cantidad) − pedidos.total_bruto) < 0.01`.
Escribe una consulta de verificación que liste los pedidos que lo incumplan y déjala en `sql/verificar_integridad_pedidos.sql`.

### 1.8 · Devoluciones dentro del margen

Las devoluciones hoy se muestran como KPI suelto y no tocan el margen por categoría. Corrígelo:

- Devolver mercancía revierte ingreso **y** revierte COGS (el producto regresa al inventario). Si el producto se destruye por daño o caducidad, revierte el ingreso pero el costo se queda como **merma**.
- **Buena noticia: el detalle ya existe.** `public.devolucion_items` (ver `sql/refactor_fase6b_rpcs_transacciones.sql:395`) guarda `devolucion_id, producto_id, producto_nombre, cantidad, precio_unitario`. Con `producto_id` llegas a la categoría, así que la reversión por categoría **sí** se puede hacer bien. Agrega `devolucion_items` al bundle de reporte y réstalo de `margenPorCat`.
- ⚠️ `devolucion_items` **no persiste `lote_id`** aunque el RPC lo lee del payload (línea 391). Sin eso, el COGS a revertir tiene que caer al respaldo `productos.costo`. Propón agregar la columna y persistirla; es un cambio de dos líneas y cierra el círculo del costo histórico.

### 1.9 · CAPEX fuera de localStorage

`DashboardModule.jsx:66-115` guarda el desglose de inversión en `localStorage`. Se pierde al limpiar el navegador y cada equipo ve un número distinto — y ese número es el denominador de todo el cálculo de ROI.

Muévelo a Supabase:

```sql
create table if not exists public.proyecto_capex (
  id           bigserial primary key,
  clave        text not null unique,
  label        text not null,
  nota         text,
  monto        numeric(12,2) not null default 0 check (monto >= 0),
  orden        int not null default 0,
  activo       boolean not null default true,
  updated_by   bigint references public.usuarios(id),
  updated_at   timestamptz not null default now()
);
```

RPC `admin_guardar_capex(p_session_token, p_lineas jsonb)` con `fn_require_admin`, y lectura dentro del bundle existente. Migra una sola vez lo que ya exista en `localStorage` y después deja de leerlo.

---

## PARTE 3 — FASE 2: Cerrar el escalón de utilidad bruta

> Meta: responder **"¿cuánto gané después del medicamento?"** con un solo número visible.

### 2.1 · KPIs totales en la pestaña Margen

Arriba de la tabla, sustituye la fila actual de 4 KPIs por:

| KPI | Fórmula | Color |
|---|---|---|
| Ventas brutas | `SUM(pedidos.total)` | azul |
| Devoluciones | `SUM(devoluciones.total_devuelto)` | rojo |
| **Ventas netas** | brutas − devoluciones | azul |
| **Costo de mercancía (COGS)** | `SUM(costo_linea)` con costo del lote | gris |
| **⭐ UTILIDAD BRUTA** | ventas netas − COGS | **verde, tamaño doble, la tarjeta más grande del tablero** |
| **Margen bruto %** | utilidad bruta ÷ ventas netas (solo líneas con costo) | verde/ámbar/rojo |
| Cobertura de costo | ingresoConCosto ÷ ingreso | semáforo |
| Utilidad por ticket | utilidad bruta ÷ número de tickets | morado |

La tarjeta de UTILIDAD BRUTA es la respuesta directa a la pregunta original. Que se vea de lejos.

### 2.2 · Fila TOTAL en la tabla de margen

Con `Ingreso`, `Costo`, `Ganancia` y `Margen %` ponderado (no el promedio simple de los porcentajes — eso da un número incorrecto cuando las categorías tienen tamaños distintos).

Agrega columnas **"% del ingreso"** y **"% de la utilidad"**. Esto revela el caso clásico de farmacia: la categoría que más factura no es la que más deja. Genéricos y dermocosmética suelen dejar más margen que patente de marca.

### 2.3 · Columna de utilidad en Transacciones

En `src/TransaccionesTab.jsx`, agrega columnas `Costo` y `Utilidad` por ticket, con el total del período junto a `sumaTotal` (línea 545). Marca en ámbar los tickets sin costo completo.

Agrega un filtro **"solo tickets con margen negativo"** — la forma más rápida de detectar precios mal capturados o promociones que están vendiendo por debajo del costo.

### 2.4 · Utilidad por empleado

En Resumen, la tabla "Ventas por empleado" gana una columna de utilidad generada y su margen %. Hoy premia al que más factura; debe premiar al que más deja.

---

## PARTE 4 — FASE 3: Gastos y pestaña Rentabilidad

> Meta: responder **"¿cuánto gané después de gastos?"**.

### 3.1 · Tabla de gastos

`sql/patch_modulo_gastos_YYYYMMDD.sql`:

```sql
create table if not exists public.gastos (
  id            bigserial primary key,
  fecha         date        not null default current_date,
  categoria     text        not null,   -- ver catálogo abajo
  subcategoria  text,
  concepto      text        not null,
  monto         numeric(12,2) not null check (monto >= 0),
  origen        text        not null default 'manual',  -- manual | nomina | comision_tpv | comision_online | merma
  ref_id        bigint,                 -- id del registro origen cuando es derivado
  es_recurrente boolean     not null default false,
  periodicidad  text,                   -- mensual | quincenal | semanal | anual
  proveedor     text,
  metodo_pago   text,
  deducible     boolean     not null default true,
  comprobante_url text,
  registrado_por bigint     references public.usuarios(id),
  notas         text,
  created_at    timestamptz not null default now()
);

create index if not exists idx_gastos_fecha     on public.gastos (fecha);
create index if not exists idx_gastos_categoria on public.gastos (categoria);
create unique index if not exists uq_gastos_derivado
  on public.gastos (origen, ref_id) where origen <> 'manual';
```

Ese índice único parcial es lo que impide que un gasto derivado se inserte dos veces si el proceso corre de nuevo.

**Catálogo de categorías** (constante compartida en `src/constants/categoriasGasto.js`, para que el select y los reportes no se desincronicen):

`renta` · `nomina` · `servicios` (luz, agua, internet, teléfono) · `comisiones` (TPV, plataformas) · `mermas` · `mantenimiento` · `publicidad` · `insumos` (bolsas, papel, limpieza) · `seguros` · `licencias` (COFEPRIS, software) · `impuestos` · `financieros` (intereses) · `ajuste_redondeo` · `otros`

**Clasificación fijo/variable** — necesaria para el punto de equilibrio:

```js
export const GASTO_FIJO = ["renta","nomina","servicios","seguros","licencias","mantenimiento"];
export const GASTO_VARIABLE = ["comisiones","mermas","insumos","publicidad","ajuste_redondeo"];
```

### 3.2 · RPCs

- `admin_registrar_gasto(p_session_token, p_gasto jsonb)`
- `admin_listar_gastos(p_session_token, p_desde, p_hasta, p_categoria)`
- `admin_eliminar_gasto(p_session_token, p_id)` — borrado lógico + `audit_log`, siguiendo el patrón del repo
- `admin_generar_gastos_derivados(p_session_token, p_desde, p_hasta)` — inserta nómina, comisiones y mermas; idempotente gracias a `uq_gastos_derivado`

Config nueva en `configuracion`: `comision_tpv_pct` (default `3.5`), `comision_online_pct` (default `25`), `carga_patronal_pct` (default `30`), `dias_operativos_mes` (default `30`).

### 3.3 · Pestaña nueva 💰 Rentabilidad

Agrégala a `DASHBOARD_TABS_DEFAULT` en `DashboardModule.jsx:118` y a los dos diccionarios de labels (línea 119 y 126). Respeta el reordenamiento por drag & drop que ya existe.

**Contenido, de arriba hacia abajo:**

**(a) Cascada visual.** Cada escalón con monto, % sobre ventas netas y una barra que se va acortando. Cada línea es clickeable y abre el detalle:

```
  Ventas brutas          $128,400   ████████████████████  100.0%
− Devoluciones            −$1,200   ▏                       0.9%
  ─────────────────────────────────────────────────────────────
= Ventas netas           $127,200   ███████████████████    99.1%
− Costo de mercancía     −$86,500   █████████████          67.4%
  ─────────────────────────────────────────────────────────────
= UTILIDAD BRUTA          $40,700   ██████                 31.7%   ← después del medicamento
− Gastos fijos           −$28,000   ████                   21.8%
− Gastos variables        −$6,200   ▉                       4.8%
  ─────────────────────────────────────────────────────────────
= UTILIDAD OPERATIVA       $6,500   █                       5.1%   ← después de gastos
```

Los últimos dos renglones llevan una etiqueta explícita — son las dos preguntas originales, contestadas.

**(b) Punto de equilibrio.** Tarjeta grande: PE mensual, PE diario, y **cuánto falta hoy** para alcanzarlo, con barra de progreso del día. Si ya se superó, mensaje verde: *"Punto de equilibrio alcanzado. Todo lo que vendas hoy es utilidad."*

**(c) Gastos por categoría.** Barras horizontales, ordenadas de mayor a menor, con % sobre ventas netas y comparativa contra el mes anterior. Marca visualmente los derivados (no editables) vs. los manuales.

**(d) Tabla de gastos del período** con alta rápida, edición y borrado. Formulario compacto: fecha, categoría, concepto, monto, recurrente. Que capturar la renta tome menos de 10 segundos, o nadie lo va a usar.

**(e) Tendencia de 6 meses.** Tres series: ventas netas, utilidad bruta, utilidad operativa. Es donde se ve si el negocio mejora o si un mes bueno fue suerte.

### 3.4 · Enganchar con Operación

En la pestaña Operación, agrega un `InsightCard` de **"Utilidad del mes"** con meta y tendencia, junto a los de ventas. La meta de utilidad se configura igual que las de venta (`meta_utilidad_mes` en `configuracion`), y el `InsightCard` ya soporta meta + delta + acción, así que reutiliza el componente tal cual.

---

## PARTE 5 — FASE 4: Indicadores de farmacia que faltan

Priorizados por utilidad real, no por facilidad.

| # | Indicador | Fórmula | Por qué importa | Dónde |
|---|---|---|---|---|
| 1 | **Valor de inventario a costo** | `SUM(lotes.cantidad_actual × costo_unitario)` | Es tu capital dormido. Suele ser el activo más grande de la farmacia y hoy no aparece en ningún lado | Rentabilidad + Inventario |
| 2 | **Rotación de inventario** | `COGS del período ÷ inventario promedio a costo` | Menos de 4× al año en farmacia es señal de sobrestock | Rentabilidad |
| 3 | **Días de inventario (DIO)** | `365 ÷ rotación` | "Tengo 90 días de stock" es más intuitivo que "roto 4 veces" | Rentabilidad |
| 4 | **GMROI** | `Utilidad bruta ÷ inventario promedio a costo` | El rey de los indicadores de retail: cuánto ganas por cada peso invertido en stock. Por categoría, decide qué resurtir y qué liquidar | Margen |
| 5 | **Merma por caducidad ($)** | `SUM(lotes vencidos × costo_unitario)` | Hoy solo cuentas piezas por caducar, no el dinero que se va a la basura | Rentabilidad + Operación |
| 6 | **Margen por canal** | Utilidad bruta por `tipo` (físico / online / consulta), **restando comisión de plataforma** | Rappi/online puede cobrar 20-30%. Sin esto, un canal que pierde dinero se ve igual de sano que el mostrador | Margen |
| 7 | **Flujo de efectivo** | Cobrado − pagado a proveedor − gastos pagados | Utilidad y efectivo no son lo mismo. Se puede tener utilidad y no tener con qué pagar la nómina | Rentabilidad |
| 8 | **Cuentas por pagar** | `SUM(compras.total WHERE estado='pendiente')` | Ya tienes la tabla `compras`. Es dinero comprometido que no se ve por ningún lado | Rentabilidad |
| 9 | **Productos bajo costo** | Líneas con `precio < costo` | Detecta errores de captura y promociones que sangran | Alerta en Operación |
| 10 | **Top 10 por utilidad** | Reordenar el top actual por ganancia, no por unidades | El top actual premia al producto barato de alta rotación | Operación |

**Nota sobre el #1 y #2:** "inventario promedio" requiere fotos históricas del valor de inventario. Como no existen, agrega una tabla `inventario_snapshot (fecha, valor_costo, valor_venta, unidades)` y un job diario. Los primeros 30 días la rotación no será confiable — **etiquétalo en la UI**, no lo escondas.

---

## PARTE 6 — Criterios de aceptación

Nada se marca como terminado sin verificar esto:

**Fase 1**

- [ ] Ningún literal de porcentaje sobrevive en cálculos financieros. `grep -rn "0\.55\|\* 0\.5" src/` no devuelve nada en lógica de utilidad.
- [ ] Venta de prueba con total bruto `$124.40` → cobra `$124.00`, `pedidos.total_bruto = 124.40`, `ajuste_redondeo = -0.40`, y el ticket muestra los tres renglones.
- [ ] Venta con total bruto `$124.50` → cobra `$125.00`.
- [ ] El cambio en efectivo se calcula sobre el total redondeado (paga con $200 → cambio $76.00, no $75.60).
- [ ] Venta con promoción: `ABS(SUM(items) − total_bruto) < 0.01`.
- [ ] En Resumen, las tres fuentes de ingreso suman exactamente 100%.
- [ ] Un producto con `costo = 0` **no** aparece con 100% de margen; cuenta como "sin costo".
- [ ] El CAPEX persiste después de borrar el localStorage del navegador.
- [ ] `npm run build` sin warnings nuevos.

**Fase 2**

- [ ] La tarjeta UTILIDAD BRUTA cuadra a mano: tomar 3 tickets, calcular ingreso − costo con calculadora, comparar.
- [ ] El margen % del TOTAL es ponderado, no el promedio de los porcentajes por categoría.
- [ ] La cobertura de costo se muestra en todas las vistas que usen margen.

**Fase 3**

- [ ] Capturar la renta y verla reflejada en la cascada en menos de 10 segundos.
- [ ] Correr `admin_generar_gastos_derivados` dos veces **no** duplica gastos.
- [ ] La nómina aparece una sola vez, aunque también exista en RRHH.
- [ ] Una compra a proveedor **no** aparece como gasto.
- [ ] El punto de equilibrio cuadra: `PE × margen% ≈ gastos fijos`.

**Transversal**

- [ ] Funciona en móvil (`useMediaQuery("(max-width: 768px)")` ya está en el módulo — úsalo).
- [ ] Todo dato que no se pueda calcular se muestra como "No disponible", nunca estimado en silencio.
- [ ] Los RPC nuevos validan sesión y rol antes de devolver datos financieros.
- [ ] Ningún `supabase.from()` nuevo en el cliente para datos de costo o utilidad.

---

## PARTE 7 — Lo que NO debes hacer

1. **No inventes constantes.** Si falta un dato, muestra "No disponible" y explica qué capturar. Es exactamente el problema que este trabajo viene a resolver; no lo reintroduzcas en otro lado.
2. **No metas las compras a proveedor en el P&L.** Comprar inventario es cambiar dinero por activo, no un gasto. Se vuelve COGS cuando se vende.
3. **No redondees los renglones**, solo el total del ticket.
4. **No trates un costo faltante como cero.** `null ≠ 0`.
5. **No reescribas `DashboardModule.jsx` de cero.** Son 1,171 líneas con lógica de metas, tendencias, drag & drop de pestañas y pendientes accionables que funciona bien. Cambios quirúrgicos.
6. **No cambies el diseño visual.** Estilos inline con `C_LIGHT` y `BRAND`, igual que el resto.
7. **No hagas las tres fases en un solo commit.** Una fase, una revisión, un merge.
8. **Si el esquema real no coincide con lo que dice este documento, detente y pregunta.** No implementes sobre una suposición.

---

## Resumen ejecutivo de las dos preguntas originales

**"¿Dónde veo el dinero neto que gané después de lo que me costó el medicamento?"**
→ Tarjeta **UTILIDAD BRUTA**, pestaña 💹 Margen (Fase 2). Fórmula: ventas netas − COGS del lote real.

**"¿Dónde veo la ganancia después de gastos?"**
→ Renglón **UTILIDAD OPERATIVA** de la cascada, pestaña 💰 Rentabilidad (Fase 3). Fórmula: utilidad bruta − gastos fijos − gastos variables.

**Y el número que más vas a usar:** el **punto de equilibrio diario** — cuánto tienes que vender hoy para no perder dinero.
