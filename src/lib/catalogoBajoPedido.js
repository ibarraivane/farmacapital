/**
 * Catálogo bajo pedido (Dermaexpress, Birdman, Ewafra/DIS, Promexsa techo,
 * Suplementos Mayoreo).
 * El costo de mayoreo se guarda. El precio público va en 0 (botón Ordenar)
 * hasta que el dueño revise las cifras. `precioBajoPedido` queda para ese día.
 * CJS para que el script de alta (`scripts/generar-alta-bajo-pedido.js`) lo requiera.
 */
function tipoAltaNormalizado(tipo) {
  const t = String(tipo || "").toLowerCase();
  if (t === "marca" || t === "patente") return "marca";
  return "generico";
}

function precioSugeridoAltaRecepcion(costo, tipo) {
  const c = Number(costo);
  if (!Number.isFinite(c) || c <= 0) return null;
  const markup = tipoAltaNormalizado(tipo) === "marca" ? 0.25 : 0.6;
  return Math.ceil(c * (1 + markup));
}

function skuAltaRecepcion(codigo) {
  const bc = String(codigo || "").replace(/\D/g, "");
  if (bc.length >= 8) return `FC-${bc.slice(-8)}`;
  return null;
}

function urlImagenPublicaTienda(rawUrl) {
  const url = String(rawUrl || "").trim();
  if (!url) return "";
  try {
    const host = new URL(url).hostname;
    if (/(^|\.)fahorro\.com$/i.test(host)) return "";
  } catch {
    return "";
  }
  return url;
}

const FUENTE_DERMAEXPRESS = "dermaexpress";
const FUENTE_BIRDMAN = "birdman";
const FUENTE_EWAFRA = "ewafra";
const FUENTE_PROMEXSA = "promexsa";

const STOP = new Set([
  "de", "del", "la", "el", "los", "las", "y", "con", "para", "en", "un", "una",
  "caja", "c", "pz", "pza", "pieza", "piezas", "ml", "cm", "mm", "fr", "x",
]);

const MARCAS_DIS = [
  "AMBIDERM", "DIBAR", "NIPRO", "BD", "BECTON", "SENSI", "SENSIMEDICAL",
  "AMSINO", "DENTILAB", "NIPRO", "MISAWA", "DL", "PREVARIS", "HERGOM",
  "DEMEVA", "QUIRMEX", "PLASTICWORLD", "GARNIER",
];

const DIS_EXCLUIR = [
  /anticipo/i,
  /aceite de inmersion/i,
  /acido acetico/i,
  /acido fenico/i,
  /agua tridestilada/i,
  /\badrenalina\b/i,
  /pinadrina/i,
  /aethoxysklerol|aethoxylerol/i,
];

const ABREV_DIS = [
  [/D\/MAD\.?/gi, "de madera"],
  [/N\/EST/gi, "no esteril"],
  [/N\/E\b/gi, "no esteril"],
  [/C\/(\d+)/gi, "caja $1"],
  [/\bPZA\b/gi, "pieza"],
  [/\bPZ\b/gi, "pieza"],
  [/\bLTR\b/gi, "litro"],
  [/\bLT\b/gi, "litro"],
  [/\bAG\b/gi, "aguja"],
  [/\bEST\b/gi, "esteril"],
  [/\bSOB\.?/gi, "sobres"],
  [/\bCVE\b/gi, ""],
];

function norm(s) {
  return String(s ?? "")
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/\s+/g, " ");
}

/** Hash FNV-1a estable → 8 dígitos (SKU sin EAN). */
function hashSku8(texto) {
  let h = 2166136261;
  const str = String(texto || "");
  for (let i = 0; i < str.length; i += 1) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return String((h >>> 0) % 100000000).padStart(8, "0");
}

function skuCatalogoBajoPedido(ean, { proveedor = "", codigoProveedor = "" } = {}) {
  const bc = String(ean || "").replace(/\D/g, "");
  if (bc.length >= 8) return skuAltaRecepcion(bc);
  const clave = `${norm(proveedor)}:${norm(codigoProveedor)}`;
  if (!clave || clave === ":") return null;
  return `FC-${hashSku8(clave)}`;
}

/**
 * Precio ancla de mostrador. techo (PVP / Promexsa) solo recorta, no se pega.
 * Sin costo usable → 0 (Cotizar).
 */
