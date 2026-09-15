# Especificación: Encargo de Medicamentos (No Disponibles en Catálogo)
### Farmacia Ventura — Sitio público + Admin
**Versión 1.0 — 14 de septiembre de 2026**

> Documento de implementación. Escrito para ser usado como contexto en Cursor.
> Complementa a `perfil-vendedor-pos.md` (roles, `solicitud_producto`, matriz de permisos) y a `claude_envio-domicilio.md` (si el encargo se entrega a domicilio, reutiliza ese flujo).
> Los valores marcados como `[CONFIGURABLE]` deben confirmarse con el dueño antes de fijarlos en código.

---

## 0. Qué es esto y qué NO es

Es distinto de `solicitud_producto` (definida en `perfil-vendedor-pos.md` §3.4): esa es interna — un vendedor reportando que llegó mercancía sin dar de alta en catálogo. Esto es **el cliente pidiendo algo que la farmacia no tiene en existencia**, desde el sitio público, esperando una cotización antes de comprometerse a nada.

Flujo en una línea: cliente pide → admin cotiza (precio + tiempo de entrega) → cliente acepta y paga → farmacia consigue el medicamento → se entrega o se recoge en tienda.

## 0.1 Dos casos distintos — no todo necesita cotización completa

Al revisar cómo lo resuelven otras farmacias especializadas en México (BuscaMed, AltamediQ, Farmacias Especializadas), aparece una distinción que conviene adoptar: **no todo "no lo tenemos" es lo mismo.**

- **Caso A — agotado temporal.** El producto ya está en tu catálogo, ya tiene precio fijado, simplemente no hay existencia ahora mismo. Aquí no hace falta cotizar nada — el precio ya se conoce. Basta con un botón de **"Avísame cuando esté disponible"**: el cliente deja su teléfono, y cuando entra una `entrada_inventario` validada de ese producto, se le notifica automáticamente por WhatsApp. Sin espera de respuesta, sin vigencia que expire, sin admin de por medio.
- **Caso B — nunca lo has manejado.** Es tu ejemplo de Exkutera: no está en catálogo, no tienes precio, hay que cotizarlo con un distribuidor. Aquí sí aplica todo el flujo de cotización completo descrito abajo (§3-§4).

El formulario público debe distinguir esto desde el inicio — si el cliente busca un nombre que sí existe en tu catálogo pero con stock 0, se le ofrece el botón simple del Caso A; si no existe en catálogo, cae directo al formulario de encargo del Caso B.

---

## 1. Objetivo

1. Dar al cliente un lugar en el sitio para pedir un medicamento que no está en el catálogo.
2. Que el admin pueda cotizar (precio y tiempo estimado) desde el panel, sin que esto recaiga en el vendedor.
3. Que el cliente reciba la cotización, decida, y si acepta, pague antes de que la farmacia gaste en conseguir el producto.
4. Dar seguimiento del encargo hasta la entrega, reutilizando la lógica de envío a domicilio ya definida donde aplique.

---

## 2. Dónde vive esto

**Sitio público:** un tercer punto de entrada junto a "Agendar cita" y "Catálogo" — sugerido: **"¿No lo encuentras? Pídelo"**. No requiere que el cliente ya tenga cuenta para empezar, pero sí un teléfono/WhatsApp de contacto obligatorio (es el canal donde se le va a mandar la cotización, mismo patrón que en envío a domicilio).

**Admin:** no es un módulo nuevo aislado — es un tercer tipo de pedido dentro de **"Pedidos en línea"** (ya existe en la matriz de permisos de `perfil-vendedor-pos.md` §6), junto a los pedidos normales de catálogo y las citas. Se distingue por su propio estado inicial: "esperando cotización".

---

## 3. Modelo de datos

### 3.0 `aviso_disponibilidad` — Caso A (agotado temporal)

```
aviso_disponibilidad
├─ id                 uuid, pk
├─ producto_id        fk productos
├─ cliente_telefono   varchar
├─ cliente_nombre     varchar
├─ notificado         bool default false
├─ notificado_at      timestamp nullable
└─ created_at
```

**Trigger:** cuando una `entrada_inventario` de ese `producto_id` pasa a `validada` (ver `perfil-vendedor-pos.md` §3.3) y el stock resultante es > 0, se dispara el aviso a todos los `aviso_disponibilidad` con `notificado=false` de ese producto.

**Qué tan automático es esto depende de si hay WhatsApp Business API conectada (mismo punto que ya aplicaba al envío a domicilio):**

