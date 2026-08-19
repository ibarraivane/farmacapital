/**
 * Forma canónica de un pedido Rappi → FarmaCapital.
 * El webhook real se mapea aquí; no descuenta stock desde el navegador.
 */

function asPositiveQty(value) {
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.trunc(n);
}

function itemFromUnknown(raw) {
  if (!raw || typeof raw !== "object") return null;
  const sku = String(raw.sku || raw.SKU || raw.product_sku || raw.sku_id || "").trim();
  const qty = asPositiveQty(raw.qty ?? raw.quantity ?? raw.cantidad ?? raw.units);
  if (!sku || qty == null) return null;
  return { sku, qty };
}

/**
 * @param {object} payload
 * @returns {{ ok: true, order: object } | { ok: false, error: string }}
 */
export function normalizeRappiInboundOrder(payload) {
  if (!payload || typeof payload !== "object") {
    return { ok: false, error: "payload_invalido" };
  }
  const externalOrderId = String(
    payload.external_order_id ||
      payload.order_id ||
      payload.id ||
      payload.rappi_order_id ||
      ""
  ).trim();
  if (!externalOrderId) {
    return { ok: false, error: "falta_external_order_id" };
  }

  const rawItems = Array.isArray(payload.items)
    ? payload.items
    : Array.isArray(payload.products)
      ? payload.products
      : Array.isArray(payload.order_items)
        ? payload.order_items
        : [];
  const items = [];
  const seen = new Map();
  for (const raw of rawItems) {
    const item = itemFromUnknown(raw);
    if (!item) continue;
    seen.set(item.sku, (seen.get(item.sku) || 0) + item.qty);
  }
  for (const [sku, qty] of seen.entries()) {
    items.push({ sku, qty });
  }
  if (!items.length) {
    return { ok: false, error: "sin_items" };
  }

  return {
    ok: true,
    order: {
      external_order_id: externalOrderId,
      store_id: payload.store_id || payload.storeId || null,
      items,
      raw: payload,
    },
  };
}
