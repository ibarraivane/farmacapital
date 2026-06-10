'use strict';
const { sendOrderNotifications } = require('../../_lib/orderNotifications');

function normalizeSupabaseProjectUrl(url) {
  if (url == null || typeof url !== 'string') return url;
  let u = url.trim().replace(/\/+$/g, '');
  while (/\/rest\/v1$/i.test(u)) u = u.replace(/\/rest\/v1$/i, '').replace(/\/+$/g, '');
  return u;
}

module.exports = async function handler(req, res) {
  const MP_ACCESS_TOKEN = (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
  const SUPABASE_URL = normalizeSupabaseProjectUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();

  if (!MP_ACCESS_TOKEN || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  // MP puede llamar por GET o POST dependiendo del tipo de notificación.
  const topic = String(req.query?.topic || req.query?.type || req.body?.type || '').toLowerCase();
  const action = String(req.body?.action || '').toLowerCase();
  const dataId = String(req.query?.id || req.query?.['data.id'] || req.body?.data?.id || '').trim();
  if (!dataId) return res.status(200).json({ ok: true, ignored: true, reason: 'missing_data_id' });

  try {
    const looksLikePaymentTopic = topic === 'payment' || action.startsWith('payment.');
    if (!looksLikePaymentTopic) {
      return res.status(200).json({ ok: true, ignored: true, reason: `topic_${topic || action || 'unknown'}` });
    }

    // Simulaciones de MP a veces envían data.id = "payment" (no es un id real).
    if (!/^\d+$/.test(dataId)) {
      return res.status(200).json({ ok: true, ignored: true, reason: 'non_numeric_payment_id', dataId });
    }

    const mpResp = await fetch(`https://api.mercadopago.com/v1/payments/${encodeURIComponent(dataId)}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` },
    });
    const payment = await mpResp.json();
    if (!mpResp.ok) {
      return res.status(200).json({
        ok: true,
        ignored: true,
        reason: 'mp_payment_not_accessible',
        status: mpResp.status,
      });
    }

    const externalRef = String(payment?.external_reference || '');
    const m = externalRef.match(/FARMACAPITAL-PED-(\d+)/);
    const pedidoId = m ? Number(m[1]) : null;
    if (!pedidoId) return res.status(200).json({ ok: true, ignored: true, reason: 'no_pedido_reference' });

    const pedidoResp = await fetch(
      `${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,cliente_id,total,tipo_entrega,payment_status&limit=1`,
      {
        headers: {
          apikey: SUPABASE_SERVICE_ROLE_KEY,
          Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        },
      }
    );
    const pedidoRows = await pedidoResp.json().catch(() => []);
    const pedidoBefore = Array.isArray(pedidoRows) ? pedidoRows[0] : null;

    const status = String(payment?.status || '').toLowerCase();
    const approved = status === 'approved';
    const patch = {
      payment_provider: 'mercadopago',
      payment_status: status || 'unknown',
      payment_id: String(payment?.id || dataId),
      paid_at: approved ? new Date().toISOString() : null,
      payment_payload: {
        status_detail: payment?.status_detail || null,
        transaction_amount: payment?.transaction_amount ?? null,
        currency_id: payment?.currency_id || null,
        date_approved: payment?.date_approved || null,
        last_event_at: new Date().toISOString(),
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
      body: JSON.stringify(patch),
    });
    if (!patchResp.ok) {
      let detail = null;
      try { detail = await patchResp.json(); } catch { detail = await patchResp.text(); }
      return res.status(502).json({ ok: false, error: 'supabase_update_failed', detail });
    }

    if (pedidoBefore && pedidoBefore.payment_status !== status) {
      try {
        const cliResp = await fetch(
          `${SUPABASE_URL}/rest/v1/clientes?id=eq.${pedidoBefore.cliente_id}&select=id,nombre,telefono,email&limit=1`,
          {
            headers: {
              apikey: SUPABASE_SERVICE_ROLE_KEY,
              Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
            },
          }
        );
        const cliRows = await cliResp.json().catch(() => []);
        const cliente = Array.isArray(cliRows) ? cliRows[0] : null;
        const event = status === 'approved'
          ? 'payment_approved'
          : (status === 'pending' || status === 'in_process' ? 'payment_pending' : 'payment_rejected');
        await sendOrderNotifications({
          event,
          pedido: { ...pedidoBefore, id: pedidoId },
          cliente: cliente || {},
        });
      } catch (_) {
        // Notificaciones no bloquean webhook.
      }
    }

    return res.status(200).json({ ok: true, pedidoId, status });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'unexpected_error', message: e?.message || 'unknown' });
  }
};
