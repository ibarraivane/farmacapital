'use strict';

/**
 * ENCARGO BAJO PEDIDO — reserva en tarjeta con Mercado Pago (Checkout API / Orders).
 *
 *   reservar  → POST /v1/orders  capture_mode "manual"  (el dinero NO cae a la cuenta)
 *   cobrar    → POST /v1/orders/{id}/capture             (cuando ya se consiguió)
 *   cancelar  → POST /v1/orders/{id}/cancel              (no se consiguió; sin cargo)
 *
 * MP sostiene la reserva 5 días. Solo tarjeta de crédito. Se cobra el monto completo reservado.
 * No agrega Serverless Functions (Vercel Hobby 12/12):
 *   - reservar: POST /api/payments/mp/create-preference con { modo: "reserva" }
 *   - cobrar/cancelar: /api/payments/mp/point?action=reserva-cobrar|reserva-cancelar (sesión empleado)
 */

const crypto = require('crypto');

const MP_API = 'https://api.mercadopago.com';
const DIAS_RESERVA_MP = 5;
const GUEST_VENTANA_MS = 2 * 60 * 60 * 1000;

function round2(n) {
  return Math.round(Number(n) * 100) / 100;
}

function digits10(v) {
  return String(v || '').replace(/\D/g, '').slice(-10);
}

function sbHeaders(serviceKey, extra = {}) {
  return { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, ...extra };
}

function esBajoPedidoPedido(pedido) {
  const meta = pedido && pedido.logistics_meta;
  return Boolean(meta && typeof meta === 'object' && meta.bajo_pedido === true);
}

function payloadDe(pedido) {
  return pedido && pedido.payment_payload && typeof pedido.payment_payload === 'object'
    ? pedido.payment_payload
    : {};
}

function mpErrorDetail(data) {
  if (!data || typeof data !== 'object') return null;
  if (typeof data.message === 'string' && data.message) return data.message;
  if (Array.isArray(data.errors) && data.errors.length) {
    return data.errors.map((e) => e.message || e.code || '').filter(Boolean).join(', ');
  }
  return null;
}

/** Estado de la transacción de una orden MP (la orden y su primer pago). */
function estadoOrdenMp(order) {
  const pay = order && order.transactions && Array.isArray(order.transactions.payments)
    ? order.transactions.payments[0] || {}
    : {};
  return {
    orderStatus: String((order && order.status) || '').toLowerCase(),
    orderDetail: String((order && order.status_detail) || '').toLowerCase(),
    payStatus: String(pay.status || '').toLowerCase(),
    payDetail: String(pay.status_detail || '').toLowerCase(),
    paymentId: pay.id != null ? String(pay.id) : null,
  };
}

function reservaAutorizada(order) {
  const e = estadoOrdenMp(order);
  return e.orderDetail === 'waiting_capture' || e.payDetail === 'waiting_capture';
}

function capturaExitosa(order) {
  const e = estadoOrdenMp(order);
  const malos = ['failed', 'canceled', 'cancelled', 'expired', 'rejected', 'action_required'];
  if (malos.includes(e.orderStatus) || malos.includes(e.payStatus)) return false;
  return ['processed', 'accredited', 'approved'].some(
    (s) => [e.orderStatus, e.orderDetail, e.payStatus, e.payDetail].includes(s),
  );
}

function ordenYaCancelada(order) {
  const e = estadoOrdenMp(order);
  return ['canceled', 'cancelled', 'expired'].includes(e.orderStatus)
    || ['canceled', 'cancelled', 'expired'].includes(e.payStatus);
}

async function fetchJson(url, init) {
  const resp = await fetch(url, init);
  const data = await resp.json().catch(() => null);
  return { resp, data };
}

async function leerPedido(supabaseUrl, serviceKey, pedidoId) {
  const select = 'id,cliente_id,total,estado,tipo,tipo_entrega,metodo_pago,created_at,guest_telefono,logistics_meta,payment_status,payment_payload,whatsapp_recibo';
  const { resp, data } = await fetchJson(
    `${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}&select=${select}&limit=1`,
    { headers: sbHeaders(serviceKey) },
  );
  if (!resp.ok || !Array.isArray(data)) return null;
  return data[0] || null;
}

