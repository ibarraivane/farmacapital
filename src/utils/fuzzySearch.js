/**
 * Búsqueda tolerante a errores de escritura (distancia de edición) + sugerencias.
 * Un solo motor para tienda, POS, inventario y lotes.
 */

import {
  normalizeForSearch,
  someFieldIncludesNormalizedQuery,
  isNormalizedDoseUnitToken,
  tokenMatchesInNormalizedHaystack,
} from "../utils";
import { coincidenciaIntencionMostrador } from "./intencionMostrador";

const AMBIGUOUS_SHORT_SUBSTRING_TOKENS = new Set(["para"]);

/** Conectores y talla de frase. No tumban el AND si ya pegó el ancla (pañales para adultos). */
const WEAK_QUERY_TOKENS = new Set([
  "para", "de", "del", "al", "la", "el", "los", "las",
  "un", "una", "unos", "unas", "y", "o", "en", "con", "por", "sin", "tipo",
  "adulto", "adultos", "adulta", "adultas",
  "pieza", "piezas", "pza", "pzas", "caja", "cajas",
]);

function isWeakQueryToken(tok) {
  return WEAK_QUERY_TOKENS.has(String(tok || "").toLowerCase());
}

function requiredCatalogQueryTokens(tokens) {
  const required = (tokens || []).filter((t) => !isWeakQueryToken(t));
  return required.length ? required : tokens || [];
}

const CATALOG_UNIT_TOKENS = new Set([
  "cm", "mm", "m", "ml", "mg", "mcg", "g", "kg", "l", "lt", "iu", "ui",
  "tab", "tabs", "cap", "caps", "pza", "pieza",
]);

const CATALOG_NAME_LIKE_KINDS = new Set([
  "nombre",
  "marca",
  "principio_activo",
  "denominacion_generica",
  "denominacion_distintiva",
  "concentracion",
  "presentacion",
  "forma_farmaceutica",
]);

function isPureNumericSearchToken(tok) {
  return /^\d+(\.\d+)?$/.test(String(tok || ""));
}

function isCatalogUnitToken(tok) {
  return CATALOG_UNIT_TOKENS.has(String(tok || "").toLowerCase());
}

function catalogQueryAnchorToken(tokens) {
  return tokens.find(
    (t) =>
      !isWeakQueryToken(t) &&
      t.length >= 5 &&
      /[a-z]/.test(t) &&
      !/^fc-[0-9a-f-]+$/i.test(t) &&
      !/^\d{8,}$/.test(t)
  );
}

function unitTokenAdjacentToNumber(numTok, tokens) {
  const idx = tokens.indexOf(numTok);
  if (idx < 0) return null;
  if (idx + 1 < tokens.length && isCatalogUnitToken(tokens[idx + 1])) return tokens[idx + 1];
  if (idx > 0 && isCatalogUnitToken(tokens[idx - 1])) return tokens[idx - 1];
  return null;
}

function catalogNumericTokenMatchesField(numTok, fieldNorm, unitTok) {
  const n = String(numTok);
  const f = String(fieldNorm || "");
  if (!n || !f) return false;
  if (unitTok) {
    const u = String(unitTok).toLowerCase();
    return new RegExp(`(^|[^\\d])${n}\\s*${u}(?=\\s|$|x)`, "i").test(` ${f} `);
  }
  let i = 0;
  while ((i = f.indexOf(n, i)) !== -1) {
    const before = i === 0 ? "" : f[i - 1];
    const afterPos = i + n.length;
    const after = afterPos >= f.length ? "" : f[afterPos];
    if (/\d/.test(before) || /\d/.test(after)) {
      i += 1;
      continue;
    }
    const tail = f.slice(afterPos).trimStart();
    for (const u of CATALOG_UNIT_TOKENS) {
      if (tail.startsWith(u)) return true;
    }
    return true;
  }
  return false;
}

