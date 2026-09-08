/**
 * Costo que Recibir pone solo: ticket → catálogo → última compra.
 * Siempre por pieza. El ticket a veces trae el importe del renglón
 * (2 × 45.89 = 91.78); eso no se guarda como costo unitario.
 * El vendedor lo corrobora; la caducidad sigue saliendo de la caja.
 */

export function parseCostoRecepcion(val) {
  const n = Number(val);
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function roundCostoUnitario(n) {
  return Math.round(Number(n) * 10000) / 10000;
}

export function mensajeErrorRecepcion(error) {
  const msg = error?.message || String(error || "");
  if (/solo se edita una recepcion en borrador/i.test(msg)) {
    return "Este ticket ya no está en borrador. Recibir lo muestra porque faltan cajas, pero no deja grabar la caducidad. Corre sql/patch_recibir_guardar_caducidad_vivo_20260908.sql y reintenta.";
  }
  return msg;
}

/**
 * Si `costo` es el total de N piezas, lo parte. Si ya es unitario, lo deja.
 * No divide un costo de catálogo válido solo porque el renglón traiga qty 2.
 */
export function unidadDesdeImporte(costo, cantidad, { subtotal, unitRef } = {}) {
  const c = parseCostoRecepcion(costo);
  const qty = Number(cantidad);
  const sub = parseCostoRecepcion(subtotal);
  const ref = parseCostoRecepcion(unitRef);

  if (c == null) {
    if (sub != null && qty > 1) return roundCostoUnitario(sub / qty);
    return sub;
  }
  if (!(qty > 1)) return c;

  if (sub != null && Math.abs(c - sub) <= 0.03) {
    return roundCostoUnitario(sub / qty);
  }
  if (
    ref != null
    && c > ref * 1.1
    && Math.abs(c - ref * qty) <= Math.max(0.05, 0.02 * c)
  ) {
    return ref;
  }
  return c;
}

export function costoSugeridoRecepcion({ item, producto, ultimaCompra } = {}) {
  const qty = Number(item?.cantidad);
  const ticket = parseCostoRecepcion(item?.costo_estimado)
    ?? parseCostoRecepcion(item?.costo);
  const sub = parseCostoRecepcion(item?.subtotal ?? item?.importe);
  const cat = parseCostoRecepcion(producto?.costo)
    ?? parseCostoRecepcion(item?.costo_catalogo);
  const uc = parseCostoRecepcion(ultimaCompra?.precio)
    ?? parseCostoRecepcion(ultimaCompra?.costo);

  const delTicket = unidadDesdeImporte(ticket, qty, { subtotal: sub, unitRef: cat ?? uc });
  if (delTicket != null) return delTicket;
  return cat ?? uc ?? null;
}
