'use strict';

const { ingestRappiOrder, isRappiWebhookAuthorized, rappiWebhookSecretConfigured } = require('../_lib/rappiIngest');
const {
  getUberDirectConfig,
  verifyUberWebhookSignature,
  extractUberWebhookDelivery,
  mapUberDeliveryStatus,
} = require('../_lib/uberDirect');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

function getQuery(req) {
  try {
    const q = req.query;
    if (q && typeof q === 'object' && !Array.isArray(q)) return q;
    const full = req.url || '';
    const qs = full.includes('?') ? full.split('?')[1] : '';
    return Object.fromEntries(new URLSearchParams(qs));
  } catch {
    return {};
  }
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

function mapDeliveryStatus(raw) {
  const s = String(raw || '').trim().toLowerCase();
  if (!s) return null;
  if (['ready_for_pickup', 'listo', 'ready'].includes(s)) return 'ready_for_pickup';
  if (['in_route', 'en_ruta', 'on_the_way', 'courier_picked_up'].includes(s)) return 'in_route';
  if (['delivered', 'entregado', 'completed'].includes(s)) return 'delivered';
  if (['cancelled', 'canceled', 'cancelado'].includes(s)) return 'cancelled';
  return s;
}

async function handleRappiOrder(req, res, body) {
  if (!rappiWebhookSecretConfigured()) {
    console.warn('[rappi-order] inerte: falta RAPPI_WEBHOOK_SECRET (o LOGISTICS_WEBHOOK_TOKEN)');
    return res.status(503).json({ ok: false, skipped: 'not_configured' });
  }
  const auth = isRappiWebhookAuthorized(req);
  if (!auth.ok) {
    return res.status(401).json({ ok: false, error: auth.reason });
  }
  const result = await ingestRappiOrder(body);
  const status = result.ok ? 200 : (result.error === 'payload_invalido' || result.error === 'falta_external_order_id' || result.error === 'sin_items' || result.error === 'item_invalido' || result.error === 'sku_no_existe' ? 400 : 502);
  return res.status(status).json(result);
}

function rawBodyForSignature(req, body) {
  if (typeof req.body === 'string') return req.body;
  if (Buffer.isBuffer(req.body)) return req.body.toString('utf8');
  try {
    return JSON.stringify(body || {});
  } catch {
    return '';
  }
}

async function findPedidoForUber(supabaseUrl, serviceKey, { deliveryId, externalId }) {
  const headers = {
    apikey: serviceKey,
    Authorization: `Bearer ${serviceKey}`,
  };
  const ext = String(externalId || '').replace(/\D/g, '');
  if (ext) {
    const byId = await fetch(
      `${supabaseUrl}/rest/v1/pedidos?id=eq.${Number(ext)}&select=id,estado,logistics_meta,delivery_status&limit=1`,
      { headers }
    );
    const rows = await byId.json().catch(() => []);
    if (byId.ok && Array.isArray(rows) && rows[0]) return rows[0];
  }
  if (deliveryId) {
    const byMeta = await fetch(
      `${supabaseUrl}/rest/v1/pedidos?logistics_meta->>external_delivery_id=eq.${encodeURIComponent(deliveryId)}&select=id,estado,logistics_meta,delivery_status&limit=1`,
      { headers }
    );
    const rows = await byMeta.json().catch(() => []);
    if (byMeta.ok && Array.isArray(rows) && rows[0]) return rows[0];
  }
  return null;
}

async function handleUberDirect(req, res, body) {
  const cfg = getUberDirectConfig();
  if (!cfg.webhookSecret) {
    console.warn('[uber-direct] inerte: falta UBER_DIRECT_WEBHOOK_SECRET');
    return res.status(503).json({ ok: false, skipped: 'not_configured' });
  }
  const sig = req.headers['x-uber-signature'] || req.headers['x-postmates-signature'] || '';
  const verified = verifyUberWebhookSignature(rawBodyForSignature(req, body), sig, cfg.webhookSecret);
  if (!verified.ok) {
    return res.status(401).json({ ok: false, error: verified.reason });
  }

  const SUPABASE_URL = normalizeSupabaseProjectUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  const ev = extractUberWebhookDelivery(body);
  const deliveryStatus = mapUberDeliveryStatus(ev.status);
  if (!deliveryStatus) {
    return res.status(200).json({ ok: true, ignored: 'no_status' });
  }

  const pedido = await findPedidoForUber(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, ev);
  if (!pedido) {
    return res.status(404).json({ ok: false, error: 'pedido_not_found' });
  }

  const prevMeta = pedido.logistics_meta && typeof pedido.logistics_meta === 'object' ? pedido.logistics_meta : {};
  const prevUber = prevMeta.uber_direct && typeof prevMeta.uber_direct === 'object' ? prevMeta.uber_direct : {};
  const trackingUrl = ev.trackingUrl || prevUber.tracking_url || null;
  const payload = {
    delivery_provider: 'uber_direct',
    delivery_status: deliveryStatus,
    delivery_tracking_url: trackingUrl ? String(trackingUrl).slice(0, 600) : null,
    logistics_meta: {
      ...prevMeta,
      logistics_provider: 'uber_direct',
      external_delivery_id: ev.deliveryId || prevMeta.external_delivery_id || null,
      tracking_url: trackingUrl,
      uber_direct: {
        ...prevUber,
        delivery_id: ev.deliveryId || prevUber.delivery_id || null,
        status: ev.status,
        tracking_url: trackingUrl,
        last_webhook_at: new Date().toISOString(),
      },
    },
  };
  if (deliveryStatus === 'delivered' && String(pedido.estado || '') === 'listo') {
    payload.estado = 'completado';
  }

  const patchResp = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedido.id}`, {
    method: 'PATCH',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
    },
    body: JSON.stringify(payload),
  });
  if (!patchResp.ok) {
    const { logistics_meta, ...rest } = payload;
    const retry = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedido.id}`, {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(rest),
    });
    if (!retry.ok) {
      let detail = null;
      try { detail = await retry.json(); } catch { detail = await retry.text(); }
      return res.status(502).json({ ok: false, error: 'supabase_update_failed', detail });
    }
  }

  return res.status(200).json({ ok: true, pedidoId: pedido.id, deliveryStatus, deliveryId: ev.deliveryId || null });
}

