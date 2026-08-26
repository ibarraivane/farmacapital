/** Opciones visuales del POS relacionadas por principio activo. */
import { normalizeForSearch } from "../utils";
import { normalizedTextFuzzyMatch } from "./fuzzySearch";

const RUIDO_SUSTANCIA = new Set(["clorhidrato", "hidrocloruro", "maleato", "sulfato", "fosfato", "nitrato", "acetato", "tartrato", "citrato", "succinato", "besilato", "mesilato", "sodico", "sodica", "sodio", "calcico", "calcio", "potasico", "potasio", "magnesico", "acido", "dihidratado", "monohidratado", "trihidrato", "anhidro", "micronizado", "purificado", "del", "con", "mas", "por"]);
const NO_ES_SUSTANCIA = new Set(["producto", "homeopatico", "homeopatica", "natural", "naturales", "material", "curacion", "plastico", "sintetico", "sinteticos", "suplemento", "nutricional", "alimento", "cosmetico", "cosmeticos", "formula", "surfactantes", "tensioactivos", "detergentes", "capilar", "corporal", "facial", "emolientes", "humectantes", "antitranspirante", "desodorante", "jabon", "latex", "absorbente", "celulosa", "limpiadora", "limpiador", "solucion", "higiene", "aseo", "varios", "otros", "generico", "genericos"]);
const CONSULTAS_AMBIGUAS = new Set(["para", "dolor", "medicina", "medicamento", "pastilla", "pastillas", "jarabe", "crema", "gotas", "adulto", "nino", "nina"]);
const MAX_OPCIONES_GRUPO = 24;
const RESULTADOS_QUE_DECIDEN = 8;
const cacheClave = new WeakMap();

export function claveSustancia(producto) {
  if (producto && typeof producto === "object" && cacheClave.has(producto)) return cacheClave.get(producto);
  const crudo = String(producto?.principio_activo || producto?.denominacion_generica || "");
  let s = normalizeForSearch(crudo);
  if (s) s = s.replace(/\b\d+([.,]\d+)?\s*(mg|mcg|ug|g|gr|kg|ml|l|lt|ui|iu|meq|%)\b/g, " ").replace(/\d+\s*\/\s*\d+/g, " ").replace(/\b\d+([.,]\d+)?\b/g, " ").replace(/[^a-z]+/g, " ");
  const palabras = s.split(" ").filter((w) => w.length > 2 && !RUIDO_SUSTANCIA.has(w));
  const clave = !palabras.length || palabras.some((w) => NO_ES_SUSTANCIA.has(w)) ? "" : [...new Set(palabras)].sort().join("+");
  if (producto && typeof producto === "object") cacheClave.set(producto, clave);
  return clave;
}

function norm(value) { return normalizeForSearch(String(value || "")).replace(/\s+/g, " ").trim(); }

function formaDe(producto) {
  const s = norm(`${producto?.forma_farmaceutica || ""} ${producto?.presentacion || ""} ${producto?.nombre || ""}`);
  if (/\b(tableta|tabletas|tab|comprimido|comprimidos|gragea|grageas)\b/.test(s)) return "tabletas";
  if (/\b(capsula|capsulas|cap)\b/.test(s)) return "capsulas";
  if (/\b(suspension|jarabe|solucion oral)\b/.test(s)) return "suspension";
  if (/\b(gota|gotas)\b/.test(s)) return "gotas";
  if (/\b(unguento|pomada)\b/.test(s)) return "unguento";
  if (/\b(crema)\b/.test(s)) return "crema";
  if (/\b(ampolleta|inyectable|frasco ampula)\b/.test(s)) return "inyectable";
  if (/\b(polvo|sobre|sobres)\b/.test(s)) return "polvo";
  return norm(producto?.forma_farmaceutica);
}

