# Especificación: Reporte mensual (PDF) y Exportación de transacciones (Excel)
### FarmaCapital — módulo Transacciones
**Versión 1.0 — 20 de septiembre de 2026**

> Documento de implementación. Escrito para usarse como contexto en Cursor.
> Reemplaza el botón de descarga actual en la vista de Transacciones.
> Los valores marcados `[CONFIGURABLE]` se confirman con Iván antes de fijarlos en código.
> Los marcados `[VERIFICAR EN REPO]` requieren leer el esquema real antes de escribir la consulta.

---

## 0. Antes de escribir una sola línea

El botón actual exporta un formato que no se lee bien (casi seguro un CSV sin BOM, con acentos rotos y fechas como texto). **Se elimina**, no se parcha.

**Paso obligatorio 1 — mapeo de datos.** Antes de implementar, levantar una tabla de equivalencias leyendo el repo `ibarraivane/farmacapital` y el esquema de Supabase. Lo que ya se conoce por la auditoría de corte de caja:

| Concepto | Nombre conocido | Estado |
|---|---|---|
| Ticket / venta | `pedidos` | confirmado |
| Método de pago | `pedidos.metodo_pago` (`efectivo`, `tarjeta`, `spei`, `mercadopago`) | confirmado |
| Estado de venta | `pedidos.estado` (`completado`, …) | confirmado |
| Recargas, CFE y similares | `pagos_servicio` (tabla aparte) | confirmado |
| Turno del vendedor | `usuarios.turno` | confirmado |
| Frontera de turnos | Matutino 8:00–15:30, Vespertino 15:00–22:30 (`src/constants/turnos.js`) | confirmado |
| Sesión de caja / corte | `caja_sesion`, `registrar_corte_caja`, `reconcile_shift_cash` | confirmado |
| Partidas del ticket (renglones) | ? | `[VERIFICAR EN REPO]` |
| Costo del producto | ? | `[VERIFICAR EN REPO]` |
| Categoría / laboratorio / principio activo | ? | `[VERIFICAR EN REPO]` |
| Lotes y caducidad | tabla de lotes | `[VERIFICAR EN REPO]` |
| Cliente identificado en el ticket | ? | `[VERIFICAR EN REPO]` |
| Devoluciones y cancelaciones | ? | `[VERIFICAR EN REPO]` |

**Paso obligatorio 2 — decidir la fuente de verdad del stock.** El plan maestro (§2, punto 8) lo tiene abierto: hoy se usa el mayor valor entre `productos.stock` y la suma de lotes. Los bloques de inventario de este reporte **no se implementan hasta que eso esté resuelto**, porque un número de stock ambiguo produce un reporte que miente. Si al momento de construir sigue abierto, entregar el PDF sin la sección de inventario y dejarla para un segundo PR.

**Paso obligatorio 3 — zona horaria.** Supabase guarda en UTC. Todo agregado por hora, día, semana o mes se calcula en `America/Mexico_City`. Si esto se hace mal, "la mejor hora de venta" sale desplazada 6 horas y el reporte completo pierde valor. En SQL:

```sql
(p.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'America/Mexico_City')
```

El mes también se delimita en hora local, no con `date_trunc` sobre UTC.

---

## 1. Alcance

Dos botones en la barra superior de la vista de Transacciones:

| Botón | Salida | Contenido |
|---|---|---|
| **Reporte del mes (PDF)** | `farmacapital_reporte_2026-09.pdf` | Documento de lectura, ~9 páginas, con indicadores y gráficas. |
| **Exportar a Excel** | `farmacapital_transacciones_2026-09.xlsx` | Libro con 9 hojas, formateado para filtrar y hacer tablas dinámicas. |

Ambos toman el periodo del selector que ya exista en la vista. Si hoy no hay selector de mes, se agrega: mes y año, con el mes actual por defecto.

---

## 2. Permisos

