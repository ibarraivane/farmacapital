# Especificación: Envío a Domicilio por Distancia
### Farmacia Ventura — POS
**Versión 1.0 — 14 de septiembre de 2026**

> Documento de implementación. Escrito para ser usado como contexto en Cursor.
> Complementa a `perfil-vendedor-pos.md`. Reemplaza cualquier lógica previa basada en integración directa con Uber Direct API.
> Los valores marcados como `[CONFIGURABLE]` deben confirmarse con el dueño antes de fijarlos en código.

---

## 0. Contexto y decisión de diseño

La integración directa con Uber Direct (cotización + despacho automático vía API) está descartada por ahora — sin soporte de respuesta para resolver ajustes. La alternativa que se implementa aquí:

1. El sistema **estima** el costo de envío solo, usando distancia calculada + una tabla de tarifas propia. No llama a ninguna API de Uber/Didi para esto.
2. Si el envío no es gratis, al confirmar el pedido el cliente **autoriza una pre-autorización (hold)** en Mercado Pago por el estimado **más un colchón** — el dinero queda retenido en su tarjeta, pero no se le cobra todavía. Esto asume que la cuenta de Mercado Pago del negocio soporta captura diferida (hay que confirmarlo — ver §8); si no la soporta, el sistema cae al plan B descrito en la nota al final de §5.
3. Cuando el pedido está listo para salir, la vendedora **cotiza el viaje real** en la app de Uber/Didi (fuera del sistema) y **captura ese costo real** en el pedido, dentro de un plazo con cuenta regresiva (§5).
4. El sistema **captura de la pre-autorización solo el monto real** — nunca el colchón completo. El resto de la retención se libera automáticamente; el cliente no paga de más y no hace falta ningún reembolso manual.
5. Si el costo real supera el colchón autorizado (caso raro), el sistema captura el máximo autorizado y genera un cobro adicional aparte por la diferencia, vía link de Mercado Pago — ver §5.
6. Si aplica envío gratis según la tabla (§4), no hay pre-autorización ni cobro de ningún tipo por este concepto.

> Esto deja la puerta abierta a una Fase 2: si más adelante consiguen una integración con API de despacho (Uber Direct, Didi, o un agregador), el paso 3 se automatiza sin tocar el resto del modelo.

---

## 1. Objetivo

1. Calcular automáticamente la distancia entre la farmacia y la dirección del cliente.
2. Mostrar a la vendedora un **costo estimado de envío** (o "gratis") antes de cobrar, basado en distancia + monto de la compra.
3. Permitir que, al despachar, la vendedora capture el costo real cotizado por Uber/Didi y el sistema registre la diferencia.
4. Rechazar o marcar para aprobación manual los pedidos fuera del radio de cobertura.

---

## 2. Modelo de datos

### 2.1 `direccion_entrega`

```
direccion_entrega
├─ id                  uuid, pk
├─ pedido_id           fk pedidos
├─ texto_direccion     varchar          -- lo que captura la vendedora / cliente
├─ referencia          text nullable    -- "portón negro", "entre calles X y Y"
├─ latitud             decimal nullable
├─ longitud            decimal nullable
├─ geocoding_estado    enum('pendiente','resuelto','fallido')
├─ distancia_km        decimal nullable -- calculada, ver §3
└─ created_at
```

### 2.2 `envio` — una fila por pedido con entrega a domicilio

