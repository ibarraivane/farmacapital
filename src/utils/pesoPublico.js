import { snapPrecioVenta } from "../lib/denominacionPrecio";

/** Cobro al público: de $0.50 en $0.50. $1.50 se queda en $1.50. */

export function pesoPublico(n) {
  const x = snapPrecioVenta(n);
  if (x == null || x <= 0) return 0;
  return x;
}

/** Importe de una línea del ticket (unitario ya en pesos × cantidad). */
export function cobroLinea(precio, qty = 1, descuentoPct = 0) {
  const bruto = (parseFloat(precio) || 0) * (1 - (parseFloat(descuentoPct) || 0) / 100);
  return pesoPublico(bruto) * (parseInt(qty, 10) || 0);
}
