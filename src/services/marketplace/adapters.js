/**
 * Adaptadores placeholder para integraciones externas (sin credenciales).
 *
 * - Rappi / Uber Eats: típicamente reciben pedidos vía API del marketplace o tablet;
 *   aquí solo definimos la forma esperada del payload y puntos de enganche.
 * - Uber Direct: última milla desde FarmaCapital; crear entrega programmatically cuando exista token.
 *
 * Ver: docs/DELIVERY_MARKETPLACE_PREP.md
 */

/** @typedef {{ external_order_id?: string, provider: string, raw?: object }} MarketplaceOrderRef */

/**
 * Normaliza un pedido interno a snapshot para enviar a un conector (futuro).
 * @param {object} pedido - fila pedidos + items
 * @returns {object}
 */
export function toMarketplaceOutboundSnapshot(pedido) {
  return {
    farmacapital_pedido_id: pedido?.id,
    total: pedido?.total,
    estado: pedido?.estado,
    tipo_entrega: pedido?.tipo_entrega,
    logistics_meta: pedido?.logistics_meta || {},
    items: pedido?.pedido_items || [],
  };
}

/** Placeholder: registrar pedido entrante desde Rappi (implementar con API real). */
export async function ingestRappiOrderPlaceholder(_payload) {
  return {
    ok: false,
    error: "Integración Rappi no configurada. Ver docs/DELIVERY_MARKETPLACE_PREP.md",
  };
}

/** Placeholder: registrar pedido entrante desde Uber Eats. */
export async function ingestUberEatsOrderPlaceholder(_payload) {
  return {
    ok: false,
    error: "Integración Uber Eats no configurada. Ver docs/DELIVERY_MARKETPLACE_PREP.md",
  };
}

/** Placeholder: solicitar recolección Uber Direct (requiere cuenta + OAuth/API). */
export async function requestUberDirectDeliveryPlaceholder(_args) {
  return {
    ok: false,
    error: "Uber Direct no configurado. Definir credenciales y flujo de cotización.",
  };
}
