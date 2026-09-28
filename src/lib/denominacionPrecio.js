/** Mínima denominación del precio de venta: $0.50. */
export const PASO_PRECIO_VENTA = 0.5;

/**
 * Ajusta un precio al múltiplo de $0.50 más cercano.
 * 10.24 → 10.00 · 10.25 → 10.50 · 1.20 → 1.00 · 1.30 → 1.50.
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

/** Precio con centavos: $10.00, $1.50. */
export function fmtPrecioInventario(n) {
  const p = parseFloat(n);
  if (!Number.isFinite(p)) return "—";
  return `$${p.toFixed(2)}`;
}

/** Mismas cifras que fmtPrecioInventario, sin el signo de pesos. */
export function cifrasPrecioInventario(n) {
  const shown = fmtPrecioInventario(n);
  if (shown === "—") return "";
  return shown.replace("$", "");
}
