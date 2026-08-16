# WhatsApp — FarmaCapital (Meta Cloud API)

Número comercial (app celular): **+52 55 6253 0631** — no migrar vía Meta hasta resolver coexistencia.

Número temporal Meta (API de prueba): Phone Number ID `1338650695990173` (+1 555-342-4819).

## Endpoints (solo servidor Vercel)

| Ruta | Método | Uso |
|------|--------|-----|
| `/api/webhooks/whatsapp` | GET | Verificación Meta (`hub.verify_token` + `hub.challenge`) |
| `/api/webhooks/whatsapp` | POST | Eventos entrantes y estados (requiere firma `X-Hub-Signature-256`) |
| `/api/whatsapp/send` | POST | Envío manual → rewrite a `/api/notifications/send?type=whatsapp` |

**Límite Vercel Hobby:** máx. 12 funciones serverless. La lógica WhatsApp vive en `api/_lib/` (no cuenta); webhook y send usan rewrites a funciones existentes.

URL pública del webhook (Meta): **https://www.farmacapital.mx/api/health**

> En Vercel Hobby, `/api/webhooks/whatsapp` devuelve 404 si no hay archivo serverless en esa ruta (el rewrite no siempre aplica). **`/api/health`** detecta `hub.mode` / firma Meta y delega al handler WhatsApp.
>
> Usa siempre **`www`**. Sin `www` hay redirect 308 y Meta falla la verificación.

## Variables en Vercel (Sensitive — Production y Preview)

```env
WHATSAPP_ACCESS_TOKEN=...
WHATSAPP_PHONE_NUMBER_ID=1338650695990173
WHATSAPP_BUSINESS_ACCOUNT_ID=2277703916307084
WHATSAPP_VERIFY_TOKEN=...          # tú lo eliges; mismo valor en Meta webhook
WHATSAPP_APP_SECRET=...            # Meta → App → Configuración → Básica → Clave secreta
WHATSAPP_INTERNAL_SECRET=...       # tú lo generas; protege /api/whatsapp/send
WHATSAPP_PROVIDER=meta             # opcional; auto-detecta si hay ACCESS_TOKEN
WHATSAPP_GRAPH_VERSION=v21.0       # opcional

# Plantillas Utility (nombres exactos tras aprobación en Meta)
WHATSAPP_TEMPLATE_LANGUAGE=es_MX
WHATSAPP_TEMPLATE_PEDIDO_CONFIRMADO=pedido_confirmado
WHATSAPP_TEMPLATE_PEDIDO_PAGO=pedido_pago_aprobado
WHATSAPP_TEMPLATE_PEDIDO_LISTO=pedido_listo
WHATSAPP_TEMPLATE_CITA=cita_confirmacion
WHATSAPP_TEMPLATE_FALLBACK_TEXT=true   # si la plantilla falla, envía texto libre
```

Compatibilidad legacy (opcional): `META_WHATSAPP_TOKEN`, `META_WHATSAPP_PHONE_ID`, `META_APP_SECRET`.

**No uses** prefijo `REACT_APP_` ni `NEXT_PUBLIC_` para secretos.

### Token expirado — «Authentication Error»

Si el panel muestra **Authentication Error**, el `WHATSAPP_ACCESS_TOKEN` en Vercel ya no es válido (caduca ~24 h si es el token temporal del panel Meta).

