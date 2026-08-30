'use strict';

const { getSupabaseAdminConfig, rpc } = require('./supabaseAdmin');

function asPositiveQty(value) {
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.trunc(n);
}

/** FARMACAPITALmt_eq-ult146 → eq-ult146 (el RPC busca case-insensitive). */
function skuInternoDesdeRappi(sku) {
  const raw = String(sku || '').trim();
  if (!raw) return '';
  const low = raw.toLowerCase();
  if (low.startsWith('farmacapitalmt_')) return raw.slice('FARMACAPITALmt_'.length);
  const mt = low.indexOf('mt_');
  if (mt >= 0 && mt <= 20) return raw.slice(mt + 3);
  return raw;
}

function itemFromUnknown(raw) {
  if (!raw || typeof raw !== 'object') return null;
  const sku = skuInternoDesdeRappi(raw.sku || raw.SKU || raw.product_sku || raw.sku_id);
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
    const doResolve = options.resolveSkus === true || (options.resolveSkus !== false && !options.rpcFn);
    const resolved = doResolve
      ? await resolveItemsSkus(normalized.order.items, cfg, options.fetchFn)
      : { items: normalized.order.items };
    const order = { ...normalized.order, items: resolved.items };
    const result = await rpcFn(
      cfg.serviceKey,
      cfg.supabaseUrl,
      'ingest_rappi_order',
      { p_payload: order }
    );
    if (result && result.ok === false) return result;
    const out = result && typeof result === 'object' ? result : { ok: true, result };
    const shouldNotify = options.notify === true || (options.notify !== false && !options.rpcFn);
    if (out.ok && !out.already_ingested && shouldNotify) {
      const { notifyRappiStaff } = options.notifyFn
        ? { notifyRappiStaff: options.notifyFn }
        : require('./rappiAlerta');
      try {
        out.alerta = await notifyRappiStaff({
          order,
          pedidoId: out.pedido_id,
          supabase: cfg,
        });
      } catch (alertErr) {
        out.alerta = { ok: false, error: String(alertErr.message || alertErr).slice(0, 200) };
      }
    }
    return out;
  } catch (err) {
    return { ok: false, error: String(err.message || err).slice(0, 300) };
  }
}

async function resolveItemsSkus(items, cfg, fetchFn = fetch) {
  const out = [];
  for (const item of items || []) {
    const sku = await resolveOneSku(item.sku, cfg, fetchFn);
    out.push({ sku: sku || item.sku, qty: item.qty });
  }
  return { items: out };
}

async function resolveOneSku(sku, cfg, fetchFn) {
  const raw = String(sku || '').trim();
  if (!raw || !cfg?.supabaseUrl || !cfg?.serviceKey) return raw;
  const tryVals = [raw];
  const stripped = skuInternoDesdeRappi(raw);
  if (stripped && stripped !== raw) tryVals.push(stripped);
  for (const val of tryVals) {
    const url = `${cfg.supabaseUrl}/rest/v1/productos?select=sku&sku=ilike.${encodeURIComponent(val)}&limit=1`;
    try {
      const resp = await fetchFn(url, {
        headers: {
          apikey: cfg.serviceKey,
          Authorization: `Bearer ${cfg.serviceKey}`,
        },
      });
      const rows = await resp.json().catch(() => []);
      if (Array.isArray(rows) && rows[0]?.sku) return rows[0].sku;
    } catch {
      /* seguir */
    }
  }
  return stripped || raw;
}

module.exports = {
  normalizeRappiInboundOrder,
  skuInternoDesdeRappi,
  rappiWebhookSecretConfigured,
  isRappiWebhookAuthorized,
  ingestRappiOrder,
};
