/**
 * Búsqueda tolerante a errores de escritura (distancia de edición) + sugerencias.
 */

import {
  normalizeForSearch,
  someFieldIncludesNormalizedQuery,
  isNormalizedDoseUnitToken,
  tokenMatchesInNormalizedHaystack,
} from "../utils";

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
  if (tokenMatchesInNormalizedHaystack(queryNorm, textNorm)) return true;
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
    if (isNormalizedDoseUnitToken(tok)) {
      return normalizedValues.some((nv) => tokenMatchesInNormalizedHaystack(tok, nv));
    }
    if (tok.length < 3) {
      return normalizedValues.some((nv) => nv.includes(tok) || normalizedTextFuzzyMatch(tok, nv));
    }
    return normalizedValues.some((nv) => normalizedTextFuzzyMatch(tok, nv));
  });
}

/**
 * Catálogo tienda: sin descripción — textos largos suelen contener "ácido", "sodio", etc.
 * y hacen que consultas cortas (ej. "ácido") devuelvan casi todo el inventario.
 */
const TIENDA_GETTERS = [
  (x) => x.nombre,
  (x) => x.principio_activo,
  (x) => x.marca,
  (x) => x.categoria,
  (x) => x.sku,
  (x) => x.codigo_barras,
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

/**
 * Relevancia para ordenar resultados del catálogo (menor = mejor).
 * Prioriza nombre y principio activo sobre descripción o coincidencia solo difusa.
 */
export function tiendaSearchRelevanceRank(product, queryRaw) {
  const raw = String(queryRaw ?? "").trim();
  if (!raw) return 0;
  const values = TIENDA_GETTERS.map((fn) => fn(product)).filter((v) => v != null && String(v).trim() !== "");
  const bySubstring = someFieldIncludesNormalizedQuery(values, raw);
  const qn = normalizeForSearch(raw);
  if (!qn) return 40;
  const tokens = qn.split(/\s+/).filter(Boolean);
  const n = normalizeForSearch(product.nombre || "");
  const pa = normalizeForSearch(product.principio_activo || "");
  const d = normalizeForSearch(product.descripcion || "");
  const sku = normalizeForSearch(String(product.sku ?? ""));
  const cb = normalizeForSearch(String(product.codigo_barras ?? ""));
  const marca = normalizeForSearch(String(product.marca ?? ""));
  const cat = normalizeForSearch(product.categoria || "");
  const everyIn = (hay) => tokens.length > 0 && tokens.every((t) => hay.includes(t));

  if (n.includes(qn)) return 0;
  if (everyIn(n)) return 2;
  if (pa.includes(qn)) return 1;
  if (everyIn(pa)) return 3;
  if (sku === qn || cb === qn) return 0;
  if (qn.length >= 2 && (sku.startsWith(qn) || cb.startsWith(qn))) return 4;
  if (bySubstring) {
    if (everyIn(d)) return 12;
    if (everyIn(marca)) return 14;
    if (everyIn(cat)) return 16;
    return 20;
  }
  return 60;
}

/**
 * Sugerencias para el buscador de la tienda (nombre, SKU, código de barras).
 * Orden: coincidencia exacta/prefijo en SKU y código, luego resto que pase el matcher.
 */
export function tiendaCatalogSearchSuggestions(products, queryRaw, { limit = 8 } = {}) {
  const q = String(queryRaw ?? "").trim();
  if (q.length < 2 || !products?.length) return [];
  const qn = normalizeForSearch(q);
  if (!qn) return [];
  const qTokens = qn.split(/\s+/).filter(Boolean);
  const out = [];
  for (const p of products) {
    if (!p || p.activo === false) continue;
    const sku = p.sku != null && String(p.sku).trim() !== "" ? normalizeForSearch(String(p.sku)) : "";
    const cb =
      p.codigo_barras != null && String(p.codigo_barras).trim() !== ""
        ? normalizeForSearch(String(p.codigo_barras))
        : "";
    let rank = 100;
    if (sku && sku === qn) rank = 0;
    else if (cb && cb === qn) rank = 0;
    else if (sku && sku.startsWith(qn)) rank = 1;
    else if (cb && cb.startsWith(qn)) rank = 1;
    else if (sku && sku.includes(qn)) rank = 3;
    else if (cb && cb.includes(qn)) rank = 3;
    const nn = normalizeForSearch(p.nombre || "");
    const ptn = normalizeForSearch(p.principio_activo || "");
    if (nn.includes(qn)) rank = Math.min(rank, 2);
    if (qTokens.length && qTokens.every((t) => nn.includes(t))) rank = Math.min(rank, 5);
    if (ptn.includes(qn)) rank = Math.min(rank, 4);
    if (qTokens.length && qTokens.every((t) => ptn.includes(t))) rank = Math.min(rank, 6);
    if (rank === 100) {
      if (!tiendaProductMatchesBusqueda(p, q)) continue;
      rank = 8;
    }
    out.push({
      id: p.id,
      nombre: p.nombre || "",
      sku: p.sku != null ? String(p.sku) : "",
      codigo_barras: p.codigo_barras != null ? String(p.codigo_barras) : "",
      stock: p.stock,
      rank,
    });
  }
  out.sort((a, b) => a.rank - b.rank || String(a.nombre).localeCompare(String(b.nombre), "es"));
  return out.slice(0, limit);
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