function precioBajoPedido(costo, tipo, techo) {
  const c = Number(costo);
  if (!Number.isFinite(c) || c <= 0) return 0;
  const sugerido = precioSugeridoAltaRecepcion(c, tipoAltaNormalizado(tipo));
  if (sugerido == null) return 0;
  const t = Number(techo);
  if (Number.isFinite(t) && t > 0.01) return Math.min(sugerido, Math.ceil(t));
  return sugerido;
}

function esMerchBirdman(row) {
  const t = `${row?.sku || ""} ${row?.nombre || ""} ${row?.linea || ""} ${row?.categoria || ""}`;
  return /playera|playeras|hoodie|gorra(?!.*shaker)|mochila|distribuidor autorizado/i.test(t);
}

function mapCategoriaBirdman(row) {
  const linea = norm(row?.linea || row?.categoria);
  if (/protein/.test(linea)) {
    return { categoria: "Suplemento", subcategoria: "Proteína" };
  }
  if (/vitamin/.test(linea)) {
    return { categoria: "Vitaminas", subcategoria: "Vitaminas" };
  }
  return { categoria: "Suplemento", subcategoria: "Nutrición deportiva" };
}

function mapCategoriaDermaexpress() {
  return { categoria: "Cuidado personal", subcategoria: "Dermatología" };
}

function mapCategoriaDispositivo() {
  return { categoria: "Dispositivo médico", subcategoria: "Insumos" };
}

function excluirFilaDis(row) {
  const costo = Number(row?.costo ?? row?.precio ?? row?.costo_lista6);
  if (!Number.isFinite(costo) || costo <= 0) return "sin_costo";
  const texto = `${row?.nombre || ""} ${row?.descripcion || ""} ${row?.codigo || ""}`;
  if (DIS_EXCLUIR.some((re) => re.test(texto))) return "excluido";
  return null;
}

function marcaDesdeDescripcionDis(descripcion) {
  const up = String(descripcion || "").toUpperCase();
  for (const marca of MARCAS_DIS) {
    if (up.includes(marca)) {
      if (marca === "BD" || marca === "DL") {
        const re = new RegExp(`\\b${marca}\\b`);
        if (!re.test(up)) continue;
      }
      if (marca === "SENSI") return "Sensi Medical";
      if (marca === "BD") return "BD";
      return marca.charAt(0) + marca.slice(1).toLowerCase();
    }
  }
  return "";
}

function nombreMostradorDis(descripcion) {
  let s = String(descripcion || "").trim();
  if (!s) return "";
  for (const [re, rep] of ABREV_DIS) s = s.replace(re, rep);
  s = s.replace(/\s+/g, " ").trim();
  return s
    .split(" ")
    .filter(Boolean)
    .map((w) => {
      const low = w.toLowerCase();
      if (/^\d/.test(w) || /^(ml|cm|mm|kg|fr|x)$/i.test(w)) return low;
      if (["de", "del", "la", "el", "con", "para", "en"].includes(low)) return low;
      return low.charAt(0).toUpperCase() + low.slice(1);
    })
    .join(" ");
}

function tokensNombre(s) {
  return norm(s)
    .split(/[^a-z0-9]+/)
    .filter((t) => t.length >= 2 && !STOP.has(t));
}

function scoreMatchNombre(a, b) {
  const ta = new Set(tokensNombre(a));
  const tb = new Set(tokensNombre(b));
  if (!ta.size || !tb.size) return 0;
  let inter = 0;
  ta.forEach((t) => { if (tb.has(t)) inter += 1; });
  const coverage = inter / Math.min(ta.size, tb.size);
  const jaccard = inter / (ta.size + tb.size - inter);
  return Math.max(coverage * 0.85, jaccard);
}

function matchPromexsa(disRow, promexsaRows, { minimo = 0.72 } = {}) {
  const nombre = disRow?.nombre || disRow?.descripcion || "";
  const marca = norm(disRow?.marca || "");
  let best = null;
  let bestScore = 0;
  for (const p of promexsaRows || []) {
    const score = scoreMatchNombre(nombre, p.nombre);
    if (score < minimo) continue;
    if (marca && p.marca && norm(p.marca) !== marca && !norm(p.nombre).includes(marca)) {
      continue;
    }
    if (score > bestScore) {
      bestScore = score;
      best = p;
    }
  }
  return best ? { row: best, score: bestScore } : null;
}

