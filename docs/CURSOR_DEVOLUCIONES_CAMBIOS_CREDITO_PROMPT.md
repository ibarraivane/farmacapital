# Propuesta: lógica de devoluciones, cambios y crédito en tienda — FarmaCapital

Fecha: 20 agosto 2026. Este documento es un prompt/spec listo para pasarle a Cursor. Está basado en revisar tu código actual: `src/DevolucionesModule.jsx`, la función `crear_devolucion` en `sql/refactor_fase6b_rpcs_transacciones.sql`, `sql/patch_devoluciones_busqueda_telefono_20260819.sql`, `src/CorteCajaModule.jsx`, `src/TransaccionesTab.jsx`, `src/FacturacionModule.jsx`, `src/utils/barcodeProductLookup.js` y el flujo de cobro con terminal en `api/payments/mp/point.js`.

## 1. Qué ya tienes hoy (y el hueco real)

Ya tienes un módulo de devoluciones funcional a nivel de inventario: el cajero busca el pedido por folio o teléfono (`empleado_buscar_pedidos_devolucion`), selecciona los productos y cantidades a devolver, indica motivo y "método de reembolso" (hoy las opciones son efectivo / tarjeta / puntos / crédito), y al guardar, la función `crear_devolucion`:

- Inserta el registro en `devoluciones` y sus líneas en `devolucion_items`.
- Repone el inventario automáticamente vía `restock_via_lote`.
- Deja rastro en `audit_log`.
- **Siempre inserta `estado = 'aprobada'` de inmediato** — aunque la interfaz tiene filtros para "pendiente" y "rechazada", el RPC nunca produce esos estados hoy; no hay aprobación real.

Lo que falta, y es exactamente lo que preguntas, es la parte de dinero y caja:

- `crear_devolucion` no toca caja para nada. Si el cajero entrega efectivo en una devolución, ese dinero sale del cajón pero el sistema no se entera.
- `CorteCajaModule.jsx` calcula el efectivo esperado del turno sin considerar devoluciones en absoluto (lo confirmé buscando "devolucion" en ese archivo y en `TransaccionesTab.jsx` — no aparece ni una vez).
- No existe ningún concepto de "cambio de producto" (devolver uno, llevarse otro).
- No existe crédito en tienda: `metodo_reembolso = "credito"` es una opción en el `<select>`, pero no pasa nada en el backend cuando se elige — no se guarda saldo en ningún lado.
- No hay reembolso real a tarjeta: revisé `src/utils/mercadoPago.js`, `src/components/MercadoPagoModal.jsx` y `api/payments/mp/` completo, y no hay ningún endpoint de refund/reversal contra la API de MercadoPago.
- La búsqueda para iniciar una devolución hoy es solo por folio o teléfono — no hay forma de arrancar escaneando el producto físico.

Con eso claro, aquí está la lógica que propongo, ya incorporando tus respuestas: **el cliente siempre puede elegir entre efectivo, crédito o cambio de producto** (nunca se le obliga a aceptar solo crédito), aprobación de supervisor solo arriba de un monto, y una política de devolución flexible cuando el cliente sigue enfrente tuyo.

## 2. Punto de entrada: escanear el producto en vez de buscar el folio

Me gusta la idea de escanear el producto que se devuelve y que el sistema pregunte después qué hacer — es más rápido en el mostrador y ya tienes toda la infraestructura de escaneo hecha y probada en `src/utils/barcodeProductLookup.js` (tolera EAN-12/13, ráfagas de pistola lectora, etc.), la misma que usa `Tienda.jsx` para armar el carrito. No hay que construir nada nuevo para "leer" el código de barras.

Ojo con un punto importante: un código de barras identifica el **producto**, no la **venta**. Si el flujo se basa solo en escanear, pierdes tres cosas que hoy sí tienes al buscar por folio/teléfono: (1) el precio real que pagó ese cliente (puede haber cambiado o haber tenido descuento), (2) el lote exacto del que salió, que necesitas para reponerlo correctamente y para tu bitácora de caducidades, y (3) la certeza de que ese producto en verdad se compró en tu farmacia y no en otro lado — sin eso, cualquiera podría "devolver" algo que nunca compró contigo.

