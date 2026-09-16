/**
 * Precio de la TIENDA WEB con el costo de Mercado Pago incluido.
 *
 * - `productos.precio` guarda el ANCLA de mostrador (costo + margen de lista).
 * - En la web (catálogo, bandas, bajo pedido) el cliente ve y paga el precio
 *   final. El checkout SOLO suma esas líneas (más envío si es domicilio).
 *   Nunca se agrega una línea de comisión / $4 en el carrito.
 * - POS / mostrador: ancla sin incremento.
 *
 * Checkout MX «al instante»: 3.49% + $4 MXN + IVA 16% sobre toda la comisión.
 * El $4 es por cobro, no por SKU; se mete en cada tarjeta para que un artículo
 * barato no deje a la farmacia en pérdida. En carritos de varios productos
 * el $4 se cubre de más (no se pierde).
 *
 *   web = ceil(round((ancla + 4×1.16) / (1 − 3.49%×1.16), 2))
 *
 * Espejo exacto en SQL: public.fc_precio_online_mp(numeric) y api/_lib/precioOnlineMp.js.
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

/** Ancla → precio web final (peso entero hacia arriba). null si no hay ancla usable. */
export function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = (Number(precioLista) + FIJO_MP_CON_IVA) / (1 - TASA_MP_ONLINE);
  // Redondeo a centavos antes del ceil: evita que 105.0000000001 suba a 106.
  return Math.ceil(Math.round(bruto * 100) / 100);
}
