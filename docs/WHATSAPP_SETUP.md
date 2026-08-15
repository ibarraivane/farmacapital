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
```

Compatibilidad legacy (opcional): `META_WHATSAPP_TOKEN`, `META_WHATSAPP_PHONE_ID`, `META_APP_SECRET`.

**No uses** prefijo `REACT_APP_` ni `NEXT_PUBLIC_` para secretos.

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
3. **URL de devolución de llamada:** `https://farmacapital.mx/api/webhooks/whatsapp`
4. **Token de verificación:** el mismo valor que `WHATSAPP_VERIFY_TOKEN` en Vercel
5. Clic **Verificar y guardar**

Si falla: revisa Vercel Logs de la función; errores comunes `invalid_verify_token`, `missing_verify_token_env`.

### Pantalla 2 — Suscribir campos

1. En la misma sección, **Administrar** suscripciones del webhook
2. Suscríbete al WABA **FarmaCapital** (`2277703916307084`)
3. Activa el campo **`messages`** (incluye mensajes entrantes y estados de entrega)

### Pantalla 3 — Prueba entrante

1. Desde un número registrado como tester en Meta, envía un WhatsApp al **+1 555-342-4819**
2. Vercel → Deployments → Functions → `/api/webhooks/whatsapp` → Logs
3. Debes ver líneas `[whatsapp-webhook]` con `kind: "message"` o `kind: "status"`

## Envío manual de prueba (Fase 1)

```bash
curl -sS -X POST "https://farmacapital.mx/api/whatsapp/send" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_WHATSAPP_INTERNAL_SECRET" \
  -d '{"to":"52XXXXXXXXXX","text":"Prueba FarmaCapital API"}'
```

Sustituye el teléfono por un número autorizado en Meta (modo desarrollo).

## Notificaciones existentes (pedidos / citas)

Siguen usando `api/_lib/orderNotifications.js` → `sendWhatsAppText()` cuando `WHATSAPP_PROVIDER=meta` o hay `WHATSAPP_ACCESS_TOKEN`.

Opt-in checkout: columna `pedidos.whatsapp_recibo` (`sql/patch_pedidos_whatsapp_recibo.sql`).

## Fases posteriores (no implementadas aún)

- **Fase 2:** pedidos, citas, recibos con enlace seguro
- **Fase 3:** plantillas Utility/Marketing, idempotencia, auditoría en Supabase

## Reglas de negocio

- No migrar +52 55 6253 0631 hasta Embedded Signup / coexistencia
- Utility: confirmaciones de pedido/cita; Marketing: promociones
- Sin datos médicos sensibles en mensajes automáticos