Por eso la propuesta es usar el escaneo como acelerador que sigue amarrado a una venta real, no como reemplazo de esa validación:

1. El cajero escanea el producto. El sistema lo identifica al instante (como ya hace en `Tienda.jsx`).
2. En vez de pedir folio o teléfono, el sistema busca automáticamente si ese producto aparece en alguna venta reciente (por ejemplo, últimos 7–15 días, alineado con la ventana de devolución de la sección 3) — puede cruzar por teléfono del cliente si lo tienes a la mano, o simplemente por producto si el cliente compra de forma anónima.
3. Si encuentra **una sola venta que calza claramente**, la propone de una vez: "Encontramos que compraste esto el 18 de agosto en el ticket VTA-000123 — ¿es correcto?" — y de ahí ya tienes folio, precio pagado y lote, exactamente como si hubieras buscado por folio a mano.
4. Si encuentra **varias ventas posibles** (el mismo producto se vendió varias veces esa semana) o **ninguna**, ahí sí le pide al cajero el folio o el teléfono — no porque el escaneo haya fallado, sino porque no hay forma segura de saber a cuál venta pertenece sin ese dato. Esto también es tu red de seguridad contra devoluciones de productos que no se compraron ahí.
5. Una vez identificada la venta, exactamente como imaginas: el sistema pregunta "¿Qué quieres hacer?" con las opciones de la sección 5 — cambio por otro producto, efectivo, o crédito.
6. Si el cliente devuelve varios productos, cada escaneo adicional agrega esa línea (reusando la misma lógica de "ráfaga de escaneo" que ya tienes para no duplicar por accidente cuando la pistola manda el código muy rápido).
7. Para un cambio de producto, el mismo componente de escaneo sirve para capturar el producto **nuevo** que el cliente se lleva — escaneas lo que devuelve, luego escaneas lo que se lleva, y el sistema calcula la diferencia en vivo.

Esto se puede construir como parte de la Fase 1 (ver sección 8) porque es en buena parte reutilizar `barcodeProductLookup.js` y agregar un RPC chico, `empleado_buscar_venta_reciente_por_producto(p_session_token, p_producto_id, p_dias default 15)`, que devuelve las ventas candidatas para que el modal decida si hay una sola coincidencia o si necesita desambiguar. La búsqueda por folio/teléfono no desaparece — sigue siendo necesaria para el caso ambiguo y para cuando el cliente no trae el producto en la mano (por ejemplo, reclamos por teléfono).

## 3. Política de devolución propuesta

La regla más importante primero, porque resuelve tu preocupación de "el cliente sigue enfrente de mí": **si el cliente no se ha ido, con el ticket en la mano y el producto sin abrir, el cajero siempre puede procesarla en el momento**, sin excepciones ni aprobaciones extra (salvo que el monto supere el umbral de supervisor que ves en la sección 4). Esa es la vía rápida y es la que más se va a usar en la práctica — y con el escaneo de la sección 2, además, la más rápida de teclear.

Para el resto de los casos (el cliente vuelve otro día), propongo estas reglas, pensadas para una farmacia en México:

**Siempre se acepta, sin importar antigüedad ni categoría del producto**, cuando el motivo es error o responsabilidad de la farmacia: medicamento equivocado, producto caducado o dañado al momento de la venta, o cobro duplicado. Este tipo de devolución no debería tener fricción — es un error tuyo, no del cliente, y es también lo que espera la ley de protección al consumidor.

**Se acepta con ventana de tiempo** (propongo 7 días naturales, ajustable) cuando el motivo es que el cliente ya no lo necesita o se equivocó al comprar, y el producto sigue sellado/cerrado, sin refrigeración y no es un medicamento controlado.