function catalogUnitTokenMatchesField(unitTok, fieldNorm) {
  const u = String(unitTok || "").toLowerCase();
  const f = String(fieldNorm || "");
  if (!u || !f) return false;
  return new RegExp(`(^|[^a-z])\\d+(?:\\.\\d+)?\\s*${u}(?=\\s|$|x)`, "i").test(` ${f} `);
}

function catalogSearchFieldEntries(product, { inventario = false } = {}) {
  const pairs = [
    ["nombre", product?.nombre],
    ["principio_activo", product?.principio_activo],
    ["denominacion_generica", product?.denominacion_generica],
    ["denominacion_distintiva", product?.denominacion_distintiva],
    ["marca", product?.marca],
    ["concentracion", product?.concentracion],
    ["presentacion", product?.presentacion],
    ["forma_farmaceutica", product?.forma_farmaceutica],
    ["sku", product?.sku],
    ["codigo_barras", product?.codigo_barras],
    ["categoria", product?.categoria],
  ];
  if (inventario) {
    pairs.push(
      ["ubicacion", product?.ubicacion_texto || product?.ubicacion],
      ["zona", product?.zona],
      ["anaquel", product?.anaquel],
      ["cajon", product?.cajon],
      ["proveedor", product?.proveedor]
    );
  }
  return pairs
    .map(([kind, raw]) => ({ kind, norm: normalizeForSearch(raw) }))
    .filter((e) => e.norm);
}

function catalogTokenMatchesField(tok, kind, fieldNorm, { queryTokens = [] } = {}) {
  if (!tok || !fieldNorm) return false;
  const t = String(tok).toLowerCase();

  if (isPureNumericSearchToken(t)) {
    if (kind === "sku" || kind === "codigo_barras") {
      return t.length >= 6 && fieldNorm.includes(t);
    }
    if (!CATALOG_NAME_LIKE_KINDS.has(kind)) return false;
    return catalogNumericTokenMatchesField(t, fieldNorm, unitTokenAdjacentToNumber(t, queryTokens));
  }

  if (isCatalogUnitToken(t)) {
    if (!CATALOG_NAME_LIKE_KINDS.has(kind)) return false;
    return catalogUnitTokenMatchesField(t, fieldNorm);
  }

  if ((kind === "sku" || kind === "codigo_barras") && t.length <= 4) {
    return false;
  }

  if (AMBIGUOUS_SHORT_SUBSTRING_TOKENS.has(t)) {
    return matchesAmbiguousShortCatalogToken(t, fieldNorm);
  }
  if (tokenMatchesInNormalizedHaystack(t, fieldNorm)) return true;
  if (t.length >= 5 && normalizedTextFuzzyMatch(t, fieldNorm)) return true;
  return false;
}

function catalogFieldsMatchAllTokens(product, queryRaw, { inventario = false } = {}) {
  const q = normalizeCatalogSearchQuery(queryRaw);
  if (!q) return true;
  const tokens = q.split(/\s+/).filter(Boolean);
  if (!tokens.length) return true;

  const entries = catalogSearchFieldEntries(product, { inventario });
  const required = requiredCatalogQueryTokens(tokens);
  const anchor = catalogQueryAnchorToken(required);
  if (anchor) {
    const nameEntries = entries.filter((e) => CATALOG_NAME_LIKE_KINDS.has(e.kind));
    if (!nameEntries.some((e) => catalogTokenOrVernacularMatches(anchor, e.kind, e.norm, required))) {
      return false;
    }
  }

  return required.every((tok) =>
    entries.some((e) => catalogTokenOrVernacularMatches(tok, e.kind, e.norm, required))
  );
}

/**
 * Término de mostrador → marcas/nombres del catálogo.
 * No sustituye la palabra (suero sigue encontrando suero glucosado);
 * añade alternativas con OR. Las alias no usan fuzzy de typos.
 */
