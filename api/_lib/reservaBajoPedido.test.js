'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const { crearReserva, cobrarReserva, cancelarReserva } = require('./reservaBajoPedido');

const env = { accessToken: 'APP_USR-x', supabaseUrl: 'https://sb.test', serviceKey: 'svc' };
const json = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });

function mock(routes) {
  const calls = [];
  global.fetch = async (url, init = {}) => {
    const u = String(url);
    calls.push({ url: u, init, body: init.body ? JSON.parse(init.body) : null });
    for (const [pat, fn] of routes) if (u.includes(pat)) return fn(u, init);
    throw new Error('fetch no esperado: ' + u);
  };
  return calls;
}

const pedidoBase = () => ({
  id: 7, cliente_id: 1, total: 958, estado: 'pendiente', tipo: 'online', tipo_entrega: 'recoger',
  created_at: new Date().toISOString(), guest_telefono: null, logistics_meta: { bajo_pedido: true },
  payment_status: null, payment_payload: null,
});

const bodyBase = () => ({
  modo: 'reserva', pedidoId: 7, amount: 958, cardToken: 'tok123', paymentMethodId: 'visa',
  paymentTypeId: 'credit_card', payer: { email: 'ana@x.mx' },
});

const ordenReservada = { id: 'ORD1', status: 'action_required', status_detail: 'waiting_capture', transactions: { payments: [{ id: 'PAY1', status: 'action_required', status_detail: 'waiting_capture' }] } };

describe('crearReserva', () => {
  let orig; let pedido;
  beforeEach(() => { orig = global.fetch; pedido = pedidoBase(); });
  afterEach(() => { global.fetch = orig; });

  it('reserva el total del pedido y marca authorized con vencimiento a 5 días', async () => {
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['fn_validar_token_cliente', () => json(200, 1)],
      ['api.mercadopago.com/v1/orders', () => json(201, ordenReservada)],
      ['/rest/v1/pedidos?id=eq.7', () => json(204, null)],
    ]);
    const out = await crearReserva({ env, body: bodyBase(), clienteToken: 'cli-tok' });
    assert.equal(out.status, 200, JSON.stringify(out.json));
    const mp = calls.find((c) => c.url.endsWith('/v1/orders'));
    assert.equal(mp.body.capture_mode, 'manual');
    assert.equal(mp.body.total_amount, '958.00');
    assert.equal(mp.body.external_reference, 'FARMACAPITAL-PED-7');
    assert.equal(mp.body.transactions.payments[0].payment_method.token, 'tok123');
    assert.ok(mp.init.headers['X-Idempotency-Key'].startsWith('fc-reserva-7-'));
    const patch = calls.filter((c) => c.init.method === 'PATCH')[0].body;
    assert.equal(patch.payment_status, 'authorized');
    assert.equal(patch.payment_payload.order_id, 'ORD1');
    const dias = (Date.parse(patch.payment_payload.reserva_expira_at) - Date.parse(patch.payment_payload.reserva_creada_at)) / 86400000;
    assert.equal(Math.round(dias), 5);
  });

  it('rechaza débito, monto distinto, pedido normal, ajeno o ya reservado', async () => {
    mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['fn_validar_token_cliente', () => json(200, 1)],
    ]);
    assert.equal((await crearReserva({ env, body: { ...bodyBase(), paymentTypeId: 'debit_card' }, clienteToken: 't' })).json.error, 'solo_tarjeta_credito');
    assert.equal((await crearReserva({ env, body: { ...bodyBase(), amount: 900 }, clienteToken: 't' })).json.error, 'amount_mismatch');
    pedido.logistics_meta = {};
    assert.equal((await crearReserva({ env, body: bodyBase(), clienteToken: 't' })).json.error, 'pedido_no_es_bajo_pedido');
    pedido = pedidoBase(); pedido.cliente_id = 99;
    assert.equal((await crearReserva({ env, body: bodyBase(), clienteToken: 't' })).json.error, 'pedido_not_owned');
    pedido = pedidoBase(); pedido.payment_status = 'authorized';
    assert.equal((await crearReserva({ env, body: bodyBase(), clienteToken: 't' })).json.error, 'pedido_ya_reservado');
  });

  it('invitado: teléfono del pedido debe coincidir', async () => {
    pedido.guest_telefono = '55 1111 2222';
    mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['api.mercadopago.com/v1/orders', () => json(201, ordenReservada)],
      ['/rest/v1/pedidos?id=eq.7', () => json(204, null)],
    ]);
    assert.equal((await crearReserva({ env, body: { ...bodyBase(), guest: true, guestPhone: '5599990000' } })).json.error, 'guest_phone_mismatch');
    assert.equal((await crearReserva({ env, body: { ...bodyBase(), guest: true, guestPhone: '+52 5511112222' } })).status, 200);
  });

  it('tarjeta rechazada: 402 y no toca el pedido', async () => {
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['fn_validar_token_cliente', () => json(200, 1)],
      ['api.mercadopago.com/v1/orders', () => json(201, { id: 'ORD2', status: 'failed', transactions: { payments: [{ status: 'failed', status_detail: 'cc_rejected_insufficient_amount' }] } })],
    ]);
    const out = await crearReserva({ env, body: bodyBase(), clienteToken: 't' });
    assert.equal(out.status, 402);
    assert.equal(out.json.status_detail, 'cc_rejected_insufficient_amount');
    assert.equal(calls.some((c) => c.init.method === 'PATCH'), false);
  });

  it('si no se puede guardar, libera la reserva en MP', async () => {
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['fn_validar_token_cliente', () => json(200, 1)],
      ['/v1/orders/ORD1/cancel', () => json(200, { id: 'ORD1', status: 'canceled' })],
      ['api.mercadopago.com/v1/orders', () => json(201, ordenReservada)],
      ['/rest/v1/pedidos?id=eq.7', () => json(500, { message: 'down' })],
    ]);
    const out = await crearReserva({ env, body: bodyBase(), clienteToken: 't' });
    assert.equal(out.json.error, 'supabase_update_failed_reserva_liberada');
    assert.ok(calls.some((c) => c.url.includes('/v1/orders/ORD1/cancel')));
  });
});

