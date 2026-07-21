'use strict';
// Proxy seguro para MP Point Smart 2 (Orders API — reemplaza Payment Intent legacy).
// El Access Token nunca sale al frontend — se usa solo aquí en el servidor.
//
// Docs: https://www.mercadopago.com.mx/developers/en/docs/mp-point/migrate-payment-intent-to-orders

const crypto = require('crypto');

const MP_API = 'https://api.mercadopago.com';
const MP_DEVICES_LEGACY = `${MP_API}/point/integration-api/devices`;

const PENDING_ORDER_STATUSES = new Set(['created', 'at_terminal']);

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

function isQueuedTerminalConflict(status, data) {
  if (status !== 409) return false;
  const msg = mpErrorMessage(data, status).toLowerCase();
  return msg.includes('queued order') || msg.includes('already a queued');
}

function authHeaders(token, extra = {}) {
  return {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
    ...extra,
  };
}

async function mpJson(url, options) {
  const resp = await fetch(url, options);
  const data = await resp.json().catch(() => ({}));
  return { resp, data };
}

async function listPendingPointOrders(token, terminalId) {
  const end = new Date();
  const begin = new Date(end.getTime() - 48 * 60 * 60 * 1000);
  const params = new URLSearchParams({
    begin_date: begin.toISOString(),
    end_date: end.toISOString(),
    type: 'point',
    page_size: '50',
    sort_by: 'created_date',
    sort_order: 'desc',
  });

  const { resp, data } = await mpJson(`${MP_API}/v1/orders?${params}`, {
    method: 'GET',
    headers: authHeaders(token),
  });

  if (!resp.ok) return [];

  const rows = Array.isArray(data?.data) ? data.data : [];
  return rows.filter((order) => {
    const terminal = order?.config?.point?.terminal_id;
    const status = String(order?.status || '').toLowerCase();
    return terminal === terminalId && PENDING_ORDER_STATUSES.has(status);
  });
}

async function cancelPointOrder(token, orderId, status) {
  const attempt = async (withAtTerminalHeader) => {
    const extra = { 'X-Idempotency-Key': newIdempotencyKey() };
    if (withAtTerminalHeader) extra['x-allow-cancelable-status'] = 'at_terminal';
    const { resp } = await mpJson(`${MP_API}/v1/orders/${encodeURIComponent(orderId)}/cancel`, {
      method: 'POST',
      headers: authHeaders(token, extra),
      body: '{}',
    });
    return resp;
  };

  let resp = await attempt(String(status || '').toLowerCase() === 'at_terminal');
  if (resp.ok || resp.status === 409) return true;
  if (resp.status === 403 || resp.status === 409) {
    resp = await attempt(true);
  }
  return resp.ok || resp.status === 409;
}

async function clearTerminalQueue(token, terminalId) {
  const pending = await listPendingPointOrders(token, terminalId);
  let cleared = 0;
  for (const order of pending) {
    const ok = await cancelPointOrder(token, order.id, order.status);
    if (ok) cleared += 1;
  }
  return { cleared, pending: pending.length };
}

function buildCreateOrderBody(deviceId, amount, description, externalReference) {
  return {
    type: 'point',
    external_reference: String(externalReference || `FC-${Date.now()}`).slice(0, 64),
    expiration_time: 'PT16M',
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
}

async function createPointOrder(token, deviceId, body) {
  return mpJson(`${MP_API}/v1/orders`, {
    method: 'POST',
    headers: authHeaders(token, { 'X-Idempotency-Key': newIdempotencyKey() }),
    body: JSON.stringify(body),
  });
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  if (!MP_ACCESS_TOKEN) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });

  // path: /api/payments/mp/point?action=devices|create-intent|get-intent|cancel-intent|clear-terminal
  const { action, deviceId, intentId, orderId } = req.query;
  const body = req.method === 'POST' ? (typeof req.body === 'object' ? req.body : {}) : null;

  try {
    if (action === 'devices') {
      const { resp, data } = await mpJson(MP_DEVICES_LEGACY, {
        method: 'GET',
        headers: authHeaders(MP_ACCESS_TOKEN),
      });
      if (!resp.ok) {
        return res.status(resp.status).json({ ok: false, message: mpErrorMessage(data, resp.status), ...data });
      }
      return res.status(200).json({ ok: true, ...data });
    }

    if (action === 'clear-terminal') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const result = await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId));
      return res.status(200).json({ ok: true, ...result });
    }

    if (action === 'create-intent') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const { amount, description, externalReference } = body || {};
      if (!amount || !Number.isFinite(Number(amount)) || Number(amount) <= 0) {
        return res.status(400).json({ ok: false, error: 'invalid_amount' });
      }

      const orderBody = buildCreateOrderBody(deviceId, amount, description, externalReference);

      // Limpia cobros abandonados (p. ej. modal cerrado sin pagar).
      await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId));

      let { resp, data } = await createPointOrder(MP_ACCESS_TOKEN, deviceId, orderBody);

      if (isQueuedTerminalConflict(resp.status, data)) {
        await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId));
        ({ resp, data } = await createPointOrder(MP_ACCESS_TOKEN, deviceId, orderBody));
      }

      if (!resp.ok) {
        return res.status(resp.status).json({
          ok: false,
          message: mpErrorMessage(data, resp.status),
          ...data,
        });
      }

      return res.status(200).json({
        ok: true,
        id: data.id,
        order_id: data.id,
        status: data.status,
        status_detail: data.status_detail,
        ...data,
      });
    }

    if (action === 'get-intent') {
      const oid = orderId || intentId;
      if (!oid) return res.status(400).json({ ok: false, error: 'missing_intentId' });
      const { resp, data } = await mpJson(`${MP_API}/v1/orders/${encodeURIComponent(String(oid))}`, {
        method: 'GET',
        headers: authHeaders(MP_ACCESS_TOKEN),
      });
      if (!resp.ok) {
        return res.status(resp.status).json({ ok: false, message: mpErrorMessage(data, resp.status), ...data });
      }
      return res.status(200).json({ ok: true, ...data });
    }

    if (action === 'cancel-intent') {
      const oid = orderId || intentId;
      if (!oid) return res.status(400).json({ ok: false, error: 'missing_intentId' });

      const { resp: getResp, data: orderData } = await mpJson(
        `${MP_API}/v1/orders/${encodeURIComponent(String(oid))}`,
        { method: 'GET', headers: authHeaders(MP_ACCESS_TOKEN) }
      );

      const status = getResp.ok ? orderData?.status : 'created';
      const { resp, data } = await mpJson(
        `${MP_API}/v1/orders/${encodeURIComponent(String(oid))}/cancel`,
        {
          method: 'POST',
          headers: authHeaders(MP_ACCESS_TOKEN, {
            'X-Idempotency-Key': newIdempotencyKey(),
            ...(String(status).toLowerCase() === 'at_terminal'
              ? { 'x-allow-cancelable-status': 'at_terminal' }
              : {}),
          }),
          body: '{}',
        }
      );

      if (!resp.ok && resp.status !== 409) {
        return res.status(resp.status).json({ ok: false, message: mpErrorMessage(data, resp.status), ...data });
      }
      return res.status(200).json({ ok: true, ...data });
    }

    return res.status(400).json({ ok: false, error: 'unknown_action' });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'proxy_error', message: e?.message || 'unknown' });
  }
};
