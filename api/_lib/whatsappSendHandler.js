'use strict';

const {
  sendWhatsAppText,
  normalizePhoneE164,
  authorizeInternalSend,
  getWhatsAppCloudConfig,
} = require('./whatsappCloud');
const { getSupabaseAdminConfig, validateEmployeeSession } = require('./supabaseAdmin');

async function authorizeSend(req, body) {
  const internal = authorizeInternalSend(req, body);
  if (internal.ok) return internal;

  const employeeToken = String(
    body?.employeeSessionToken ||
    body?.sessionTokenEmpleado ||
    req.headers['x-employee-session'] ||
    ''
  ).trim();

  if (employeeToken) {
    const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
    if (supabaseUrl && serviceKey) {
      const valid = await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken);
      if (valid) return { ok: true, via: 'employee_session' };
    }
  }

  return { ok: false, reason: 'unauthorized' };
}

async function handleWhatsAppManualSend(req, res, body) {
  const cfg = getWhatsAppCloudConfig();
  if (!cfg.isConfigured) {
    return res.status(503).json({ ok: false, error: 'whatsapp_cloud_not_configured' });
  }

  if (!cfg.internalSecret) {
    return res.status(503).json({
      ok: false,
      error: 'missing_whatsapp_internal_secret',
      hint: 'Crea WHATSAPP_INTERNAL_SECRET en Vercel (Sensitive) y redeploy.',
    });
  }

  const auth = await authorizeSend(req, body);
  if (!auth.ok) {
    return res.status(401).json({ ok: false, error: auth.reason || 'unauthorized' });
  }

  const to = body?.to ?? body?.telefono ?? body?.phone;
  const text = body?.text ?? body?.message ?? body?.body;

  if (!to) {
    return res.status(400).json({ ok: false, error: 'missing_to' });
  }
  if (!String(text || '').trim()) {
    return res.status(400).json({ ok: false, error: 'missing_text' });
  }

  const normalized = normalizePhoneE164(to);
  if (!normalized) {
    return res.status(400).json({ ok: false, error: 'invalid_phone' });
  }

  const phoneNumberId = body?.phoneNumberId || body?.phone_number_id || null;
  const result = await sendWhatsAppText({
    to: normalized,
    text,
    phoneNumberId: phoneNumberId || undefined,
  });

  if (!result.sent) {
    const status = result.reason === 'meta_provider_error' ? 502 : 400;
    return res.status(status).json({
      ok: false,
      error: result.reason,
      status: result.status || undefined,
      detail: result.detail || undefined,
    });
  }

  return res.status(200).json({
    ok: true,
    sent: true,
    messageId: result.messageId || null,
    to: result.to,
    via: auth.via,
  });
}

module.exports = { handleWhatsAppManualSend };
