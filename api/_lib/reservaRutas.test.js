'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');

function res() {
  return { statusCode: 0, body: null, headers: {}, setHeader(k, v) { this.headers[k] = v; },
    status(c) { this.statusCode = c; return this; }, json(b) { this.body = b; return this; }, end() { return this; } };
}
const json = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body });

describe('rutas de reserva sin funciones nuevas', () => {
  let orig;
  beforeEach(() => {
    orig = global.fetch;
    process.env.MP_ACCESS_TOKEN = 'APP_USR-x';
    process.env.SUPABASE_URL = 'https://sb.test';
    process.env.SUPABASE_SERVICE_ROLE_KEY = 'svc';
  });
  afterEach(() => { global.fetch = orig; });

  it('create-preference: un encargo no puede pagarse con liga directa', async () => {
    global.fetch = async (url) => {
      const u = String(url);
      if (u.includes('fn_validar_token_cliente')) return json(200, 1);
      if (u.includes('/rest/v1/pedidos')) return json(200, [{ id: 7, cliente_id: 1, total: 479, estado: 'pendiente', tipo: 'online', logistics_meta: { bajo_pedido: true } }]);
      throw new Error('no esperado ' + u);
    };
    const handler = require('../payments/mp/create-preference');
    const r = res();
    await handler({ method: 'POST', headers: { authorization: 'Bearer cli' }, body: { pedidoId: 7, amount: 479 } }, r);
    assert.equal(r.statusCode, 409);
    assert.equal(r.body.error, 'pedido_bajo_pedido_usa_reserva');
  });

  it('create-preference con modo reserva llega a crearReserva', async () => {
    global.fetch = async (url) => {
      const u = String(url);
      if (u.includes('/rest/v1/pedidos')) return json(200, []);
      throw new Error('no esperado ' + u);
    };
    const handler = require('../payments/mp/create-preference');
    const r = res();
    await handler({ method: 'POST', headers: {}, body: { modo: 'reserva', pedidoId: 7, amount: 479, cardToken: 't', paymentMethodId: 'visa', payer: { email: 'a@b.mx' } } }, r);
    assert.equal(r.statusCode, 404);
    assert.equal(r.body.error, 'pedido_not_found');
  });

  it('point: cobrar reserva exige sesión de empleado', async () => {
    global.fetch = async (url) => {
      if (String(url).includes('fn_validar_token_empleado')) return json(200, null);
      throw new Error('no esperado ' + url);
    };
    const handler = require('../payments/mp/point');
    const r = res();
    await handler({ method: 'POST', headers: {}, query: { action: 'reserva-cobrar' }, body: { pedidoId: 7 } }, r);
    assert.equal(r.statusCode, 401);
  });

  it('point: con sesión, cancelar reserva responde', async () => {
    global.fetch = async (url) => {
      const u = String(url);
      if (u.includes('fn_validar_token_empleado')) return json(200, 5);
      if (u.includes('/rest/v1/pedidos')) return json(200, []);
      throw new Error('no esperado ' + u);
    };
    const handler = require('../payments/mp/point');
    const r = res();
    await handler({ method: 'POST', headers: { 'x-session-token': 'emp' }, query: { action: 'reserva-cancelar' }, body: { pedidoId: 7 } }, r);
    assert.equal(r.statusCode, 404);
    assert.equal(r.body.error, 'pedido_not_found');
  });
});
