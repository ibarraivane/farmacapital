import { normalizeForSearch } from "../utils";

/** Texto crudo del escáner (sin normalizar). */
export function normalizeBarcodeRaw(raw) {
  let t = String(raw ?? "").trim();
  t = t.replace(/^[\]C1\][\x00-\x1f]*/i, "");
  t = t.replace(/\s/g, "");
  return t;
}

/** Solo dígitos (escaneo en progreso o código completo). */
export function isAllDigitsInput(raw) {
  const t = normalizeBarcodeRaw(raw);
  return t.length > 0 && /^\d+$/.test(t);
}

/** Entrada típica de pistola (solo dígitos, EAN/UPC). */
export function looksLikeBarcodeInput(raw) {
  const t = normalizeBarcodeRaw(raw);
  return t.length >= 8 && /^\d+$/.test(t);
}

/**
 * Coincidencia exacta por código de barras (EAN/UPC) o SKU interno.
 * Usado en POS, recepción de mercancía y registro de lotes.
 */
export function findProductExactScan(products, raw, { activeOnly = true } = {}) {
  const trimmed = normalizeBarcodeRaw(raw);
  if (!trimmed || !Array.isArray(products)) return null;
  const qN = normalizeForSearch(trimmed);
  return (
    products.find((p) => {
      if (!p) return false;
      if (activeOnly && p.activo === false) return false;
      if (p.codigo_barras && String(p.codigo_barras).trim() === trimmed) return true;
      if (p.sku && normalizeForSearch(p.sku) === qN) return true;
      return false;
    }) || null
  );
}
