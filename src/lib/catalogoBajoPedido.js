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
const FUENTE_MEPIEL = "mepiel";

/**
 * Fila Excel (1-indexed) del logo de cada laboratorio en
 * «ME Piel Lista de precios 2026». El logo vive en el dibujo, no en una celda.
 */
const BLOQUES_MARCA_MEPIEL_2026 = [
  [4, "Advaita"],
  [44, "Eucerin"],
  [140, "Bioderma"],
  [273, "Institut Esthederm"],
  [319, "Vichy"],
  [343, "Cantabria Labs"],
  [439, "Cell Pharma"],
  [464, "DS Laboratories"],
  [515, "Euderma"],
  [556, "Farmapiel"],
  [627, "Fedele"],
  [718, "CeraVe"],
  [778, "La Roche-Posay"],
  [924, "Isispharma"],
  [1041, "Galderma"],
  [1147, "Genové"],
  [1224, "Glenmark"],
  [1254, "ISDIN"],
  [1456, "Italmex"],
  [1558, "Leo Pharma"],
  [1581, "Ducray"],
  [1648, "Avène"],
  [1811, "Darrow"],
  [1851, "A-Derma"],
  [1896, "Remexa"],
  [1939, "Sesderma"],
  [2068, "Up Pharma"],
  [2088, "Etat Pur"],
  [2106, "Noreva"],
  [2156, "Uriage"],
  [2257, "Panalab"],
  [2343, "Armstrong"],
  [2374, "Babé"],
  [2412, "Apivita"],
  [2495, "SkinCeuticals"],
  [2595, "SVR"],
  [2621, "MartiDerm"],
  [2768, "Mustela"],
  [2821, "Dermaglós"],
  [2883, "Senti2"],
];

/** Bonificación de la hoja OFERTAS FIJAS. No baja el precio unitario de la lista. */
const OFERTA_MEPIEL_2026 = {
  Advaita: "10+1",
  Galderma: "10+1",
  "Cell Pharma": "10+1",
  ISDIN: "10+1",
  Fedele: "10+1",
  Genové: "10+1",
  Glenmark: "10+1",
  Italmex: "10+1 (excepto Hydrysage)",
  "Leo Pharma": "10+1",
  "Cantabria Labs": "10+1",
  Eucerin: "10+1",
  Farmapiel: "10+1",
  Avène: "10+1",
  "DS Laboratories": "10+1",
  Sesderma: "5+1",
  Isispharma: "5+1",
  Armstrong: "Leti AT4 5+1, Pilexil 3+1",
  Remexa: "Desde 50 piezas 10+1",
  "La Roche-Posay": "10+1 o 9.09%",
  Vichy: "10+1 o 9.09%",
  CeraVe: "10+1 o 9.09%",
  Bioderma: "Sin oferta (precio financiero)",
};

const TOKEN_LISTA_MEPIEL = {
  fps: "FPS",
  spf: "SPF",
  uv: "UV",
  uva: "UVA",
  uvb: "UVB",
  ml: "ml",
  g: "g",
  gr: "g",
  mg: "mg",
  h2o: "H2O",
  ds: "DS",
  ar: "AR",
  kit: "Kit",
};

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

function marcaMepielPorFila(excelRow) {
  const n = Number(excelRow);
  if (!Number.isFinite(n)) return "";
  let marca = "";
  for (const [row, name] of BLOQUES_MARCA_MEPIEL_2026) {
    if (n >= row) marca = name;
    else break;
  }
  return marca;
}

function ofertaMepielPorMarca(marca) {
  return OFERTA_MEPIEL_2026[marca] || "";
}

function redondearDinero(n) {
  const x = Number(n);
  if (!Number.isFinite(x)) return null;
  return Math.round(x * 100) / 100;
}

/** El precio que ME Piel cobra es «Precio cliente c/IVA». El público es techo, no costo. */
function costoClienteMepiel(row) {
  return redondearDinero(row?.cliente_con ?? row?.precio_cliente_con_iva);
}

function separarUnidadesLista(s) {
  return String(s || "")
    .replace(/(\d)\s*(ml|mg|gr|g)\b/gi, (_, num, unit) => {
      const u = unit.toLowerCase() === "gr" ? "g" : unit.toLowerCase();
      return `${num} ${u}`;
    })
    .replace(/\s{2,}/g, " ")
    .trim();
}

function nombreDesdeListaMepiel(desc) {
  const original = String(desc || "").replace(/\s+/g, " ").trim();
  if (!original) return "";
  const mixed = original !== original.toUpperCase() && original !== original.toLowerCase();
  const titled = mixed
    ? original
    : original
      .toLowerCase()
      .split(/(\s+|-|\/)/)
      .map((part) => {
        if (!part || /^\s+$/.test(part) || part === "-" || part === "/") return part;
        if (/^\d/.test(part)) return part;
        const key = part.toLowerCase();
        if (TOKEN_LISTA_MEPIEL[key]) return TOKEN_LISTA_MEPIEL[key];
        if (["de", "del", "la", "el", "y", "con", "para", "en"].includes(key)) return key;
        return key.charAt(0).toUpperCase() + key.slice(1);
      })
      .join("");
  return separarUnidadesLista(titled)
    .replace(/\bspf\s*(\d+\+?)/gi, "SPF$1")
    .replace(/\bfps\s*(\d+\+?)/gi, "FPS $1");
}

