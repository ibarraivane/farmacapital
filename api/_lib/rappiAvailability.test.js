'use strict';

const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  calcStockRappi,
  calcDisponibleRappi,
  shouldEnqueueDisponibilidad,
} = require('./rappiAvailability');

describe('rappiAvailability', () => {
  it('aplica reserva de mostrador y no publica 0–2', () => {
    assert.equal(calcStockRappi(5, 2), 3);
    assert.equal(calcStockRappi(2, 2), 0);
    assert.equal(calcStockRappi(1, 2), 0);
    assert.equal(calcDisponibleRappi(2, 2), false);
    assert.equal(calcDisponibleRappi(3, 2), true);
  });

  it('no encola cada unidad vendida si sigue disponible', () => {
    const r = shouldEnqueueDisponibilidad({ oldStock: 20, newStock: 19, reserva: 2 });
    assert.equal(r.enqueue, false);
    assert.equal(r.newDisponible, true);
    assert.equal(r.newStockRappi, 17);
  });

  it('encola cuando pasa de disponible a agotado (con colchón)', () => {
    const r = shouldEnqueueDisponibilidad({ oldStock: 3, newStock: 2, reserva: 2 });
    assert.equal(r.enqueue, true);
    assert.equal(r.reason, 'availability');
    assert.equal(r.oldDisponible, true);
    assert.equal(r.newDisponible, false);
  });

  it('encola si stock_rappi cruza el umbral de 5', () => {
    // stock 8 → 7: stock_rappi 6 → 5, cruza <=5
    const r = shouldEnqueueDisponibilidad({ oldStock: 8, newStock: 7, reserva: 2 });
    assert.equal(r.enqueue, true);
    assert.equal(r.reason, 'threshold');
    assert.equal(r.oldStockRappi, 6);
    assert.equal(r.newStockRappi, 5);
  });

  it('no publica Alka C/100 ni Aspirina 80 (mostrador por pieza)', () => {
    const { productoEligibleRappi, cajasCerradasParaRappi } = require('./rappiAvailability');
    const alka = { activo: true, venta_unidad: true, unidades_por_caja: 100, stock: 35, stock_unidades: 100 };
    assert.equal(productoEligibleRappi(alka), false);
    assert.equal(cajasCerradasParaRappi(alka), 0);
  });

  it('caja abierta descuenta 1 del stock publicado', () => {
    const { cajasCerradasParaRappi, calcStockRappi } = require('./rappiAvailability');
    const saba = { venta_unidad: true, unidades_por_caja: 8, stock: 5, stock_unidades: 8 };
    assert.equal(cajasCerradasParaRappi(saba), 4);
    assert.equal(calcStockRappi(4, 2), 2);
  });

  it('no publica receta/controlado aunque haya stock', () => {
    const r = shouldEnqueueDisponibilidad({
      oldStock: 10,
      newStock: 10,
      oldEligible: true,
      newEligible: false,
      reserva: 2,
    });
    assert.equal(r.enqueue, true);
    assert.equal(r.newDisponible, false);
  });
});
