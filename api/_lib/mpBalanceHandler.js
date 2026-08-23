'use strict';

const { getSupabaseAdminConfig, validateAdminSession } = require('./supabaseAdmin');

const MP_API = 'https://api.mercadopago.com';

function mpToken() {
  return (process.env.MP_ACCESS_TOKEN || process.env.MERCADOPAGO_ACCESS_TOKEN || '').trim();
}

/** Saldo MP (admin). Vive en _lib para no gastar un slot Hobby. */
module.exports = async function mpBalanceHandler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, x-session-token');
  if (req.method === 'OPTIONS') return res.status(204).end();
  if (req.method !== 'GET') return res.status(405).json({ ok: false, error: 'method_not_allowed' });

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  const sessionToken = String(req.headers['x-session-token'] || '').trim();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'supabase_not_configured' });
  }
  const isAdmin = await validateAdminSession(supabaseUrl, serviceKey, sessionToken);
  if (!isAdmin) return res.status(403).json({ ok: false, error: 'requiere_admin' });

  const token = mpToken();
  if (!token) return res.status(500).json({ ok: false, error: 'missing_mp_access_token' });

  try {
    const meResp = await fetch(`${MP_API}/users/me`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const me = await meResp.json().catch(() => ({}));
    if (!meResp.ok || !me.id) {
      return res.status(502).json({
        ok: false,
        error: 'mp_users_me_failed',
        message: me.message || 'Mercado Pago no dejó leer la cuenta. Pon el saldo a mano desde la app.',
      });
    }

    const balResp = await fetch(`${MP_API}/users/${me.id}/mercadopago_account/balance`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const bal = await balResp.json().catch(() => ({}));
    if (!balResp.ok) {
      return res.status(502).json({
        ok: false,
        error: 'mp_balance_failed',
        message: bal.message || 'Mercado Pago no expone el saldo con este token. Ponlo a mano desde Actividad.',
      });
    }

    const available = Number(bal.available_balance);
    return res.status(200).json({
      ok: true,
      user_id: me.id,
      available_balance: Number.isFinite(available) ? available : null,
      total_amount: bal.total_amount ?? null,
      unavailable_balance: bal.unavailable_balance ?? null,
    });
  } catch (e) {
    return res.status(500).json({ ok: false, error: e?.message || 'error' });
  }
};
