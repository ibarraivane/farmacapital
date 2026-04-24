/**
 * Búsqueda tolerante a errores de escritura (distancia de edición) + sugerencias.
 */

import { normalizeForSearch, someFieldIncludesNormalizedQuery } from "../utils";

/** Distancia de Levenshtein (iterativa, O(nm)). */
export function levenshtein(a, b) {
  const s = String(a);
  const t = String(b);
  if (s === t) return 0;
  if (!s.length) return t.length;
  if (!t.length) return s.length;
  let prev = Array.from({ length: t.length + 1 }, (_, j) => j);
  for (let i = 1; i <= s.length; i++) {
    const cur = [i];
    for (let j = 1; j <= t.length; j++) {
      const cost = s[i - 1] === t[j - 1] ? 0 : 1;
      cur[j] = Math.min(cur[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost);
    }
    prev = cur;
  }
  return prev[t.length];
}

/** Mínima distancia entre la consulta y el texto completo o cada palabra (≥2 letras). */
export function minEditDistanceQueryToText(queryNorm, textNorm) {
  if (!queryNorm || !textNorm) return Infinity;
  const full = levenshtein(queryNorm, textNorm);
  const words = textNorm.split(/\s+/).filter((w) => w.length >= 2);
  let m = full;
  for (const w of words) {
    if (Math.abs(w.length - queryNorm.length) > 6) continue;
    const d = levenshtein(queryNorm, w);
    if (d < m) m = d;
  }
  return m;
}

function maxTypoForLength(len) {
  if (len <= 4) return 1;
  if (len <= 7) return 2;
  return Math.min(4, Math.floor(len * 0.35));
}

/**
 * Coincidencia aproximada sobre texto ya normalizado (sin acentos).
 * queryNorm debe tener al menos 2 caracteres.
 */
export function normalizedTextFuzzyMatch(queryNorm, textNorm) {
  if (!queryNorm || queryNorm.length < 2 || !textNorm) return false;
  if (textNorm.includes(queryNorm)) return true;
  const dist = minEditDistanceQueryToText(queryNorm, textNorm);
  const maxLen = Math.max(queryNorm.length, textNorm.length);
  const ratio = maxLen ? dist / maxLen : 1;
  const maxTypo = maxTypoForLength(queryNorm.length);
  return dist <= maxTypo || ratio <= 0.34;
}

/**
 * Incluye coincidencia por subcadena (acentos ignorados) o por similitud ortográfica.
 * valueGetters: funciones (product) => string | null
 */
export function productMatchesSearchQuery(product, queryRaw, valueGetters) {
  if (!String(queryRaw || "").trim()) return true;
  const values = valueGetters.map((fn) => fn(product)).filter((v) => v != null && String(v).trim() !== "");
  if (someFieldIncludesNormalizedQuery(values, queryRaw)) return true;
  const q = normalizeForSearch(queryRaw);
  const tokens = q.split(/\s+/).filter(Boolean);
  if (!tokens.length) return false;
  const normalizedValues = values.map((v) => normalizeForSearch(v));
  return tokens.every((tok) => {
    if (tok.length <= 1) {
      return normalizedValues.some((nv) => nv.includes(tok));
    }
    if (tok.length < 3) {
      return normalizedValues.some((nv) => nv.includes(tok) || normalizedTextFuzzyMatch(tok, nv));
    }
    return normalizedValues.some((nv) => normalizedTextFuzzyMatch(tok, nv));
  });
}

const TIENDA_GETTERS = [
  (x) => x.nombre,
  (x) => x.marca,
  (x) => x.descripcion,
  (x) => x.categoria,
  (x) => x.sku,
  (x) => x.codigo_barras,
  (x) => x.principio_activo,
];

const INVENTARIO_GETTERS = [
  (x) => x.nombre,
  (x) => x.sku,
  (x) => x.codigo_barras,
  (x) => x.categoria,
  (x) => x.descripcion,
  (x) => x.proveedor,
  (x) => x.marca,
  (x) => x.principio_activo,
];

export function tiendaProductMatchesBusqueda(product, queryRaw) {
  return productMatchesSearchQuery(product, queryRaw, TIENDA_GETTERS);
}

export function inventarioProductMatchesBusqueda(product, queryRaw) {
  return productMatchesSearchQuery(product, queryRaw, INVENTARIO_GETTERS);
}

/**
 * Sugerencias cuando no hay resultados: productos con nombre ortográficamente cercano.
 */
export function spellSuggestFromProducts(products, queryRaw, { limit = 4, minQueryLen = 3 } = {}) {
  const qRaw = String(queryRaw || "").trim();
  if (qRaw.length < minQueryLen || !products?.length) return [];
  const q = normalizeForSearch(qRaw);
  if (!q || q.length < minQueryLen) return [];
  const scored = [];
  for (const p of products) {
    const name = p.nombre;
    if (!name || !String(name).trim()) continue;
    const nn = normalizeForSearch(name);
    const qTokens = q.split(/\s+/).filter(Boolean);
    if (qTokens.length && qTokens.every((t) => nn.includes(t))) continue;
    const dist = minEditDistanceQueryToText(q, nn);
    const maxLen = Math.max(q.length, nn.length);
    const ratio = maxLen ? dist / maxLen : 1;
    const maxTypo = maxTypoForLength(q.length);
    if (dist <= maxTypo + 1 || ratio <= 0.4) {
      scored.push({ label: name, dist, ratio, id: p.id });
    }
  }
  scored.sort((a, b) => a.dist - b.dist || a.ratio - b.ratio);
  const out = [];
  const seen = new Set();
  for (const s of scored) {
    const key = normalizeForSearch(s.label);
    if (seen.has(key)) continue;
    seen.add(key);
    out.push({ label: s.label, productId: s.id });
    if (out.length >= limit) break;
  }
  return out;
}