function imagenCatalogoSegura(url) {
  return urlImagenPublicaTienda(url);
}

function filaDermaexpress(row) {
  const ean = String(row.sku || row.ean || "").replace(/\D/g, "");
  const costo = Number(row.costo_proveedor);
  const disponible = String(row.disponible_proveedor) === "1" || row.disponible_proveedor === 1 || row.disponible_proveedor === true;
  const techo = Number(row.pvp_referencia);
  const cats = mapCategoriaDermaexpress();
  const costoOk = Number.isFinite(costo) && costo > 0;
  return {
    ean: ean.length >= 8 ? ean : "",
    sku: skuCatalogoBajoPedido(ean, { proveedor: FUENTE_DERMAEXPRESS, codigoProveedor: row.sku }),
    nombre: String(row.nombre || "").trim(),
    marca: String(row.marca || "").trim(),
    presentacion: String(row.subcategoria || "").trim(),
    ...cats,
    tipo: "marca",
    costo: costoOk ? costo : null,
    precio: 0,
    techo: Number.isFinite(techo) && techo > 0 ? techo : null,
    imagen_url: imagenCatalogoSegura(row.imagen_url),
    fuente: FUENTE_DERMAEXPRESS,
    sku_externo: String(row.sku || ""),
    disponible,
    url_proveedor: row.url_proveedor || "",
  };
}

function filaBirdman(row) {
  if (esMerchBirdman(row)) return null;
  const costo = Number(row.costo_base_25);
  const disponible = String(row.disponible_proveedor) === "1" || row.disponible_proveedor === 1 || row.disponible_proveedor === true;
  const techo = Number(row.pvp_sugerido_marca || row.precio_publico_sugerido);
  const cats = mapCategoriaBirdman(row);
  const costoOk = Number.isFinite(costo) && costo > 0;
  const ean = String(row.ean || row.codigo_barras || "").replace(/\D/g, "");
  return {
    ean: ean.length >= 8 ? ean : "",
    sku: skuCatalogoBajoPedido(ean, { proveedor: FUENTE_BIRDMAN, codigoProveedor: row.sku }),
    nombre: String(row.nombre || "").trim(),
    marca: String(row.marca || "Birdman").trim(),
    presentacion: String(row.variante || row.linea || "").trim(),
    ...cats,
    tipo: "marca",
    costo: costoOk ? costo : null,
    precio: 0,
    techo: Number.isFinite(techo) && techo > 0 ? techo : null,
    imagen_url: imagenCatalogoSegura(row.imagen_url),
    fuente: FUENTE_BIRDMAN,
    sku_externo: String(row.sku || ""),
    disponible,
    descripcion: String(row.descripcion || "").trim(),
  };
}

function filaEwafra(row, promexsaMatch) {
  const motivo = excluirFilaDis(row);
  if (motivo) return null;
  const crudo = row.descripcion || row.nombre || "";
  const nombre = (promexsaMatch?.nombre && promexsaMatch.score >= 0.8)
    ? promexsaMatch.nombre
    : nombreMostradorDis(crudo);
  const marca = row.marca || marcaDesdeDescripcionDis(crudo) || promexsaMatch?.marca || "";
  const costo = Number(row.costo ?? row.costo_lista6 ?? row.precio);
  const techo = Number(promexsaMatch?.precio_techo_mercado || promexsaMatch?.precio_publico_promexsa);
  const cats = mapCategoriaDispositivo();
  const imagen = imagenCatalogoSegura(promexsaMatch?.url_imagen || row.imagen_url);
  return {
    ean: String(row.ean || "").replace(/\D/g, ""),
    sku: skuCatalogoBajoPedido(row.ean, { proveedor: FUENTE_EWAFRA, codigoProveedor: row.codigo || row.sku }),
    nombre,
    marca,
    presentacion: String(row.unidad || row.presentacion || "").trim(),
    ...cats,
    tipo: "marca",
    costo,
    precio: 0,
    techo: Number.isFinite(techo) && techo > 0 ? techo : null,
    imagen_url: imagen,
    fuente: FUENTE_EWAFRA,
    sku_externo: String(row.codigo || row.sku || ""),
    disponible: true,
    descripcion_cruda: String(crudo).trim(),
    match_promexsa: promexsaMatch?.sku || null,
  };
}