async function patchPedido(supabaseUrl, serviceKey, pedidoId, patch) {
  const resp = await fetch(`${supabaseUrl}/rest/v1/pedidos?id=eq.${pedidoId}`, {
    method: 'PATCH',
    headers: sbHeaders(serviceKey, { 'Content-Type': 'application/json', Prefer: 'return=minimal' }),
    body: JSON.stringify(patch),
  });
  return resp.ok;
}

async function mpPost(accessToken, path, body, idempotencyKey) {
  return fetchJson(`${MP_API}${path}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
      'X-Idempotency-Key': idempotencyKey,
    },
    body: body == null ? undefined : JSON.stringify(body),
  });
}

/** El que paga es dueño del pedido (cliente con sesión o invitado con su teléfono). */
async function validarDueno({ supabaseUrl, serviceKey, pedido, clienteToken, guest, guestPhone }) {
  if (!guest) {
    if (!clienteToken) return 'missing_cliente_token';
    const { resp, data } = await fetchJson(`${supabaseUrl}/rest/v1/rpc/fn_validar_token_cliente`, {
      method: 'POST',
      headers: sbHeaders(serviceKey, { 'Content-Type': 'application/json' }),
      body: JSON.stringify({ p_token: clienteToken }),
    });
    const clienteId = Number(data);
    if (!resp.ok || !clienteId) return 'invalid_cliente_token';
    if (Number(pedido.cliente_id) !== clienteId) return 'pedido_not_owned';
    return null;
  }
  if (digits10(guestPhone).length !== 10) return 'missing_guest_phone';
  const created = Date.parse(pedido.created_at);
  if (!Number.isFinite(created) || Date.now() - created > GUEST_VENTANA_MS) return 'guest_checkout_expired';
  let tel = digits10(pedido.guest_telefono);
  if (tel.length !== 10 && pedido.cliente_id) {
    const { data } = await fetchJson(
      `${supabaseUrl}/rest/v1/clientes?id=eq.${pedido.cliente_id}&select=telefono&limit=1`,
      { headers: sbHeaders(serviceKey) },
    );
    tel = digits10(Array.isArray(data) && data[0] ? data[0].telefono : '');
  }
  if (tel !== digits10(guestPhone)) return 'guest_phone_mismatch';
  return null;
}

/**
 * Reservar. body: { modo:"reserva", pedidoId, amount, cardToken, paymentMethodId, paymentTypeId,
 *                   payer:{ email }, guest, guestPhone }
 */
async function crearReserva({ env, body, clienteToken }) {
  const { accessToken, supabaseUrl, serviceKey } = env;
  const pedidoId = Number(body && body.pedidoId);
  const amount = round2(body && body.amount);
  const cardToken = String((body && body.cardToken) || '').trim();
  const paymentMethodId = String((body && body.paymentMethodId) || '').trim();
  const paymentTypeId = String((body && body.paymentTypeId) || 'credit_card').trim();
  const email = String((body && body.payer && body.payer.email) || '').trim().slice(0, 120);
  const guest = body && body.guest === true;

  if (!Number.isInteger(pedidoId) || pedidoId <= 0) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  if (!(amount > 0)) return { status: 400, json: { ok: false, error: 'invalid_amount' } };
  if (!cardToken || !paymentMethodId) return { status: 400, json: { ok: false, error: 'missing_card_token' } };
  if (paymentTypeId !== 'credit_card') return { status: 400, json: { ok: false, error: 'solo_tarjeta_credito' } };
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return { status: 400, json: { ok: false, error: 'invalid_payer_email' } };

  const pedido = await leerPedido(supabaseUrl, serviceKey, pedidoId);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };

  const dueno = await validarDueno({ supabaseUrl, serviceKey, pedido, clienteToken, guest, guestPhone: body && body.guestPhone });
  if (dueno) return { status: dueno.startsWith('invalid') || dueno.startsWith('missing') ? 401 : 403, json: { ok: false, error: dueno } };

  if (pedido.tipo !== 'online') return { status: 400, json: { ok: false, error: 'pedido_not_online' } };
  if (!esBajoPedidoPedido(pedido)) return { status: 400, json: { ok: false, error: 'pedido_no_es_bajo_pedido' } };
  if (pedido.estado !== 'pendiente') return { status: 409, json: { ok: false, error: 'pedido_not_pending' } };
  const st = String(pedido.payment_status || '').toLowerCase();
  if (st === 'authorized' || st === 'approved') return { status: 409, json: { ok: false, error: 'pedido_ya_reservado' } };

  const totalDb = round2(pedido.total);
  if (!(totalDb > 0)) return { status: 400, json: { ok: false, error: 'invalid_db_total' } };
  const expected = totalDb;
  if (Math.abs(expected - amount) > 0.01) {
    return { status: 409, json: { ok: false, error: 'amount_mismatch', expected } };
  }

  const monto = Number(expected).toFixed(2);
  const idem = `fc-reserva-${pedidoId}-${crypto.createHash('sha256').update(cardToken).digest('hex').slice(0, 16)}`;
  const { resp, data } = await mpPost(accessToken, '/v1/orders', {
    type: 'online',
    processing_mode: 'automatic',
    capture_mode: 'manual',
    marketplace: 'NONE',
    external_reference: `FARMACAPITAL-PED-${pedidoId}`,
    description: `FarmaCapital encargo #${pedidoId}`,
    total_amount: monto,
    payer: { email },
    transactions: {
      payments: [{
        amount: monto,
        payment_method: { id: paymentMethodId, type: 'credit_card', token: cardToken, installments: 1 },
      }],
    },
  }, idem);

  if (!resp.ok || !reservaAutorizada(data)) {
    const e = estadoOrdenMp(data);
    return {
      status: resp.ok ? 402 : 502,
      json: {
        ok: false,
        error: resp.ok ? 'reserva_rechazada' : 'mp_order_failed',
        status_detail: e.payDetail || e.orderDetail || null,
        detail: mpErrorDetail(data),
      },
    };
  }

  const e = estadoOrdenMp(data);
  const ahora = new Date();
  const expira = new Date(ahora.getTime() + DIAS_RESERVA_MP * 24 * 60 * 60 * 1000);
  const ok = await patchPedido(supabaseUrl, serviceKey, pedidoId, {
    payment_provider: 'mercadopago',
    payment_status: 'authorized',
    payment_id: e.paymentId,
    payment_payload: {
      modo: 'reserva',
      order_id: data.id,
      transaction_id: e.paymentId,
      status_detail: e.payDetail || e.orderDetail,
      monto: expected,
      reserva_creada_at: ahora.toISOString(),
      reserva_expira_at: expira.toISOString(),
      last_event_at: ahora.toISOString(),
    },
  });

  if (!ok) {
    // No dejar dinero apartado sin registro: se libera la reserva.
    await mpPost(accessToken, `/v1/orders/${encodeURIComponent(data.id)}/cancel`, null, `fc-cancelar-${pedidoId}-rollback`).catch(() => null);
    return { status: 502, json: { ok: false, error: 'supabase_update_failed_reserva_liberada' } };
  }

  return {
    status: 200,
    json: { ok: true, pedidoId, reservado: expected, expira_at: expira.toISOString() },
  };
}