**No se acepta**, salvo error de farmacia, para: medicamentos controlados (los que ya marca tu módulo COFEPRIS / bitácora de controlados), productos que requieren cadena de frío una vez que salieron del refrigerador, cualquier producto ya abierto o con el sello roto, y artículos de higiene íntima. Esto es estándar en farmacia — no es solo por política interna, hay temas sanitarios reales (no puedes revender un medicamento controlado o refrigerado que ya salió de tu control).

**Fuera de la ventana de 7 días o categoría dudosa**: se puede procesar, pero cae en aprobación de supervisor (ver sección 4), no se rechaza de plano — así el cajero nunca tiene que decirle que no a un cliente enfrente suyo, simplemente la deja pendiente de autorizar.

## 4. Aprobación por monto

Propongo un umbral configurable (arranca en, digamos, $500–$800 MXN — tú defines el número real) para no frenar el mostrador en el 90% de los casos, que son tickets bajos:

- Devolución con total devuelto **igual o menor al umbral** → se aprueba y se ejecuta en el momento (repone inventario, otorga efectivo/crédito, como hoy pero completo).
- Devolución **arriba del umbral**, o fuera de la ventana de 7 días, o de una categoría dudosa → se guarda como `estado = 'pendiente'`, no repone inventario ni entrega nada todavía, y aparece en un panel para que un admin la apruebe o rechace desde `DevolucionesModule.jsx` (ahí es donde por fin se usan los filtros que ya tiene la interfaz).

Esto requiere dos RPCs nuevos, `aprobar_devolucion` y `rechazar_devolucion`, protegidos con `fn_require_admin` (el mismo patrón que ya usas en `registrar_nomina`), que ejecutan el restock + efectivo/crédito solo al momento de aprobar.

## 5. La pregunta central: ¿cómo se resuelve el dinero?

Aquí está la lógica, ya con tu decisión de ofrecer las tres opciones sin forzar ninguna.

### 5.1 Venta pagada en efectivo, devolución en efectivo

El caso simple: sale el mismo efectivo que entró. Se registra el monto en la devolución y ese monto se resta automáticamente del efectivo esperado en el corte de caja del turno (ver sección 6). No hay ninguna complicación aquí.

### 5.2 Venta pagada con terminal (MercadoPago Point), reembolso en efectivo

Esto es lo que preguntabas específicamente. La realidad es que **no hay ninguna incompatibilidad contable en dar efectivo aunque haya cobrado por terminal** — el dinero de esa venta con tarjeta ya entró al banco (MercadoPago liquida en 1–2 días hábiles), así que darle efectivo al cliente hoy es simplemente un gasto/salida de caja normal del día, exactamente igual que si compraras insumos de limpieza en efectivo. Lo único que rompe el cuadre de caja es que **hoy el sistema no resta ese efectivo entregado del efectivo esperado**, así que el cajero declara menos efectivo del que "debería" haber y parece un faltante que no existe.

La solución no es evitar dar efectivo — es que el corte de caja lo contemple. Con eso resuelto, puedes dar efectivo con toda tranquilidad sin importar cómo se pagó la venta original; simplemente ese día tu caja va a tener menos efectivo físico porque salió una devolución, y el sistema lo va a saber y restarlo, no va a aparecer como diferencia/error.

No construyo (por ahora, ver sección 9) un reembolso automático a la tarjeta vía API de MercadoPago porque tú mismo decidiste que el crédito en tienda es la opción que quieres empujar primero, y agregar esa integración es trabajo considerable para un caso que vas a usar poco si el crédito funciona bien.

### 5.3 Crédito en tienda — cómo se lleva el registro sin complicarse

Tu preocupación era razonable: si el crédito fuera obligatorio, a alguien con un ticket bajo que necesita el efectivo ahora le estarías reteniendo su dinero. Por eso la regla es que el cajero siempre ofrece las tres opciones y el cliente elige — el crédito es la opción que **conviene más al negocio** (no sale efectivo del cajón), así que tiene sentido incentivarla un poco sin forzarla: por ejemplo, ofrecer un bono pequeño (5–10%) solo cuando el cliente elige crédito en vez de efectivo. Es opcional, tú decides si lo activas.