function mapCategoriaMepiel() {
  return { categoria: "Cuidado personal", subcategoria: "Dermatología" };
}

function puntajeDuplicadoMepiel(fila) {
  const uni = String(fila?.uni || "");
  let score = Math.min(String(fila?.nombre_lista || fila?.nombre || "").length, 120);
  if (/^pza\b|^pieza\b/i.test(uni.trim())) score += 200;
  score += Number(fila?.fila || 0) / 100000;
  return score;
}

/**
 * Una fila de la lista 2026. `precio` queda en 0: el dueño no ha publicado
 * la vitrina. `costo` es lo que ME Piel cobra (cliente c/IVA).
 */
function filaMepiel(row) {
  const ean = String(row?.ean || "").replace(/\D/g, "");
  if (ean.length < 8) return null;
  const costo = costoClienteMepiel(row);
  if (costo == null || costo <= 0) return null;
  const techo = redondearDinero(row?.publico_con ?? row?.precio_publico_con_iva);
  const marca = String(row?.marca || marcaMepielPorFila(row?.fila) || "").trim();
  const nombreLista = String(row?.descripcion || row?.nombre || "").trim();
  if (!nombreLista) return null;
  const cats = mapCategoriaMepiel();
  return {
    ean,
    sku: skuCatalogoBajoPedido(ean, { proveedor: FUENTE_MEPIEL, codigoProveedor: ean }),
    nombre: nombreLista,
    nombre_lista: nombreLista,
    marca,
    presentacion: "",
    ...cats,
    tipo: "marca",
    costo,
    precio: 0,
    techo: techo && techo > 0 ? techo : null,
    imagen_url: "",
    fuente: FUENTE_MEPIEL,
    sku_externo: ean,
    disponible: true,
    linea: String(row?.linea || "").trim(),
    uni: String(row?.uni || "").trim(),
    fila: Number(row?.fila) || 0,
    oferta: ofertaMepielPorMarca(marca),
  };
}

function filasMepielDesdeRaws(raws) {
  const groups = new Map();
  for (const raw of raws || []) {
    const fila = filaMepiel(raw);
    if (!fila) continue;
    const arr = groups.get(fila.ean) || [];
    arr.push(fila);
    groups.set(fila.ean, arr);
  }
  const out = [];
  for (const arr of groups.values()) {
    arr.sort((a, b) => puntajeDuplicadoMepiel(b) - puntajeDuplicadoMepiel(a));
    out.push(arr[0]);
  }
  return out;
}

/** Si el mismo EAN ya tiene costo de otro mayoreo, se queda el más barato. */
function costoMayoreoPreferido(actual, nuevo) {
  const a = Number(actual);
  const n = Number(nuevo);
  const aOk = Number.isFinite(a) && a > 0;
  const nOk = Number.isFinite(n) && n > 0;
  if (!nOk) return aOk ? a : null;
  if (!aOk) return n;
  return Math.min(a, n);
}

function enriquecerFilaMepiel(fila, fuentes = {}) {
  const { aplicarFichaMostrador } = require("./nombreMostrador");
  const derma = fuentes.derma || null;
  const extra = fuentes.extra || null;
  let nombre = String(fila.nombre_lista || fila.nombre || "");
  let marca = String(fila.marca || "");
  let imagen = "";
  let imagen_origen = "";
  if (derma && String(derma.nombre || "").trim()) nombre = String(derma.nombre).trim();
  else if (extra && String(extra.nombre || "").trim()) nombre = String(extra.nombre).trim();
  nombre = nombreDesdeListaMepiel(nombre)
    .replace(/,\s+(?=\d)/g, " ")
    .replace(/\.\s*$/g, "");
  if (derma && String(derma.marca || "").trim()) marca = String(derma.marca).trim();
  if (derma && derma.imagen_url) {
    imagen = imagenCatalogoSegura(derma.imagen_url);
    if (imagen) imagen_origen = "dermaexpress";
  }
  if (!imagen && extra && extra.imagen_url) {
    imagen = imagenCatalogoSegura(extra.imagen_url);
    if (imagen) imagen_origen = extra.origen || "extra";
  }
  const ficha = aplicarFichaMostrador({
    nombre,
    marca,
    presentacion: fila.presentacion || "",
  });
  let nombreFicha = ficha.nombre || nombre;
  const letras = nombreFicha.replace(/[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ]/g, "");
  if (letras && letras === letras.toUpperCase()) {
    nombreFicha = nombreDesdeListaMepiel(nombreFicha);
  }
  return {
    ...fila,
    nombre: nombreFicha,
    marca: ficha.marca || marca,
    presentacion: ficha.presentacion || "",
    concentracion: ficha.concentracion || "",
    forma_farmaceutica: ficha.forma_farmaceutica || "",
    imagen_url: imagen,
    imagen_origen,
    precio: 0,
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
  FUENTE_MEPIEL,
  BLOQUES_MARCA_MEPIEL_2026,
  marcaMepielPorFila,
  ofertaMepielPorMarca,
  costoClienteMepiel,
  nombreDesdeListaMepiel,
  filaMepiel,
  filasMepielDesdeRaws,
  costoMayoreoPreferido,
  enriquecerFilaMepiel,
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
