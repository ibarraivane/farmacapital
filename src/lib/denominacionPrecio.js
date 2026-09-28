/** Mínima denominación del precio de venta en inventario: $0.50. */
export const PASO_PRECIO_VENTA = 0.5;

/**
 * Ajusta un precio de venta al múltiplo de $0.50 más cercano.
 * 10.24 → 10.00 · 10.25 → 10.50 · 10.75 → 11.00.
 * Vacío o negativo → null. Cero se queda en cero.
 */
export function snapPrecioVenta(valor) {
  if (valor == null || valor === "") return null;
  const raw = typeof valor === "number" ? valor : parseFloat(String(valor).trim().replace(",", "."));
  if (!Number.isFinite(raw) || raw < 0) return null;
  const centavos = Math.round(raw * 100);
  const snapped = Math.round(centavos / 50) * 50;
  return snapped / 100;
}

/** Precio de inventario con centavos: $10.00, $10.50. */
export function fmtPrecioInventario(n) {
  const p = parseFloat(n);
  if (!Number.isFinite(p)) return "—";
  return `$${p.toFixed(2)}`;
}