const FUENTE_SUPLEMENTOS_MAYOREO = "suplementosmayoreo";

/** Frases de marca al inicio de nombre_completo cuando el CSV no partió la marca. */
const MARCAS_FRASE_SUPLEMENTO = [
  ["APPLIED NUTRITION", "Applied Nutrition"],
  ["ALL NATURE", "All Nature"],
  ["SASCHA FITNESS", "Sascha Fitness"],
  ["RED LINE", "Red Line"],
  ["FIT BUTTERS", "Fit Butters"],
  ["HIGH TECH PHARMACEUTICALS", "High Tech Pharmaceuticals"],
].sort((a, b) => b[0].length - a[0].length);

/** Código corto del mayorista → marca de mostrador. */
const PREFIJO_MARCA_SUPLEMENTO = {
  ALMX: "Allmax",
  ON: "Optimum Nutrition",
  INS: "Insane Labz",
  EVO: "Evogen Nutrition",
  MUT: "Mutant",
  HTP: "High Tech Pharmaceuticals",
  NT: "Nutrex",
  GA: "GAT Sport",
  CEL: "Cellucor",
  MMD: "MuscleMeds",
  DYM: "Dymatize",
  MT: "MuscleTech",
  UNI: "Universal Nutrition",
  GN: "Gaspari Nutrition",
  FINA: "Finaflex",
  NB: "Nature's Best",
  SYN: "Syntrax",
  SCI: "Scivation",
  LA: "Labrada",
  PBS: "Physical Building Systems",
  EVL: "EVL Nutrition",
  SL: "Saiyan Labz",
  USP: "USP Labs",
  CLP: "Cloma Pharma",
  ADV: "Advance Nutrition",
  AN: "Applied Nutrition",
  BLACKBEAR: "Blackbear",
  PROSUPPS: "ProSupps",
  BLOOM: "Bloom",
  REDEFINE: "Redefine",
  EUPHORIC: "Euphoric",
  SUPERLABS: "Superlabs",
  VIDANAT: "Vidanat",
  SPARTA: "Sparta",
  BASIC: "Basic",
  EMPOWER: "Empower",
  MUSCLEFIT: "MuscleFit",
  STEELFIT: "Steelfit",
  MONAV: "Monav",
  EAS: "EAS",
};

const SALTO_PREFIJO_SUPLEMENTO = new Set(["FUNNEL"]);

const NO_ES_MARCA_SUPLEMENTO = new Set([
  "CREATINA", "CREATINE", "WHEY", "PROTEIN", "PROTEINA", "BCAA", "OMEGA",
  "VITAMIN", "VITAMINA", "AMINO", "MASS", "ISO", "GOLD",
]);

const SIGLAS_SUPLEMENTO = new Set([
  "bcaa", "hmb", "nac", "zma", "cla", "dha", "epa", "eaa", "atp", "hcl",
  "tmg", "dhea", "c4", "on", "hd", "iso", "bpi", "bsn", "gat", "eas", "gh", "nad",
]);

/**
 * Hormonales, SARMs, clenbuterol y somatropina no van a la vitrina.
 * En mostrador el controlado pide receta; /conseguir no los publica.
 */
const RE_HORMONAL_SUPLEMENTO = /\b(stanozolol\w*|estanozolol\w*|stanovet|trenbolone\w*|trenbovet|oxandrolone\w*|nandrolone\w*|boldenone\w*|boldeprime|methandro\w*|methandien\w*|oxymetholone\w*|primobolan|masteron|mastabold|sustanon\w*|winstrol|clenbuterol|clembuterol|alphaclen|clenbuprime|clenmax|sarms?|andarine|cardarine|ostarine|ligandrol|ligadrol|ibutamoren|testolone|turinabol|anadrol|anavar|alphanavar|dianabol|dianadrol|testoviron|testex|deposteron|durateston|nebido|spiropent|parabolan|finajet|arimidex|anastrozole\w*|arimidrol|clomiphene|anaztro|proviron|mesterolone|drostanolone|decadurabolin|decabold|somatropina\w*|somatropin\w*|somatrope|gentropin|gonadotropin|pregnyl|testosterone|testosterona|testoprime|enatest|supertest|methelonone|methenolone\w*|superbull|rotterdam|biomedic|veterii?x)\b|\bionic\s*\+|(\bclen\b|\bclomi\b|\bclomid\b|\bprotest\b)|\b(4\s*limits|4lmt)\b|\bmk-\d+|\bgw-\d+|\brad-?\d+|\blgd-?\d+|\btesto\s+\d/i;

