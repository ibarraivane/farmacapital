'use strict';

const { sendWhatsapp, buildReceiptMessage } = require('../_lib/orderNotifications');
const { getSupabaseAdminConfig, validateEmployeeSession } = require('../_lib/supabaseAdmin');

async function safeJson(req) {
  try {
    if (!req?.body) return {};
    if (typeof req.body === 'object') return req.body;
    return JSON.parse(req.body || '{}');
  } catch {
    return {};
  }
}

function digitsOnly(v) {
  return String(v || '').replace(/\D/g, '');
}

async function fetchPedido(supabaseUrl, serviceKey, pedidoId) {
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,total,tipo,tipo_entrega,metodo_pago,cliente_id,guest_telefono,created_at,pedido_items(cantidad,precio_unitario,productos(nombre))&limit=1`,
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

async function fetchClienteTelefono(supabaseUrl, serviceKey, clienteId) {
  if (!clienteId) return null;
  const resp = await fetch(
    `${supabaseUrl}/rest/v1/clientes?id=eq.${clienteId}&select=telefono&limit=1`,
    {
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
      },
    }
  );
  const rows = await resp.json().catch(() => []);
  const cli = Array.isArray(rows) ? rows[0] : null;
  return cli?.telefono ? String(cli.telefono) : null;
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

function phoneTailMatches(storedPhone, verifyDigits) {
  const stored = digitsOnly(storedPhone);
  const verify = digitsOnly(verifyDigits);
  if (!stored || verify.length < 4) return false;
  return stored.endsWith(verify.slice(-4));
}

function pedidoReciente(createdAt, maxMinutes = 15) {
  if (!createdAt) return false;
  const ts = new Date(createdAt).getTime();
  if (!Number.isFinite(ts)) return false;
  return Date.now() - ts <= maxMinutes * 60 * 1000;
}

async function resolvePedidoTelefono(supabaseUrl, serviceKey, pedido) {
  if (pedido?.guest_telefono) return String(pedido.guest_telefono);
  if (pedido?.cliente_id) {
    const tel = await fetchClienteTelefono(supabaseUrl, serviceKey, pedido.cliente_id);
    if (tel) return tel;
  }
  return null;
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ ok: false, error: 'method_not_allowed' });
  }

  const body = await safeJson(req);
  const pedidoId = Number(body?.pedidoId);
  const sessionToken = String(body?.sessionToken || '').trim() || null;
  const employeeToken = String(body?.employeeSessionToken || body?.sessionTokenEmpleado || '').trim() || null;
  const phoneVerify = String(body?.phoneVerify || '').trim() || null;
  const event = String(body?.event || 'order_created').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(500).json({ ok: false, error: 'missing_server_env' });
  }

  let pedido = null;
  try {
    pedido = await fetchPedido(supabaseUrl, serviceKey, pedidoId);
  } catch (e) {
    console.warn('[order-receipt] fetch pedido:', e?.message);
  }

  if (!pedido) {
    return res.status(404).json({ ok: false, error: 'pedido_not_found' });
  }

  let authorized = false;

  if (employeeToken && (await validateEmployeeSession(supabaseUrl, serviceKey, employeeToken))) {
    authorized = true;
  } else if (sessionToken) {
    const clienteId = await validateClienteToken(supabaseUrl, serviceKey, sessionToken);
    if (clienteId != null) {
      if (pedido.cliente_id == null || Number(pedido.cliente_id) === Number(clienteId)) {
        authorized = true;
      }
    }
  } else if (phoneVerify && pedidoReciente(pedido.created_at)) {
    const telPedido = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido);
    if (phoneTailMatches(telPedido, phoneVerify)) {
      authorized = true;
    }
  }

  if (!authorized) {
    return res.status(403).json({ ok: false, error: 'unauthorized' });
  }

  const telefono = await resolvePedidoTelefono(supabaseUrl, serviceKey, pedido);
  if (!telefono) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'missing_phone' } });
  }

  const message = buildReceiptMessage({
    event,
    pedido,
    items: pedido.pedido_items || [],
  });

  const waRes = await sendWhatsapp({ to: telefono, text: message });
  return res.status(200).json({ ok: true, whatsapp: waRes, pedidoId });
};
