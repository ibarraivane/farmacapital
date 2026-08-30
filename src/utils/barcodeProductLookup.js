import { normalizeForSearch } from "../utils";

/** Texto crudo del escáner (sin normalizar). */
export function normalizeBarcodeRaw(raw) {
  let t = String(raw ?? "").trim();
  t = t.replace(/^[\]C1\][\x00-\x1f]*/i, "");
  t = t.replace(/\s/g, "");
  return t;
}

/**
 * Consulta de catálogo en el POS: conserva espacios ("dolor de cabeza").
 * Si es pistola (solo dígitos), sí se pegan para armar el EAN.
 */
export function queryCatalogoDesdeInputPos(srch) {
  const texto = String(srch || "").trim();
  if (!texto) return "";
  if (isAllDigitsInput(texto)) return normalizeBarcodeRaw(texto);
  return texto;
}

/** Solo dígitos (escaneo en progreso o código completo). */
export function isAllDigitsInput(raw) {
  const t = normalizeBarcodeRaw(raw);
  return t.length > 0 && /^\d+$/.test(t);
}

/** Longitudes de un beep ya armado (EAN-8 / UPC-A / EAN-13 / GTIN-14). */
export const COMPLETE_BARCODE_LENGTHS = [8, 12, 13, 14];

/** Entrada típica de pistola (solo dígitos, EAN/UPC). */
export function looksLikeBarcodeInput(raw) {
  const t = normalizeBarcodeRaw(raw);
  return t.length >= 8 && /^\d+$/.test(t);
}

/** El recuadro ya tiene un EAN/UPC de longitud legal — no un prefijo a medias. */
export function isCompleteBarcodeLength(raw) {
  const t = normalizeBarcodeRaw(raw);
  return COMPLETE_BARCODE_LENGTHS.includes(t.length) && /^\d+$/.test(t);
}

/** Beep listo para buscar: EAN completo o SKU interno (FC-…). */
export function looksLikeCompleteScanInput(raw) {
  return isCompleteBarcodeLength(raw) || looksLikeInternalSku(raw);
}

/**
 * Tras un miss: borrar el recuadro solo si el beep ya cerró.
 * 8 o 12 dígitos en idle pueden ser el arranque de un EAN-13 (Bluetooth / iPad).
 * Enter sí cierra: la pistola mandó el sufijo.
 */
export function shouldClearScanMiss(raw, { fromEnter = false } = {}) {
  const trimmed = String(raw ?? "").trim();
  if (looksLikeInternalSku(trimmed)) return true;
  const t = normalizeBarcodeRaw(raw);
  if (!t || !/^\d+$/.test(t)) return false;
  if (fromEnter) return t.length >= 8;
  return t.length === 13 || t.length === 14;
}

/** SKU interno (FC-…, EQ-…, FMX-…). No es búsqueda por nombre. */
export function looksLikeInternalSku(raw) {
  return /^(FC|EQ|FMX)[-_]/i.test(String(raw || "").trim());
}

/** Un mismo producto con dos empaques (pieza y bote). */
export const EAN_PARES_CONOCIDOS = [
  ["747589705123", "714706903205"], // Broncolin paleta suelta / vitrolero C/50
];

function digitsOnly(raw) {
  return String(raw || "").replace(/\D/g, "");
}

export function eansAliasDe(ean) {
  const d = digitsOnly(ean);
  if (!d) return [];
  const extra = [];
  for (const par of EAN_PARES_CONOCIDOS) {
    if (par.some((p) => barcodeDigitsMatch(d, p))) extra.push(...par);
  }
  return extra;
}

/** Código principal, pares conocidos y EANs escritos en la ficha. */
export function codigosBarrasDeProducto(product) {
  const out = [];
  const push = (v) => {
    const d = digitsOnly(v);
    if (d.length < 8 || d.length > 14) return;
    if (!out.some((x) => barcodeDigitsMatch(d, x))) out.push(d);
  };
  push(product?.codigo_barras);
  for (const a of eansAliasDe(product?.codigo_barras)) push(a);
  const desc = String(product?.descripcion || "");
  for (const m of desc.match(/\d{12,14}/g) || []) push(m);
  return out;
}

/** Coincidencia flexible EAN-13 / UPC-A (pistola vs BD con dígito extra). */
export function barcodeDigitsMatch(scanRaw, storedRaw, { allowNearPrefix = true } = {}) {
  const scan = normalizeBarcodeRaw(scanRaw);
  const stored = normalizeBarcodeRaw(storedRaw);
  if (!scan || !stored) return false;
  if (scan === stored) return true;
  if (scan.length === 12 && stored.length === 13 && stored === `0${scan}`) return true;
  if (stored.length === 12 && scan.length === 13 && scan === `0${stored}`) return true;
  // Prefijo ±1: Enter ya cerró el beep. En idle a 12 dígitos NO: aún puede
  // llegar el dígito 13 del EAN y no hay que agregar ni borrar el recuadro.
  if (allowNearPrefix) {
    if (stored.startsWith(scan) && stored.length - scan.length <= 1) return true;
    if (scan.startsWith(stored) && scan.length - stored.length <= 1) return true;
  }
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

function productMatchesScan(product, candidate, qN, matchOpts) {
  if (!product) return false;
  if (codigosBarrasDeProducto(product).some((cb) => barcodeDigitsMatch(candidate, cb, matchOpts))) return true;
  if (product.sku && normalizeForSearch(product.sku) === qN) return true;
  return false;
}

/**
 * Coincidencia exacta por código de barras (EAN/UPC) o SKU interno.
 * Tolera EAN-13 vs 14 dígitos en BD y doble escaneo concatenado.
 */
export function findProductExactScan(products, raw, { activeOnly = true, allowNearPrefix = true } = {}) {
  const trimmed = normalizeBarcodeRaw(raw);
  if (!trimmed || !Array.isArray(products)) return null;
  const candidates = splitBarcodeCandidates(trimmed);
  const qN = normalizeForSearch(trimmed);
  const matchOpts = { allowNearPrefix };

  for (const cand of candidates) {
    const hit = products.find((p) => {
      if (activeOnly && p?.activo === false) return false;
      return productMatchesScan(p, cand, normalizeForSearch(cand), matchOpts);
    });
    if (hit) return hit;
  }

  return (
    products.find((p) => {
      if (activeOnly && p?.activo === false) return false;
      return productMatchesScan(p, trimmed, qN, matchOpts);
    }) || null
  );
}

/** Clave estable del escaneo (para evitar doble agregado). */
export function scanDedupeKey(raw, product) {
  const cb = product?.codigo_barras ? String(product.codigo_barras).trim() : "";
  return cb || normalizeBarcodeRaw(raw) || String(product?.id || "");
}

/**
 * Nueva ráfaga: reemplazar el campo en lugar de concatenar.
 * Bluetooth en iPad mete pausas de 200–350 ms a mitad de un EAN-13;
 * a los 8 dígitos eso pisaba el código y el POS “se borraba”.
 */
export function shouldReplaceScanInput(prevRaw, lastKeyTs, now = Date.now()) {
  const current = normalizeBarcodeRaw(prevRaw);
  if (!current) return false;
  const gap = now - (lastKeyTs || 0);
  if (gap <= 400) return false;
  // 8 dígitos suele ser el arranque de un EAN-13; no pises.
  return current.length === 12 || current.length === 13 || current.length === 14;
}