- **Con WhatsApp Business API:** el mensaje sale solo, sin que nadie lo toque. El backend arma el texto ("Ya llegó tu [producto], ya está disponible") y lo manda directo al reabastecer. `notificado=true` se marca automático al confirmarse el envío del mensaje.
- **Sin WhatsApp Business API (probable punto de partida):** no se puede mandar el mensaje solo — WhatsApp normal no tiene API pública para esto. En su lugar, el sistema arma una **cola de avisos pendientes de enviar**, visible en el admin: "3 personas esperando [producto], ya está disponible" con el link de WhatsApp precargado (`wa.me/...`) para cada una. La vendedora o el admin solo dan clic y enviar — un toque por persona, sin escribir nada a mano. `notificado=true` se marca cuando se da clic en "enviado" en esa cola.

**Recomendación:** arrancar con la versión sin API (cola manual con un clic). El trámite de WhatsApp Business API con Meta sigue pendiente de cerrarse, y el volumen de pedidos hoy es bajo — no hay urgencia de automatizarlo del todo. Implementar directamente la cola manual, sin depender de tener la API aprobada primero. Si el trámite se cierra más adelante y el volumen crece, se puede automatizar sin cambiar el modelo de datos (`aviso_disponibilidad` ya queda listo para ambos casos).

### 3.1 `encargo_medicamento` — Caso B (nunca manejado, requiere cotización)

```
encargo_medicamento
├─ id                     uuid, pk
├─ cliente_nombre         varchar
├─ cliente_telefono       varchar            -- obligatorio, canal de contacto
├─ cliente_id             fk usuarios nullable -- si el cliente sí tiene cuenta
├─ nombre_medicamento     varchar            -- texto libre, no ligado a catálogo (no existe ahí)
├─ presentacion           varchar nullable   -- "500mg, 20 tabletas", etc.
├─ cantidad               int
├─ requiere_receta        bool               -- ver §7, sube desde el formulario si aplica
├─ receta_url             varchar nullable   -- foto/PDF de receta, si requiere_receta=true
├─ comentario_cliente     text nullable
├─ estado                 enum('pendiente_cotizacion','cotizado','aceptado',
│                                'rechazado','expirado','pagado','consiguiendo',
│                                'listo_para_entrega','entregado','cancelado')
├─ metodo_entrega         enum('domicilio','recoger_en_tienda') nullable
│                            -- se define al aceptar la cotización, no antes
├─ envio_id               fk envio nullable  -- si metodo_entrega='domicilio',
│                                                reutiliza el flujo de claude_envio-domicilio.md
└─ created_at
```

### 3.2 `cotizacion_encargo`

Una cotización por encargo (si se vuelve a cotizar tras un rechazo, se crea una fila nueva, no se sobreescribe — conviene el historial).

```
cotizacion_encargo
├─ id                    uuid, pk
├─ encargo_id            fk encargo_medicamento
├─ precio_unitario       decimal
├─ precio_total          decimal generado: precio_unitario * cantidad
├─ disponibilidad        enum('disponible','sujeto_a_confirmacion','no_disponible')
├─ nota_disponibilidad   varchar nullable   -- ej. "confirmado con Nadro", "en tránsito, llega en 2 días"
├─ tiempo_estimado_dias  int                -- ej. 2, 3, 5 — días hábiles estimados
├─ tiempo_estimado_nota  varchar nullable   -- "sujeto a disponibilidad del distribuidor"
├─ vigencia_hasta        timestamp          -- deadline para que el cliente responda
├─ cotizado_por          fk usuarios        -- admin, nunca vendedor (ver §5)
├─ estado                enum('enviada','aceptada','rechazada','expirada')
├─ enviado_at            timestamp
├─ respondido_at         timestamp nullable
└─ created_at
```

**Restricción:** `encargo_medicamento.estado` no puede pasar a `'aceptado'` sin una `cotizacion_encargo` en estado `'aceptada'`. Un encargo puede tener varias cotizaciones en su historial (si la primera expiró o se rechazó y se volvió a cotizar), pero solo una activa a la vez.

**Todo el dato de la cotización se captura a mano por ahora.** El admin busca el medicamento con su distribuidor (llamada, portal B2B, lo que use hoy) y mete precio, disponibilidad y tiempo estimado directamente en el formulario — no hay ninguna búsqueda automática ni integración con sitios de terceros en esta versión. Si más adelante conviene una herramienta de referencia rápida (enlaces precargados a sitios de precio público, o una integración real con la API de algún distribuidor si la ofrecen), es un punto aparte para evaluar después con datos de uso real — no bloquea esta implementación.

