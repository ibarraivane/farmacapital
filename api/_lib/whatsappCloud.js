'use strict';

const crypto = require('crypto');

/** Graph API — override con WHATSAPP_GRAPH_VERSION si Meta depreca la versión por defecto. */
const DEFAULT_GRAPH_VERSION = 'v21.0';

function trimEnv(name) {
  return String(process.env[name] || '').trim();
}

/**
 * Configuración desacoplada: cambiar token / Phone Number ID en Vercel
 * sin tocar la lógica de envío ni webhooks.
 */
function getWhatsAppCloudConfig() {
  const accessToken =
    trimEnv('WHATSAPP_ACCESS_TOKEN') || trimEnv('META_WHATSAPP_TOKEN');
  const phoneNumberId =
    trimEnv('WHATSAPP_PHONE_NUMBER_ID') || trimEnv('META_WHATSAPP_PHONE_ID');
  const businessAccountId =
    trimEnv('WHATSAPP_BUSINESS_ACCOUNT_ID') || trimEnv('META_WHATSAPP_BUSINESS_ACCOUNT_ID');
  const verifyToken = trimEnv('WHATSAPP_VERIFY_TOKEN');
  const appSecret =
    trimEnv('WHATSAPP_APP_SECRET') || trimEnv('META_APP_SECRET');
  const graphVersion = trimEnv('WHATSAPP_GRAPH_VERSION') || DEFAULT_GRAPH_VERSION;
  const internalSecret =
    trimEnv('WHATSAPP_INTERNAL_SECRET') || trimEnv('WHATSAPP_SEND_SECRET');

  return {
    accessToken,
    phoneNumberId,
    businessAccountId,
    verifyToken,
    appSecret,
    graphVersion,
    internalSecret,
    isConfigured: Boolean(accessToken && phoneNumberId),
  };
}

function resolveWhatsAppProvider() {
  const pref = trimEnv('WHATSAPP_PROVIDER').toLowerCase();
  if (pref === 'twilio') return 'twilio';
  if (pref === 'meta') return 'meta';
  const cfg = getWhatsAppCloudConfig();
  if (cfg.isConfigured) return 'meta';
  return 'twilio';
}

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

/**
 * Normaliza a E.164 sin '+' (formato que espera Meta Cloud API en `to`).
 * MX: 10 dígitos → 52XXXXXXXXXX
 * US Meta test: 11 dígitos empezando en 1
 */
function normalizePhoneE164(input, { defaultCountryCode = '52' } = {}) {
  let digits = digitsOnly(input);
  if (!digits) return null;

  if (digits.length === 10 && defaultCountryCode === '52') {
    digits = `52${digits}`;
  }

  if (digits.length === 11 && digits.startsWith('1')) {
    return digits;
  }

  if (digits.length === 12 && digits.startsWith('52')) {
    return digits;
  }

  if (digits.length >= 11 && digits.length <= 15) {
    return digits;
  }

  return null;
}

function redactPhone(e164) {
  const d = digitsOnly(e164);
  if (d.length < 4) return '***';
  return `***${d.slice(-4)}`;
}

function graphUrl(path, graphVersion) {
  const ver = graphVersion || getWhatsAppCloudConfig().graphVersion;
  const p = String(path || '').replace(/^\//, '');
  return `https://graph.facebook.com/${ver}/${p}`;
}

function sanitizeMetaError(detail) {
  if (!detail) return null;
  try {
    const raw = typeof detail === 'string' ? detail : JSON.stringify(detail);
    return raw
      .replace(/Bearer\s+[A-Za-z0-9._-]+/gi, 'Bearer ***')
      .replace(/"access_token"\s*:\s*"[^"]+"/gi, '"access_token":"***"')
      .slice(0, 500);
  } catch {
    return 'meta_error';
  }
}

/**
 * Envío de texto libre (solo dentro de ventana 24h o números de prueba Meta).
 * Fase 2+: plantillas Utility/Marketing vía sendWhatsAppTemplate().
 */
async function sendWhatsAppText({ to, text, phoneNumberId, accessToken, graphVersion } = {}) {
  const cfg = getWhatsAppCloudConfig();
  const token = accessToken || cfg.accessToken;
  const fromId = phoneNumberId || cfg.phoneNumberId;
  const bodyText = String(text || '').trim();

  if (!token || !fromId) {
    return { sent: false, reason: 'whatsapp_cloud_not_configured' };
  }
  if (!bodyText) {
    return { sent: false, reason: 'empty_message' };
  }

  const toE164 = normalizePhoneE164(to);
  if (!toE164) {
    return { sent: false, reason: 'invalid_phone' };
  }

  const resp = await fetch(graphUrl(`${encodeURIComponent(fromId)}/messages`, graphVersion), {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: toE164,
      type: 'text',
      text: { body: bodyText.slice(0, 4096) },
    }),
  });

  let data = null;
  try {
    data = await resp.json();
  } catch {
    data = null;
  }

  if (!resp.ok) {
    return {
      sent: false,
      reason: 'meta_provider_error',
      status: resp.status,
      detail: sanitizeMetaError(data),
    };
  }

  const messageId = data?.messages?.[0]?.id || null;
  return { sent: true, messageId, to: redactPhone(toE164) };
}