1. [developers.facebook.com](https://developers.facebook.com) → App **FarmaCapital** → **WhatsApp** → **API Setup**
2. En la misma pantalla anota el **Phone number ID** (debe coincidir con `WHATSAPP_PHONE_NUMBER_ID` en Vercel).
3. Clic **Generate access token** (o token del System User si ya lo configuraste).
4. Vercel → **Settings → Environment Variables** → actualiza `WHATSAPP_ACCESS_TOKEN` (Sensitive, Production).
5. **Redeploy** y prueba 📱 de nuevo.

> No pegues la **App Secret** ni el **Verify Token** en `WHATSAPP_ACCESS_TOKEN` — solo el access token largo que empieza con `EAA…`.

### Crear WHATSAPP_APP_SECRET en Vercel

1. [developers.facebook.com](https://developers.facebook.com) → App **FarmaCapital** → **Configuración de la app** → **Básica**
2. Copia **Clave secreta de la app** (App Secret)
3. Vercel → **Settings → Environment Variables** → Add → Name: `WHATSAPP_APP_SECRET`, Value: (pegar), Sensitive: ON
4. Redeploy

### Crear WHATSAPP_INTERNAL_SECRET

Genera una cadena aleatoria larga (32+ caracteres). En Vercel: `WHATSAPP_INTERNAL_SECRET` (Sensitive).  
Usar en pruebas: `Authorization: Bearer <valor>` al llamar `/api/whatsapp/send`.

## Configurar webhook en Meta (paso a paso)

### Pantalla 1 — WhatsApp → Configuración → Webhook

1. Meta for Developers → App **FarmaCapital** → **WhatsApp** → **Configuración**
2. Sección **Webhook** → **Editar**
3. **URL de devolución de llamada:** `https://www.farmacapital.mx/api/webhooks/whatsapp`
4. **Token de verificación:** el mismo valor que `WHATSAPP_VERIFY_TOKEN` en Vercel
5. Clic **Verificar y guardar**

### Pantalla 2 — Suscribir campos

1. **Administrar** suscripciones del webhook → WABA FarmaCapital
2. Activa **`messages`** y enciende **Suscribir webhooks** en el número +1 555-342-4819

### Pantalla 3 — Prueba entrante

Envía un WhatsApp al +1 555-342-4819 y revisa Vercel Logs (`[whatsapp-webhook]`).

## Envío manual de prueba (Fase 1)

```bash
curl -sS -X POST "https://www.farmacapital.mx/api/whatsapp/send" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_WHATSAPP_INTERNAL_SECRET" \
  -d '{"to":"52XXXXXXXXXX","text":"Prueba FarmaCapital API"}'
```

## Fase 2 — Plantillas y recibos automáticos

El servidor intenta **plantilla Utility** si `WHATSAPP_TEMPLATE_*` está en Vercel; si falla, envía **texto libre** (fallback).

Solo se envía WhatsApp de pedido con opt-in (`pedidos.whatsapp_recibo = true`).

### Crear plantillas en Meta (WhatsApp → Plantillas)

Idioma **es_MX**, categoría **Utility**. Usa estos cuerpos (ajusta nombres a los de Vercel):

**`pedido_confirmado`** — 4 variables cuerpo:
```
FarmaCapital — Pedido confirmado

Folio: {{1}}
Total: ${{2}}
Entrega: {{3}}

{{4}}
```

**`pedido_pago_aprobado`** — 4 variables:
```
FarmaCapital — Pago aprobado

Folio: {{1}}
Total: ${{2}}
Entrega: {{3}}

{{4}}
```

**`pedido_listo`** — 2 variables:
```
FarmaCapital — ¡Tu pedido está listo!

Folio: {{1}}
{{2}}
```

**`cita_confirmacion`** — 4 variables:
```
FarmaCapital — Cita confirmada

Hola {{1}}, tu cita quedó registrada.
Fecha: {{2}}
Hora: {{3}}
📍 {{4}}
```

Tras aprobación, agrega en Vercel los nombres exactos (`WHATSAPP_TEMPLATE_*`) y redeploy.

### Ticket digital en el mismo mensaje (URL `/r/{token}`)

1. Ejecuta en Supabase: `sql/patch_recibos_ticket_whatsapp.sql` (columna `recibo_token`).
2. En Vercel: `PUBLIC_SITE_URL=https://www.farmacapital.mx`
3. Al enviar WhatsApp (POS o pedido online), el servidor genera un token único y guarda la URL en el pedido.
4. La plantilla `pedido_confirmado` usa la variable **{{4}}** con el enlace, por ejemplo:  
   `Ver ticket: https://www.farmacapital.mx/r/550e8400-e29b-41d4-a716-446655440000`
5. El cliente abre `/r/{token}` (rewrite → `/api/health?token=…`) y ve el ticket HTML (mismo contenido que el ticket térmico).

**Opcional — botón «Ver ticket»** (un solo toque en WhatsApp):

- Crea plantilla con botón URL fija: `https://www.farmacapital.mx/r/{{1}}`
- En Vercel: `WHATSAPP_TEMPLATE_PEDIDO_URL_BUTTON=true`
- El sistema envía solo el UUID en el botón (más limpio que pegar URL en el cuerpo).

**Dónde se guarda:** columna `pedidos.recibo_token` en Supabase (no bucket PDF por ahora). El ticket se renderiza al vuelo desde los datos del pedido.

### Envío manual con plantilla

```bash
curl -sS -X POST "https://www.farmacapital.mx/api/whatsapp/send" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_WHATSAPP_INTERNAL_SECRET" \
  -d '{
    "to":"52XXXXXXXXXX",
    "template":"pedido_confirmado",
    "bodyParams":["#FC-0042","599.00","Pick-up en FarmaCapital","¡Gracias!"],
    "text":"Fallback texto libre si la plantilla falla"
  }'
```

## Notificaciones automáticas (pedidos / citas)

- Checkout → `/api/notifications/order-receipt` (evento `order_created`)
- Mercado Pago webhook → `payment_approved` / `pending` / `rejected`
- Citas → `/api/notifications/cita-confirmacion`

Opt-in checkout: `sql/patch_pedidos_whatsapp_recibo.sql` (columna `whatsapp_recibo`).

## Fase 3 (pendiente)

- Enlaces seguros en recibos, idempotencia, auditoría Supabase

## Reglas de negocio

- No migrar +52 55 6253 0631 hasta Embedded Signup / coexistencia
- Utility: confirmaciones de pedido/cita; Marketing: promociones
- Sin datos médicos sensibles en mensajes automáticos
