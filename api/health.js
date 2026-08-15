/**
 * FARMACAPITAL — Health check + puente webhook WhatsApp (rewrite /api/webhooks/whatsapp)
 */

'use strict';

const { whatsappWebhookHandler } = require('./_lib/whatsappWebhookHandler');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) {
    u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  }
  return u;
}

const SUPABASE_URL =
  normalizeSupabaseProjectUrl(
    process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL
  );
const SUPABASE_ANON_KEY =
  process.env.SUPABASE_ANON_KEY || process.env.REACT_APP_SUPABASE_ANON_KEY;

function sanitizeError(err) {
  const msg = (err && err.message) || String(err || 'unknown');
  return msg
    .replace(/postgres(?:ql)?:\/\/[^\s"']+/gi, 'postgres://***')
    .replace(/(key|token|secret|authorization)[:=]\s*[^\s"',]+/gi, '$1=***')
    .slice(0, 300);
}

async function handler(req, res) {
  const hubMode = req.query?.['hub.mode'];
  const hasMetaSignature =
    req.headers['x-hub-signature-256'] || req.headers['X-Hub-Signature-256'];

  if (hubMode || (req.method === 'POST' && hasMetaSignature)) {
    return whatsappWebhookHandler(req, res);
  }

  const startedAt = Date.now();

  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    res.status(500).json({
      ok: false,
      db: 'unknown',
      error: 'missing_supabase_env',
      ts: new Date().toISOString(),
    });
    return;
  }

  try {
    const url = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/productos?select=id&limit=1`;
    const resp = await fetch(url, {
      method: 'GET',
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        Accept: 'application/json',
      },
    });

    if (resp.status === 503 || resp.status === 504) {
      res.status(503).json({
        ok: false,
        db: 'down',
        status: resp.status,
        ms: Date.now() - startedAt,
        ts: new Date().toISOString(),
      });
      return;
    }

    res.status(200).json({
      ok: true,
      db: 'up',
      status: resp.status,
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
    });
  } catch (err) {
    res.status(503).json({
      ok: false,
      db: 'down',
      error: sanitizeError(err),
      ms: Date.now() - startedAt,
      ts: new Date().toISOString(),
    });
  }
}

handler.config = {
  api: { bodyParser: false },
};

module.exports = handler;
