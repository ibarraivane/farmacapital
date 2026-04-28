'use strict';

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
  const dataId = String(req.query?.id || req.query?.['data.id'] || req.body?.data?.id || '').trim();
  if (!dataId) return res.status(200).json({ ok: true, ignored: true, reason: 'missing_data_id' });

  try {
    if (topic && topic !== 'payment') return res.status(200).json({ ok: true, ignored: true, reason: `topic_${topic}` });

    const mpResp = await fetch(`https://api.mercadopago.com/v1/payments/${encodeURIComponent(dataId)}`, {
      headers: { Authorization: `Bearer ${MP_ACCESS_TOKEN}` },
    });
    const payment = await mpResp.json();
    if (!mpResp.ok) return res.status(502).json({ ok: false, error: 'mp_payment_fetch_failed' });

    const externalRef = String(payment?.external_reference || '');
    const m = externalRef.match(/FARMAX-PED-(\d+)/);
    const pedidoId = m ? Number(m[1]) : null;
    if (!pedidoId) return res.status(200).json({ ok: true, ignored: true, reason: 'no_pedido_reference' });

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

    await fetch(`${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}`, {
      method: 'PATCH',
      headers: {
        apikey: SUPABASE_SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(patch),
    });

    return res.status(200).json({ ok: true, pedidoId, status });
  } catch (e) {
    return res.status(500).json({ ok: false, error: 'unexpected_error', message: e?.message || 'unknown' });
  }
};
