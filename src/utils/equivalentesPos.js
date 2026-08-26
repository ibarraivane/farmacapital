/**
 * Opciones del mismo principio activo, agrupadas por marca, para el mostrador.
 *
 * El buscador ordena por parecido de texto, así que la patente siempre cae al
 * final: "Treda" no se parece a "neomicina caolín pectina". Aquí se arma el
 * grupo completo para mostrarlo de un vistazo, sin depender de cómo se llama.
 */

import { normalizeForSearch } from "../utils";

/** Sales, prefijos y conectores que no cambian de qué sustancia hablamos. */
const RUIDO_SUSTANCIA = new Set([
  "clorhidrato", "hidrocloruro", "maleato", "sulfato", "fosfato", "nitrato",
  "acetato", "tartrato", "citrato", "succinato", "besilato", "mesilato",
  "sodico", "sodica", "sodio", "calcico", "calcio", "potasico", "potasio",
  "magnesico", "acido", "dihidratado", "monohidratado", "trihidrato",
  "anhidro", "micronizado", "purificado", "del", "con", "mas", "por",
]);

/**
 * Palabras de categoría, no de sustancia. Si aparecen, el campo trae un rubro
 * ("surfactantes fórmula capilar") y agrupar juntaría 23 shampoos distintos.
 */
const NO_ES_SUSTANCIA = new Set([
  "producto", "homeopatico", "homeopatica", "natural", "naturales",
  "material", "curacion", "plastico", "sintetico", "sinteticos",
  "suplemento", "nutricional", "alimento", "cosmetico", "cosmeticos",
  "formula", "surfactantes", "tensioactivos", "detergentes",
  "capilar", "corporal", "facial", "emolientes", "humectantes",
  "antitranspirante", "desodorante", "jabon", "latex", "absorbente",
  "celulosa", "limpiadora", "limpiador", "solucion", "higiene", "aseo",
  "varios", "otros", "generico", "genericos",
]);

/** Un grupo más grande que esto ya no es una decisión de mostrador. */
const MAX_OPCIONES_GRUPO = 16;

/**
 * Clave estable del principio activo: sin dosis, sin sales, sin orden.
 * "Neomicina + Caolin + Pectina" y "Neomicina / Caolín y Pectina" caen igual.
 */
/** El POS recalcula esto en cada tecla sobre todo el catálogo; se cachea por producto. */
const cacheClave = new WeakMap();

export function claveSustancia(producto) {
  if (producto && typeof producto === "object" && cacheClave.has(producto)) {
    return cacheClave.get(producto);
  }
  const clave = calcularClaveSustancia(producto);
  if (producto && typeof producto === "object") cacheClave.set(producto, clave);
  return clave;
}

function calcularClaveSustancia(producto) {
  const crudo = String(producto?.principio_activo || producto?.denominacion_generica || "");
  let s = normalizeForSearch(crudo);
  if (!s) return "";

  s = s.replace(/\b\d+([.,]\d+)?\s*(mg|mcg|ug|g|gr|kg|ml|l|lt|ui|iu|meq|%)\b/g, " ");
  s = s.replace(/\d+\s*\/\s*\d+/g, " ");
  s = s.replace(/\b\d+([.,]\d+)?\b/g, " ");
  s = s.replace(/[^a-z]+/g, " ");

  const palabras = s.split(" ").filter((w) => w.length > 2 && !RUIDO_SUSTANCIA.has(w));
  if (!palabras.length) return "";
  if (palabras.some((w) => NO_ES_SUSTANCIA.has(w))) return "";

  return [...new Set(palabras)].sort().join("+");
}

function precioNum(p) {
  const n = parseFloat(p?.precio);
  return Number.isFinite(n) ? n : Infinity;
}

/** Patente = lo que el laboratorio vende con su marca; el resto, genérico. */
export function esPatente(producto) {
  return String(producto?.tipo || "").trim().toLowerCase() === "marca";
}

