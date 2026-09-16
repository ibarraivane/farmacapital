/**
 * Precio de la TIENDA WEB.
 *
 * - Cada tarjeta: ancla + 3.49% + IVA. POS no se toca.
 * - Una vez por PEDIDO: Servicio $5 (peso entero; cubre el $4+IVA de MP).
 *   No es un SKU. Va en carrito y checkout.
 *
 * Espejo: api/_lib/precioOnlineMp.js y public.fc_precio_online_mp(numeric).
 */

export const TASA_MP_ONLINE = 0.040484;
export const FIJO_MP_MXN = 4;
export const IVA_MP = 1.16;
export const FIJO_MP_CON_IVA = FIJO_MP_MXN * IVA_MP; // 4.64
export const CARGO_SERVICIO_MXN = 5;

export const CONCEPTO_CARGO_PLATAFORMA = "Servicio";

/** Precios <= $0.01 son placeholder de alta: no se pueden pagar en línea. */
export const PRECIO_PLACEHOLDER_MAX = 0.01;

export function precioAnclaUsable(precio) {
  const n = Number(precio);
  return Number.isFinite(n) && n > PRECIO_PLACEHOLDER_MAX;
}

/** Ancla → precio de tarjeta (solo %). null si no hay ancla usable. */
export function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = Number(precioLista) / (1 - TASA_MP_ONLINE);
  return Math.ceil(Math.round(bruto * 100) / 100);
}

/** Servicio $5, una vez por pedido en línea. */
export function cargoPlataformaOnline() {
  return CARGO_SERVICIO_MXN;
}

/** @deprecated usar cargoPlataformaOnline */
export function cargoFijoMp() {
  return cargoPlataformaOnline();
}

/** Subtotal de productos + servicio (una vez), peso entero. */
export function totalPedidoConPlataforma(subProductos) {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b + cargoPlataformaOnline());
}

/** @deprecated usar totalPedidoConPlataforma */
export function totalConCargoMp(base) {
  return totalPedidoConPlataforma(base);
}