Sobre "cómo llevar el registro" — es más simple de lo que parece, y de hecho ya tienes el patrón exacto en tu propio sistema: así es como ya manejas los **puntos** (`clientes.puntos`, una columna que suma con cada venta). El crédito funciona igual, solo que en pesos en vez de puntos, y se puede usar como pago completo o parcial en la siguiente compra en vez de ser un descuento:

- Se agrega una columna `clientes.saldo_credito numeric not null default 0`.
- Se agrega una tabla pequeña `clientes_credito_movimientos` (cliente_id, devolucion_id, tipo `'otorgado' | 'canjeado' | 'ajuste'`, monto, saldo_resultante, motivo, creado_por, created_at) — esto te da el historial completo de cada movimiento, algo que `puntos` no tiene hoy y que para dinero real sí conviene tener por auditoría.
- El saldo queda amarrado al **cliente identificado por teléfono**, no a un vale de papel — es el mismo dato que ya usas para buscar sus pedidos en `NuevaDevolucionModal`. El cliente no necesita guardar nada físico; en su próxima visita, buscas su teléfono y el sistema le muestra cuánto tiene disponible.
- Para clientes sin registro (compra anónima): si eligen crédito, hay que capturar al menos el teléfono en ese momento para crearles un registro ligero en `clientes` — si no quieren dar el teléfono, no se puede ofrecer crédito y la opción por default pasa a ser efectivo.
- En el checkout (`Tienda.jsx` o el POS), se agrega "Crédito FarmaCapital" como forma de pago: si el cliente tiene saldo, se puede aplicar hasta el total de la compra (parcial o completo) y el resto se cobra por otro método. Esto necesita un RPC `canjear_credito_cliente` que reste el saldo — y es importante que este descuento de saldo y la creación de la venta ocurran en la **misma transacción de base de datos**, para que nunca se dé el caso de que se reste el crédito sin completarse la venta (o viceversa).
- ¿Expira el crédito? Te lo dejo como decisión de negocio — técnicamente es trivial agregar una fecha de expiración (6 o 12 meses, por ejemplo) para no cargar un pasivo indefinido, pero no es necesario para la primera versión.

### 5.4 Cambio por otro producto (con diferencia de precio)

Este es el flujo que faltaba por completo. La lógica:

1. Se seleccionan los productos que el cliente devuelve (igual que hoy, o escaneados como en la sección 2) **y** los productos nuevos que se lleva, en la misma pantalla — como un mini-carrito de "lo que entra" y "lo que sale".
2. El sistema calcula `total_nuevo - total_devuelto = diferencia`.
3. Si `diferencia = 0`: es un cambio puro, no se cobra ni se devuelve nada. Solo se mueve inventario: entra lo devuelto (`restock_via_lote`), sale lo nuevo (descuenta stock, con el mismo bloqueo de fila `for update` que ya usa `create_sale_transaction` para evitar condiciones de carrera).
4. Si `diferencia > 0` (el producto nuevo cuesta más): se cobra la diferencia como una venta chica — efectivo, terminal, o crédito si el cliente tiene saldo. Es literalmente el mismo flujo de cobro que ya tienes en el POS, solo que por el monto de la diferencia.
5. Si `diferencia < 0` (el producto nuevo cuesta menos): se le regresa la diferencia al cliente, y aquí aplican las mismas tres opciones de las secciones 5.1–5.3 (efectivo, crédito, o de plano llevarse un producto adicional).

Técnicamente esto es una extensión de `crear_devolucion`: agregar `p_tipo` (`'reembolso' | 'cambio_producto'`) y, cuando es cambio, un segundo arreglo `p_items_nuevos`. En vez de crear una tabla nueva para los productos que se lleva, lo más simple es reusar `devolucion_items` agregando una columna `es_entrada boolean` (false = el cliente lo devuelve, true = se lo lleva) — así una sola devolución con cambio queda completa en una sola tabla, y el reporte de "qué se movió" sale de ahí mismo.

