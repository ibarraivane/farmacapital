/**
 * Normalizador determinista. Sin IA.
 * Si no hay piezas_por_empaque, el registro es NO_NORMALIZABLE.
 */

"use strict";

function quitarAcentos(texto) {
  return String(texto || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");
}

function colapsar(texto) {
  return quitarAcentos(texto)
    .toLowerCase()
    .replace(/&/g, " ")
    .replace(/[^\w\s./-]/g, " ")
    .replace(/[_-]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

const FORMAS = [
  { forma: "tableta", re: /\b(tabs?|tabletas?|comprimidos?|comp\b|grageas?)\b/ },
  { forma: "cápsula", re: /\b(capsulas?|caps?|caplets?)\b/ },
  { forma: "suspensión", re: /\b(suspensiones?|susp)\b/ },
  { forma: "solución", re: /\b(soluciones?|sol\b)\b/ },
  { forma: "inyectable", re: /\b(inyectables?|iny|ampolletas?|ampollas?|amp)\b/ },
  { forma: "crema", re: /\b(cremas?|geles?|gel\b|unguentos?|pomadas?)\b/ },
  { forma: "supositorio", re: /\b(supositorios?|supos?)\b/ },
];

const RE_CONC = /(\d+(?:[.,]\d+)?)\s*(mg\/ml|mcg\/ml|ug\/ml|ui\/ml|mg|mcg|ug|g|ui)\b/;
const RE_PACK = [
  /\bc\s*\/\s*(\d+)\b/,
  /\bcaja\s+con\s+(\d+)/,
  /(?:x|por)\s*(\d+)\b/,
  /(\d+)\s*(?:pzas?|piezas?|pz|uds?|unidades?)\b/,
  /(\d+)\s*(?:tabs?|tabletas?|capsulas?|caps?|comprimidos?)\b/,
];

const MARCAS_CONOCIDAS = [
  "sanfer", "bayer", "pfizer", "gsk", "novartis", "roche", "abbott",
  "liomont", "pisa", "silanes", "senosiain", "tempra", "tylenol",
  "aspirina", "next", "dorixina", "flanax", "advil",
];

function extraerForma(norm) {
  for (const f of FORMAS) {
    if (f.re.test(norm)) return f.forma;
  }
  return null;
}

function extraerConcentracion(norm) {
  const m = norm.match(RE_CONC);
  if (!m) return { valor: null, unidad: null };
  const valor = Number(String(m[1]).replace(",", "."));
  let unidad = m[2];
  if (unidad === "ug" || unidad === "mcg") unidad = "mcg";
  if (unidad === "ui") unidad = "UI";
  if (unidad === "ui/ml") unidad = "UI/ml";
  return { valor, unidad };
}

function extraerPiezas(norm) {
  for (const re of RE_PACK) {
    const m = norm.match(re);
    if (m) {
      const n = parseInt(m[1], 10);
      if (n > 0 && n < 10000) return n;
    }
  }
  return null;
}

function extraerMarca(norm) {
  for (const marca of MARCAS_CONOCIDAS) {
    const re = new RegExp(`(?:^|\\s)${marca}(?:\\s|$)`);
    if (re.test(norm)) return marca;
  }
  return null;
}

function extraerSustancia(norm, conc, forma) {
  let s = norm;
  if (conc && conc.valor != null) {
    s = s.replace(RE_CONC, " ");
  }
  s = s.replace(/\bc\s*\/\s*\d+\b/g, " ");
  s = s.replace(/\bcaja\s+con\s+\d+/g, " ");
  s = s.replace(/\b\d+\s*(?:pzas?|piezas?|pz|uds?|unidades?)\b/g, " ");
  s = s.replace(/\b\d+\s*(?:tabs?|tabletas?|capsulas?|caps?|comprimidos?)\b/g, " ");
  s = s.replace(/\b(tabs?|tabletas?|capsulas?|caps?|comprimidos?|comp|grageas?|suspensiones?|susp|soluciones?|sol|inyectables?|iny|ampolletas?|cremas?|geles?|supositorios?)\b/g, " ");
  s = s.replace(/\b(caja|con|de|para|uso|oral|adulto|infantil|pediatrico)\b/g, " ");
  if (forma) {
    /* ya se quitaron alias */
  }
  const marca = extraerMarca(s);
  if (marca) s = s.replace(new RegExp(`\\b${marca}\\b`), " ");
  s = s.replace(/\s+/g, " ").trim();
  return s || null;
}

function normalizarNombreCrudo(nombreCrudo) {
  const norm = colapsar(nombreCrudo);
  const conc = extraerConcentracion(norm);
  const forma = extraerForma(norm);
  const piezas = extraerPiezas(norm);
  const marca = extraerMarca(norm);
  const sustancia = extraerSustancia(norm, conc, forma);

  return {
    nombre_norm: norm,
    sustancia_activa: sustancia,
    concentracion_valor: conc.valor,
    concentracion_unidad: conc.unidad,
    forma_farmaceutica: forma,
    piezas_por_empaque: piezas,
    marca,
  };
}

function normalizarRegistro(registro) {
  const extraido = normalizarNombreCrudo(registro.nombre_crudo);
  const piezas = extraido.piezas_por_empaque;
  if (!piezas || piezas < 1) {
    return {
      ...registro,
      ...extraido,
      precio_unitario: null,
      estado_norm: "NO_NORMALIZABLE",
    };
  }
  const precio = Number(registro.precio);
  return {
    ...registro,
    ...extraido,
    precio_unitario: Math.round((precio / piezas) * 10000) / 10000,
    estado_norm: "NORMALIZADO",
  };
}

function clasificarTipoComercial(producto) {
  const tipo = colapsar(producto && producto.tipo);
  const rx = Boolean(producto && producto.requiere_receta);
  if (tipo === "generico") return "generico";
  if (tipo === "marca" && rx) return "patente";
  if (tipo === "marca" && !rx) return "otc";
  if (rx) return "patente";
  return "otc";
}

module.exports = {
  quitarAcentos,
  colapsar,
  extraerForma,
  extraerConcentracion,
  extraerPiezas,
  extraerMarca,
  extraerSustancia,
  normalizarNombreCrudo,
  normalizarRegistro,
  clasificarTipoComercial,
};