async function acreditarYNotificar({ supabaseUrl, serviceKey, pedido, notify }) {
  try {
    await fetch(`${supabaseUrl}/rest/v1/rpc/service_acreditar_puntos_pedido`, {
      method: 'POST',
      headers: sbHeaders(serviceKey, { 'Content-Type': 'application/json' }),
      body: JSON.stringify({ p_pedido_id: pedido.id }),
    });
  } catch (_) { /* puntos no bloquean */ }
  if (typeof notify !== 'function') return;
  try {
    const [cli, items] = await Promise.all([
      fetchJson(`${supabaseUrl}/rest/v1/clientes?id=eq.${pedido.cliente_id}&select=id,nombre,telefono,email&limit=1`, { headers: sbHeaders(serviceKey) }),
      fetchJson(`${supabaseUrl}/rest/v1/pedido_items?pedido_id=eq.${pedido.id}&select=cantidad,precio_unitario,productos(nombre)`, { headers: sbHeaders(serviceKey) }),
    ]);
    await notify({
      event: 'payment_approved',
      pedido,
      cliente: Array.isArray(cli.data) ? cli.data[0] || {} : {},
      items: Array.isArray(items.data) ? items.data : [],
    });
  } catch (_) { /* notificación no bloquea */ }
}

/** Cobrar la reserva (ya se consiguió el producto). */
async function cobrarReserva({ env, pedidoId, notify }) {
  const { accessToken, supabaseUrl, serviceKey } = env;
  const id = Number(pedidoId);
  if (!Number.isInteger(id) || id <= 0) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const pedido = await leerPedido(supabaseUrl, serviceKey, id);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (!esBajoPedidoPedido(pedido)) return { status: 400, json: { ok: false, error: 'pedido_no_es_bajo_pedido' } };
  const st = String(pedido.payment_status || '').toLowerCase();
  if (st === 'approved') return { status: 200, json: { ok: true, pedidoId: id, ya: 'cobrado' } };
  const payload = payloadDe(pedido);
  if (st !== 'authorized' || payload.modo !== 'reserva' || !payload.order_id) {
    return { status: 409, json: { ok: false, error: 'sin_reserva_activa' } };
  }

  const { resp, data } = await mpPost(accessToken, `/v1/orders/${encodeURIComponent(payload.order_id)}/capture`, null, `fc-cobrar-${id}`);
  const ahora = new Date().toISOString();

  if (resp.ok && capturaExitosa(data)) {
    const e = estadoOrdenMp(data);
    const ok = await patchPedido(supabaseUrl, serviceKey, id, {
      payment_status: 'approved',
      paid_at: ahora,
      payment_payload: { ...payload, capturada_at: ahora, capture_status: e.payDetail || e.orderDetail || e.orderStatus, last_event_at: ahora },
    });
    if (!ok) return { status: 502, json: { ok: false, error: 'cobrado_en_mp_pero_no_guardado', order_id: payload.order_id } };
    await acreditarYNotificar({ supabaseUrl, serviceKey, pedido: { ...pedido, payment_status: 'approved' }, notify });
    return { status: 200, json: { ok: true, pedidoId: id, cobrado: round2(pedido.total) } };
  }

  if (ordenYaCancelada(data)) {
    await patchPedido(supabaseUrl, serviceKey, id, {
      payment_status: 'cancelled',
      payment_payload: { ...payload, cancelada_at: ahora, motivo: 'reserva_vencida', last_event_at: ahora },
    });
    return { status: 409, json: { ok: false, error: 'reserva_vencida' } };
  }

  return { status: 502, json: { ok: false, error: 'mp_capture_failed', detail: mpErrorDetail(data) } };
}

