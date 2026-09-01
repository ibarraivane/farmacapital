/**
 * FARMACAPITAL — Health check + puente webhook WhatsApp (rewrite /api/webhooks/whatsapp)
 */

'use strict';

const { whatsappWebhookHandler } = require('./_lib/whatsappWebhookHandler');
const {
  authorizeInternalSend,
  diagnoseWhatsAppTemplates,
} = require('./_lib/whatsappCloud');
const { getSupabaseAdminConfig } = require('./_lib/supabaseAdmin');
const { stripeWebhookHandler } = require('./_lib/stripeWebhookHandler');
const {
  fetchPedidoByReciboToken,
  generateReciboHTML,
  buildReciboPublicUrl,
} = require('./_lib/receiptTicket');

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

/** GET /api/health?token=… o rewrite /r/:token — ticket digital público. */
async function handleReciboView(req, res) {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.setHeader('Allow', 'GET, HEAD');
    return res.status(405).send('Method not allowed');
  }

  const token = String(req.query?.token || '').trim();
  if (!token || token.length < 8 || token.length > 64) {
    return res.status(400).send('Enlace de ticket inválido');
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(503).send('Servicio no disponible');
  }

  let pedido = null;
  try {
    pedido = await fetchPedidoByReciboToken(supabaseUrl, serviceKey, token);
  } catch (e) {
    console.warn('[health:recibo] fetch:', e?.message);
  }

  if (!pedido) {
    return res.status(404).send('Ticket no encontrado o enlace expirado');
  }

  const ticketUrl = buildReciboPublicUrl(token);
  const html = generateReciboHTML({ pedido, ticketUrl });

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'private, max-age=300');
  if (req.method === 'HEAD') {
    return res.status(200).end();
  }
  return res.status(200).send(html);
}

async function handler(req, res) {
  const hubMode = req.query?.['hub.mode'];
  const hasMetaSignature =
    req.headers['x-hub-signature-256'] || req.headers['X-Hub-Signature-256'];

  // Stripe Apple/Google Pay webhook (rewrite /api/payments/stripe/webhook).
  // health.js ya tiene bodyParser:false — necesario para verificar la firma.
  const stripeType = String(req.query?.type || req.query?.provider || '').toLowerCase();
  if (req.method === 'POST' && (stripeType === 'stripe-webhook' || stripeType === 'stripe')) {
    return stripeWebhookHandler(req, res);
  }

  if (hubMode || (req.method === 'POST' && hasMetaSignature)) {
    return whatsappWebhookHandler(req, res);
  }

  if (req.query?.token && (req.method === 'GET' || req.method === 'HEAD')) {
    return handleReciboView(req, res);
  }

  if (req.query?.whatsapp === 'diag' && req.method === 'GET') {
    const auth = authorizeInternalSend(req, {});
    if (!auth.ok) {
      return res.status(403).json({ ok: false, error: 'forbidden' });
    }
    try {
      const diag = await diagnoseWhatsAppTemplates();
      return res.status(200).json(diag);
    } catch (e) {
      return res.status(500).json({ ok: false, error: e?.message || 'diag_failed' });
    }
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
