'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  haversineKm,
  lookupTarifa,
  calcularCostoEnvio,
  estimarEnvioDesdeCoords,
  getEnvioConfig,
  coloniaEsPropia,
  proveedorSugerido,
  deadlineCotizacionIso,
  cotizacionVencida,
  puedeDespacharEnvio,
  DEFAULT_TARIFAS,
} = require('./envioDomicilio');

describe('envioDomicilio tarifas y radio', () => {
  it('tramo 0–2 km cobra $30 y es gratis desde $180', () => {
    const a = calcularCostoEnvio({ distanciaKm: 0, subtotal: 100 });
    assert.equal(a.ok, true);
    assert.equal(a.costo, 30);
    const b = calcularCostoEnvio({ distanciaKm: 2, subtotal: 180 });
    assert.equal(b.ok, true);
    assert.equal(b.costo, 0);
    assert.equal(b.gratis, true);
  });

  it('tramo 2–4 y 4–5', () => {
    assert.equal(calcularCostoEnvio({ distanciaKm: 2.01, subtotal: 50 }).costo, 45);
    assert.equal(calcularCostoEnvio({ distanciaKm: 4, subtotal: 50 }).costo, 45);
    assert.equal(calcularCostoEnvio({ distanciaKm: 4.01, subtotal: 50 }).costo, 65);
    assert.equal(calcularCostoEnvio({ distanciaKm: 5, subtotal: 50 }).costo, 65);
    assert.equal(calcularCostoEnvio({ distanciaKm: 5, subtotal: 320 }).costo, 0);
  });

  it('rechaza 5.01 km y sin tramo', () => {
    const r = calcularCostoEnvio({ distanciaKm: 5.01, radioMaximoKm: 5 });
    assert.equal(r.ok, false);
    assert.equal(r.error, 'fuera_radio');
    assert.equal(lookupTarifa(5.01, DEFAULT_TARIFAS), null);
  });

  it('lee config de env sin hardcode de negocio', () => {
    const cfg = getEnvioConfig({
      RADIO_MAXIMO_KM: '4',
      TIEMPO_MAXIMO_COTIZACION_MIN: '12',
      ENVIO_PROVEEDOR_DEFAULT: 'didi',
      FACTOR_COLCHON_PREAUTORIZACION: '1.4',
      ENVIO_COLONIAS_PROPIO: 'Chinampac de Juárez, Reforma Política',
    });
    assert.equal(cfg.radioMaximoKm, 4);
    assert.equal(cfg.tiempoMaximoCotizacionMin, 12);
    assert.equal(cfg.proveedorDefault, 'didi');
    assert.equal(cfg.factorColchonPreautorizacion, 1.4);
    assert.ok(coloniaEsPropia('Col. Chinampac de Juarez', cfg.coloniasPropio));
    assert.equal(proveedorSugerido('Reforma Política', cfg), 'propio');
    assert.equal(proveedorSugerido('Roma Norte', cfg), 'didi');
  });
});

describe('envioDomicilio distancia', () => {
  it('haversine de la sucursal a ~0 km', () => {
    const d = haversineKm(19.3714047, -99.0526916, 19.3714047, -99.0526916);
    assert.equal(d, 0);
  });

  it('estima dentro y fuera de radio desde coords', () => {
    const cfg = getEnvioConfig({});
    const cerca = estimarEnvioDesdeCoords({
      lat: 19.375, lng: -99.055, subtotal: 80, config: cfg,
    });
    assert.equal(cerca.ok, true);
    assert.ok(cerca.distancia_km < 5);
    const lejos = estimarEnvioDesdeCoords({
      lat: 19.43, lng: -99.19, subtotal: 80, config: cfg,
    });
    assert.equal(lejos.ok, false);
    assert.equal(lejos.error, 'fuera_radio');
  });
});

describe('envioDomicilio SLA y despacho', () => {
  it('deadline y vencido', () => {
    const iso = deadlineCotizacionIso(new Date('2026-09-15T18:00:00Z'), 15);
    assert.equal(iso, '2026-09-15T18:15:00.000Z');
    assert.equal(cotizacionVencida('2026-09-15T18:14:00Z', new Date('2026-09-15T18:15:00Z')), true);
    assert.equal(cotizacionVencida('2026-09-15T18:16:00Z', new Date('2026-09-15T18:15:00Z')), false);
  });

  it('solo despacha si pagó o el envío es gratis', () => {
    assert.equal(puedeDespacharEnvio({ estado: 'pagado', costo_cotizado: 45 }), true);
    assert.equal(puedeDespacharEnvio({ estado: 'cotizado', costo_cotizado: 0 }), true);
    assert.equal(puedeDespacharEnvio({ estado: 'cotizado', costo_cotizado: 45 }), false);
    assert.equal(puedeDespacharEnvio({ estado: 'pendiente_cotizacion' }), false);
    assert.equal(puedeDespacharEnvio({
      estado: 'cotizado', costo_cotizado: 45, cobrado_en_checkout: true,
    }), false);
    assert.equal(puedeDespacharEnvio({
      estado: 'cotizado', costo_cotizado: 45, cobrado_en_checkout: true,
    }, { paymentApproved: true }), true);
  });
});
