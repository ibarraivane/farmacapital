'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');

/** Espejo de la ventana de guest en attach / resumen / create-preference. */
function guestCheckoutWindowMs(tipoEntrega) {
  return String(tipoEntrega || '').toLowerCase() === 'envio'
    ? 72 * 60 * 60 * 1000
    : 2 * 60 * 60 * 1000;
}

function phonesMatchGuest(telPedido, guestPhone) {
  const a = String(telPedido || '').replace(/\D/g, '');
  const b = String(guestPhone || '').replace(/\D/g, '');
  if (b.length < 10 || a.length < 10) return false;
  return a.slice(-10) === b.slice(-10);
}

describe('guest checkout auth helpers', () => {
  it('domicilio tiene 72 h; pickup 2 h', () => {
    assert.equal(guestCheckoutWindowMs('envio'), 72 * 60 * 60 * 1000);
    assert.equal(guestCheckoutWindowMs('recoger'), 2 * 60 * 60 * 1000);
  });

  it('compara últimos 10 dígitos aunque el pedido tenga 52…', () => {
    assert.equal(phonesMatchGuest('525512345678', '5512345678'), true);
    assert.equal(phonesMatchGuest('5512345678', '525512345678'), true);
    assert.equal(phonesMatchGuest('', '5512345678'), false);
    assert.equal(phonesMatchGuest('525511111111', '5512345678'), false);
  });
});
