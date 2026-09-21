'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { feeEnvioParaPreferencia, desgloseCuadraPreferencia } = require('./preferenciaEnvioGuard');

describe('feeEnvioParaPreferencia', () => {
  it('rechaza domicilio sin cotización (costo_envio null no cuenta como $0 cotizado)', () => {
    const r = feeEnvioParaPreferencia({
      tipo_entrega: 'envio',
      costo_envio: null,
      logistics_meta: {},
    });
    assert.equal(r.ok, false);
    assert.equal(r.error, 'envio_quote_required');
  });

  it('toma el envío de la columna o de la meta cotizada', () => {
    assert.deepEqual(
      feeEnvioParaPreferencia({
        tipo_entrega: 'envio',
        costo_envio: 90,
        logistics_meta: { envio: { estado: 'cotizado', costo_cotizado: 90, cobrado_en_checkout: true } },
      }),
      { ok: true, fee: 90 }
    );
    assert.equal(
      feeEnvioParaPreferencia({
        tipo_entrega: 'envio',
        logistics_meta: { envio: { estado: 'cotizado', costo_cotizado: 95 } },
      }).fee,
      95
    );
  });

  it('pick-up no lleva envío', () => {
    assert.deepEqual(feeEnvioParaPreferencia({ tipo_entrega: 'recoger' }), { ok: true, fee: 0 });
  });
});

describe('desgloseCuadraPreferencia', () => {
  it('305 + 90 = 395 como el pago de Alejandro', () => {
    const r = desgloseCuadraPreferencia({ totalDb: 395, envioFee: 90, cargo: 0 });
    assert.equal(r.ok, true);
    assert.equal(r.productsTotal, 305);
    assert.equal(r.envioFee, 90);
  });
});
