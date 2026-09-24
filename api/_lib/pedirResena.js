'use strict';

const { randomUUID } = require('crypto');
const { productoAceptaResena } = require('../../src/lib/resenasProductoCore');
const { emailsAvisoCliente } = require('./clienteEmails');
const emailTemplates = require('./emailTemplates');
const { sendEmail } = require('./orderNotifications');

function lineasElegibles(items) {
  return (Array.isArray(items) ? items : []).filter((it) => productoAceptaResena(it?.productos || it));
}

/**
 * Qué hacer cuando un pedido llega a completado.
 * action stamp: no hay nada que calificar; se marca para no reintentar.
 * action send: hay productos de la lista blanca y un correo.
 */
function decidirEnvioResena({ pedido, items, emails } = {}) {
  if (pedido?.resena_pedida_at) return { action: 'skip', reason: 'already_sent' };
  if (String(pedido?.estado || '') !== 'completado') return { action: 'skip', reason: 'not_delivered' };
  const elegibles = lineasElegibles(items);
  if (!elegibles.length) return { action: 'stamp', reason: 'sin_productos' };
  if (!Array.isArray(emails) || emails.length === 0) return { action: 'skip', reason: 'missing_email' };
  return { action: 'send', elegibles };
}

function sbHeaders(key, extra) {
  return {
    apikey: key,
    Authorization: `Bearer ${key}`,
    'Content-Type': 'application/json',
    ...(extra || {}),
  };
}

async function sbFetch(url, key, path, opts = {}) {
  const resp = await fetch(`${url}/rest/v1/${path}`, {
    method: opts.method || 'GET',
    headers: sbHeaders(key, opts.headers),
    body: opts.body ? JSON.stringify(opts.body) : undefined,
  });
  const text = await resp.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { ok: resp.ok, status: resp.status, data };
}

const SELECT_PEDIDO = [
  'id', 'estado', 'cliente_id', 'guest_email', 'guest_nombre',
  'resena_pedida_at', 'resena_token',
  'pedido_items(producto_id,productos(id,nombre,marca,categoria,subcategoria,presentacion,forma_farmaceutica,principio_activo,requiere_receta,controlado,grupo_controlado))',
].join(',');

async function cargarPedido(url, key, pedidoId) {
  const q = `pedidos?id=eq.${Number(pedidoId)}&select=${encodeURIComponent(SELECT_PEDIDO)}&limit=1`;
  return sbFetch(url, key, q);
}

async function cargarCliente(url, key, clienteId) {
  if (!clienteId) return null;
  const q = `clientes?id=eq.${Number(clienteId)}&select=${encodeURIComponent('id,nombre,email,email_alt')}&limit=1`;
  const res = await sbFetch(url, key, q);
  return res.ok && Array.isArray(res.data) ? res.data[0] : null;
}

async function marcarPedida(url, key, pedidoId, extra) {
  const q = `pedidos?id=eq.${Number(pedidoId)}&resena_pedida_at=is.null`;
  return sbFetch(url, key, q, {
    method: 'PATCH',
    headers: { Prefer: 'return=representation' },
    body: { resena_pedida_at: new Date().toISOString(), ...(extra || {}) },
  });
}

async function soltarPedida(url, key, pedidoId) {
  const q = `pedidos?id=eq.${Number(pedidoId)}`;
  return sbFetch(url, key, q, {
    method: 'PATCH',
    headers: { Prefer: 'return=minimal' },
    body: { resena_pedida_at: null },
  });
}

/**
 * Manda el correo una sola vez. Si el pedido es solo medicamentos, no manda nada.
 * El enlace lleva un token para quien compró sin quedarse en la sesión.
 */
async function enviarPedidoResena({ supabaseUrl, serviceKey, pedidoId } = {}) {
  const url = String(supabaseUrl || '').replace(/\/+$/, '');
  const key = String(serviceKey || '').trim();
  const id = Number(pedidoId);
  if (!url || !key || !Number.isFinite(id) || id <= 0) {
    return { sent: false, reason: 'missing_params' };
  }

  const loaded = await cargarPedido(url, key, id);
  if (!loaded.ok) {
    const msg = JSON.stringify(loaded.data || '');
    if (/resena_pedida_at|resena_token|column/i.test(msg)) {
      return { sent: false, reason: 'schema_pending' };
    }
    return { sent: false, reason: 'pedido_fetch_failed', detail: loaded.data };
  }
  const pedido = Array.isArray(loaded.data) ? loaded.data[0] : null;
  if (!pedido) return { sent: false, reason: 'pedido_not_found' };

  const cliente = await cargarCliente(url, key, pedido.cliente_id);
  const emails = emailsAvisoCliente({
    guestEmail: pedido.guest_email,
    email: cliente?.email,
    emailAlt: cliente?.email_alt,
  });
  const decision = decidirEnvioResena({
    pedido,
    items: pedido.pedido_items,
    emails,
  });
  if (decision.action === 'skip') return { sent: false, reason: decision.reason };
  if (decision.action === 'stamp') {
    await marcarPedida(url, key, id);
    return { sent: false, reason: decision.reason };
  }

  const token = pedido.resena_token || randomUUID();
  const claimed = await marcarPedida(url, key, id, { resena_token: token });
  const claimedRow = Array.isArray(claimed.data) ? claimed.data[0] : null;
  if (!claimed.ok || !claimedRow) {
    return { sent: false, reason: claimed.ok ? 'already_sent' : 'claim_failed' };
  }

  const base = emailTemplates.DEFAULTS.baseUrl;
  const urlResena = `${base}/cuenta?resena=${encodeURIComponent(token)}`;
  const productos = decision.elegibles.map((it) => ({
    id: it.producto_id || it.productos?.id,
    nombre: it.productos?.nombre || it.nombre || 'Producto',
  }));
  const plantilla = emailTemplates.pedirResena({
    pedidoId: id,
    nombre: cliente?.nombre || pedido.guest_nombre || '',
    urlResena,
    productos,
  });
  let emailRes;
  try {
    emailRes = await sendEmail({
      to: emails,
      subject: plantilla.subject,
      text: plantilla.text,
      html: plantilla.html,
    });
  } catch (e) {
    emailRes = { sent: false, reason: 'exception', detail: e?.message };
  }
  if (!emailRes?.sent) {
    await soltarPedida(url, key, id);
    return { sent: false, reason: emailRes?.reason || 'email_failed', detail: emailRes?.detail || null };
  }
  return { sent: true, reason: 'sent', to: emails };
}

module.exports = {
  lineasElegibles,
  decidirEnvioResena,
  enviarPedidoResena,
};