```
envio
├─ id                       uuid, pk
├─ pedido_id                fk pedidos, unique
├─ direccion_id              fk direccion_entrega
├─ distancia_km              decimal            -- copiada de direccion_entrega al cotizar
├─ costo_estimado            decimal            -- calculado por el sistema, tabla §4
├─ monto_preautorizado       decimal nullable   -- costo_estimado + colchón; lo que quedó retenido
├─ es_gratis                 bool               -- si true, no hay pre-autorización ni cobro
├─ regla_aplicada            varchar            -- qué renglón de la tabla de tarifas se usó, para auditar
├─ proveedor                 enum('uber','didi','propio','pendiente')
├─ costo_real                decimal nullable   -- lo que capturó la vendedora al cotizar el viaje real
├─ diferencia                decimal generado   -- costo_real - costo_estimado (solo informativo)
├─ excede_preautorizacion    bool default false -- true si costo_real > monto_preautorizado
├─ cotizacion_limite_at      timestamp nullable -- deadline para que el vendedor capture costo_real
├─ cotizacion_vencida        bool default false -- true si se pasó el deadline sin cotizar
├─ mercadopago_authorization_id varchar nullable -- id de la pre-autorización (hold)
├─ mercadopago_capture_id    varchar nullable   -- id de la captura del monto real
├─ mercadopago_link_extra    varchar nullable   -- solo si excede_preautorizacion=true, cobro de la diferencia
├─ estado_preautorizacion    enum('no_aplica','autorizada','capturada_parcial',
│                                  'liberada','expirada','fallida')
│                               -- 'no_aplica' cuando es_gratis=true
├─ estado                    enum('cotizado','preautorizado','esperando_costo_real',
│                                  'capturado_listo_para_viaje','esperando_pago_diferencia',
│                                  'viaje_solicitado','en_camino','entregado','cancelado')
├─ solicitado_por            fk usuarios
├─ solicitado_at             timestamp nullable
├─ entregado_at              timestamp nullable
└─ created_at
```

**Restricciones:**

- `costo_real` solo se puede capturar cuando `estado='esperando_costo_real'` o después.
- El sistema **no puede** pasar a `estado='viaje_solicitado'` mientras `estado_preautorizacion` no sea `capturada_parcial` — salvo que `es_gratis=true`. Restricción a nivel de backend, no solo de UI.
- Si `excede_preautorizacion=true`, el sistema captura el máximo autorizado, genera `mercadopago_link_extra` por la diferencia, y el pedido queda en `esperando_pago_diferencia` hasta que ese cobro adicional se confirme — mismo candado que antes, solo que ahora aplica a un monto mucho más chico (la diferencia, no el envío completo).
- No se puede dejar un envío en `entregado` sin `costo_real` capturado, salvo `es_gratis=true`.

### 2.3 `tabla_tarifa_envio` — configurable, no hardcodeada

```
tabla_tarifa_envio
├─ id                uuid, pk
├─ distancia_min_km  decimal
├─ distancia_max_km  decimal
├─ costo_base        decimal
├─ monto_gratis_desde decimal nullable  -- null = nunca es gratis en este rango
├─ activo            bool
└─ orden             int
```

Se evalúa por rango de distancia; dentro del rango, si el pedido supera `monto_gratis_desde`, el envío es gratis. Si no, se cobra `costo_base`.

---

## 3. Cálculo de distancia

1. Al capturar la dirección, se manda a un servicio de geocoding (`[CONFIGURABLE]` — Google Maps Geocoding API o Mapbox) para obtener lat/lng.
2. Con esas coordenadas y la ubicación fija de la farmacia, se calcula distancia real de ruta (no línea recta) vía Distance Matrix API del mismo proveedor. Línea recta subestima la distancia real de moto en zonas con calles no directas — usar ruta real evita cotizar de menos.
3. Si el geocoding falla (dirección ambigua, sin número, colonia mal escrita), `geocoding_estado='fallido'` y la pantalla pide a la vendedora confirmar o corregir la dirección antes de cotizar. **Nunca** se cotiza envío sobre una dirección no resuelta.
4. La distancia se recalcula solo si la dirección cambia. No se recalcula en cada visita al pedido.

---

## 4. Lógica de cotización (lo que ve la vendedora)