**Los dos botones son exclusivos del rol `admin`.** No se ocultan con CSS: el endpoint o el RPC valida el rol y responde `403` a cualquier otro.

El reporte incluye costo, margen y utilidad porque es de uso exclusivo del dueño. Esto lo vuelve el documento más sensible del sistema. Por lo tanto:

- El RPC que devuelve los agregados con costo **no debe ser invocable** por `vendedor` ni por el cliente anónimo. Verificar las políticas de Supabase (esto cruza con el riesgo de seguridad del plan maestro §8).
- El PDF lleva en el pie de cada página: `Confidencial — uso interno. Contiene costos y márgenes.`
- La generación de cualquiera de los dos archivos se registra en la bitácora `auditoria` (`accion='exporta_reporte_mensual'`, con el periodo solicitado).

---

## 3. Definiciones base

Se fijan aquí para que ningún número se discuta después. Van también impresas en el anexo del PDF.

```
venta_bruta      = Σ pedidos.total  donde estado='completado' y fecha en el mes (hora local)
devoluciones     = Σ importe de devoluciones del mes
venta_neta       = venta_bruta − devoluciones        ← el número que encabeza el reporte
tickets          = COUNT(pedidos completados)
ticket_promedio  = venta_neta / tickets
piezas           = Σ cantidad de todas las partidas
piezas_x_ticket  = piezas / tickets
costo_vendido    = Σ (costo_unitario × cantidad) de las partidas
utilidad_bruta   = venta_neta − costo_vendido
margen_%         = utilidad_bruta / venta_neta
```

**Los pagos de servicio no son venta.** Recargas y CFE mueven mucho efectivo pero el ingreso real es la comisión. Se reportan en su propio bloque, con volumen y comisión separados, y **nunca** se suman a `venta_neta`. Mezclarlos infla la venta y destruye el margen aparente.

**Costo histórico, no costo de hoy.** El margen debe calcularse con el costo que tenía el producto **al momento de la venta**. Si la partida no guarda `costo_unitario`, el margen del reporte es aproximado y así debe decirlo la portada. `[VERIFICAR EN REPO]`

> **Recomendación fuerte:** si las partidas no guardan el costo, agregar la columna `costo_unitario` y llenarla en el momento de la venta. Es un cambio chico, y sin eso el margen histórico nunca va a ser confiable: cada vez que sube un precio de proveedor, se reescribe el pasado.

---

## 4. Contenido del PDF

Tamaño Carta, vertical. Debe leerse bien impreso en blanco y negro y en la pantalla del celular.

### Página 1 — Portada y resumen ejecutivo

Logo, mes en letra (`Septiembre 2026`), sucursal, fecha y hora de generación, leyenda de confidencialidad.

Seis cifras grandes, cada una con su variación contra el mes anterior en % y flecha:

| Indicador | Formato |
|---|---|
| Venta neta | `$ 000,000.00` |
| Utilidad bruta y margen % | `$ 00,000.00 (00.0%)` |
| Tickets | entero |
| Ticket promedio | moneda |
| Piezas por ticket | 1 decimal |
| Venta por hora abierta | moneda |

Debajo, **tres renglones de conclusión en texto plano**, generados de los datos, no escritos a mano. Ejemplo de la forma:

- `La venta subió 8.4% contra agosto. El crecimiento vino del ticket promedio, no de más clientes.`
- `12 productos se quedaron en cero teniendo venta. Venta perdida estimada: $14,200.`
- `$38,500 a costo caducan en los próximos 90 días.`

Esto es lo que hace que el reporte se lea en 30 segundos en vez de no leerse.

### Página 2 — Crecimiento

- **Venta por semana** del mes (barras) con el % de incremento de cada semana contra la anterior. Semana = lunes a domingo; la primera y la última pueden ser parciales y deben marcarse como tales.
- **Comparativo de 6 meses** (línea): venta neta y ticket promedio.
- **Descomposición del crecimiento.** Este bloque vale más que el resto de la página:

