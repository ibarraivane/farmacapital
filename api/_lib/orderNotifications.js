'use strict';

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

function formatMoneyMx(value) {
  const n = Number(value || 0);
  return Number.isFinite(n) ? n.toFixed(2) : '0.00';
}

function buildMessage({ event, pedido }) {
  const pedidoId = pedido?.id || '?';
  const total = formatMoneyMx(pedido?.total);
  const entrega = pedido?.tipo_entrega === 'envio' ? 'envio a domicilio' : 'pick-up en tienda';
  if (event === 'payment_approved') {
    return `Farmax: pago aprobado para pedido #${pedidoId}. Total $${total}. Te avisaremos cuando este listo.`;
  }
  if (event === 'payment_pending') {
    return `Farmax: pago en revision para pedido #${pedidoId}. Te notificaremos cuando cambie el estado.`;
  }
  if (event === 'payment_rejected') {
    return `Farmax: pago rechazado para pedido #${pedidoId}. Puedes reintentar desde Mis pedidos.`;
  }
  return `Farmax: pedido #${pedidoId} recibido (${entrega}). Total $${total}.`;
}

async function sendEmail({ to, subject, text }) {
  const RESEND_API_KEY = String(process.env.RESEND_API_KEY || '').trim();
  const from = String(process.env.NOTIFY_FROM_EMAIL || 'Farmax <no-reply@farmax.mx>').trim();
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
  const from = String(process.env.TWILIO_WHATSAPP_FROM || '').trim(); // e.g. whatsapp:+14155238886
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

async function sendOrderNotifications({ event, pedido, cliente }) {
  const msg = buildMessage({ event, pedido });
  const subject = event === 'payment_approved'
    ? `Pago aprobado Pedido #${pedido?.id || ''}`
    : `Actualizacion de Pedido #${pedido?.id || ''}`;
  const [emailRes, waRes] = await Promise.all([
    sendEmail({ to: cliente?.email || null, subject, text: msg }),
    sendWhatsapp({ to: cliente?.telefono || null, text: msg }),
  ]);
  return { ok: true, email: emailRes, whatsapp: waRes };
}

module.exports = { sendOrderNotifications };
