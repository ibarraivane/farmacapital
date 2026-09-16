/**
 * Precio de cobro canal Mercado Pago (domicilio / prepago).
 * El recargo va integrado al precio mostrado; nunca como línea «comisión».
 * pedido_items.precio_unitario sigue siendo el precio base/oferta (sin recargo).
 *
 * Default 0.08 = RECARGO_CATALOGO_ONLINE; el caller puede pasar
 * recargoCatalogoOnline() desde src/config/metodosPago.js.
 */

const DEFAULT_RECARGO = 0.08;

function pesoEntero(n) {
  const x = parseFloat(n);
  if (!Number.isFinite(x) || x <= 0) return 0;
  return Math.round(x);
}

/** Redondeo a 2 decimales MXN (cobro con recargo puede llevar centavos). */
export function roundMxn(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.round(x * 100) / 100;
}

/**
 * @param {number} precioBase oferta/lista sin recargo (pesos enteros típicos)
 * @param {number} [factor] default 0.08
 */
export function precioConRecargoCatalogo(precioBase, factor = DEFAULT_RECARGO) {
  const base = pesoEntero(precioBase);
  const f = Number(factor);
  if (!Number.isFinite(f) || f <= 0) return roundMxn(base);
  return roundMxn(base * (1 + f));
}

/**
 * Desglose de un carrito para canal MP.
 * @param {Array<{ precioBase: number, qty: number }>} lines
 * @param {number} [factor]
 */
export function desgloseRecargoPedido(lines, factor = DEFAULT_RECARGO) {
  let subtotal = 0;
  let cobrado = 0;
  for (const line of lines || []) {
    const qty = Number(line.qty) || 0;
    const base = pesoEntero(line.precioBase);
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
