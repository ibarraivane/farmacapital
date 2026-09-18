/**
 * Catálogo bajo pedido (Dermaexpress, Birdman, Ewafra/DIS, Promexsa techo).
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
  sqlEscape,
  sqlNum,
  sqlTexto,
};