## 6. Cómo se contabiliza todo — en términos prácticos, no solo teóricos

Pensando en los reportes que ya usas (`CorteCajaModule.jsx`, `TransaccionesTab.jsx`, tu dashboard):

**Inventario.** Ya está resuelto — cada devolución (con o sin cambio) pasa por `restock_via_lote` y por el descuento de stock del producto nuevo en un cambio. No hay que tocar nada aquí.

**Caja del día.** El punto que más te preocupa. La función `registrar_corte_caja` recibe hoy `p_efectivo_sistema` calculado y tecleado desde el front — nadie valida ese número contra la base de datos. Propongo que el cálculo de efectivo esperado deje de ser "lo que el cajero cree que debería haber" y pase a ser una suma real:

```
efectivo_esperado_turno =
    fondo_inicial_caja
  + suma(ventas del turno con metodo_pago = 'efectivo')
  - suma(devoluciones del turno con metodo_reembolso = 'efectivo', sin importar el metodo_pago_original de la venta)
  ± diferencias de cambio en devoluciones tipo 'cambio_producto' cobradas/pagadas en efectivo
```

Con esa fórmula ya no importa si la venta original fue por terminal — el efectivo que sale por una devolución siempre se resta, y el corte de caja cuadra solo. Esto es, con diferencia, el cambio de mayor impacto para resolver tu pregunta original y es relativamente poco esfuerzo: modificar `registrar_corte_caja` (o crear una función auxiliar `calcular_efectivo_esperado_turno`) para que sume desde `pedidos` y `devoluciones` en vez de confiar en el número que manda el front.

**Terminal / MercadoPago.** El total de "tarjeta" del corte de caja no se toca por una devolución en efectivo o crédito — ese dinero ya se cobró y ya se liquidó, no hay reversa. Solo se tocaría si en el futuro agregas el refund real por API (sección 9).

**Crédito otorgado.** No es un gasto ni entra a caja — es un pasivo: le debes mercancía o dinero al cliente a futuro. Vale la pena que el dashboard muestre un número como "crédito pendiente por canjear" (`select sum(saldo_credito) from clientes`), para que sepas cuánto tienes comprometido en cualquier momento — igual que seguramente ya te interesa saber cuántos puntos tienes acumulados sin canjear.

**Ventas netas.** Tanto el reembolso en efectivo como el de crédito deben restarse de las ventas brutas para que tus reportes de ingresos muestren el neto real del día/periodo — hoy, si `TransaccionesTab.jsx` sólo suma `pedidos.total` sin restar `devoluciones.total_devuelto`, tus números de ventas están inflados por lo que ya se devolvió.

## 7. Resumen de cambios técnicos (para Cursor)

Cambios de esquema (SQL):

```sql
alter table public.devoluciones
  add column if not exists tipo text not null default 'reembolso', -- 'reembolso' | 'cambio_producto'
  add column if not exists metodo_pago_original text,
  add column if not exists monto_efectivo numeric not null default 0,
  add column if not exists monto_credito numeric not null default 0,
  add column if not exists bono_credito numeric not null default 0,
  add column if not exists requiere_aprobacion boolean not null default false,
  add column if not exists aprobado_por bigint references public.usuarios(id);

alter table public.devolucion_items
  add column if not exists es_entrada boolean not null default false; -- true = producto que el cliente se lleva en un cambio

alter table public.clientes
  add column if not exists saldo_credito numeric not null default 0;

create table if not exists public.clientes_credito_movimientos (
  id bigint generated always as identity primary key,
  cliente_id bigint not null references public.clientes(id),
  devolucion_id bigint references public.devoluciones(id),
  pedido_id bigint references public.pedidos(id),
  tipo text not null, -- 'otorgado' | 'canjeado' | 'ajuste' | 'expirado'
  monto numeric not null,
  saldo_resultante numeric not null,
  motivo text,
  creado_por bigint references public.usuarios(id),
  created_at timestamptz not null default now()
);
```

RPCs nuevos o a modificar (mismo patrón `security definer` + `fn_require_empleado`/`fn_require_admin` que ya usas):