```
Δventa = (tickets_mes − tickets_previo) × ticket_prom_previo
       + (ticket_prom_mes − ticket_prom_previo) × tickets_mes
```

Separa dos cosas que se confunden siempre: si creciste porque entró más gente, o porque cada quien se llevó más. La acción que sigue es distinta en cada caso.

- Si hay dato del mismo mes del año anterior, comparativo interanual. Si no, omitir el bloque sin dejar hueco.

### Página 3 — Cuándo se vende

- **Mapa de calor hora × día de la semana**, de 8:00 a 22:00. Dos versiones en la misma página: por importe y por número de tickets. No son iguales, y la diferencia dice dónde está el ticket grande contra dónde está el tráfico.
- **Mejor y peor día del mes**, con su monto y qué tuvo de particular (día de quincena, fin de semana, festivo).
- **Venta por día de la semana** (promedio del mes).
- **Efecto quincena:** venta de los días 1, 2, 15 y 16 contra el promedio del resto. En una farmacia de barrio esto suele ser el patrón más marcado.
- **Horas muertas:** franjas con menos de `[CONFIGURABLE] 3` tickets por hora en promedio. Es el insumo directo para decidir horarios de personal.

### Página 4 — Qué se vende

- **Top 20 por importe** y **Top 20 por piezas**, en dos columnas lado a lado. Casi nunca coinciden.
- **Top 20 por utilidad** (margen $ × piezas). Este es el que casi nadie mira y el que realmente dice qué te da de comer. Un producto puede ser #1 en venta y #30 en utilidad.
- **Pareto ABC:** qué porcentaje del catálogo genera el 80% de la venta (clase A), el 80–95% (B) y el resto (C). Con el número de SKUs en cada clase. Los A son los que nunca deben faltar.
- **Venta y margen por categoría** (medicamento, dermocosmética, nutrición, vitaminas, servicio).
- **Concentración:** qué % de la venta hacen los 10 productos principales. Si es muy alto, cualquier desabasto duele; si es muy bajo, el inventario está disperso.

### Página 5 — Inventario y dinero parado

- **Agotados con demanda.** Productos con stock 0 hoy que tuvieron venta en los últimos 30 días. Para cada uno: velocidad (piezas/día), días estimados sin stock, venta perdida estimada.

```
velocidad        = piezas_vendidas_30d / días_con_stock_en_esos_30d
venta_perdida    = velocidad × días_sin_stock × precio_venta
```

> **Limitación honesta:** sin historial de existencias, `días_sin_stock` no se puede saber. La versión 1 usa un proxy: productos en cero hoy que vendieron en los últimos 30 días, con la venta perdida calculada sobre los días transcurridos desde la última venta. Está marcado como estimación en el PDF.
>
> **Recomendación:** crear una tabla `stock_diario` (producto_id, fecha, existencia) llenada por un job nocturno. Es una tabla chica y convierte este indicador de estimación en dato duro. También habilita días de cobertura real y rotación por producto.

- **Caducidades.** Lotes que vencen en 30, 60 y 90 días: piezas, valor a costo, y una columna de semáforo: `¿alcanza a venderse?` comparando piezas del lote contra velocidad × días restantes. Lo que no alcanza es lo que hay que rematar o devolver **ahora**, no cuando ya venció.
- **Inventario sin rotación.** Productos sin una sola venta en `[CONFIGURABLE] 60` días, con piezas y valor a costo. Total del dinero parado.
- **Días de cobertura de los productos A:** `stock_actual / velocidad`. Cuáles se acaban antes del próximo pedido.

### Página 6 — Dinero y caja

