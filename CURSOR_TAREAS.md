# Plan de trabajo para Cursor

Paquetes de trabajo derivados de [`AUDITORIA_MODULOS.md`](./AUDITORIA_MODULOS.md).
Cada tarea es **un commit independiente**. Están ordenadas: T1 y T2 primero.

**Cómo usar este archivo:** abre Cursor, referencia `@CURSOR_TAREAS.md` y
`@AUDITORIA_MODULOS.md`, y pega el bloque `PROMPT` de la tarea que toque.
Las reglas de `.cursor/rules/farmacapital-invariantes.mdc` se aplican solas.

> ## ⚠️ Esto corre en producción
>
> Una sola base Supabase, sin staging. Farmacia abierta, vendiendo.
> **Ninguna tarea de este archivo modifica, borra ni migra datos existentes.**
> Si un paso te pide mutar filas, está mal escrito: para y pregunta.
>
> Lee **[Protocolo de producción](#protocolo-de-producción)** antes de tocar SQL.
> Es obligatorio, no una recomendación.

**Antes de empezar cualquier tarea de SQL**, corre las consultas de
[Verificación previa](#verificación-previa-obligatoria) contra Supabase. Varias tareas
cambian de forma según lo que devuelvan.

---

## Verificación previa (obligatoria)

Corre esto en el SQL Editor de Supabase y pega los resultados en el chat de Cursor.
Sin esto, T1 y T2 se hacen a ciegas.

```sql
-- 1. ¿Hay productos con descuento? Decide la urgencia de T1.
select count(*) as con_descuento from productos where coalesce(descuento_pct,0) > 0;

-- 2. ¿Qué versión de la venta está viva? Busca si el cuerpo menciona descuento_pct.
select prosrc like '%descuento_pct%' as ya_aplica_descuento,
       prosrc like '%peso_publico%'  as ya_redondea
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'create_sale_transaction_v2';

-- 3. ¿Existen las funciones que el front llama y no están en el repo? (T2)
select proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname='public' and proname in (
  'admin_listar_propuestas_precio','admin_listar_mapeos_monitor',
  'admin_listar_anomalias_monitor','admin_aprobar_propuestas_precio',
  'admin_rechazar_propuestas_precio','admin_decidir_mapeo_monitor',
  'admin_resolver_anomalia_monitor','admin_listar_propuestas_caducidad',
  'admin_aprobar_propuestas_caducidad','admin_rechazar_propuestas_caducidad',
  'get_next_folio');

-- 4. ¿productos.stock coincide con los lotes? (T9)
select count(*) as productos_descuadrados from (
  select p.id from productos p
  left join lotes l on l.producto_id = p.id and coalesce(l.activo,true)
  group by p.id, p.stock having p.stock <> coalesce(sum(l.cantidad_actual),0)
) x;
```

---

---

## Protocolo de producción

### Clasificación de riesgo

| Tarea | Qué toca | ¿Riesgo para datos existentes? |
|---|---|---|
| T3, T4, T5, T6, T8 | Solo código del front | **Ninguno.** Deploy normal, revertible con un revert |
| T2 | `create` de funciones/tablas que faltan | Ninguno **si** usas `if not exists` y no re-declaras nada que ya exista |
| T1 | `create or replace` de la función de **venta** | Ninguno sobre filas viejas, pero **cambia cómo se cobra desde ese segundo**. Ver abajo |
| T7 | `alter table pedidos add column` | Ninguno con `default 0`. **Sin backfill** |
| T9 | Funciones que **descuentan stock** | **Alto.** No entrar sin ambiente de pruebas |

Nada aquí hace `update`, `delete` ni `truncate` sobre datos históricos. Si en algún momento
alguien propone un backfill (por ejemplo, llenar `total_devuelto` hacia atrás), eso es un
proyecto aparte, con su propio respaldo y su propia ventana. No lo mezcles con estas tareas.

### La regla que más importa

**Nunca corras un `create or replace function` copiado de un archivo del repo.**

`sql/` tiene 255 archivos sin orden y funciones redefinidas hasta 19 veces. La versión del
repo puede ser **más vieja** que la que está viva en Supabase. Si la pegas tal cual, revierte
silenciosamente arreglos que ya estaban aplicados — y en `create_sale_transaction_v2` eso
significa romper el cobro en el mostrador, en vivo, sin aviso.

El procedimiento correcto, siempre:

```sql
-- 1. Sacar la definición VIVA y guardarla (esto es tu rollback).
select pg_get_functiondef(p.oid)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname = 'create_sale_transaction_v2';
```

2. Pega ese resultado en `sql/migrations/000_snapshot_<fecha>_<funcion>.sql` y **comitéalo**.
   Ese archivo es el botón de deshacer.
3. Sobre **esa** definición (no la del repo) aplica el cambio de la tarea.
4. Ejecuta el `create or replace` resultante.
5. Si algo sale mal: vuelve a ejecutar el snapshot del paso 2. Vuelve al estado exacto anterior.

`create or replace function` es atómico y no bloquea ventas en curso: una venta que ya empezó
termina con la versión vieja, la siguiente usa la nueva. No hay estado intermedio.

### Antes de cualquier ejecución de SQL

1. **Confirma que el respaldo de hoy corrió.** El workflow `backup.yml` hace `pg_dump` diario
   a las 06:30 UTC (00:30 CDMX) y guarda 30 días. Revisa en GitHub → Actions que el último
   corrió en verde. Si no, dispáralo a mano (`workflow_dispatch`) y espera a que termine.
2. **Ventana horaria.** Fuera del horario de mostrador. Nada de SQL en hora pico.
3. **Una tarea a la vez.** Ejecuta, verifica en la app real, y recién entonces la siguiente.
   Si algo se rompe quieres saber exactamente qué lo rompió.
4. **Ten el snapshot abierto** en otra pestaña antes de ejecutar. Si hay que revertir, son
   segundos, no minutos buscando el archivo.

### Cómo probar sin ensuciar datos

En orden de preferencia:

1. **Consultas de verificación que no escriben** — comparan lo que la función *calcularía*
   contra lo que el front manda. Cada tarea trae la suya. Empieza siempre por aquí.
2. **Una copia real para pruebas.** Restaura el último `pg_dump` en un Postgres local o en un
   segundo proyecto Supabase. Es la única forma honesta de probar T9. Vale el rato que toma.
3. **Transacción con `rollback`** — sirve, pero deja huella: consume ids de secuencia
   (`pedidos.id` avanza aunque revierta). Inofensivo, pero no lo uses en bucle ni te asustes
   si ves un salto de folio.
4. **Venta real de prueba en el POS** — última opción. Es una venta de verdad: aparece en el
   corte de caja y en el dashboard. Si la haces, hazla por el monto mínimo y devuélvela por
   el flujo normal de Devoluciones, para que quede el rastro correcto en vez de un borrado.

**Nunca:** `update`/`delete` a mano para "dejar limpio" lo que dejó una prueba. Un dato de
prueba trazable es mejor que un borrado sin rastro en una farmacia.

### Orden de despliegue recomendado

Las tareas de **solo front** (T4, T6, T3-parte-JS) no tocan la base y se pueden desplegar
cualquier día: si algo falla, `git revert` y redeploy.

Las de SQL (T1, T2, T3-parte-SQL, T7) van de a una, con snapshot previo, fuera de horario.

---

## T1 · Aplicar `descuento_pct` en el cobro · CRÍTICO · ~30 min

### Qué pasa

El POS cobra con descuento (`src/modules/sales/pos/POS.jsx:1336`), el RPC recalcula sin él
y aborta. Cualquier producto con `descuento_pct > 0` es invendible.

### Archivos

- **Punto de partida: la definición VIVA en Supabase**, no la del repo. Ver
  [Protocolo](#la-regla-que-más-importa). `create_sale_transaction_v2` está declarada
  9 veces en `sql/`; pegar la del repo puede revertir arreglos ya aplicados y romper el
  cobro en vivo.
- `sql/migrations/000_snapshot_<fecha>_create_sale_transaction_v2.sql` (rollback)
- `sql/migrations/001_venta_aplica_descuento_pct.sql` (el cambio)
- Referencia de lectura: `sql/patch_create_sale_precio_unidad_regla.sql` — sirve para ubicar
  **dónde** van los cambios, no para copiar el cuerpo.

### Cambio exacto

**a) Declaración** — después de `v_tipo_prod text;` (línea ~110):

```sql
  v_descuento_pct numeric;
```

**b) Bucle de validación** (líneas ~154-187). El `select` pasa de:

```sql
      coalesce(p.categoria, ''),
      coalesce(p.tipo, '')
    into v_stock_actual, v_stock_unidades_actual,
         v_precio_prod, v_precio_unidad_prod, v_upc,
         v_costo_prod, v_categoria_prod, v_tipo_prod
```

a:

```sql
      coalesce(p.categoria, ''),
      coalesce(p.tipo, ''),
      coalesce(p.descuento_pct, 0)
    into v_stock_actual, v_stock_unidades_actual,
         v_precio_prod, v_precio_unidad_prod, v_upc,
         v_costo_prod, v_categoria_prod, v_tipo_prod, v_descuento_pct
```

Y el bloque de precio, de:

```sql
    if p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
```

a:

```sql
    -- El mostrador cobra con el descuento del catálogo (POS.jsx → cobroLinea).
    -- Si esto no se aplica aquí, la venta aborta con Total mismatch.
    if coalesce(v_descuento_pct, 0) > 0 then
      v_db_precio := v_db_precio * (1 - v_descuento_pct / 100.0);
    end if;
    if p_tipo = 'pos' then
      v_db_precio := public.peso_publico(v_db_precio);
    end if;
```

**c) Bucle de persistencia** (líneas ~269-296): el mismo cambio en su `select`
(el que hace `into v_precio_prod, v_precio_unidad_prod, v_upc, v_stock_unidades_actual, …`)
y en su bloque de precio.

