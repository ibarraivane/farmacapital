'use strict';

const { sendWhatsapp, buildCitaConfirmacionMessage } = require('../_lib/orderNotifications');
const { getSupabaseAdminConfig } = require('../_lib/supabaseAdmin');

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

async function fetchCita(supabaseUrl, serviceKey, citaId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/citas?id=eq.${citaId}&select=id,nombre,telefono,fecha,hora,motivo,cliente_id,estado&limit=1`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    }
  );
  const rows = await resp.json().catch(() => []);
  return Array.isArray(rows) ? rows[0] : null;
}

async function validateClienteToken(supabaseUrl, serviceKey, token) {
  if (!token) return null;
  try {
    const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ p_token: token }),
    });
    const data = await resp.json().catch(() => null);
    const id = typeof data === 'number' ? data : parseInt(String(data || ''), 10);
    return Number.isFinite(id) && id > 0 ? id : null;
  } catch {
    return null;
  }
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const body = await safeJson(req);
  const citaId = Number(body?.citaId);
  const sessionToken = String(body?.sessionToken || '').trim() || null;

  if (!citaId || !Number.isFinite(citaId)) {
    return res.status(400).json({ ok: false, error: 'invalid_cita_id' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  let cita = null;

  if (supabaseUrl && serviceKey) {
    try {
      cita = await fetchCita(supabaseUrl, serviceKey, citaId);
      if (cita && sessionToken) {
        const clienteId = await validateClienteToken(supabaseUrl, serviceKey, sessionToken);
        if (!clienteId) {
          return res.status(403).json({ ok: false, error: 'invalid_session' });
        }
        if (cita.cliente_id != null && Number(cita.cliente_id) !== Number(clienteId)) {
          return res.status(403).json({ ok: false, error: 'cita_not_owned' });
        }
      }
    } catch (e) {
      console.warn('[cita-confirmacion] fetch cita:', e?.message);
    }
  }

  const telefono = String(cita?.telefono || body?.telefono || '').trim();
  if (!telefono) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'missing_phone' } });
  }

  const message =
    String(body?.message || '').trim() ||
    buildCitaConfirmacionMessage({
      nombre: cita?.nombre || body?.nombre,
      fecha: cita?.fecha || body?.fecha,
      hora: cita?.hora || body?.hora,
      motivo: cita?.motivo ?? body?.motivo,
      citaId: cita?.id || citaId,
    });

  const waRes = await sendWhatsapp({ to: telefono, text: message });
  return res.status(200).json({ ok: true, whatsapp: waRes, citaId });
};