const CATALOG_VERNACULAR_GROUPS = [
  {
    query: ["suero", "sueros", "rehidratante", "rehidratacion", "sro"],
    catalog: [
      "suero",
      "electrolit",
      "pedialyte",
      "oralit",
      "oraliv",
      "hydralyte",
      "sueroral",
      "rehidrat",
    ],
  },
  {
    query: ["panal", "panales", "incontinencia", "incontinente"],
    catalog: [
      "panal",
      "diapro",
      "tena",
      "affective",
      "depend",
      "molicare",
      "molimed",
      "indasec",
    ],
  },
  {
    query: ["empapador", "empapadores", "sabanilla", "sabanillas", "chux", "underpad"],
    catalog: ["affective", "cover pro", "empapador", "sabanilla"],
  },
  {
    query: ["tempra", "tylenol", "acetaminofen"],
    catalog: ["paracetamol", "tempra", "tylenol", "acetaminofen"],
  },
  {
    query: ["advil", "motrin"],
    catalog: ["ibuprofeno", "advil", "motrin"],
  },
  {
    query: ["clarityne", "claritin"],
    catalog: ["loratadina", "clarityne", "claritin"],
  },
  {
    query: ["curita", "curitas", "bandaid", "band-aid"],
    catalog: ["curita", "bandaid", "band-aid", "nexcare", "aposito"],
  },
  {
    query: ["condon", "condones", "preservativo", "preservativos"],
    catalog: ["condon", "preservativo", "durex", "prudence", "trojan", "sico"],
  },
  {
    query: ["cubrebocas", "cubreboca", "mascarilla", "mascarillas"],
    catalog: ["cubrebocas", "cubreboca", "mascarilla", "n95", "kn95"],
  },
  {
    query: ["paleta", "paletas", "paleto", "paletos"],
    catalog: ["paleta", "broncolin"],
  },
];

function vernacularAltsForToken(tok) {
  const t = String(tok || "").toLowerCase();
  if (!t) return [];
  for (const g of CATALOG_VERNACULAR_GROUPS) {
    if (g.query.includes(t)) return g.catalog;
  }
  return [];
}

function catalogTokenOrVernacularMatches(tok, kind, fieldNorm, queryTokens) {
  if (catalogTokenMatchesField(tok, kind, fieldNorm, { queryTokens })) return true;
  for (const alt of vernacularAltsForToken(tok)) {
    if (alt === tok) continue;
    if (tokenMatchesInNormalizedHaystack(alt, fieldNorm)) return true;
  }
  return false;
}

/** OCR / voz / plural → forma habitual en catálogo (solo consulta, no productos). */
const CATALOG_QUERY_REPLACEMENTS = [
  [/\bsueros?\s+oral(?:es)?\b/g, "suero"],
  [/\bsolucion(?:es)?\s+de\s+rehidratacion\b/g, "suero"],
  [/\belectrolitos?\b/g, "electrolit"],
  [/\belectrolid\b/g, "electrolit"],
  [/\bpedialytes?\b/g, "pedialyte"],
  [/\bparacetamols?\b/g, "paracetamol"],
  [/\bacetaminofens?\b/g, "paracetamol"],
  [/\bibuprofenos?\b/g, "ibuprofeno"],
  [/\bomeprazols?\b/g, "omeprazol"],
  [/\bantibioticos?\b/g, "antibiotico"],
  [/\bvitaminas?\b/g, "vitamina"],
  [/\bprotector\s+solars?\b/g, "protector solar"],
  [/\btoallitas?\s+humedas?\b/g, "toallitas humedas"],
  [/\btoa\s*hum\b/g, "toallitas humedas"],
  [/\bpanales?\s+(?:desechables?\s+)?(?:para\s+)?adultos?\b/g, "panal"],
  [/\bpants?\s+(?:desechables?\s+)?(?:para\s+)?adultos?\b/g, "panal"],
  [/\bropa\s+interior\s+desechable\b/g, "panal"],
];

export function normalizeCatalogSearchQuery(raw) {
  let q = normalizeForSearch(raw);
  if (!q) return q;
  for (const [re, rep] of CATALOG_QUERY_REPLACEMENTS) {
    q = q.replace(re, rep);
  }
  return q;
}