function verifyWebhookSubscribe(query, verifyToken) {
  const mode = String(query?.['hub.mode'] || query?.hub?.mode || '').trim();
  const token = String(query?.['hub.verify_token'] || query?.hub?.verify_token || '').trim();
  const challenge = query?.['hub.challenge'] ?? query?.hub?.challenge;

  if (mode !== 'subscribe') {
    return { ok: false, reason: 'invalid_mode' };
  }
  if (!verifyToken || token !== verifyToken) {
    return { ok: false, reason: 'invalid_verify_token' };
  }
  if (challenge == null || challenge === '') {
    return { ok: false, reason: 'missing_challenge' };
  }
  return { ok: true, challenge: String(challenge) };
}

function verifyMetaSignature(rawBody, signatureHeader, appSecret) {
  if (!appSecret) {
    return { ok: false, reason: 'missing_app_secret' };
  }
  const sig = String(signatureHeader || '').trim();
  if (!sig.startsWith('sha256=')) {
    return { ok: false, reason: 'missing_signature' };
  }

  const expected =
    'sha256=' + crypto.createHmac('sha256', appSecret).update(rawBody).digest('hex');

  try {
    const a = Buffer.from(sig, 'utf8');
    const b = Buffer.from(expected, 'utf8');
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      return { ok: false, reason: 'invalid_signature' };
    }
  } catch {
    return { ok: false, reason: 'invalid_signature' };
  }

  return { ok: true };
}

function parseWebhookPayload(body) {
  const events = [];
  if (!body || body.object !== 'whatsapp_business_account') {
    return events;
  }

  for (const entry of body.entry || []) {
    const wabaId = entry?.id || null;
    for (const change of entry.changes || []) {
      const value = change?.value || {};
      const phoneNumberId = value?.metadata?.phone_number_id || null;
      const field = change?.field || null;

      for (const msg of value.messages || []) {
        events.push({
          kind: 'message',
          wabaId,
          phoneNumberId,
          field,
          messageId: msg?.id || null,
          from: msg?.from ? redactPhone(msg.from) : null,
          type: msg?.type || null,
          timestamp: msg?.timestamp || null,
        });
      }

      for (const st of value.statuses || []) {
        events.push({
          kind: 'status',
          wabaId,
          phoneNumberId,
          field,
          messageId: st?.id || null,
          status: st?.status || null,
          recipient: st?.recipient_id ? redactPhone(st.recipient_id) : null,
          timestamp: st?.timestamp || null,
          errors: Array.isArray(st?.errors)
            ? st.errors.map((e) => ({
                code: e?.code ?? null,
                title: e?.title ?? null,
              }))
            : null,
        });
      }
    }
  }

  return events;
}

function logWebhookEvents(events) {
  for (const ev of events) {
    console.log('[whatsapp-webhook]', JSON.stringify(ev));
  }
}

function authorizeInternalSend(req, body) {
  const cfg = getWhatsAppCloudConfig();
  const auth = String(req.headers.authorization || req.headers.Authorization || '');
  const bearer = auth.replace(/^Bearer\s+/i, '').trim();

  if (cfg.internalSecret && bearer && bearer === cfg.internalSecret) {
    return { ok: true, via: 'internal_secret' };
  }

  const headerSecret = String(req.headers['x-whatsapp-internal-secret'] || '').trim();
  if (cfg.internalSecret && headerSecret && headerSecret === cfg.internalSecret) {
    return { ok: true, via: 'internal_header' };
  }

  return { ok: false, reason: 'unauthorized' };
}

module.exports = {
  DEFAULT_GRAPH_VERSION,
  getWhatsAppCloudConfig,
  resolveWhatsAppProvider,
  normalizePhoneE164,
  redactPhone,
  digitsOnly,
  graphUrl,
  sendWhatsAppText,
  verifyWebhookSubscribe,
  verifyMetaSignature,
  parseWebhookPayload,
  logWebhookEvents,
  authorizeInternalSend,
  sanitizeMetaError,
};
