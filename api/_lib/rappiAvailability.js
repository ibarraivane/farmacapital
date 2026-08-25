'use strict';

/** Reserva de mostrador por defecto: no publicar las últimas 2 piezas. */
const DEFAULT_RESERVA = 2;
/** Umbral extra: encolar si stock_rappi cruza 5 (además del on/off). */
const DEFAULT_THRESHOLD = 5;

function toInt(value, fallback) {
  const n = Number(value);
  if (!Number.isFinite(n)) return fallback;
  return Math.trunc(n);
}

/**
 * stock_rappi = GREATEST(stock - reserva_mostrador, 0)
 * @param {unknown} stock
 * @param {unknown} [reserva]
 */
function calcStockRappi(stock, reserva = DEFAULT_RESERVA) {
  const s = Math.max(0, toInt(stock, 0));
  const r = Math.max(0, toInt(reserva, DEFAULT_RESERVA));
  return Math.max(s - r, 0);
}

/**
 * @param {unknown} stock
 * @param {unknown} [reserva]
 * @param {boolean} [eligible]
 */
function calcDisponibleRappi(stock, reserva = DEFAULT_RESERVA, eligible = true) {
  return Boolean(eligible) && calcStockRappi(stock, reserva) > 0;
}

function productoEligibleRappi(producto) {
  if (!producto) return false;
  if (producto.activo === false) return false;
  if (producto.requiere_receta) return false;
  if (producto.controlado) return false;
  return true;
}

function crossedThreshold(oldStockRappi, newStockRappi, threshold = DEFAULT_THRESHOLD) {
  const t = Math.max(0, toInt(threshold, DEFAULT_THRESHOLD));
  return (oldStockRappi <= t) !== (newStockRappi <= t);
}

/**
 * Encolar solo si cambió disponible_rappi o si stock_rappi cruzó el umbral.
 * @param {object} args
 * @returns {{ enqueue: boolean, reason: string|null, oldStockRappi: number, newStockRappi: number, oldDisponible: boolean, newDisponible: boolean }}
 */
function shouldEnqueueDisponibilidad(args) {
  const reserva = args?.reserva ?? DEFAULT_RESERVA;
  const threshold = args?.threshold ?? DEFAULT_THRESHOLD;
  const oldEligible = args?.oldEligible !== false;
  const newEligible = args?.newEligible !== false;
  const oldStockRappi = calcStockRappi(args?.oldStock, reserva);
  const newStockRappi = calcStockRappi(args?.newStock, reserva);
  const oldDisponible = calcDisponibleRappi(args?.oldStock, reserva, oldEligible);
  const newDisponible = calcDisponibleRappi(args?.newStock, reserva, newEligible);

  if (oldDisponible !== newDisponible) {
    return {
      enqueue: true,
      reason: 'availability',
      oldStockRappi,
      newStockRappi,
      oldDisponible,
      newDisponible,
    };
  }
  if (newDisponible && crossedThreshold(oldStockRappi, newStockRappi, threshold)) {
    return {
      enqueue: true,
      reason: 'threshold',
      oldStockRappi,
      newStockRappi,
      oldDisponible,
      newDisponible,
    };
  }
  return {
    enqueue: false,
    reason: null,
    oldStockRappi,
    newStockRappi,
    oldDisponible,
    newDisponible,
  };
}

function buildDisponibilidadPayload({ sku, productoId, stock, reserva, eligible }) {
  const stockRappi = calcStockRappi(stock, reserva);
  const disponible = calcDisponibleRappi(stock, reserva, eligible);
  return {
    sku: String(sku || '').trim(),
    producto_id: productoId ?? null,
    stock_local: toInt(stock, 0),
    reserva_mostrador: Math.max(0, toInt(reserva, DEFAULT_RESERVA)),
    stock_rappi: stockRappi,
    disponible,
    eligible: Boolean(eligible),
  };
}

module.exports = {
  DEFAULT_RESERVA,
  DEFAULT_THRESHOLD,
  calcStockRappi,
  calcDisponibleRappi,
  productoEligibleRappi,
  crossedThreshold,
  shouldEnqueueDisponibilidad,
  buildDisponibilidadPayload,
};
