'use strict';

const FARMACIA_WHATSAPP_DISPLAY = '55 6253 0631';
const FARMACIA_DIRECCION = 'Radiodifusora 100, Chinampac de Juárez, Iztapalapa, CDMX';

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

function formatMoneyMx(value) {
  const n = Number(value || 0);
  return Number.isFinite(n) ? n.toFixed(2) : '0.00';
}

function formatFolioOnline(pedidoId) {
  if (pedidoId == null) return null;
  return `#FC-${String(pedidoId).padStart(4, '0')}`;
}

function normalizeItems(items) {
  if (!Array.isArray(items)) return [];
  return items.map((i) => ({
    nombre: i?.nombre || i?.productos?.nombre || 'Producto',
    qty: Number(i?.qty ?? i?.cantidad ?? 1),
    precio: Number(i?.precio ?? i?.precio_unitario ?? 0),
  }));
}

function buildReceiptMessage({ event, pedido, items }) {
  const pedidoId = pedido?.id || '?';
  const folio = formatFolioOnline(pedidoId) || `#FC-${pedidoId}`;
  const total = formatMoneyMx(pedido?.total);
  const entrega = pedido?.tipo_entrega === 'envio' ? 'Envío a domicilio' : 'Pick-up en FarmaCapital';
  const lineItems = normalizeItems(items);
  const itemsTxt = lineItems.length
    ? lineItems.map((i) => `• ${i.nombre} ×${i.qty} = $${(i.precio * i.qty).toFixed(2)}`).join('\n')
    : null;

  if (event === 'payment_approved') {
    return (
      `🏥 FarmaCapital\n${FARMACIA_DIRECCION}\n\n` +
      `✅ Pago aprobado\n🔖 Folio: ${folio}\n` +
      (itemsTxt ? `${itemsTxt}\n\n` : '') +
      `💰 Total: $${total}\n📦 Entrega: ${entrega}\n\n` +
      `Te avisaremos cuando esté listo.\n📱 WhatsApp farmacia: ${FARMACIA_WHATSAPP_DISPLAY}`
    );
  }
  if (event === 'payment_pending') {
    return (
      `FarmaCapital: pago en revisión para pedido ${folio}. Total $${total}. ` +
      `Te notificaremos cuando cambie el estado. WhatsApp: ${FARMACIA_WHATSAPP_DISPLAY}`
    );
  }
  if (event === 'payment_rejected') {
    return (
      `FarmaCapital: pago rechazado para pedido ${folio}. ` +
      `Puedes reintentar desde Mis pedidos. WhatsApp: ${FARMACIA_WHATSAPP_DISPLAY}`
    );
  }

  const pickupNote =
    pedido?.tipo_entrega === 'recoger'
      ? `\n\nMuestra tu folio ${folio} o menciona tu teléfono al llegar.`
      : '\n\nTe contactamos para coordinar tu entrega.';

  return (
    `🏥 FarmaCapital\n${FARMACIA_DIRECCION}\n\n` +
    `✅ Pedido confirmado\n🔖 Folio: ${folio}\n` +
    (itemsTxt ? `${itemsTxt}\n\n` : '') +
    `💰 Total: $${total}\n📦 Entrega: ${entrega}` +
    pickupNote +
    `\n\n¡Gracias por tu preferencia!\n📱 WhatsApp farmacia: ${FARMACIA_WHATSAPP_DISPLAY}`
  );
}

function buildMessage({ event, pedido, items }) {
  return buildReceiptMessage({ event, pedido, items });
}

async function sendEmail({ to, subject, text }) {
  const RESEND_API_KEY = String(process.env.RESEND_API_KEY || '').trim();
  const from = String(process.env.NOTIFY_FROM_EMAIL || 'FarmaCapital <no-reply@farmacapital.mx>').trim();
  if (!RESEND_API_KEY || !to) return { sent: false, reason: 'email_not_configured' };
  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from, to: [to], subject, text }),
  });
  if (!resp.ok) {
    let detail = null;
    try { detail = await resp.json(); } catch { detail = await resp.text(); }
    return { sent: false, reason: 'email_provider_error', detail };
  }
  return { sent: true };
}

async function sendTwilioWhatsapp({ to, text }) {
  const sid = String(process.env.TWILIO_ACCOUNT_SID || '').trim();
  const token = String(process.env.TWILIO_AUTH_TOKEN || '').trim();
  const from = String(process.env.TWILIO_WHATSAPP_FROM || '').trim();
  if (!sid || !token || !from || !to) return { sent: false, reason: 'twilio_not_configured' };
  const toDigits = digitsOnly(to);
  if (!toDigits) return { sent: false, reason: 'invalid_phone' };

  const body = new URLSearchParams();
  body.set('From', from.startsWith('whatsapp:') ? from : `whatsapp:${from}`);
  body.set('To', `whatsapp:+52${toDigits}`);
  body.set('Body', text);

  const resp = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${encodeURIComponent(sid)}/Messages.json`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${Buffer.from(`${sid}:${token}`).toString('base64')}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body.toString(),
  });
  if (!resp.ok) {
    let detail = null;
    try { detail = await resp.json(); } catch { detail = await resp.text(); }
    return { sent: false, reason: 'twilio_provider_error', detail };
  }
  return { sent: true };
}

async function sendMetaWhatsapp({ to, text }) {
  const token = String(process.env.META_WHATSAPP_TOKEN || '').trim();
  const phoneId = String(process.env.META_WHATSAPP_PHONE_ID || '').trim();
  if (!token || !phoneId || !to) return { sent: false, reason: 'meta_not_configured' };
  const toDigits = digitsOnly(to);
  if (!toDigits) return { sent: false, reason: 'invalid_phone' };

  const resp = await fetch(`https://graph.facebook.com/v20.0/${encodeURIComponent(phoneId)}/messages`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: `52${toDigits}`,
      type: 'text',
      text: { body: text },
    }),
  });
  if (!resp.ok) {
    let detail = null;
    try { detail = await resp.json(); } catch { detail = await resp.text(); }
    return { sent: false, reason: 'meta_provider_error', detail };
  }
  return { sent: true };
}

async function sendWhatsapp({ to, text }) {
  const pref = String(process.env.WHATSAPP_PROVIDER || 'twilio').trim().toLowerCase();
  if (pref === 'meta') return sendMetaWhatsapp({ to, text });
  return sendTwilioWhatsapp({ to, text });
}

async function sendOrderNotifications({ event, pedido, cliente, items }) {
  const msg = buildReceiptMessage({ event, pedido, items });
  const subject = event === 'payment_approved'
    ? `Pago aprobado Pedido #${pedido?.id || ''}`
    : `Actualizacion de Pedido #${pedido?.id || ''}`;
  const [emailRes, waRes] = await Promise.all([
    sendEmail({ to: cliente?.email || null, subject, text: msg }),
    sendWhatsapp({ to: cliente?.telefono || null, text: msg }),
  ]);
  return { ok: true, email: emailRes, whatsapp: waRes };
}

module.exports = { sendOrderNotifications, sendWhatsapp, buildReceiptMessage, buildMessage };
