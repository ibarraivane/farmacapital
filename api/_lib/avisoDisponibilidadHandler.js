'use strict';

const { getSupabaseAdminConfig } = require('./supabaseAdmin');
const { applyRestrictiveCors } = require('./allowedOrigins');
const { validarAvisoDisponibilidadApi } = require('./avisoDisponibilidad');

async function rpcCrearAviso(supabaseUrl, serviceKey, value) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/rpc/tienda_crear_aviso_disponibilidad`, {
    method: 'POST',
    headers: {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      p_producto_id: value.producto_id,
      p_cliente_telefono: value.cliente_telefono,
      p_cliente_nombre: value.cliente_nombre,
    }),
  });
  const data = await resp.json().catch(() => null);
  if (!resp.ok) {
    const msg =
      (data && (data.message || data.error || data.hint)) ||
      (typeof data === 'string' ? data : JSON.stringify(data || {}));
    return { ok: false, status: resp.status, error: String(msg).slice(0, 240) };
  }
  return { ok: true, data };
}

async function handleAvisoDisponibilidad(req, res, body) {
  applyRestrictiveCors(req, res);
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const parsed = validarAvisoDisponibilidadApi(body);
  if (parsed.honeypot) {
    return res.status(200).json({ ok: true, ignored: true });
  }
  if (!parsed.ok) {
    return res.status(400).json({ ok: false, error: 'invalid_aviso', fields: parsed.errors });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  const saved = await rpcCrearAviso(supabaseUrl, serviceKey, parsed.value);
  if (!saved.ok) {
    const err = String(saved.error || '');
    if (/producto_no_encontrado/i.test(err)) {
      return res.status(404).json({ ok: false, error: 'producto_no_encontrado' });
    }
    if (/producto_con_stock/i.test(err)) {
      return res.status(409).json({
        ok: false,
        error: 'producto_con_stock',
        message: 'Este producto ya tiene stock. Puedes agregarlo al carrito.',
      });
    }
    if (/telefono_invalido/i.test(err)) {
      return res.status(400).json({ ok: false, error: 'telefono_invalido' });
    }
    return res.status(502).json({ ok: false, error: 'aviso_not_saved', detail: err });
  }

  return res.status(200).json({
    ok: true,
    ...(saved.data && typeof saved.data === 'object' ? saved.data : { data: saved.data }),
  });
}

module.exports = {
  handleAvisoDisponibilidad,
  rpcCrearAviso,
};
