/**
 * Precio de la TIENDA WEB.
 *
 * - Cada tarjeta: ancla + 3.49% + IVA. POS no se toca.
 * - El Servicio de plataforma ya no se cobra al cliente (CARGO_SERVICIO_MXN = 0).
 *   Pick-up y envío: sin cargo aparte. La comisión de MP se absorbe en el margen.
 *
 * Espejo: api/_lib/precioOnlineMp.js y public.fc_cargo_plataforma_online().
 */

export const TASA_MP_ONLINE = 0.040484;
export const FIJO_MP_MXN = 4;
export const IVA_MP = 1.16;
export const FIJO_MP_CON_IVA = FIJO_MP_MXN * IVA_MP; // 4.64
/** Antes $5 por pedido con envío. Ahora $0: no se cobra Servicio al cliente. */
export const CARGO_SERVICIO_MXN = 0;

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

/** True si el cliente recoge en farmacia. */
export function esEntregaPickup(entrega) {
  const e = String(entrega ?? "").toLowerCase().trim();
  return e === "pickup" || e === "recoger" || e === "web_pickup" || e === "pickup_store";
}

/**
 * Cargo de plataforma por pedido. Hoy siempre $0 (ya no se cobra Servicio).
 * Pick-up y envío quedan iguales. Se deja la función para no romper callers.
 * @param {{ entrega?: string, entregaUi?: string, tipo_entrega?: string }} [opts]
 */
export function cargoPlataformaOnline(opts = {}) {
  void opts;
  return CARGO_SERVICIO_MXN;
}

/** @deprecated usar cargoPlataformaOnline */
export function cargoFijoMp(opts) {
  return cargoPlataformaOnline(opts);
}

/** Subtotal de productos + servicio (si aplica), peso entero. */
export function totalPedidoConPlataforma(subProductos, opts) {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b + cargoPlataformaOnline(opts || {}));
}

/** @deprecated usar totalPedidoConPlataforma */
export function totalConCargoMp(base, opts) {
  return totalPedidoConPlataforma(base, opts);
}