const RE_INYECTABLE_SUPLEMENTO = /\b(vial|ampulas?|amp\/|\biny\b|inyectable|lipoenzima|vacuna anti)\b/i;

const RE_MERCH_SUPLEMENTO = /\b(playera|playeras|t-?shirt|gorra|muestra|hoodie|camiseta)\b/i;

const RE_PESO_SUPLEMENTO = /\b(\d{1,3}(?:,\d{3})+|\d+(?:[.,]\d+)?)\s*(lbs|lb|kgs|kg|grs|gr|g|ml|oz)\b/gi;
const RE_CONTEO_SUPLEMENTO = /\b(\d+)\s*(servicios|servs|serv|capsulas|caps|cap|tabs|tab|ct|softgels|softgel|gomitas|gummies|gummy)\b/gi;
const RE_RUIDO_SUPLEMENTO = /\*[^*]*\*|\([^)]*\)/g;

function tituloSuplemento(s) {
  const parts = String(s || "").trim().split(/\s+/).filter(Boolean);
  return parts.map((w, i) => {
    const low = w.toLowerCase();
    if (SIGLAS_SUPLEMENTO.has(low)) return low.toUpperCase();
    if (/^(mg|mcg|g|kg|ml|lb|lbs|ui|iu)$/i.test(low)) {
      if (low === "ui" || low === "iu") return "UI";
      return low;
    }
    if (/^\d/.test(w)) return w.replace(/MG\b/i, "mg").replace(/MCG\b/i, "mcg");
    if (i > 0 && ["de", "del", "y", "con", "para", "en", "la", "el", "al"].includes(low)) return low;
    return w.split("-").map((p) => {
      if (!p) return p;
      const pl = p.toLowerCase();
      if (SIGLAS_SUPLEMENTO.has(pl)) return pl.toUpperCase();
      return pl.charAt(0).toUpperCase() + pl.slice(1);
    }).join("-");
  }).join(" ");
}

function tituloMarcaSuplemento(s) {
  const t = String(s || "").trim();
  if (!t) return "";
  if (t.length <= 4 && /^[A-Z0-9+]+$/.test(t)) return t;
  return tituloSuplemento(t);
}

function numeroSuplemento(raw) {
  const s = String(raw || "");
  if (/^\d{1,3}(,\d{3})+$/.test(s)) return s.replace(/,/g, "");
  return s.replace(",", ".");
}

function unidadPesoSuplemento(raw) {
  const u = String(raw || "").toLowerCase();
  if (u === "lbs" || u === "lb") return "lb";
  if (u === "kgs" || u === "kg") return "kg";
  if (u === "grs" || u === "gr" || u === "g") return "g";
  if (u === "oz") return "oz";
  if (u === "ml") return "ml";
  return u;
}

function unidadConteoSuplemento(raw) {
  const u = String(raw || "").toLowerCase();
  if (u === "serv" || u === "servs" || u === "servicios") return "servicios";
  if (u === "cap" || u === "caps" || u === "capsulas" || u === "softgel" || u === "softgels") return "cápsulas";
  if (u === "tab" || u === "tabs") return "tabletas";
  if (u === "gomitas" || u === "gummies" || u === "gummy") return "gomitas";
  return "piezas";
}

function eanDesdeImagenSuplemento(url) {
  let decoded = String(url || "");
  try { decoded = decodeURIComponent(decoded); } catch { /* url ya decodificada */ }
  const m = decoded.match(/\/(\d{8,14})\.(?:jpe?g|png|webp)/i);
  return m ? m[1] : "";
}

function motivoExclusionSuplementoMayoreo(texto) {
  const t = String(texto || "");
  if (RE_MERCH_SUPLEMENTO.test(t)) return "merch";
  if (RE_HORMONAL_SUPLEMENTO.test(t)) return "hormonal";
  if (RE_INYECTABLE_SUPLEMENTO.test(t)) return "inyectable";
  return null;
}

