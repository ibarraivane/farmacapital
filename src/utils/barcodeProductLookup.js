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

/** Coincidencia flexible EAN-13 / UPC-A (pistola vs BD con dígito extra). */
export function barcodeDigitsMatch(scanRaw, storedRaw) {
  const scan = normalizeBarcodeRaw(scanRaw);
  const stored = normalizeBarcodeRaw(storedRaw);
  if (!scan || !stored) return false;
  if (scan === stored) return true;
  if (stored.startsWith(scan) && stored.length - scan.length <= 1) return true;
  if (scan.startsWith(stored) && scan.length - stored.length <= 1) return true;
  if (scan.length === 12 && stored.length === 13 && stored === `0${scan}`) return true;
  if (stored.length === 12 && scan.length === 13 && scan === `0${stored}`) return true;
  return false;
}

/** Variantes cuando el escáner pega dos códigos seguidos o sobran dígitos. */
export function splitBarcodeCandidates(raw) {
  const t = normalizeBarcodeRaw(raw);
  if (!t) return [];
  const out = [];
  const push = (v) => {
    if (v && !out.includes(v)) out.push(v);
  };
  push(t);
  for (const len of [13, 12, 8]) {
    if (t.length === len * 2) {
      const a = t.slice(0, len);
      const b = t.slice(len);
      push(a);
      push(b);
      if (a === b) push(a);
    }
    if (t.length > len) {
      push(t.slice(0, len));
      push(t.slice(-len));
    }
  }
  return out;
}

function productMatchesScan(product, candidate, qN) {
  if (!product) return false;
  const cb = product.codigo_barras ? String(product.codigo_barras).trim() : "";
  if (cb && barcodeDigitsMatch(candidate, cb)) return true;
  if (product.sku && normalizeForSearch(product.sku) === qN) return true;
  return false;
}

/**
 * Coincidencia exacta por código de barras (EAN/UPC) o SKU interno.
 * Tolera EAN-13 vs 14 dígitos en BD y doble escaneo concatenado.
 */
export function findProductExactScan(products, raw, { activeOnly = true } = {}) {
  const trimmed = normalizeBarcodeRaw(raw);
  if (!trimmed || !Array.isArray(products)) return null;
  const candidates = splitBarcodeCandidates(trimmed);
  const qN = normalizeForSearch(trimmed);

  for (const cand of candidates) {
    const hit = products.find((p) => {
      if (activeOnly && p?.activo === false) return false;
      return productMatchesScan(p, cand, normalizeForSearch(cand));
    });
    if (hit) return hit;
  }

  return (
    products.find((p) => {
      if (activeOnly && p?.activo === false) return false;
      return productMatchesScan(p, trimmed, qN);
    }) || null
  );
}

/** Clave estable del escaneo (para evitar doble agregado). */
export function scanDedupeKey(raw, product) {
  const cb = product?.codigo_barras ? String(product.codigo_barras).trim() : "";
  return cb || normalizeBarcodeRaw(raw) || String(product?.id || "");
}

/**
 * Nueva ráfaga de escaneo: reemplazar campo en lugar de concatenar.
 * Las pistolas envían dígitos muy rápido; pausa >120ms tras código completo = nuevo scan.
 */
export function shouldReplaceScanInput(prevRaw, lastKeyTs, now = Date.now()) {
  const current = normalizeBarcodeRaw(prevRaw);
  if (!current) return false;
  const gap = now - (lastKeyTs || 0);
  // Pistola: dígitos <50ms entre sí; pausa larga solo tras código completo
  if (gap <= 200) return false;
  if ([8, 12, 13, 14].includes(current.length)) return true;
  return false;
}