function viaDe(producto) {
  const declarada = norm(producto?.via_administracion || producto?.via || "");
  if (declarada) return declarada;
  const s = norm(`${producto?.forma_farmaceutica || ""} ${producto?.presentacion || ""} ${producto?.nombre || ""}`);
  if (/oftalm|ocular/.test(s)) return "oftalmica";
  if (/otico|auricular/.test(s)) return "otica";
  if (/nasal/.test(s)) return "nasal";
  if (/topico|topica|crema|unguento|pomada/.test(s)) return "topica";
  if (/inyectable|ampolleta|intramuscular|intravenosa/.test(s)) return "inyectable";
  if (/tableta|capsula|comprimido|gragea|suspension|jarabe|solucion oral|sobre/.test(s)) return "oral";
  return "";
}

// Si falta un atributo en uno de los dos, no afirmamos compatibilidad.
// Dos valores vacíos sí son iguales; vacío frente a un dato declarado, no.
function igualSiDeclarado(a, b) { return a === b; }
function concentracionDe(p) { return norm(p?.concentracion); }
function presentacionDe(p) { return norm(p?.contenido || p?.presentacion); }

export function clasificarRelacionProducto(producto, ancla) {
  if (claveSustancia(producto) !== claveSustancia(ancla)) return "ninguna";
  if (!igualSiDeclarado(formaDe(producto), formaDe(ancla)) || !igualSiDeclarado(viaDe(producto), viaDe(ancla)) || !igualSiDeclarado(concentracionDe(producto), concentracionDe(ancla))) return "otra_forma";
  return igualSiDeclarado(presentacionDe(producto), presentacionDe(ancla)) ? "misma_configuracion" : "otro_contenido";
}

function precioNum(p) { const n = parseFloat(p?.precio); return Number.isFinite(n) ? n : Infinity; }

/** Sólo respeta el dato explícito; no infiere clasificación desde el nombre. */
export function etiquetaTipoProducto(producto) {
  const tipo = norm(producto?.tipo);
  if (tipo === "marca" || tipo === "patente") return "Patente";
  if (tipo === "generico") return "Genérico";
  return "";
}

function consultaEsClara(query, resultados) {
  const q = norm(query);
  if (q.length < 4 || CONSULTAS_AMBIGUAS.has(q)) return false;
  const tokens = q.split(" ").filter((t) => t.length >= 4 && !CONSULTAS_AMBIGUAS.has(t));
  if (!tokens.length) return false;
  return (resultados || []).slice(0, RESULTADOS_QUE_DECIDEN).some((p) => {
    const campos = [p?.nombre, p?.marca, p?.principio_activo, p?.denominacion_generica].map(norm).filter(Boolean);
    return tokens.every((token) => campos.some((campo) => normalizedTextFuzzyMatch(token, campo)));
  });
}

/** La vendedora escribió la marca: todos esos SKU van arriba, no solo el primero. */
export function coincideConsultaDirecta(producto, query) {
  const q = norm(query);
  if (!q || q.length < 4) return false;
  const marca = norm(producto?.marca);
  const nombre = norm(producto?.nombre);
  const dist = norm(producto?.denominacion_distintiva);
  if (marca && marca.length >= 4 && (marca === q || marca.startsWith(q) || q.startsWith(marca))) return true;
  const tipo = norm(producto?.tipo);
  const esPatenteTipo = tipo === "marca" || tipo === "patente";
  const primera = (nombre.split(" ")[0] || "");
  if (primera === q && (esPatenteTipo || primera === marca)) return true;
  const primDist = (dist.split(" ")[0] || "");
  if (primDist === q && (esPatenteTipo || primDist === marca)) return true;
  return false;
}

function etiquetaDirectaDe(productos, query) {
  const marcas = [...new Set((productos || []).map((p) => String(p?.marca || "").trim()).filter(Boolean))];
  if (marcas.length === 1) return marcas[0];
  const q = String(query || "").trim();
  if (!q) return "Lo que buscaste";
  return q.charAt(0).toUpperCase() + q.slice(1);
}

function ordenarProductos(opciones, query) {
  const q = norm(query);
  return [...opciones].sort((a, b) => {
    const aDirecto = q && [a?.nombre, a?.marca].some((x) => norm(x).includes(q));
    const bDirecto = q && [b?.nombre, b?.marca].some((x) => norm(x).includes(q));
    if (aDirecto !== bDirecto) return aDirecto ? -1 : 1;
    return precioNum(a) - precioNum(b) || String(a?.nombre || "").localeCompare(String(b?.nombre || ""), "es");
  });
}

