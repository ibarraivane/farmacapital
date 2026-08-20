/** Cobro al público en mostrador: peso entero más cercano. Nunca centavos. */

export function pesoPublico(n) {
  const x = parseFloat(n);
  if (!Number.isFinite(x) || x <= 0) return 0;
  return Math.round(x);
}

/** Importe de una línea del ticket (unitario ya en pesos × cantidad). */
export function cobroLinea(precio, qty = 1, descuentoPct = 0) {
  const bruto = (parseFloat(precio) || 0) * (1 - (parseFloat(descuentoPct) || 0) / 100);
  return pesoPublico(bruto) * (parseInt(qty, 10) || 0);
}