> **El orden importa:** descuento primero, redondeo después. Así coincide con
> `cobroLinea` en `src/utils/pesoPublico.js:10-13`, que hace
> `pesoPublico(precio * (1 - pct/100))`.

### Verificación (sin escribir nada)

**Paso 1 — comprobar que las dos fórmulas coinciden.** No toca datos:

```sql
-- Lo que el RPC va a calcular, producto por producto, para los que tienen descuento.
select p.id, p.nombre, p.precio, p.descuento_pct,
       public.peso_publico(p.precio * (1 - coalesce(p.descuento_pct,0)/100.0)) as cobrara_el_rpc
from public.productos p
where coalesce(p.descuento_pct,0) > 0
order by p.nombre;
```

Compara `cobrara_el_rpc` con lo que muestra el POS en la línea del carrito. Tienen que ser
idénticos: el front hace `pesoPublico(precio * (1 - pct/100))` en
`src/utils/pesoPublico.js:10-13`.

**Paso 2 — no romper lo que ya funciona.** Para productos SIN descuento el resultado no
puede cambiar:

```sql
select count(*) as deberia_ser_cero
from public.productos p
where coalesce(p.descuento_pct,0) = 0
  and public.peso_publico(p.precio * (1 - coalesce(p.descuento_pct,0)/100.0))
      is distinct from public.peso_publico(p.precio);
```

