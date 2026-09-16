/**
 * Precio de la TIENDA WEB.
 *
 * - Cada tarjeta: ancla + 3.49% + IVA. POS no se toca.
 * - Servicio $5 una vez, solo si el pedido es a domicilio.
 *   Pick-up: no se cobra (pagan en la terminal de la farmacia).
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

/** Domicilio (cdmx / envio / foraneo). Pick-up / recoger no lleva Servicio. */
export function esEntregaConServicio(entrega) {
  const t = String(entrega || "")
    .trim()
    .toLowerCase();
  return t === "envio" || t === "cdmx" || t === "foraneo";
}

/** Servicio $5 si es domicilio; $0 si es pick-up. */
export function cargoPlataformaOnline(entrega = "envio") {
  return esEntregaConServicio(entrega) ? CARGO_SERVICIO_MXN : 0;
}

/** @deprecated usar cargoPlataformaOnline */
export function cargoFijoMp(entrega) {
  return cargoPlataformaOnline(entrega);
}

/** Subtotal de productos + servicio (si aplica), peso entero. */
export function totalPedidoConPlataforma(subProductos, entrega = "envio") {
  const b = Number(subProductos);
  if (!Number.isFinite(b) || b <= 0) return null;
  return Math.round(b + cargoPlataformaOnline(entrega));
}

/** @deprecated usar totalPedidoConPlataforma */
export function totalConCargoMp(base, entrega) {
  return totalPedidoConPlataforma(base, entrega);
}