export function matchesAmbiguousShortCatalogToken(tok, haystackNorm) {
  const n = String(tok || "");
  const h = String(haystackNorm || "");
  if (!n || !h || !AMBIGUOUS_SHORT_SUBSTRING_TOKENS.has(n)) return false;
  if (!h.includes(n)) return false;
  if (h.startsWith(n)) return true;
  if (h.includes(`/${n}`)) return true;
  for (const seg of h.split("/")) {
    if (seg.trimStart().startsWith(n)) return true;
  }
  let idx = 0;
  while ((idx = h.indexOf(n, idx)) !== -1) {
    const before = idx === 0 ? "" : h[idx - 1];
    const afterPos = idx + n.length;
    const after = afterPos >= h.length ? "" : h[afterPos];
    const isolatedPrep = before === " " && after === " ";
    if (!isolatedPrep) return true;
    idx += n.length;
  }
  return false;
}

function shortCatalogTokenMatchesNormalizedField(tok, fieldNorm) {
  if (!tok || !fieldNorm) return false;
  if (AMBIGUOUS_SHORT_SUBSTRING_TOKENS.has(tok)) {
    return matchesAmbiguousShortCatalogToken(tok, fieldNorm);
  }
  if (tokenMatchesInNormalizedHaystack(tok, fieldNorm)) return true;
  if (tok.length >= 5 && normalizedTextFuzzyMatch(tok, fieldNorm)) return true;
  return false;
}

function catalogTokenMatchRank(tok, fieldNorm) {
  if (!tok || !fieldNorm) return null;
  if (fieldNorm === tok) return 0;
  if (fieldNorm.startsWith(tok)) return 1;
  for (const word of fieldNorm.split(/\s+/)) {
    if (word.startsWith(tok)) return 2;
  }
  if (fieldNorm.includes(` ${tok}`)) return 3;
  if (shortCatalogTokenMatchesNormalizedField(tok, fieldNorm)) return 6;
  return null;
}

function catalogPhraseMatchRank(qn, tokens, ...fields) {
  let best = null;
  for (const f of fields) {
    const nf = normalizeForSearch(f);
    if (!nf) continue;
    if (tokens.length >= 2 && nf.includes(qn)) {
      best = best == null ? 2 : Math.min(best, 2);
      continue;
    }
    for (const t of tokens) {
      const r = catalogTokenMatchRank(t, nf);
      if (r != null) best = best == null ? r : Math.min(best, r);
    }
  }
  return best;
}

function tiendaFieldsMatchNormalizedTokens(fieldsRaw, queryRaw) {
  const q = normalizeCatalogSearchQuery(queryRaw);
  if (!q) return true;
  const tokens = q.split(/\s+/).filter(Boolean);
  if (!tokens.length) return true;
  const normalizedFields = fieldsRaw.map((f) => normalizeForSearch(f)).filter((nf) => nf !== "");
  return tokens.every((tok) =>
    normalizedFields.some((nf) => shortCatalogTokenMatchesNormalizedField(tok, nf))
  );
}

function catalogTokensMatchNameLikeFields(tokens, product) {
  const entries = catalogSearchFieldEntries(product, { inventario: false }).filter((e) =>
    CATALOG_NAME_LIKE_KINDS.has(e.kind)
  );
  return tokens.every((tok) =>
    entries.some((e) => catalogTokenMatchesField(tok, e.kind, e.norm, { queryTokens: tokens }))
  );
}

function normalizedHaystackMatchesPhrase(haystackNorm, qn, tokens) {
  if (!haystackNorm || !qn) return false;
  if (tokens.length >= 2) return haystackNorm.includes(qn);
  const t = tokens[0];
  return shortCatalogTokenMatchesNormalizedField(t, haystackNorm);
}

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
  // En seis letras, dos cambios generan falsos positivos peligrosos:
  // "paleta" terminaba coincidiendo con "tableta".
  if (len <= 6) return 1;
  if (len <= 7) return 2;
  return Math.min(4, Math.floor(len * 0.35));
}

