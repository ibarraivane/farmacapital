'use strict';

const { getSupabaseAdminConfig, rpc } = require('./supabaseAdmin');

function asPositiveQty(value) {
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.trunc(n);
}

function itemFromUnknown(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const sku = String(raw.sku || raw.SKU || raw.product_sku || raw.sku_id || '').trim();
  const qty = asPositiveQty(raw.qty ?? raw.quantity ?? raw.cantidad ?? raw.units);
  if (!sku || qty == null) return null;
  return { sku, qty };
}

function normalizeRappiInboundOrder(payload) {
  if (!payload || typeof payload !== 'object') {
    return { ok: false, error: 'payload_invalido' };
  }
  const externalOrderId = String(
    payload.external_order_id ||
      payload.order_id ||
      payload.id ||
      payload.rappi_order_id ||
      ''
  ).trim();
  if (!externalOrderId) {
    return { ok: false, error: 'falta_external_order_id' };
  }

  const rawItems = Array.isArray(payload.items)
    ? payload.items
    : Array.isArray(payload.products)
      ? payload.products
      : Array.isArray(payload.order_items)
        ? payload.order_items
        : [];
  const items = [];
  const seen = new Map();
  for (const raw of rawItems) {
    const item = itemFromUnknown(raw);
    if (!item) continue;
    seen.set(item.sku, (seen.get(item.sku) || 0) + item.qty);
  }
  for (const [sku, qty] of seen.entries()) {
    items.push({ sku, qty });
  }
  if (!items.length) {
    return { ok: false, error: 'sin_items' };
  }

  return {
    ok: true,
    order: {
      external_order_id: externalOrderId,
      store_id: payload.store_id || payload.storeId || null,
      items,
    },
  };
}

function rappiWebhookSecretConfigured() {
  return Boolean(
    String(process.env.RAPPI_WEBHOOK_SECRET || process.env.LOGISTICS_WEBHOOK_TOKEN || '').trim()
  );
}

function isRappiWebhookAuthorized(req) {
  const secret = String(
    process.env.RAPPI_WEBHOOK_SECRET || process.env.LOGISTICS_WEBHOOK_TOKEN || ''
  ).trim();
  if (!secret) return { ok: false, reason: 'not_configured' };
  const auth = String(req.headers.authorization || req.headers.Authorization || '');
  const token = auth.replace(/^Bearer\s+/i, '').trim();
  if (!token || token !== secret) return { ok: false, reason: 'invalid_token' };
  return { ok: true };
}

async function ingestRappiOrder(payload, options = {}) {
  const normalized = normalizeRappiInboundOrder(payload);
  if (!normalized.ok) return normalized;

  const cfg = options.supabase || getSupabaseAdminConfig();
  if (!cfg.supabaseUrl || !cfg.serviceKey) {
    return { ok: false, error: 'supabase_not_configured' };
  }

  const rpcFn = options.rpcFn || rpc;
  try {
    const result = await rpcFn(
      cfg.serviceKey,
      cfg.supabaseUrl,
      'ingest_rappi_order',
      { p_payload: normalized.order }
    );
    if (result && result.ok === false) return result;
    return result && typeof result === 'object' ? result : { ok: true, result };
  } catch (err) {
    return { ok: false, error: String(err.message || err).slice(0, 300) };
  }
}

module.exports = {
  normalizeRappiInboundOrder,
  rappiWebhookSecretConfigured,
  isRappiWebhookAuthorized,
  ingestRappiOrder,
};