**Paso 3 — prueba de punta a punta.** Solo si los pasos 1 y 2 cuadran, y fuera de horario:
una venta real en el POS de un producto con descuento, por el monto más bajo posible.
No debe salir "Total mismatch". Déjala registrada o devuélvela por el flujo normal de
Devoluciones — nunca la borres a mano.

> Si la consulta #1 de la verificación previa devolvió **0 productos con descuento**, el bug
> no está lastimando hoy. Aplica el arreglo igual (es preventivo y sin riesgo), pero el
> paso 3 tendrás que hacerlo poniendo un descuento a un producto real. Ponlo, prueba,
> y déjalo o quítalo desde la UI de Inventario — no con SQL.

### Criterio de aceptación

- [ ] Venta con `descuento_pct > 0` se cobra sin error.
- [ ] `pedido_items.precio_unitario` guarda el precio **con** descuento.
- [ ] Venta sin descuento sigue cobrando igual que antes (no hay regresión de centavos).
- [ ] `p_tipo = 'online'` sigue **sin** redondear a pesos enteros.
- [ ] El snapshot de la función original está comiteado en `sql/migrations/000_*.sql`.

### PROMPT

```
Lee @AUDITORIA_MODULOS.md sección A1 y @CURSOR_TAREAS.md tarea T1.

Esto va a producción en vivo, sin staging.

Te voy a pegar la definición VIVA de create_sale_transaction_v2, sacada de Supabase con
pg_get_functiondef. NO uses la del repo: hay 9 definiciones y la del repo puede ser vieja.

1. Guarda lo que te pegue tal cual en sql/migrations/000_snapshot_<fecha>_create_sale_transaction_v2.sql
   (es el rollback, no lo modifiques).
2. Crea sql/migrations/001_venta_aplica_descuento_pct.sql partiendo de ESA definición y
   aplicando los tres cambios de T1: declarar v_descuento_pct, agregarlo al select y aplicar
   el descuento antes del peso_publico, en LOS DOS bucles.

Reglas: descuento antes del redondeo. No cambies absolutamente nada más de la función.
No toques el front. Ningún update/delete a datos. Deja el grant al final.
```