function fuzzyMatchRatio(queryNorm, textNorm) {
  const dist = minEditDistanceQueryToText(queryNorm, textNorm);
  if (!queryNorm || !textNorm) return { dist, ratio: 1 };
  const words = textNorm.split(/\s+/).filter((word) => word.length >= 2);
  if (!words.length) {
    const denom = Math.max(queryNorm.length, textNorm.length);
    return { dist, ratio: denom ? dist / denom : 1 };
  }
  let bestRatio = 1;
  for (const w of words) {
    if (Math.abs(w.length - queryNorm.length) > 6) continue;
    const d = levenshtein(queryNorm, w);
    const denom = Math.max(queryNorm.length, w.length);
    if (denom) bestRatio = Math.min(bestRatio, d / denom);
  }
  return { dist, ratio: bestRatio };
}

export function normalizedTextFuzzyMatch(queryNorm, textNorm) {
  if (!queryNorm || queryNorm.length < 2 || !textNorm) return false;
  if (tokenMatchesInNormalizedHaystack(queryNorm, textNorm)) return true;
  const { dist, ratio } = fuzzyMatchRatio(queryNorm, textNorm);
  const maxTypo = maxTypoForLength(queryNorm.length);
  return dist <= maxTypo || ratio <= 0.34;
}

function catalogPrimaryRawFields(product, { inventario = false } = {}) {
  const fields = [
    product?.nombre,
    product?.principio_activo,
    product?.denominacion_generica,
    product?.denominacion_distintiva,
    product?.marca,
    product?.concentracion,
    product?.presentacion,
    product?.forma_farmaceutica,
    product?.sku,
    product?.codigo_barras,
    product?.categoria,
  ];
  if (inventario) {
    fields.push(
      product?.ubicacion_texto,
      product?.ubicacion,
      product?.zona,
      product?.anaquel,
      product?.cajon,
      product?.proveedor
    );
  }
  return fields;
}

function catalogNameLikeNormFields(product) {
  return [
    normalizeForSearch(product?.nombre || ""),
    normalizeForSearch(product?.principio_activo || ""),
    normalizeForSearch(product?.denominacion_generica || ""),
    normalizeForSearch(product?.denominacion_distintiva || ""),
    normalizeForSearch(product?.marca || ""),
    normalizeForSearch(product?.concentracion || ""),
    normalizeForSearch(product?.presentacion || ""),
    normalizeForSearch(product?.forma_farmaceutica || ""),
  ].filter(Boolean);
}

/**
 * Motor unificado: tienda, POS, inventario, lotes, promociones.
 * @param {{ inventario?: boolean, allowDescripcion?: boolean }} options
 */
export function catalogProductMatchesBusqueda(product, queryRaw, options = {}) {
  const { inventario = false, allowDescripcion = false } = options;
  const raw = String(queryRaw || "").trim();
  if (!raw) return true;

  const q = normalizeCatalogSearchQuery(raw);
  const directQ = normalizeForSearch(raw);
  const tokens = q.split(/\s+/).filter(Boolean);
  if (!tokens.length) return true;

  // El texto persistido completo siempre se encuentra a sí mismo. Esto evita
  // que unidades/conectores de nombres largos rompan el AND por tokens.
  const directIdentityFields = [
    product?.nombre,
    product?.marca,
    product?.denominacion_distintiva,
    product?.principio_activo,
    product?.denominacion_generica,
  ].map((value) => normalizeForSearch(value)).filter(Boolean);
  if (directIdentityFields.some((field) => field === directQ || field.includes(directQ))) return true;

  if (catalogFieldsMatchAllTokens(product, raw, { inventario })) return true;

  if (!allowDescripcion) return false;

  const desc = normalizeForSearch(product?.descripcion || "");
  if (desc && tokens.length >= 2 && desc.includes(q)) return true;
  if (desc && q.length >= 8 && tokens.every((t) => t.length >= 5 && shortCatalogTokenMatchesNormalizedField(t, desc))) {
    return true;
  }

  return false;
}

