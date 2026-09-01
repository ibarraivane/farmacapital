/**
 * Adaptadores para integraciones externas.
 *
 * Rappi disponibilidad: cola + worker en api/_lib/rappiSync.js (no llama a Rappi
 * desde el navegador). Pedidos entrantes: POST /api/webhooks/rappi-order.
 *
 * Ver: docs/DELIVERY_MARKETPLACE_PREP.md y sql/patch_rappi_sync_20260819.sql
 */

import { normalizeRappiInboundOrder } from "./rappiOrder";

export { normalizeRappiInboundOrder };

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

/**
 * Ingesta canónica de un pedido Rappi.
 * El navegador no puede descontar stock (F6: escrituras vía RPC service_role).
 * En el servidor, pasar `{ ingest }` (tests) o pegar en POST /api/webhooks/rappi-order.
 *
 * @param {object} payload
 * @param {{ ingest?: (order: object) => Promise<object> }} [deps]
 */
export async function ingestRappiOrderPlaceholder(payload, deps = {}) {
  const normalized = normalizeRappiInboundOrder(payload);
  if (!normalized.ok) return normalized;
  if (typeof deps.ingest === "function") {
    return deps.ingest(normalized.order);
  }
  return {
    ok: false,
    error: "use_server",
    hint: "POST /api/webhooks/rappi-order con RAPPI_WEBHOOK_SECRET. El RPC ingest_rappi_order descuenta stock y guarda external_order_id en logistics_meta.",
    order: normalized.order,
  };
}

/** Placeholder: registrar pedido entrante desde Uber Eats. */
export async function ingestUberEatsOrderPlaceholder(_payload) {
  return {
    ok: false,
    error: "Integración Uber Eats no configurada. Ver docs/DELIVERY_MARKETPLACE_PREP.md",
  };
}

/**
 * Solicitar recolección Uber Direct.
 * El navegador no lleva el secreto: usar POST /api/logistics/uber-direct
 * `{ action: "create", pedidoId }` con sesión de empleado.
 */
export async function requestUberDirectDeliveryPlaceholder(_args) {
  return {
    ok: false,
    error: "use_server",
    hint: "POST /api/logistics/uber-direct action=create con UBER_DIRECT_CLIENT_SECRET. Cotización visible en checkout (la paga el comprador).",
  };
}