---

## T2 · Traer al repo los 11 RPCs que faltan · CRÍTICO · ~1 h

### Qué pasa

`MonitorPreciosModule` y `DescuentoCaducidadModule` — dos pestañas de Inventario — llaman
a 10 funciones que no existen en `sql/`. El SQL se aplicó a mano en Supabase.
**El repo no reconstruye la base.**

### Paso 1 — exportar desde Supabase

```sql
select 'sql/migrations/002_monitor_precios_caducidad.sql' as destino,
       pg_get_functiondef(p.oid) || E';\n' as ddl
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname in (
  'admin_listar_propuestas_precio','admin_listar_mapeos_monitor',
  'admin_listar_anomalias_monitor','admin_aprobar_propuestas_precio',
  'admin_rechazar_propuestas_precio','admin_decidir_mapeo_monitor',
  'admin_resolver_anomalia_monitor','admin_listar_propuestas_caducidad',
  'admin_aprobar_propuestas_caducidad','admin_rechazar_propuestas_caducidad')
order by p.proname;
```

Añade también las tablas que usan (`propuestas_precio`, `mapeos_monitor`,
`anomalias_monitor`, o como se llamen — sácalas del `prosrc`) y sus `grant`.

> **En vivo:** este paso es una **exportación, no una ejecución**. Estás copiando a `sql/`
> lo que ya existe en Supabase. No corras nada de lo exportado contra la base: ya está ahí.
> Los `create table` que escribas van con `if not exists`, y ningún `drop`.

### Paso 2 — si las funciones NO existen en Supabase

Entonces esas dos pestañas llevan tiempo rotas — lo cual es una buena noticia para el
riesgo: nadie depende de datos que nunca se generaron. Hay que decidir:
escribirlas desde cero (el front ya define el contrato: mira los parámetros en
`src/MonitorPreciosModule.jsx:37,58,62,97,115,130,146` y
`src/DescuentoCaducidadModule.jsx:41,123,142`) **o** quitar las pestañas de
`src/InventarioHub.jsx:26-27` hasta que existan. No dejarlas clicables y rotas.

### Paso 3 — `get_next_folio`

`src/utils/folioGenerator.js` **no tiene ningún llamador**. Bórralo, o conéctalo y crea la
función. Su fallback actual (`VTA-${Date.now()}`) rompe la promesa de folio secuencial del
propio encabezado del archivo.

### Criterio de aceptación