function catalogSearchRelevanceRank(product, queryRaw, { inventario = false } = {}) {
  const raw = String(queryRaw ?? "").trim();
  if (!raw) return 0;
  const qn = normalizeCatalogSearchQuery(raw);
  const directQn = normalizeForSearch(raw);
  if (!qn) return 40;
  const tokens = requiredCatalogQueryTokens(qn.split(/\s+/).filter(Boolean));
  const n = normalizeForSearch(product?.nombre || "");
  const pa = normalizeForSearch(product?.principio_activo || "");
  const dg = normalizeForSearch(product?.denominacion_generica || "");
  const dd = normalizeForSearch(product?.denominacion_distintiva || "");
  const marca = normalizeForSearch(product?.marca || "");
  const conc = normalizeForSearch(product?.concentracion || "");
  const pres = normalizeForSearch(product?.presentacion || "");
  const forma = normalizeForSearch(product?.forma_farmaceutica || "");
  const sku = normalizeForSearch(String(product?.sku ?? ""));
  const cb = normalizeForSearch(String(product?.codigo_barras ?? ""));
  const cat = normalizeForSearch(product?.categoria || "");
  const ubic = normalizeForSearch(product?.ubicacion_texto || product?.ubicacion || "");
  const everyIn = (hay) =>
    tokens.length > 0 && tokens.every((t) => shortCatalogTokenMatchesNormalizedField(t, hay));
  const everyInNameLike = catalogTokensMatchNameLikeFields(tokens, product);

  // Identidad exacta antes de cualquier coincidencia fuzzy en otro campo.
  if (sku === directQn || cb === directQn) return 0;
  if (n === directQn) return 0;
  if (marca === directQn) return 1;
  if (dd === directQn) return 1;

  if (normalizedHaystackMatchesPhrase(n, qn, tokens)) {
    const pr = catalogPhraseMatchRank(qn, tokens, product?.nombre);
    return pr != null ? pr : 0;
  }
  if (everyIn(n)) {
    const pr = catalogPhraseMatchRank(qn, tokens, product?.nombre);
    return pr != null ? pr + 1 : 2;
  }
  if (normalizedHaystackMatchesPhrase(marca, qn, tokens)) return 1;
  if (everyIn(marca)) return 2;
  if (normalizedHaystackMatchesPhrase(pa, qn, tokens)) return 3;
  if (normalizedHaystackMatchesPhrase(dg, qn, tokens)) return 3;
  if (normalizedHaystackMatchesPhrase(dd, qn, tokens)) return 4;
  if (everyIn(pa)) return 4;
  if (everyIn(dg)) return 5;
  if (everyIn(dd)) return 6;
  if (qn.length >= 2 && (sku.startsWith(qn) || cb.startsWith(qn))) return 5;
  if (everyInNameLike) return 5;
  if (conc.includes(qn) || pres.includes(qn) || forma.includes(qn)) return 6;
  if (inventario && everyIn(ubic)) return 8;
  if (everyIn(cat)) return 12;
  if (catalogProductMatchesBusqueda(product, raw, { inventario, allowDescripcion: false })) return 20;
  return 60;
}