```
[Vendedora captura dirección]
        │
        ▼
  Geocoding + cálculo de distancia_km
        │
        ├── distancia_km > RADIO_MAXIMO_KM ──► "Fuera de zona de reparto.
        │                                       Ofrecer recoger en tienda,
        │                                       o marcar para aprobación
        │                                       manual del admin."
        │
        └── dentro del radio
                │
                ▼
        Buscar renglón de tabla_tarifa_envio donde
        distancia_min_km <= distancia_km < distancia_max_km
                │
                ▼
        ¿monto del pedido >= monto_gratis_desde de ese renglón?
                │
        ┌───────┴───────┐
        SÍ               NO
        │                │
   es_gratis=true    costo_estimado = costo_base
   costo_estimado=0   es_gratis=false
        │                │
        │                ▼
        │         monto_preautorizado =
        │         costo_estimado * FACTOR_COLCHON_PREAUTORIZACION
        │                │
        └───────┬────────┘
                ▼
   Se muestra a la vendedora / cliente ANTES de cerrar el pedido:
   "Envío: $X estimado (o Gratis) — Ndistancia_km km"
   Si no es gratis: cliente autoriza la retención en su tarjeta
   por monto_preautorizado (no se le cobra todavía)
                │
                ▼
        estado='cotizado' → 'preautorizado' (o se queda en
        'cotizado' si es_gratis=true, sin pasar por MP)
```

### Tabla de tarifas — con DiDi como proveedor base

DiDi queda como el proveedor por defecto para cotizar (comisión más baja para el repartidor y tarifa dinámica menos agresiva que Uber, según benchmarks de mercado). Uber se deja como fallback manual si DiDi no tiene repartidor disponible en el momento — el campo `proveedor` sigue aceptando ambos valores, pero la pantalla de cotización abre la app de DiDi primero.

**La lógica de "gratis" es la misma sin importar el proveedor — lo único que cambia es el costo real que se usa de base:**

```
monto_gratis_desde = (costo_envio_estimado + ganancia_minima_deseada) / margen_promedio
```

- `costo_envio_estimado`: lo que cuesta el viaje en ese rango de distancia.
- `margen_promedio`: tu margen bruto típico (usamos 28% como referencia — ajústalo al real de Farmacia Ventura).
- `ganancia_minima_deseada`: cuánto quieres que te quede de ganancia neta en el pedido después de cubrir el envío, no solo empatar.

Con costos de DiDi (más bajos que la referencia de Uber usada antes) y una ganancia mínima deseada de ~$20 por pedido:

| Distancia | Costo DiDi estimado | Punto de equilibrio (margen = envío) | Gratis desde (con $20 de ganancia) |
|---|---|---|---|
| 0 – 2 km | `[CONFIGURABLE] $30` | $30 / 0.28 ≈ $107 | `[CONFIGURABLE] $180` |
| 2 – 4 km | `[CONFIGURABLE] $45` | $45 / 0.28 ≈ $161 | `[CONFIGURABLE] $230` |
| 4 – `RADIO_MAXIMO_KM` | `[CONFIGURABLE] $65` | $65 / 0.28 ≈ $232 | `[CONFIGURABLE] $320` |

> Con tu ticket promedio actual de $100, la mayoría de pedidos normales van a pagar el envío base, no calificar gratis — es la idea: el umbral de gratis está pensado para empujar el ticket a un tamaño donde regalar el envío sigue dejando ganancia, no para regalarlo en la operación normal. Ajusta `margen_promedio` y `ganancia_minima_deseada` con tus números reales y recalcula — la fórmula es lo que importa, no estos valores puntuales.

---

## 5. Flujo de despacho y captura del monto real