export function grupoOpcionesRelacionadas(productos, ancla, query = "") {
  const clave = claveSustancia(ancla);
  if (!clave) return null;
  const opciones = (productos || []).filter((p) => p?.activo !== false && claveSustancia(p) === clave);
  if (opciones.length < 2 || opciones.length > MAX_OPCIONES_GRUPO) return null;
  const secciones = { mismaConfiguracion: [], otroContenido: [], otrasPresentaciones: [] };
  opciones.forEach((p) => {
    const relacion = clasificarRelacionProducto(p, ancla);
    if (relacion === "misma_configuracion") secciones.mismaConfiguracion.push(p);
    else if (relacion === "otro_contenido") secciones.otroContenido.push(p);
    else if (relacion === "otra_forma") secciones.otrasPresentaciones.push(p);
  });
  Object.keys(secciones).forEach((k) => { secciones[k] = ordenarProductos(secciones[k], query); });

  const coincidenciasDirectas = [];
  const vistos = new Set();
  ["mismaConfiguracion", "otroContenido", "otrasPresentaciones"].forEach((k) => {
    secciones[k] = secciones[k].filter((p) => {
      if (!coincideConsultaDirecta(p, query)) return true;
      if (!vistos.has(p.id)) {
        vistos.add(p.id);
        coincidenciasDirectas.push(p);
      }
      return false;
    });
  });

  return {
    clave,
    etiqueta: String(ancla?.principio_activo || ancla?.denominacion_generica || "").trim(),
    etiquetaDirecta: coincidenciasDirectas.length ? etiquetaDirectaDe(coincidenciasDirectas, query) : "",
    ancla,
    total: opciones.length,
    coincidenciasDirectas: ordenarProductos(coincidenciasDirectas, query),
    ...secciones,
  };
}

export function grupoEquivalentesDeBusqueda(productos, resultados, query = "") {
  if (!consultaEsClara(query, resultados)) return null;
  const top = (resultados || []).slice(0, RESULTADOS_QUE_DECIDEN);
  const q = norm(query);

  // Marca o nombre escrito de verdad (Treda, Nineka), no un prefijo de sustancia
  // que también abre otro SKU ("neomici" → "Neomici Polimixi…").
  const anclaDirecta = top.find((p) => {
    if (!q) return false;
    const marca = norm(p?.marca);
    const nombre = norm(p?.nombre);
    const dist = norm(p?.denominacion_distintiva);
    if ([marca, nombre, dist].includes(q)) return true;
    if (marca && q.length >= 4 && marca.length >= 4 && (marca.startsWith(q) || q.startsWith(marca))) return true;
    const variasPalabras = q.split(" ").length >= 2;
    if (variasPalabras && [nombre, dist].some((campo) => campo.startsWith(`${q} `) || campo.includes(` ${q} `))) return true;
    return false;
  });
  if (anclaDirecta) {
    // Si el producto directo no tiene alternativas, no buscamos un grupo ajeno:
    // se conserva la lista/ficha normal para esa búsqueda.
    return grupoOpcionesRelacionadas(productos, anclaDirecta, query);
  }

  const candidatos = new Map();
  top.forEach((p, orden) => {
    const clave = claveSustancia(p);
    if (!clave) return;
    if (!candidatos.has(clave)) candidatos.set(clave, { n: 0, orden, ancla: p });
    candidatos.get(clave).n += 1;
  });
  const ordenados = [...candidatos.values()].sort((a, b) => b.n - a.n || a.orden - b.orden);
  for (const candidato of ordenados) {
    const grupo = grupoOpcionesRelacionadas(productos, candidato.ancla, query);
    if (grupo) return grupo;
  }
  return null;
}

export const agruparOpcionesEquivalentes = grupoOpcionesRelacionadas;
export const esPatente = (producto) => etiquetaTipoProducto(producto) === "Patente";
