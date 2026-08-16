# WhatsApp Meta — snapshot FarmaCapital (ago 2026)

> **Referencia congelada** a partir de capturas del panel Meta + WhatsApp Manager (Ivan, 16-ago-2026).  
> No volver a pedir estos datos al usuario; actualizar este archivo si cambian en Meta/Vercel.

## App y links directos

| Qué | Link |
|-----|------|
| Apps Meta | https://developers.facebook.com/apps/ → **FarmaCapital** → WhatsApp → **API Setup** |
| Plantillas | https://business.facebook.com/wa/manage/message-templates/ |
| Env Vercel | https://vercel.com/ibarraivane/farmacapital/settings/environment-variables |
| Deployments | https://vercel.com/ibarraivane/farmacapital/deployments |

## Modo Development — API Setup (captura 16-ago-2026)

| Campo | Valor |
|-------|--------|
| **Número de prueba Meta** | +1 (555) 670-7800 |
| **Phone number ID** | `1320112064512676` |
| **WhatsApp Business Account ID (WABA)** | `1575449287233472` |
| **Access token** | `EAA…` (rotar en API Setup; **no documentar** en git) |

### Vercel — variables obligatorias (Production)

```env
WHATSAPP_ACCESS_TOKEN=EAA…                    # Generate access token (caduca ~24 h si es temporal)
WHATSAPP_PHONE_NUMBER_ID=1320112064512676
WHATSAPP_BUSINESS_ACCOUNT_ID=1575449287233472
WHATSAPP_VERIFY_TOKEN=…
WHATSAPP_APP_SECRET=…
SUPABASE_SERVICE_ROLE_KEY=…
PUBLIC_SITE_URL=https://www.farmacapital.mx
```

**No hace falta** (defaults en `api/_lib/whatsappCloud.js` desde `fb5e0b4`):

- `WHATSAPP_TEMPLATE_PEDIDO_CONFIRMADO`
- `WHATSAPP_TEMPLATE_PEDIDO_PAGO`
- `WHATSAPP_TEMPLATE_PEDIDO_LISTO`
- `WHATSAPP_TEMPLATE_CITA`

**Evitar / borrar si existe:**

- `WHATSAPP_TEMPLATE_LANGUAGE=Spanish (MEX)` → provoca error **132001**; usar `es_MX` o borrar la variable.
- `WHATSAPP_TEMPLATE_PEDIDO_URL_BUTTON=true` → solo si la plantilla tiene botón URL en Meta.
- Duplicados: `META_WHATSAPP_TOKEN`, `META_WHATSAPP_PHONE_ID`, IDs viejos (`1338650695990173`, `2277703916307084`).

## Plantillas aprobadas (WhatsApp Manager — 4 activas)

Todas: categoría **Utilidad**, idioma **Spanish (MEX)** → API `es_MX`, estado **Activa** (calidad pendiente OK para pruebas), última edición **15-ago-2026**.

| Nombre exacto (API) | Uso en FarmaCapital | Variables cuerpo |
|---------------------|---------------------|------------------|
| `pedido_confirmado` | 📱 Transacciones / ticket POS (`sendPosTicketNotification`) | 4: folio, total, entrega, nota/ticket URL en {{4}} |
| `pedido_pago_aprobado` | Pago online aprobado (webhook MP) | 4: folio, total, entrega, detalle |
| `pedido_listo` | Pedido online listo (POS surte) | 2: folio, pase `/r/{token}` o seguimiento envío en {{2}} |
| `cita_confirmacion` | Confirmación de cita | 4: nombre, fecha, hora, dirección |

Lista UI trunca nombres largos (ej. `pedido_pago_aproba…`, `cita_confirmacion_co…`); los nombres API son los de la tabla.

### Cuerpo referencia `pedido_confirmado`

```
FarmaCapital — Pedido confirmado

Folio: {{1}}
Total: ${{2}}
Entrega: {{3}}

{{4}}
```

{{4}} en runtime: `Ver ticket: https://www.farmacapital.mx/r/{recibo_token}`

### Cuerpo referencia `pedido_pago_aprobado` (captura detalle)

- Encabezado: FarmaCapital — Pago aprobado  
- Cuerpo: mensaje fijo + Folio {{1}}, Total {{2}}, Entrega {{3}}, Detalle {{4}}  
- Sin botón URL (solo texto)

## Números de prueba Meta (Development)

Deben estar en API Setup → **Números de teléfono de prueba** (formato +52):

| Persona | Teléfono | Uso en panel |
|---------|----------|--------------|
| Ivan ibarra | +52 55 3727 5035 (`525537275035`) | Transacción #27, $16 |
| Luis palillero | +52 55 1612 4562 (`525516124562`) | Transacción #28, $143 |

Los mensajes de prueba llegan al WhatsApp del cliente desde **+1 555 670-7800**, no desde +52 FarmaCapital.

## Ticket digital

| Qué | Dónde |
|-----|--------|
| Token | `pedidos.recibo_token` (Supabase, patch `sql/patch_recibos_ticket_whatsapp.sql`) |
| URL pública | `https://www.farmacapital.mx/r/{token}` → rewrite `/api/health?token=…` |
| WhatsApp | Misma URL en variable {{4}} de `pedido_confirmado` |
| QR impreso | Misma URL (hook `usePedidoTicketUrl` → `/api/recibos/ensure` rewrite) |

## Errores vistos y causa

| Error | Causa | Fix |
|-------|--------|-----|
| Authentication Error | Token expirado o App Secret pegado como token | Regenerar token API Setup → Vercel |
| 132001 | Plantillas creadas en **WABA viejo** `2277703916307084` (WhatsApp Manager antiguo) pero el número de prueba usa **WABA** `1575449287233472` | Tras deploy: el toast dirá si detectó plantillas en el WABA viejo. **Solución:** en [WhatsApp Manager](https://business.facebook.com/wa/manage/message-templates/) selecciona WABA `1575449287233472` y crea de nuevo las 4 plantillas (`pedido_confirmado`, etc.) en **es_MX** |
| 131030 | Número cliente no en lista de prueba Meta | Agregar +52 en API Setup |
| 131047 | Texto libre fuera de ventana 24 h | Plantilla obligatoria; `WHATSAPP_TEMPLATE_FALLBACK_TEXT` no true |
| http_500 / FUNCTION_INVOCATION_FAILED | >12 funciones Vercel o syntax error deploy | Límite Hobby; recibos en `health` + `notifications/send` |

## Número comercial (futuro Live)

**+52 55 6253 0631** — app celular FarmaCapital; **no migrar** a Cloud API hasta Embedded Signup / coexistencia resuelta.
