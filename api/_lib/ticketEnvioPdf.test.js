'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { ticketCompraPdfBase64, ticketPagoAdjunto } = require('./ticketEnvioPdf');

const URL = 'https://www.farmacapital.mx/r/11111111-1111-1111-1111-111111111111';

describe('ticket de compra al pagar', () => {
  it('no arma PDF si el ticket todavía no existe', () => {
    assert.equal(ticketCompraPdfBase64({ pedidoId: 333, total: 540 }), null);
    assert.equal(ticketPagoAdjunto({ pedidoId: 333, total: 540, ticketUrl: '  ' }), null);
  });

  it('sale un PDF pagado con el folio y la liga del ticket', () => {
    const adj = ticketPagoAdjunto({
      pedidoId: 333,
      nombre: 'Ivan Ibarra',
      items: [{ nombre: 'Paracetamol', qty: 1, importe: 480 }],
      productos: 480,
      envio: 60,
      total: 540,
      ticketUrl: URL,
      ahora: new Date('2026-09-21T12:00:00Z'),
    });
    assert.equal(adj.filename, 'ticket-FC-0333.pdf');
    assert.equal(adj.url, URL);
    const raw = Buffer.from(adj.content, 'base64').toString('latin1');
    assert.match(raw, /^%PDF/);
    assert.match(raw, /FC-0333/);
    assert.match(raw, /Paracetamol/);
    assert.match(raw, /Pagado/);
    assert.doesNotMatch(raw, /Pendiente de pago/);
    assert.match(raw, /farmacapital\.mx\/r\//);
  });

  it('el ticket muestra el Servicio y cuadra con el total', () => {
    const adj = ticketPagoAdjunto({
      pedidoId: 441,
      items: [{ nombre: 'Omeprazol', qty: 1, importe: 202 }],
      productos: 202,
      servicio: 5,
      envio: 100,
      total: 307,
      ticketUrl: URL,
      ahora: new Date('2026-09-21T12:00:00Z'),
    });
    const raw = Buffer.from(adj.content, 'base64').toString('latin1');
    assert.match(raw, /Servicio/);
    assert.match(raw, /\$5\.00/);
    assert.match(raw, /\$307\.00/);
  });
});