- `empleado_buscar_venta_reciente_por_producto(p_session_token, p_producto_id, p_dias default 15)`: soporta el flujo de escaneo de la sección 2 — devuelve las ventas candidatas donde apareció ese producto dentro de la ventana, para que el modal decida si hay una sola coincidencia o necesita desambiguar por folio/teléfono.
- `crear_devolucion`: agregar `p_tipo`, `p_items_nuevos` (para cambios), y la lógica de umbral de aprobación — si supera el umbral, guarda `estado='pendiente'`, `requiere_aprobacion=true` y no ejecuta restock ni efectivo/crédito todavía.
- `aprobar_devolucion(p_session_token, p_devolucion_id)` / `rechazar_devolucion(p_session_token, p_devolucion_id, p_motivo)`: ejecutan (o descartan) los efectos que quedaron pendientes.
- `canjear_credito_cliente(p_session_token, p_cliente_id, p_monto)`: valida saldo suficiente y lo descuenta — idealmente invocado dentro de la misma transacción que crea la venta, no como llamada separada.
- `calcular_efectivo_esperado_turno(p_turno)` o modificar `registrar_corte_caja` para que calcule en vez de confiar en el input del front.

Cambios de interfaz:

- `NuevaDevolucionModal`: agregar un modo "Escanear producto" como alternativa al buscador de folio/teléfono (reusando `barcodeProductLookup.js`), y un tercer flujo/paso "Cambio de producto" con buscador/escáner de producto nuevo y la diferencia calculada en vivo.
- `CorteCajaModule.jsx`: mostrar una línea "Devoluciones en efectivo del turno" que se resta del efectivo esperado, y "Crédito otorgado del turno" solo informativo (no afecta caja).
- Checkout (`Tienda.jsx` o donde cierres la venta en POS): agregar "Crédito FarmaCapital" como método de pago cuando el cliente identificado por teléfono tenga `saldo_credito > 0`.
- `DevolucionesModule.jsx`: el listado ya filtra por estado — solo falta que "pendiente" tenga contenido real y un botón de aprobar/rechazar visible para admins.

## 8. Fases sugeridas (para no parar el mostrador mientras se construye)

**Fase 1 — la que resuelve tu pregunta original, alto impacto y poco esfuerzo.** Agregar `metodo_pago_original` y `monto_efectivo` a `devoluciones`, corregir `registrar_corte_caja` para que reste el efectivo entregado en devoluciones del efectivo esperado, y agregar el modo "Escanear producto" como entrada rápida (sección 2) reusando `barcodeProductLookup.js`. Con solo esto, ya puedes dar efectivo con confianza aunque la venta haya sido por terminal, sin descuadres, y el mostrador queda más rápido.

**Fase 2 — crédito en tienda.** Columna `saldo_credito`, tabla `clientes_credito_movimientos`, RPC `canjear_credito_cliente`, y la opción de pago en checkout.

**Fase 3 — cambio de producto.** Extender `crear_devolucion` y el modal con el flujo de diferencia.

**Fase 4 — aprobación por umbral.** Los RPCs `aprobar_devolucion` / `rechazar_devolucion` y la política de ventana de 7 días / categorías no devolvibles.

**Fase 5 — opcional, a futuro.** Reembolso real a tarjeta vía API de refunds de MercadoPago (solo si el crédito no resulta suficiente para tus clientes en la práctica), y nota de crédito CFDI (tipo Egreso) ligada a la factura original — esto último no es urgente porque hoy no están facturando.

## 9. Nota sobre facturación (CFDI)

Como no están facturando activamente, no incluí la generación automática de nota de crédito fiscal en las fases anteriores. El día que activen `FacturacionModule.jsx` en serio, cualquier devolución de una venta que sí tenga CFDI de ingreso debería generar un CFDI de egreso (nota de crédito) ligado al folio original — es un requisito del SAT, no solo buena práctica — pero mientras la facturación no esté en uso, ese punto puede quedar documentado y no implementado.