- [ ] `sql/migrations/002_*.sql` crea todo lo que las dos pestañas necesitan.
- [ ] El script de la auditoría no reporta RPCs faltantes (ver [Guardas](#guardas-para-que-no-vuelva-a-pasar)).
- [ ] `folioGenerator.js` borrado o conectado.

---

## T3 · Totales del Dashboard desde el bundle · ALTO · ~45 min

### Qué pasa

`p_limite: 500` trunca el mes (~917 tickets esperados) y ese conjunto recortado **le gana**
al `ped_mes` del bundle, que no tiene límite. Además rompe todas las comparativas
"vs periodo anterior", porque `pedVentasMes` solo cubre el mes en curso y se usa para
filtrar rangos del mes pasado — que siempre dan vacío.

### Cambio

> **En vivo:** `empleado_dashboard_operacion_bundle` es una función de **solo lectura**
> (puros `select`). Cambiarla no puede alterar datos. Aun así, saca el snapshot antes:
> es la misma regla para toda función que reemplaces.

**a) SQL** — `sql/rpc_p1_lecturas_admin.sql:376`. `ped_mes` no trae el nombre del empleado,
que es la única razón por la que existe el fetch de 500. Agrégalo:

```sql
'ped_mes', coalesce((
  select jsonb_agg(jsonb_build_object(
    'total', p.total,
    'atendido_por', p.atendido_por,
    'usuarios', jsonb_build_object('nombre', u.nombre)
  ))
  from public.pedidos p
  left join public.usuarios u on u.id = p.atendido_por
  where (p.estado)::text = 'completado' and p.created_at >= v_ms
), '[]'::jsonb),
```

`byEmp` (`src/DashboardModule.jsx:565`) ya lee `p.usuarios?.nombre || p.atendido_por`,
así que no hay que tocarlo.

**b) JS** — `src/DashboardModule.jsx`:

- Borrar el bloque `let pedVentasMes = []; if (adminTok) { … p_limite: 500 … }` (líneas 435-444).
- En las siete asignaciones de las líneas 466-482, quitar el ternario y dejar solo la rama
  del bundle. Ejemplo:

```js
// antes
let pedMes = pedVentasMes.length
  ? pedVentasMes
  : ventasRowsOrFallback(B, "ped_mes", H, "ventas_mes");

// después
const pedMes = ventasRowsOrFallback(B, "ped_mes", H, "ventas_mes");
```

- El fallback de `ventasPorDia` en la línea 459 (`agruparVentasPorDia(pedVentasMes)`) se cae
  con el borrado: quítalo, ya hay dos niveles de respaldo antes.
- Varias `let` pueden pasar a `const`.

### Verificación

- [ ] En un mes con >500 pedidos, "Ventas del mes" coincide con
      `select sum(total) from pedidos where estado='completado' and created_at >= '<1 del mes>'`.
- [ ] La tarjeta "Ventas del mes" **ya muestra** flecha de tendencia (antes decía
      "Sin comparativo" siempre).
- [ ] "Ventas por empleado" sigue mostrando nombres, no UUIDs.
- [ ] Una petición menos en la pestaña Red al cargar el Dashboard.

---

## T4 · Cortar el bucle de recarga tras deploy · ALTO · ~20 min

### Qué pasa

`src/index.js:68-95` corta el bucle de `ChunkLoadError` a los 4 intentos.
`src/App.js:120-123` borra el contador **en cada montaje**, así que nunca llega a 4.
Como `InventarioHub` restaura la pestaña activa desde `sessionStorage`, la app vuelve
determinísticamente al chunk roto. Bucle infinito.

### Cambio

En `src/App.js`, quitar el `removeItem` inmediato y limpiarlo solo cuando la app llevó
un rato estable:

```js
// antes
useEffect(() => {
  try {
    sessionStorage.removeItem("farmacapital_chunk_retries");
  } catch (_) { /* noop */ }
  try {

// después
useEffect(() => {
  // El contador se limpia solo si la app aguantó estable. Si lo borramos al
  // montar, el corta-circuitos de index.js nunca llega a 4 y un chunk roto
  // deja la PWA recargando para siempre.
  const t = setTimeout(() => {
    try {
      sessionStorage.removeItem("farmacapital_chunk_retries");
    } catch (_) { /* noop */ }
  }, 15000);
  try {
```

y devolver `() => clearTimeout(t)` en el cleanup del `useEffect`.

### Verificación

Reproducción manual: en DevTools → Network, bloquea `static/js/*.chunk.js`, abre una
pestaña de Inventario. Debe recargar como mucho 4 veces y luego mostrar el error, no
recargar sin fin.

---

## T5 · Un solo "hoy": `src/lib/fecha.js` · ALTO · ~1.5 h

