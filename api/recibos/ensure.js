'use strict';

const { getSupabaseAdminConfig, validateEmployeeSession } = require('../_lib/supabaseAdmin');
const {
  ensurePedidoReciboToken,
  buildReciboPublicUrl,
} = require('../_lib/receiptTicket');

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

/** POST /api/recibos/ensure — token público para QR impreso y WhatsApp (misma URL /r/{token}). */
module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  try {
    const body = await safeJson(req);
    const pedidoId = Number(body?.pedidoId);
    const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim();

    if (!pedidoId || !Number.isFinite(pedidoId)) {
      return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
    }
    if (!employeeToken) {
      return res.status(403).json({ ok: false, error: 'missing_employee_session' });
    }

    const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
    if (!supabaseUrl || !serviceKey) {
      return res.status(500).json({ ok: false, error: 'missing_server_env' });
    }

    const validEmployee = await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken);
    if (!validEmployee) {
      return res.status(403).json({ ok: false, error: 'invalid_employee_session' });
    }

    const token = await ensurePedidoReciboToken(supabaseUrl, serviceKey, pedidoId);
    if (!token) {
      return res.status(404).json({ ok: false, error: 'pedido_not_found' });
    }

    return res.status(200).json({
      ok: true,
      pedidoId,
      token,
      ticketUrl: buildReciboPublicUrl(token),
    });
  } catch (e) {
    console.error('[recibos/ensure] unhandled:', e?.message || e);
    return res.status(500).json({ ok: false, error: 'server_error', detail: e?.message || 'unknown' });
  }
};