function mapCategoriaSuplemento(texto) {
  const t = norm(texto);
  if (/\b(shaker|blender|botella|toalla|towel|morral|mangas|aplicador|applicator)\b/.test(t)) {
    return { categoria: "Suplemento", subcategoria: "Accesorios" };
  }
  if (/\b(whey|protein|proteina|isolate|isoflex|iso\s*100|isopure|casein|caseina|gainer|carnivor|mass|syntha|nitro-tech|nitrotech)\b/.test(t)) {
    return { categoria: "Suplemento", subcategoria: "Proteína" };
  }
  if (/\b(vitamina|vitamin|d3|k2|nad|omega|magnesio|magnesium|colageno|collagen|ashwagand|berberina|probiot|multivit|melaton|zinc|resveratrol|maca|inositol|glutathione|glutation|biotina|biotin)\b/.test(t)) {
    return { categoria: "Vitaminas", subcategoria: "Vitaminas" };
  }
  return { categoria: "Suplemento", subcategoria: "Deportiva" };
}

function formaSuplemento(texto, presentacion) {
  const t = `${texto || ""} ${presentacion || ""}`;
  if (/\bc[aá]psulas?\b|\bcaps?\b|\bsoftgels?\b/i.test(t)) return "Cápsulas";
  if (/\btabletas?\b|\btabs?\b/i.test(t)) return "Tabletas";
  if (/\b(polvo|powder|whey|protein|proteina|creatin|isolate|gainer|bcaa|amino)\b/i.test(texto || "")
    && /\b(g|kg|lb)\b/i.test(presentacion || "")) return "Polvo";
  return "";
}

function limpiarNombreSuplemento(nombre) {
  let s = String(nombre || "");
  const partes = [];
  RE_PESO_SUPLEMENTO.lastIndex = 0;
  RE_CONTEO_SUPLEMENTO.lastIndex = 0;
  RE_RUIDO_SUPLEMENTO.lastIndex = 0;
  s = s.replace(RE_CONTEO_SUPLEMENTO, (full, num, unit) => {
    partes.push(`${num} ${unidadConteoSuplemento(unit)}`);
    return " ";
  });
  RE_PESO_SUPLEMENTO.lastIndex = 0;
  s = s.replace(RE_PESO_SUPLEMENTO, (full, num, unit) => {
    partes.push(`${numeroSuplemento(num)} ${unidadPesoSuplemento(unit)}`);
    return " ";
  });
  RE_RUIDO_SUPLEMENTO.lastIndex = 0;
  s = s.replace(RE_RUIDO_SUPLEMENTO, " ");
  s = s.replace(/"[^"]*"/g, " ");
  s = s.replace(/\b(oferta|nuevo sabor|nuevos sabores|nuevo|nueva)\b/gi, " ");
  s = s.replace(/\(\s*\)/g, " ").replace(/\s{2,}/g, " ").replace(/\s+([,.;])/g, "$1").trim();
  s = s.replace(/^[-–—,.\s]+|[-–—,.\s]+$/g, "").trim();
  const concentracion = (s.match(/\b\d+(?:[.,]\d+)?\s*(?:mg|mcg|ui|iu)\b/i) || [""])[0]
    .replace(/\s+/g, " ")
    .toLowerCase()
    .replace("iu", "UI")
    .replace("ui", "UI");
  return {
    nombre: tituloSuplemento(s),
    presentacion: partes.join(" · "),
    concentracion: concentracion || "",
  };
}

function separarMarcaSuplemento(row) {
  const marcaCol = String(row?.marca || "").trim();
  const nombreCol = String(row?.nombre || "").trim();
  const completo = String(row?.nombre_completo || "").trim();
  if (marcaCol && nombreCol) {
    return { marca: tituloMarcaSuplemento(marcaCol), nombre: nombreCol };
  }
  let texto = nombreCol || completo;
  let guard = 0;
  while (guard < 3) {
    guard += 1;
    const up = texto.toUpperCase();
    const frase = MARCAS_FRASE_SUPLEMENTO.find(([pref]) => up === pref || up.startsWith(`${pref} `));
    if (frase) {
      return { marca: frase[1], nombre: texto.slice(frase[0].length).trim() };
    }
    const tok = (texto.split(/\s+/)[0] || "").replace(/[.,]+$/g, "");
    const key = tok.toUpperCase();
    if (SALTO_PREFIJO_SUPLEMENTO.has(key)) {
      texto = texto.slice(tok.length).trim();
      continue;
    }
    if (PREFIJO_MARCA_SUPLEMENTO[key]) {
      return { marca: PREFIJO_MARCA_SUPLEMENTO[key], nombre: texto.slice(tok.length).trim() };
    }
    if (marcaCol) return { marca: tituloMarcaSuplemento(marcaCol), nombre: texto };
    if (key && key.length <= 16 && /^[A-Z0-9+]+$/.test(key) && !NO_ES_MARCA_SUPLEMENTO.has(key)) {
      return { marca: tituloMarcaSuplemento(key), nombre: texto.slice(tok.length).trim() };
    }
    break;
  }
  return { marca: marcaCol ? tituloMarcaSuplemento(marcaCol) : "", nombre: texto };
}

