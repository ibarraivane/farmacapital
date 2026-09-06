'use strict';

const { getSupabaseAdminConfig } = require('./supabaseAdmin');
const { applyRestrictiveCors } = require('./allowedOrigins');
const { validarSolicitudTienda, buildStaffEmail } = require('./solicitudTienda');

async function sendResendEmail({ to, subject, text }) {
  const RESEND_API_KEY = String(process.env.RESEND_API_KEY || '').trim();
  const from = String(process.env.NOTIFY_FROM_EMAIL || 'FarmaCapital <no-reply@farmacapital.mx>').trim();
  const recipients = Array.isArray(to) ? to.filter(Boolean) : [to].filter(Boolean);
  if (!RESEND_API_KEY || !recipients.length) {
    return { sent: false, reason: RESEND_API_KEY ? 'missing_to' : 'email_not_configured' };
  }
  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ from, to: recipients, subject, text }),
  });
  if (!resp.ok) {
    let detail = null;
    try { detail = await resp.json(); } catch { detail = await resp.text(); }
    return { sent: false, reason: 'email_provider_error', detail };
  }
  return { sent: true, to: recipients };
}

async function insertSolicitudTienda(supabaseUrl, serviceKey, value) {
  const payload = {
    texto: value.texto,
    cantidad: value.cantidad,
    urgencia: value.urgencia,
    tipo: 'no_catalogo',
    estado: 'pendiente',
    origen: 'tienda',
    notas: value.notas,
    cliente_nombre: value.cliente_nombre,
    cliente_telefono: value.cliente_telefono,
    cliente_email: value.cliente_email,
    direccion: value.direccion,
    pago_tipo: 'nada',
    anotado_por: null,
  };
  const resp = await fetch(`${supabaseUrl}/rest/v1/solicitudes_mostrador`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
    },
    body: JSON.stringify(payload),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data || '');
    return { ok: false, error: detail.slice(0, 240) };
  }
  const row = Array.isArray(data) ? data[0] : data;
  return { ok: true, id: row?.id ?? null };
}

async function handleSolicitudTienda(req, res, body) {
  applyRestrictiveCors(req, res);
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const parsed = validarSolicitudTienda(body);
  if (parsed.honeypot) {
    return res.status(200).json({ ok: true, ignored: true });
  }
  if (!parsed.ok) {
    return res.status(400).json({ ok: false, error: 'invalid_solicitud', fields: parsed.errors });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  let saved = { ok: false, id: null, error: null };
  if (supabaseUrl && serviceKey) {
    saved = await insertSolicitudTienda(supabaseUrl, serviceKey, parsed.value);
  } else {
    saved = { ok: false, id: null, error: 'missing_server_env' };
  }

  const mail = buildStaffEmail({ value: parsed.value, id: saved.id });
  const emailRes = await sendResendEmail(mail);

  if (!saved.ok && !emailRes.sent) {
    return res.status(502).json({
      ok: false,
      error: 'solicitud_not_delivered',
      saved: false,
      email: emailRes,
      db: saved.error || null,
    });
  }

  return res.status(200).json({
    ok: true,
    id: saved.id,
    saved: Boolean(saved.ok),
    email: emailRes,
  });
}

module.exports = {
  handleSolicitudTienda,
  sendResendEmail,
  insertSolicitudTienda,
};
