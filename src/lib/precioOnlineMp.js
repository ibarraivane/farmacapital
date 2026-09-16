/**
 * Precio de la TIENDA WEB: ancla de mostrador + comisión completa de Mercado Pago.
 *
 * MP al instante: 3.49% + $4 MXN + IVA 16% sobre esa comisión.
 * Para que el neto sea ≥ ancla en UNA pieza:
 *   web = ceil((ancla + 4×1.16) / (1 − 3.49%×1.16))
 *
 * `productos.precio` = ANCLA. El POS no se toca.
 * El checkout solo suma las tarjetas: no se vuelve a cobrar el $4.
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
  const bruto = (Number(precioLista) + FIJO_MP_CON_IVA) / (1 - TASA_MP_ONLINE);
  return Math.ceil(Math.round(bruto * 100) / 100);
}

/** $4 + IVA (ya va dentro de cada tarjeta; no sumar otra vez). */
export function cargoFijoMp() {
  return Math.round(FIJO_MP_CON_IVA * 100) / 100;
}

/** Total a cobrar: lo que ya suman las líneas (sin cargo extra). */
export function totalConCargoMp(base) {
  const b = Number(base);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b * 100) / 100;
}