/**
 * Fila de Suplementos Mayoreo. `precio` del CSV es costo de mayoreo.
 * El precio público queda en 0 (Ordenar) hasta que el dueño lo revise.
 * Devuelve null si es merch, hormonal/inyectable o no trae costo.
 */
function filaSuplementosMayoreo(row) {
  const marcaNombre = separarMarcaSuplemento(row);
  const crudo = `${row?.marca || ""} ${row?.nombre || ""} ${row?.nombre_completo || ""} ${marcaNombre.nombre}`;
  if (motivoExclusionSuplementoMayoreo(crudo)) return null;
  const costo = Number(row?.precio ?? row?.costo);
  if (!Number.isFinite(costo) || costo <= 0) return null;
  const textoNombre = marcaNombre.nombre
    || String(row?.nombre || row?.nombre_completo || "").trim();
  const limpio = limpiarNombreSuplemento(textoNombre);
  let nombre = limpio.nombre || tituloSuplemento(textoNombre);
  const marcaLower = String(marcaNombre.marca || "").toLowerCase();
  if (marcaLower && nombre.toLowerCase().startsWith(marcaLower)) {
    const resto = nombre.slice(marcaNombre.marca.length).trim();
    if (resto.length >= 3) nombre = resto;
  }
  if (!nombre) return null;
  const cats = mapCategoriaSuplemento(`${nombre} ${marcaNombre.marca} ${limpio.presentacion}`);
  const ean = eanDesdeImagenSuplemento(row?.imagen_url);
  const codigo = String(row?.codigo || row?.sku || "").trim();
  const stock = Number(row?.stock);
  return {
    ean,
    sku: skuCatalogoBajoPedido(ean, { proveedor: FUENTE_SUPLEMENTOS_MAYOREO, codigoProveedor: codigo }),
    nombre,
    marca: marcaNombre.marca,
    presentacion: limpio.presentacion,
    concentracion: limpio.concentracion,
    forma_farmaceutica: formaSuplemento(nombre, limpio.presentacion),
    ...cats,
    tipo: "marca",
    costo,
    precio: 0,
    techo: null,
    imagen_url: imagenCatalogoSegura(row?.imagen_url),
    fuente: FUENTE_SUPLEMENTOS_MAYOREO,
    sku_externo: codigo,
    disponible: !Number.isFinite(stock) || stock > 0,
  };
}

function sqlEscape(s) {
  return String(s ?? "").replace(/'/g, "''");
}

function sqlNum(n, fallback = "null") {
  const x = Number(n);
  if (!Number.isFinite(x)) return fallback;
  return String(Math.round(x * 100) / 100);
}

function sqlTexto(s) {
  if (s == null || s === "") return "null";
  return `'${sqlEscape(s)}'`;
}

module.exports = {
  FUENTE_DERMAEXPRESS,
  FUENTE_BIRDMAN,
  FUENTE_EWAFRA,
  FUENTE_PROMEXSA,
  FUENTE_SUPLEMENTOS_MAYOREO,
  hashSku8,
  skuCatalogoBajoPedido,
  precioBajoPedido,
  esMerchBirdman,
  mapCategoriaBirdman,
  mapCategoriaDermaexpress,
  mapCategoriaDispositivo,
  excluirFilaDis,
  marcaDesdeDescripcionDis,
  nombreMostradorDis,
  tokensNombre,
  scoreMatchNombre,
  matchPromexsa,
  imagenCatalogoSegura,
  filaDermaexpress,
  filaBirdman,
  filaEwafra,
  filaSuplementosMayoreo,
  motivoExclusionSuplementoMayoreo,
  mapCategoriaSuplemento,
  separarMarcaSuplemento,
  sqlEscape,
  sqlNum,
  sqlTexto,
};