- **Mezcla de pago:** efectivo, tarjeta, SPEI, MercadoPago. Monto, % y número de tickets. Para tarjeta y MercadoPago, estimar la comisión con una tasa `[CONFIGURABLE]` y mostrar el ingreso neto. La mezcla de pago cambia la utilidad real y normalmente nadie la ve.
- **Pagos de servicio, aparte:** volumen operado, número de operaciones, comisión ganada. Con la leyenda de que no forma parte de la venta.
- **Descuentos aplicados:** total, % sobre venta bruta, y desglose por vendedor. `[VERIFICAR EN REPO]` si existe el campo.
- **Devoluciones y cancelaciones:** monto, número, y los 5 productos con más devoluciones. Un producto que se devuelve seguido es una señal, no ruido.
- **Diferencias de caja del mes:** suma de faltantes, suma de sobrantes, diferencia neta, número de cortes fuera de tolerancia. Faltantes y sobrantes **separados**, nunca netos: $500 de faltante y $500 de sobrante no son cero, son dos problemas.

> Si el hallazgo P0 de `pagos_servicio` en `reconcile_shift_cash` sigue sin corregirse, los sobrantes de este bloque son en buena parte fantasma. El PDF debe imprimir esa advertencia mientras el fix no esté en producción.

### Página 7 — Personal

Ordenado por **venta por hora**, nunca por venta total. La venta total depende del tráfico y de las horas trabajadas, y ninguna de las dos las controla el vendedor. Esta regla ya está establecida en el módulo de RH y aquí se respeta igual.

Por vendedor: horas trabajadas, turnos, venta neta, venta por hora, tickets, ticket promedio, piezas por ticket, puntualidad, diferencias de caja acumuladas (faltante y sobrante por separado).

- Horas salen de `caja_sesion`: `Σ (cerrada_at − abierta_at)`. Turnos en estado forzado se excluyen del cálculo y se listan aparte para que Iván los resuelva.
- Puntualidad: `abierta_at` contra el inicio del turno asignado (8:00 matutino, 15:00 vespertino) más `[CONFIGURABLE] 10` minutos de tolerancia.
- **Las horas trabajadas van siempre al lado de cualquier cifra de venta.** Sin excepción.
- Las diferencias de caja se reportan como dato de cuidado y precisión. No se convierten en puntaje ni en ranking competitivo.

### Página 8 — Cronología del mes

Tabla por día: venta neta, tickets, ticket promedio, piezas, margen %, turno con más venta. Ordenada por fecha. Sirve para ubicar un día raro y luego buscarlo en el Excel.

### Página 9 — Anexo de definiciones

Cada indicador del reporte con su fórmula exacta, y las notas de qué queda excluido (pedidos no completados, pagos de servicio, turnos forzados). Media página. Evita tres discusiones al mes sobre por qué un número no cuadra.

---

## 5. Diseño del PDF

Se apega al sistema visual del plan maestro:

- Tinta `#001534` para texto y encabezados. Azul `#054ABC` para elementos de datos y ejes. Jade `#02A158` **solo** para variaciones positivas y estados favorables. Rojo únicamente para faltantes, caídas y caducidades. Nada decorativo.
- Tipografía Inter con **cifras tabulares** en toda tabla numérica, para que las columnas alineen.
- Sin degradados, sin sombras, sin emojis, sin iconografía de adorno.
- Todas las cantidades monetarias en MXN con separador de miles y dos decimales. Porcentajes con un decimal.
- Todas las tablas con su total al pie.
- Encabezado corrido en cada página: `FarmaCapital · Septiembre 2026 · pág. n/9`.

---

## 6. Contenido del Excel

Libro de 9 hojas. Formato uniforme en todas.

### Hoja 1 — Portada
Periodo, fecha y hora de generación, quién lo generó, filtros aplicados, y una tabla de **cifras de control**: venta neta, tickets, piezas, utilidad. Sirve para verificar contra el PDF de un vistazo.

### Hoja 2 — Transacciones (un renglón por ticket)