/** Cancelar la reserva (no se consiguió). Libera el dinero del cliente sin cargo. */
async function cancelarReserva({ env, pedidoId, motivo }) {
  const { accessToken, supabaseUrl, serviceKey } = env;
  const id = Number(pedidoId);
  if (!Number.isInteger(id) || id <= 0) return { status: 400, json: { ok: false, error: 'invalid_pedido_id' } };
  const pedido = await leerPedido(supabaseUrl, serviceKey, id);
  if (!pedido) return { status: 404, json: { ok: false, error: 'pedido_not_found' } };
  if (!esBajoPedidoPedido(pedido)) return { status: 400, json: { ok: false, error: 'pedido_no_es_bajo_pedido' } };
  const st = String(pedido.payment_status || '').toLowerCase();
  if (st === 'approved') return { status: 409, json: { ok: false, error: 'ya_cobrado_usa_devolucion' } };
  const payload = payloadDe(pedido);
  const ahora = new Date().toISOString();
  const razon = String(motivo || 'no_se_consiguio').slice(0, 80);

  if (st === 'authorized' && payload.order_id) {
    const { resp, data } = await mpPost(accessToken, `/v1/orders/${encodeURIComponent(payload.order_id)}/cancel`, null, `fc-cancelar-${id}`);
    if (!resp.ok && !ordenYaCancelada(data)) {
      return { status: 502, json: { ok: false, error: 'mp_cancel_failed', detail: mpErrorDetail(data) } };
    }
  }

  const ok = await patchPedido(supabaseUrl, serviceKey, id, {
    estado: 'cancelado',
    payment_status: 'cancelled',
    payment_payload: { ...payload, cancelada_at: ahora, motivo: razon, last_event_at: ahora },
  });
  if (!ok) return { status: 502, json: { ok: false, error: 'supabase_update_failed' } };
  return { status: 200, json: { ok: true, pedidoId: id, cancelado: true } };
}

module.exports = {
  DIAS_RESERVA_MP,
  crearReserva,
  cobrarReserva,
  cancelarReserva,
  reservaAutorizada,
  capturaExitosa,
  ordenYaCancelada,
  esBajoPedidoPedido,
};