### Qué pasa

Tres convenciones conviviendo. `toISOString().slice(0,10)` devuelve **mañana** después de
las 18:00 en CDMX, y la farmacia vende en turno vespertino.

### Paso 1 — crear `src/lib/fecha.js`

Mueve ahí las funciones que **ya están bien resueltas** en `src/lib/rhSemana.js:9-26`
(`hoyISOMexico`, `addDaysISO`, `dowISO`) y haz que `rhSemana.js` las importe de ahí.
No las reescribas: son la referencia correcta.

Agrega:

```js
export const TZ_FARMACIA = "America/Mexico_City";

/** Rango [inicio, fin) del día de farmacia, en ISO con offset, para filtrar timestamps. */
export function rangoDiaMexico(iso = hoyISOMexico()) { /* … */ }
```

`src/lib/ventasVsMeta.js` ya tiene `ymdMexico` y `TZ_FARMACIA` duplicados: hazlos re-export
de `fecha.js`.

### Paso 2 — sustituir

Migrar a `hoyISOMexico()`:

| Archivo:línea | Qué decide hoy mal |
|---|---|
| `src/PromocionesModule.jsx:196` | Vigencia de promos (vencen a las 6pm) |
| `src/hooks/useSidebarBadges.js:12, 23` | Badge de alertas COFEPRIS |
| `src/DashboardModule.jsx:364, 370, 551, 629` | Ventana y vencidos de COFEPRIS |
| `src/Tienda.jsx:2662, 4096` | Vigencia de promos en tienda |
| `src/db.js:162, 395, 430` | Ventas / bitácora / cortes del día (IndexedDB) |
| `src/Admin.jsx:2110` | — |
| `src/lib/ultimaCompra.js:121` | Fecha de compra registrada |
| `src/PreciosReferenciaModule.jsx:997` | — |
| `src/components/ImportReferenciaPrecios.jsx:21` | Default del date picker |
| `src/modules/sales/MiDia.jsx:270, 317` | — |
| `src/core/projections/salesProjection.js:13` | Agrupa ventas por día UTC |
| `src/core/readModels/buildSalesModel.js:14` | Idem |

Migrar también los `toLocaleDateString("sv-SE")` (dependen del reloj del equipo):
`POS.jsx:656, 1039, 1461`, `AgendaConsultasModule.jsx:18, 49, 92, 221, 233`,
`ConsultorioModule.jsx:23`, `LotesModule.jsx:63, 181, 214`,
`CorteCajaModule.jsx:136, 198, 312, 362`, `Admin.jsx:588`,
`DashboardModule.jsx:165, 361, 363`, `utils/citasAgenda.js:42`.

> **NO TOCAR `src/lib/rhSemana.js:21`.** Ese `toISOString().slice(0,10)` opera sobre un
> `Date.UTC(y, m-1, d+days)` — es aritmética de fecha pura y está **correcta**. Es el patrón
> a imitar, no un bug.

### Paso 3 — guarda de lint

En `package.json` → `eslintConfig`:

```json
"rules": {
  "no-restricted-syntax": ["error", {
    "selector": "CallExpression[callee.property.name='slice'][callee.object.callee.property.name='toISOString']",
    "message": "Usa hoyISOMexico() de src/lib/fecha.js. toISOString() da el día UTC y en CDMX adelanta el día desde las 18:00."
  }]
}
```

Excluye `src/lib/fecha.js` y `src/lib/rhSemana.js` con un `eslint-disable` puntual.

### Criterio de aceptación

- [ ] A las 19:00 hora CDMX, una promo que vence hoy sigue apareciendo vigente.
- [ ] `npm test` verde (hay tests en `src/utils/turnosMetas.test.js` y `src/lib/rhSemana.test.js`).
- [ ] El lint falla si alguien reintroduce el patrón.

---

## T6 · `try/finally` en los 24 handlers · MEDIO · ~40 min

### Qué pasa

`setSaving(true)` → `await` → sin `catch` ni `finally`. Un corte de red rechaza la promesa y
el botón queda deshabilitado hasta recargar. El peor caso deja a la cajera sin poder abrir caja.

