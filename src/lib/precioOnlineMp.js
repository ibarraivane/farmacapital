/**
 * Precio web de productos BAJO PEDIDO con el costo de Mercado Pago incluido.
 *
 * Regla fija (contrato bajo pedido):
 * - `productos.precio` guarda el ANCLA de mostrador (costo + margen de lista).
 * - En la tienda web, solo líneas `bajo_pedido`, el cliente ve y paga
 *   ceilPeso(ancla / (1 - tasa)). Se aplica UNA vez; el checkout no suma recargo.
 * - Productos con stock (catálogo normal) y POS: ancla sin incremento.
 *
 * Tasa: Checkout MX 3.49% + IVA 16% = 4.0484%.
 * Espejo exacto en SQL: public.fc_precio_online_mp(numeric) y api/_lib/precioOnlineMp.js.
 */

export const TASA_MP_ONLINE = 0.040484;

/** Precios <= $0.01 son placeholder de alta: no se pueden pagar en línea. */
export const PRECIO_PLACEHOLDER_MAX = 0.01;

export function precioAnclaUsable(precio) {
  const n = Number(precio);
  return Number.isFinite(n) && n > PRECIO_PLACEHOLDER_MAX;
}

/** Ancla → precio web (peso entero hacia arriba). null si no hay ancla usable. */
export function precioOnlineMp(precioLista) {
  if (!precioAnclaUsable(precioLista)) return null;
  const bruto = Number(precioLista) / (1 - TASA_MP_ONLINE);
  // Redondeo a centavos antes del ceil: evita que 105.0000000001 suba a 106.
  return Math.ceil(Math.round(bruto * 100) / 100);
}