```
Pedido de producto ya pagado, listo para salir
        │
        ▼
¿es_gratis = true?
        │
   ┌────┴────┐
  SÍ          NO
   │           │
   │           ▼
   │    estado='esperando_costo_real'
   │    cotizacion_limite_at = now() + TIEMPO_MAXIMO_COTIZACION_MIN
   │    Aparece como rubro pendiente y visible en el
   │    propio pedido — la vendedora lo ve en su lista
   │    de pendientes con cuenta regresiva
   │    ("Cotizar envío — 12 min restantes")
   │           │
   │           ▼
   │    Vendedora cotiza el viaje en la app de
   │    DiDi (fuera del sistema, sin pedirlo todavía;
   │    Uber queda como fallback manual si DiDi no
   │    tiene repartidor disponible) y captura en el
   │    sistema:
   │      - proveedor (didi / uber)
   │      - costo_real
   │           │
   │    ┌──────┴───────────────────────┐
   │    │ Si se captura ANTES del      │ Si se pasa el deadline
   │    │ deadline → sigue el flujo    │ sin capturar:
   │    │ normal abajo                 │ cotizacion_vencida=true
   │    │                              │ Se notifica al admin
   │    │                              │ (el pedido sigue
   │    │                              │  esperando, pero ya
   │    │                              │  quedó marcado para
   │    │                              │  seguimiento)
   │    └──────────────┬───────────────┘
   │                   ▼
   │    ¿costo_real <= monto_preautorizado?
   │           │
   │      ┌────┴────┐
   │     SÍ          NO
   │      │           │
   │      ▼           ▼
   │  Backend       excede_preautorizacion=true
   │  captura       Backend captura el máximo
   │  costo_real    autorizado (monto_preautorizado)
   │  de la hold    y genera mercadopago_link_extra
   │  (resto se     por (costo_real - monto_preautorizado),
   │  libera solo)  enviado por WhatsApp
   │      │           │
   │      │           ▼
   │      │     estado='esperando_pago_diferencia'
   │      │     Pedido pausado hasta confirmar ese
   │      │     cobro adicional (mismo candado de
   │      │     antes, pero aplicado solo a la
   │      │     diferencia, no al envío completo)
   │      │           │
   │      │           ▼ (al confirmarse el pago)
   │      └─────┬─────┘
   │            ▼
   │    estado_preautorizacion='capturada_parcial'
   │    estado='capturado_listo_para_viaje'
   │
   └──────┤
          ▼
   Vendedora pide el viaje real en Uber/Didi
   (recién ahora, con el monto real ya cobrado
   o el envío gratis confirmado)
          │
          ▼
   estado='viaje_solicitado', solicitado_at = now()
          │
          ▼
   diferencia = costo_real - costo_estimado
   (solo informativo para el admin, §6)
          │
          ▼
   Repartidor entrega → vendedora marca 'entregado',
   entregado_at = now()
```

**Plan B si la cuenta de Mercado Pago no soporta captura diferida (pre-autorización):** el flujo completo de arriba no aplica. En su lugar, no se retiene nada en el checkout; se cotiza el estimado como referencia (sin cobrarlo), y al capturar `costo_real` el sistema genera directamente un **link de pago de Mercado Pago** por ese monto completo, enviado por WhatsApp — el pedido espera esa confirmación antes de pedir el viaje. Es el mismo mecanismo que ya se usa arriba para el caso de "excede preautorización", solo que aplicado al monto completo en vez de a la diferencia. Conviene confirmar con Mercado Pago cuál de los dos planes aplica antes de construir esto.

**El costo_estimado nunca se cobra tal cual.** Es la base para calcular el colchón de la pre-autorización; lo único que efectivamente se captura de la tarjeta del cliente es `costo_real`.

---

## 5.1 Repartidor propio (bicicleta/moto local) — opción adicional

En proceso de contratar a alguien local, en bicicleta o moto, para hacer entregas por propina en vez de usar Uber/Didi. Esto es un **tercer valor de `proveedor`** (`'propio'`, ya contemplado en el modelo de §2.2), con una lógica distinta a la de Uber/Didi:

- **Solo disponible dentro de la misma colonia** de la farmacia — no aplica el radio en km de §3, es una restricción por colonia. `direccion_entrega` necesita un campo `colonia` (texto, se puede derivar del resultado del geocoding) para poder filtrar esto.
- **No pasa por pre-autorización ni captura de Mercado Pago.** Es un pago informal por propina que el cliente le da directo al repartidor — el sistema no cobra nada por este concepto. `costo_estimado` para este caso es `0` y `es_gratis=true` a efectos de cobro, aunque el pedido sí tiene un repartidor asignado.
- **Requiere disponibilidad del repartidor.** Se necesita un estado simple (`disponible` / `ocupado` / `fuera_de_turno`) para que la vendedora sepa si puede ofrecer esta opción antes de mostrarla como alternativa a Uber/Didi.
- **Selección manual por la vendedora**, no automática: si la dirección cae en la colonia de cobertura y el repartidor está disponible, la pantalla ofrece "Repartidor local (propina)" como opción junto al estimado de Uber/Didi. La vendedora decide cuál usar según el caso.
- No aplica el flujo de §5 (cotización con deadline, pre-autorización, captura) porque no hay un costo real que cobrar — el pedido pasa directo de `esperando_costo_real` a `viaje_solicitado` en cuanto se asigna al repartidor propio, sin pasos de cobro de por medio.

