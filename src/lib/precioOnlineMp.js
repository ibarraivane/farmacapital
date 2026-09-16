/**
 * Precio de la TIENDA WEB con la comisión % de Mercado Pago incluida.
 *
 * - `productos.precio` = ANCLA de mostrador. POS no se toca.
 * - Cada tarjeta muestra ancla + 3.49% + IVA (4.0484%). Checkout suma esas líneas.
 * - El $4 MXN + IVA es POR TRANSACCIÓN (un cobro), no por producto: se agrega
 *   una sola vez al pagar con Mercado Pago (`cargoFijoMp` / `totalConCargoMp`).
 *   Pickup en tienda (BBVA) no lo lleva.
 *
 * Espejo: api/_lib/precioOnlineMp.js y public.fc_precio_online_mp(numeric).
 */

export const TASA_MP_ONLINE = 0.040484;
export const FIJO_MP_MXN = 4;
export const IVA_MP = 1.16;
export const FIJO_MP_CON_IVA = FIJO_MP_MXN * IVA_MP; // 4.64

/** Precios <= $0.01 son placeholder de alta: no se pueden pagar en línea. */
export const PRECIO_PLACEHOLDER_MAX = 0.01;

export function precioAnclaUsable(precio) {
  const n = Number(precio);
  return Number.isFinite(n) && n > PRECIO_PLACEHOLDER_MAX;
}

/** Ancla → precio de tarjeta (peso entero hacia arriba). null si no hay ancla usable. */
export function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = Number(precioLista) / (1 - TASA_MP_ONLINE);
  return Math.ceil(Math.round(bruto * 100) / 100);
}

/** $4 + IVA, una vez por cobro MP. */
export function cargoFijoMp() {
  return Math.round(FIJO_MP_CON_IVA * 100) / 100;
}

/** Productos (+ envío si ya está cotizado) + cargo fijo de la transacción. */
export function totalConCargoMp(base) {
  const b = Number(base);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round((b + cargoFijoMp()) * 100) / 100;
}
