'use strict';

const { sendWhatsAppText } = require('./whatsappCloud');

function digitsOnly(value) {
  return String(value || '').replace(/\D/g, '');
}

function parseDestinos(raw) {
  return String(raw || '')
    .split(/[,;]+/)
    .map((s) => s.trim())
    .filter(Boolean);
}

function buildAlertaRappiTexto({ order, pedidoId } = {}) {
  const id = order?.external_order_id || '—';
  const items = Array.isArray(order?.items) ? order.items : [];
  const lineas = items.slice(0, 12).map((it) => `• ${it.sku} × ${it.qty}`).join('\n');
  const extra = items.length > 12 ? `\n… +${items.length - 12} ítems` : '';
  const ped = pedidoId ? ` · FarmaCapital #${pedidoId}` : '';
  return [
    `🛒 Pedido Rappi ${id}${ped}`,
    'Llegó un pedido. Revisá anaquel y aceptalo en Rappi Aliados.',
    lineas || '• (sin ítems)',
    extra,
  ].filter(Boolean).join('\n');
}

async function leerConfigAlertas(cfg, fetchFn = fetch) {
  const envWa = String(process.env.RAPPI_ALERTA_WHATSAPP || '').trim();
  const envMail = String(process.env.RAPPI_ALERTA_EMAIL || process.env.NOTIFY_RAPPI_EMAIL || '').trim();
  let wa = envWa;
  let mail = envMail;
  if (!cfg?.supabaseUrl || !cfg?.serviceKey) {
    return { whatsapp: parseDestinos(wa), emails: parseDestinos(mail) };
  }
  try {
    const url = `${cfg.supabaseUrl}/rest/v1/configuracion?clave=in.(rappi_alerta_whatsapp,rappi_alerta_email)&select=clave,valor`;
    const resp = await fetchFn(url, {
      headers: {
        apikey: cfg.serviceKey,
        Authorization: `Bearer ${cfg.serviceKey}`,
      },
    });
    const rows = await resp.json().catch(() => []);
    for (const row of Array.isArray(rows) ? rows : []) {
      if (row.clave === 'rappi_alerta_whatsapp' && String(row.valor || '').trim()) wa = row.valor;
      if (row.clave === 'rappi_alerta_email' && String(row.valor || '').trim()) mail = row.valor;
    }
  } catch {
    /* env */
  }
  return { whatsapp: parseDestinos(wa), emails: parseDestinos(mail) };
}

async function sendEmailSimple({ to, subject, text }) {
  const key = String(process.env.RESEND_API_KEY || '').trim();
  const from = String(process.env.NOTIFY_FROM_EMAIL || 'FarmaCapital <no-reply@farmacapital.mx>').trim();
  if (!key || !to) return { sent: false, reason: 'email_not_configured' };
  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from, to: [to], subject, text }),
  });
  if (!resp.ok) return { sent: false, reason: 'email_provider_error' };
  return { sent: true };
}

async function notifyRappiStaff({ order, pedidoId, supabase, fetchFn = fetch, sendWaFn, sendMailFn } = {}) {
  const dest = await leerConfigAlertas(supabase, fetchFn);
  const text = buildAlertaRappiTexto({ order, pedidoId });
  const subject = `Pedido Rappi ${order?.external_order_id || ''}`.trim();
  const waFn = sendWaFn || sendWhatsAppText;
  const mailFn = sendMailFn || sendEmailSimple;
  const whatsapp = [];
  const email = [];

  for (const to of dest.whatsapp) {
    if (digitsOnly(to).length < 10) continue;
    try {
      whatsapp.push(await waFn({ to, text }));
    } catch (err) {
      whatsapp.push({ sent: false, error: String(err.message || err).slice(0, 160) });
    }
  }
  for (const to of dest.emails) {
    if (!to.includes('@')) continue;
    try {
      email.push(await mailFn({ to, subject, text }));
    } catch (err) {
      email.push({ sent: false, error: String(err.message || err).slice(0, 160) });
    }
  }

  return {
    ok: whatsapp.some((r) => r.sent) || email.some((r) => r.sent),
    skipped: !dest.whatsapp.length && !dest.emails.length,
    whatsapp,
    email,
  };
}

module.exports = {
  parseDestinos,
  buildAlertaRappiTexto,
  leerConfigAlertas,
  notifyRappiStaff,
};
