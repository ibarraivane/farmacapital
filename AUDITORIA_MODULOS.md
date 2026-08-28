# Auditoría FarmaCapital — lógica, conexión entre módulos y cableado de UI

> Documento para trabajar con Cursor. Cada hallazgo trae archivo:línea, qué pasa y qué cambiar.
> Auditado sobre el código del repo (`src/` + `sql/`). **No se verificó contra la base en vivo.**
>
> **Para ejecutar los arreglos, usa [`CURSOR_TAREAS.md`](./CURSOR_TAREAS.md)**: trae los
> paquetes de trabajo ordenados, con diffs exactos, verificación y criterios de aceptación.
> Este archivo es el diagnóstico; aquél es el plan.

**Índice**

- [0. Advertencia previa](#0-advertencia-previa-migraciones-sin-orden)
- [Parte 1 — Lógica y datos](#parte-1--lógica-y-datos)
  - [A. Bloqueadores](#a-bloqueadores--rompen-operación-hoy)
  - [B. Números que no cuadran](#b-números-que-no-cuadran-entre-módulos)
  - [C. Fechas y zonas horarias](#c-fechas--el-problema-sistémico)
  - [D. Stock y lotes](#d-stock-y-lotes--cuatro-fefo-distintos)
- [Parte 2 — UI, navegación y despliegue](#parte-2--ui-navegación-y-despliegue)
  - [F. Backend faltante](#f-botones-que-llaman-a-rpcs-que-no-existen)
  - [G. Recarga infinita](#g-bucle-de-recarga-infinito-tras-un-deploy)
  - [H. Robustez de botones](#h-botones-que-se-quedan-trabados)
  - [I. Lo que sí está bien](#i-lo-que-sí-está-bien-verificado)
- [E. Código muerto](#e-código-muerto-y-features-desconectadas)
- [Orden de ataque](#orden-de-ataque)

---

## 0. Advertencia previa: migraciones sin orden

`sql/` tiene **255 archivos** sin numeración ni orden garantizado, con funciones redefinidas muchas veces:

```
19x  create_producto_with_lote
16x  registrar_corte_caja
13x  receive_merchandise_lote
10x  reconcile_shift_cash
 9x  create_sale_transaction_v2   (repartidas en 5 archivos)
```

No hay forma de saber desde el repo **cuál versión está viva en Supabase**. Todo lo que sigue asume
que manda el patch con fecha más reciente.

**Acción:** crear `sql/migrations/NNN_*.sql` con orden explícito y tabla `schema_migrations`.
Sin esto, cualquier arreglo de SQL es a ciegas.

---

# Parte 1 — Lógica y datos

## A. Bloqueadores — rompen operación hoy

### A1 · Poner un descuento a un producto lo vuelve invendible · CRÍTICO

Cruza tres módulos:

| Paso | Dónde | Qué hace |
|---|---|---|
| 1 | `src/InventarioModule.jsx:1960`, `:2957`, `:3733` | El admin escribe `descuento_pct` en el producto |
| 2 | `src/modules/sales/pos/POS.jsx:1336`, `:1425` | El POS cobra `cobroLinea(precio, qty, descuento_pct)` |
| 3 | `sql/patch_create_sale_precio_unidad_regla.sql:186` | El RPC recalcula desde `p.precio` **sin leer `descuento_pct`** |
| 4 | idem `:227` | `raise exception 'Total mismatch detected'` |

**Resultado:** cualquier producto con `descuento_pct > 0` revienta el cobro. El cajero ve
"Total mismatch detected" y no puede vender. Es justo la función de descuento por caducidad
del commit `511b603`.

**Arreglo** — en `create_sale_transaction_v2`, traer `p.descuento_pct` en el mismo
`select … for update` que ya lee `p.precio`, y aplicarlo antes del redondeo, **en los dos bucles**
(validación `:186` y persistencia `:295`) para que `pedido_items.precio_unitario` guarde lo cobrado:

```sql
v_db_precio := v_db_precio * (1 - coalesce(v_descuento_pct, 0) / 100.0);
if p_tipo = 'pos' then
  v_db_precio := public.peso_publico(v_db_precio);
end if;
```

**Verificar primero:** ¿hay hoy productos con `descuento_pct > 0`? Eso decide si esto ya está
lastimando o es una bomba de tiempo.

```sql
select count(*) from productos where coalesce(descuento_pct,0) > 0;
```

### A2 · Ventas del mes truncadas a 500 tickets · CRÍTICO

- `src/DashboardModule.jsx:437-441` pide con `p_limite: 500`.
- El RPC (`sql/rpc_p1_lecturas_admin.sql:47`) hace `order by created_at desc limit`, y **no filtra
  por estado** — el recorte se aplica sobre todos los pedidos y recién después
  `pedidosCompletados()` (`:443`) filtra en el navegador. Los completados efectivos son menos de 500.
- `src/DashboardModule.jsx:466-482`: el patrón `pedVentasMes.length ? … : bundle` hace que ese
  conjunto recortado **le gane** a `ped_mes` del bundle (`sql/rpc_p1_lecturas_admin.sql:376`),
  que no tiene límite y ya viene filtrado por `estado='completado'` desde SQL.

Con `meta_ventas_mes=110000` y ticket ~120 son ~917 tickets/mes: el corte muerde alrededor del
día 15. De ahí en adelante "Ventas del mes" es en realidad una ventana rodante de ~2 semanas:
se estanca y nunca llega a la meta.

**Contamina:** ventas del mes, ingresos por fuente, ventas por empleado, y `gananciaMes`
(`= ventasMes * 0.55`) → el payback del proyecto sale pesimista.
**Se salva:** ticket promedio, porque es razón de dos cantidades igualmente recortadas.

**Arreglo:** que todos los totales salgan del bundle. `pedVentasMes` solo aporta el nombre del
empleado (`p.usuarios.nombre`), que el bundle no trae — agregar ese join a `ped_mes` en SQL y
borrar el fetch. De paso sale del camino crítico: hoy está fuera del `Promise.all`.

---

## B. Números que no cuadran entre módulos

### B1 · "Ventas" del Dashboard ≠ dinero que entró a Caja · ALTO

Caja está bien hecha. `reconcile_cash_rango`
(`sql/patch_caja_cadena_continua_20260824.sql:99-130`) es cuidadoso:

```sql
sum(total - coalesce(monto_credito, 0)) filter (where metodo_pago = 'efectivo')
...
'efectivo_sistema', v_ef_pedidos + v_ef_serv - v_dev_ef + v_dev_in
```

El Dashboard hace lo contrario: `sumPedidosTotal` (`src/DashboardModule.jsx:56`) suma
`pedidos.total` **crudo**. Entonces:

- **Suma crédito canjeado** — dinero que no entró; ya había entrado antes.
- **Ignora `pagos_servicio`** — el Dashboard solo lee `pedidos`. Los pagos de servicio viven en
  otra tabla que solo `TransaccionesTab.jsx:72` consulta. Una línea de ingreso entera invisible
  en Operación y Resumen.
- **Ignora devoluciones** en Operación, pero sí las resta en Margen (`rep.totalDevoluciones`).

Tres pantallas del mismo sistema dan tres cifras de "lo que vendimos hoy", ninguna etiquetada.

**Arreglo:** definir dos conceptos explícitos y etiquetarlos en pantalla:
`venta_bruta` y `ingreso_neto` (= bruto − crédito canjeado − devoluciones + servicios).
Lo más barato es un RPC único de totales que devuelva ambos, consumido por Dashboard, Caja y
Transacciones.

### B2 · Una devolución no revierte la venta · ALTO

`fn_ejecutar_efectos_devolucion` (`sql/patch_devoluciones_caja_credito_20260820.sql`) repone stock
y mueve crédito, pero el único `update public.pedidos` del archivo (línea 703) es para
`monto_credito`. **Nunca toca `estado` ni `total`.**

Como todo el reporting filtra `estado='completado'` y suma `total`, un producto devuelto cuenta
como venta para siempre. Combinado con B1, el `recuperado` del ROI
(`src/DashboardModule.jsx:~527`) está inflado por todas las devoluciones históricas.

**Arreglo:** agregar `pedidos.total_devuelto numeric default 0` que
`fn_ejecutar_efectos_devolucion` incremente, y que los agregados usen `total - total_devuelto`.
**No cambiar `estado`** — rompería los cortes de caja históricos, que sí están bien calculados.

### B3 · Las comparativas "vs periodo anterior" están muertas · MEDIO

Mismo origen que A2. `pedVentasMes` solo trae pedidos desde el 1 del mes actual, pero se usa para
calcular períodos anteriores:

```js
// src/DashboardModule.jsx:474
let pedMesAnt = pedVentasMes.length
  ? filtrarPedidosRango(pedVentasMes, monthPrevStart, monthPrevEnd)   // siempre []
  : rpcBundleRows(B, "ped_mes_ant");
```

Rango del mes pasado ∩ datos desde el 1 de este mes = vacío → `ventasMesAnt = 0` → `trendDelta`
devuelve `null` (`:186`) → **"Sin comparativo" permanente**. Igual el ticket promedio.

El de la semana (`pedSemanaAnt`, `:472`) es intermitente: el rango de hace 7–14 días cae fuera del
mes en curso durante la primera quincena, así que la flecha de tendencia aparece y desaparece
según el día del mes. **Se arregla solo con A2.**

### B4 · Dos definiciones de "día", "semana" y "meta" en la misma pantalla · MEDIO

- **Día:** la tarjeta "Ventas hoy" usa `metas.ventasDia` plano (`:536`, default 4000); la strip usa
  `metaDiaCompleto` con ajuste por día de semana (domingo 2800). Un domingo: **43% vs 61%**.
- **Semana:** `rangeWeek()` (`:159`) son los últimos 7 días rodantes; `construirSerie` grano semana
  es lunes–domingo. Dos cifras de "esta semana" a diez centímetros.
- **Prorrateo:** `metaVentasMesProrrateada` (`:723`) prorratea; `MetasPeriodoStrip` compara contra
  la meta completa. El día 3 la tarjeta dice **100%** y la strip dice **10% en rojo**.
- **Config:** `cargarConfigMetas()` y `cfg_rows` del bundle leen la misma tabla `configuracion` por
  dos caminos y se fusionan en `:594`.

**Arreglo:** una sola función `metasDelPeriodo(fecha)` en `src/lib/` que devuelva `{dia, semana, mes}`
con la misma regla, consumida por tarjetas y gráfica. Prorratear semana y mes en la strip, o
cambiar el marco a "vas al X% del ritmo".

### B5 · La vista "Mes" pinta 6 barras con 92 días de datos · BAJO

`src/lib/ventasVsMeta.js:104` itera 6 meses; `src/DashboardModule.jsx:401` solo pide 92 días.
Los ~3 meses más viejos salen en $0 y en rojo. Subir la ventana a ~190 días o no pintar barras
sin datos.

---

## C. Fechas — el problema sistémico

Hay **tres convenciones de "hoy" conviviendo**:

| Patrón | Qué es | Sitios |
|---|---|---|
| `toISOString().slice(0,10)` | día **UTC** | ~20 |
| `toLocaleDateString("sv-SE")` | día del **navegador** | ~20 |
| `Intl` con `America/Mexico_City` | día de la **farmacia** | 3 archivos |

El patrón UTC es el peligroso: en CDMX (UTC−6), `new Date().toISOString().slice(0,10)` **devuelve
mañana a partir de las 18:00 local**. La farmacia está abierta en turno vespertino: se equivoca
todas las tardes.

Sitios con consecuencia real:

| Archivo:línea | Qué se rompe |
|---|---|
| `src/PromocionesModule.jsx:196-197` | Promo con `fecha_fin` = hoy se marca vencida desde las 6pm |
| `src/hooks/useSidebarBadges.js:23` | Badge de alertas COFEPRIS se corre un día por la tarde |
| `src/DashboardModule.jsx:551` | Decide qué documento COFEPRIS está "vencido" |
| `src/db.js:162, 395, 430` | `obtenerVentasHoy`, `obtenerBitacoraHoy`, `obtenerCortesDia` |
| `src/Tienda.jsx:2662, 4096` | Vigencia de promos en la tienda online |
| `src/lib/ultimaCompra.js:121` | Fecha de compra registrada |
| `src/core/projections/salesProjection.js:13` | Agrupa ventas por día UTC |
| `src/core/readModels/buildSalesModel.js:14` | Idem |

**Lo bueno: el patrón correcto ya está escrito en el repo.** `src/lib/rhSemana.js:9-26` hace
exactamente lo que hay que hacer — `Intl.DateTimeFormat` con TZ para obtener el día, y luego
aritmética en UTC sobre el `YYYY-MM-DD` como fecha pura:

```js
export function hoyISOMexico(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(now);
}
```

**Arreglo:** promover `hoyISOMexico` / `addDaysISO` / `dowISO` a un `src/lib/fecha.js` compartido y
sustituir los ~40 sitios. Es mecánico y de alto retorno. Añadir una regla de ESLint
(`no-restricted-syntax`) que prohíba `toISOString().slice(0,10)` para que no vuelva a entrar.

---

## D. Stock y lotes — cuatro FEFO distintos

La misma operación ("saca N unidades de los lotes") está implementada cuatro veces con reglas
diferentes:

| Implementación | Usa | ¿Excluye vencidos? | ¿Viva? |
|---|---|---|---|
| `create_sale_transaction_v2` (venta) | `get_lote_fefo` | Sí | Sí |
| `fn_descontar_fefo_cantidad` (cambio) | `get_lote_fefo` | Sí | Sí |
| `consume_stock_via_lotes` | query propia | **No** | Sin llamadas |
| `adjust_stock_via_lotes` | query propia | **No** | Sí |

### D1 · `consume_stock_via_lotes` se contradice a sí misma · MEDIO (latente)

`sql/refactor_fase3a_addendum.sql`. **Verifica** disponibilidad excluyendo vencidos:

```sql
and (l.fecha_caducidad is null or l.fecha_caducidad >= current_date)
```

y luego **consume** sin ese filtro, ordenando por `fecha_caducidad asc` — los lotes vencidos, al
tener la fecha más antigua, se consumen **primero**. Te dice que revisó que hay producto bueno y
despacha el caducado.

**Atenuante:** no hay llamadas desde el frontend a `consume_stock_secure`. Es una mina sin pisar,
pero está `grant`eada a `anon` (`sql/refactor_fase6b_rpcs_secure_wrappers.sql`).

### D2 · Una devolución puede resucitar un lote vencido · MEDIO

`restock_via_lote` (`sql/refactor_fase3a_rpcs_lotes.sql`), cuando no le pasan `lote_id`:

```sql
order by (fecha_caducidad is null) asc, fecha_caducidad desc nulls last, id desc
...
update public.lotes
set cantidad_actual = ... + p_cantidad,
    activo = true          -- sin comprobar caducidad
```

Dos problemas: elige el lote de caducidad **más lejana** (LIFO, al revés del FEFO con que se
vendió — rompe trazabilidad COFEPRIS), y reactiva el lote sin mirar si ya caducó.

**Arreglo:** exigir `lote_id` cuando `devolucion_items` lo tenga (que es el caso), y si no, crear
un lote `REINTEGRO-` nuevo en vez de tocar uno existente. Nunca `activo = true` sin validar
`fecha_caducidad >= current_date`.

### D3 · La venta por unidad no toca lotes · MEDIO

En `create_sale_transaction_v2`, `modo_venta = 'unidad'` solo hace
`update productos set stock_unidades = …`. No descuenta ningún lote y guarda el `pedido_item`
con `lote = null`.

Consecuencia: las unidades sueltas **no tienen trazabilidad de lote** (problema regulatorio en
farmacia) y `productos.stock` — que el trigger define como `sum(lotes.cantidad_actual)` — sigue
contando la caja completa de la que salieron.

### D4 · `productos.stock` declarado derivado pero escrito a mano · BAJO

`sql/refactor_fase2_5b_trigger_stock.sql` es explícito:

> `Productos.stock ya NO es fuente de verdad, es campo derivado.`

Y aun así `create_sale_transaction_v2` hace `update public.productos set stock = v_stock_nuevo`
después de haber movido los lotes (que ya dispararon el trigger). Hoy coinciden, así que no se
nota; pero cualquier divergencia futura entre `productos.stock` y `sum(lotes)` queda **congelada**
por esa escritura manual en vez de corregida por el trigger.

**Arreglo:** borrar las escrituras directas a `productos.stock` en rutas que ya mueven lotes.
Consolidar los cuatro FEFO en una sola función que reciba una política
(`'venta' | 'merma' | 'ajuste'`) y decida ahí si incluye vencidos.

---

# Parte 2 — UI, navegación y despliegue

## F. Botones que llaman a RPCs que no existen · CRÍTICO

Cruzando los 176 RPC invocados desde `src/` contra las 264 funciones definidas en `sql/`,
**11 no existen en ningún archivo del repo**:

| RPC | Llamado desde | Módulo |
|---|---|---|
| `admin_listar_propuestas_precio` | `src/MonitorPreciosModule.jsx:37` | Aprobar PVP |
| `admin_listar_mapeos_monitor` | `src/MonitorPreciosModule.jsx:58` | Aprobar PVP |
| `admin_listar_anomalias_monitor` | `src/MonitorPreciosModule.jsx:62` | Aprobar PVP |
| `admin_aprobar_propuestas_precio` | `src/MonitorPreciosModule.jsx:97` | Aprobar PVP |
| `admin_rechazar_propuestas_precio` | `src/MonitorPreciosModule.jsx:115` | Aprobar PVP |
| `admin_decidir_mapeo_monitor` | `src/MonitorPreciosModule.jsx:130` | Aprobar PVP |
| `admin_resolver_anomalia_monitor` | `src/MonitorPreciosModule.jsx:146` | Aprobar PVP |
| `admin_listar_propuestas_caducidad` | `src/DescuentoCaducidadModule.jsx:41` | Precio por caducar |
| `admin_aprobar_propuestas_caducidad` | `src/DescuentoCaducidadModule.jsx:123` | Precio por caducar |
| `admin_rechazar_propuestas_caducidad` | `src/DescuentoCaducidadModule.jsx:142` | Precio por caducar |
| `get_next_folio` | `src/utils/folioGenerator.js:16` | Folios |

**Dos pestañas completas de Inventario** (`aprobar` y `caducidad` en `InventarioHub.jsx:26-27`)
dependen enteramente de RPCs que el repo no puede crear. Están montadas, son clicables, y cada
botón falla.

El propio código lo delata — `src/MonitorPreciosModule.jsx:70`:

```js
showToast(err.message || "No se pudo cargar el monitor. ¿Corriste el SQL?", "error");
```

Es decir: el SQL se aplicó a mano en Supabase y nunca se comiteó. **El repo no puede reconstruir
la base.** Si alguien levanta un entorno nuevo (o hay que restaurar), esos módulos no existen.

`get_next_folio` es distinto: `getSiguienteFolio()` **no tiene ningún llamador**, así que el sistema
de folios secuenciales está muerto por completo. Y su fallback silencioso
(`src/utils/folioGenerator.js:23`) devuelve `VTA-${Date.now()}`, que rompe la promesa de
"secuencial, sin duplicados" del encabezado del archivo.

**Acción:** exportar esas 10 funciones desde Supabase (`pg_get_functiondef`) y comitearlas a
`sql/migrations/`. Borrar `folioGenerator.js` o conectarlo.

```sql
select pg_get_functiondef(p.oid)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname='public' and p.proname like 'admin_%monitor%'
   or p.proname like 'admin_%propuestas%' or p.proname='get_next_folio';
```

## G. Bucle de recarga infinito tras un deploy · ALTO

`src/index.js:68-95` implementa recuperación ante `ChunkLoadError` (caché vieja tras deploy):
lee un contador, si llegó a 4 se rinde, si no lo incrementa y recarga con cache-buster.

Pero `src/App.js:120-123` borra ese contador **en cada montaje de App**:

```js
useEffect(() => {
  try { sessionStorage.removeItem("farmacapital_chunk_retries"); } catch (_) {}
}, []);
```

`Admin` y `Tienda` se importan de forma eager, así que App monta **antes** de que fallen los
chunks `lazy()` (los 7 de `InventarioHub.jsx:11-17`). Secuencia:

1. Carga la página → App monta → contador a 0.
2. El usuario abre una pestaña de Inventario → el chunk falla → contador 0→1 → recarga.
3. Recarga → App monta → **contador a 0 otra vez**.
4. `InventarioHub` restaura la pestaña desde `sessionStorage` (`STORAGE_KEY`, línea 31) → vuelve
   a pedir el mismo chunk → falla → recarga.
5. Bucle. El corta-circuitos `retries >= 4` nunca se dispara.

El paso 4 es determinista, no casual: la pestaña se persiste y se restaura.

**Arreglo:** no limpiar el contador al montar App. Limpiarlo cuando un chunk `lazy` cargue bien
(en el `then` de un import o tras un timeout de estabilidad de ~10s sin errores).

## H. Botones que se quedan trabados · MEDIO

**24 handlers** ponen `setSaving(true)` / `setBusy(true)`, hacen `await`, y no tienen `catch` ni
`finally`. En `supabase-js` v2 el `.rpc()` normalmente resuelve con `{error}` en vez de lanzar,
así que el camino de error de negocio está cubierto — pero **un fallo de red sí rechaza la
promesa**, y ahí el botón queda deshabilitado para siempre y hay que recargar.

En una farmacia con wifi intermitente eso pasa. El más caro operativamente:

```js
// src/modules/sales/pos/AperturaCajaModal.jsx:67-69
setSaving(true);
const { sesion, error } = await abrirSesionCaja({ denoms, nota });
setSaving(false);   // nunca se ejecuta si abrirSesionCaja lanza
```

Si eso falla, **la cajera no puede abrir la caja** y no puede vender hasta recargar.

Lista completa:

```
src/modules/sales/pos/AperturaCajaModal.jsx:67   ← el más crítico
src/RappiSyncPanel.jsx:82
src/ClientesModule.jsx:50, 156, 171, 187, 211
src/LotesModule.jsx:191
src/InventarioModule.jsx:944, 1435
src/RecepcionModule.jsx:390, 731
src/AdminDashboard.jsx:68
src/Admin.jsx:740
src/MonitorPreciosModule.jsx:96, 114, 129, 145
src/COFEPRISModule.jsx:99
src/DescuentoCaducidadModule.jsx:121, 140
src/modules/clinical/ConsultorioModule.jsx:58, 105, 488
```

**Arreglo:** envolver en `try/finally` con `setSaving(false)` en el `finally`. Es mecánico.

## I. Lo que sí está bien (verificado)

Para que Cursor no toque lo que funciona:

- **Navegación: cero rutas rotas.** Cruzando `NAV_ITEMS` (23 ids), `NAV_ADMIN`, `NAV_VENDEDOR`,
  `NAV_DOCTORA`, `ADMIN_NAV_SECTIONS` contra los 25 `case` de `Admin.renderPage`: ningún item de
  menú cae en el `default` ("Módulo en construcción"), y ninguna sección referencia un id
  inexistente.
- **Deep-links correctos.** `setPageAndSave(id, opts)` (`Admin.jsx:1871`) propaga `tab`, `posTab` y
  `dashTab`. Los destinos existen: tabs de POS (`venta|online|consultas|servicios`,
  `POS.jsx:476`) y las 7 de `InventarioHub` (`:21-29`), todas renderizadas (`:140-148`).
- **Botones sin handler: uno solo**, y está dentro de un bloque comentado (`Admin.jsx:428`).
- **Sin `href="#"` ni links vacíos** en todo `src/`.
- **Claves de storage consistentes**: ninguna se escribe sin leerse ni al revés.
- **Corte de caja**: `reconcile_cash_rango` es el módulo mejor resuelto del sistema — descuenta
  crédito, suma servicios, resta devoluciones en efectivo y suma las de cambio.
- **`src/lib/rhSemana.js`**: el manejo de fechas correcto, listo para generalizar.

---

## E. Código muerto y features desconectadas

### E1 · Promociones no se aplican en ningún lado · ALTO

`src/modules/sales/pos/POS.jsx:1334` dice:

```js
// P2.2: Calcular total con promociones activas aplicadas
return cart.reduce((a,c) => a + cobroLinea(c.precio, c.qty, c.descuento_pct), 0);
```

El comentario miente: **no lee la tabla `promociones`**. `PromocionesModule.jsx` es un CRUD cuyo
resultado solo aparece como banner informativo en `Tienda.jsx:2663` y `:4097`. Un admin crea un
2x1, lo ve listado, y no aplica en ninguna venta.

### E2 · Arquitectura de event-sourcing construida y nunca conectada · MEDIO

`src/core/eventStore/initEventStore` se monta en `src/index.js:6`, pero toda la capa de lectura
está huérfana. Componentes **nunca importados**:

```
src/modules/admin/projections/EventDashboard.jsx
src/modules/admin/replay/ReplayDashboard.jsx
src/modules/admin/ProductosValidacionDashboard.jsx
src/modules/billing/ledger/LedgerView.jsx
src/modules/clinical/ConsDoctora.jsx
src/modules/shared/navigation/Sidebar.jsx      ← Admin.jsx tiene su propio sidebar inline
```

Y `useSalesReport` (`src/modules/billing/projections/useSalesReport.js`) no se usa en ningún
componente. Son proyecciones de ventas paralelas a `pedidos`, agrupadas por día UTC (ver C).
**O se conecta o se borra**; en medio solo confunde y engorda el bundle.

### E3 · La vista de vendedor del Dashboard es inalcanzable · BAJO

`DashboardModule.jsx:325` define `soloTransacciones = usuario?.rol === "vendedor"`, y
`Admin.jsx:2197` la habilita si `puedeVerModulo(usuario, "trans")`. Pero `permissions.js:88`
bloquea `"trans"` para vendedor incondicionalmente.

Además `"trans"` no está en `NAV_ITEMS` ni tiene `case` en `renderPage`: es un id fantasma que
solo existe en la lista de permisos. No es hueco de seguridad — es código muerto que aparenta
una función inexistente.

### E4 · RPC sin llamadas y con grant a `anon` · BAJO

`consume_stock_secure` no tiene llamadores (ver D1). Revocar o borrar.

### E5 · Menores en el Dashboard · BAJO

- `metaSemana()` es inalcanzable: `mezclarCfgMetas` siempre inyecta `meta_ventas_semana` desde
  `METAS_COLONIA_DEF`, así que la rama de suma-de-días con ajustes nunca corre. El test que la
  cubre llama a la lib directo, no al componente → **cobertura con confianza falsa**.
- `metaConsultasMesProrrateada` (`:724`) se calcula y no se usa.
- `invalidarCacheMetas()` existe y nadie la llama: tras editar metas, la gráfica queda hasta 60s
  con la meta vieja.
- `VentasVsMetaChart.jsx:165`: `role="img"` con `<button>` adentro. ARIA vuelve presentacionales a
  los hijos de un `role="img"` → las barras clicables desaparecen para lectores de pantalla.
  Usar `figure` o `role="group"`.
- `Admin.renderPage` tiene `case "cons_cobro"` y `case "inventario"` que nadie navega. Rutas muertas.

### E6 · Acceso directo a tablas saltándose la capa de RPCs seguras · REVISAR

Se construyeron 52 RPCs `security definer` en la fase 6b, pero el frontend sigue leyendo tablas
directo:

```
16x .from("productos")        9x .from("configuracion")     6x .from("citas")
 6x .from("producto_precios_referencia")   6x .from("event_log")
 4x .from("promociones")      3x .from("rappi_sync_queue")  3x .from("banners")
```

Si esas tablas tienen RLS bien puesta no hay problema de seguridad, pero sí de consistencia: dos
caminos de lectura con reglas distintas. **Verificar RLS** en `productos`, `configuracion` y
`citas` antes de decidir si migrar o documentar la excepción.

---

## Orden de ataque

| # | Qué | Por qué primero |
|---|---|---|
| 1 | **A1** — descuentos rompen ventas | Bloqueador de mostrador |
| 2 | **F** — exportar los 10 RPCs faltantes a `sql/` | Dos pestañas muertas + el repo no reconstruye la base |
| 3 | **A2 + B3** — un cambio arregla el número más mirado y resucita las comparativas | Alto impacto, bajo riesgo |
| 4 | **G** — bucle de recarga | Deja la app inusable tras un deploy |
| 5 | **C** — extraer `src/lib/fecha.js`, barrer ~40 sitios | Mecánico, alto retorno, + regla de lint |
| 6 | **H** — `try/finally` en los 24 handlers | Mecánico |
| 7 | **B2 + B1** — `total_devuelto` y separar bruto/neto | Toca SQL y varios módulos; con calma |
| 8 | **D** — unificar FEFO, quitar escrituras manuales a `productos.stock` | Riesgo regulatorio |
| 9 | **E** — por cada uno: conectar o borrar | Nada intermedio |
| 0 | **Migraciones ordenadas** | Debería ser lo primero si van a tocar SQL en serio |

---

## Pendiente de verificar contra la base en vivo

1. ¿Cuál definición de `create_sale_transaction_v2` está desplegada? Hay 9 en el repo.
2. ¿Existen hoy productos con `descuento_pct > 0`? Decide si A1 ya está lastimando.
3. ¿Están las 10 funciones de monitor/caducidad realmente creadas en Supabase, o esas pestañas
   llevan tiempo rotas?
4. ¿`productos.stock` coincide hoy con `sum(lotes.cantidad_actual)`?
   ```sql
   select p.id, p.stock, coalesce(sum(l.cantidad_actual),0) as en_lotes
   from productos p left join lotes l on l.producto_id = p.id and coalesce(l.activo,true)
   group by p.id, p.stock having p.stock <> coalesce(sum(l.cantidad_actual),0);
   ```
5. ¿RLS activa en `productos`, `configuracion`, `citas`? (E6)
