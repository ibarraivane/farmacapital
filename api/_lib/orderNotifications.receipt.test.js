'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { buildReceiptMessage } = require('./orderNotifications');

describe('recibo pago aprobado', () => {
  it('da las gracias y menciona el recibo', () => {
    const msg = buildReceiptMessage({
      event: 'payment_approved',
      pedido: { id: 453, total: 395, tipo_entrega: 'envio' },
      cliente: { nombre: 'Alejandro Escalante' },
      items: [{ cantidad: 1, precio_unitario: 56, productos: { nombre: 'Roxidolin' } }],
    });
    assert.match(msg, /Hola Alejandro/);
    assert.match(msg, /Gracias por tu compra/);
    assert.match(msg, /#FC-0453/);
    assert.match(msg, /recibo|ticket/i);
    assert.match(msg, /Roxidolin/);
  });
});