function nombreDeMarca(producto) {
  const marca = String(producto?.marca || "").trim();
  if (marca && !/^gen[eé]rico$/i.test(marca)) return marca;
  const nombre = String(producto?.nombre || "").trim();
  return nombre.split(/\s+/).slice(0, 2).join(" ") || "Sin marca";
}

function fotoDe(producto) {
  return producto?.imagen_url || producto?.imagen_mobile_url || "";
}

/** Etiqueta legible del grupo: la escritura más corta que ya trae el catálogo. */
function etiquetaSustancia(opciones) {
  const textos = opciones
    .map((p) => String(p?.principio_activo || p?.denominacion_generica || "").trim())
    .filter(Boolean)
    .sort((a, b) => a.length - b.length);
  return textos[0] || "";
}

/**
 * Grupo de equivalentes de `item`, ya listo para pintar: una tarjeta por marca,
 * patente primero y luego lo más barato. Devuelve null si no hay nada que comparar.
 */
export function agruparOpcionesEquivalentes(productos, item) {
  const clave = claveSustancia(item);
  if (!clave) return null;

  const opciones = (productos || []).filter(
    (p) => p?.activo !== false && claveSustancia(p) === clave
  );
  if (opciones.length < 2 || opciones.length > MAX_OPCIONES_GRUPO) return null;

  const porMarca = new Map();
  for (const p of opciones) {
    const marca = nombreDeMarca(p);
    const llave = normalizeForSearch(marca);
    if (!porMarca.has(llave)) {
      porMarca.set(llave, { marca, patente: esPatente(p), opciones: [] });
    }
    const grupo = porMarca.get(llave);
    grupo.opciones.push(p);
    if (esPatente(p)) grupo.patente = true;
  }

  const marcas = [...porMarca.values()].map((g) => {
    const ordenadas = [...g.opciones].sort((a, b) => precioNum(a) - precioNum(b));
    const conFoto = ordenadas.find((p) => fotoDe(p));
    return {
      ...g,
      opciones: ordenadas,
      precioDesde: precioNum(ordenadas[0]),
      foto: conFoto ? fotoDe(conFoto) : "",
    };
  });

  if (marcas.length < 2) return null;

  marcas.sort((a, b) => {
    if (a.patente !== b.patente) return a.patente ? -1 : 1;
    return a.precioDesde - b.precioDesde;
  });

  return {
    clave,
    etiqueta: etiquetaSustancia(opciones),
    total: opciones.length,
    marcas,
  };
}

/** Cuántos de los primeros resultados se miran para decidir de qué habla la búsqueda. */
const RESULTADOS_QUE_DECIDEN = 8;

/**
 * De qué sustancia habla la búsqueda, mirando los primeros resultados y no
 * sólo el primero: "tempra" trae arriba el antigripal, pero lo que la clienta
 * pide casi siempre es el paracetamol que viene abajo.
 */
export function grupoEquivalentesDeBusqueda(productos, resultados) {
  const top = (resultados || []).slice(0, RESULTADOS_QUE_DECIDEN);
  if (!top.length) return null;

  const candidatos = new Map();
  top.forEach((p, orden) => {
    const clave = claveSustancia(p);
    if (!clave) return;
    if (!candidatos.has(clave)) candidatos.set(clave, { n: 0, orden, ancla: p });
    candidatos.get(clave).n += 1;
  });

  // Gana la sustancia que más se repite; empate, la que salió antes. Si esa no
  // arma tablero (una sola marca), se prueba la siguiente antes de rendirse.
  const ordenados = [...candidatos.values()].sort((a, b) => b.n - a.n || a.orden - b.orden);
  for (const c of ordenados) {
    const grupo = agruparOpcionesEquivalentes(productos, c.ancla);
    if (grupo) return grupo;
  }
  return agruparOpcionesEquivalentes(productos, top[0]);
}