---

## 4. Flujo completo

```
Cliente llena el formulario en el sitio (nombre_medicamento,
cantidad, teléfono, receta si aplica)
        │
        ▼
estado='pendiente_cotizacion'
Aparece en el admin, dentro de Pedidos en línea, como
encargo pendiente de cotizar
        │
        ▼
Admin busca el medicamento con su distribuidor/proveedor,
define precio_unitario y tiempo_estimado_dias
        │
        ▼
Se crea cotizacion_encargo, estado='enviada'
vigencia_hasta = now() + TIEMPO_VIGENCIA_COTIZACION_DIAS
Se manda al cliente por WhatsApp (mismo mecanismo que en
envío a domicilio: mensaje precargado con el detalle)
        │
        ▼
estado='cotizado'
        │
   ┌────┴─────────────────┐
   │                       │
Cliente responde      Se pasa vigencia_hasta
antes del deadline    sin respuesta
   │                       │
   ▼                       ▼
¿Acepta?              cotizacion_encargo.estado='expirada'
   │                  encargo.estado='expirado'
┌──┴──┐               Admin puede volver a cotizar si el
SÍ     NO              cliente contacta de nuevo (nueva fila
│       │               en cotizacion_encargo)
▼       ▼
Continúa  encargo.estado='rechazado'
abajo     (fin del flujo, salvo que el
          cliente pida cotizar de nuevo)
│
▼
Cliente elige metodo_entrega:
  domicilio / recoger en tienda / (si requiere_cadena_fria=true,
  ver §4.1 — estas dos opciones normales no aplican)
        │
        ▼
Se genera cobro por precio_total (+ costo_entrega_extra si
aplica cadena fría, ver §4.1) vía Mercado Pago
(mismo patrón que envío: si hay captura diferida disponible,
se puede pre-autorizar; si no, link de pago directo — aquí
no hay "colchón" que aplicar porque el precio ya es fijo y
conocido, a diferencia del envío que dependía de una cotización
externa de Uber/Didi)
        │
        ▼
Al confirmarse el pago: estado='pagado'
        │
        ▼
Admin marca 'consiguiendo' mientras gestiona con el proveedor
        │
        ▼
Al llegar el medicamento: estado='listo_para_entrega'
        │
   ┌────┴────┐
domicilio   recoger en tienda
   │            │
   ▼            ▼
Se crea/vincula   Cliente recoge en
un envio_id y     tienda, admin marca
sigue el flujo    'entregado' manualmente
ya definido en
claude_envio-
domicilio.md
   │
   ▼
estado='entregado'
```

---

## 4.1 Cadena fría — entrega personalizada

Si `encargo_medicamento.requiere_cadena_fria=true` (biológicos, insulinas, y similares), **no aplican las opciones normales de entrega**: ni el flujo de Uber/DiDi ni el repartidor propio de `claude_envio-domicilio.md` garantizan temperatura controlada. Solo hay dos caminos:

- **Recoger en tienda.** El cliente pasa directo a la farmacia. Sin costo extra, sin nada especial que planear.
- **Entrega personalizada.** El admin la arma manualmente — a diferencia del flujo normal de envío, aquí no hay tabla de tarifas por distancia ni cotización automática de Uber/DiDi: es el admin decidiendo cómo se transporta con frío (hielera, alguien de confianza, un servicio especializado si lo hay) y capturando el costo directamente.

### Campos adicionales en `encargo_medicamento`

```
├─ requiere_cadena_fria    bool default false
├─ costo_entrega_extra     decimal nullable   -- solo si eligió entrega personalizada
├─ nota_entrega_extra      text nullable      -- cómo se va a transportar, capturado por admin
```

### Flujo

```
estado='listo_para_entrega' Y requiere_cadena_fria=true
        │
        ▼
Cliente elige: recoger en tienda / entrega personalizada
        │
   ┌────┴────┐
recoger      entrega personalizada
   │              │
   ▼              ▼
Sin costo    Admin captura costo_entrega_extra
extra,       y nota_entrega_extra
sigue flujo       │
normal            ▼
   │         Se genera cobro adicional por ese monto
   │         vía Mercado Pago (mismo mecanismo de link
   │         de pago ya usado en el resto del sistema)
   │              │
   │              ▼
   │         Al confirmarse: admin coordina la entrega
   │         directamente (fuera del sistema de reparto
   │         automático) y marca 'entregado' a mano
   │              │
   └──────┬───────┘
          ▼
   estado='entregado'
```