describe('cobrarReserva / cancelarReserva', () => {
  let orig; let pedido;
  beforeEach(() => {
    orig = global.fetch;
    pedido = { ...pedidoBase(), payment_status: 'authorized', payment_payload: { modo: 'reserva', order_id: 'ORD1', reserva_expira_at: '2026-09-21T00:00:00Z' } };
  });
  afterEach(() => { global.fetch = orig; });

  it('cobra: approved, puntos y aviso de pago', async () => {
    const avisos = [];
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['/v1/orders/ORD1/capture', () => json(200, { id: 'ORD1', status: 'processed', status_detail: 'accredited', transactions: { payments: [{ status: 'processed', status_detail: 'accredited' }] } })],
      ['/rest/v1/pedidos?id=eq.7', () => json(204, null)],
      ['service_acreditar_puntos_pedido', () => json(200, { ok: true })],
      ['/rest/v1/clientes', () => json(200, [{ id: 1, nombre: 'Ana' }])],
      ['/rest/v1/pedido_items', () => json(200, [{ cantidad: 2 }])],
    ]);
    const out = await cobrarReserva({ env, pedidoId: 7, notify: async (a) => avisos.push(a) });
    assert.equal(out.status, 200, JSON.stringify(out.json));
    const patch = calls.find((c) => c.init.method === 'PATCH').body;
    assert.equal(patch.payment_status, 'approved');
    assert.ok(patch.paid_at);
    assert.ok(calls.some((c) => c.url.includes('service_acreditar_puntos_pedido')));
    assert.equal(avisos[0].event, 'payment_approved');
  });

  it('cobrar una reserva vencida la marca cancelada', async () => {
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['/v1/orders/ORD1/capture', () => json(400, { id: 'ORD1', status: 'expired' })],
      ['/rest/v1/pedidos?id=eq.7', () => json(204, null)],
    ]);
    const out = await cobrarReserva({ env, pedidoId: 7 });
    assert.equal(out.json.error, 'reserva_vencida');
    assert.equal(calls.find((c) => c.init.method === 'PATCH').body.payment_status, 'cancelled');
  });

  it('no cobra sin reserva activa ni dos veces', async () => {
    pedido.payment_status = null;
    mock([['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])]]);
    assert.equal((await cobrarReserva({ env, pedidoId: 7 })).json.error, 'sin_reserva_activa');
    pedido.payment_status = 'approved';
    assert.equal((await cobrarReserva({ env, pedidoId: 7 })).json.ya, 'cobrado');
  });

  it('cancela: libera en MP y deja el pedido cancelado', async () => {
    const calls = mock([
      ['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])],
      ['/v1/orders/ORD1/cancel', () => json(200, { id: 'ORD1', status: 'canceled' })],
      ['/rest/v1/pedidos?id=eq.7', () => json(204, null)],
    ]);
    const out = await cancelarReserva({ env, pedidoId: 7, motivo: 'agotado en Nadro' });
    assert.equal(out.status, 200);
    const patch = calls.find((c) => c.init.method === 'PATCH').body;
    assert.equal(patch.estado, 'cancelado');
    assert.equal(patch.payment_status, 'cancelled');
    assert.equal(patch.payment_payload.motivo, 'agotado en Nadro');
  });

  it('no cancela lo ya cobrado', async () => {
    pedido.payment_status = 'approved';
    mock([['/rest/v1/pedidos?id=eq.7&select', () => json(200, [pedido])]]);
    assert.equal((await cancelarReserva({ env, pedidoId: 7 })).json.error, 'ya_cobrado_usa_devolucion');
  });
});
