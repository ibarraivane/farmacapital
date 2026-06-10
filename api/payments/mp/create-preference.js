'use strict';
const { sendOrderNotifications } = require('../../_lib/orderNotifications');

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

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'method_not_allowed' });

  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  const SUPABASE_URL = normalizeSupabaseProjectUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();

  if (!MP_ACCESS_TOKEN) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'missing_supabase_service_role' });
  }

  const body = await safeJson(req);
  const pedidoId = Number(body?.pedidoId);
  const amount = Number(body?.amount || 0);
  const items = Array.isArray(body?.items) ? body.items : [];
  const payer = body?.payer && typeof body.payer === 'object' ? body.payer : {};
  const baseUrl = String(body?.baseUrl || '').trim();
  const auth = req.headers.authorization || req.headers.Authorization || '';
  const clienteToken = auth.replace(/^Bearer\s+/i, '').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  if (!Number.isFinite(amount) || amount <= 0) return res.status(400).json({ ok: false, error: 'invalid_amount' });
  if (!clienteToken) return res.status(401).json({ ok: false, error: 'missing_cliente_token' });

  try {
    // Verifica sesión cliente y ownership del pedido.
    const validTokResp = await fetch(`${SUPABASE_URL}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ p_token: clienteToken }),
    });
    const clienteId = Number(await validTokResp.json());
    if (!validTokResp.ok || !clienteId) return res.status(401).json({ ok: false, error: 'invalid_cliente_token' });

    const pedidoResp = await fetch(
      `${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,cliente_id,total,estado,tipo,metodo_pago,tipo_entrega`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      }
    );
    const pedidoRows = await pedidoResp.json();
    const pedido = Array.isArray(pedidoRows) ? pedidoRows[0] : null;
    if (!pedidoResp.ok || !pedido) return res.status(404).json({ ok: false, error: 'pedido_not_found' });
    if (Number(pedido.cliente_id) !== clienteId) return res.status(403).json({ ok: false, error: 'pedido_not_owned' });
    if (pedido.tipo !== 'online') return res.status(400).json({ ok: false, error: 'pedido_not_online' });
    if (pedido.estado !== 'pendiente') return res.status(409).json({ ok: false, error: 'pedido_not_pending' });

    const totalDb = Number(pedido.total || 0);
    if (!Number.isFinite(totalDb) || totalDb <= 0) return res.status(400).json({ ok: false, error: 'invalid_db_total' });
    if (Math.abs(totalDb - amount) > 0.01) return res.status(409).json({ ok: false, error: 'amount_mismatch' });

    const safeBase = baseUrl || 'https://farmacapital.mx';
    const externalReference = `FARMACAPITAL-PED-${pedidoId}`;
    const mpPayload = {
      external_reference: externalReference,
      notification_url: `${safeBase.replace(/\/$/, '')}/api/payments/mp/webhook`,
      back_urls: {
        success: `${safeBase.replace(/\/$/, '')}/?payment=success&pedido=${pedidoId}`,
        pending: `${safeBase.replace(/\/$/, '')}/?payment=pending&pedido=${pedidoId}`,
        failure: `${safeBase.replace(/\/$/, '')}/?payment=failure&pedido=${pedidoId}`,
      },
      auto_return: 'approved',
      statement_descriptor: 'FARMACAPITAL',
      payer: {
        name: String(payer?.name || '').slice(0, 120) || undefined,
        email: String(payer?.email || '').slice(0, 120) || undefined,
      },
      items: items.length
        ? items.map((it) => ({
            title: String(it?.title || 'Producto FarmaCapital').slice(0, 256),
            quantity: Math.max(1, Number(it?.quantity || 1)),
            currency_id: 'MXN',
            unit_price: Number(it?.unit_price || 0),
          }))
        : [{ title: `Pedido #${pedidoId}`, quantity: 1, currency_id: 'MXN', unit_price: totalDb }],
      metadata: {
        pedido_id: pedidoId,
        cliente_id: clienteId,
      },
    };

    const mpResp = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${MP_ACCESS_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(mpPayload),
    });
    const mpData = await mpResp.json();
    if (!mpResp.ok) return res.status(502).json({ ok: false, error: 'mp_preference_failed', detail: mpData?.message || null });

    const patchResp = await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      },
      body: JSON.stringify({
        payment_provider: 'mercadopago',
        payment_status: 'initiated',
        payment_payload: { preference_id: mpData?.id || null },
      }),
    });
    if (!patchResp.ok) {
      let patchErr = null;
      try {
        patchErr = await patchResp.json();
      } catch {
        patchErr = await patchResp.text();
      }
      return res.status(502).json({
        ok: false,
        error: 'supabase_payment_tracking_update_failed',
        detail: patchErr || null,
      });
    }

    try {
      const clienteResp = await fetch(
        `${SUPABASE_URL}/rest/v1/clientes?id=eq.${clienteId}&select=id,nombre,telefono,email&limit=1`,
        {
          headers: {
            apikey: SUPABASE_SERVICE_ROLE_KEY,
            Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          },
        }
      );
      const cliRows = await clienteResp.json().catch(() => []);
      const cliente = Array.isArray(cliRows) ? cliRows[0] : null;
      await sendOrderNotifications({
        event: 'order_created',
        pedido: { ...pedido, id: pedidoId },
        cliente: cliente || {},
      });
    } catch (_) {
      // Notificaciones no bloquean checkout.
    }

    return res.status(200).json({
      ok: true,
      preferenceId: mpData?.id || null,
      initPoint: mpData?.init_point || null,
      sandboxInitPoint: mpData?.sandbox_init_point || null,
    });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'unexpected_error', message: e?.message || 'unknown' });
  }
};
