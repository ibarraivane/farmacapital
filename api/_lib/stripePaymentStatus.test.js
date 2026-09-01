'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  mapStripePaymentIntentStatus,
  amountToStripeCents,
  stripeCentsToMxn,
  pedidoIdFromStripePaymentIntent,
} = require('./stripePaymentStatus');

describe('mapStripePaymentIntentStatus', () => {
  it('maps succeeded to approved', () => {
    assert.deepEqual(mapStripePaymentIntentStatus('succeeded'), {
      payment_status: 'approved',
      approved: true,
    });
  });

  it('maps processing to pending', () => {
    assert.equal(mapStripePaymentIntentStatus('processing').payment_status, 'pending');
    assert.equal(mapStripePaymentIntentStatus('processing').approved, false);
  });

  it('maps canceled to rejected', () => {
    assert.deepEqual(mapStripePaymentIntentStatus('canceled'), {
      payment_status: 'rejected',
      approved: false,
    });
  });
});

describe('amount helpers', () => {
  it('converts MXN to cents', () => {
    assert.equal(amountToStripeCents(199.5), 19950);
    assert.equal(amountToStripeCents(10), 1000);
    assert.equal(amountToStripeCents(0), null);
  });

  it('converts cents to MXN', () => {
    assert.equal(stripeCentsToMxn(19950), 199.5);
  });
});

describe('pedidoIdFromStripePaymentIntent', () => {
  it('reads metadata.pedido_id', () => {
    assert.equal(pedidoIdFromStripePaymentIntent({ metadata: { pedido_id: '42' } }), 42);
  });

  it('parses FARMACAPITAL-PED ref', () => {
    assert.equal(
      pedidoIdFromStripePaymentIntent({ metadata: { external_reference: 'FARMACAPITAL-PED-99' } }),
      99
    );
  });
});
