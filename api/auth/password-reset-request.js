'use strict';

/**
 * Auth tienda — un solo Serverless Function (Hobby máx. 12):
 * - POST /api/auth/password-reset-request
 * - POST /api/auth/oauth-bridge  (rewrite → ?type=oauth-bridge)
 */

const oauthBridgeHandler = require('../_lib/oauthBridgeHandler');
const { sendWhatsapp } = require('../_lib/orderNotifications');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

function siteOrigin() {
  const raw = String(
    process.env.PUBLIC_SITE_URL ||
      process.env.REACT_APP_SITE_URL ||
      'https://www.farmacapital.mx'
  ).trim();
  return raw.replace(/\/+$/g, '');
}

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

async function rpc(serviceKey, supabaseUrl, fn, payload) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });
  const data = await resp.json().catch(() => ({}));
  if (!resp.ok) {
    const detail = typeof data === 'object' ? JSON.stringify(data) : String(data);
    throw new Error(`${fn}_failed:${resp.status}:${detail.slice(0, 200)}`);
  }
  return data;
}

function requestType(req) {
  const q = String(req?.query?.type || req?.query?.action || '').trim().toLowerCase();
  if (q) return q;
  try {
    const url = new URL(req.url || '', 'http://localhost');
    return String(url.searchParams.get('type') || url.searchParams.get('action') || '')
      .trim()
      .toLowerCase();
  } catch {
    return '';
  }
}

module.exports = async function handler(req, res) {
  const type = requestType(req);
  if (type === 'oauth-bridge' || type === 'oauth') {
    return oauthBridgeHandler(req, res);
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const SUPABASE_URL = normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || ''
  );
  const SERVICE_KEY = String(process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  if (!SUPABASE_URL || !SERVICE_KEY) {
    return res.status(500).json({ ok: false, error: 'server_not_configured' });
  }

  const body = await safeJson(req);
  const identificador = String(body?.identificador || body?.p_identificador || '').trim();
  if (!identificador) {
    return res.status(400).json({ ok: false, error: 'missing_identificador' });
  }

  try {
    const result = await rpc(SERVICE_KEY, SUPABASE_URL, 'service_iniciar_reset_password', {
      p_identificador: identificador,
      p_ip: String(body?.ip || req.headers['x-forwarded-for'] || '').split(',')[0].trim() || null,
    });

    let whatsapp = { sent: false, reason: 'not_found_or_rate_limited' };
    if (result?.found && result?.token) {
      const resetUrl = `${siteOrigin()}/?reset=${encodeURIComponent(result.token)}`;
      const tel = String(result.telefono || identificador).replace(/\D/g, '');
      const msg =
        `🔐 *FarmaCapital — Restablecer contraseña*\n\n` +
        `Recibimos tu solicitud para la tienda en línea.\n\n` +
        `Toca el enlace (válido 2 horas) para crear tu nueva contraseña:\n${resetUrl}\n\n` +
        `Si no la pediste, ignora este mensaje.`;

      if (tel.length >= 10) {
        whatsapp = await sendWhatsapp({ to: tel, text: msg });
      } else {
        whatsapp = { sent: false, reason: 'no_phone_on_account' };
      }
    }

    return res.status(200).json({
      ok: true,
      message:
        'Si tu correo o teléfono está registrado, recibirás un enlace por WhatsApp en unos minutos.',
    });
  } catch (e) {
    console.error('[password-reset-request]', e);
    return res.status(502).json({ ok: false, error: 'reset_request_failed' });
  }
};
