/**
 * Precio de cobro canal Mercado Pago (domicilio / prepago).
 * El recargo va integrado al precio mostrado; nunca como línea «comisión».
 * pedido_items.precio_unitario sigue siendo el precio base/oferta (sin recargo).
 */
import { recargoCatalogoOnline } from "../config/metodosPago";
import { pesoPublico } from "../utils/pesoPublico";

/** Redondeo a 2 decimales MXN. */
export function roundMxn(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.round(x * 100) / 100;
}

/**
 * @param {number} precioBase oferta/lista sin recargo
 * @param {number} [factor] default RECARGO_CATALOGO_ONLINE
 */
export function precioConRecargoCatalogo(precioBase, factor = recargoCatalogoOnline()) {
  const base = pesoPublico(precioBase);
  const f = Number(factor);
  if (!Number.isFinite(f) || f <= 0) return roundMxn(base);
  return roundMxn(base * (1 + f));
}

/**
 * Desglose de un carrito para canal MP.
 * @param {Array<{ precioBase: number, qty: number }>} lines
 * @param {number} [factor]
 */
export function desgloseRecargoPedido(lines, factor = recargoCatalogoOnline()) {
  let subtotal = 0;
  let cobrado = 0;
  for (const line of lines || []) {
    const qty = Number(line.qty) || 0;
    const base = pesoPublico(line.precioBase);
    subtotal = roundMxn(subtotal + base * qty);
    cobrado = roundMxn(cobrado + precioConRecargoCatalogo(base, factor) * qty);
  }
  const recargo = roundMxn(cobrado - subtotal);
  return {
    subtotal_productos: subtotal,
    recargo_procesamiento_pago: recargo,
    monto_cobrado_mercadopago: cobrado,
  };
}