export function catalogSearchSuggestions(products, queryRaw, { limit = 8, inventario = false } = {}) {
  const q = String(queryRaw ?? "").trim();
  if (q.length < 2 || !products?.length) return [];
  const qn = normalizeCatalogSearchQuery(q);
  if (!qn) return [];
  const qTokens = qn.split(/\s+/).filter(Boolean);
  const out = [];

  for (const p of products) {
    if (!p || p.activo === false) continue;
    if (!catalogProductMatchesBusqueda(p, q, { inventario, allowDescripcion: inventario })) continue;

    const sku = p.sku != null && String(p.sku).trim() !== "" ? normalizeForSearch(String(p.sku)) : "";
    const cb =
      p.codigo_barras != null && String(p.codigo_barras).trim() !== ""
        ? normalizeForSearch(String(p.codigo_barras))
        : "";
    let rank = catalogSearchRelevanceRank(p, q, { inventario });

    if (sku && sku === qn) rank = Math.min(rank, 0);
    else if (cb && cb === qn) rank = Math.min(rank, 0);
    else if (sku && sku.startsWith(qn)) rank = Math.min(rank, 1);
    else if (cb && cb.startsWith(qn)) rank = Math.min(rank, 1);

    const nameRank = catalogPhraseMatchRank(
      qn,
      qTokens,
      p.nombre,
      p.marca,
      p.principio_activo,
      p.denominacion_generica,
      p.denominacion_distintiva,
      p.forma_farmaceutica
    );
    if (nameRank != null) rank = Math.min(rank, nameRank);

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

/**
 * Búsqueda genérica (clientes, expedientes). Usa normalización de catálogo pero sin fuzzy amplio en textos largos.
 */
export function productMatchesSearchQuery(product, queryRaw, valueGetters) {
  if (!String(queryRaw || "").trim()) return true;
  const values = valueGetters.map((fn) => fn(product)).filter((v) => v != null && String(v).trim() !== "");
  const normalizedValues = values.map((v) => normalizeForSearch(v));
  const qPhrase = normalizeCatalogSearchQuery(queryRaw);
  if (qPhrase.length >= 2) {
    if (normalizedValues.some((nv) => nv.includes(qPhrase))) return true;
  }
  if (someFieldIncludesNormalizedQuery(values, queryRaw)) return true;
  const tokens = qPhrase.split(/\s+/).filter(Boolean);
  if (!tokens.length) return false;
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
    return normalizedValues.some((nv) => shortCatalogTokenMatchesNormalizedField(tok, nv));
  });
}

/** Producto de catálogo con campos estándar (tienda / POS). */
export function tiendaProductMatchesBusqueda(product, queryRaw) {
  return catalogProductMatchesBusqueda(product, queryRaw, { inventario: false, allowDescripcion: false })
    || Boolean(coincidenciaIntencionMostrador(product, queryRaw));
}

export function tiendaSearchRelevanceRank(product, queryRaw) {
  const catalogRank = catalogSearchRelevanceRank(product, queryRaw, { inventario: false });
  // Identidad, marca, activo y atributos del SKU siempre ganan a una intención.
  if (catalogRank < 60) return catalogRank;
  return coincidenciaIntencionMostrador(product, queryRaw) ? 30 : catalogRank;
}

export function tiendaCatalogSearchSuggestions(products, queryRaw, { limit = 8 } = {}) {
  const direct = catalogSearchSuggestions(products, queryRaw, { limit, inventario: false });
  if (direct.length >= limit) return direct;
  const seen = new Set(direct.map((item) => String(item.id)));
  const related = (products || [])
    .filter((product) => product?.activo !== false && !seen.has(String(product?.id)))
    .filter((product) => coincidenciaIntencionMostrador(product, queryRaw))
    .map((product) => ({
      id: product.id,
      nombre: product.nombre || "",
      sku: product.sku != null ? String(product.sku) : "",
      codigo_barras: product.codigo_barras != null ? String(product.codigo_barras) : "",
      stock: product.stock,
      rank: 30,
    }))
    .sort((a, b) => String(a.nombre).localeCompare(String(b.nombre), "es"));
  return [...direct, ...related].slice(0, limit);
}

export function inventarioProductMatchesBusqueda(product, queryRaw) {
  return catalogProductMatchesBusqueda(product, queryRaw, { inventario: true, allowDescripcion: false });
}

export function inventarioSearchRelevanceRank(product, queryRaw) {
  return catalogSearchRelevanceRank(product, queryRaw, { inventario: true });
}

export function inventarioCatalogSearchSuggestions(products, queryRaw, { limit = 8 } = {}) {
  return catalogSearchSuggestions(products, queryRaw, { limit, inventario: true });
}

export function spellSuggestFromProducts(products, queryRaw, { limit = 4, minQueryLen = 3 } = {}) {
  const qRaw = String(queryRaw || "").trim();
  if (qRaw.length < minQueryLen || !products?.length) return [];
  const q = normalizeCatalogSearchQuery(qRaw);
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