module.exports = async function handler(req, res) {
  if (!['POST', 'PUT'].includes(req.method)) {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const body = await safeJson(req);
  const type = String(getQuery(req).type || body?.type || '').toLowerCase();
  if (type === 'rappi-order' || type === 'rappi_order') {
    return handleRappiOrder(req, res, body);
  }
  const uberSig = req.headers['x-uber-signature'] || req.headers['x-postmates-signature'];
  if (type === 'uber-direct' || type === 'uber_direct' || type === 'uber' || uberSig) {
    return handleUberDirect(req, res, body);
  }

  const SUPABASE_URL = normalizeSupabaseProjectUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  const LOGISTICS_WEBHOOK_TOKEN = (process.env.LOGISTICS_WEBHOOK_TOKEN || '').trim();
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !LOGISTICS_WEBHOOK_TOKEN) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  const auth = String(req.headers.authorization || req.headers.Authorization || '');
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  if (!token || token !== LOGISTICS_WEBHOOK_TOKEN) {
    return res.status(401).json({ ok: false, error: 'invalid_token' });
  }

  const pedidoId = Number(body?.pedidoId || body?.pedido_id || body?.orderId);
  const provider = String(body?.provider || body?.courier || 'manual').toLowerCase();
  const deliveryStatus = mapDeliveryStatus(body?.status || body?.delivery_status);
  const trackingUrl = body?.trackingUrl || body?.tracking_url || null;

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }
  if (!deliveryStatus) {
    return res.status(400).json({ ok: false, error: 'invalid_delivery_status' });
  }

  const payload = {
    delivery_provider: provider,
    delivery_status: deliveryStatus,
    delivery_tracking_url: trackingUrl ? String(trackingUrl).slice(0, 600) : null,
    delivery_payload: {
      source: 'logistics_webhook',
      raw: body || {},
      updated_at: new Date().toISOString(),
    },
  };

  const patchResp = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
    method: 'PATCH',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=representation',
    },
    body: JSON.stringify(payload),
  });
  if (!patchResp.ok) {
    let detail = null;
    try { detail = await patchResp.json(); } catch { detail = await patchResp.text(); }
    return res.status(502).json({ ok: false, error: 'supabase_update_failed', detail });
  }

  return res.status(200).json({ ok: true, pedidoId, provider, deliveryStatus, trackingUrl: trackingUrl || null });
};
