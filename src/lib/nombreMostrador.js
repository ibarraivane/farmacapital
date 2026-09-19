/**
 * Ficha partida: el nombre de mostrador es corto; empaque y volumen
 * van a presentación. La dosis (mg, %) se queda en el nombre para no
 * colapsar Ibuprofeno 400 mg con Ibuprofeno 600 mg.
 *
 * No inventa marca ni principio activo.
 */

"use strict";

const FORMA_PAIRS = [
  [/tabletas?\s+efervescentes?/i, "Tabletas efervescentes"],
  [/c[aá]psulas?|\bcaps?\.?\b/i, "Cápsulas"],
  [/tabletas?|\btabs?\.?\b/i, "Tabletas"],
  [/comprimidos?/i, "Comprimidos"],
  [/grageas?/i, "Grageas"],
  [/suspensi[oó]n/i, "Suspensión"],
  [/soluci[oó]n/i, "Solución"],
  [/jarabe/i, "Jarabe"],
  [/\bcrema\b/i, "Crema"],
  [/ung[uü]ento/i, "Ungüento"],
  [/pomada/i, "Pomada"],
  [/\bgel\b/i, "Gel"],
  [/\bgotas\b/i, "Gotas"],
  [/\b(?:spray|aerosol)\b/i, "Spray"],
  [/\bfluido\b/i, "Fluido"],
  [/\bsobres?\b/i, "Sobres"],
];

const RE_PACK_END =
  /(?:c\/\s*\d+(?:\s*(?:tabletas?|tabs?\.?|c[aá]psulas?|caps?\.?|comprimidos?|pzas?|piezas?))?|caja\s+(?:con\s+)?\d+(?:\s*(?:tabletas?|tabs?\.?|c[aá]psulas?|caps?\.?))?|\d+\s*(?:tabletas?|tabs?\.?|c[aá]psulas?|caps?\.?|comprimidos?|grageas?|sobres?|pzas?|piezas?)|\d+(?:[.,]\d+)?\s*(?:ml|l)\b|\d+(?:[.,]\d+)?\s*(?:g|gr)\b)\s*$/i;

const RE_DOSE = /(\d+(?:[.,]\d+)?(?:\s*\/\s*\d+(?:[.,]\d+)?)*)\s*(mg|mcg|µg|ug|ui|iu|meq|%)\b/i;
const RE_FPS = /\bfps\s*\d+\+?/i;
const RE_FORMA_END =
  /(?:tabletas?\s+efervescentes?|c[aá]psulas?|tabletas?|comprimidos?|grageas?|suspensi[oó]n|soluci[oó]n|jarabe|ung[uü]ento|pomada|gotas|spray|aerosol|fluido|sobres?|\bcrema\b|\bgel\b)\s*$/i;

function trimNombre(s) {
  return String(s || "")
    .replace(/[\s,;·|/]+$/g, "")
    .replace(/^[\s,;·|/]+/g, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

function textoOpcional(v) {
  const s = String(v == null ? "" : v).trim();
  return s || null;
}

function normalizarPresentacion(raw) {
  let s = trimNombre(raw);
  if (!s) return null;
  s = s.replace(/^caja\s+(?:con\s+)?/i, "C/");
  s = s.replace(/^c\/\s*/i, "C/");
  s = s.replace(/\btabs?\.?\b/i, "tabletas");
  s = s.replace(/\bcaps?\.?\b/i, "cápsulas");
  s = s.replace(/\bml\b/i, "ml");
  s = s.replace(/\bgr\b/i, "g");
  s = s.replace(/\s{2,}/g, " ").trim();
  return s || null;
}

function extraerForma(texto) {
  const t = String(texto || "");
  if (/\ben\s+polvo\b/i.test(t)) return null;
  for (const [re, label] of FORMA_PAIRS) {
    if (re.test(t)) return label;
  }
  return null;
}

function extraerConcentracion(texto) {
  const t = String(texto || "");
  const fps = t.match(RE_FPS);
  if (fps) {
    return fps[0].replace(/\s+/g, " ").replace(/fps/i, "FPS").trim();
  }
  const dose = t.match(RE_DOSE);
  if (!dose) return null;
  const num = String(dose[1]).replace(/\s+/g, "");
  const unit = String(dose[2]).toLowerCase() === "µg" ? "mcg" : String(dose[2]).toLowerCase();
  return `${num} ${unit}`;
}

/**
 * Parte un texto sucio en columnas. Nunca inventa marca ni principio.
 * La dosis (mg / %) se copia a concentracion pero se queda en `nombre`.
 * Empaque y volumen (C/24, 20 tabletas, 40 ml) salen del nombre.
 *
 * @param {string} texto
 * @param {{ presentacion?: string, concentracion?: string, forma?: string }} [opts]
 */
function partirNombreMostrador(texto, opts = {}) {
  const original = trimNombre(texto);
  let presentacion = textoOpcional(opts.presentacion);
  let concentracion = textoOpcional(opts.concentracion);
  let forma = textoOpcional(opts.forma);
  let raw = original;

  if (!raw) {
    return { nombre: "", presentacion, concentracion, forma };
  }

  if (!forma) forma = extraerForma(raw);

  const pack = raw.match(RE_PACK_END);
  if (pack) {
    if (!presentacion) presentacion = normalizarPresentacion(pack[0]);
    if (!forma) forma = extraerForma(pack[0]);
    raw = trimNombre(raw.slice(0, pack.index));
  }
  if (forma && RE_FORMA_END.test(raw) && !/\ben\s+polvo\b/i.test(raw)) {
    raw = trimNombre(raw.replace(RE_FORMA_END, ""));
  }

  if (!concentracion) concentracion = extraerConcentracion(raw);

  return {
    nombre: raw || original,
    presentacion,
    concentracion,
    forma,
  };
}

function mismaMarcaAlInicio(nombre, marca) {
  const n = String(nombre || "").trim();
  const m = String(marca || "").trim();
  if (!n || !m) return false;
  const n0 = n.toLowerCase();
  const m0 = m.toLowerCase();
  if (!n0.startsWith(m0)) return false;
  const rest = n.slice(m.length);
  return rest === "" || /^\s/.test(rest);
}

/**
 * Aplica la partición a una ficha ya armada. No pisa marca ni principio.
 * Si el nombre empieza por la marca y queda línea comercial, la marca se
 * queda solo en `marca`.
 */
function aplicarFichaMostrador(ficha) {
  if (!ficha || typeof ficha !== "object") return ficha;
  const parted = partirNombreMostrador(ficha.nombre, {
    presentacion: ficha.presentacion,
    concentracion: ficha.concentracion,
    forma: ficha.forma_farmaceutica,
  });
  let nombre = parted.nombre;
  const marca = textoOpcional(ficha.marca);
  if (marca && mismaMarcaAlInicio(nombre, marca)) {
    const resto = trimNombre(nombre.slice(marca.length));
    if (resto.length >= 3) nombre = resto;
  }
  return {
    ...ficha,
    nombre,
    presentacion: textoOpcional(ficha.presentacion) || parted.presentacion,
    concentracion: textoOpcional(ficha.concentracion) || parted.concentracion,
    forma_farmaceutica: textoOpcional(ficha.forma_farmaceutica) || parted.forma,
  };
}

function fichaTieneIdentidad(ficha) {
  if (!ficha || !textoOpcional(ficha.nombre)) return false;
  return Boolean(textoOpcional(ficha.marca) || textoOpcional(ficha.principio_activo));
}

module.exports = {
  partirNombreMostrador,
  aplicarFichaMostrador,
  fichaTieneIdentidad,
  extraerConcentracion,
};
