'use strict';

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
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

module.exports = async function handler(req, res) {
  if (!['POST', 'PUT'].includes(req.method)) {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
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

  const body = await safeJson(req);
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
