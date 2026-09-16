'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

const json = (status, body) => ({ ok: status >= 200 && status < 300, status, json: async () => body, text: async () => '' });

function firmado(dataId, body) {
  const ts = '1700000000';
  const reqId = 'req-1';
  const v1 = crypto.createHmac('sha256', 'secreto').update(`id:${dataId};request-id:${reqId};ts:${ts};`).digest('hex');
  return { method: 'POST', query: {}, body, headers: { 'x-signature': `ts=${ts},v1=${v1}`, 'x-request-id': reqId } };
}
function res() {
  return { statusCode: 0, body: null, status(c) { this.statusCode = c; return this; }, json(b) { this.body = b; return this; } };
}

describe('webhook MP y reservas', () => {
  let orig; let patches;
  beforeEach(() => {
    orig = global.fetch; patches = [];
    process.env.MP_ACCESS_TOKEN = 'APP_USR-x';
    process.env.SUPABASE_URL = 'https://sb.test';
    process.env.SUPABASE_SERVICE_ROLE_KEY = 'svc';
    process.env.MP_WEBHOOK_SECRET = 'secreto';
  });
  afterEach(() => { global.fetch = orig; });

  function mock(pedido, payment) {
    global.fetch = async (url, init = {}) => {
      const u = String(url);
      if (u.includes('api.mercadopago.com/v1/payments/')) return json(200, payment);
      if (init.method === 'PATCH') { patches.push({ u, body: JSON.parse(init.body) }); return json(200, [{}]); }
      if (u.includes('/rest/v1/pedidos')) return json(200, [pedido]);
      return json(200, []);
    };
  }

  it('un aviso «authorized» no pisa una reserva viva', async () => {
    mock({ id: 7, total: 958, payment_status: 'authorized', payment_payload: { modo: 'reserva' }, logistics_meta: { bajo_pedido: true } },
      { id: 123, status: 'authorized', external_reference: 'FARMACAPITAL-PED-7', transaction_amount: 958 });
    const handler = require('../payments/mp/webhook');
    const r = res();
    await handler(firmado('123', { type: 'payment', data: { id: '123' } }), r);
    assert.equal(r.body.reason, 'estado_no_degrada');
    assert.equal(patches.length, 0);
  });

  it('un aviso tardío «pending» no degrada un pedido ya cobrado', async () => {
    mock({ id: 8, total: 100, payment_status: 'approved', payment_payload: {}, logistics_meta: {} },
      { id: 124, status: 'pending', external_reference: 'FARMACAPITAL-PED-8', transaction_amount: 100 });
    const handler = require('../payments/mp/webhook');
    const r = res();
    await handler(firmado('124', { type: 'payment', data: { id: '124' } }), r);
    assert.equal(r.body.reason, 'estado_no_degrada');
    assert.equal(patches.length, 0);
  });

  it('pedido normal pendiente → approved sigue funcionando igual', async () => {
    mock({ id: 9, cliente_id: 1, total: 100, payment_status: 'initiated', payment_payload: { preference_id: 'p' }, logistics_meta: {}, tipo_entrega: 'recoger' },
      { id: 125, status: 'approved', external_reference: 'FARMACAPITAL-PED-9', transaction_amount: 100 });
    const handler = require('../payments/mp/webhook');
    const r = res();
    await handler(firmado('125', { type: 'payment', data: { id: '125' } }), r);
    assert.equal(r.statusCode, 200);
    assert.equal(r.body.status, 'approved');
    assert.equal(patches[0].body.payment_status, 'approved');
  });
});
