'use strict';
// Proxy seguro para MP Point Smart 2 (Orders API — reemplaza Payment Intent legacy).
// El Access Token nunca sale al frontend — se usa solo aquí en el servidor.
//
// Docs: https://www.mercadopago.com.mx/developers/en/docs/mp-point/migrate-payment-intent-to-orders

const crypto = require('crypto');

const MP_API = 'https://api.mercadopago.com';
const MP_DEVICES_LEGACY = `${MP_API}/point/integration-api/devices`;

function newIdempotencyKey() {
  return crypto.randomUUID();
}

function mpErrorMessage(data, fallbackStatus) {
  if (typeof data?.message === 'string' && data.message.trim()) return data.message;
  if (Array.isArray(data?.errors) && data.errors.length) {
    return data.errors.map((e) => e.message || e.code || JSON.stringify(e)).join(', ');
  }
  return `HTTP ${fallbackStatus}`;
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  if (!MP_ACCESS_TOKEN) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });

  // path: /api/payments/mp/point?action=devices|create-intent|get-intent|cancel-intent
  const { action, deviceId, intentId, orderId } = req.query;
  const body = req.method === 'POST' ? (typeof req.body === 'object' ? req.body : {}) : null;

  const mpHeaders = {
    Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
    'Content-Type': 'application/json',
  };

  try {
    let mpUrl;
    let mpMethod = 'GET';
    let mpBody;
    let extraHeaders = {};

    if (action === 'devices') {
      // Listado legacy sigue operativo; el terminal_id se usa en create-order.
      mpUrl = MP_DEVICES_LEGACY;

    } else if (action === 'create-intent') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const { amount, description, externalReference } = body || {};
      if (!amount || !Number.isFinite(Number(amount)) || Number(amount) <= 0) {
        return res.status(400).json({ ok: false, error: 'invalid_amount' });
      }

      mpUrl = `${MP_API}/v1/orders`;
      mpMethod = 'POST';
      extraHeaders['X-Idempotency-Key'] = newIdempotencyKey();
      mpBody = {
        type: 'point',
        external_reference: String(externalReference || `FC-${Date.now()}`).slice(0, 64),
        transactions: {
          payments: [{ amount: Number(amount).toFixed(2) }],
        },
        config: {
          point: {
            terminal_id: String(deviceId),
            print_on_terminal: 'seller_ticket',
          },
          payment_method: {
            default_type: 'credit_card',
          },
        },
        description: String(description || 'Venta FarmaCapital').slice(0, 255),
      };

    } else if (action === 'get-intent') {
      const oid = orderId || intentId;
      if (!oid) return res.status(400).json({ ok: false, error: 'missing_intentId' });
      mpUrl = `${MP_API}/v1/orders/${encodeURIComponent(String(oid))}`;

    } else if (action === 'cancel-intent') {
      const oid = orderId || intentId;
      if (!oid) return res.status(400).json({ ok: false, error: 'missing_intentId' });
      mpUrl = `${MP_API}/v1/orders/${encodeURIComponent(String(oid))}/cancel`;
      mpMethod = 'POST';
      extraHeaders['X-Idempotency-Key'] = newIdempotencyKey();
      mpBody = {};

    } else {
      return res.status(400).json({ ok: false, error: 'unknown_action' });
    }

    const mpResp = await fetch(mpUrl, {
      method: mpMethod,
      headers: { ...mpHeaders, ...extraHeaders },
      ...(mpBody != null ? { body: JSON.stringify(mpBody) } : {}),
    });

    const data = await mpResp.json().catch(() => ({}));

    if (!mpResp.ok) {
      return res.status(mpResp.status).json({
        ok: false,
        message: mpErrorMessage(data, mpResp.status),
        ...data,
      });
    }

    // Compatibilidad con frontend legacy (MercadoPagoModal espera `id` de la orden).
    if (action === 'create-intent' && data?.id) {
      return res.status(200).json({
        ok: true,
        id: data.id,
        order_id: data.id,
        status: data.status,
        status_detail: data.status_detail,
        ...data,
      });
    }

    return res.status(200).json({ ok: true, ...data });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'proxy_error', message: e?.message || 'unknown' });
  }
};