**Por qué el costo se cobra aparte y no se mete en la tabla de tarifas normal:** el costo de cadena fría depende de cómo se resuelva caso por caso (no hay un proveedor fijo tipo DiDi con tarifa por km) — forzarlo dentro de la lógica de distancia de `claude_envio-domicilio.md` complicaría esa tabla sin necesidad. Es más simple mantenerlo como un cobro manual aparte, igual que ya se hace con `precio_total` del medicamento mismo.

---

## 5. Permisos

| Acción | `vendedor` | `admin` |
|---|:--:|:--:|
| Ver encargos pendientes de cotizar | ✅ (solo para informar al cliente que está en proceso) | ✅ |
| Cotizar (definir precio y tiempo) | ❌ | ✅ |
| Marcar 'consiguiendo' / 'listo_para_entrega' / 'entregado' | ✅ | ✅ |
| Ver historial de cotizaciones de un encargo | ❌ | ✅ |
| Ver precio de compra / margen del encargo | ❌ | ✅ |

**Por qué cotizar es solo admin:** poner precio implica saber el costo del medicamento con el distribuidor — mismo principio ya establecido en `perfil-vendedor-pos.md` §7: el vendedor nunca ve costos ni márgenes. Que la vendedora capture la solicitud del cliente está bien (es atención al cliente), pero el número final lo pone quien sí ve el costo.

---

## 6. Lo que ve el cliente vs. lo que no

**Ve:** el estado de su encargo (pendiente de cotización, cotizado con precio y tiempo, en proceso, listo), el detalle de la cotización, y el historial si se le volvió a cotizar.

**No ve:** con qué distribuidor se consiguió, el costo del medicamento, ni quién de la farmacia lo está gestionando.

---

## 7. Nota sobre receta médica

Si `requiere_receta=true`, el formulario debe pedir subir foto o PDF de la receta antes de que el admin pueda cotizar — es un punto legal/regulatorio, no solo de UX. Definir con el dueño (o revisar con quien corresponda) qué medicamentos de su catálogo caen en esa categoría, y si el sistema debe intentar detectarlo automáticamente por nombre o dejarlo como una casilla que el cliente marca bajo su responsabilidad, con el admin validando la receta antes de proceder. Esto no es asesoría legal — conviene que alguien con conocimiento regulatorio de farmacias en México lo confirme antes de lanzar esta parte.

---

## 8. Parámetros configurables

| Parámetro | Valor sugerido | Notas |
|---|---|---|
| `TIEMPO_VIGENCIA_COTIZACION_DIAS` | `[CONFIGURABLE] 3 días` | Después de esto, la cotización expira y hay que volver a cotizar si el cliente sigue interesado. |
| `REQUIERE_TELEFONO_OBLIGATORIO` | `true` (no configurable, es el único canal de contacto) | |

---

## 9. Puntos abiertos

- **Qué pasa si el admin no puede conseguir el medicamento después de cotizarlo y cobrarlo.** Falta definir el flujo de cancelación con reembolso — probablemente reembolso completo vía Mercado Pago, con nota al cliente. No está resuelto en este documento.
- **Detección de medicamentos que requieren receta (§7).** Confirmar antes de lanzar esta parte.
- **Límite de cuántos encargos activos puede tener el admin sin cotizar antes de que se vuelva un cuello de botella operativo** — si el volumen crece, puede valer la pena una alerta de "encargos esperando cotización hace más de X horas", parecido al SLA que ya existe en envío a domicilio.
- **Búsqueda automatizada de referencia de precios (descartada por ahora).** Se evaluó scraping de sitios de farmacias grandes para ayudar a cotizar, pero se descartó: los medicamentos raros que suele pedir la gente casi nunca están en esos catálogos, y el precio público no es el costo real del distribuidor. Si en el futuro algún distribuidor ofrece API para farmacias afiliadas, vale la pena revisarlo — mientras tanto, todo el dato de la cotización se captura a mano.
- **SLA de comunicación desde que se recibe la solicitud.** Otras farmacias especializadas (Farmacias Especializadas, AltamediQ) prometen un tiempo de respuesta explícito ("te decimos en minutos si lo tenemos" / "lo conseguimos en 24 horas") incluso antes de tener el precio final. Vale la pena definir algo similar — un mensaje automático al recibir la solicitud tipo "te cotizamos en menos de X horas" — para que el cliente no sienta que el formulario se fue al vacío mientras el admin cotiza.