### Patrón

```js
// antes
setSaving(true);
const { data, error } = await supabase.rpc("…", {…});
setSaving(false);
if (error) { showToast(…); return; }

// después
setSaving(true);
try {
  const { data, error } = await supabase.rpc("…", {…});
  if (error) { showToast(…); return; }
  // …
} catch (e) {
  showToast(e?.message || "Se cayó la conexión. Intenta de nuevo.", "error");
} finally {
  setSaving(false);
}
```

### Sitios

Empieza por `src/modules/sales/pos/AperturaCajaModal.jsx:67` — es el que deja a la cajera
sin vender.

```
src/modules/sales/pos/AperturaCajaModal.jsx:67   ← primero
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

> No cambies la lógica de negocio de ningún handler. Solo el envoltorio.

---

## T7 · `total_devuelto`: que las devoluciones bajen del reporting · ALTO · ~1 h

### Qué pasa

Una devolución repone stock y mueve crédito, pero **nunca toca `pedidos`**
(el único `update pedidos` de `patch_devoluciones_caja_credito_20260820.sql:703` es para
`monto_credito`). Todo el reporting suma `total` de pedidos `completado`, así que lo devuelto
cuenta como venta para siempre — e infla el `recuperado` del ROI.

### Cambio

> **En vivo — lo más delicado de esta tarea es lo que NO se hace.**
> El `alter table` con `default 0` no reescribe la tabla en Postgres 11+ (Supabase corre 17),
> así que es casi instantáneo. Toma un lock breve: hazlo fuera de horario igual.
> **Prohibido el backfill.** Las devoluciones históricas se quedan con `total_devuelto = 0`
> y los reportes viejos siguen mostrando lo mismo de siempre. Recalcular hacia atrás es un
> proyecto aparte, con respaldo y ventana propios. Si lo mezclas aquí, cambias números que
> alguien ya cerró contablemente.

1. Migración: `alter table pedidos add column if not exists total_devuelto numeric not null default 0;`
2. En `fn_ejecutar_efectos_devolucion`, sumar el monto devuelto a `pedidos.total_devuelto`
   del `v_dev.pedido_id`.
3. Cambiar los agregados de `rpc_p1_lecturas_admin.sql` (`ped_hoy`, `ped_ayer`, `ped_semana`,
   `ped_semana_ant`, `ped_mes`, `ped_mes_ant`, `ped_todos`) para emitir
   `p.total - coalesce(p.total_devuelto, 0)`.

> **No cambiar `pedidos.estado`.** `reconcile_cash_rango` reconstruye cortes históricos con
> `estado='completado'` y su ventana de tiempo; si el estado cambia, los cortes ya cerrados
> dejan de cuadrar.

### Criterio de aceptación

- [ ] Una devolución baja "Ventas del mes" en el Dashboard.
- [ ] El corte de caja de un turno **anterior** a la devolución no cambia ni un peso.

---

## T8 · Una sola definición de meta y de período · MEDIO · ~1 h

Hoy conviven dos metas del día (plana vs por día de semana), dos semanas
(7 días rodantes vs lunes–domingo) y dos criterios de prorrateo — la tarjeta prorratea,
la strip no. El día 3 del mes una dice 100% y la otra 10% en rojo.

**Cambio:** una función `metasDelPeriodo(fecha, cfg)` en `src/lib/` que devuelva
`{dia, semana, mes}` con **una** regla, consumida por `InsightCard` y por
`MetasPeriodoStrip`. Prorratear semana y mes en curso, o cambiar el texto a
"vas al X% del ritmo".

Limpieza que entra aquí: `metaSemana()` es inalcanzable (`mezclarCfgMetas` siempre inyecta
`meta_ventas_semana`), `metaConsultasMesProrrateada` (`:724`) no se usa,
`invalidarCacheMetas()` no se llama nunca, y `VentasVsMetaChart.jsx:165` usa `role="img"`
con botones dentro (los esconde de lectores de pantalla; usar `figure`).

Detalles en `AUDITORIA_MODULOS.md` B4, B5, E5.

---

## T9 · Un solo FEFO · MEDIO · requiere decisión de producto

Cuatro implementaciones de "saca N unidades de los lotes", dos sin filtro de caducidad.
`consume_stock_via_lotes` se contradice: valida contra stock no vencido y luego consume
vencidos primero.

> **En vivo: no entres a esta tarea contra producción.** Es el único cambio que puede
> corromper inventario de forma difícil de deshacer — un lote mal descontado no se arregla
> con un revert de código. Restaura el último `pg_dump` en un Postgres local o en un segundo
> proyecto Supabase, prueba ahí, y recién entonces planea el despliegue. Si no hay tiempo
> para eso, no hay tiempo para esta tarea.

**Antes de codificar hay que decidir:** ¿un ajuste de merma **debe** consumir lotes vencidos
primero (para darlos de baja) o no? La respuesta define la política.

Propuesta: una función `descontar_lotes(producto_id, cantidad, politica)` con
`politica in ('venta','merma','ajuste')` — `venta` excluye vencidos, `merma` los prioriza.
Reemplazar las cuatro. Y arreglar `restock_via_lote` para que use el lote de origen y no
reactive caducados (`AUDITORIA_MODULOS.md` D2).

---

## T10 · Conectar o borrar · BAJO · requiere decisión de producto

Nada de esto se queda a medias:

| Qué | Estado | Decisión |
|---|---|---|
| Promociones | El CRUD funciona, el POS nunca las aplica (`POS.jsx:1334` tiene un comentario que miente) | ¿Se implementan en el cobro o se quita el módulo? |
| Event-sourcing (`src/core`, `EventDashboard`, `ReplayDashboard`, `LedgerView`, `useSalesReport`) | Se inicializa en `index.js`, nada lo consume | ¿Se conecta o se borra? |
| `ConsDoctora.jsx`, `ProductosValidacionDashboard.jsx`, `modules/shared/navigation/Sidebar.jsx` | Nunca importados | Borrar |
| Vista de vendedor del Dashboard (`soloTransacciones`) | Inalcanzable: `permissions.js:88` bloquea `"trans"` | Borrar la rama o abrir el permiso |
| `consume_stock_secure` | Sin llamadores, con grant a `anon` | Revocar |
| `case "cons_cobro"` y `case "inventario"` en `Admin.renderPage` | Rutas que nadie navega | Borrar |

---

## Guardas para que no vuelva a pasar

Ya está escrito y probado en **`scripts/check-rpcs-existen.js`**. Hoy falla con los 11
conocidos; después de T2 debe pasar en verde. Cuélgalo del build en `package.json`:

```json
"prebuild": "node scripts/check-react-supabase-env.js && node scripts/check-rpcs-existen.js"
```

Súmalo al `prebuild` en el mismo commit que T2, para que el build no vuelva a pasar con
RPCs fantasma.

---

## Resumen de orden

| # | Tarea | Toca | Datos existentes | Cómo se revierte |
|---|---|---|---|---|
| T4 | Bucle de recarga | Front | No | `git revert` |
| T6 | `try/finally` | Front | No | `git revert` |
| T3 | Totales del Dashboard | Front + función de lectura | No | `git revert` + snapshot |
| T5 | `src/lib/fecha.js` | Front | No | `git revert` |
| T8 | Metas unificadas | Front | No | `git revert` |
| T1 | `descuento_pct` en el cobro | Función de **escritura** | No, pero cambia el cobro futuro | Snapshot |
| T2 | RPCs faltantes al repo | Solo archivos | No (es exportar) | — |
| T7 | `total_devuelto` | `alter table` + lecturas | No, **sin backfill** | Snapshot; la columna se puede dejar |
| T9 | FEFO único | Funciones de **stock** | **Alto** | Snapshot, pero un lote mal descontado no se revierte solo |
| T10 | Conectar o borrar | Depende | No | `git revert` |

Ordenadas así, los primeros cinco no tocan la base: se pueden desplegar hoy mismo y el
peor caso es un `git revert`. Los de SQL van después, de a uno, con snapshot y fuera de horario.

T7–T10 necesitan que alguien decida antes de escribir código. T9 además necesita una copia
restaurada de la base: no se toca contra producción.
