'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { ticketEnvioPdfBase64 } = require('./ticketEnvioPdf');

describe('ticket de envío en PDF', () => {
  it('sale un PDF con el folio', () => {
    const b64 = ticketEnvioPdfBase64({
      pedidoId: 333,
      nombre: 'Ivan Ibarra',
      items: [{ nombre: 'Paracetamol', qty: 1, importe: 480 }],
      productos: 480,
      envio: 60,
      total: 540,
      ahora: new Date('2026-09-21T12:00:00Z'),
    });
    const raw = Buffer.from(b64, 'base64').toString('latin1');
    assert.match(raw, /^%PDF/);
    assert.match(raw, /FC-0333/);
    assert.match(raw, /Paracetamol/);
  });
});