`folio` · `fecha` · `hora` · `día_semana` · `turno` · `vendedor` · `canal` (mostrador / en línea) · `método_pago` · `subtotal` · `descuento` · `total` · `piezas` · `partidas` · `cliente` · `estado` · `caja_sesion_id`

### Hoja 3 — Detalle (un renglón por producto vendido)

`folio` · `fecha` · `hora` · `turno` · `vendedor` · `producto_id` · `código_barras` · `descripción` · `categoría` · `laboratorio` · `cantidad` · `precio_unitario` · `descuento` · `importe` · `costo_unitario` · `costo_total` · `utilidad` · `margen_%` · `lote` · `caducidad` · `método_pago`

Esta es la hoja para tablas dinámicas. Debe ser plana: sin subtotales intercalados, sin renglones en blanco, sin celdas combinadas.

### Hoja 4 — Resumen diario
`fecha` · `día_semana` · `venta_neta` · `tickets` · `ticket_promedio` · `piezas` · `costo` · `utilidad` · `margen_%` · `efectivo` · `tarjeta` · `spei` · `mercadopago`

### Hoja 5 — Resumen por producto
`producto_id` · `código_barras` · `descripción` · `categoría` · `piezas` · `importe` · `costo` · `utilidad` · `margen_%` · `% de la venta` · `clase_ABC` · `stock_actual` · `días_cobertura` · `última_venta`

### Hoja 6 — Resumen por hora
Matriz hora (8–22) × día de la semana, con importe. Una segunda tabla igual con número de tickets. Es la fuente del mapa de calor del PDF.

### Hoja 7 — Pagos de servicio
`fecha` · `hora` · `tipo` (recarga, CFE, otro) · `referencia` · `monto` · `comisión` · `método_pago` · `vendedor`

### Hoja 8 — Cortes de caja
`fecha` · `turno` · `vendedor` · `apertura` · `cierre` · `horas` · `fondo_inicial` · `efectivo_declarado` · `efectivo_sistema` · `esperado` · `diferencia` · `tarjeta` · `spei` · `mercadopago` · `total_general` · `estado`

### Hoja 9 — Devoluciones y cancelaciones
`fecha` · `folio_original` · `producto` · `cantidad` · `importe` · `motivo` · `autorizó` · `vendedor`

### Reglas de formato (todas las hojas)

- **Fechas como fecha real y horas como hora real**, nunca texto. `dd/mm/yyyy` y `hh:mm`.
- Moneda: `"$"#,##0.00`. Porcentajes: `0.0%` sobre el valor decimal, no sobre el número ya multiplicado.
- Encabezado en tinta `#001534`, texto blanco, negritas, **fila congelada**.
- **Autofiltro** en el encabezado de cada hoja de datos.
- Cada hoja de datos definida como **tabla con nombre** (`tblTransacciones`, `tblDetalle`, …) para que las dinámicas se actualicen solas.
- Ancho de columna ajustado al contenido. Nada de `####`.
- Sin celdas combinadas en hojas de datos. Solo en la portada.
- Números como números. Ni un solo valor numérico guardado como texto.
- Franja de color alterna suave para lectura. Sin bordes gruesos ni relleno decorativo.
- Nombres de hoja en español, sin acentos ni caracteres especiales, máximo 31 caracteres.
- Formato condicional: rojo en `diferencia` negativa, en `margen_%` bajo `[CONFIGURABLE] 15%`, y en caducidades a menos de 30 días.

> El archivo debe abrir sin advertencias en Excel de escritorio, Excel móvil y Google Sheets. Probar en los tres antes de dar por terminado.

**Nota:** este Excel es una herramienta de gestión, no un documento contable ni fiscal. No sustituye la contabilidad ni los CFDI. Conviene que lo diga la portada.

---

## 7. Implementación

### Dónde se calcula

Todo agregado se calcula en **SQL, del lado del servidor**, no en el navegador. Dos RPCs nuevos:

```
rpc_reporte_mensual(p_anio int, p_mes int)
  → JSON con todos los bloques agregados del PDF.
    Payload chico (decenas de KB). Valida rol admin.

rpc_transacciones_mes(p_anio int, p_mes int, p_hoja text, p_offset int, p_limit int)
  → Filas planas para cada hoja del Excel, paginadas.
    Valida rol admin.
```

Razones: el mes tiene del orden de miles de tickets y decenas de miles de partidas. Traerlos crudos al navegador para agregarlos es lento y frágil. Además, un RPC con `SECURITY DEFINER` y validación de rol es un solo punto donde proteger el costo, en vez de repartir esa responsabilidad en el cliente.

### Con qué se genera

- **Excel: ExcelJS.** SheetJS en su versión libre no da el formato que se pide aquí (tablas con nombre, formato condicional, estilos de encabezado).
- **PDF: pdfmake**, o React-PDF si el equipo ya lo usa en otra parte. `[VERIFICAR EN REPO]`
- Gráficas del PDF: dibujadas como vectores dentro del documento, no como imágenes de un canvas. Una imagen rasterizada se ve mal impresa y pesa de más.

### Carga diferida, obligatoria

ExcelJS y pdfmake son pesados. Se cargan con `import()` dinámico **solo al presionar el botón**, nunca en el bundle inicial. Esto no es opcional: el plan maestro (§2, punto 9) tiene como criterio no empeorar el tamaño del paquete, y estas dos librerías juntas lo empeorarían de forma notable.

### Experiencia durante la generación

- Estado de carga con progreso por etapas (`Consultando ventas… Calculando indicadores… Armando el archivo…`). Un mes completo puede tardar varios segundos.
- Si falla, mensaje concreto de qué falló y un botón de reintento. Nunca un archivo a medias.
- El nombre del archivo incluye el periodo, no la fecha de descarga.

### Casos borde que deben manejarse sin romper

| Caso | Comportamiento |
|---|---|
| Mes sin ventas | Genera el PDF con ceros y la leyenda "sin movimientos", no truena ni descarga vacío. |
| Mes en curso | Se permite. La portada dice `Parcial: del 1 al 20 de septiembre` y las comparativas se hacen contra el mismo tramo del mes anterior, no contra el mes completo. |
| Mes con 4 o 6 semanas | La tabla semanal se adapta. Semanas parciales marcadas. |
| Producto eliminado del catálogo | Aparece con su descripción histórica, no como renglón en blanco. |
| Partida sin costo | El margen se omite en ese renglón y la portada declara qué % de la venta quedó sin costo. |
| Turno forzado o sin cerrar | Excluido de horas, listado aparte. |
| Cambio de horario de verano | No aplica en México desde 2022, pero la conversión debe usar la zona IANA, no un offset fijo de −6. |

---

## 8. Criterios de aceptación

1. Un usuario con rol distinto de `admin` que llame `rpc_reporte_mensual` o `rpc_transacciones_mes` recibe `403`. Verificar contra la API directa, no contra la interfaz.
2. La respuesta de cualquier endpoint accesible a `vendedor` no contiene costo, margen ni utilidad en ningún campo. Verificar sobre el JSON crudo.
3. La venta neta del PDF, la de la portada del Excel y la suma de la hoja Transacciones son idénticas al centavo.
4. La suma de efectivo del reporte cuadra con la suma de `efectivo_sistema` de los cortes del mes. Si no cuadra, hay un bug o está vivo el hallazgo P0 de `pagos_servicio`; el reporte debe señalar cuál de los dos.
5. Una venta registrada a las 23:30 hora local del último día del mes aparece en ese mes y no en el siguiente.
6. El mapa de calor coloca la venta en la hora local correcta. Probar con un ticket de hora conocida.
7. Los pagos de servicio no están incluidos en `venta_neta` en ninguna vista del reporte.
8. Los pedidos con estado distinto de `completado` no suman a la venta.
9. El Excel abre en Excel de escritorio, Excel móvil y Google Sheets sin advertencias de formato.
10. Los acentos y la eñe se ven correctamente en las tres aplicaciones.
11. Las fechas del Excel se pueden ordenar cronológicamente y filtrar por rango. Es decir: son fechas, no texto.
12. Una tabla dinámica sobre la hoja Detalle agrupa por categoría sin limpieza previa.
13. Un mes sin ventas genera ambos archivos sin error.
14. El bundle de la tienda no crece: ExcelJS y pdfmake no aparecen en el chunk inicial. Verificar con el analizador de bundle.
15. El PDF es legible impreso en blanco y negro: ninguna información depende solo del color.
16. Generar cualquiera de los dos archivos deja exactamente un registro en `auditoria`.
17. El ranking de personal no acepta venta total como criterio de ordenamiento, y toda cifra de venta por persona tiene sus horas trabajadas al lado.

