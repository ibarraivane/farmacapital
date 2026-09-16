/**
 * Config métodos de pago / checkout online (FarmaCapital).
 * Valores [CONFIGURABLE] — defaults de negocio 15-sep-2026.
 */

function numEnv(keys, fallback) {
  for (const k of keys) {
    const raw = typeof process !== "undefined" ? process.env?.[k] : undefined;
    if (raw == null || String(raw).trim() === "") continue;
    const n = Number(raw);
    if (Number.isFinite(n) && n >= 0) return n;
  }
  return fallback;
}

/** Mínimo de productos (antes de envío) para domicilio / prepago online. Pickup sin mínimo. */
export function montoMinimoPedidoOnline() {
  return numEnv(
    ["REACT_APP_MONTO_MINIMO_PEDIDO_ONLINE", "MONTO_MINIMO_PEDIDO_ONLINE"],
    150
  );
}

/** Factor de recargo integrado al precio de canal MP (domicilio). Pickup = 0. */
export function recargoCatalogoOnline() {
  return numEnv(
    ["REACT_APP_RECARGO_CATALOGO_ONLINE", "RECARGO_CATALOGO_ONLINE"],
    0.08
  );
}

export function mensajeMontoMinimoPedidoOnline(min = montoMinimoPedidoOnline()) {
  const m = Number(min);
  const pretty = Number.isFinite(m) ? m.toFixed(m % 1 ? 2 : 0) : "150";
  return `El pedido a domicilio tiene un mínimo de $${pretty} en productos (antes de envío). Agrega algo más al carrito o recógelo en farmacia sin mínimo.`;
}

/** true si el subtotal de productos alcanza el mínimo para canal envío. */
export function cumpleMontoMinimoEnvio(subtotalProductos, min = montoMinimoPedidoOnline()) {
  const sub = Number(subtotalProductos);
  const m = Number(min);
  if (!Number.isFinite(sub) || !Number.isFinite(m)) return false;
  return sub + 1e-9 >= m;
}
