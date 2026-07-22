'use strict';
// Proxy seguro para MP Point Smart 2 (Orders API — reemplaza Payment Intent legacy).
// El Access Token nunca sale al frontend — se usa solo aquí en el servidor.
//
// Docs: https://www.mercadopago.com.mx/developers/en/docs/mp-point/migrate-payment-intent-to-orders

const crypto = require('crypto');

const MP_API = 'https://api.mercadopago.com';
const MP_DEVICES_LEGACY = `${MP_API}/point/integration-api/devices`;

const PENDING_ORDER_STATUSES = new Set(['created', 'at_terminal']);
const STALE_CREATED_MS = 90 * 1000;

function orderAgeMs(order) {
  const raw = order?.created_date || order?.created_at;
  if (!raw) return Infinity;
  const t = Date.parse(raw);
  return Number.isFinite(t) ? Date.now() - t : Infinity;
}

function isStaleCreatedOrder(order) {
  return String(order?.status || '').toLowerCase() === 'created' && orderAgeMs(order) >= STALE_CREATED_MS;
}

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

async function clearTerminalQueue(token, terminalId, { onlyStaleCreated = true } = {}) {
  const pending = await listPendingPointOrders(token, terminalId);
  const atTerminal = pending.filter((o) => String(o?.status || '').toLowerCase() === 'at_terminal');
  if (atTerminal.length) {
    return { cleared: 0, pending: pending.length, blocked: true, at_terminal: atTerminal.map((o) => o.id) };
  }

  const toCancel = onlyStaleCreated
    ? pending.filter((o) => isStaleCreatedOrder(o))
    : pending.filter((o) => String(o?.status || '').toLowerCase() === 'created');

  let cleared = 0;
  const failures = [];
  for (const order of toCancel) {
    const ok = await cancelPointOrder(token, order.id, order.status);
    if (ok) cleared += 1;
    else failures.push({ id: order.id, status: order.status, external_reference: order.external_reference });
  }
  return { cleared, pending: pending.length, blocked: false, failures };
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

async function getDeviceOperatingMode(token, deviceId) {
  const { resp, data } = await mpJson(MP_DEVICES_LEGACY, {
    method: 'GET',
    headers: authHeaders(token),
  });
  if (!resp.ok) return null;
  const devices = Array.isArray(data?.devices) ? data.devices : [];
  const match = devices.find((d) => d?.id === deviceId);
  return match?.operating_mode || null;
}

async function setTerminalOperatingMode(token, deviceId, mode) {
  const { resp, data } = await mpJson(`${MP_API}/terminals/v1/setup`, {
    method: 'PATCH',
    headers: authHeaders(token),
    body: JSON.stringify({
      terminals: [{ id: String(deviceId), operating_mode: mode }],
    }),
  });
  return { ok: resp.ok, status: resp.status, data, message: mpErrorMessage(data, resp.status) };
}

async function setTerminalPdvMode(token, deviceId) {
  return setTerminalOperatingMode(token, deviceId, 'PDV');
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  if (!MP_ACCESS_TOKEN) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });

  // path: /api/payments/mp/point?action=devices|create-intent|get-intent|cancel-intent|clear-terminal|set-pdv
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

    if (action === 'reset-terminal') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const before = await getDeviceOperatingMode(MP_ACCESS_TOKEN, String(deviceId));
      const cleared = await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId), { onlyStaleCreated: false });
      const standalone = await setTerminalOperatingMode(MP_ACCESS_TOKEN, String(deviceId), 'STANDALONE');
      await new Promise((r) => setTimeout(r, 2000));
      const pdv = await setTerminalPdvMode(MP_ACCESS_TOKEN, String(deviceId));
      const pending = await listPendingPointOrders(MP_ACCESS_TOKEN, String(deviceId));
      return res.status(200).json({
        ok: pdv.ok,
        operating_mode_before: before,
        operating_mode_after: pdv.ok ? 'PDV' : before,
        cleared: cleared.cleared,
        pending_remaining: pending.length,
        pending_orders: pending.map((o) => o.id),
        restart_terminal_required: true,
        message:
          pending.length > 0
            ? `Modo PDV reactivado pero quedan ${pending.length} cobros atascados en Mercado Pago. Desvincula el lector en la app MP y contacta soporte MP con esos IDs.`
            : 'Terminal reseteada a PDV. Reinicia el Point Smart 2 y prueba un cobro.',
      });
    }

    if (action === 'list-pending') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const pending = await listPendingPointOrders(MP_ACCESS_TOKEN, String(deviceId));
      return res.status(200).json({
        ok: true,
        count: pending.length,
        orders: pending.map((o) => ({
          id: o.id,
          status: o.status,
          amount: o?.transactions?.payments?.[0]?.amount,
          external_reference: o.external_reference,
          created_date: o.created_date,
        })),
      });
    }

    if (action === 'clear-terminal') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const force = String(req.query.force || '').toLowerCase() === '1' || req.query.force === 'true';
      const result = await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId), {
        onlyStaleCreated: !force,
      });
      return res.status(200).json({ ok: true, force, ...result });
    }

    if (action === 'set-pdv') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const before = await getDeviceOperatingMode(MP_ACCESS_TOKEN, String(deviceId));
      const result = await setTerminalPdvMode(MP_ACCESS_TOKEN, String(deviceId));
      const after = result.ok ? 'PDV' : before;
      if (!result.ok) {
        return res.status(result.status || 500).json({
          ok: false,
          message: result.message,
          operating_mode_before: before,
          ...result.data,
        });
      }
      return res.status(200).json({
        ok: true,
        operating_mode_before: before,
        operating_mode_after: after,
        restart_terminal_required: true,
        message: 'Terminal configurado en modo PDV (integración API). Reinicia el Point Smart 2 y vuelve a cobrar.',
        ...result.data,
      });
    }

    if (action === 'create-intent') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const { amount, description, externalReference } = body || {};
      if (!amount || !Number.isFinite(Number(amount)) || Number(amount) <= 0) {
        return res.status(400).json({ ok: false, error: 'invalid_amount' });
      }

      const operatingMode = await getDeviceOperatingMode(MP_ACCESS_TOKEN, String(deviceId));
      if (operatingMode && operatingMode !== 'PDV') {
        const pdv = await setTerminalPdvMode(MP_ACCESS_TOKEN, String(deviceId));
        if (pdv.ok) {
          return res.status(409).json({
            ok: false,
            error: 'terminal_mode_switched_to_pdv',
            message:
              'El Point estaba en modo STANDALONE (no recibe cobros del sistema). Se cambió a modo PDV. Reinicia el terminal, espera que abra, e intenta cobrar de nuevo.',
            operating_mode_before: operatingMode,
            restart_terminal_required: true,
          });
        }
        return res.status(409).json({
          ok: false,
          error: 'terminal_not_in_pdv_mode',
          message:
            'El Point Smart 2 está en modo STANDALONE y no puede recibir cobros desde FarmaCapital. En Mercado Pago activa modo PDV/integrado para este terminal.',
          operating_mode: operatingMode,
          mp_error: pdv.message,
        });
      }

      const orderBody = buildCreateOrderBody(deviceId, amount, description, externalReference);

      const queue = await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId), { onlyStaleCreated: true });
      if (queue.blocked) {
        return res.status(409).json({
          ok: false,
          error: 'terminal_busy',
          message:
            'Hay un cobro activo en el Point. Complétalo en el terminal (tarjeta/NFC) o cancélalo ahí con X, y vuelve a intentar.',
          at_terminal_orders: queue.at_terminal,
        });
      }

      let { resp, data } = await createPointOrder(MP_ACCESS_TOKEN, deviceId, orderBody);

      if (isQueuedTerminalConflict(resp.status, data)) {
        await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId), { onlyStaleCreated: false });
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
        operating_mode: operatingMode || 'PDV',
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

    if (action === 'diagnose') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const cleared = await clearTerminalQueue(MP_ACCESS_TOKEN, String(deviceId), { onlyStaleCreated: false });
      const mode = await getDeviceOperatingMode(MP_ACCESS_TOKEN, String(deviceId));
      const { data: devData } = await mpJson(MP_DEVICES_LEGACY, {
        method: 'GET',
        headers: authHeaders(MP_ACCESS_TOKEN),
      });
      const device = (devData?.devices || []).find((d) => d.id === deviceId);
      const testBody = buildCreateOrderBody(deviceId, 18, 'Diagnostico FC', `FC-DIAG-${Date.now()}`);
      const { resp, data } = await createPointOrder(MP_ACCESS_TOKEN, deviceId, testBody);
      let afterStatus = null;
      if (resp.ok && data?.id) {
        await new Promise((r) => setTimeout(r, 8000));
        const { data: d2 } = await mpJson(`${MP_API}/v1/orders/${encodeURIComponent(data.id)}`, {
          method: 'GET',
          headers: authHeaders(MP_ACCESS_TOKEN),
        });
        afterStatus = d2?.status || null;
        await cancelPointOrder(MP_ACCESS_TOKEN, data.id, d2?.status || 'created');
      }
      return res.status(200).json({
        ok: true,
        operating_mode: mode,
        pending_cleared: cleared.cleared,
        pending_remaining: cleared.pending,
        order_created: resp.ok,
        order_create_error: resp.ok ? null : mpErrorMessage(data, resp.status),
        order_id: data?.id || null,
        order_status_after_8s: afterStatus,
        user_id: data?.user_id || null,
        application_id: data?.integration_data?.application_id || null,
        pos_id: device?.pos_id || null,
        store_id: device?.store_id || null,
        diagnosis:
          mode !== 'PDV'
            ? 'Terminal no está en PDV según API.'
            : !resp.ok
              ? `No se pudo crear cobro de prueba: ${mpErrorMessage(data, resp.status)}`
              : afterStatus === 'at_terminal'
                ? 'OK: el Point recibe cobros.'
                : 'FarmaCapital y Mercado Pago OK; el Point físico no sincroniza. Desvincula y revincula el lector en la app MP.',
      });
    }

    return res.status(400).json({ ok: false, error: 'unknown_action' });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'proxy_error', message: e?.message || 'unknown' });
  }
};
