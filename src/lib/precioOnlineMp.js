/**
 * Precio de la TIENDA WEB.
 *
 * - Cada tarjeta: ancla + 3.49% + IVA (4.0484%). POS no se toca.
 * - Una vez por PEDIDO (no por SKU): cargo de plataforma $4 + IVA = $4.64
 *   («Pedido en línea FarmaCapital»). No es un producto. Va en carrito y
 *   checkout para todo pedido web (MP o recoger con BBVA).
 *
 * Espejo: api/_lib/precioOnlineMp.js y public.fc_precio_online_mp(numeric).
 */

export const TASA_MP_ONLINE = 0.040484;
export const FIJO_MP_MXN = 4;
export const IVA_MP = 1.16;
export const FIJO_MP_CON_IVA = FIJO_MP_MXN * IVA_MP; // 4.64

export const CONCEPTO_CARGO_PLATAFORMA = "Pedido en línea FarmaCapital";

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

/** $4 + IVA, una vez por pedido en línea. */
export function cargoPlataformaOnline() {
  return Math.round(FIJO_MP_CON_IVA * 100) / 100;
}

/** @deprecated usar cargoPlataformaOnline */
export function cargoFijoMp() {
  return cargoPlataformaOnline();
}

/** Subtotal de productos + cargo de plataforma (una vez). */
export function totalPedidoConPlataforma(subProductos) {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round((b + cargoPlataformaOnline()) * 100) / 100;
}

/** @deprecated usar totalPedidoConPlataforma */
export function totalConCargoMp(base) {
  return totalPedidoConPlataforma(base);
}
