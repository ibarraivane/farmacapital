'use strict';
// Proxy seguro para MP Point Smart 2
// El Access Token nunca sale al frontend — se usa solo aquí en el servidor.

const MP_BASE = 'https://api.mercadopago.com/point/integration-api';

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  if (!MP_ACCESS_TOKEN) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });

  // path: /api/payments/mp/point?action=devices|create-intent|get-intent|cancel-intent
  const { action, deviceId, intentId } = req.query;
  const body = req.method === 'POST' ? (typeof req.body === 'object' ? req.body : {}) : null;

  const mpHeaders = {
    Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
    'Content-Type': 'application/json',
    'X-Sandbox': 'false',
  };

  try {
    let mpUrl, mpMethod, mpBody;

    if (action === 'devices') {
      mpUrl = `${MP_BASE}/devices`;
      mpMethod = 'GET';

    } else if (action === 'create-intent') {
      if (!deviceId) return res.status(400).json({ ok: false, error: 'missing_deviceId' });
      const { amount, description, externalReference } = body || {};
      if (!amount || !Number.isFinite(Number(amount)) || Number(amount) <= 0)
        return res.status(400).json({ ok: false, error: 'invalid_amount' });
      mpUrl = `${MP_BASE}/devices/${deviceId}/payment-intents`;
      mpMethod = 'POST';
      mpBody = {
        amount: Number(amount),
        description: String(description || 'Venta FarmaCapital').slice(0, 255),
        payment: { installments: 1, installments_cost: 'seller', type: 'credit_card' },
        additional_info: {
          external_reference: String(externalReference || ''),
          print_on_terminal: true,
        },
      };

    } else if (action === 'get-intent') {
      if (!intentId) return res.status(400).json({ ok: false, error: 'missing_intentId' });
      mpUrl = `${MP_BASE}/payment-intents/${intentId}`;
      mpMethod = 'GET';

    } else if (action === 'cancel-intent') {
      if (!deviceId || !intentId) return res.status(400).json({ ok: false, error: 'missing_deviceId_or_intentId' });
      mpUrl = `${MP_BASE}/devices/${deviceId}/payment-intents/${intentId}`;
      mpMethod = 'DELETE';

    } else {
      return res.status(400).json({ ok: false, error: 'unknown_action' });
    }

    const mpResp = await fetch(mpUrl, {
      method: mpMethod,
      headers: mpHeaders,
      ...(mpBody ? { body: JSON.stringify(mpBody) } : {}),
    });

    const data = await mpResp.json().catch(() => ({}));
    return res.status(mpResp.ok ? 200 : mpResp.status).json({ ok: mpResp.ok, ...data });

  } catch (e) {
    return res.status(500).json({ ok: false, error: 'proxy_error', message: e?.message || 'unknown' });
  }
};
