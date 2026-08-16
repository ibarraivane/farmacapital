'use strict';

const { FARMACIA_FISCAL } = require('./farmaciaFiscal');
const {
  sendWhatsAppSmart,
  getWhatsAppTemplateConfig,
  resolveWhatsAppProvider,
  digitsOnly,
} = require('./whatsappCloud');

const FARMACIA_WHATSAPP_DISPLAY = FARMACIA_FISCAL.telefono_display;
const FARMACIA_DIRECCION = FARMACIA_FISCAL.direccion_comercial;
const FARMACIA_MAPS_URL = FARMACIA_FISCAL.maps_url;

function formatMoneyMx(value) {
  const n = Number(value || 0);
  return Number.isFinite(n) ? n.toFixed(2) : '0.00';
}

function formatFolioOnline(pedidoId) {
  if (pedidoId == null) return null;
  return `#FC-${String(pedidoId).padStart(4, '0')}`;
}

function formatFolioPOS(pedidoId) {
  if (pedidoId == null) return null;
  return `VTA-${String(pedidoId).padStart(8, '0')}`;
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
    const pickupNote =
      pedido?.tipo_entrega === 'recoger'
        ? `\n\nMuestra tu folio ${folio} al llegar.\n📍 ${FARMACIA_MAPS_URL}`
        : '';
    return (
      `🏥 FarmaCapital\n${FARMACIA_DIRECCION}\n\n` +
      `✅ Pago aprobado\n🔖 Folio: ${folio}\n` +
      (itemsTxt ? `${itemsTxt}\n\n` : '') +
      `💰 Total: $${total}\n📦 Entrega: ${entrega}` +
      pickupNote +
      `\n\nTe avisaremos cuando esté listo.\n📱 WhatsApp farmacia: ${FARMACIA_WHATSAPP_DISPLAY}`
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
      ? `\n\nMuestra tu folio ${folio} o menciona tu teléfono al llegar.\n📍 ${FARMACIA_MAPS_URL}`
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

function formatCitaFecha(fecha) {
  if (!fecha) return '';
  try {
    const [y, m, d] = String(fecha).slice(0, 10).split('-').map(Number);
    if (!y || !m || !d) return String(fecha);
    const dt = new Date(y, m - 1, d);
    return dt.toLocaleDateString('es-MX', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
  } catch {
    return String(fecha);
  }
}

function buildCitaConfirmacionMessage({ nombre, fecha, hora, motivo, citaId }) {
  const folio = citaId != null ? `#CITA-${String(citaId).padStart(4, '0')}` : '';
  const fechaTxt = formatCitaFecha(fecha);
  const motivoLine = motivo && String(motivo).trim() ? `Motivo: ${String(motivo).trim()}\n\n` : '';
  const saludo = nombre && String(nombre).trim() ? ` ${String(nombre).trim()}` : '';
  return (
    `📅 *Cita confirmada en FarmaCapital*\n\n` +
    `Hola${saludo}! Tu cita médica ha sido registrada.\n\n` +
    (folio ? `🔖 Folio: ${folio}\n` : '') +
    `🗓 Fecha: ${fechaTxt || fecha}\n` +
    `🕐 Hora: ${hora}\n` +
    `👩‍⚕️ Médico general\n` +
    `📍 ${FARMACIA_DIRECCION}\n` +
    `🗺 ${FARMACIA_MAPS_URL}\n\n` +
    motivoLine +
    `💊 Al terminar tu consulta, surte tu receta en FarmaCapital con 10% de descuento.\n\n` +
    `Te enviaremos un recordatorio 24 hrs antes.\n` +
    `📱 Dudas: ${FARMACIA_WHATSAPP_DISPLAY}\n\n` +
    `¡Te esperamos! 🏥`
  );
}

function resolveOrderEventTemplate(event) {
  const tpl = getWhatsAppTemplateConfig();
  const ev = String(event || 'order_created').trim();
  if (ev === 'payment_pending' || ev === 'payment_rejected') {
    return '';
  }
  if (ev === 'payment_approved') {
    return tpl.pedidoPago || tpl.pedidoConfirmado || '';
  }
  if (ev === 'order_ready') {
    return tpl.pedidoListo || '';
  }
  return tpl.pedidoConfirmado || '';
}

function resolveCitaTemplate() {
  return getWhatsAppTemplateConfig().citaConfirmacion || '';
}

function buildOrderTemplateBodyParams({ event, pedido }) {
  const folio = formatFolioOnline(pedido?.id) || `#FC-${pedido?.id || '?'}`;
  const total = formatMoneyMx(pedido?.total);
  const entrega =
    pedido?.tipo_entrega === 'envio' ? 'Envío a domicilio' : 'Pick-up en FarmaCapital';

  if (event === 'order_ready') {
    const note =
      pedido?.tipo_entrega === 'recoger'
        ? `Recógelo en mostrador. Mapa: ${FARMACIA_MAPS_URL}`
        : 'Te contactamos para coordinar la entrega.';
    return [folio, note];
  }

  let note = '¡Gracias por tu preferencia!';
  if (event === 'payment_approved') {
    note = 'Te avisaremos cuando esté listo.';
  } else if (pedido?.tipo_entrega === 'recoger') {
    note = `Muestra tu folio al llegar. Mapa: ${FARMACIA_MAPS_URL}`;
  } else {
    note = 'Te contactamos para coordinar tu entrega.';
  }

  return [folio, total, entrega, note];
}

function buildCitaTemplateBodyParams({ nombre, fecha, hora }) {
  const nombreTxt = nombre && String(nombre).trim() ? String(nombre).trim() : 'Cliente';
  const fechaTxt = formatCitaFecha(fecha) || String(fecha || '');
  const horaTxt = String(hora || '');
  return [nombreTxt, fechaTxt, horaTxt, FARMACIA_DIRECCION];
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

async function sendMetaWhatsapp({
  to,
  text,
  templateName,
  bodyParameters,
  templateLanguage,
  allowTextFallback,
}) {
  if (!to) return { sent: false, reason: 'invalid_phone' };
  return sendWhatsAppSmart({
    to,
    text,
    templateName,
    bodyParameters,
    templateLanguage,
    allowTextFallback,
  });
}

async function sendWhatsapp({
  to,
  text,
  templateName,
  bodyParameters,
  templateLanguage,
  allowTextFallback = false,
}) {
  const provider = resolveWhatsAppProvider();
  if (provider === 'meta') {
    return sendMetaWhatsapp({
      to,
      text,
      templateName,
      bodyParameters,
      templateLanguage,
      allowTextFallback,
    });
  }
  return sendTwilioWhatsapp({ to, text });
}

function pedidoQuiereWhatsAppRecibo(pedido) {
  if (pedido?.whatsapp_recibo === true) return true;
  if (pedido?.whatsapp_recibo === false) return false;
  const meta = pedido?.logistics_meta;
  if (meta && typeof meta === 'object') {
    if (meta.whatsapp_recibo === true) return true;
    if (meta.whatsapp_recibo === false) return false;
  }
  return false;
}

function buildPosTicketMessage({ pedido, items, metodoPago, puntosGanados, saldoPuntos }) {
  const folio = formatFolioPOS(pedido?.id) || `#${pedido?.id || '?'}`;
  const lineItems = normalizeItems(items);
  const itemsTxt = lineItems.length
    ? lineItems.map((i) => `• ${i.nombre} ×${i.qty} = $${(i.precio * i.qty).toFixed(2)}`).join('\n')
    : '• (sin detalle)';
  const total = formatMoneyMx(pedido?.total);
  const pago = String(metodoPago || pedido?.metodo_pago || '—').replace(/_/g, ' ');
  let msg =
    `🏥 FarmaCapital\n${FARMACIA_DIRECCION}\n🗺 ${FARMACIA_MAPS_URL}\n\n` +
    `🧾 Ticket de compra\n🔖 Folio: ${folio}\n\n` +
    `${itemsTxt}\n\n` +
    `💰 Total: $${total}\n` +
    `💳 Pago: ${pago}`;
  if (puntosGanados != null && Number(puntosGanados) > 0) {
    msg += `\n\n⭐ +${puntosGanados} puntos FarmaCapital`;
    if (saldoPuntos != null) msg += `\nSaldo: ${saldoPuntos} pts`;
  }
  msg += '\n\n¡Gracias por su preferencia! 💊';
  return msg;
}

function buildPosTicketTemplateBodyParams({ pedido, puntosGanados, saldoPuntos }) {
  const folio = formatFolioPOS(pedido?.id) || `#${pedido?.id || '?'}`;
  const total = formatMoneyMx(pedido?.total);
  const entrega = 'Venta en mostrador FarmaCapital';
  let note = '¡Gracias por su preferencia!';
  if (puntosGanados != null && Number(puntosGanados) > 0) {
    note = `+${puntosGanados} pts FarmaCapital`;
    if (saldoPuntos != null) note += `. Saldo: ${saldoPuntos} pts`;
  }
  return [folio, total, entrega, note];
}

async function sendPosTicketNotification({
  telefono,
  pedido,
  items,
  metodoPago,
  puntosGanados = null,
  saldoPuntos = null,
}) {
  if (!telefono) return { sent: false, reason: 'missing_phone' };
  const text = buildPosTicketMessage({
    pedido,
    items,
    metodoPago,
    puntosGanados,
    saldoPuntos,
  });
  const tpl = getWhatsAppTemplateConfig();
  const templateName = tpl.pedidoConfirmado || '';
  const bodyParameters = templateName
    ? buildPosTicketTemplateBodyParams({ pedido, puntosGanados, saldoPuntos })
    : undefined;
  return sendWhatsapp({
    to: telefono,
    text,
    templateName: templateName || undefined,
    bodyParameters,
    allowTextFallback: false,
  });
}

async function sendOrderNotifications({ event, pedido, cliente, items }) {
  const msg = buildReceiptMessage({ event, pedido, items });
  const templateName = resolveOrderEventTemplate(event);
  const bodyParameters = templateName
    ? buildOrderTemplateBodyParams({ event, pedido, items, cliente })
    : undefined;
  const subject = event === 'payment_approved'
    ? `Pago aprobado Pedido #${pedido?.id || ''}`
    : `Actualizacion de Pedido #${pedido?.id || ''}`;
  const waPromise = pedidoQuiereWhatsAppRecibo(pedido)
    ? sendWhatsapp({
        to: cliente?.telefono || null,
        text: msg,
        templateName: templateName || undefined,
        bodyParameters,
        allowTextFallback: false,
      })
    : Promise.resolve({ sent: false, reason: 'whatsapp_opt_out' });
  const [emailRes, waRes] = await Promise.all([
    sendEmail({ to: cliente?.email || null, subject, text: msg }),
    waPromise,
  ]);
  return { ok: true, email: emailRes, whatsapp: waRes };
}

module.exports = {
  sendOrderNotifications,
  sendPosTicketNotification,
  sendWhatsapp,
  buildReceiptMessage,
  buildPosTicketMessage,
  buildMessage,
  buildCitaConfirmacionMessage,
  buildOrderTemplateBodyParams,
  buildPosTicketTemplateBodyParams,
  buildCitaTemplateBodyParams,
  resolveOrderEventTemplate,
  resolveCitaTemplate,
  pedidoQuiereWhatsAppRecibo,
};
