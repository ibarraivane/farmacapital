'use strict';

const { getSupabaseAdminConfig } = require('../_lib/supabaseAdmin');
const {
  fetchPedidoByReciboToken,
  generateTicketHTML,
  buildReciboPublicUrl,
} = require('../_lib/receiptTicket');

/** GET /api/recibos/view?token=…  o rewrite /r/:token */
module.exports = async function handler(req, res) {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.setHeader('Allow', 'GET, HEAD');
    return res.status(405).send('Method not allowed');
  }

  const token = String(req.query?.token || '').trim();
  if (!token || token.length < 8 || token.length > 64) {
    return res.status(400).send('Enlace de ticket inválido');
  }

  const { supabaseUrl, serviceKey } = getSupabaseAdminConfig();
  if (!supabaseUrl || !serviceKey) {
    return res.status(503).send('Servicio no disponible');
  }

  let pedido = null;
  try {
    pedido = await fetchPedidoByReciboToken(supabaseUrl, serviceKey, token);
  } catch (e) {
    console.warn('[recibos/view] fetch:', e?.message);
  }

  if (!pedido) {
    return res.status(404).send('Ticket no encontrado o enlace expirado');
  }

  const ticketUrl = buildReciboPublicUrl(token);
  const html = generateTicketHTML({ pedido, ticketUrl });

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'private, max-age=300');
  if (req.method === 'HEAD') {
    return res.status(200).end();
  }
  return res.status(200).send(html);
};