> Punto abierto: falta decidir si el negocio le paga algo fijo al repartidor además de la propina (sueldo base, por entrega, etc.) — eso es un tema de RH/nómina, no de este flujo de pedido, y se resuelve aparte.

---

## 6. Lo que ve el admin (no el vendedor)

- Reporte de `diferencia` acumulada por periodo — si el estimado sistemáticamente se queda corto, es señal de que la tabla de tarifas necesita ajustarse.
- Pedidos marcados como fuera de radio, pendientes de aprobación manual.
- Costo real promedio por rango de distancia, comparado contra `costo_base` de la tabla — permite ajustar la tabla con datos reales después de unas semanas de operación.

El vendedor solo ve el estimado que cotizó y el costo real que él mismo capturó en su propio pedido — no el acumulado de diferencias del negocio (mismo principio que en `perfil-vendedor-pos.md` §7: nada de márgenes o impacto financiero agregado visible para el rol vendedor).

---

## 7. Parámetros configurables

| Parámetro | Valor sugerido | Notas |
|---|---|---|
| `RADIO_MAXIMO_KM` | `[CONFIGURABLE] 5 km` | Arriba de esto, no se cotiza envío automático. |
| `TIEMPO_MAXIMO_COTIZACION_MIN` | `[CONFIGURABLE] 15 min` | Plazo para que el vendedor capture el costo real desde que el pedido queda listo para salir. Vencido, se notifica al admin pero el pedido no se cancela solo. |
| `FACTOR_COLCHON_PREAUTORIZACION` | `[CONFIGURABLE] 1.4x` | Multiplicador sobre `costo_estimado` para fijar el monto que se retiene en la tarjeta. Empezar generoso (1.4-1.5x) y ajustar hacia abajo con datos reales de cuántas veces se excede — ver `excede_preautorizacion` en reportes de admin. |
| `PROVEEDOR_GEOCODING` | `[CONFIGURABLE]` | Google Maps o Mapbox — definir por costo de API y cobertura en la zona. |
| `tabla_tarifa_envio` | ver §4 | Editable por admin, no hardcodeada en el código. |
| `POLITICA_DIFERENCIA` | `[CONFIGURABLE] absorbe negocio` | Alternativa: ajustar la tabla mensualmente con base en el promedio real — pero nunca re-cobrar al cliente ya cotizado. |

---

## 8. Puntos abiertos

- **Costo real de geocoding/Distance Matrix.** Google Maps cobra por llamada después de cierto volumen gratuito — vale la pena estimar cuántas cotizaciones al mes hace la farmacia antes de elegir proveedor.
- **Confirmar con Mercado Pago si la cuenta del negocio soporta captura diferida (pre-autorización) en México, y por cuántos días queda vigente el hold antes de expirar solo.** Esto es lo primero que hay que resolver antes de construir §5 tal como está descrito — si no está disponible, aplica el Plan B ya documentado ahí mismo.
- **Pedidos fuera de radio con excepción.** Si un cliente frecuente vive a 6 km, ¿se permite una aprobación manual del admin caso por caso, o se cierra la puerta del todo? El modelo de arriba ya deja espacio para ese estado, falta decidir la política.
- **Validación del costo real capturado.** Hoy se confía en que la vendedora anote lo que vio en la app. Si en la práctica hay discrepancias grandes o sospechosas, se podría pedir captura de pantalla como evidencia — igual que un justificante en otras partes del sistema.
- **Fase 2 — integración automática.** Si más adelante hay acceso a una API de despacho (Uber Direct u otra), el paso manual de §5 se reemplaza por una llamada automática que cotiza y solicita en un solo paso, sin cambiar el resto del modelo de datos.
