'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { validarAvisoDisponibilidadApi } = require('./avisoDisponibilidad');

describe('avisoDisponibilidad api', () => {
  it('exige producto y teléfono 10 dígitos', () => {
    const bad = validarAvisoDisponibilidadApi({ producto_id: 1, telefono: '123' });
    assert.equal(bad.ok, false);
    assert.ok(bad.errors.includes('telefono'));
  });

  it('normaliza teléfono y acepta nombre opcional', () => {
    const ok = validarAvisoDisponibilidadApi({
      producto_id: 42,
      telefono: '55-1234-5678',
      nombre: 'Ana',
    });
    assert.equal(ok.ok, true);
    assert.equal(ok.value.cliente_telefono, '5512345678');
    assert.equal(ok.value.cliente_nombre, 'Ana');
    assert.equal(ok.value.producto_id, 42);
  });

  it('honeypot website', () => {
    const hp = validarAvisoDisponibilidadApi({
      producto_id: 1,
      telefono: '5512345678',
      website: 'spam',
    });
    assert.equal(hp.honeypot, true);
  });
});
