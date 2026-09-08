/**
 * Costo que Recibir pone solo: ticket → catálogo → última compra.
 * El vendedor lo corrobora; la caducidad sigue saliendo de la caja.
 */

export function parseCostoRecepcion(val) {
  const n = Number(val);
  return Number.isFinite(n) && n > 0 ? n : null;
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
