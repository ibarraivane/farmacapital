'use strict';

const { sendWhatsapp, buildReceiptMessage } = require('../_lib/orderNotifications');

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

  const SUPABASE_URL = normalizeSupabaseProjectUrl(process.env.SUPABASE_URL || process.env.REACT_APP_SUPABASE_URL || '');
  const SUPABASE_SERVICE_ROLE_KEY = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
  const body = await safeJson(req);
  const pedidoId = Number(body?.pedidoId);
  let telefono = String(body?.telefono || '').trim();
  let message = String(body?.message || '').trim();

  if (!pedidoId || !Number.isFinite(pedidoId)) {
    return res.status(400).json({ ok: false, error: 'invalid_pedido_id' });
  }

  if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
    try {
      const pedidoResp = await fetch(
        `${SUPABASE_URL}/rest/v1/pedidos?id=eq.${pedidoId}&select=id,total,tipo,tipo_entrega,metodo_pago,cliente_id,guest_telefono,pedido_items(cantidad,precio_unitario,productos(nombre))&limit=1`,
        {
          headers: {
            apikey: SUPABASE_SERVICE_ROLE_KEY,
            Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
          },
        }
      );
      const pedidoRows = await pedidoResp.json().catch(() => []);
      const pedido = Array.isArray(pedidoRows) ? pedidoRows[0] : null;

      if (pedido) {
        if (!telefono && pedido.guest_telefono) telefono = String(pedido.guest_telefono);
        if (!telefono && pedido.cliente_id) {
          const cliResp = await fetch(
            `${SUPABASE_URL}/rest/v1/clientes?id=eq.${pedido.cliente_id}&select=telefono&limit=1`,
            {
              headers: {
                apikey: SUPABASE_SERVICE_ROLE_KEY,
                Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
              },
            }
          );
          const cliRows = await cliResp.json().catch(() => []);
          const cli = Array.isArray(cliRows) ? cliRows[0] : null;
          if (cli?.telefono) telefono = String(cli.telefono);
        }
        if (!message) {
          message = buildReceiptMessage({
            event: 'order_created',
            pedido,
            items: pedido.pedido_items || [],
          });
        }
      }
    } catch (e) {
      console.warn('[order-receipt] fetch pedido:', e?.message);
    }
  }

  if (!telefono) {
    return res.status(200).json({ ok: true, whatsapp: { sent: false, reason: 'missing_phone' } });
  }
  if (!message) {
    return res.status(400).json({ ok: false, error: 'missing_message' });
  }

  const waRes = await sendWhatsapp({ to: telefono, text: message });
  return res.status(200).json({ ok: true, whatsapp: waRes });
};
