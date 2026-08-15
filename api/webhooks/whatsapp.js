'use strict';

const {
  getWhatsAppCloudConfig,
  verifyWebhookSubscribe,
  verifyMetaSignature,
  parseWebhookPayload,
  logWebhookEvents,
} = require('../_lib/whatsappCloud');
const { readRawBody } = require('../_lib/supabaseAdmin');

function safeJsonBuffer(raw) {
  try {
    return JSON.parse(raw.toString('utf8'));
  } catch {
    return null;
  }
}

async function handler(req, res) {
  const cfg = getWhatsAppCloudConfig();

  if (req.method === 'GET') {
    if (!cfg.verifyToken) {
      return res.status(503).json({ ok: false, error: 'missing_verify_token_env' });
    }

    const result = verifyWebhookSubscribe(req.query || {}, cfg.verifyToken);
    if (!result.ok) {
      return res.status(403).json({ ok: false, error: result.reason });
    }

    res.setHeader('Content-Type', 'text/plain');
    return res.status(200).send(result.challenge);
  }

  if (req.method === 'POST') {
    let rawBody;
    try {
      rawBody = await readRawBody(req);
    } catch (e) {
      console.warn('[whatsapp-webhook] read body:', e?.message || 'error');
      return res.status(400).json({ ok: false, error: 'invalid_body' });
    }

    const signature = req.headers['x-hub-signature-256'] || req.headers['X-Hub-Signature-256'];
    const sigCheck = verifyMetaSignature(rawBody, signature, cfg.appSecret);
    if (!sigCheck.ok) {
      console.warn('[whatsapp-webhook] signature rejected:', sigCheck.reason);
      return res.status(401).json({ ok: false, error: sigCheck.reason });
    }

    const body = safeJsonBuffer(rawBody);
    if (!body) {
      return res.status(400).json({ ok: false, error: 'invalid_json' });
    }

    const events = parseWebhookPayload(body);
    if (events.length) {
      logWebhookEvents(events);
    } else {
      console.log('[whatsapp-webhook]', JSON.stringify({ kind: 'noop', object: body.object || null }));
    }

    return res.status(200).json({ ok: true, received: events.length });
  }

  res.setHeader('Allow', 'GET, POST');
  return res.status(405).json({ ok: false, error: 'method_not_allowed' });
}

handler.config = {
  api: { bodyParser: false },
};

module.exports = handler;
