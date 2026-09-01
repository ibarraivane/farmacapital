'use strict';

const { describe, it, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const {
  feeCentsToMxn,
  mxPhoneE164,
  parseDireccionCheckout,
  dropoffAddressFromParts,
  mapUberDeliveryStatus,
  normalizeQuoteResponse,
  verifyUberWebhookSignature,
  extractUberWebhookDelivery,
  quoteChangedTooMuch,
  buildManifestItems,
  getUberDirectConfig,
  getUberAccessToken,
  resetUberTokenCache,
  pickupAddressFromConfig,
  geocodeQueryFromAddress,
} = require('./uberDirect');

describe('uberDirect helpers', () => {
  it('convierte fee en centavos a pesos', () => {
    assert.equal(feeCentsToMxn(558), 5.58);
    assert.equal(feeCentsToMxn(8500), 85);
    assert.equal(feeCentsToMxn(-1), null);
    assert.equal(feeCentsToMxn('x'), null);
  });

  it('normaliza teléfono MX a E.164', () => {
    assert.equal(mxPhoneE164('55 6253 0631'), '+525562530631');
    assert.equal(mxPhoneE164('525562530631'), '+525562530631');
    assert.equal(mxPhoneE164('+52 55 6253 0631'), '+525562530631');
    assert.equal(mxPhoneE164('123'), '');
  });

  it('arma dropoff desde calle, colonia y CP del checkout', () => {
    const parsed = parseDireccionCheckout('Radiodifusora 50, Chinampac de Juárez, 09208');
    assert.deepEqual(parsed, {
      street: 'Radiodifusora 50',
      colonia: 'Chinampac de Juárez',
      zip: '09208',
    });
    const addr = dropoffAddressFromParts(parsed);
    assert.equal(addr.country, 'MX');
    assert.equal(addr.zip_code, '09208');
    assert.equal(addr.street_address[0], 'Radiodifusora 50, Chinampac de Juárez');
  });

  it('rechaza dirección sin CP de 5 dígitos', () => {
    assert.equal(parseDireccionCheckout('Calle 1, Centro'), null);
    assert.equal(dropoffAddressFromParts({ street: 'x', zip: '12' }), null);
  });

  it('mapea estados Uber a delivery_status interno', () => {
    assert.equal(mapUberDeliveryStatus('pending'), 'courier_requested');
    assert.equal(mapUberDeliveryStatus('pickup'), 'in_route');
    assert.equal(mapUberDeliveryStatus('delivered'), 'delivered');
    assert.equal(mapUberDeliveryStatus('canceled'), 'cancelled');
  });

  it('normaliza cotización MXN', () => {
    const q = normalizeQuoteResponse({
      id: 'dqt_abc',
      fee: 7250,
      currency: 'MXN',
      duration: 32,
      expires: '2026-08-31T23:00:00Z',
    });
    assert.equal(q.ok, true);
    assert.equal(q.fee_mxn, 72.5);
    assert.equal(q.quote_id, 'dqt_abc');
    assert.equal(q.duration_min, 32);
  });

  it('rechaza cotización en otra moneda', () => {
    const q = normalizeQuoteResponse({ id: 'dqt_x', fee: 500, currency: 'USD' });
    assert.equal(q.ok, false);
    assert.equal(q.error, 'quote_currency_not_mxn');
  });

  it('detecta si el precio cambió más de $8', () => {
    assert.equal(quoteChangedTooMuch(80, 84), false);
    assert.equal(quoteChangedTooMuch(80, 90), true);
  });

  it('verifica firma HMAC del webhook', () => {
    const crypto = require('crypto');
    const body = '{"delivery_id":"del_1"}';
    const key = 'test-signing-key';
    const sig = crypto.createHmac('sha256', key).update(body, 'utf8').digest('hex');
    assert.equal(verifyUberWebhookSignature(body, sig, key).ok, true);
    assert.equal(verifyUberWebhookSignature(body, '00' + sig.slice(2), key).ok, false);
    assert.equal(verifyUberWebhookSignature(body, sig, '').ok, false);
  });

  it('extrae delivery_id y status del webhook', () => {
    const ev = extractUberWebhookDelivery({
      event_type: 'event.delivery_status',
      data: { id: 'del_Pw2e2GpnS0Gf0XUjb2xi3R', status: 'delivered', tracking_url: 'https://t' },
      external_id: '1234',
    });
    assert.equal(ev.deliveryId, 'del_Pw2e2GpnS0Gf0XUjb2xi3R');
    assert.equal(ev.status, 'delivered');
    assert.equal(ev.trackingUrl, 'https://t');
    assert.equal(ev.externalId, '1234');
  });

  it('arma manifiesto con fallback', () => {
    assert.equal(buildManifestItems([]).length, 1);
    assert.equal(buildManifestItems([{ nombre: 'Paracetamol', cantidad: 2 }])[0].quantity, 2);
  });

  it('incluye referencia en la segunda línea de calle', () => {
    const addr = dropoffAddressFromParts({
      street: 'José Ignacio Bartolache 1750',
      colonia: 'Del Valle Sur',
      zip: '03104',
      referencia: 'Edificio gris, portero',
    });
    assert.equal(addr.street_address[1], 'Edificio gris, portero');
    assert.match(geocodeQueryFromAddress(addr), /Bartolache/);
  });

  it('pickup de FarmaCapital queda en CDMX', () => {
    const pickup = pickupAddressFromConfig();
    assert.equal(pickup.country, 'MX');
    assert.equal(pickup.zip_code, '09208');
    assert.match(pickup.street_address[0], /Radiodifusora/);
  });
});

describe('uberDirect credentials', () => {
  beforeEach(() => {
    resetUberTokenCache();
    delete process.env.UBER_DIRECT_CLIENT_SECRET;
  });

  it('queda no configurado sin Client Secret', () => {
    const cfg = getUberDirectConfig();
    assert.equal(cfg.configured, false);
    assert.ok(cfg.customerId);
    assert.ok(cfg.clientId);
  });

  it('oauth no llama a Uber si falta el secreto', async () => {
    const res = await getUberAccessToken({
      fetchFn: async () => {
        throw new Error('no debe llamar');
      },
    });
    assert.equal(res.ok, false);
    assert.equal(res.error, 'not_configured');
  });
});
