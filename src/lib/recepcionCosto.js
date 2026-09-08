/**
 * Costo que Recibir pone solo: ticket → catálogo → última compra.
 * El vendedor lo corrobora; la caducidad sigue saliendo de la caja.
 */

export function parseCostoRecepcion(val) {
  const n = Number(val);
  return Number.isFinite(n) && n > 0 ? n : null;
}

export function mensajeErrorRecepcion(error) {
  const msg = error?.message || String(error || "");
  if (/solo se edita una recepcion en borrador/i.test(msg)) {
    return "Este ticket ya no está en borrador. Recibir lo muestra porque faltan cajas, pero no deja grabar la caducidad. Corre sql/patch_recibir_guardar_caducidad_vivo_20260908.sql y reintenta.";
  }
  return msg;
}

export function costoSugeridoRecepcion({ item, producto, ultimaCompra } = {}) {
  return (
    parseCostoRecepcion(item?.costo_estimado)
    ?? parseCostoRecepcion(item?.costo)
    ?? parseCostoRecepcion(producto?.costo)
    ?? parseCostoRecepcion(ultimaCompra?.precio)
    ?? parseCostoRecepcion(ultimaCompra?.costo)
    ?? null
  );
}