---

## 9. Parámetros configurables

| Parámetro | Sugerido | Notas |
|---|---|---|
| `DIAS_SIN_ROTACION` | `60` | Umbral para considerar inventario parado. |
| `VENTANA_VELOCIDAD_DIAS` | `30` | Para calcular piezas por día de cada producto. |
| `UMBRAL_HORA_MUERTA` | `3 tickets/hora` | Debajo de esto, la franja se marca como hora muerta. |
| `TOLERANCIA_PUNTUALIDAD` | `10 min` | Contra el inicio del turno asignado. |
| `MARGEN_MINIMO_ALERTA` | `15%` | Debajo de esto el renglón se marca en rojo. |
| `COMISION_TARJETA` | `[CONFIGURABLE]` | Tasa real del terminal. Sin esto, el ingreso neto es adivinanza. |
| `COMISION_MERCADOPAGO` | `[CONFIGURABLE]` | Igual. |
| `DIAS_CADUCIDAD_ALERTA` | `30 / 60 / 90` | Tres cortes en el bloque de caducidades. |

---

## 10. Orden sugerido de implementación

**PR 1 — Excel.** Es el que resuelve el dolor inmediato de no poder leer el archivo. Independiente de todo lo demás. Hojas 1 a 4 y 8.

**PR 2 — PDF, núcleo.** Páginas 1, 2, 3, 4, 6, 8 y 9. Es el 80% del valor y no depende de resolver el stock.

**PR 3 — Inventario.** Página 5 y hojas 5 y 9 del Excel. Solo cuando esté decidida la fuente de verdad del stock.

**PR 4 — `stock_diario`.** El job nocturno de existencias, que convierte la venta perdida de estimación en dato.

Dividirlo así evita un PR gigante y permite que Iván ya esté usando el Excel mientras se resuelve lo del inventario.

---

## 11. Puntos abiertos

- **Costo en las partidas.** Si no existe `costo_unitario` histórico, decidir si se agrega ahora o si el margen se declara aproximado. Recomendación: agregarlo ahora; el costo no deja de moverse y cada mes que pasa es un mes de historia que no se va a poder reconstruir.
- **Fuente de verdad del stock.** Bloquea la página 5 completa. Es la misma decisión abierta del plan maestro.
- **Hallazgo P0 de `pagos_servicio`.** Mientras no se corrija en `reconcile_shift_cash`, las diferencias de caja del reporte arrastran sobrantes fantasma y el bloque debe llevar advertencia.
- **Tasas reales de comisión** de terminal y MercadoPago. Sin el dato, el ingreso neto por método de pago no se puede calcular.
- **Cliente identificado en el ticket.** Si no existe, el indicador de recompra no es posible. Vale la pena evaluarlo por separado: es la base de cualquier análisis de clientes recurrentes más adelante.
- **Envío por correo.** Si conviene que el PDF llegue solo el día 1 de cada mes, es un job programado sobre el mismo RPC. No entra en esta versión.
