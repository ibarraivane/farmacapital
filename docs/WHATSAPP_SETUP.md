# WhatsApp — FarmaCapital

Número oficial: **55 6253 0631** (`5562530631`).

## Qué hace hoy

| Canal | Comportamiento |
|-------|----------------|
| **Tienda web** | Botón flotante + footer/FAQ → abre chat con la farmacia |
| **Checkout online** | Checkbox opt-in: envía recibo por WhatsApp tras pago MP (webhook) |
| **POS mostrador** | Opcional: abre WhatsApp al cliente con ticket prellenado (manual) |
| **Citas** | Confirmación automática vía API |
| **Reset contraseña** | Enlace por WhatsApp vía API |

## Variables en Vercel (Production)

Ir a **Vercel → farmacapital → Settings → Environment Variables**:

### Opción A — Twilio (recomendado México)

```
WHATSAPP_PROVIDER=twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxx
TWILIO_WHATSAPP_FROM=whatsapp:+14155238886
```

En Twilio Console:
1. Activar **WhatsApp Sandbox** (pruebas) o **WhatsApp Sender** aprobado (producción).
2. El número `TWILIO_WHATSAPP_FROM` debe ser el remitente autorizado en Twilio.
3. Para sandbox, cada cliente debe enviar el código de join al número sandbox antes de recibir mensajes.

### Opción B — Meta Cloud API

```
WHATSAPP_PROVIDER=meta
META_WHATSAPP_TOKEN=xxxxxxxx
META_WHATSAPP_PHONE_ID=xxxxxxxx
```

### También necesarias (servidor)

```
SUPABASE_URL=https://qyabhoftqfmqwpqcsdrb.supabase.co
SUPABASE_SERVICE_ROLE_KEY=...
MP_ACCESS_TOKEN=...
MP_WEBHOOK_SECRET=...   (opcional pero recomendado)
```

## Migración Supabase (opt-in checkout)

Ejecutar en SQL Editor:

```
sql/patch_pedidos_whatsapp_recibo.sql
```

Agrega columna `pedidos.whatsapp_recibo` y extiende `cliente_crear_pedido_online` con `p_whatsapp_recibo`.

## Cómo verificar que Twilio está activo

1. **Vercel → Deployments → último deploy → Functions → Logs**
2. Hacer un pedido de prueba con checkbox WhatsApp activado.
3. Completar pago en MP (sandbox si aplica).
4. Buscar en logs del webhook `/api/payments/mp/webhook`:
   - `whatsapp: { sent: true }` → OK
   - `whatsapp: { sent: false, reason: 'twilio_not_configured' }` → faltan variables
   - `twilio_provider_error` → credenciales incorrectas o número no autorizado

También puedes probar manualmente:

```bash
curl -X POST https://www.farmacapital.mx/api/notifications/order-receipt \
  -H "Content-Type: application/json" \
  -d '{"pedidoId":123,"phoneVerify":"0631","event":"order_created"}'
```

(Usa un `pedidoId` real reciente y los últimos 4 dígitos del teléfono del pedido.)

## Pendientes futuros (no implementados)

- Recordatorio de cita 24 h antes (cron)
- WhatsApp automático pacientes crónicos (solo UI demo en admin)
- Opt-in persistente en perfil de cliente (hoy es por pedido)
